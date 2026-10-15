import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../utils/app_format.dart';

class TodoCard extends StatelessWidget {
  final Todo todo;
  final VoidCallback onTap;
  const TodoCard({super.key, required this.todo, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(children: [
            Icon(todo.completed ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded, color: todo.completed ? Colors.green : theme.colorScheme.primary),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(todo.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.w800, decoration: todo.completed ? TextDecoration.lineThrough : null)), if (todo.dueDate != null) Text('Due ${formatDate(todo.dueDate!)}', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant))])),
            const Icon(Icons.chevron_right_rounded),
          ]),
        ),
      ),
    );
  }
}
