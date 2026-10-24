# Android TV: implementation status as of 2026-10-24

## Implemented source code
- 10-foot TV home with channel-number navigation, visible focus and sample HLS video
- Full electronic programme guide screen backed by per-channel schedule API (empty unless broadcaster data supplied)
- Search and categories; favorite channels and device-local profile preferences
- Child-oriented discovery filter (UI-only, not secure parental control)
- Device-local last-viewed position data (not yet a finished Resume Playing flow)
- Seekable-media 10-second rewind/forward and playback progress controls; ordinary live DVR is disabled
- Playback diagnostics for state, size, buffering and media errors (not remote QoE telemetry)
- TV/ISP customer service dashboard, bundle entitlement and pending checkout APIs
- Restricted DVR capability policy with tests; no recorder, transcoder or storage infrastructure

## Not yet implemented or not production verified
- Broadcaster-approved cloud DVR, scheduled recordings, catch-up and time-shift storage
- Signed paid playback/CDN/DRM/key management, actual commercial broadcasts, reliable ABR benchmarking
- AI conversational search and on-device microphone/transcription service
- Caption tracks and multi-language audio selection, secure kids PIN profiles
- Persisted per-user/cloud watch progress across devices
- Real ISP edge caches, peering and operator-multicast delivery
- Production Firebase sign-in, confirmed M-Pesa payments, entitlement enforcement on media URLs
- Emulator/physical remote testing, Flutter analyze/build success, automated QA results

## Critical path
1. Configure the canonical Firebase Auth issuer for TV and Workspace, then test account linking in emulator.
2. Add rights-cleared broadcaster test feed and server-controlled programme schedule metadata.
3. Implement short-lived entitlement-checked playback token URLs and integration with HLS origin.
4. Integrate verified Workspace billing. Never enable ISP/TV based on unverified payment claims.
5. Add a TV recording engine with rights flags, retention expiry, quotas, and audit trails.
6. Bind streaming performance events only after privacy consent, and add real-device tests for codecs, focus and TV launcher.
7. Independently test and approve ISP equipment/network and local-cache changes.

These commits are **draft** review changes. They do not imply a live network, broadcaster rights or commercial deployment.
