'use strict';
const {test} = require('node:test');
const assert = require('node:assert/strict');
const {bundleSummary, eligibleSubscription} = require('../src/entitlements');
const {publicChannel, guide, scheduledProgramme} = require('../src/catalog');
test('TV and ISP bundle does not falsely activate Workspace', () => {
  const subs = [{product:'TV',status:'active'},{product:'ISP',status:'active'}];
  assert.deepEqual(bundleSummary(subs), {products:['ISP','TV'],bundle:true,workspaceEligible:false});
});
test('expired/paused plans do not grant access', () => {
  assert.equal(eligibleSubscription({product:'TV',status:'active',endsAt:'2020-01-01'},'TV'),false);
  assert.equal(eligibleSubscription({product:'TV',status:'paused'},'TV'),false);
});
test('unverified broadcaster is excluded', () => {
  assert.equal(publicChannel({published:true,rightsVerified:false,name:'test'},'x'),null);
});
test('guide uses stable channel numbers', () => {
  assert.deepEqual(guide([{id:'b',number:201},{id:'a',number:101}]).map(x=>x.id),['a','b']);
});
test('programme window excludes irrelevant entries', () => {
  assert.equal(scheduledProgramme({id:'1',channelId:'a',published:true,startsAt:'2026-10-20T00:00:00Z',endsAt:'2026-10-20T01:00:00Z'},'a',new Date('2026-10-21'),new Date('2026-10-22')),null);
});

test('one active bundle unlocks TV and ISP without Workspace', () => {
  assert.deepEqual(bundleSummary([{product:'ISP_TV_BUNDLE',status:'active'}]),{
    products:['ISP','TV'],bundle:true,workspaceEligible:false
  });
});
test('paused or expired bundle cannot unlock either service', () => {
  assert.deepEqual(bundleSummary([{product:'ISP_TV_BUNDLE',status:'paused'}]).products,[]);
  assert.deepEqual(bundleSummary([{product:'ISP_TV_BUNDLE',status:'active',endsAt:'2025-01-01'}]).products,[]);
});
