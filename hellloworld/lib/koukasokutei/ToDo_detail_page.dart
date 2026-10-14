import 'package:flutter/material.dart';
import 'todo_repository.dart';
import 'todo_store.dart';
import 'todo_utils.dart';
import 'ToDo_input_page.dart';

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

