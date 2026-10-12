// リスト2.50
import 'package:flutter/material.dart';

class TestPage2 extends StatelessWidget {
  const TestPage2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Test2")),
      body: Center(
        child: Container(
          color: Colors.greenAccent,
          child: const Text("Test2", style: TextStyle(fontSize: 80)),
        ),
      ),
    );
  }
}
