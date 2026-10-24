'use strict';
const test=require('node:test');const assert=require('node:assert/strict');
const {validateOrderRequest,validatePublishedPlan,orderDocumentId,makePendingOrder}=require('../src/orders');
const valid={product:'ISP_TV_BUNDLE',published:true,title:'Home Internet + TV',currency:'KES',amountMinor:150000,period:'monthly'};
test('only server-approved plan and key are accepted',()=>{
 assert.deepEqual(validateOrderRequest({planId:'bundle1',idempotencyKey:'order-abcdef'}),{planId:'bundle1',idempotencyKey:'order-abcdef'});
 assert.throws(()=>validateOrderRequest({planId:'bundle1',idempotencyKey:'order-abcdef',amountMinor:1}));
});
test('unpublished and malformed priced plans rejected',()=>{
 assert.throws(()=>validatePublishedPlan({...valid,published:false}));
 assert.throws(()=>validatePublishedPlan({...valid,amountMinor:1.1}));
});
test('deterministic order id is scoped to verified user',()=>{
 assert.equal(orderDocumentId('a','order-abcdef'),orderDocumentId('a','order-abcdef'));
 assert.notEqual(orderDocumentId('a','order-abcdef'),orderDocumentId('b','order-abcdef'));
});
test('order never grants access before payment confirmation',()=>{
 const order=makePendingOrder('a','bundle1',validatePublishedPlan(valid),'order-abcdef');
 assert.equal(order.status,'pending_payment');assert.equal(order.paymentVerified,false);
});
