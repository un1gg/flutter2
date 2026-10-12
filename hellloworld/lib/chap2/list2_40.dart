// リスト2.40
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

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animationDouble;
  final Tween<double> _tweenDouble = Tween(begin: 0.0, end: 200.0);
  late Animation<Color?> _animationColor;
  final ColorTween _tweenColor = ColorTween(
    begin: Colors.green,
    end: Colors.blue,
  );

  // 再生
  void _forward() {
    setState(() {
      _animationController.forward();
    });
  }

  // 停止
  void _stop() {
    setState(() {
      _animationController.stop();
    });
  }

  // 逆再生
  void _reverse() {
    setState(() {
      _animationController.reverse();
    });
  }

  // 生成
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    // TweenとAnimationControllerからAnimationを作る(サイズ)
    _animationDouble = _tweenDouble.animate(_animationController);
    _animationDouble.addListener(() {
      setState(() {});
    });
    // TweenとAnimationControllerからAnimationを作る(色)
    _animationColor = _tweenColor.animate(_animationController);
    _animationColor.addListener(() {
      setState(() {});
    });
  }

  // 破棄
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("AnimationController:${_animationController.value}"),
            Text("AnimationDouble:${_animationDouble.value}"),
            Text("AnimationColor:${_animationColor.value}"),
            SizeTransition(
              sizeFactor: _animationController,
              child: Center(
                child: SizedBox(
                  width: _animationDouble.value,
                  height: _animationDouble.value,
                  child: Container(color: _animationColor.value),
                ),
              ),
            ),
          ],
        ),
      ),
      // 再生、停止、逆再生のボタン
      floatingActionButton: Row(
        spacing: 10,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FloatingActionButton(
            onPressed: _forward,
            child: const Icon(Icons.arrow_forward),
          ),
          FloatingActionButton(
            onPressed: _stop,
            child: const Icon(Icons.pause),
          ),
          FloatingActionButton(
            onPressed: _reverse,
            child: const Icon(Icons.arrow_back),
          ),
        ],
      ),
    );
  }
}
