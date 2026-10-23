# Shared TeknTandao API contract — draft v0.1

**Status:** Specification only; endpoints are not yet deployed.

All requests require verified identity tokens and role-appropriate authorization; admin/status mutations are server-only and audited.

## Customer
`GET /v1/me` — returns customer profile for the authenticated principal:
```json
{"customerId":"cus_example","email":"viewer@example.org","phone":null,"roles":["subscriber"],"status":"active"}
```
Never allow a caller to select arbitrary customer IDs without scoped authorization.

## Subscriptions
`GET /v1/me/subscriptions`
```json
{"subscriptions":[{"subscriptionId":"sub_example","customerId":"cus_example","product":"TV","plan":"basic","status":"active","startsAt":"2026-10-24T00:00:00Z"}]}
```
Valid products: `TV`, `ISP`, `WORKSPACE`. Separate entitlements, common customer ID, distinct billing records.

`POST /v1/admin/subscriptions/{subscriptionId}/status`
```json
{"status":"active","reason":"verified_payment","idempotencyKey":"evt_example"}
```
Server-authorized only. Publish `subscription.status.changed.v1` to an idempotent event bus. Product handlers provision/revoke access only after verified payment or policy decisions; enforce grace periods.

## Payments and consent
Provider callbacks must be signature-verified, deduplicated and reconciled before activating service.
Viewer consent and marketing preferences are distinct from billing necessity. Broadcasters get aggregate/eligible segments, not arbitrary individual viewer records.

## Next implementation
1. Decide Firebase project and identity mapping (including safe account linking).
2. Implement authenticated backend and Firestore rules.
3. Add subscription entitlements to player authorization.
4. Add authorized live channel ingestion, DRM/access control where applicable and DVR.
