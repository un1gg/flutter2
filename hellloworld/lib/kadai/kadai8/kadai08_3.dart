import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TTS Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const MyHomePage(title: '演習課題08-3'),
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
  final _controller = TextEditingController();
  final _tts = FlutterTts();
  var _rate = 0.5;
  var _volume = 1.0;
  var _pitch = 1.0;

  @override
  void initState() {
    super.initState();
    _loadPref();
  }

  Future<void> _loadPref() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _rate = prefs.getDouble('rate') ?? 0.5;
      _volume = prefs.getDouble('volume') ?? 1.0;
      _pitch = prefs.getDouble('pitch') ?? 1.0;
    });
  }

  Future<void> _savePref() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setDouble('rate', _rate);
    prefs.setDouble('volume', _volume);
    prefs.setDouble('pitch', _pitch);
  }

  Future<void> _speak() async {
    if (_controller.text.isEmpty) return;
    await _tts.setLanguage("ja-JP");
    await _tts.setSpeechRate(_rate);
    await _tts.setVolume(_volume);
    await _tts.setPitch(_pitch);
    await _tts.speak(_controller.text);
  }

  Future<void> _stop() async {
    await _tts.stop();
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: '読み上げるテキストを入力',
              ),
              minLines: 5,
              maxLines: 5,
            ),
            const SizedBox(height: 20),
            Text('速度: ${_rate.toStringAsFixed(2)}'),
            Slider(
              min: 0.0,
              max: 1.0,
              value: _rate,
              onChanged: (value) {
                setState(() => _rate = value);
              },
              onChangeEnd: (_) {
                _savePref();
              },
            ),
            Text('音量: ${_volume.toStringAsFixed(2)}'),
            Slider(
              min: 0.0,
              max: 1.0,
              value: _volume,
              onChanged: (value) {
                setState(() => _volume = value);
              },
              onChangeEnd: (_) {
                _savePref();
              },
            ),
            Text('ピッチ: ${_pitch.toStringAsFixed(2)}'),
            Slider(
              min: 0.5,
              max: 2.0,
              value: _pitch,
              onChanged: (value) {
                setState(() => _pitch = value);
              },
              onChangeEnd: (_) {
                _savePref();
              },
            ),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _speak,
            child: const Icon(Icons.play_arrow),
          ),
          const SizedBox(width: 10),
          FloatingActionButton(onPressed: _stop, child: const Icon(Icons.stop)),
        ],
      ),
    );
  }
}
