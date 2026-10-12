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
      title: 'Firestore Init',
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
  static const collectionName = 'touhokuCollection';
  final _data = {
    '1': {'name': '青森県', 'population': 124.9},
    '2': {'name': '岩手県', 'population': 122.9},
    '3': {'name': '秋田県', 'population': 96.6},
    '4': {'name': '宮城県', 'population': 230.6},
    '5': {'name': '山形県', 'population': 108.0},
    '6': {'name': '福島県', 'population': 184.8},
  };

  var _message = '';

  Future<void> _registerData() async {
    final collection = FirebaseFirestore.instance.collection(collectionName);
    for (final entry in _data.entries) {
      await collection.doc(entry.key).set(entry.value);
    }
    setState(() {
      _message = '登録完了';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Firestoreデータ登録')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _registerData,
              child: const Text('データ登録'),
            ),
            const SizedBox(height: 16),
            Text(_message),
          ],
        ),
      ),
    );
  }
}
