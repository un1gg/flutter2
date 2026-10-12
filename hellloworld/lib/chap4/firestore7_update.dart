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
      title: 'Firestore Update',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const ListPage(),
    );
  }
}

// 一覧ページ
class ListPage extends StatefulWidget {
  const ListPage({super.key});

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  static const collectionName = 'touhokuCollection';
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
      appBar: AppBar(title: const Text('Firestoreドキュメント一覧')),
      body: _docs.isEmpty
          ? const Center(child: Text('ドキュメントがありません'))
          : ListView(
              children: _docs.map((doc) {
                return ListTile(
                  leading: Text(doc.id),
                  title: Text("${doc.get("name")}"),
                  subtitle: Text("人口${doc.get("population")}万人"),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailPage(docId: doc.id),
                      ),
                    ).then((_) => _loadData());
                  },
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

// 詳細・更新ページ
class DetailPage extends StatefulWidget {
  final String docId;
  const DetailPage({super.key, required this.docId});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
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

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    final doc = await FirebaseFirestore.instance
        .collection(collectionName)
        .doc(widget.docId)
        .get();
    if (doc.exists) {
      _nameController.text = doc.get('name');
      _populationController.text = doc.get('population').toString();
    }
  }

  Future<void> _updateData() async {
    final name = _nameController.text;
    final population = double.tryParse(_populationController.text);
    if (name.isEmpty || population == null) {
      setState(() {
        _message = '入力内容を確認してください';
      });
      return;
    }
    await FirebaseFirestore.instance
        .collection(collectionName)
        .doc(widget.docId)
        .update({'name': name, 'population': population});
    setState(() {
      _message = '更新完了';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('詳細: ${widget.docId}')),
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
              ElevatedButton(onPressed: _updateData, child: const Text('更新')),
              const SizedBox(height: 16),
              Text(_message),
            ],
          ),
        ),
      ),
    );
  }
}
