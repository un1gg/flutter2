import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'todo_store.dart';
import 'todo_utils.dart';

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

