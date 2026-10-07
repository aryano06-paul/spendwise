import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../models/goal.dart';
import '../models/todo.dart';
import '../widgets/category_card.dart';
import '../widgets/dashboard_metric_card.dart';
import '../widgets/expense_card.dart';
import '../widgets/goal_card.dart';
import '../widgets/todo_card.dart';

class DashboardScreen extends StatelessWidget {
  final List<Expense> expenses;
  final List<Todo> todos;
  final double monthlyBudget;
  final VoidCallback? onOpenGoals;
  final VoidCallback? onOpenAppearance;
  final VoidCallback? onOpenAnalytics;

  const DashboardScreen({
    super.key,
    required this.expenses,
    required this.todos,
    this.monthlyBudget = 25000.0,
    this.onOpenGoals,
    this.onOpenAppearance,
    this.onOpenAnalytics,
  });

  double get totalSpent {
    return expenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  double get remainingBudget {
    final value = monthlyBudget - totalSpent;
    return value < 0 ? 0.0 : value;
  }

  double get budgetProgress {
    if (monthlyBudget <= 0) {
      return 0.0;
    }

    return (totalSpent / monthlyBudget).clamp(0.0, 1.0);
  }

  int get completedTodos {
    return todos.where((todo) => todo.completed).length;
  }

  double _categoryTotal(ExpenseCategory category) {
    return expenses
        .where((expense) => expense.category == category)
        .fold(0.0, (sum, expense) => sum + expense.amount);
  }

  String _money(double value) {
    return '₹${value.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final recentExpenses = expenses.take(3).toList();
    final pendingTodos = todos.where((todo) => !todo.completed).take(3).toList();

    final goals = const [
      Goal(
        title: 'New Laptop',
        subtitle: 'Save for your next laptop',
        target: 25000,
        saved: 12000,
        icon: Icons.laptop_mac_rounded,
      ),
      Goal(
        title: 'Germany Trip',
        subtitle: 'Travel fund',
        target: 100000,
        saved: 30000,
        icon: Icons.flight_takeoff_rounded,
      ),
      Goal(
        title: 'Emergency Fund',
        subtitle: 'Build a safety net',
        target: 250000,
        saved: 50000,
        icon: Icons.shield_rounded,
      ),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Good Morning,',
                    style: TextStyle(
                      color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.65),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Aryan 👋',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            if (onOpenAppearance != null)
              IconButton(
                onPressed: onOpenAppearance,
                icon: const Icon(Icons.tune_rounded),
                tooltip: 'Appearance',
              ),
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF675CF6),
                    Color(0xFF9A94FF),
                  ],
                ),
              ),
              alignment: Alignment.center,
              child: const Text(
                'A',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: const LinearGradient(
              colors: [
                Color(0xFF282452),
                Color(0xFF675CF6),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Total Spent',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _money(totalSpent),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'of ${_money(monthlyBudget)} monthly budget',
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 18),
              ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: LinearProgressIndicator(
                  value: budgetProgress,
                  minHeight: 9,
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${(budgetProgress * 100).round()}% of monthly budget used',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        Row(
          children: [
            Expanded(
              child: DashboardMetricCard(
                title: 'Remaining',
                value: _money(remainingBudget),
                icon: Icons.arrow_downward_rounded,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DashboardMetricCard(
                title: 'Tasks Done',
                value: '$completedTodos/${todos.length}',
                icon: Icons.task_alt_rounded,
                color: const Color(0xFF675CF6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),

        _sectionHeader(
          context,
          title: 'Category Breakdown',
          action: 'Analytics',
          onTap: onOpenAnalytics,
        ),
        const SizedBox(height: 13),
        Row(
          children: [
            Expanded(
              child: CategoryCard(
                icon: Icons.restaurant_rounded,
                title: 'Food',
                amount: _money(_categoryTotal(ExpenseCategory.food)),
                color: Colors.teal,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: CategoryCard(
                icon: Icons.directions_car_rounded,
                title: 'Transport',
                amount: _money(_categoryTotal(ExpenseCategory.transport)),
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: CategoryCard(
                icon: Icons.shopping_bag_rounded,
                title: 'Shopping',
                amount: _money(_categoryTotal(ExpenseCategory.shopping)),
                color: Colors.purple,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: CategoryCard(
                icon: Icons.receipt_long_rounded,
                title: 'Bills',
                amount: _money(_categoryTotal(ExpenseCategory.bills)),
                color: Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),

        _sectionHeader(
          context,
          title: 'Recent Expenses',
          action: 'View All',
          onTap: onOpenAnalytics,
        ),
        const SizedBox(height: 13),
        if (recentExpenses.isEmpty)
          _emptyCard(
            context,
            icon: Icons.receipt_long_rounded,
            title: 'No expenses yet',
            subtitle: 'Your recent transactions will appear here.',
          )
        else
          ...recentExpenses.map(
                (expense) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ExpenseCard(expense: expense),
            ),
          ),
        const SizedBox(height: 18),

        _sectionHeader(
          context,
          title: 'Your Goals',
          action: 'See All',
          onTap: onOpenGoals,
        ),
        const SizedBox(height: 13),
        GoalCard(
          goal: goals.first,
          onTap: onOpenGoals,
        ),
        const SizedBox(height: 10),
        GoalCard(
          goal: goals[1],
          onTap: onOpenGoals,
        ),
        const SizedBox(height: 28),

        _sectionHeader(
          context,
          title: 'Pending Tasks',
          action: 'Todo',
          onTap: null,
        ),
        const SizedBox(height: 13),
        if (pendingTodos.isEmpty)
          _emptyCard(
            context,
            icon: Icons.check_circle_outline_rounded,
            title: 'All caught up',
            subtitle: 'You have no pending tasks right now.',
          )
        else
          ...pendingTodos.map(
                (todo) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: TodoCard(todo: todo),
            ),
          ),

        const SizedBox(height: 10),
        GestureDetector(
          onTap: onOpenAnalytics,
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFEDEBFF),
                  Color(0xFFF8EFFF),
                ],
              ),
            ),
            child: const Row(
              children: [
                CircleAvatar(
                  radius: 27,
                  backgroundColor: Color(0xFF675CF6),
                  child: Icon(
                    Icons.auto_awesome_rounded,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Smart Insight',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Discover patterns in your spending and build better habits.',
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _sectionHeader(
      BuildContext context, {
        required String title,
        required String action,
        VoidCallback? onTap,
      }) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        if (onTap != null)
          GestureDetector(
            onTap: onTap,
            child: Text(
              action,
              style: const TextStyle(
                color: Color(0xFF675CF6),
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
      ],
    );
  }

  Widget _emptyCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
      }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.06),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF675CF6).withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.info_outline_rounded,
              color: Color(0xFF675CF6),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.60),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
