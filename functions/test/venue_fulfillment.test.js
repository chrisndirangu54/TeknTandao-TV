'use strict';
const test=require('node:test'),assert=require('node:assert/strict');
const {transition,eligibleForQueue,displayPriority}=require('../src/venue_fulfillment');
test('only verified billing can confirm payment',()=>{assert.equal(transition('pending_payment','paid_verified','host'),false);assert.equal(transition('pending_payment','paid_verified','verified_billing'),true);});
test('DJ controls paid request approval, not settlement',()=>{assert.equal(transition('awaiting_dj','approved','dj'),true);assert.equal(transition('awaiting_dj','approved','payer'),false);});
test('pending payment never jumps queue',()=>{assert.equal(displayPriority({status:'pending_payment',paymentVerified:false,feature:'priority_request'}),false);assert.equal(displayPriority({status:'approved',paymentVerified:true,feature:'priority_request'}),true);});
