# TeknTandao TV architecture (implementation boundaries)

```text
Flutter viewers (mobile/web/Android TV)
    └── TV service adapter / authenticated gateway
          ├── Identity: one TeknTandao customer ID / Firebase Auth
          ├── Subscription/entitlement service: TV, ISP, Workspace
          ├── Television catalogue: channels, rights, schedules
          ├── Playback authorization: short-lived signed playback tokens
          ├── Streaming: authorized ingest → transcoding → HLS origin → CDN/cache
          ├── Viewer events: consent-aware analytics pipeline
          └── B2B integrations: Workspace CRM, ISP subscriber operations
```

## Security guarantees
- No private router keys, payment credentials, or administrator tokens in Flutter builds.
- Never let the client directly mutate paid entitlements or request arbitrary customer records.
- Authenticate user tokens at the gateway; enforce tenant scope and broadcaster ownership server side.
- Signed webhook and idempotent payment processing; subscription changes produce auditable events.
- Viewer marketing is off by default and must be independently consented to.
- Edge caches store only entitled, authorized content; enforce rights, expiry and geographic restrictions.
- DVR/start-over requires broadcaster consent, retention control, protected storage and proper implementation; not present in demo.
- Links to YouTube, Spotify and TikTok must use authorized SDKs/players; do not capture their streams.

## Shared cross-product IDs
A canonical `customerId` maps authenticated identities to a single profile.
`organizationId`, `subscriptionId` and `entitlementId` are separately scoped.
TV, ISP and Workspace maintain independent operational data; Workspace displays permitted aggregate views via secure APIs.

## Planned milestones
1. Flutter channel guide and test player (prototype).
2. Configure Firebase identity and backend adapter, verify existing account linking.
3. Add backend catalogue, scheduled programmes, broadcaster administration and playback authorization.
4. Add rights-cleared HLS ingest, DVR/restart, resilient delivery, analytics.
5. Add opt-in AI features, ISP edge-cache integration, M-Pesa reconciliation and bundle workflows.

See `INTEGRATION_API_V0_1.md` for the shared API draft.
