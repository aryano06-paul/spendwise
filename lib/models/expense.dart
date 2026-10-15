import 'package:flutter/material.dart';

enum ExpenseCategory {
  food,
  transport,
  shopping,
  bills,
  health,
  education,
  entertainment,
  home,
  other,
}

extension ExpenseCategoryDetails on ExpenseCategory {
  String get label => switch (this) {
        ExpenseCategory.food => 'Food & Drink',
        ExpenseCategory.transport => 'Transport',
        ExpenseCategory.shopping => 'Shopping',
        ExpenseCategory.bills => 'Bills',
        ExpenseCategory.health => 'Health',
        ExpenseCategory.education => 'Education',
        ExpenseCategory.entertainment => 'Entertainment',
        ExpenseCategory.home => 'Home',
        ExpenseCategory.other => 'Other',
      };

  IconData get icon => switch (this) {
        ExpenseCategory.food => Icons.restaurant_rounded,
        ExpenseCategory.transport => Icons.directions_car_rounded,
        ExpenseCategory.shopping => Icons.shopping_bag_rounded,
        ExpenseCategory.bills => Icons.receipt_long_rounded,
        ExpenseCategory.health => Icons.favorite_rounded,
        ExpenseCategory.education => Icons.school_rounded,
        ExpenseCategory.entertainment => Icons.movie_rounded,
        ExpenseCategory.home => Icons.home_rounded,
        ExpenseCategory.other => Icons.category_rounded,
      };

  Color get color => switch (this) {
        ExpenseCategory.food => const Color(0xFF16A085),
        ExpenseCategory.transport => const Color(0xFF4786E8),
        ExpenseCategory.shopping => const Color(0xFF9866D8),
        ExpenseCategory.bills => const Color(0xFFE99A35),
        ExpenseCategory.health => const Color(0xFFE76582),
        ExpenseCategory.education => const Color(0xFF4EA4B8),
        ExpenseCategory.entertainment => const Color(0xFFDA6A48),
        ExpenseCategory.home => const Color(0xFF6C8F63),
        ExpenseCategory.other => const Color(0xFF8992A7),
      };
}

class Expense {
  final String id;
  final String title;
  final double amount;
  final ExpenseCategory category;
  final DateTime date;
  final String note;

  const Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.note = '',
  });

  Expense copyWith({
    String? title,
    double? amount,
    ExpenseCategory? category,
    DateTime? date,
    String? note,
  }) => Expense(
        id: id,
        title: title ?? this.title,
        amount: amount ?? this.amount,
        category: category ?? this.category,
        date: date ?? this.date,
        note: note ?? this.note,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'amount': amount,
        'category': category.name,
        'date': date.toIso8601String(),
        'note': note,
      };

  factory Expense.fromJson(Map<String, dynamic> json) {
    final categoryName = json['category'] as String? ?? 'other';
    return Expense(
      id: json['id'] as String? ?? DateTime.now().microsecondsSinceEpoch.toString(),
      title: json['title'] as String? ?? 'Untitled expense',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      category: ExpenseCategory.values.firstWhere(
        (item) => item.name == categoryName,
        orElse: () => ExpenseCategory.other,
      ),
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
      note: json['note'] as String? ?? '',
    );
  }
}
