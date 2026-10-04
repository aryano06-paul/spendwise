enum ExpenseCategory {
  food,
  transport,
  shopping,
  bills,
  health,
  education,
  entertainment,
  other,
}

class Expense {
  final String id;
  final String title;
  final double amount;
  final ExpenseCategory category;
  final DateTime date;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
  });
}