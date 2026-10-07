import 'package:flutter/material.dart';
import '../models/expense.dart';
import 'analytics_screen.dart';

class InsightsScreen extends StatelessWidget {
  final List<Expense> expenses;

  const InsightsScreen({
    super.key,
    required this.expenses,
  });

  double get totalSpent {
    return expenses.fold(
      0.0,
          (sum, expense) => sum + expense.amount,
    );
  }

  double get averageSpent {
    if (expenses.isEmpty) {
      return 0.0;
    }

    return totalSpent / expenses.length;
  }

  Map<ExpenseCategory, double> get categoryTotals {
    final result = <ExpenseCategory, double>{};

    for (final category in ExpenseCategory.values) {
      result[category] = 0.0;
    }

    for (final expense in expenses) {
      result[expense.category] =
          (result[expense.category] ?? 0.0) +
              expense.amount;
    }

    return result;
  }

  ExpenseCategory get topCategory {
    if (expenses.isEmpty) {
      return ExpenseCategory.other;
    }

    return categoryTotals.entries.reduce(
          (a, b) => a.value > b.value ? a : b,
    ).key;
  }

  double get topCategoryAmount {
    return categoryTotals[topCategory] ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final hasExpenses = expenses.isNotEmpty;

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
            if (!hasExpenses)
              _emptyState(context)
            else ...[
              _mainInsightCard(context),
              const SizedBox(height: 22),
              _sectionTitle(
                context,
                'Spending Overview',
              ),
              const SizedBox(height: 12),
              _overviewCard(context),
              const SizedBox(height: 22),
              _sectionTitle(
                context,
                'Category Breakdown',
              ),
              const SizedBox(height: 12),
              _categoryCard(context),
              const SizedBox(height: 22),
              _sectionTitle(
                context,
                'Smart Suggestions',
              ),
              const SizedBox(height: 12),
              _suggestionCard(
                context,
                Icons.savings_rounded,
                'Save before you spend',
                'Try moving a small amount into your savings goal before making discretionary purchases.',
              ),
              const SizedBox(height: 10),
              _suggestionCard(
                context,
                Icons.analytics_rounded,
                'Watch ${_categoryName(topCategory)}',
                'This is currently your largest spending category. A weekly limit could help keep your budget balanced.',
              ),
              const SizedBox(height: 10),
              _suggestionCard(
                context,
                Icons.auto_graph_rounded,
                'Build a spending habit',
                'Keep adding expenses consistently so Spendwise can reveal stronger patterns over time.',
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            AnalyticsScreen(
                              expenses: expenses,
                            ),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.bar_chart_rounded,
                  ),
                  label: const Text(
                    'View Full Analytics',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor:
                    const Color(0xFF675CF6),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(18),
                    ),
                  ),
                ),
              ),
            ],
          ],
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
                'Smart Insights ✨',
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
                'Your spending, translated into useful actions.',
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
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.auto_awesome_rounded,
            color: Color(0xFF675CF6),
          ),
        ),
      ],
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

  Widget _mainInsightCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(30),
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF272353),
            Color(0xFF675CF6),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white
                  .withValues(alpha: 0.12),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Your biggest spending area',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            _categoryName(topCategory),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 27,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            '₹${topCategoryAmount.toStringAsFixed(0)} spent',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white
                  .withValues(alpha: 0.09),
              borderRadius:
              BorderRadius.circular(17),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.lightbulb_rounded,
                  color: Colors.amber,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${_categoryName(topCategory)} is currently taking the biggest share of your spending.',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _overviewCard(BuildContext context) {
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
        children: [
          _statRow(
            context,
            'Total spent',
            '₹${totalSpent.toStringAsFixed(0)}',
          ),
          const SizedBox(height: 16),
          _statRow(
            context,
            'Transactions',
            '${expenses.length}',
          ),
          const SizedBox(height: 16),
          _statRow(
            context,
            'Average transaction',
            '₹${averageSpent.toStringAsFixed(0)}',
          ),
        ],
      ),
    );
  }

  Widget _statRow(
      BuildContext context,
      String title,
      String value,
      ) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.color
                  ?.withValues(alpha: 0.60),
              fontSize: 13,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _categoryCard(BuildContext context) {
    final visible = categoryTotals.entries
        .where((entry) => entry.value > 0)
        .toList();

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
      child: visible.isEmpty
          ? Text(
        'Add expenses to generate category insights.',
        style: TextStyle(
          color: Theme.of(context)
              .textTheme
              .bodySmall
              ?.color
              ?.withValues(alpha: 0.60),
        ),
      )
          : Column(
        children: visible
            .map(
              (entry) {
            final percentage =
            totalSpent == 0.0
                ? 0.0
                : entry.value /
                totalSpent;

            return Padding(
              padding:
              const EdgeInsets.only(
                bottom: 18,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration:
                        BoxDecoration(
                          color: const Color(
                            0xFF675CF6,
                          ).withValues(
                            alpha: 0.10,
                          ),
                          shape:
                          BoxShape.circle,
                        ),
                        child: Icon(
                          _categoryIcon(
                            entry.key,
                          ),
                          color: const Color(
                            0xFF675CF6,
                          ),
                          size: 18,
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Text(
                          _categoryName(
                            entry.key,
                          ),
                          style:
                          const TextStyle(
                            fontWeight:
                            FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Text(
                        '${(percentage * 100).round()}%',
                        style:
                        const TextStyle(
                          fontWeight:
                          FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        '₹${entry.value.toStringAsFixed(0)}',
                        style:
                        const TextStyle(
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
                    BorderRadius.circular(
                      50,
                    ),
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
        )
            .toList(),
      ),
    );
  }

  Widget _suggestionCard(
      BuildContext context,
      IconData icon,
      String title,
      String description,
      ) {
    return Container(
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF675CF6)
                  .withValues(alpha: 0.10),
              borderRadius:
              BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF675CF6),
              size: 21,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  description,
                  style: TextStyle(
                    color: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.color
                        ?.withValues(alpha: 0.60),
                    fontSize: 11,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    return SizedBox(
      height: 500,
      child: Center(
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF675CF6)
                    .withValues(alpha: 0.09),
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: Color(0xFF675CF6),
                size: 40,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Insights need a little data',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              'Add a few expenses and Spendwise will start finding patterns in your spending.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.color
                    ?.withValues(alpha: 0.60),
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
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

