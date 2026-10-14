import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'todo_repository.dart';
import 'todo_store.dart';
import 'todo_utils.dart';

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
