import 'package:firebase_core/firebase_core.dart';

/// Firebase web configuration for SpendWise.
///
/// Fill these six values from the Firebase console:
/// Project settings (gear icon) -> General -> Your apps -> Web app -> SDK setup
/// and configuration -> Config.
///
/// These values identify your project; they are not secrets. Your data is
/// protected by the rules in `firestore.rules`, not by hiding these values.
class SpendWiseFirebase {
  static const String apiKey = 'AIzaSyBNJZ2Z-o1gvFtZsK_L0XXLPvVYxrQMRWo';
  static const String appId = '1:872117731607:web:8440ac45c503a5fc56f752';
  static const String messagingSenderId = '872117731607';
  static const String projectId = 'spendwise240';
  static const String authDomain = 'spendwise240.firebaseapp.com';
  static const String storageBucket = 'spendwise240.firebasestorage.app';

  static bool get isConfigured => !apiKey.startsWith('PASTE_') && !projectId.startsWith('PASTE_') && !appId.startsWith('PASTE_');

  static const FirebaseOptions options = FirebaseOptions(
    apiKey: apiKey,
    appId: appId,
    messagingSenderId: messagingSenderId,
    projectId: projectId,
    authDomain: authDomain,
    storageBucket: storageBucket,
  );
}
