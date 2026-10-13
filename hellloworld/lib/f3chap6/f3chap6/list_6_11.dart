// リスト6-11
// ※ 注意 ブラウザ環境では動作しません
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

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
  static const url = 'https://jsonplaceholder.typicode.com/posts';

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
    final ob = {
      "title": "foo",
      "author": "SYODA-Tuyano",
      "content": "this is content. これはサンプルのコンテンツです。",
    };
    final jsondata = json.encode(ob);
    var https = HttpClient();
    HttpClientRequest request = await https.postUrl(Uri.parse(url));
    request.headers.set(
      HttpHeaders.contentTypeHeader,
      "application/json; charset=UTF-8",
    );
    request.write(jsondata);
    HttpClientResponse response = await request.close();
    final value = await response.transform(utf8.decoder).join();
    _controller.text = value;
  }
}
