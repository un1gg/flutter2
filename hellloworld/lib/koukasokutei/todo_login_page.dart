import 'package:flutter/material.dart';
import 'todo_store.dart';
import 'todo_utils.dart';
import 'todo_register_page.dart';

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

