// リスト6-2
// ※ 注意 ブラウザ環境では動作しません
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Generated App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _controller = TextEditingController();
  final _fname = 'flutter_sampledata.txt';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              'FILE ACCESS.',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.w500),
            ),
            Padding(padding: EdgeInsets.all(10.0)),
            TextField(
              controller: _controller,
              style: TextStyle(fontSize: 24),
              minLines: 1,
              maxLines: 5,
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.blue,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white,
        currentIndex: 0,
        items: [
          BottomNavigationBarItem(
            label: 'Save',
            icon: Icon(Icons.save, color: Colors.white, size: 32),
          ),
          BottomNavigationBarItem(
            label: 'Load',
            icon: Icon(Icons.open_in_new, color: Colors.white, size: 32),
          ),
        ],
        onTap: (int value) async {
          switch (value) {
            case 0:
              saveIt(_controller.text);
              setState(() {
                _controller.text = '';
              });
              showDialog(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: Text("saved!"),
                  content: Text("save message to file."),
                ),
              );
            case 1:
              String value = await loadIt();
              setState(() {
                _controller.text = value;
              });

              // （修正点）asyncの中でcontextは使うとクラッシュする可能性があるため
              //          利用前に存在チェックを行います
              if (!context.mounted) return;

              showDialog(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: Text("loaded!"),
                  content: Text("load message from file."),
                ),
              );
            default:
              print('no defalut.');
          }
        },
      ),
    );
  }

  Future<File> getDataFile(String filename) async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$filename');
  }

  Future<void> saveIt(String value) async {
    final file = await getDataFile(_fname);
    file.writeAsString(value);
  }

  Future<String> loadIt() async {
    try {
      final file = await getDataFile(_fname);
      return file.readAsString();
    } catch (e) {
      return '*** no data ***';
    }
  }
}
