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
}
