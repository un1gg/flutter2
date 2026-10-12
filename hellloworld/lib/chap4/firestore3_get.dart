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
      title: 'Firestore Get',
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
  final _idController = TextEditingController();
  String _result = 'IDを入力してください';

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  Future<void> _getData() async {
    if (_idController.text.isEmpty) {
      setState(() {
        _result = 'IDを入力してください';
      });
      return;
    }
    final doc = await FirebaseFirestore.instance
        .collection(collectionName)
        .doc(_idController.text)
        .get();
    if (doc.exists) {
      setState(() {
        _result =
            'name: ${doc.get('name')}, population: ${doc.get('population')}';
      });
    } else {
      setState(() {
        _result = 'ドキュメントが見つかりません';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Firestoreデータ取得')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _idController,
                decoration: const InputDecoration(labelText: 'ID'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _getData, child: const Text('取得')),
              const SizedBox(height: 16),
              Text(_result),
            ],
          ),
        ),
      ),
    );
  }
}
