'use strict';
const PRODUCTS = new Set(['TV','ISP','WORKSPACE']);
const ACTIVE = new Set(['active','trialing']);
function eligibleSubscription(subscription, product, now = new Date()) {
  if (!subscription || !PRODUCTS.has(product) || subscription.product !== product) return false;
  if (!ACTIVE.has(subscription.status)) return false;
  if (subscription.startsAt && new Date(subscription.startsAt).getTime() > now.getTime()) return false;
  if (subscription.endsAt && new Date(subscription.endsAt).getTime() <= now.getTime()) return false;
  return true;
}
function entitlements(subscriptions, now = new Date()) {
  const active = new Set();
  for (const product of PRODUCTS) {
    if (subscriptions.some(s => eligibleSubscription(s, product, now))) active.add(product);
  }
  return [...active].sort();
}
function bundleSummary(subscriptions, now = new Date()) {
  const products = entitlements(subscriptions, now);
  return {products, bundle: products.includes('TV') && products.includes('ISP'),
    workspaceEligible: products.includes('WORKSPACE')};
}
module.exports = {eligibleSubscription, entitlements, bundleSummary};
