// リスト2.6
import 'package:flutter/material.dart';

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(children: const [Icon(Icons.create), Text("初めてのタイトル")]),
      ),
      body: Column(
        children: [
          const Text("HellowWorld"),
          const Text("ハローワールド"),
          TextButton(
            // ignore: avoid_print
            onPressed: () => {print("ボタンが押されたよ")},
            child: const Text("テキストボタン"),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              Icon(Icons.favorite, color: Colors.pink, size: 24.0),
              Icon(Icons.audiotrack, color: Colors.green, size: 30.0),
              Icon(Icons.beach_access, color: Colors.blue, size: 36.0),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        // ignore: avoid_print
        onPressed: () => {print("押したね？")},
        child: const Icon(Icons.timer),
      ),
    );
  }
}
