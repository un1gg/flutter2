import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';

import 'todo_repository.dart';
import 'firebase_options.dart';

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

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.store});
  final TodoStore store;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  final id = TextEditingController();
  final password = TextEditingController();
  bool busy = false;

  @override
  void dispose() {
    id.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate() || busy) return;
    setState(() => busy = true);
    try {
      await widget.store.login(id.text, password.text);
    } catch (error) {
      if (mounted) showError(context, error);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ToDo')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('ログイン', style: Theme.of(context).textTheme.headlineMedium),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: id,
                        decoration: const InputDecoration(labelText: 'ID'),
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.username],
                        validator: (value) => value == null || value.trim().isEmpty ? 'IDを入力してください。' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: password,
                        decoration: const InputDecoration(labelText: 'パスワード'),
                        obscureText: true,
                        autofillHints: const [AutofillHints.password],
                        onFieldSubmitted: (_) => submit(),
                        validator: (value) => value == null || value.isEmpty ? 'パスワードを入力してください。' : null,
                      ),
                      const SizedBox(height: 24),
                      FilledButton(onPressed: busy ? null : submit, child: const Text('ログイン')),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: busy ? null : () => Navigator.of(context).push(MaterialPageRoute<void>(
                          builder: (_) => RegisterPage(store: widget.store),
                        )),
                        child: const Text('アカウント登録'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key, required this.store});
  final TodoStore store;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final formKey = GlobalKey<FormState>();
  final id = TextEditingController();
  final password = TextEditingController();
  bool busy = false;

  @override
  void dispose() {
    id.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate() || busy) return;
    setState(() => busy = true);
    try {
      await widget.store.register(id.text, password.text);
      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      if (mounted) showError(context, error);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('アカウント登録')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('アカウント登録', style: Theme.of(context).textTheme.headlineMedium),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: id,
                        decoration: const InputDecoration(labelText: 'ID', helperText: '1〜32文字・重複不可'),
                        inputFormatters: [LengthLimitingTextInputFormatter(32)],
                        validator: (value) => value == null || value.trim().isEmpty ? 'IDを入力してください。' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: password,
                        decoration: const InputDecoration(labelText: 'パスワード', helperText: '6〜64文字'),
                        obscureText: true,
                        inputFormatters: [LengthLimitingTextInputFormatter(64)],
                        validator: (value) => value == null || value.length < 6 ? '6文字以上で入力してください。' : null,
                      ),
                      const SizedBox(height: 24),
                      FilledButton(onPressed: busy ? null : submit, child: const Text('登録')),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MyPage extends StatelessWidget {
  const MyPage({super.key, required this.store});
  final TodoStore store;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('マイページ'),
        actions: [
          TextButton(
            onPressed: () async {
              try {
                await store.logout();
              } catch (error) {
                if (context.mounted) showError(context, error);
              }
            },
            child: const Text('ログアウト'),
          ),
        ],
      ),
      body: store.todos.isEmpty
          ? const Center(child: Text('まだToDoはありません。\nToDo入力から登録してください。', textAlign: TextAlign.center))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: store.todos.length,
              separatorBuilder: (_, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final todo = store.todos[index];
                return Card(
                  child: ListTile(
                    leading: Checkbox(
                      value: todo.isCompleted,
                      onChanged: (_) async {
                        try {
                          await store.toggle(todo);
                        } catch (error) {
                          if (context.mounted) showError(context, error);
                        }
                      },
                    ),
                    title: Text(todo.title, style: TextStyle(decoration: todo.isCompleted ? TextDecoration.lineThrough : null)),
                    subtitle: Text(displayDate(todo.scheduledAt)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                      builder: (_) => TodoDetailPage(store: store, todo: todo),
                    )),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(
          builder: (_) => TodoInputPage(store: store),
        )),
        label: const Text('ToDo入力'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}

class TodoDetailPage extends StatelessWidget {
  const TodoDetailPage({super.key, required this.store, required this.todo});
  final TodoStore store;
  final Todo todo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ToDo詳細')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(todo.isCompleted ? '完了' : '未完了', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                  const SizedBox(height: 12),
                  Text(todo.title, style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 24),
                  const Text('日時'),
                  Text(displayDate(todo.scheduledAt)),
                  const SizedBox(height: 24),
                  const Text('詳細'),
                  Text(todo.detail.isEmpty ? '詳細はありません。' : todo.detail),
                  const SizedBox(height: 28),
                  FilledButton(
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(
                      builder: (_) => TodoInputPage(store: store, todo: todo),
                    )),
                    child: const Text('編集'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TodoInputPage extends StatefulWidget {
  const TodoInputPage({super.key, required this.store, this.todo});
  final TodoStore store;
  final Todo? todo;

  @override
  State<TodoInputPage> createState() => _TodoInputPageState();
}

class _TodoInputPageState extends State<TodoInputPage> {
  final formKey = GlobalKey<FormState>();
  late final TextEditingController title = TextEditingController(text: widget.todo?.title ?? '');
  late final TextEditingController detail = TextEditingController(text: widget.todo?.detail ?? '');
  DateTime? scheduled;
  bool busy = false;

  @override
  void initState() {
    super.initState();
    scheduled = widget.todo?.scheduledAt;
  }

  @override
  void dispose() {
    title.dispose();
    detail.dispose();
    super.dispose();
  }

  Future<void> selectDate() async {
    final initial = scheduled ?? DateTime.now();
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      initialDate: initial,
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: scheduled == null ? TimeOfDay.now() : TimeOfDay.fromDateTime(initial),
    );
    if (time == null || !mounted) return;
    setState(() => scheduled = DateTime(date.year, date.month, date.day, time.hour, time.minute));
  }

  Future<void> save() async {
    if (!formKey.currentState!.validate() || busy) return;
    if (scheduled == null) {
      showError(context, const FormatException('日時を選択してください。'));
      return;
    }
    setState(() => busy = true);
    try {
      await widget.store.save(todo: widget.todo, title: title.text, scheduledAt: scheduled!, detail: detail.text);
      if (mounted) {
        if (widget.todo == null) {
          Navigator.of(context).pop();
        } else {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      }
    } catch (error) {
      if (mounted) showError(context, error);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> delete() async {
    final todo = widget.todo;
    if (todo == null || busy) return;
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ToDoを削除しますか？'),
        content: const Text('削除したToDoは元に戻せません。'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('キャンセル')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('削除')),
        ],
      ),
    );
    if (accepted != true || !mounted) return;
    setState(() => busy = true);
    try {
      await widget.store.delete(todo);
      if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (error) {
      if (mounted) showError(context, error);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.todo == null ? 'ToDo入力' : 'ToDo編集')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: title,
                    decoration: const InputDecoration(labelText: 'タイトル（必須）'),
                    inputFormatters: [LengthLimitingTextInputFormatter(100)],
                    validator: (value) => value == null || value.trim().isEmpty ? 'タイトルを入力してください。' : null,
                  ),
                  const SizedBox(height: 20),
                  OutlinedButton.icon(
                    onPressed: busy ? null : selectDate,
                    icon: const Icon(Icons.calendar_today_outlined),
                    label: Text(scheduled == null ? '日時を選択（必須）' : displayDate(scheduled!)),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: detail,
                    decoration: const InputDecoration(labelText: '詳細（任意）', alignLabelWithHint: true),
                    maxLines: 5,
                    inputFormatters: [LengthLimitingTextInputFormatter(1000)],
                  ),
                  const SizedBox(height: 28),
                  FilledButton(onPressed: busy ? null : save, child: const Text('保存')),
                  if (widget.todo != null) ...[
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: busy ? null : delete,
                      child: const Text('削除'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
