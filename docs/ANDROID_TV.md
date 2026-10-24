# TeknTandao TV — Android TV build

The same Flutter codebase supports a dedicated Android TV ten-foot UI with a numbered channel guide, physical remote D-pad (up/down/select), Media Play/Pause, HLS playback and a TV launcher entry.

## Build
Generate Flutter's Android boilerplate **without replacing tracked files**:
```bash
flutter create . --platforms=android,web --project-name tekntandao_tv
flutter pub get
flutter analyze
flutter test
flutter build apk --release --dart-define=ANDROID_TV_MODE=true
```
In Android Studio/ADB install on a TV emulator or certified Android TV / Google TV device.

## Important distinctions
- The manifest marks this APK as an Android TV app via `LEANBACK_LAUNCHER`, a required leanback feature and disabled touchscreen requirement; use a separate mobile flavor/manifest if publishing a mobile APK. This repository's mobile Flutter UI is still selected unless `ANDROID_TV_MODE=true`.
- The icon is a temporary banner placeholder: **replace** `android:banner` with a proper 320 × 180 or higher 16:9 TV banner resource before Play Store submission.
- Full EPG, channel switching, reliable live streams, DVR/restart, protected playback, Firebase authentication and verified channel-rights data are not production-complete.
- The included Mux sample is sample video footage, **not a broadcaster channel**.
- A physical D-pad/remote and decoder/codec testing are needed before publication. The code is committed but neither emulator nor TV hardware build has been verified here.
- Firebase and API credentials are not committed. Broadcast distribution or caching requires appropriate rights.
