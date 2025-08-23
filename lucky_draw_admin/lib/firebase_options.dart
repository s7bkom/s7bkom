// lucky_draw_admin/lib/firebase_options.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return const FirebaseOptions(
        apiKey: "AIzaSyDPVaALTed2ug_9p9-YL7zEBkzSO1x9Pt4",
        authDomain: "lucky-draw-6d34a.firebaseapp.com",
        projectId: "lucky-draw-6d34a",
        storageBucket: "lucky-draw-6d34a.firebasestorage.app",
        messagingSenderId: "565882709702",
        appId: "1:565882709702:web:dc18e7095d84a35fc2d9c7",
        measurementId: "G-HBFMT0VDDX",
      );
    }
    // Add other platforms if needed, though for admin panel, web is primary
    throw UnsupportedError(
      'DefaultFirebaseOptions are not supported for this platform.',
    );
  }
}
