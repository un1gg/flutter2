import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppUser {
  const AppUser({
    required this.id,
    required this.loginId,
    required this.createdAt,
  });

  final String id;
  final String loginId;
  final DateTime createdAt;

  factory AppUser.fromMap(String id, Map<String, dynamic> data) => AppUser(
    id: id,
    loginId: data['loginId'] as String,
    createdAt: (data['createdAt'] as Timestamp).toDate(),
  );

  Map<String, dynamic> toMap() => {
    'loginId': loginId,
    'createdAt': Timestamp.fromDate(createdAt),
  };
}

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

  factory Todo.fromMap(String id, Map<String, dynamic> data) => Todo(
    id: id,
    userId: data['userId'] as String,
    title: data['title'] as String,
    scheduledAt: (data['scheduledAt'] as Timestamp).toDate(),
    detail: data['detail'] as String,
    createdAt: (data['createdAt'] as Timestamp).toDate(),
    updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    isCompleted: data['isCompleted'] as bool,
  );
}

class TodoRepository {
  TodoRepository._(this.auth, this.firestore);

  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  static Future<TodoRepository> open() async {
    final repository = TodoRepository._(
      FirebaseAuth.instance,
      FirebaseFirestore.instance,
    );
    await repository.auth.signOut();
    return repository;
  }

  String _loginId(String input) {
    final id = input.trim();
    if (id.isEmpty || id.length > 32) {
      throw const FormatException('IDは1〜32文字で入力してください。');
    }
    return id;
  }

  String _email(String id) =>
      '${sha256.convert(utf8.encode(id))}@todo.example.com';

  Future<AppUser> register(String inputId, String password) async {
    final id = _loginId(inputId);
    if (password.length < 6 || password.length > 64) {
      throw const FormatException('パスワードは6〜64文字で入力してください。');
    }
    final credential = await auth.createUserWithEmailAndPassword(
      email: _email(id),
      password: password,
    );
    final user = credential.user!;
    final profile = AppUser(
      id: user.uid,
      loginId: id,
      createdAt: DateTime.now(),
    );
    try {
      await firestore.collection('users').doc(user.uid).set(profile.toMap());
      return profile;
    } catch (_) {
      await auth.signOut();
      throw const FormatException(
        '認証アカウントは作成されましたが、ユーザー情報の保存に失敗しました。'
        'Firestoreの設定とルールを確認してから、同じIDでログインしてください。',
      );
    }
  }

  Future<AppUser> login(String inputId, String password) async {
    final id = _loginId(inputId);
    try {
      final credential = await auth.signInWithEmailAndPassword(
        email: _email(id),
        password: password,
      );
      final user = credential.user!;
      final ref = firestore.collection('users').doc(user.uid);
      final snapshot = await ref.get(const GetOptions(source: Source.server));
      if (snapshot.exists) {
        return AppUser.fromMap(user.uid, snapshot.data()!);
      }
      final profile = AppUser(
        id: user.uid,
        loginId: id,
        createdAt: user.metadata.creationTime ?? DateTime.now(),
      );
      await ref.set(profile.toMap());
      return profile;
    } catch (_) {
      await auth.signOut();
      rethrow;
    }
  }

  Future<void> logout() => auth.signOut();

  void _checkUser(String userId) {
    if (auth.currentUser?.uid != userId) {
      throw const FormatException('ログインし直してください。');
    }
  }

  Future<List<Todo>> list(String userId) async {
    _checkUser(userId);
    final snapshot = await firestore
        .collection('todos')
        .where('userId', isEqualTo: userId)
        .get(const GetOptions(source: Source.server));
    final todos = snapshot.docs
        .map((doc) => Todo.fromMap(doc.id, doc.data()))
        .toList();
    todos.sort((a, b) {
      final order = b.createdAt.compareTo(a.createdAt);
      return order == 0 ? b.id.compareTo(a.id) : order;
    });
    return todos;
  }

  Future<Todo> save({
    required String userId,
    Todo? todo,
    required String title,
    required DateTime scheduledAt,
    required String detail,
  }) async {
    _checkUser(userId);
    final cleanTitle = title.trim();
    final cleanDetail = detail.trim();
    if (cleanTitle.isEmpty || cleanTitle.length > 100 ||
        cleanDetail.length > 1000) {
      throw const FormatException(
        'タイトルは1〜100文字、詳細は1000文字以内で入力してください。',
      );
    }
    final data = <String, dynamic>{
      'title': cleanTitle,
      'scheduledAt': Timestamp.fromDate(scheduledAt),
      'detail': cleanDetail,
      'updatedAt': Timestamp.now(),
    };
    final ref = todo == null
        ? firestore.collection('todos').doc()
        : firestore.collection('todos').doc(todo.id);
    final createdAt = todo?.createdAt ?? DateTime.now();
    if (todo == null) {
      await ref.set({
        ...data,
        'userId': userId,
        'createdAt': Timestamp.fromDate(createdAt),
        'isCompleted': false,
      });
    } else {
      await ref.update(data);
    }
    return Todo(
      id: ref.id,
      userId: userId,
      title: cleanTitle,
      scheduledAt: scheduledAt,
      detail: cleanDetail,
      createdAt: createdAt,
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      isCompleted: todo?.isCompleted ?? false,
    );
  }

  Future<void> toggle(String userId, Todo todo) async {
    _checkUser(userId);
    await firestore.collection('todos').doc(todo.id).update({
      'isCompleted': !todo.isCompleted,
      'updatedAt': Timestamp.now(),
    });
  }

  Future<void> delete(String userId, String todoId) async {
    _checkUser(userId);
    await firestore.collection('todos').doc(todoId).delete();
  }
}
