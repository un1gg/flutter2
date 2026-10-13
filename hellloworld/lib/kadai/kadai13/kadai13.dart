import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// 通知プラグインインスタンス
final FlutterLocalNotificationsPlugin flnp = FlutterLocalNotificationsPlugin();

// バックグランドでメッセージを受け取った時のイベント
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  RemoteNotification? notification = message.notification;
  if (notification == null) return;

  await flnp.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    ),
  );
}

// フォアグランドでメッセージを受け取った時のイベント
void _firebaseMessagingForegroundHandler(RemoteMessage message) {
  RemoteNotification? notification = message.notification;
  flnp.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    ),
  );
  if (notification == null) {
    return;
  }
  // 通知
  flnp.show(
    notification.hashCode,
    notification.title,
    notification.body,
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'note-fg',
        'フォアグラウンド通知',
        importance: Importance.high,
      ),
    ),
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Firebaseの初期化
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 通知の許可を求める
  await FirebaseMessaging.instance.requestPermission();
  // フォアグラウンドでのメッセージ受信イベントを設定
  FirebaseMessaging.onMessage.listen(_firebaseMessagingForegroundHandler);
  // バックグラウンドでのメッセージ受信イベントを設定
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Generated App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _tokenController = TextEditingController();
  // FCMインスタンス
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();

    // アプリ初期化時に画面にtokenを表示
    _firebaseMessaging.getToken().then((String? token) {
      _tokenController.text = token ?? '';
    });
  }

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("PUSH通知")),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: TextField(controller: _tokenController, maxLines: 5),
        ),
      ),
    );
  }
}
