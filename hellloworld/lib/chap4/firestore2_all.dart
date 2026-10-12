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
      title: 'Firestore All',
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
  var _docs = <QueryDocumentSnapshot>[];

  Future<void> _loadData() async {
    final snapshot = await FirebaseFirestore.instance
        .collection(collectionName)
        .get();
    setState(() {
      _docs = snapshot.docs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Firestoreドキュメント一覧')),
      body: _docs.isEmpty
          ? const Center(child: Text('ドキュメントがありません'))
          : ListView(
              children: _docs.map((doc) {
                return ListTile(
                  leading: Text(doc.id),
                  title: Text("${doc.get("name")}"),
                  subtitle: Text("人口${doc.get("population")}万人"),
                );
              }).toList(),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadData,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
