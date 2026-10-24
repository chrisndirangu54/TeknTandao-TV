# AI DJ, Listening Parties, Creator Commerce — Progress and deployment gates

## Implemented on feature/unified-tv-isp-workspace
- `functions/src/ai_dj_planner.js`: beat/key/energy-aware candidate scoring, transition planning and bounded BeatSync-style audio-visual signals; **no audio DSP rendering**.
- `functions/src/music_party_api.js`: authenticated room-based song proposal, vote replacement, queue ranking, host-only next-track selection. Room membership + active subscription checked before song operations.
- `functions/src/music_party_core.js`: input validation, ranked queue and safe pending tip intention.
- `functions/src/gift_catalog.js`: virtual gift presets and bounded BeatSync frames.
- Flutter interfaces: DJ queue and votes, host selection, gift presets, tipping amount and watch-party entry points on TV/mobile.
- Node tests: DJ planning, voting core, gift validation and idempotent tip IDs.

## Not wired or not deployable without owner inputs
1. **Firebase:** The Flutter `PartyService` needs production identity tokens and deployed Cloud Function URLs. Current demo navigation opens service-less screens. After user config, inject a real service with approved origins, device auth and account linking.
2. **Audio:** Streaming music, deterministic beat mix rendering, timed transitions, track metadata ingest and advanced AI DJ recommendations need authorized music feeds, licensing and BeatSync DSP workers.
3. **Real-time:** Queue/chat currently require manual refresh. For synchronized listening at scale, use a low-latency authenticated session transport, clock sync, drift correction and transport-specific player integration.
4. **Calls / voice notes:** Not implemented. Need consent, capture permissions, SFU/TURN, transcription choices, upload security, content moderation, expiry and retention.
5. **Gifts / revenue:** Only pending tip intents; no payment initiation, settlement, payout, reversals, creator onboarding or cash rewards. Server-set gifts and prices need binding to authoritative checkout.
6. **Public moderation:** Admin reporting, bans, rate limiting, age enforcement, private invite rotation and abuse systems must be implemented before public launch.
7. **Test:** Full Flutter build, device codec testing, Firestore emulator integration and actual payment callback verification have not been run.

Never interpret planning algorithms, pending payment records or UI previews as a deployed functioning social media streaming product.
