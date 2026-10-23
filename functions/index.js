'use strict';
const {onRequest} = require('firebase-functions/v2/https');
const admin = require('firebase-admin');
const {authorize, publicProfile} = require('./src/security');

if (!admin.apps.length) admin.initializeApp();
const db = admin.firestore();

exports.tvApi = onRequest({cors: false, region: 'europe-west1'}, async (req, res) => {
  res.setHeader('Cache-Control', 'no-store');
  if (req.method !== 'GET') return res.status(405).json({error: 'method_not_allowed'});
  let principal;
  try { principal = await authorize(req, (token) => admin.auth().verifyIdToken(token, true)); }
  catch (_) { return res.status(401).json({error: 'unauthenticated'}); }

  // Identity linkage uses the verified Firebase UID. Production cross-project
  // migration needs explicit account-linking, not a client-provided customerId.
  const uid = principal.uid;
  try {
    const profile = await db.collection('customers').doc(uid).get();
    if (req.path === '/v1/me') {
      if (!profile.exists) return res.status(404).json({error: 'customer_not_found'});
      return res.status(200).json(publicProfile(uid, profile.data()));
    }
    if (req.path === '/v1/me/subscriptions') {
      const snapshot = await db.collection('subscriptions').where('customerId', '==', uid).limit(50).get();
      return res.status(200).json({subscriptions: snapshot.docs.map((doc) => ({
        subscriptionId: doc.id,
        product: doc.get('product') ?? null,
        plan: doc.get('plan') ?? null,
        status: doc.get('status') ?? null,
      }))});
    }
    return res.status(404).json({error: 'not_found'});
  } catch (err) {
    console.error('tvApi request failed', {path: req.path, name: err?.name});
    return res.status(500).json({error: 'internal_error'});
  }
});
