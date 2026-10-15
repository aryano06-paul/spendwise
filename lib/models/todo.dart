enum TodoPriority {
  low,
  medium,
  high,
}

class Todo {
  final String id;
  final String title;
  final DateTime date;
  final TodoPriority priority;
  bool completed;

  Todo({
    required this.id,
    required this.title,
    required this.date,
    required this.priority,
    this.completed = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'date': date.toIso8601String(),
      'priority': priority.name,
      'completed': completed,
    };
  }

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'] as String,
      title: json['title'] as String,
      date: DateTime.parse(json['date'] as String),
      priority: TodoPriority.values.firstWhere(
        (priority) => priority.name == json['priority'],
        orElse: () => TodoPriority.medium,
      ),
      completed: json['completed'] as bool? ?? false,
    );
  }
}
