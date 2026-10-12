// リスト2.38
import 'package:flutter/material.dart';

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
  bool _flag = false;

  // ボタンタップ時にフラグを切り替える
  Future<void> _click() async {
    setState(() {
      _flag = !_flag;
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
            // transformは滑らかにアニメーションされませんが、Flutterの仕様です
            AnimatedContainer(
              duration: const Duration(seconds: 3),
              width: _flag ? 100 : 50,
              height: _flag ? 50 : 100,
              padding: _flag
                  ? const EdgeInsets.all(0)
                  : const EdgeInsets.all(30),
              margin: _flag
                  ? const EdgeInsets.all(0)
                  : const EdgeInsets.all(30),
              transform: _flag ? Matrix4.skewX(0.0) : Matrix4.skewX(0.3),
              color: _flag ? Colors.blue : Colors.grey,
            ),
            // （変更点：切り替わるウィジェットにkeyプロパティを設定することで滑らかにアニメーションします）
            AnimatedSwitcher(
              duration: const Duration(seconds: 3),
              child: _flag
                  ? const Text(
                      "なにもない",
                      // ValueKeyでこのウィジェットの識別子を与える
                      key: ValueKey("text-widget"),
                    )
                  : const Icon(
                      Icons.favorite,
                      color: Colors.pink,
                      key: ValueKey("icon-widget"),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _click,
        child: const Icon(Icons.add),
      ),
    );
  }
}
