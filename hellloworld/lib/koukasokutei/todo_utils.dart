import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void showError(BuildContext context, Object error) {
  if (!context.mounted) return;
  final String message;
  if (error is FormatException) {
    message = error.message;
  } else if (error is FirebaseException) {
    message = switch (error.code) {
      'email-already-in-use' => 'このIDはすでに使われています。',
      'invalid-credential' || 'invalid-login-credentials' ||
      'wrong-password' || 'user-not-found' => 'IDまたはパスワードが違います。',
      'weak-password' => 'パスワードがFirebaseの設定条件を満たしていません。',
      'operation-not-allowed' => 'Firebase Authenticationでメール/パスワードを有効にしてください。',
      'permission-denied' => 'Firestoreのセキュリティルールを確認してください。',
      'network-request-failed' || 'unavailable' => '通信に失敗しました。ネット接続を確認してください。',
      'too-many-requests' => '試行回数が多すぎます。時間を置いて再試行してください。',
      'not-found' => 'ToDoが見つかりません。',
      _ => 'Firebaseの処理に失敗しました（${error.code}）。',
    };
  } else {
    message = '処理に失敗しました。もう一度お試しください。';
  }
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message.toString())));
}

String displayDate(DateTime date) {
  final value = date.toLocal();
  String pad(int number) => number.toString().padLeft(2, '0');
  return '${value.year}/${pad(value.month)}/${pad(value.day)} ${pad(value.hour)}:${pad(value.minute)}';
}

