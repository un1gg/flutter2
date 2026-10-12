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
      home: const MyHomePage(title: '演習課題01-4'),
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
  var _src = 'https://picsum.photos/id/10/200/200';
  var _message = '';
  var _colors = Colors.black;

  final Map<String, String> _imageUrls = {
    '風景': 'https://picsum.photos/id/10/200/200',
    '動物': 'https://picsum.photos/id/237/200/200',
    '建物': 'https://picsum.photos/id/164/200/200',
    '自然': 'https://picsum.photos/id/15/200/200',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Row(children: [Icon(Icons.create), Text('演習課題01-4')]),
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
                child: const Icon(
                  Icons.shopping_cart,
                  color: Colors.orange,
                  size: 24.0,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  _putMessage(
                    message: 'notificationsボタンタップ！！',
                    color: Colors.green,
                  );
                },
                child: const Icon(
                  Icons.notifications,
                  color: Colors.green,
                  size: 30.0,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  _putMessage(
                    message: 'personボタンタップ！！',
                    color: Colors.blue,
                  );
                },
                child: const Icon(
                  Icons.person,
                  color: Colors.blue,
                  size: 36.0,
                ),
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
      drawer: _drawerMenu(),
    );
  }

  void _putMessage({String? message, Color? color}) {
    setState(() {
      _message = message!;
      _colors = color!;
    });
  }

  Widget _drawerMenu() {
    return Drawer(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '画像ギャラリー',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            _imageButton('風景'),
            _imageButton('動物'),
            _imageButton('建物'),
            _imageButton('自然'),
            Image.network(_src, width: 200, height: 200),
          ],
        ),
      ),
    );
  }

  Widget _imageButton(String name) {
    return TextButton(
      child: Text(
        name,
        style: const TextStyle(color: Colors.green, fontSize: 16.0),
      ),
      onPressed: () {
        setState(() {
          _src = _imageUrls[name]!;
        });
      },
    );
  }
}

