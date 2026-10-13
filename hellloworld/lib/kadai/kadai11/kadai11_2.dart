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
      title: 'Book Delete',
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
  static const _filterLabels = ['すべて', '読了', '未読'];
  var _docs = <QueryDocumentSnapshot>[];
  var _filter = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final collection = FirebaseFirestore.instance.collection(collectionName);
    late final QuerySnapshot snapshot;
    if (_filter == 1) {
      snapshot = await collection.where('isRead', isEqualTo: true).get();
    } else if (_filter == 2) {
      snapshot = await collection.where('isRead', isEqualTo: false).get();
    } else {
      snapshot = await collection.get();
    }
    setState(() {
      _docs = snapshot.docs;
    });
  }

  Future<void> _deleteDoc(String id) async {
    await FirebaseFirestore.instance
        .collection(collectionName)
        .doc(id)
        .delete();
  }

  void _onFilterChanged(int index) {
    setState(() {
      _filter = index;
    });
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('本の一覧'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const InsertPage()),
              ).then((_) => _loadData());
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < _filterLabels.length; i++)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(_filterLabels[i]),
                      selected: _filter == i,
                      onSelected: (_) {
                        _onFilterChanged(i);
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      body: _docs.isEmpty
          ? const Center(child: Text('データがありません'))
          : ListView(
              children: _docs.map((doc) {
                return Dismissible(
                  key: Key(doc.id),
                  onDismissed: (direction) {
                    _deleteDoc(doc.id);
                    setState(() {
                      _docs.remove(doc);
                    });
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("${doc.get("title")}を削除しました")),
                    );
                  },
                  background: Container(color: Colors.red),
                  child: ListTile(
                    leading: Icon(
                      doc.get('isRead')
                          ? Icons.check_box_outlined
                          : Icons.check_box_outline_blank,
                    ),
                    title: Text(doc.get('title')),
                    subtitle: Text(doc.get('author')),
                  ),
                );
              }).toList(),
            ),
    );
  }
}

class InsertPage extends StatefulWidget {
  const InsertPage({super.key});

  @override
  State<InsertPage> createState() => _InsertPageState();
}

class _InsertPageState extends State<InsertPage> {
  static const collectionName = 'bookCollection';
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    super.dispose();
  }

  Future<void> _insertData() async {
    if (_titleController.text.isEmpty) return;
    await FirebaseFirestore.instance.collection(collectionName).add({
      'title': _titleController.text,
      'author': _authorController.text,
      'isRead': false,
    });
    _titleController.clear();
    _authorController.clear();
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('登録完了'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('本の登録')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'タイトル'),
            ),
            TextField(
              controller: _authorController,
              decoration: const InputDecoration(labelText: '著者'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _insertData, child: const Text('登録')),
          ],
        ),
      ),
    );
  }
}
