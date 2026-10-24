'use strict';
const test=require('node:test');const assert=require('node:assert/strict');
const {roomInput,accessible,hashInvite,cleanMessage,playerState}=require('../src/watch_party_core');
test('private room refuses strangers',()=>assert.equal(accessible({status:'open',visibility:'private',hostId:'a',members:['a'],inviteHash:hashInvite('valid-invitation-token')},'b','wrong-token-value-123'),false));
test('private invitation permits entry',()=>assert.equal(accessible({status:'open',visibility:'private',hostId:'a',members:['a'],inviteHash:hashInvite('valid-invitation-token')},'b','valid-invitation-token'),true));
test('public room is accessible for a signed-in viewer',()=>assert.equal(accessible({status:'open',visibility:'public',hostId:'a',members:[]},'b'),true));
test('rejects invalid media and oversized chat',()=>{assert.throws(()=>roomInput({kind:'unknown',visibility:'public',title:'Hi',mediaId:'x'}));assert.throws(()=>cleanMessage('x'.repeat(501)));});
test('rejects invalid playback command',()=>assert.throws(()=>playerState({action:'seek',positionMs:-1})));
