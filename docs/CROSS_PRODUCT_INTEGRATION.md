# TeknTandao unified platform integration (implementation plan)
Core principle: one verified person identity and customer ID, independent TV/ISP/Workspace entitlements, one consolidated dashboard.

## Existing repos and owners
- `TeknTandao-TV`: TV catalogue, broadcaster rights, Flutter player, viewing permissions.
- `TeknTandao-Workspace`: existing business tenancy, CRM, verified Tandao subscription payment and ISP management UI.
- `HTML`: public website, legacy ISP self-service and enquiry console. This must not become a second authority for subscriber billing.

## Control plane
Use a canonical identity authority, ideally the existing Workspace Firebase Auth project after checking project and user mapping. Authenticate each service request using verified Firebase ID tokens, matching issuer and audience; if separate Firebase projects remain, implement a verified token-exchange broker first. Never equate matching email addresses to identity.
Store identity mapping and cross-product subscriptions only on the authoritative backend. Do not copy personal data between browsers or merge Firestore instances.
An organization has an owner and scoped organization memberships. A customer's personal TV access does not confer broadcaster, ISP admin, or Workspace tenant access.

## Data contracts
- customers/{customerId}: minimal profile, created/updated timestamps.
- organizations/{organizationId}: tenant metadata and verified membership.
- subscriptions/{subscriptionId}: customerId, product (TV/ISP/WORKSPACE), plan, status, startsAt, endsAt, source/payment reference.
- tvChannels/{channelId}: number, name, rightsVerified, rightsEnd, category, status, published, replayAllowed.
- tvProgrammes/{programmeId}: channelId, startsAt, endsAt, published, title.
- ispSubscribers and ispDevices: continue in Workspace/ISP, not copied into TV.
- viewerConsent/{customerId}: independent optional analytics and marketing consents.

## Event design
Emit idempotent `subscription.status.changed.v1` after *verified* payment/reconciliation or authorized administrator update. Payload has eventId, customerId, subscriptionId, product, newStatus, occurredAt; no credentials or rich profile. Individual product adapters observe their own entitlement and do not execute unapproved changes to equipment.
Use an outbox and processed-event ledger to allow safe replay; no unaudited direct mutation.

## Launch constraints
- TV and ISP can each be purchased separately; bundle pricing is a billing construct, not database merging.
- Without TV distribution rights, native channels cannot be commercially broadcast, cached or recorded.
- No default marketing retargeting or exposing individual viewer histories to broadcasters.
- No live MikroTik/OLT provisioning, M-Pesa merchant charges or CDN deploy without approved credentials, tests and commercial authorization.
- Workspace is the dashboard; HTML and TV may deep-link to it after verified sign-in.

## Required owner configuration
Select authoritative Firebase project and approved identity mapping; configure Functions and HTTPS origins, content rights, M-Pesa contracts, wholesale internet agreement, physical lab devices, secure secrets and domain names. Run emulator tests before staged production deployment.
