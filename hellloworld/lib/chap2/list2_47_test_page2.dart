// リスト2.47
import 'package:flutter/material.dart';

class TestPage2 extends StatelessWidget {
  const TestPage2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Test2")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () => {
                Navigator.of(context).pushNamed("/test3"),
                //下記の書き方でも可
                // Navigator.pushNamed(context,"/test2")
              },
              child: const Text("進む", style: TextStyle(fontSize: 80)),
            ),
            TextButton(
              onPressed: () => {Navigator.of(context).pop()},
              child: const Text("戻る", style: TextStyle(fontSize: 80)),
            ),
          ],
        ),
      ),
    );
  }
}
