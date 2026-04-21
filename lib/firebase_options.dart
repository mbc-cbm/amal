// Firebase options for project: amal-app-production
// Values sourced from Firebase console config files.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for '
          '${defaultTargetPlatform.name}.',
        );
    }
  }

  // ── Web ───────────────────────────────────────────────────────────────────
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyA_CYfI1fB0vr7wtDenTZdxyCPz9TPo2uM',
    authDomain: 'amal-app-production.firebaseapp.com',
    projectId: 'amal-app-production',
    storageBucket: 'amal-app-production.firebasestorage.app',
    messagingSenderId: '1064683710947',
    appId: '1:1064683710947:web:cb4ce6237c390af416d8d6',
    measurementId: 'G-R0M17MCQFL',
  );

  // ── Android ───────────────────────────────────────────────────────────────

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDcUIqKty7f3vEcpyKeKkRJSgpXbRG9jZg',
    appId: '1:1064683710947:android:72be42acaf39936b16d8d6',
    messagingSenderId: '1064683710947',
    projectId: 'amal-app-production',
    storageBucket: 'amal-app-production.firebasestorage.app',
  );

  // Source: android/app/google-services.json

  // ── iOS ───────────────────────────────────────────────────────────────────

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDCrL82uu-dN6Z6cn-6dSVj9bx4IpSa_aI',
    appId: '1:1064683710947:ios:1092e6acae9e0bbc16d8d6',
    messagingSenderId: '1064683710947',
    projectId: 'amal-app-production',
    storageBucket: 'amal-app-production.firebasestorage.app',
    iosBundleId: 'com.amal.app',
  );

  // Source: ios/Runner/GoogleService-Info.plist
}