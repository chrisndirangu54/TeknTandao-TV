# Venue Party Mode: clubs, matatus, events and virtual rooms

## Source committed
- Flutter screen: `lib/src/features/music/venue_party_screen.dart` (Android TV and mobile entry points)
- Backend functions: `functions/src/venue_party_api.js`; pure validation: `venue_party_core.js`
- Tests: `functions/test/venue_party_core.test.js`
- Room categories: club, party, matatu, event, virtual
- Public / invite / approval / paid admission requests, DJ mode AI or live
- Coarse opt-in area search; public discoverable rooms only; no precise tracking
- Join via room ID and optional private token. QR code and link encode room ID only. Deep link reception and QR camera scanning still require app link routing and camera permission work.
- One nominated `outputOperatorId`; owner can transfer logical output authority to an admitted participant; actual phone audio routing remains controlled by Android/iOS/desktop.
- Pending KES offerings: normal track request, priority request, shoutout, dedication, admission, tip, priced only from server-approved `venueOffers`. No unauthorized queue jump or charge.

## Payment/priority fairness
Never execute priority, shoutouts or paid admission on `pending_payment` status. Require verified M-Pesa provider callbacks from Workspace payment authority, an idempotent fulfillment queue, published price and refund rules, and live DJ acceptance/moderation. Avoid pay-to-win mechanics targeting minors. Display a clearly labeled paid queue, keep a free queue, and set per-user spending/priority limits.

## Audio architecture
Exactly one device/operator should output the shared audio to the physical venue system; other participants control queue/votes/chat via apps. Output may use the OS Bluetooth/AUX/USB/HDMI/Wi-Fi audio route. Multiple phones should **not** simultaneously attach and stream different master audio feeds. Provide a failover process only after verified handoff and buffer synchronization. Android Bluetooth device selection and permission flows, output hardware adapters, DJ mixer integration and live latency tests are not yet implemented.

## Proximity, accounts and security
Real GPS/BLE discovery requires explicit opt-in, foreground location permissions, coarse search cells or temporary proximity tokens. This code intentionally supports *only coarse manually entered area*. Do not expose identities or exact location in a public directory. Username lookup requires unique handles and privacy settings before enabling it. User-controlled presence, blocking/reporting, age safeguards, safety moderation and configurable retention are preconditions for real clubs and public discovery.

## Launch blockers
Verified Firebase Auth and API configuration; real hosted domain/deep links; licensed DJ catalog; BeatSync DSP worker; video/audio rooms and voice notes; approved pricing/payment/payout flow; social moderation; load/physical hardware tests. CI has not been verified; no venue or hardware was accessed.
