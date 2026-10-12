// リスト2.47
import 'package:flutter/material.dart';

class TestPage1 extends StatelessWidget {
  const TestPage1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Test1")),
      body: Center(
        child: TextButton(
          onPressed: () => {
            Navigator.of(context).pushNamed("/test2"),
            //下記の書き方でも可
            // Navigator.pushNamed(context,"/test2")
          },
          child: const Text("進む", style: TextStyle(fontSize: 80)),
        ),
      ),
    );
  }
}
