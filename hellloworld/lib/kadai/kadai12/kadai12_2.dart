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
      title: 'Profile Input',
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
  final _nameController = TextEditingController();
  final _zipcodeController = TextEditingController();
  final _cityController = TextEditingController();
  final _streetController = TextEditingController();
  final _buildingController = TextEditingController();
  final _phoneController = TextEditingController();

  static const _prefectures = [
    '',
    '北海道',
    '青森県',
    '岩手県',
    '宮城県',
    '秋田県',
    '山形県',
    '福島県',
    '茨城県',
    '栃木県',
    '群馬県',
    '埼玉県',
    '千葉県',
    '東京都',
    '神奈川県',
    '新潟県',
    '富山県',
    '石川県',
    '福井県',
    '山梨県',
    '長野県',
    '岐阜県',
    '静岡県',
    '愛知県',
    '三重県',
    '滋賀県',
    '京都府',
    '大阪府',
    '兵庫県',
    '奈良県',
    '和歌山県',
    '鳥取県',
    '島根県',
    '岡山県',
    '広島県',
    '山口県',
    '徳島県',
    '香川県',
    '愛媛県',
    '高知県',
    '福岡県',
    '佐賀県',
    '長崎県',
    '熊本県',
    '大分県',
    '宮崎県',
    '鹿児島県',
    '沖縄県',
  ];
  var _selectedPrefecture = '';

  @override
  void dispose() {
    _nameController.dispose();
    _zipcodeController.dispose();
    _cityController.dispose();
    _streetController.dispose();
    _buildingController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _searchAddress() async {
    final url = Uri.https('zipcloud.ibsnet.co.jp', '/api/search', {
      'zipcode': _zipcodeController.text,
    });
    final response = await http.get(url);
    final data = jsonDecode(response.body);
    final results = data['results'];
    if (results != null && results.isNotEmpty) {
      final result = results[0];
      setState(() {
        _selectedPrefecture = result['address1'];
        _cityController.text = '${result['address2']}${result['address3']}';
      });
    }
  }

  void _register() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('確認'),
        content: Text(
          '名前: ${_nameController.text}\n'
          '郵便番号: ${_zipcodeController.text}\n'
          '都道府県: $_selectedPrefecture\n'
          '市区町村: ${_cityController.text}\n'
          '丁目番地: ${_streetController.text}\n'
          'マンション名: ${_buildingController.text}\n'
          '電話番号: ${_phoneController.text}',
        ),
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
      appBar: AppBar(title: const Text('プロフィール入力')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: '名前'),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _zipcodeController,
                    decoration: const InputDecoration(labelText: '郵便番号'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _searchAddress,
                  child: const Text('検索'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: '都道府県'),
              value: _selectedPrefecture,
              items: _prefectures.map((pref) {
                return DropdownMenuItem(
                  value: pref,
                  child: Text(pref.isEmpty ? '選択してください' : pref),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedPrefecture = value ?? '';
                });
              },
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _cityController,
              decoration: const InputDecoration(labelText: '市区町村'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _streetController,
              decoration: const InputDecoration(labelText: '丁目番地'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _buildingController,
              decoration: const InputDecoration(labelText: 'マンション名'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: '電話番号'),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: _register, child: const Text('登録')),
          ],
        ),
      ),
    );
  }
}
