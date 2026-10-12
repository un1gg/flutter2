import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Camera Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const MyHomePage(title: '演習課題06-2'),
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
  File? _savedImage;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadSavedImage();
  }

  Future<void> _loadSavedImage() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/photo.jpg');
    if (await file.exists()) {
      setState(() {
        _savedImage = file;
      });
    }
  }

  Future<void> _takePhotoAndSave() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      final dir = await getApplicationDocumentsDirectory();
      final savedFile = await File(
        pickedFile.path,
      ).copy('${dir.path}/photo.jpg');
      setState(() {
        _savedImage = savedFile;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('アプリ内に保存しました')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
        child: _savedImage == null
            ? const Text('写真を撮影してください')
            : Image.file(
                _savedImage!,
                width: 300,
                height: 300,
                fit: BoxFit.contain,
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _takePhotoAndSave,
        child: const Icon(Icons.photo_camera),
      ),
    );
  }
}
