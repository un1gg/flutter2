# Firebase ToDo アプリ

Flutter の5画面構成です。認証は Firebase Authentication、データ保存は Cloud Firestore を使用します。

## 初回設定

GitHub には実際の Firebase 接続設定がないため、同梱の firebase_options.dart は設定未完了を表示するひな形です。FlutterFire CLI で上書きします。

1. Firebase Console で ToDo 用のプロジェクトを作成するか、既存プロジェクトを選択します。授業のデータと分けたい場合は ToDo 用の新規プロジェクトを使用します。
2. Authentication の「ログイン方法」で「メール/パスワード」を有効にします。「メールリンク」は不要です。
3. Cloud Firestore のデータベースを作成します。データベースIDは既定の (default) を使用します。
4. Firestore の「ルール」に同じフォルダの firestore.rules を反映して公開します。このルールは users と todos 専用です。授業用プロジェクトに適用する場合は既存コレクションのルールを残して統合してください。全データの公開は不要です。
5. PowerShell で次を実行します。

```powershell
npm install -g firebase-tools
firebase login
dart pub global activate flutterfire_cli
```

hellloworld フォルダで実行します。表示されたプロジェクト一覧から対象プロジェクトを選びます。

```powershell
dart pub global run flutterfire_cli:flutterfire configure --platforms=android --out=lib/koukasokutei/firebase_options.dart
flutter pub get
flutter run -t lib/koukasokutei/main.dart
```

Android のパッケージ名は com.example.hellloworld です。既存の Android アプリを使用する場合は、このパッケージ名が一致するものを選択します。設定を済ませた後は、生成された設定ファイルと CLI が更新した Android 設定もソースコードに含めて保存してください。

## データと認証

| 保存先 | 内容 |
|---|---|
| Authentication | 認証用メール形式とパスワードを Firebase が管理 |
| users/{uid} | loginId、createdAt |
| todos/{todoId} | userId、title、scheduledAt、detail、createdAt、updatedAt、isCompleted |

画面の任意IDは、前後の空白を取り除いた後、SHA-256の16進文字列 + @todo.example.com に変換してメール/パスワード認証を使用します。大文字と小文字は区別します。メール形式は内部識別用であり、メール送信・メール認証・メールでのパスワード再設定には対応していません。crypto はこのID変換にだけ使用し、パスワードやパスワードハッシュは Firestore に保存しません。

データモデルは AppUser と Todo の2つです。userId は Authentication の uid を指します。日時フィールドは Firestore の Timestamp、完了は bool です。

SQLite 版の端末内アカウント・ToDo は自動移行しません。Firebase 版で新しく登録します。起動時はログイン画面を表示し、ログイン・一覧取得・保存にはネット接続が必要です。一覧取得は所有者の条件で絞り込み、端末内で作成日時順に並べるため複合インデックスは不要です。他の端末で更新したデータは再ログイン時に取得します。

登録時に Authentication の作成だけ成功し、users の保存に失敗した場合は、ルール等を修正して同じIDでログインするとユーザー情報を作成し直します。

## 確認手順

- 登録して users に1件作成されること
- 同じIDを別端末から登録しても重複が拒否されること
- 間違ったパスワードでログインできないこと
- ToDo の登録、詳細表示、編集、完了切替、削除が反映されること
- 別アカウントには元のアカウントの ToDo が表示されないこと
- 別端末で同じアカウントにログインし、保存した ToDo を取得できること
- Firebase の接続設定がない場合に設定案内が表示されること

## 提出用 APK

```powershell
flutter build apk --release -t lib/koukasokutei/main.dart
```

APK は build/app/outputs/flutter-apk/app-release.apk です。現在のプロジェクトは release も debug キーで署名する設定なので、ストア公開用の署名設定とは別です。テーブル設計書は SQLite の列型から上記 Firestore フィールド型へ合わせて更新してください。
