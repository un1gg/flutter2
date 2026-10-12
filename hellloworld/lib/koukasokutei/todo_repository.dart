import 'dart:convert';
import 'dart:isolate';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

class Todo {
  const Todo({
    required this.id,
    required this.userId,
    required this.title,
    required this.scheduledAt,
    required this.detail,
    required this.createdAt,
    required this.updatedAt,
    required this.isCompleted,
  });

  final String id;
  final String userId;
  final String title;
  final DateTime scheduledAt;
  final String detail;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isCompleted;

  factory Todo.fromMap(Map<String, Object?> map) => Todo(
        id: map['todoId'] as String,
        userId: map['userId'] as String,
        title: map['title'] as String,
        scheduledAt: DateTime.parse(map['scheduledAt'] as String),
        detail: map['detail'] as String,
        createdAt: DateTime.parse(map['createdAt'] as String),
        updatedAt: DateTime.parse(map['updatedAt'] as String),
        isCompleted: map['isCompleted'] == 1,
      );
}

class TodoRepository {
  TodoRepository._(this.db);

  final Database db;

  static Future<TodoRepository> open() async {
    final database = await openDatabase(
      path.join(await getDatabasesPath(), 'todo_app.db'),
      version: 1,
      onConfigure: (db) async => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users (
            userId TEXT PRIMARY KEY,
            loginId TEXT NOT NULL UNIQUE,
            passwordHash TEXT NOT NULL,
            createdAt TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE todos (
            todoId TEXT PRIMARY KEY,
            userId TEXT NOT NULL REFERENCES users(userId) ON DELETE CASCADE,
            title TEXT NOT NULL,
            scheduledAt TEXT NOT NULL,
            detail TEXT NOT NULL DEFAULT '',
            createdAt TEXT NOT NULL,
            updatedAt TEXT NOT NULL,
            isCompleted INTEGER NOT NULL DEFAULT 0 CHECK(isCompleted IN (0, 1))
          )
        ''');
        await db.execute('CREATE INDEX todos_user_created ON todos(userId, createdAt DESC)');
      },
    );
    return TodoRepository._(database);
  }

  Future<String> register(String inputId, String password) async {
    final loginId = inputId.trim();
    if (loginId.isEmpty || loginId.length > 32 || password.length < 6 || password.length > 64) {
      throw const FormatException('IDは1〜32文字、パスワードは6〜64文字で入力してください。');
    }
    final existing = await db.query('users', columns: ['userId'], where: 'loginId = ?', whereArgs: [loginId], limit: 1);
    if (existing.isNotEmpty) {
      throw const FormatException('このIDはすでに使われています。');
    }
    final salt = _randomHex();
    final digest = await Isolate.run(() => _derivePassword(password, salt));
    final userId = _randomHex();
    try {
      await db.insert('users', {
        'userId': userId,
        'loginId': loginId,
        'passwordHash': '$salt:$digest',
        'createdAt': DateTime.now().toUtc().toIso8601String(),
      });
    } on DatabaseException catch (error) {
      if (error.isUniqueConstraintError()) {
        throw const FormatException('このIDはすでに使われています。');
      }
      rethrow;
    }
    return userId;
  }

  Future<String> login(String inputId, String password) async {
    final rows = await db.query('users', where: 'loginId = ?', whereArgs: [inputId.trim()], limit: 1);
    if (rows.isEmpty) {
      throw const FormatException('IDまたはパスワードが違います。');
    }
    final stored = rows.single['passwordHash'] as String;
    final parts = stored.split(':');
    final digest = await Isolate.run(() => _derivePassword(password, parts.first));
    if (parts.length != 2 || !_sameDigest(digest, parts.last)) {
      throw const FormatException('IDまたはパスワードが違います。');
    }
    return rows.single['userId'] as String;
  }

  Future<List<Todo>> list(String userId) async {
    final rows = await db.query('todos', where: 'userId = ?', whereArgs: [userId], orderBy: 'createdAt DESC, rowid DESC');
    return rows.map(Todo.fromMap).toList();
  }

  Future<void> save({required String userId, String? todoId, required String title, required DateTime scheduledAt, required String detail}) async {
    final cleanTitle = title.trim();
    final cleanDetail = detail.trim();
    if (cleanTitle.isEmpty || cleanTitle.length > 100 || cleanDetail.length > 1000) {
      throw const FormatException('タイトルは1〜100文字、詳細は1000文字以内で入力してください。');
    }
    final timestamp = DateTime.now().toUtc().toIso8601String();
    if (todoId == null) {
      await db.insert('todos', {
        'todoId': _randomHex(),
        'userId': userId,
        'title': cleanTitle,
        'scheduledAt': scheduledAt.toIso8601String(),
        'detail': cleanDetail,
        'createdAt': timestamp,
        'updatedAt': timestamp,
        'isCompleted': 0,
      });
    } else {
      final count = await db.update('todos', {
        'title': cleanTitle,
        'scheduledAt': scheduledAt.toIso8601String(),
        'detail': cleanDetail,
        'updatedAt': timestamp,
      }, where: 'todoId = ? AND userId = ?', whereArgs: [todoId, userId]);
      if (count == 0) throw const FormatException('ToDoが見つかりません。');
    }
  }

  Future<void> toggle(String userId, Todo todo) async {
    final count = await db.update('todos', {
      'isCompleted': todo.isCompleted ? 0 : 1,
      'updatedAt': DateTime.now().toUtc().toIso8601String(),
    }, where: 'todoId = ? AND userId = ?', whereArgs: [todo.id, userId]);
    if (count == 0) throw const FormatException('ToDoが見つかりません。');
  }

  Future<void> delete(String userId, String todoId) async {
    final count = await db.delete('todos', where: 'todoId = ? AND userId = ?', whereArgs: [todoId, userId]);
    if (count == 0) throw const FormatException('ToDoが見つかりません。');
  }
}

String _randomHex() {
  final random = Random.secure();
  return List<int>.generate(16, (_) => random.nextInt(256)).map((value) => value.toRadixString(16).padLeft(2, '0')).join();
}

String _derivePassword(String password, String saltHex) {
  final salt = <int>[for (var i = 0; i < saltHex.length; i += 2) int.parse(saltHex.substring(i, i + 2), radix: 16)];
  final mac = Hmac(sha256, utf8.encode(password));
  var block = mac.convert([...salt, 0, 0, 0, 1]).bytes;
  final result = List<int>.from(block);
  for (var iteration = 1; iteration < 120000; iteration++) {
    block = mac.convert(block).bytes;
    for (var i = 0; i < result.length; i++) {
      result[i] ^= block[i];
    }
  }
  return result.map((value) => value.toRadixString(16).padLeft(2, '0')).join();
}

bool _sameDigest(String actual, String expected) {
  var diff = actual.length ^ expected.length;
  final count = actual.length < expected.length ? actual.length : expected.length;
  for (var i = 0; i < count; i++) {
    diff |= actual.codeUnitAt(i) ^ expected.codeUnitAt(i);
  }
  return diff == 0;
}
