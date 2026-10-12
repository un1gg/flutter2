// リスト3.5
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

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
  VideoPlayerController? _controller;
  final imagePicker = ImagePicker();

  // カメラから動画を取得するメソッド
  Future<void> getVideoFromCamera() async {
    XFile? pickedFile = await imagePicker.pickVideo(source: ImageSource.camera);
    if (pickedFile != null) {
      _controller = VideoPlayerController.file(File(pickedFile.path));
      _controller!.initialize().then((_) {
        setState(() {
          _controller!.play();
        });
      });
    }
  }

  // ギャラリーから動画を取得するメソッド
  Future<void> getVideoFromGarally() async {
    XFile? pickedFile = await imagePicker.pickVideo(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      _controller = VideoPlayerController.file(File(pickedFile.path));
      _controller!.initialize().then((_) {
        setState(() {
          _controller!.play();
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
        // 取得した動画を表示(ない場合はメッセージ)
        child: _controller == null || !_controller!.value.isInitialized
            ? Text(
                '動画を選択してください',
                style: Theme.of(context).textTheme.headlineMedium,
              )
            : VideoPlayer(_controller!),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // カメラから取得するボタン
          FloatingActionButton(
            onPressed: getVideoFromCamera,
            child: const Icon(Icons.video_call),
          ),
          // ギャラリーから取得するボタン
          FloatingActionButton(
            onPressed: getVideoFromGarally,
            child: const Icon(Icons.movie_creation),
          ),
        ],
      ),
    );
  }
}
