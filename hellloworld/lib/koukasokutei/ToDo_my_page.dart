import 'package:flutter/material.dart';
import 'todo_store.dart';
import 'todo_utils.dart';
import 'ToDo_detail_page.dart';
import 'ToDo_input_page.dart';

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

