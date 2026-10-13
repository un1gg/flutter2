// pubspec.yamlに以下を追記してください

// dependencies:
//   http: any
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              'INTERNET ACCESS.',
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
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.open_in_new),
        onPressed: () {
          setData();
          showDialog(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: Text("loaded!"),
              content: Text("get content from URI."),
            ),
          );
        },
      ),
    );
  }

  Future<void> setData() async {
    // https://jsonplaceholder.typicode.com/posts
    const host = 'jsonplaceholder.typicode.com';
    const path = '/posts';
    final url = Uri.https(host, path);

    final ob = {
      "title": "foo",
      "author": "SYODA-Tuyano",
      "content": "this is content. これはサンプルのコンテンツです。",
    };
    final jsondata = json.encode(ob);

    const headers = {'Content-Type': 'application/json; charset=UTF-8'};

    final response = await http.post(url, body: jsondata, headers: headers);
    final value = response.body;
    _controller.text = value;
  }
}
