import 'package:flutter/material.dart';
import '../models/todo.dart';
import 'todo_tile.dart';

class TodoCard extends StatelessWidget {
  final Todo todo;
  final ValueChanged<bool?>? onChanged;
  final VoidCallback? onDelete;

  const TodoCard({
    super.key,
    required this.todo,
    this.onChanged,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return TodoTile(
      todo: todo,
      onChanged: onChanged,
      onDelete: onDelete,
    );
  }
}