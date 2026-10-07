import 'package:flutter/material.dart';
import '../models/expense.dart';

class AnalyticsScreen extends StatelessWidget {
  final List<Expense> expenses;

  const AnalyticsScreen({
    super.key,
    required this.expenses,
  });

  double get totalSpent {
    return expenses.fold(
      0.0,
          (sum, expense) => sum + expense.amount,
    );
  }

  Map<ExpenseCategory, double> get categoryTotals {
    final totals = <ExpenseCategory, double>{};

    for (final category in ExpenseCategory.values) {
      totals[category] = 0.0;
    }

    for (final expense in expenses) {
      totals[expense.category] =
          (totals[expense.category] ?? 0.0) +
              expense.amount;
    }

    return totals;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
      Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Analytics',
          style: TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          20,
          5,
          20,
          30,
        ),
        children: [
          _periodSelector(context),
          const SizedBox(height: 18),
          _overviewCard(context),
          const SizedBox(height: 22),
          Text(
            'Category Insights',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          _categoryCard(context),
          const SizedBox(height: 22),
          _insightCard(context),
        ],
      ),
    );
  }

  Widget _periodSelector(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _periodItem(
            'Week',
            false,
          ),
          _periodItem(
            'Month',
            true,
          ),
          _periodItem(
            'Year',
            false,
          ),
        ],
      ),
    );
  }

  Widget _periodItem(
      String title,
      bool selected,
      ) {
    return Expanded(
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF675CF6)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: selected
                ? Colors.white
                : Colors.grey,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Widget _overviewCard(BuildContext context) {
    final values = _dailyValues();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Theme.of(context)
              .dividerColor
              .withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          const Text(
            'Spending Overview',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 190,
            child: Row(
              crossAxisAlignment:
              CrossAxisAlignment.end,
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
              children: List.generate(
                values.length,
                    (index) {
                  return Column(
                    mainAxisAlignment:
                    MainAxisAlignment.end,
                    children: [
                      Container(
                        width: 27,
                        height: 135 * values[index],
                        decoration: BoxDecoration(
                          borderRadius:
                          BorderRadius.circular(10),
                          gradient:
                          const LinearGradient(
                            begin:
                            Alignment.topCenter,
                            end:
                            Alignment.bottomCenter,
                            colors: [
                              Color(0xFF8C84FF),
                              Color(0xFF675CF6),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _dayLabel(index),
                        style: TextStyle(
                          fontSize: 10,
                          color: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.color
                              ?.withValues(alpha: 0.60),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            '₹${totalSpent.toStringAsFixed(0)}',
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'Total spending from recorded expenses',
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
    );
  }

  Widget _categoryCard(BuildContext context) {
    final totals = categoryTotals;
    final visible = totals.entries
        .where((entry) => entry.value > 0)
        .toList();

    if (visible.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Text(
          'Add expenses to generate category insights.',
          style: TextStyle(
            color: Theme.of(context)
                .textTheme
                .bodySmall
                ?.color
                ?.withValues(alpha: 0.60),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: Theme.of(context)
              .dividerColor
              .withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        children: visible.map(
              (entry) {
            final percentage =
            totalSpent == 0.0
                ? 0.0
                : entry.value / totalSpent;

            return Padding(
              padding: const EdgeInsets.only(
                bottom: 18,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color:
                          const Color(0xFF675CF6)
                              .withValues(
                            alpha: 0.10,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _categoryIcon(entry.key),
                          color:
                          const Color(0xFF675CF6),
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _categoryName(entry.key),
                          style: const TextStyle(
                            fontWeight:
                            FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Text(
                        '${(percentage * 100).round()}%',
                        style: const TextStyle(
                          fontWeight:
                          FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '₹${entry.value.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontWeight:
                          FontWeight.w900,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius:
                    BorderRadius.circular(50),
                    child:
                    LinearProgressIndicator(
                      value: percentage,
                      minHeight: 7,
                      backgroundColor:
                      Theme.of(context)
                          .dividerColor
                          .withValues(
                        alpha: 0.10,
                      ),
                      valueColor:
                      const AlwaysStoppedAnimation<
                          Color>(
                        Color(0xFF675CF6),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ).toList(),
      ),
    );
  }

  Widget _insightCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(24),
        ),
        gradient: LinearGradient(
          colors: [
            Color(0xFFEDEBFF),
            Color(0xFFF8EFFF),
          ],
        ),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 25,
            backgroundColor:
            Color(0xFF675CF6),
            child: Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Text(
              'Use these patterns to decide where your next rupee should go.',
              style: TextStyle(
                color: Theme.of(context)
                    .brightness ==
                    Brightness.dark
                    ? Colors.black87
                    : Colors.black87,
                fontSize: 11,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<double> _dailyValues() {
    final values = List<double>.filled(7, 0.0);

    for (final expense in expenses) {
      final day =
          expense.date.weekday - 1;

      if (day >= 0 && day < 7) {
        values[day] += expense.amount;
      }
    }

    final maxValue = values.reduce(
          (a, b) => a > b ? a : b,
    );

    if (maxValue == 0.0) {
      return List<double>.filled(7, 0.08);
    }

    return values.map(
          (value) =>
          (value / maxValue)
              .clamp(0.08, 1.0),
    ).toList();
  }

  String _dayLabel(int index) {
    const days = [
      'M',
      'T',
      'W',
      'T',
      'F',
      'S',
      'S',
    ];

    return days[index];
  }

  String _categoryName(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.food:
        return 'Food';
      case ExpenseCategory.transport:
        return 'Transport';
      case ExpenseCategory.shopping:
        return 'Shopping';
      case ExpenseCategory.bills:
        return 'Bills';
      case ExpenseCategory.health:
        return 'Health';
      case ExpenseCategory.education:
        return 'Education';
      case ExpenseCategory.entertainment:
        return 'Entertainment';
      case ExpenseCategory.other:
        return 'Other';
    }
  }

  IconData _categoryIcon(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.food:
        return Icons.restaurant_rounded;
      case ExpenseCategory.transport:
        return Icons.directions_car_rounded;
      case ExpenseCategory.shopping:
        return Icons.shopping_bag_rounded;
      case ExpenseCategory.bills:
        return Icons.receipt_long_rounded;
      case ExpenseCategory.health:
        return Icons.favorite_rounded;
      case ExpenseCategory.education:
        return Icons.school_rounded;
      case ExpenseCategory.entertainment:
        return Icons.movie_rounded;
      case ExpenseCategory.other:
        return Icons.more_horiz_rounded;
    }
  }
}
