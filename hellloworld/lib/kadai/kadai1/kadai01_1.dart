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
      home: const MyHomePage(title: '演習課題01-1'),
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
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          const Text(
            "Flutterの復習",
            style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
          ),
          const Text("基本の使い方を思い出そう"),
          TextButton(
            onPressed: () {
              // ignore: avoid_print
              print("ボタンが押されたよ");
            },
            child: const Text("タップ！"),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () {
                  // ignore: avoid_print
                  print("shopping_cartボタンタップ！！");
                },
                child: Icon(Icons.shopping_cart, color: Colors.orange, size: 24.0),
              ),
              ElevatedButton(
                onPressed: () {
                  // ignore: avoid_print
                  print("notificationsボタンタップ！！");
                },
                child: Icon(Icons.notifications, color: Colors.red, size: 30.0),
              ),
              ElevatedButton(
                onPressed: () {
                  // ignore: avoid_print
                  print("personボタンタップ！！");
                },
                child: Icon(Icons.person, color: Colors.blue, size: 36.0),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // ignore: avoid_print
          print("FloatingActionButtonタップ！！");
        },
        child: const Icon(Icons.timer),
      ),
    );
  }
}

