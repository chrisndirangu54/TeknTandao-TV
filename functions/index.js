'use strict';
const {onRequest} = require('firebase-functions/v2/https');
const admin = require('firebase-admin');
const {authorize, publicProfile} = require('./src/security');
const {bundleSummary} = require('./src/entitlements');
const {publicChannel, guide, scheduledProgramme} = require('./src/catalog');

if (!admin.apps.length) admin.initializeApp();
const db = admin.firestore();

exports.tvApi = onRequest({cors: false, region: 'europe-west1'}, async (req, res) => {
  res.setHeader('Cache-Control', 'no-store');
  if (req.method !== 'GET') return res.status(405).json({error: 'method_not_allowed'});
  let principal;
  try { principal = await authorize(req, (token) => admin.auth().verifyIdToken(token, true)); }
  catch (_) { return res.status(401).json({error: 'unauthenticated'}); }

  // The verified Firebase UID is authoritative. Multi-project account linking
  // must be implemented explicitly; never trust email or customerId in requests.
  const uid = principal.uid;
  try {
    if (req.path === '/v1/me') {
      const profile = await db.collection('customers').doc(uid).get();
      if (!profile.exists) return res.status(404).json({error: 'customer_not_found'});
      return res.status(200).json(publicProfile(uid, profile.data()));
    }
    if (req.path === '/v1/me/subscriptions' || req.path === '/v1/me/entitlements') {
      const snapshot = await db.collection('subscriptions').where('customerId','==',uid).limit(100).get();
      const subscriptions = snapshot.docs.map(doc => ({
        subscriptionId:doc.id, product:doc.get('product') ?? null,
        plan:doc.get('plan') ?? null, status:doc.get('status') ?? null,
        startsAt:doc.get('startsAt')?.toDate?.()?.toISOString?.() ?? null,
        endsAt:doc.get('endsAt')?.toDate?.()?.toISOString?.() ?? null
      }));
      if (req.path === '/v1/me/entitlements') return res.status(200).json(bundleSummary(subscriptions));
      return res.status(200).json({subscriptions});
    }
    if (req.path === '/v1/tv/guide') {
      const snapshot = await db.collection('tvChannels').where('published','==',true).limit(100).get();
      const channels = guide(snapshot.docs.map(doc => publicChannel(doc.data(), doc.id)));
      return res.status(200).json({channels});
    }
    if (/^\/v1\/tv\/channels\/[A-Za-z0-9_-]{1,100}\/schedule$/.test(req.path)) {
      const channelId = req.path.split('/')[4];
      const channel = await db.collection('tvChannels').doc(channelId).get();
      if (!channel.exists || !publicChannel(channel.data(),channel.id)) {
        return res.status(404).json({error:'channel_not_found'});
      }
      const start = new Date();
      const end = new Date(start.getTime()+7*24*60*60*1000);
      const programs = await db.collection('tvProgrammes').where('channelId','==',channelId).limit(200).get();
      const items = programs.docs.map(doc=>scheduledProgramme({id:doc.id,...doc.data(),
        startsAt:doc.get('startsAt')?.toDate?.(), endsAt:doc.get('endsAt')?.toDate?.()},channelId,start,end)).filter(Boolean);
      return res.status(200).json({programmes: items.sort((a,b)=>a.startsAt.localeCompare(b.startsAt))});
    }
    return res.status(404).json({error: 'not_found'});
  } catch (err) {
    console.error('tvApi request failed', {path:req.path,name:err?.name});
    return res.status(500).json({error:'internal_error'});
  }
});

const {validateOrderRequest,validatePublishedPlan,orderDocumentId,makePendingOrder} = require('./src/orders');

/**
 * Creates only an unpaid order. Real payment capture and subscription
 * activation remain in the authoritative Workspace billing service.
 */
exports.createTvOrder = onRequest({cors:false, region:'europe-west1'}, async (req,res) => {
  res.setHeader('Cache-Control','no-store');
  if (req.method !== 'POST') return res.status(405).json({error:'method_not_allowed'});
  let user;
  try { user = await authorize(req, token=>admin.auth().verifyIdToken(token,true)); }
  catch (_) { return res.status(401).json({error:'unauthenticated'}); }
  let input;
  try { input = validateOrderRequest(req.body); }
  catch (_) { return res.status(400).json({error:'invalid_order_request'}); }
  try {
    const planSnapshot=await db.collection('tvPlans').doc(input.planId).get();
    let plan;
    try { plan=validatePublishedPlan(planSnapshot.data()); }
    catch (_) { return res.status(404).json({error:'plan_unavailable'}); }
    const id=orderDocumentId(user.uid,input.idempotencyKey);
    const ref=db.collection('tvOrders').doc(id);
    const order=await db.runTransaction(async tx => {
      const current=await tx.get(ref);
      if (current.exists) {
        const value=current.data();
        if(value.customerId!==user.uid || value.planId!==input.planId) throw new Error('idempotency_conflict');
        return value;
      }
      const newOrder=makePendingOrder(user.uid,input.planId,plan,input.idempotencyKey);
      tx.create(ref,newOrder);
      return newOrder;
    });
    return res.status(200).json({orderId:id,planId:order.planId,product:order.product,
      amountMinor:order.amountMinor,currency:order.currency,period:order.period,status:order.status});
  } catch(err) {
    if(err.message==='idempotency_conflict') return res.status(409).json({error:'idempotency_conflict'});
    console.error('createTvOrder failed',{name:err?.name});
    return res.status(500).json({error:'internal_error'});
  }
});
