'use strict';
const crypto=require('node:crypto');
const {onRequest}=require('firebase-functions/v2/https');
const admin=require('firebase-admin');
const {authorize}=require('./security');
const {roomInput,hashInvite,accessible,cleanMessage,playerState}=require('./watch_party_core');
if(!admin.apps.length)admin.initializeApp();
const db=admin.firestore();
function endpoint(handler){
 return onRequest({region:'europe-west1',cors:false},async(req,res)=>{
  res.set('Cache-Control','no-store');
  if(req.method!=='POST')return res.status(405).json({error:'method_not_allowed'});
  let principal;
  try{principal=await authorize(req,token=>admin.auth().verifyIdToken(token,true));}
  catch(_){return res.status(401).json({error:'unauthenticated'});}
  try{return await handler(req,res,principal.uid);}
  catch(e){console.error('watch_party',{name:e.name});return res.status(400).json({error:'invalid_request'});}
 });
}
const createWatchParty=endpoint(async(req,res,uid)=>{
 const input=roomInput(req.body);
 // The catalogue must be rights-verified. The token for playback is still
 // separately issued by the playback service per participant.
 const media=await db.collection('watchPartyMedia').doc(input.mediaId).get();
 if(!media.exists || media.get('kind')!==input.kind || media.get('watchPartyAllowed')!==true ||
 media.get('rightsVerified')!==true)return res.status(403).json({error:'media_not_authorized'});
 const id=crypto.randomUUID(),invite=input.visibility==='private'?crypto.randomBytes(24).toString('base64url'):null;
 await db.collection('watchParties').doc(id).create({...input,hostId:uid,members:[uid],
   inviteHash:invite?hashInvite(invite):null,status:'open',
   playback:{action:'pause',positionMs:0,updatedAt:admin.firestore.FieldValue.serverTimestamp()},
   createdAt:admin.firestore.FieldValue.serverTimestamp()});
 return res.status(201).json({roomId:id,inviteToken:invite});
});
const joinWatchParty=endpoint(async(req,res,uid)=>{
 const id=req.body?.roomId;
 if(typeof id!=='string'||!/^[0-9a-f-]{36}$/.test(id))return res.status(400).json({error:'invalid_room'});
 const ref=db.collection('watchParties').doc(id);
 const result=await db.runTransaction(async tx=>{
  const snap=await tx.get(ref);if(!snap.exists)return 'not_found';
  const room=snap.data();
  if(!accessible(room,uid,req.body.inviteToken))return 'forbidden';
  if(room.members.includes(uid))return 'joined';
  if(room.members.length>=25)return 'full';
  tx.update(ref,{members:admin.firestore.FieldValue.arrayUnion(uid)});
  return 'joined';
 });
 return res.status(result==='joined'?200:result==='not_found'?404:403).json({status:result});
});
const partyAction=endpoint(async(req,res,uid)=>{
 const id=req.body?.roomId;
 if(typeof id!=='string'||!/^[0-9a-f-]{36}$/.test(id))return res.status(400).json({error:'invalid_room'});
 const state=playerState(req.body);
 const ref=db.collection('watchParties').doc(id);
 const outcome=await db.runTransaction(async tx=>{
  const snap=await tx.get(ref);const room=snap.data();
  if(!room||room.status!=='open'||room.hostId!==uid)return false;
  tx.update(ref,{playback:{...state,updatedAt:admin.firestore.FieldValue.serverTimestamp()}});
  return true;
 });
 return res.status(outcome?200:403).json({ok:outcome});
});
const partyComment=endpoint(async(req,res,uid)=>{
 const id=req.body?.roomId,text=cleanMessage(req.body?.text);
 if(typeof id!=='string'||!/^[0-9a-f-]{36}$/.test(id))return res.status(400).json({error:'invalid_room'});
 const ref=db.collection('watchParties').doc(id);
 const outcome=await db.runTransaction(async tx=>{
  const snap=await tx.get(ref);const room=snap.data();
  if(!room||room.status!=='open'||!room.members.includes(uid))return false;
  const message=db.collection('watchPartyComments').doc();
  tx.create(message,{roomId:id,authorId:uid,text,createdAt:admin.firestore.FieldValue.serverTimestamp()});
  return true;
 });
 return res.status(outcome?201:403).json({ok:outcome});
});
module.exports={createWatchParty,joinWatchParty,partyAction,partyComment};
