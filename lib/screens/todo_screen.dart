import 'package:flutter/material.dart';
import '../models/todo.dart';

class TodoScreen extends StatefulWidget {
  final List<Todo> todos;
  final void Function(Todo) onAddTodo;
  final void Function(String) onDeleteTodo;
  final VoidCallback onTodosChanged;

  const TodoScreen({
    super.key,
    required this.todos,
    required this.onAddTodo,
    required this.onDeleteTodo,
    required this.onTodosChanged,
  });

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final TextEditingController _titleController =
  TextEditingController();

  TodoPriority _selectedPriority =
      TodoPriority.medium;

  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  int get completedCount {
    return widget.todos
        .where((todo) => todo.completed)
        .length;
  }

  int get pendingCount {
    return widget.todos
        .where((todo) => !todo.completed)
        .length;
  }

  double get completionProgress {
    if (widget.todos.isEmpty) {
      return 0.0;
    }

    return completedCount / widget.todos.length;
  }

  List<Todo> get todayTodos {
    final now = DateTime.now();

    return widget.todos.where((todo) {
      return todo.date.year == now.year &&
          todo.date.month == now.month &&
          todo.date.day == now.day;
    }).toList();
  }

  List<Todo> get upcomingTodos {
    final now = DateTime.now();

    final endOfToday = DateTime(
      now.year,
      now.month,
      now.day,
      23,
      59,
      59,
    );

    return widget.todos
        .where(
          (todo) => todo.date.isAfter(endOfToday),
    )
        .toList();
  }

  List<Todo> get pastTodos {
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);

    return widget.todos
        .where((todo) => todo.date.isBefore(startOfToday))
        .toList();
  }

  void _toggleTodo(Todo todo) {
    setState(() {
      todo.completed = !todo.completed;
    });
    widget.onTodosChanged();
  }

  void _addTodo() {
    final title = _titleController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a task title.'),
        ),
      );
      return;
    }

    final todo = Todo(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
      date: _selectedDate,
      priority: _selectedPriority,
    );

    widget.onAddTodo(todo);

    _titleController.clear();

    setState(() {
      _selectedPriority = TodoPriority.medium;
      _selectedDate = DateTime.now();
    });

    Navigator.of(context).pop();
  }

  void _openAddTodoSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _AddTodoSheet(
          titleController: _titleController,
          selectedPriority: _selectedPriority,
          selectedDate: _selectedDate,
          onPriorityChanged: (priority) {
            setState(() {
              _selectedPriority = priority;
            });
          },
          onDateChanged: (date) {
            setState(() {
              _selectedDate = date;
            });
          },
          onSave: _addTodo,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
      Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            20,
            22,
            20,
            120,
          ),
          children: [
            _header(context),
            const SizedBox(height: 20),
            _productivityCard(context),
            const SizedBox(height: 28),
            _sectionTitle(context, 'Today'),
            const SizedBox(height: 12),
            if (todayTodos.isEmpty)
              _emptyToday(context)
            else
              ...todayTodos.map(
                    (todo) => Padding(
                  padding:
                  const EdgeInsets.only(bottom: 10),
                  child: _todoCard(
                    context,
                    todo,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            _sectionTitle(context, 'Upcoming'),
            const SizedBox(height: 12),
            if (upcomingTodos.isEmpty)
              _emptyUpcoming(context)
            else
              ...upcomingTodos.map(
                    (todo) => Padding(
                  padding:
                  const EdgeInsets.only(bottom: 10),
                  child: _todoCard(
                    context,
                    todo,
                  ),
                ),
              ),
            if (pastTodos.isNotEmpty) ...[
              const SizedBox(height: 16),
              _sectionTitle(context, 'Earlier'),
              const SizedBox(height: 12),
              ...pastTodos.map(
                (todo) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _todoCard(
                    context,
                    todo,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      floatingActionButton:
      FloatingActionButton.extended(
        onPressed: _openAddTodoSheet,
        backgroundColor:
        const Color(0xFF675CF6),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Add Task',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                'My Tasks',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.6,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Plan better. Do better.',
                style: TextStyle(
                  color: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.color
                      ?.withValues(alpha: 0.60),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.tune_rounded,
            size: 21,
          ),
        ),
      ],
    );
  }

  Widget _productivityCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: Theme.of(context)
              .dividerColor
              .withValues(alpha: 0.06),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 68,
            height: 68,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 68,
                  height: 68,
                  child: CircularProgressIndicator(
                    value: completionProgress,
                    strokeWidth: 7,
                    backgroundColor:
                    Theme.of(context)
                        .dividerColor
                        .withValues(alpha: 0.12),
                    valueColor:
                    const AlwaysStoppedAnimation<
                        Color>(
                      Color(0xFF675CF6),
                    ),
                  ),
                ),
                Text(
                  '${(completionProgress * 100).round()}%',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                const Text(
                  'Today’s productivity',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '$completedCount completed • '
                      '$pendingCount pending',
                  style: TextStyle(
                    color: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.color
                        ?.withValues(alpha: 0.60),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 7),
                const Text(
                  'Keep the streak alive.',
                  style: TextStyle(
                    color: Color(0xFF675CF6),
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(
      BuildContext context,
      String title,
      ) {
    return Text(
      title,
      style: Theme.of(context)
          .textTheme
          .titleMedium
          ?.copyWith(
        fontSize: 19,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  Widget _todoCard(
      BuildContext context,
      Todo todo,
      ) {
    final priorityColor =
    _priorityColor(todo.priority);

    return Dismissible(
      key: ValueKey(todo.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        widget.onDeleteTodo(todo.id);
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(
          right: 22,
        ),
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(21),
        ),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: Colors.white,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(21),
          border: Border.all(
            color: Theme.of(context)
                .dividerColor
                .withValues(alpha: 0.06),
          ),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => _toggleTodo(todo),
              child: AnimatedContainer(
                duration:
                const Duration(milliseconds: 180),
                width: 27,
                height: 27,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: todo.completed
                      ? const Color(0xFF675CF6)
                      : Colors.transparent,
                  border: Border.all(
                    color: todo.completed
                        ? const Color(0xFF675CF6)
                        : Theme.of(context)
                        .dividerColor,
                    width: 2,
                  ),
                ),
                child: todo.completed
                    ? const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 17,
                )
                    : null,
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    todo.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      decoration: todo.completed
                          ? TextDecoration.lineThrough
                          : null,
                      color: todo.completed
                          ? Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.color
                          : Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_formatDate(todo.date)} • '
                        '${_formatTime(todo.date)}',
                    style: TextStyle(
                      color: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.color
                          ?.withValues(alpha: 0.60),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 9,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color:
                priorityColor.withValues(
                  alpha: 0.10,
                ),
                borderRadius:
                BorderRadius.circular(12),
              ),
              child: Text(
                _priorityName(todo.priority),
                style: TextStyle(
                  color: priorityColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyToday(BuildContext context) {
    return _emptyBox(
      context,
      'No tasks for today',
      'Enjoy the empty space or add something new.',
    );
  }

  Widget _emptyUpcoming(BuildContext context) {
    return _emptyBox(
      context,
      'Nothing planned yet',
      'Add a future task whenever you are ready.',
    );
  }

  Widget _emptyBox(
      BuildContext context,
      String title,
      String subtitle,
      ) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.check_circle_outline_rounded,
            color: Color(0xFF675CF6),
            size: 40,
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.color
                  ?.withValues(alpha: 0.60),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Color _priorityColor(TodoPriority priority) {
    switch (priority) {
      case TodoPriority.low:
        return const Color(0xFF16A36A);
      case TodoPriority.medium:
        return const Color(0xFF675CF6);
      case TodoPriority.high:
        return const Color(0xFFFF5578);
    }
  }

  String _priorityName(TodoPriority priority) {
    switch (priority) {
      case TodoPriority.low:
        return 'Low';
      case TodoPriority.medium:
        return 'Medium';
      case TodoPriority.high:
        return 'High';
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];

    return '${date.day} ${months[date.month - 1]}';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour == 0
        ? 12
        : date.hour > 12
        ? date.hour - 12
        : date.hour;

    final minute =
    date.minute.toString().padLeft(2, '0');

    final suffix = date.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $suffix';
  }
}

class _AddTodoSheet extends StatefulWidget {
  final TextEditingController titleController;
  final TodoPriority selectedPriority;
  final DateTime selectedDate;
  final ValueChanged<TodoPriority> onPriorityChanged;
  final ValueChanged<DateTime> onDateChanged;
  final VoidCallback onSave;

  const _AddTodoSheet({
    required this.titleController,
    required this.selectedPriority,
    required this.selectedDate,
    required this.onPriorityChanged,
    required this.onDateChanged,
    required this.onSave,
  });

  @override
  State<_AddTodoSheet> createState() => _AddTodoSheetState();
}

class _AddTodoSheetState extends State<_AddTodoSheet> {
  late TodoPriority _priority = widget.selectedPriority;
  late DateTime _date = widget.selectedDate;

  @override
  Widget build(BuildContext context) {
    final bottom =
        MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.fromLTRB(
          20,
          12,
          20,
          20 + bottom,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(30),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .dividerColor
                        .withValues(alpha: 0.20),
                    borderRadius:
                    BorderRadius.circular(30),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Add Task',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: widget.titleController,
                decoration: const InputDecoration(
                  labelText: 'Task title',
                  hintText:
                  'e.g. Complete assignment',
                  prefixIcon:
                  Icon(Icons.checklist_rounded),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Priority',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: TodoPriority.values.map(
                      (priority) {
                    return ChoiceChip(
                      label: Text(
                        _priorityName(priority),
                      ),
                      selected: _priority == priority,
                      onSelected: (_) {
                        setState(() {
                          _priority = priority;
                        });
                        widget.onPriorityChanged(
                          priority,
                        );
                      },
                    );
                  },
                ).toList(),
              ),
              const SizedBox(height: 18),
              InkWell(
                onTap: () async {
                  final picked =
                  await showDatePicker(
                    context: context,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2035),
                    initialDate: _date,
                  );

                  if (picked == null || !mounted) {
                    return;
                  }

                  setState(() {
                    _date = picked;
                  });
                  widget.onDateChanged(picked);
                },
                borderRadius:
                BorderRadius.circular(18),
                child: Ink(
                  padding:
                  const EdgeInsets.all(17),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius:
                    BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_rounded,
                        color:
                        Color(0xFF675CF6),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Date',
                          style: TextStyle(
                            fontWeight:
                            FontWeight.w700,
                          ),
                        ),
                      ),
                      Text(
                        '${_date.day}/'
                            '${_date.month}/'
                            '${_date.year}',
                        style: const TextStyle(
                          fontWeight:
                          FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: FilledButton(
                  onPressed: widget.onSave,
                  style:
                  FilledButton.styleFrom(
                    backgroundColor:
                    const Color(0xFF675CF6),
                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    'Save Task',
                    style: TextStyle(
                      fontWeight:
                      FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _priorityName(
      TodoPriority priority,
      ) {
    switch (priority) {
      case TodoPriority.low:
        return 'Low';
      case TodoPriority.medium:
        return 'Medium';
      case TodoPriority.high:
        return 'High';
    }
  }
}
