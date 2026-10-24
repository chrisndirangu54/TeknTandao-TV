'use strict';
const test=require('node:test'),assert=require('node:assert/strict');
const {venueInput,codeDigest,joinCode,admissionState,canOperate,paidFeatureRequest}=require('../src/venue_party_core');
test('venue creation requires explicit discovery preferences',()=>{
 assert.equal(venueInput({name:'Nairobi Night Ride',type:'matatu',admission:'approval',djMode:'live',discoverable:false}).discoverable,false);
 assert.throws(()=>venueInput({name:'Bad',type:'taxi',admission:'public',djMode:'ai'}));
});
test('invite token uses a strong digest',()=>{
 const code=joinCode();assert.ok(code.length>=16);assert.equal(codeDigest(code).length,64);
});
test('paid admission is not auto-approved',()=>assert.equal(admissionState('paid'),'pending_approval'));
test('only nominated operator can use venue output',()=>{
 const room={status:'open',outputOperatorId:'d1'};
 assert.equal(canOperate(room,'d1'),true);assert.equal(canOperate(room,'other'),false);
});
test('paid-feature client amount cannot be negative',()=>{
 assert.throws(()=>paidFeatureRequest({roomId:'abc',feature:'priority_request',amountMinor:-1,idempotencyKey:'request123',message:'Hi'}));
});
