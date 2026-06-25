import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        return android;
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCafy5Bph-QO-JlysDtRtAtNWWS96HluzI',
    appId: '1:151681820353:android:57420232edb421b26f9640',
    messagingSenderId: '151681820353',
    projectId: 'study-quest-de6f7',
    storageBucket: 'study-quest-de6f7.firebasestorage.app',
  );
}
