import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Book Init',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const collectionName = 'bookCollection';

  final _data = {
    '1': {'title': 'Flutter入門', 'author': '山田太郎', 'isRead': true},
    '2': {'title': 'Dart実践', 'author': '鈴木花子', 'isRead': false},
    '3': {'title': 'Firebase活用', 'author': '佐藤一郎', 'isRead': true},
    '4': {'title': 'Android開発', 'author': '田中次郎', 'isRead': false},
    '5': {'title': 'iOS入門', 'author': '山田太郎', 'isRead': false},
  };

  var _message = '';

  Future<void> _registerData() async {
    final collection = FirebaseFirestore.instance.collection(collectionName);
    for (final entry in _data.entries) {
      await collection.doc(entry.key).set(entry.value);
    }
    setState(() {
      _message = '登録完了\n$_data';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('本データ登録')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _registerData,
              child: const Text('データ登録'),
            ),
            const SizedBox(height: 16),
            Text(_message, textAlign: .center),
          ],
        ),
      ),
    );
  }
}
