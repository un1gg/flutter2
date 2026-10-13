import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zipcode Search',
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
  final _zipcodeController = TextEditingController();
  var _address = '';

  @override
  void dispose() {
    _zipcodeController.dispose();
    super.dispose();
  }

  Future<void> _searchAddress() async {
    final url = Uri.https('zipcloud.ibsnet.co.jp', '/api/search', {
      'zipcode': _zipcodeController.text,
    });
    final response = await http.get(url);
    final data = jsonDecode(response.body);
    final results = data['results'];
    setState(() {
      if (results != null && results.isNotEmpty) {
        final result = results[0];
        _address =
            '${result['address1']}${result['address2']}${result['address3']}';
      } else {
        _address = '住所が見つかりません';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('郵便番号検索')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _zipcodeController,
              decoration: const InputDecoration(labelText: '郵便番号'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _searchAddress, child: const Text('検索')),
            const SizedBox(height: 24),
            Text(_address, style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
