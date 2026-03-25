// FlutterFire로 교체하세요: `dart pub global activate flutterfire_cli` 후 `flutterfire configure`
// 값이 기본 플레이스홀더이면 Firebase 초기화를 건너뜁니다(FCM만 비활성, 로컬 알림은 동작).

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  static const String _placeholderProject = 'CONFIGURE_FLUTTERFIRE';

  static bool get isConfigured {
    if (kIsWeb) return false;
    try {
      return currentPlatform.projectId != _placeholderProject;
    } catch (_) {
      return false;
    }
  }

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('Firebase Web: flutterfire configure 후 web 옵션을 추가하세요.');
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'Firebase: 이 플랫폼은 firebase_options.dart에 추가하세요.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'CONFIGURE_FLUTTERFIRE',
    appId: '1:0:android:0',
    messagingSenderId: '0',
    projectId: _placeholderProject,
    storageBucket: 'CONFIGURE_FLUTTERFIRE.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'CONFIGURE_FLUTTERFIRE',
    appId: '1:0:ios:0',
    messagingSenderId: '0',
    projectId: _placeholderProject,
    storageBucket: 'CONFIGURE_FLUTTERFIRE.appspot.com',
    iosBundleId: 'com.svil.lovetype_tarot',
  );
}
