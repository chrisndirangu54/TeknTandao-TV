# Android TV quality bar — SOTA-oriented, not yet verified

## Implemented in this iteration
- High-contrast, animated, focusable TV tiles designed for 10-foot viewing
- D-pad channel selection, explicit media play/pause support and full-width video
- Asynchronous per-channel programme schedule loading
- Fallbacks for unavailable streams and missing schedules
- A keyboard activation widget regression test

## Required before claiming state-of-the-art
1. **Reliability:** player startup, retry/backoff, HLS adaptive rendition selection, stall telemetry and repeatable switch-time benchmarks.
2. **Premium interface:** channel category filtering, EPG grid, Continue Watching, full-screen immersive viewing, search and profiles.
3. **Accessibility:** talkback, WCAG contrast checks, larger text/overscan-safe UI, caption selection, audio language and keyboard focus audits on real remotes.
4. **Media:** rights-cleared ingest, low-latency live, signed playback, DRM where rights require it, 24-hour start-over/catch-up only where permitted, EPG and saved programme controls.
5. **Discovery:** optional recommendations that never remove a broadcaster from the numbered channel guide; transparent privacy and consent controls.
6. **Network integration:** authenticated ISP service-health status, zero assumptions about zero-rated mobile access, operator caching under content agreements.
7. **Testing:** Android TV emulator and physical remotes across screen densities, Firebase emulator, network degradation, stream DRM and device codecs. Measure crash-free sessions, playback start time, channel-change time and rebuffer ratio.

No commercial streams, login, billing, or ISP provisioning are active in this repository. Production rollout requires independently verified content contracts, correct Firebase Auth issuer and service entitlements.

## Run TV UI
```bash
flutter create . --platforms=android,web --project-name tekntandao_tv
flutter pub get
flutter analyze
flutter test
flutter build apk --release --dart-define=ANDROID_TV_MODE=true
```
Android manifest currently uses a placeholder launcher banner resource. Replace it with a proper TV landscape graphic for store submission.
