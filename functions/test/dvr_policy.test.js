'use strict';
const test=require('node:test');
const assert=require('node:assert/strict');
const {dvrCapabilities}=require('../src/dvr_policy');
test('rights-free streams cannot be recorded',()=>{
 const cap=dvrCapabilities({published:true,rightsVerified:false,replayAllowed:true,dvrProviderEnabled:true,recordingAllowed:true},
  {product:'TV',status:'active'});
 assert.deepEqual(cap,{restart:false,record:false});
});
test('active bundle only enables explicitly licensed backend capabilities',()=>{
 const base={published:true,rightsVerified:true,replayAllowed:true,dvrProviderEnabled:true};
 assert.deepEqual(dvrCapabilities(base,{product:'ISP_TV_BUNDLE',status:'active'}),{restart:true,record:false});
 assert.equal(dvrCapabilities({...base,recordingAllowed:true},{product:'ISP_TV_BUNDLE',status:'active'}).record,true);
});
