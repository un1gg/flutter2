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
      title: 'Book Where',
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
