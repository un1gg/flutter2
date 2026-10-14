import 'package:flutter/foundation.dart';

import 'todo_repository.dart';

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

