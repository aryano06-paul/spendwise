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
  static const String apiKey = 'PASTE_API_KEY';
  static const String appId = 'PASTE_APP_ID';
  static const String messagingSenderId = 'PASTE_MESSAGING_SENDER_ID';
  static const String projectId = 'PASTE_PROJECT_ID';
  static const String authDomain = 'PASTE_AUTH_DOMAIN';
  static const String storageBucket = 'PASTE_STORAGE_BUCKET';

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
