// リスト2.37
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
  // （変更点：戻り値の型を明記し、asyncを削除しました）
  void _click() {
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
            AnimatedOpacity(
              opacity: _flag ? 0.1 : 1.0,
              duration: const Duration(seconds: 3),
              child: Text(
                "消える文字",
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            // 実機であっても縮小アニメーションは動作しません
            AnimatedSize(
              duration: const Duration(seconds: 3),
              child: SizedBox(
                width: _flag ? 50 : 200,
                height: _flag ? 50 : 200,
                child: Container(color: Colors.purple),
              ),
            ),
            // （追記：P127に記載のAnimatedContainerを使うと縮小アニメーションも表示されます）
            AnimatedContainer(
              duration: const Duration(seconds: 3),
              width: _flag ? 50 : 200,
              height: _flag ? 50 : 200,
              color: Colors.purpleAccent,
            ),

            AnimatedAlign(
              duration: const Duration(seconds: 3),
              alignment: _flag ? Alignment.topLeft : Alignment.bottomRight,
              child: SizedBox(
                width: 50,
                height: 50,
                child: Container(color: Colors.green),
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
