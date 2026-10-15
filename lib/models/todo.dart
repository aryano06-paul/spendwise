enum TodoPriority { low, medium, high }

extension TodoPriorityDetails on TodoPriority {
  String get label => switch (this) {
        TodoPriority.low => 'Low',
        TodoPriority.medium => 'Medium',
        TodoPriority.high => 'High',
      };
}

class Todo {
  final String id;
  final String title;
  final String notes;
  final DateTime createdAt;
  final DateTime? dueDate;
  final TodoPriority priority;
  final bool completed;

  const Todo({
    required this.id,
    required this.title,
    this.notes = '',
    required this.createdAt,
    this.dueDate,
    this.priority = TodoPriority.medium,
    this.completed = false,
  });

  Todo copyWith({
    String? title,
    String? notes,
    DateTime? dueDate,
    bool clearDueDate = false,
    TodoPriority? priority,
    bool? completed,
  }) => Todo(
        id: id,
        title: title ?? this.title,
        notes: notes ?? this.notes,
        createdAt: createdAt,
        dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
        priority: priority ?? this.priority,
        completed: completed ?? this.completed,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'notes': notes,
        'createdAt': createdAt.toIso8601String(),
        'dueDate': dueDate?.toIso8601String(),
        'priority': priority.name,
        'completed': completed,
      };

  factory Todo.fromJson(Map<String, dynamic> json) {
    final priorityName = json['priority'] as String? ?? 'medium';
    return Todo(
      id: json['id'] as String? ?? DateTime.now().microsecondsSinceEpoch.toString(),
      title: json['title'] as String? ?? 'Untitled task',
      notes: json['notes'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      dueDate: DateTime.tryParse(json['dueDate'] as String? ?? ''),
      priority: TodoPriority.values.firstWhere(
        (item) => item.name == priorityName,
        orElse: () => TodoPriority.medium,
      ),
      completed: json['completed'] as bool? ?? false,
    );
  }
}
