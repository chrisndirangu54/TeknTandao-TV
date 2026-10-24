'use strict';
const admin=require('firebase-admin'),{onRequest}=require('firebase-functions/v2/https');
const {authorize}=require('./security');
const {trackRequest,tipRequest,tipId,rankQueue}=require('./music_party_core');
if(!admin.apps.length)admin.initializeApp();
const db=admin.firestore();
async function hasMusicEntitlement(uid) {
 const snap=await db.collection('subscriptions').where('customerId','==',uid).limit(100).get();
 const now=Date.now();
 return snap.docs.some(s=>{
  if(!['TV','ISP_TV_BUNDLE'].includes(s.get('product'))||!['active','trialing'].includes(s.get('status')))return false;
  const start=s.get('startsAt')?.toDate?.()?.getTime?.();
  const end=s.get('endsAt')?.toDate?.()?.getTime?.();
  return (start==null||start<=now)&&(end==null||end>now);
 });
}
const secured=handler=>onRequest({region:'europe-west1',cors:false},async(req,res)=>{
 res.set('Cache-Control','no-store');if(req.method!=='POST')return res.status(405).json({error:'method'});
 let principal;try{principal=await authorize(req,t=>admin.auth().verifyIdToken(t,true));}
 catch(_){return res.status(401).json({error:'unauthenticated'});}
 try{await handler(req,res,principal.uid);}catch(e){console.error('music_api',e.name);res.status(400).json({error:'invalid_request'});}
});
const proposeTrack=secured(async(req,res,uid)=>{
 const {roomId,trackId}=trackRequest(req.body);
 if(!await hasMusicEntitlement(uid))return res.status(403).json({error:'subscription_required'});
 const roomRef=db.collection('watchParties').doc(roomId),trackRef=db.collection('musicTracks').doc(trackId);
 const [room,track]=await Promise.all([roomRef.get(),trackRef.get()]);
 if(!room.exists||room.get('kind')!=='music'||!room.get('members')?.includes(uid))return res.status(403).json({error:'not_member'});
 if(!track.exists||track.get('rightsVerified')!==true||track.get('partyAllowed')!==true)return res.status(403).json({error:'track_unavailable'});
 const ref=roomRef.collection('queue').doc(trackId);
 await db.runTransaction(async tx=>{
  const old=await tx.get(ref);if(!old.exists)tx.create(ref,{trackId,requesterId:uid,createdAt:admin.firestore.FieldValue.serverTimestamp()});
 });
 return res.status(200).json({trackId,queued:true});
});
const voteTrack=secured(async(req,res,uid)=>{
 const {roomId,trackId}=trackRequest(req.body);
 if(!await hasMusicEntitlement(uid))return res.status(403).json({error:'subscription_required'});
 const roomRef=db.collection('watchParties').doc(roomId);
 const voteRef=roomRef.collection('votes').doc(uid),queueRef=roomRef.collection('queue').doc(trackId);
 const result=await db.runTransaction(async tx=>{
  const [room,track,previous]=await Promise.all([tx.get(roomRef),tx.get(queueRef),tx.get(voteRef)]);
  if(!room.exists||room.get('kind')!=='music'||!room.get('members')?.includes(uid)||!track.exists)return false;
  tx.set(voteRef,{trackId,voterId:uid,updatedAt:admin.firestore.FieldValue.serverTimestamp()});
  return true;
 });
 return res.status(result?200:403).json({ok:result});
});
const musicQueue=secured(async(req,res,uid)=>{
 const id=req.body?.roomId;if(typeof id!=='string')return res.status(400).json({error:'invalid_room'});
 if(!await hasMusicEntitlement(uid))return res.status(403).json({error:'subscription_required'});
 const ref=db.collection('watchParties').doc(id),room=await ref.get();
 if(!room.exists||room.get('kind')!=='music'||!room.get('members')?.includes(uid))return res.status(403).json({error:'not_member'});
 const [queue,votes]=await Promise.all([ref.collection('queue').limit(100).get(),ref.collection('votes').limit(200).get()]);
 const tally={};for(const v of votes.docs){const t=v.get('trackId');tally[t]=(tally[t]||0)+1;}
 const tracks=rankQueue(queue.docs.map(d=>({trackId:d.id,requesterId:d.get('requesterId'),createdAt:d.get('createdAt')?.toDate?.()?.toISOString?.()??new Date().toISOString()})),tally);
 return res.status(200).json({queue:tracks.map(({trackId,score})=>({trackId,votes:tally[trackId]??0,score}))});
});
const createTvTipIntent=secured(async(req,res,uid)=>{
 const request=tipRequest(req.body);if(request.recipientId===uid)return res.status(400).json({error:'self_tip'});
 const recipient=await db.collection('creatorProfiles').doc(request.recipientId).get();
 if(!recipient.exists||recipient.get('payoutEligible')!==true)return res.status(403).json({error:'recipient_unavailable'});
 const id=tipId(uid,request.idempotencyKey),ref=db.collection('tvTipIntents').doc(id);
 const record=await db.runTransaction(async tx=>{
  const previous=await tx.get(ref);
  if(previous.exists){const old=previous.data();if(old.recipientId!==request.recipientId||old.amountMinor!==request.amountMinor||old.context!==request.context)throw Error('conflicting_key');return old;}
  const value={...request,payerId:uid,status:'pending_payment',paymentVerified:false,createdAt:admin.firestore.FieldValue.serverTimestamp()};
  tx.create(ref,value);return value;
 });
 return res.status(200).json({intentId:id,status:record.status,amountMinor:record.amountMinor,currency:record.currency});
});
module.exports={proposeTrack,voteTrack,musicQueue,createTvTipIntent};
