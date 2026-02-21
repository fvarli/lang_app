# LangRoutine

Offline-first Flutter MVP focused on Reading, Listening, and Grammar practice.

## Release Build Commands (Android)

```bash
flutter pub get
flutter analyze
flutter test
flutter build apk --release
flutter build appbundle --release
```

## Build Outputs

- APK: `build/app/outputs/flutter-apk/app-release.apk`
- AAB: `build/app/outputs/bundle/release/app-release.aab`

## Basic Verification Steps

1. Install APK on a device/emulator and launch.
2. Verify app name is **LangRoutine** on launcher.
3. Verify package id:
   - `adb shell dumpsys package com.langroutine.app | head`
4. Open Settings and confirm About shows version/build and feedback action.
5. Run content validator:
   - `dart run tool/validate_content.dart`
