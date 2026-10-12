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
      home: const MyHomePage(title: '演習課題01-3'),
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
  var _message = '';
  var _colors = Colors.black;

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
              _putMessage(message: 'タップ！！', color: Colors.brown);
            },
            child: const Text(
              "タップ！",
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () {
                  _putMessage(message: 'shopping_cartボタンタップ！！', color: Colors.orange);
                },
                child: Icon(Icons.shopping_cart, color: Colors.orange, size: 24.0),
              ),
              ElevatedButton(
                onPressed: () {
                  _putMessage(
                    message: 'notificationsボタンタップ！！',
                    color: Colors.green,
                  );
                },
                child: Icon(Icons.notifications, color: Colors.red, size: 30.0),
              ),
              ElevatedButton(
                onPressed: () {
                  _putMessage(
                    message: 'personボタンタップ！！',
                    color: Colors.blue,
                  );
                },
                child: Icon(Icons.person, color: Colors.blue, size: 36.0),
              ),
            ],
          ),
          Text(
            _message,
            style: TextStyle(
              color: _colors,
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _putMessage(
            message: 'FloatingActionButtonタップ！！',
            color: Colors.purple,
          );
        },
        child: const Icon(Icons.timer),
      ),
    );
  }

  void _putMessage({String? message, Color? color}) {
    setState(() {
      _message = message!;
      _colors = color!;
    });
  }
}

