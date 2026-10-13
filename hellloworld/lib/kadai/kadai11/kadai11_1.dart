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
      title: 'Book Insert',
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

class InsertPage extends StatefulWidget {
  const InsertPage({super.key});

  @override
  State<InsertPage> createState() => _InsertPageState();
}

class _InsertPageState extends State<InsertPage> {
  static const collectionName = 'bookCollection';
  final _titleController = TextEditingController();
  String? _titleError;
  final _authorController = TextEditingController();
  String? _authorError;

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    super.dispose();
  }

  Future<void> _insertData() async {
    if (_titleController.text.isEmpty) {
      setState(() {
        _titleError = 'タイトルを入力してください';
      });
      return;
    } else {
      setState(() {
        _titleError = null;
      });
    }
    if (_authorController.text.isEmpty) {
      setState(() {
        _authorError = '著者を入力してください';
      });
      return;
    } else {
      setState(() {
        _authorError = null;
      });
    }
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
              decoration: InputDecoration(
                labelText: 'タイトル',
                errorText: _titleError,
              ),
            ),
            TextField(
              controller: _authorController,
              decoration: InputDecoration(
                labelText: '著者',
                errorText: _authorError,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _insertData, child: const Text('登録')),
          ],
        ),
      ),
    );
  }
}
