// リスト3.12
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
  String _userAccelerometerValues = "";
  String _gyroscopeValues = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            _userAccelerometerValues,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          Text(
            _gyroscopeValues,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // （変更点）センサーイベント取得方法が変更になりました
    userAccelerometerEventStream().listen((UserAccelerometerEvent event) {
      setState(() {
        _userAccelerometerValues =
            "加速度センサー\n${event.x}\n${event.y}\n${event.z}";
      });
    });
    gyroscopeEventStream().listen((GyroscopeEvent event) {
      setState(() {
        _gyroscopeValues = "ジャイロセンサー\n${event.x}\n${event.y}\n${event.z}";
      });
    });
  }
}
