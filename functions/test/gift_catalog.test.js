'use strict';
const test=require('node:test'),assert=require('node:assert/strict');
const {GIFTS,giftDetails,normalizeBeatSyncFrame}=require('../src/gift_catalog');
test('only approved gift prices exist',()=>{assert.equal(giftDetails('coffee').amountMinor,25000);assert.throws(()=>giftDetails('unlisted'));});
test('BeatSync frame is bounded',()=>assert.throws(()=>normalizeBeatSyncFrame({beat:3})));
test('all gift amounts are integer minor units',()=>assert.ok(GIFTS.every(g=>Number.isSafeInteger(g.amountMinor)&&g.amountMinor>0)));
