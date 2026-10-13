import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform => throw StateError(
    'Firebaseの接続設定が必要です。READMEのflutterfire configureを実行してください。',
  );
}
