'use strict';
const PRODUCTS = new Set(['TV','ISP','WORKSPACE']);
const ACTIVE = new Set(['active','trialing']);
function eligibleSubscription(subscription, product, now = new Date()) {
  if (!subscription || !PRODUCTS.has(product) || subscription.product !== product) return false;
  if (!ACTIVE.has(subscription.status)) return false;
  const start = subscription.startsAt?.toDate?.() ?? subscription.startsAt;
  const end = subscription.endsAt?.toDate?.() ?? subscription.endsAt;
  if (start && new Date(start).getTime() > now.getTime()) return false;
  if (end && new Date(end).getTime() <= now.getTime()) return false;
  return true;
}
function entitlements(subscriptions, now = new Date()) {
  const active = new Set();
  for (const s of subscriptions) {
    if (s?.product === 'ISP_TV_BUNDLE' && ACTIVE.has(s.status)) {
      const start = s.startsAt?.toDate?.() ?? s.startsAt;
      const end = s.endsAt?.toDate?.() ?? s.endsAt;
      if ((!start || new Date(start) <= now) && (!end || new Date(end) > now)) {
        active.add('ISP'); active.add('TV');
      }
    }
  }
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
