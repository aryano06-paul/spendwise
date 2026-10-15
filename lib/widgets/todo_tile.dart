import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../utils/app_format.dart';

class TodoTile extends StatelessWidget {
  final Todo todo;
  final ValueChanged<bool> onChanged;
  final VoidCallback onEdit;

  const TodoTile({super.key, required this.todo, required this.onChanged, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final priorityColor = switch (todo.priority) {
      TodoPriority.high => theme.colorScheme.error,
      TodoPriority.medium => const Color(0xFFDB9630),
      TodoPriority.low => const Color(0xFF299B7A),
    };
    return Card(
      child: ListTile(
        leading: Checkbox(value: todo.completed, onChanged: (value) => onChanged(value ?? false), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))),
        title: Text(todo.title, style: TextStyle(fontWeight: FontWeight.w800, decoration: todo.completed ? TextDecoration.lineThrough : null, color: todo.completed ? theme.colorScheme.onSurfaceVariant : null)),
        subtitle: Padding(padding: const EdgeInsets.only(top: 5), child: Wrap(spacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [Container(width: 7, height: 7, decoration: BoxDecoration(color: priorityColor, shape: BoxShape.circle)), Text(todo.priority.label, style: theme.textTheme.bodySmall?.copyWith(color: priorityColor)), if (todo.dueDate != null) Text('Due ${formatDate(todo.dueDate!)}', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant))])),
        trailing: IconButton(onPressed: onEdit, tooltip: 'Edit task', icon: const Icon(Icons.more_horiz_rounded)),
      ),
    );
  }
}
