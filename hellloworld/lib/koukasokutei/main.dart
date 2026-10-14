import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'todo_repository.dart';
import 'todo_store.dart';
import 'todo_login_page.dart';
import 'todo_my_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
    final repository = await TodoRepository.open();
    runApp(TodoApp(store: TodoStore(repository)));
  } catch (error) {
    runApp(MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Firebase接続設定')),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Firebaseを初期化できませんでした。'
                  'koukasokutei/README.mdの接続手順を確認してください。'),
              const SizedBox(height: 16),
              Text(error.toString()),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: main, child: const Text('再試行')),
            ],
          ),
        ),
      ),
    ));
  }
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key, required this.store});

  final TodoStore store;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ToDo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF253D60)),
        scaffoldBackgroundColor: const Color(0xFFF5F7F9),
        inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder()),
      ),
      home: AnimatedBuilder(
        animation: store,
        builder: (context, child) => store.userId == null
            ? LoginPage(store: store)
            : MyPage(store: store),
      ),
    );
  }
}

