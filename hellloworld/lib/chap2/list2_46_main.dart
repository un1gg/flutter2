// リスト2.46
import 'package:flutter/material.dart';
import 'list2_47_test_page1.dart';
import 'list2_47_test_page2.dart';
import 'list2_47_test_page3.dart';

void main() {
  runApp(MyApp());
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
      routes: {
        "/test1": (BuildContext context) => TestPage1(),
        "/test2": (BuildContext context) => TestPage2(),
        "/test3": (BuildContext context) => TestPage3(),
      },
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: TestPage1());
  }
}
