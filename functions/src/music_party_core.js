'use strict';
const crypto=require('node:crypto');
const assertId=x=>typeof x==='string'&&/^[A-Za-z0-9_-]{1,100}$/.test(x);
function trackRequest(body){
 if(!body||!assertId(body.roomId)||!assertId(body.trackId))throw Error('invalid_track_request');
 return {roomId:body.roomId,trackId:body.trackId};
}
function rankQueue(queue,votes,seed=0){
 return queue.map((t,i)=>({...t,score:(votes[t.trackId]||0)*100+
 Math.min(20,Math.floor((Date.now()-new Date(t.createdAt).getTime())/60000))+
 (t.requesterId===t.hostId?3:0),order:i})).sort((a,b)=>b.score-a.score||a.order-b.order);
}
function beatVisualState(beat){
 const keys=['beat','onset','bass','mids','treble','rms','brightness','dropLikelihood'];
 if(!beat||keys.some(k=>typeof beat[k]!=='number'||!Number.isFinite(beat[k])||beat[k]<0||beat[k]>1))throw Error('invalid_beat_state');
 return {pulse:beat.beat,shake:beat.onset,particles:beat.bass,hueShift:beat.brightness,glitch:beat.treble,drop:beat.dropLikelihood};
}
function tipRequest(body){
 if(!body||!assertId(body.recipientId)||!['creator','dj','host','broadcaster'].includes(body.recipientKind)||
 !Number.isSafeInteger(body.amountMinor)||body.amountMinor<100||body.amountMinor>100000000||
 !assertId(body.idempotencyKey)||!['tv','music','podcast','watch_party'].includes(body.context))throw Error('invalid_tip');
 return {recipientId:body.recipientId,recipientKind:body.recipientKind,
 amountMinor:body.amountMinor,currency:'KES',context:body.context,idempotencyKey:body.idempotencyKey};
}
function tipId(uid,key){return crypto.createHash('sha256').update(uid+'\0'+key).digest('hex');}
module.exports={trackRequest,rankQueue,beatVisualState,tipRequest,tipId};
