'use strict';

async function authorize(req, verifyToken) {
  const match = /^Bearer ([A-Za-z0-9._~-]+)$/.exec(req.headers.authorization || '');
  if (!match) throw new Error('missing_bearer');
  const decoded = await verifyToken(match[1]);
  if (!decoded || typeof decoded.uid !== 'string' || !decoded.uid) throw new Error('invalid_token');
  return decoded;
}

// Server controls the returned fields to avoid leaking internal/ISP data.
function publicProfile(uid, profile) {
  return {
    customerId: uid,
    displayName: String(profile?.displayName ?? ''),
    email: String(profile?.email ?? ''),
    status: String(profile?.status ?? 'pending'),
  };
}

module.exports = {authorize, publicProfile};
