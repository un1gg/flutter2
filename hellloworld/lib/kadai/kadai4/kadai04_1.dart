import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'File Memo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const MyHomePage(title: 'メモ帳（ファイル保存）'),
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
  List<String> _memos = [];
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMemos();
  }

  Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/memos.txt');
  }

  Future<void> _loadMemos() async {
    final file = await _getFile();
    if (await file.exists()) {
      final content = await file.readAsString();
      setState(() {
        _memos = content.isNotEmpty ? content.split('\n') : [];
      });
    }
  }

  Future<void> _saveMemos() async {
    final file = await _getFile();
    await file.writeAsString(_memos.join('\n'));
  }

  Future<void> _addMemo() async {
    if (_controller.text.isEmpty) return;
    setState(() {
      _memos.add(_controller.text);
    });
    _controller.clear();
    await _saveMemos();
  }

  @override
  void dispose() {
    _controller.dispose();
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
                  .map((memo) => ListTile(title: Text(memo)))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
