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
      title: 'Book List',
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
  var _docs = <QueryDocumentSnapshot>[];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

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
      appBar: AppBar(title: const Text('本の一覧')),
      body: _docs.isEmpty
          ? const Center(child: Text('データがありません'))
          : ListView(
              children: _docs.map((doc) {
                return ListTile(
                  leading: Icon(
                    doc.get('isRead')
                        ? Icons.check_box_outlined
                        : Icons.check_box_outline_blank,
                  ),
                  title: Text(doc.get('title')),
                  subtitle: Text(doc.get('author')),
                );
              }).toList(),
            ),
    );
  }
}
