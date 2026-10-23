'use strict';
const test = require('node:test');
const assert = require('node:assert/strict');
const {authorize, publicProfile} = require('../src/security');

test('rejects missing authorization', async () => {
  await assert.rejects(() => authorize({headers: {}}, async () => ({uid: 'ok'})));
});
test('uses verified uid rather than submitted customer ID', async () => {
  const user = await authorize({headers: {authorization: 'Bearer mock.token'}}, async () => ({uid: 'verified'}));
  assert.equal(user.uid, 'verified');
});
test('redacts arbitrary profile fields', () => {
  const profile = publicProfile('u1', {email: 'u@example.invalid', routerPassword: 'sensitive'});
  assert.equal(profile.customerId, 'u1');
  assert.equal('routerPassword' in profile, false);
});
