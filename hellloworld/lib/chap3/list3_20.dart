// リスト3.20
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

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
  String lastWords = '';
  String lastError = '';
  String lastStatus = '';
  stt.SpeechToText speech = stt.SpeechToText();

  // 音声入力開始
  Future<void> _speak() async {
    bool available = await speech.initialize(
      onError: errorListener,
      onStatus: statusListener,
    );
    if (available) {
      speech.listen(onResult: resultListener);
    } else {
      // ignore: avoid_print
      print("The user has denied the use of speech recognition.");
    }
  }

  // 音声入力停止
  Future<void> _stop() async {
    speech.stop();
  }

  // リザルトリスナー
  void resultListener(SpeechRecognitionResult result) {
    setState(() {
      lastWords = result.recognizedWords;
    });
  }

  // エラーリスナー
  void errorListener(SpeechRecognitionError error) {
    setState(() {
      lastError = '${error.errorMsg} - ${error.permanent}';
    });
  }

  // ステータスリスナー
  void statusListener(String status) {
    setState(() {
      lastStatus = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '変換文字:$lastWords',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              'ステータス : $lastStatus',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: Row(
        spacing: 10,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _speak,
            child: const Icon(Icons.play_arrow),
          ),
          FloatingActionButton(onPressed: _stop, child: const Icon(Icons.stop)),
        ],
      ),
    );
  }
}
