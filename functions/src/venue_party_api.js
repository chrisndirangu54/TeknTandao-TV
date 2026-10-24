'use strict';
const admin=require('firebase-admin'),{onRequest}=require('firebase-functions/v2/https');
const crypto=require('node:crypto');
const {authorize}=require('./security');
const {venueInput,joinCode,codeDigest,admissionState,canOperate,paidFeatureRequest,publicVenue}=require('./venue_party_core');
if(!admin.apps.length)admin.initializeApp();
const db=admin.firestore();
function secured(fn){return onRequest({region:'europe-west1',cors:false},async(req,res)=>{
 res.set('Cache-Control','no-store');
 if(req.method!=='POST')return res.status(405).json({error:'method_not_allowed'});
 let user;try{user=await authorize(req,t=>admin.auth().verifyIdToken(t,true));}
 catch(_){return res.status(401).json({error:'unauthenticated'});}
 try{await fn(req,res,user.uid);}catch(err){console.error('venue_party',{name:err?.name});return res.status(400).json({error:'invalid_request'});}
});}
const createVenueParty=secured(async(req,res,uid)=>{
 const input=venueInput(req.body),id=crypto.randomUUID(),code=joinCode();
 const venue={...input,ownerId:uid,outputOperatorId:uid,liveDjId:input.djMode==='live'?uid:null,
  status:'open',joinCodeHash:codeDigest(code),members:{[uid]:'host'},
  createdAt:admin.firestore.FieldValue.serverTimestamp()};
 await db.collection('venueParties').doc(id).create(venue);
 res.status(201).json({roomId:id,joinCode:code,sharePath:'/party/'+id});
});
const discoverVenueParties=secured(async(req,res)=>{
 // Coarse area only; do not collect, store, or publish precise GPS coordinates.
 const area=typeof req.body?.approxArea==='string'?req.body.approxArea.trim().slice(0,70):'';
 if(area.length<2)return res.status(400).json({error:'area_required'});
 const snap=await db.collection('venueParties').where('approxArea','==',area).limit(40).get();
 const rooms=snap.docs.filter(d=>d.get('status')==='open'&&d.get('discoverable')===true&&d.get('admission')==='public')
   .map(d=>publicVenue(d.data(),d.id));
 res.status(200).json({rooms});
});
const joinVenueParty=secured(async(req,res,uid)=>{
 const roomId=req.body?.roomId,code=req.body?.joinCode;
 if(typeof roomId!=='string'||roomId.length>100)return res.status(400).json({error:'invalid_room'});
 const ref=db.collection('venueParties').doc(roomId);
 const outcome=await db.runTransaction(async tx=>{
  const snap=await tx.get(ref);if(!snap.exists||snap.get('status')!=='open')return 'unavailable';
  const room=snap.data(),member=room.members?.[uid];
  if(member)return member;
  if(room.admission!=='public'&&(typeof code!=='string'||codeDigest(code)!==room.joinCodeHash))return 'invite_required';
  if(Object.keys(room.members||{}).length>=100)return 'full';
  const status=admissionState(room.admission);
  tx.update(ref,{['members.'+uid]:status});
  return status;
 });
 res.status(['invite_required','unavailable','full'].includes(outcome)?403:200).json({status:outcome});
});
const approveVenueMember=secured(async(req,res,uid)=>{
 const {roomId,memberId}=req.body||{};
 if(typeof roomId!=='string'||typeof memberId!=='string'||!/^\w[\w-]{0,127}$/.test(memberId))return res.status(400).json({error:'invalid_member'});
 const ref=db.collection('venueParties').doc(roomId);
 const outcome=await db.runTransaction(async tx=>{
  const snap=await tx.get(ref),room=snap.data();
  if(!room||room.ownerId!==uid||room.members?.[memberId]!=='pending_approval')return false;
  tx.update(ref,{['members.'+memberId]:'admitted'});return true;
 });
 res.status(outcome?200:403).json({ok:outcome});
});
const nominateOutput=secured(async(req,res,uid)=>{
 const {roomId,operatorId}=req.body||{};
 if(typeof roomId!=='string'||typeof operatorId!=='string'||!/^\w[\w-]{0,127}$/.test(operatorId))return res.status(400).json({error:'invalid_request'});
 const ref=db.collection('venueParties').doc(roomId),room=await ref.get();
 if(!room.exists||room.get('ownerId')!==uid||!['host','admitted'].includes(room.get('members')?.[operatorId]))return res.status(403).json({error:'not_allowed'});
 await ref.update({outputOperatorId:operatorId});
 res.status(200).json({operatorId});
});
const prepareVenuePurchase=secured(async(req,res,uid)=>{
 const request=paidFeatureRequest(req.body),room=await db.collection('venueParties').doc(request.roomId).get();
 if(!room.exists||room.get('status')!=='open'||!['host','admitted'].includes(room.get('members')?.[uid]))return res.status(403).json({error:'not_admitted'});
 // Never take client amount as the price. Locate a configured server-side offering.
 const offer=await db.collection('venueOffers').doc(request.feature).get();
 if(!offer.exists||offer.get('enabled')!==true||offer.get('currency')!=='KES'||
 !Number.isSafeInteger(offer.get('amountMinor'))||offer.get('amountMinor')<0)
 return res.status(404).json({error:'offer_unavailable'});
 const id=crypto.createHash('sha256').update(uid+'\0'+request.idempotencyKey).digest('hex');
 const ref=db.collection('venueFeatureOrders').doc(id);
 const result=await db.runTransaction(async tx=>{
  const old=await tx.get(ref);
  if(old.exists){const prev=old.data();if(prev.roomId!==request.roomId||prev.feature!==request.feature)throw Error('conflict');return prev;}
  const value={roomId:request.roomId,feature:request.feature,customerId:uid,
   amountMinor:offer.get('amountMinor'),currency:'KES',message:request.message,
   status:'pending_payment',paymentVerified:false,createdAt:admin.firestore.FieldValue.serverTimestamp()};
  tx.create(ref,value);return value;
 });
 res.status(200).json({orderId:id,status:result.status,amountMinor:result.amountMinor,currency:'KES'});
});

const findPartyUser=secured(async(req,res,uid)=>{
 const handle=req.body?.handle;
 if(typeof handle!=='string'||!/^[a-z0-9_]{3,24}$/.test(handle))return res.status(400).json({error:'invalid_handle'});
 const user=await db.collection('publicPartyHandles').doc(handle).get();
 if(!user.exists||user.get('discoverable')!==true)return res.status(404).json({error:'not_found'});
 res.status(200).json({handle,displayName:user.get('displayName')||handle});
});
const pendingVenueAdmissions=secured(async(req,res,uid)=>{
 const id=req.body?.roomId;if(typeof id!=='string')return res.status(400).json({error:'invalid_room'});
 const room=await db.collection('venueParties').doc(id).get();
 if(!room.exists||room.get('ownerId')!==uid)return res.status(403).json({error:'host_only'});
 const members=room.get('members')||{};
 res.status(200).json({pending:Object.entries(members).filter(([,role])=>role==='pending_approval')
   .slice(0,100).map(([memberId])=>memberId)});
});
module.exports={createVenueParty,discoverVenueParties,joinVenueParty,approveVenueMember,nominateOutput,prepareVenuePurchase,findPartyUser,pendingVenueAdmissions};
