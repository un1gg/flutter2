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
      title: 'Firestore Where',
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
  final _populationController = TextEditingController();
  var _docs = <QueryDocumentSnapshot>[];

  @override
  void dispose() {
    _populationController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final value = double.tryParse(_populationController.text);
    if (value == null) return;
    final snapshot = await FirebaseFirestore.instance
        .collection(collectionName)
        .where('population', isGreaterThanOrEqualTo: value)
        .orderBy(
          'population',
          descending: true,
        ) // whereと同じフィールドであればソート可 異なる場合はインデックスの作成が必要
        .get();
    setState(() {
      _docs = snapshot.docs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Firestore Where検索')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _populationController,
              decoration: const InputDecoration(labelText: '人口（万人）'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _search, child: const Text('検索')),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: _docs.map((doc) {
                  return ListTile(
                    leading: Text(doc.id),
                    title: Text(doc.get('name')),
                    subtitle: Text('人口: ${doc.get('population')}万人'),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
