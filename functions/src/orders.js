'use strict';
const crypto = require('node:crypto');
const VALID_PRODUCTS = new Set(['TV','ISP','ISP_TV_BUNDLE']);
function validateOrderRequest(body) {
  if (!body || typeof body !== 'object' || Array.isArray(body)) throw new Error('invalid_body');
  if (!/^[A-Za-z0-9_-]{1,80}$/.test(body.planId ?? '')) throw new Error('invalid_plan');
  if (!/^[A-Za-z0-9_-]{8,100}$/.test(body.idempotencyKey ?? '')) throw new Error('invalid_idempotency_key');
  if (Object.keys(body).some(k => !['planId','idempotencyKey'].includes(k))) throw new Error('unexpected_field');
  return {planId:body.planId,idempotencyKey:body.idempotencyKey};
}
function validatePublishedPlan(plan, now = new Date()) {
  if (!plan || plan.published !== true || !VALID_PRODUCTS.has(plan.product)) throw new Error('plan_unavailable');
  if (plan.currency !== 'KES' || !Number.isSafeInteger(plan.amountMinor) || plan.amountMinor < 0) throw new Error('invalid_price');
  if (!['monthly','quarterly','yearly'].includes(plan.period)) throw new Error('invalid_billing_period');
  if (plan.availableUntil && new Date(plan.availableUntil) <= now) throw new Error('plan_expired');
  return {product:plan.product,title:plan.title ?? plan.product,
    amountMinor:plan.amountMinor,currency:plan.currency,period:plan.period};
}
function orderDocumentId(uid,key) {
  return crypto.createHash('sha256').update(uid+'\0'+key).digest('hex');
}
function makePendingOrder(uid,planId,plan,idempotencyKey) {
  return {customerId:uid,planId,product:plan.product,description:plan.title,
    amountMinor:plan.amountMinor,currency:plan.currency,period:plan.period,
    status:'pending_payment',idempotencyKey,createdAt:new Date().toISOString(),
    paymentVerified:false};
}
module.exports={validateOrderRequest,validatePublishedPlan,orderDocumentId,makePendingOrder};
