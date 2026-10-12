// リスト3.3
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
  XFile? _image;
  final imagePicker = ImagePicker();

  // カメラから写真を取得するメソッド
  Future<void> getImageFromCamera() async {
    final pickedFile = await imagePicker.pickImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null) {
        // ignore: avoid_print
        print(pickedFile.path);
        // （修正点）pickedFileはそもそもXFileクラスなのでそのまま使えます
        _image = pickedFile;
      }
    });
  }

  // ギャラリーから写真を取得するメソッド
  Future<void> getImageFromGallery() async {
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = pickedFile;
        // ignore: avoid_print
        print(pickedFile.path);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
        // 取得した写真を表示（ない場合はメッセージ）
        child: _image == null
            ? Text(
                '写真を選択してください',
                style: Theme.of(context).textTheme.headlineMedium,
              )
            : Image.file(File(_image!.path)),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // カメラから取得するボタン
          FloatingActionButton(
            onPressed: getImageFromCamera,
            child: const Icon(Icons.photo_camera),
          ),
          // ギャラリーから取得するボタン
          FloatingActionButton(
            onPressed: getImageFromGallery,
            child: const Icon(Icons.photo_album),
          ),
        ],
      ),
    );
  }
}
