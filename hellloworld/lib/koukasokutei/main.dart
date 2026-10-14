import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';

import 'todo_repository.dart';
import 'firebase_options.dart';

part 'login_page.dart';
part 'register_page.dart';
part 'my_page.dart';
part 'todo_detail_page.dart';
part 'todo_input_page.dart';

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

class TodoStore extends ChangeNotifier {
  TodoStore(this.repository);

  final TodoRepository repository;
  AppUser? user;
  String? get userId => user?.id;
  List<Todo> todos = [];

  Future<void> register(String id, String password) async {
    user = await repository.register(id, password);
    todos = [];
    notifyListeners();
  }

  Future<void> login(String id, String password) async {
    final profile = await repository.login(id, password);
    try {
      final items = await repository.list(profile.id);
      user = profile;
      todos = items;
      notifyListeners();
    } catch (_) {
      await repository.logout();
      rethrow;
    }
  }

  Future<void> logout() async {
    await repository.logout();
    user = null;
    todos = [];
    notifyListeners();
  }

  Future<void> save({Todo? todo, required String title, required DateTime scheduledAt, required String detail}) async {
    final owner = userId!;
    final saved = await repository.save(
      userId: owner, todo: todo, title: title,
      scheduledAt: scheduledAt, detail: detail,
    );
    if (userId != owner) return;
    if (todo == null) {
      todos = [saved, ...todos];
    } else {
      todos = todos.map((item) => item.id == saved.id ? saved : item).toList();
    }
    notifyListeners();
  }

  Future<void> toggle(Todo todo) async {
    final owner = userId!;
    await repository.toggle(owner, todo);
    if (userId != owner) return;
    todos = todos.map((item) => item.id == todo.id
        ? Todo(
            id: item.id, userId: item.userId, title: item.title,
            scheduledAt: item.scheduledAt, detail: item.detail,
            createdAt: item.createdAt, updatedAt: DateTime.now(),
            isCompleted: !todo.isCompleted,
          )
        : item).toList();
    notifyListeners();
  }

  Future<void> delete(Todo todo) async {
    final owner = userId!;
    await repository.delete(owner, todo.id);
    if (userId != owner) return;
    todos = todos.where((item) => item.id != todo.id).toList();
    notifyListeners();
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

void showError(BuildContext context, Object error) {
  if (!context.mounted) return;
  final String message;
  if (error is FormatException) {
    message = error.message;
  } else if (error is FirebaseException) {
    message = switch (error.code) {
      'email-already-in-use' => 'このIDはすでに使われています。',
      'invalid-credential' || 'invalid-login-credentials' ||
      'wrong-password' || 'user-not-found' => 'IDまたはパスワードが違います。',
      'weak-password' => 'パスワードがFirebaseの設定条件を満たしていません。',
      'operation-not-allowed' => 'Firebase Authenticationでメール/パスワードを有効にしてください。',
      'permission-denied' => 'Firestoreのセキュリティルールを確認してください。',
      'network-request-failed' || 'unavailable' => '通信に失敗しました。ネット接続を確認してください。',
      'too-many-requests' => '試行回数が多すぎます。時間を置いて再試行してください。',
      'not-found' => 'ToDoが見つかりません。',
      _ => 'Firebaseの処理に失敗しました（${error.code}）。',
    };
  } else {
    message = '処理に失敗しました。もう一度お試しください。';
  }
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message.toString())));
}

String displayDate(DateTime date) {
  final value = date.toLocal();
  String pad(int number) => number.toString().padLeft(2, '0');
  return '${value.year}/${pad(value.month)}/${pad(value.day)} ${pad(value.hour)}:${pad(value.minute)}';
}

