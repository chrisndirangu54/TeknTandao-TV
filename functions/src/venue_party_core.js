'use strict';
const crypto=require('node:crypto');
const TYPES=new Set(['club','party','matatu','event','virtual']);
function venueInput(x){
 if(!x||!TYPES.has(x.type)||typeof x.name!=='string'||x.name.trim().length<3||x.name.length>80||
 !['public','invite','approval','paid'].includes(x.admission)||!['ai','live'].includes(x.djMode))
 throw Error('invalid_venue');
 return {type:x.type,name:x.name.trim(),admission:x.admission,djMode:x.djMode,
  discoverable:x.discoverable===true,approxArea:typeof x.approxArea==='string'?x.approxArea.slice(0,70):''};
}
function joinCode(){return crypto.randomBytes(18).toString('base64url');}
function codeDigest(x){return crypto.createHash('sha256').update(x).digest('hex');}
function admissionState(mode){return mode==='public'||mode==='invite'?'admitted':'pending_approval';}
function canOperate(room,uid){return room&&room.status==='open'&&room.outputOperatorId===uid;}
function paidFeatureRequest(x){
 if(!x||!['song_request','priority_request','shoutout','dedication','admission','tip'].includes(x.feature)||
 typeof x.roomId!=='string'||!/^[a-zA-Z0-9_-]{1,100}$/.test(x.roomId)||
 !Number.isSafeInteger(x.amountMinor)||x.amountMinor<0||
 !/^[a-zA-Z0-9_-]{8,100}$/.test(x.idempotencyKey||''))throw Error('invalid_feature_request');
 if(['priority_request','shoutout','dedication'].includes(x.feature)&&
 (typeof x.message!=='string'||x.message.length>180))throw Error('invalid_message');
 return {roomId:x.roomId,feature:x.feature,amountMinor:x.amountMinor,currency:'KES',
  idempotencyKey:x.idempotencyKey,message:(x.message||'').trim().slice(0,180)};
}
function publicVenue(room,id){return {id,name:room.name,type:room.type,approxArea:room.approxArea||'',
 djMode:room.djMode,admission:room.admission};}
module.exports={venueInput,joinCode,codeDigest,admissionState,canOperate,paidFeatureRequest,publicVenue};
