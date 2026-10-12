// リスト4.18
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// 通知インスタンスの生成
final FlutterLocalNotificationsPlugin flnp = FlutterLocalNotificationsPlugin();

// バックグランドでメッセージを受け取った時のイベント（トップレベルに定義）
// （変更点：バックグラウンドで動作するようにする）
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // （変更点：初期化が必要）
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  RemoteNotification? notification = message.notification;
  if (notification == null) return;

  await flnp.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    ),
  );
  flnp.show(
    notification.hashCode,
    "${notification.title}:バックグラウンド",
    notification.body,
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'channel_id',
        'channel_name',
        // （変更点：通知の重要度と優先度を設定）
        importance: Importance.max,
        priority: Priority.high,
      ),
    ),
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // （変更点）ユーザーに通知の許可を求める
  await FirebaseMessaging.instance.requestPermission();

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
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  const MyHomePage({super.key, required this.title});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _token = "";
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();

    // アプリ初期化時に画面にtokenを表示
    _firebaseMessaging.getToken().then((String? token) {
      setState(() {
        _token = token!;
      });
      // コピーしやすいようにターミナルに出すためにprint
      print(token);
    });

    // フォアグラウンドでメッセージを受け取った時のイベント
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
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
        "${notification.title}:フォアグラウンド",
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails('channel_id', 'channel_name'),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(child: Text(_token)),
    );
  }
}
