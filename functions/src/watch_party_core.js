'use strict';
const crypto=require('node:crypto');
const KINDS=new Set(['movie','tv','podcast']);
function roomInput(body){
 if(!body||!KINDS.has(body.kind)||!['public','private'].includes(body.visibility)||
 typeof body.title!=='string'||body.title.trim().length<2||body.title.length>100||
 !/^[A-Za-z0-9_-]{1,100}$/.test(body.mediaId??'')) throw new Error('invalid_room');
 return {kind:body.kind,title:body.title.trim(),visibility:body.visibility,mediaId:body.mediaId};
}
function hashInvite(code){return crypto.createHash('sha256').update(code).digest('hex');}
function accessible(room,uid,invite){
 if(!room||room.status!=='open') return false;
 if(room.hostId===uid || (Array.isArray(room.members)&&room.members.includes(uid)))return true;
 if(room.visibility==='public')return true;
 return typeof invite==='string'&&invite.length>=16&&hashInvite(invite)===room.inviteHash;
}
function cleanMessage(text){
 if(typeof text!=='string'||text.trim().length===0||text.length>500)throw new Error('invalid_message');
 return text.trim();
}
function playerState(state){
 if(!state||!['play','pause','seek'].includes(state.action)||
 !Number.isInteger(state.positionMs)||state.positionMs<0||state.positionMs>86400000)
 throw new Error('invalid_sync');
 return {action:state.action,positionMs:state.positionMs};
}
module.exports={roomInput,hashInvite,accessible,cleanMessage,playerState};
