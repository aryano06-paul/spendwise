import 'package:flutter/material.dart';

import '../app_state.dart';
import '../utils/app_format.dart';
import '../widgets/editor_sheets.dart';
import '../widgets/todo_tile.dart';

class TodoScreen extends StatefulWidget {
  final SpendWiseState state;
  const TodoScreen({super.key, required this.state});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  String _filter = 'Open';
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = DateTime.now();
    final items = widget.state.todos.where((todo) {
      final matchesStatus = switch (_filter) {
        'Completed' => todo.completed,
        'All' => true,
        'Today' => !todo.completed && todo.dueDate != null && isSameDay(todo.dueDate!, today),
        _ => !todo.completed,
      };
      final matchesQuery = _query.isEmpty ||
          todo.title.toLowerCase().contains(_query) ||
          todo.notes.toLowerCase().contains(_query);
      return matchesStatus && matchesQuery;
    }).toList()
      ..sort((a, b) {
        if (a.completed != b.completed) return a.completed ? 1 : -1;
        if (a.dueDate == null && b.dueDate == null) return b.createdAt.compareTo(a.createdAt);
        if (a.dueDate == null) return 1;
        if (b.dueDate == null) return -1;
        return a.dueDate!.compareTo(b.dueDate!);
      });

    final completion = widget.state.todos.isEmpty ? 0.0 : widget.state.completedTodoCount / widget.state.todos.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Focus', style: TextStyle(fontWeight: FontWeight.w900)),
        actions: [
          IconButton(tooltip: 'Add task', onPressed: () => showTodoEditor(context, widget.state), icon: const Icon(Icons.add_circle_outline_rounded)),
          const SizedBox(width: 6),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showTodoEditor(context, widget.state),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New task'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 4, 18, 15),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(color: widget.state.accentColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(15)),
                          child: Icon(Icons.bolt_rounded, color: widget.state.accentColor),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Make room for progress', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                              Text('${widget.state.pendingTodoCount} tasks to go · ${widget.state.completedTodoCount} done', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    ClipRRect(borderRadius: BorderRadius.circular(20), child: LinearProgressIndicator(value: completion, minHeight: 8)),
                    const SizedBox(height: 7),
                    Text('${(completion * 100).round()}% completed', style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: TextField(
              onChanged: (value) => setState(() => _query = value.trim().toLowerCase()),
              decoration: const InputDecoration(prefixIcon: Icon(Icons.search_rounded), hintText: 'Search tasks'),
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              children: ['Open', 'Today', 'Completed', 'All']
                  .map((filter) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(filter),
                  selected: _filter == filter,
                  onSelected: (_) => setState(() => _filter = filter),
                ),
              ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: items.isEmpty
                ? Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.task_alt_rounded, size: 52, color: widget.state.accentColor),
                    const SizedBox(height: 12),
                    Text(_filter == 'Completed' ? 'No completed tasks yet' : 'Nothing on this list', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                    const SizedBox(height: 7),
                    Text('Add a task, pick a priority, and optionally set a due date.', textAlign: TextAlign.center, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                    const SizedBox(height: 12),
                    FilledButton.icon(onPressed: () => showTodoEditor(context, widget.state), icon: const Icon(Icons.add_rounded), label: const Text('Create task')),
                  ],
                ),
              ),
            )
                : ListView.separated(
              padding: const EdgeInsets.fromLTRB(18, 3, 18, 90),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final todo = items[index];
                return Dismissible(
                  key: ValueKey(todo.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 22),
                    decoration: BoxDecoration(color: theme.colorScheme.error, borderRadius: BorderRadius.circular(20)),
                    child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
                  ),
                  confirmDismiss: (_) => confirmDelete(context, title: 'Delete task?', message: '“${todo.title}” will be removed.'),
                  onDismissed: (_) => widget.state.deleteTodo(todo.id),
                  child: TodoTile(
                    todo: todo,
                    onChanged: (_) => widget.state.toggleTodo(todo.id),
                    onEdit: () => showTodoEditor(context, widget.state, existing: todo),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
