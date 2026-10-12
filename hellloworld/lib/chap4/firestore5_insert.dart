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
      title: 'Firestore Insert',
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
  final _nameController = TextEditingController();
  final _populationController = TextEditingController();
  String _message = '';

  @override
  void dispose() {
    _nameController.dispose();
    _populationController.dispose();
    super.dispose();
  }

  Future<void> _insertData() async {
    final name = _nameController.text;
    final population = double.tryParse(_populationController.text);
    if (name.isEmpty || population == null) {
      setState(() {
        _message = '入力内容を確認してください';
      });
      return;
    }
    await FirebaseFirestore.instance.collection(collectionName).add({
      'name': name,
      'population': population,
    });
    setState(() {
      _message = '登録完了';
    });
    _nameController.clear();
    _populationController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Firestoreデータ登録')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: '都道府県名'),
              ),
              TextField(
                controller: _populationController,
                decoration: const InputDecoration(labelText: '人口（万人）'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _insertData, child: const Text('登録')),
              const SizedBox(height: 16),
              Text(_message),
            ],
          ),
        ),
      ),
    );
  }
}
