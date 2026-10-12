# ToDo アプリ

既存の `hellloworld` プロジェクト内で動く独立した Flutter アプリです。

```sh
cd hellloworld
flutter pub get
flutter run -t lib/koukasokutei/main.dart
```

Android 端末では USB デバッグを有効にして接続してから実行します。`flutter build apk -t lib/koukasokutei/main.dart` で APK をビルドできます。

画面はアカウント登録、ログイン、マイページ（ToDo 一覧）、ToDo 詳細、ToDo 入力・編集の 5 画面です。完了状態の切り替えと編集画面からの削除に対応します。データは端末内の SQLite に保存し、アカウントはこの端末内でのみ有効です。パスワードはソルト付きの導出値として保存します。端末間共有やオンライン認証はありません。
