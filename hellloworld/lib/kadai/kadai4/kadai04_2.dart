import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SQLite Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const MyHomePage(title: 'メモ帳'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  const MyHomePage({super.key, required this.title});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Database? _db;
  List<Map<String, dynamic>> _memos = [];
  final _controller = TextEditingController();
  var _result = '';

  @override
  void initState() {
    super.initState();
    _initDb();
  }

  Future<void> _initDb() async {
    final dir = await getApplicationDocumentsDirectory();
    _db = await openDatabase(
      '${dir.path}/sqlite.db',
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE memos(id INTEGER PRIMARY KEY AUTOINCREMENT, text TEXT)',
        );
      },
      version: 1,
    );
    _loadMemos();
  }

  Future<void> _loadMemos() async {
    final data = await _db!.query('memos');
    setState(() {
      _memos = data;
    });
  }

  Future<void> _addMemo() async {
    if (_controller.text.isEmpty) return;
    await _db!.insert('memos', {'text': _controller.text});
    _controller.clear();
    _loadMemos();
  }

  Future<void> _deleteMemo(int id) async {
    await _db!.delete('memos', where: 'id = ?', whereArgs: [id]);
    _loadMemos();
  }

  Future<void> _query() async {
    final query = await _db!.rawQuery('SELECT * FROM memos');
    setState(() {
      _result = "$query";
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _db?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(hintText: 'メモを入力'),
                  ),
                ),
                IconButton(onPressed: _addMemo, icon: const Icon(Icons.add)),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: _memos
                  .map(
                    (memo) => ListTile(
                      title: Text(memo['text']),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          _deleteMemo(memo['id']);
                        },
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          ElevatedButton(onPressed: _query, child: const Text('Query')),
          Text(_result),
        ],
      ),
    );
  }
}
