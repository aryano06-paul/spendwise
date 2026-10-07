import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../models/todo.dart';
import 'analytics_screen.dart';
import 'appearance_screen.dart';
import 'expense_screen.dart';
import 'goals_screen.dart';
import 'insights_screen.dart';
import 'todo_screen.dart';

class HomeScreen extends StatefulWidget {
  final ThemeMode currentTheme;
  final void Function(ThemeMode) onThemeChanged;

  const HomeScreen({
    super.key,
    required this.currentTheme,
    required this.onThemeChanged,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;

  final double monthlyBudget = 25000.0;

  final List<Expense> expenses = [];

  final List<Todo> todos = [
    Todo(
      id: '1',
      title: 'Complete CN assignment',
      date: DateTime(2026, 10, 4, 14, 0),
      priority: TodoPriority.medium,
    ),
    Todo(
      id: '2',
      title: 'Go to gym',
      date: DateTime(2026, 10, 4, 18, 0),
      priority: TodoPriority.low,
    ),
    Todo(
      id: '3',
      title: 'Study German A1',
      date: DateTime(2026, 10, 4, 20, 0),
      priority: TodoPriority.high,
    ),
  ];

  double get totalSpent {
    return expenses.fold(
      0.0,
          (sum, expense) => sum + expense.amount,
    );
  }

  double get remainingBudget {
    final value = monthlyBudget - totalSpent;
    return value < 0 ? 0.0 : value;
  }

  double get budgetProgress {
    if (monthlyBudget == 0) {
      return 0.0;
    }

    return (totalSpent / monthlyBudget).clamp(0.0, 1.0);
  }

  void _addExpense(Expense expense) {
    setState(() {
      expenses.insert(0, expense);
    });
  }

  void _deleteExpense(String id) {
    setState(() {
      expenses.removeWhere(
            (expense) => expense.id == id,
      );
    });
  }

  void _addTodo(Todo todo) {
    setState(() {
      todos.add(todo);
    });
  }

  void _deleteTodo(String id) {
    setState(() {
      todos.removeWhere(
            (todo) => todo.id == id,
      );
    });
  }

  void _openGoals() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const GoalsScreen(),
      ),
    );
  }

  void _openAppearance() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AppearanceScreen(
          currentTheme: widget.currentTheme,
          onThemeChanged: widget.onThemeChanged,
        ),
      ),
    );
  }

  void _openAnalytics() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AnalyticsScreen(
          expenses: expenses,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _dashboard(),
      ExpenseScreen(
        expenses: expenses,
        onAddExpense: _addExpense,
        onDeleteExpense: (expense) {
          _deleteExpense(expense.id);
        },
      ),
      TodoScreen(
        todos: todos,
        onAddTodo: _addTodo,
        onDeleteTodo: _deleteTodo,
      ),
      InsightsScreen(
        expenses: expenses,
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: selectedIndex,
          children: pages,
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildBottomNavigation() {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return BottomAppBar(
      height: 76,
      color: Theme.of(context).cardColor,
      elevation: 10,
      child: Row(
        children: [
          _navItem(
            icon: Icons.home_rounded,
            label: 'Home',
            index: 0,
            inactiveColor:
            isDark ? Colors.white54 : Colors.black38,
          ),
          _navItem(
            icon: Icons.account_balance_wallet_rounded,
            label: 'Expenses',
            index: 1,
            inactiveColor:
            isDark ? Colors.white54 : Colors.black38,
          ),
          _navItem(
            icon: Icons.checklist_rounded,
            label: 'Todo',
            index: 2,
            inactiveColor:
            isDark ? Colors.white54 : Colors.black38,
          ),
          _navItem(
            icon: Icons.auto_awesome_rounded,
            label: 'Insights',
            index: 3,
            inactiveColor:
            isDark ? Colors.white54 : Colors.black38,
          ),
        ],
      ),
    );
  }

  Widget _navItem({
    required IconData icon,
    required String label,
    required int index,
    required Color inactiveColor,
  }) {
    final selected = selectedIndex == index;
    const activeColor = Color(0xFF675CF6);

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedIndex = index;
          });
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 23,
              color:
              selected ? activeColor : inactiveColor,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: selected
                    ? FontWeight.w800
                    : FontWeight.w500,
                color:
                selected ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dashboard() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        20,
        20,
        20,
        35,
      ),
      children: [
        _header(),
        const SizedBox(height: 25),
        _totalSpentCard(),
        const SizedBox(height: 18),
        _budgetMetrics(),
        const SizedBox(height: 28),
        _sectionHeader(
          title: 'Category Breakdown',
          action: 'Analytics',
          onTap: _openAnalytics,
        ),
        const SizedBox(height: 13),
        _categoryRow(),
        const SizedBox(height: 28),
        _sectionHeader(
          title: 'Recent Expenses',
          action: 'View all',
          onTap: () {
            setState(() {
              selectedIndex = 1;
            });
          },
        ),
        const SizedBox(height: 13),
        _recentExpenses(),
        const SizedBox(height: 20),
        _goalsPreview(),
        const SizedBox(height: 20),
        _smartInsightCard(),
      ],
    );
  }

  Widget _header() {
    final cardColor = Theme.of(context).cardColor;
    final secondaryText =
    Theme.of(context).brightness == Brightness.dark
        ? Colors.white70
        : Colors.black54;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good Morning,',
                style: TextStyle(
                  fontSize: 14,
                  color: secondaryText,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Aryan 👋',
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: _openAppearance,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: cardColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.palette_outlined,
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          width: 45,
          height: 45,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                Color(0xFF675CF6),
                Color(0xFF8C84FF),
              ],
            ),
          ),
          alignment: Alignment.center,
          child: const Text(
            'A',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _totalSpentCard() {
    return Container(
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
            '₹${totalSpent.toStringAsFixed(0)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'This month',
            style: TextStyle(
              color: Colors.white60,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: LinearProgressIndicator(
              value: budgetProgress,
              minHeight: 9,
              backgroundColor: Colors.white24,
              valueColor:
              const AlwaysStoppedAnimation<Color>(
                Colors.white,
              ),
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
    );
  }

  Widget _budgetMetrics() {
    return Row(
      children: [
        Expanded(
          child: _metricCard(
            title: 'Remaining',
            value:
            '₹${remainingBudget.toStringAsFixed(0)}',
            icon: Icons.arrow_downward_rounded,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _metricCard(
            title: 'Budget',
            value:
            '₹${monthlyBudget.toStringAsFixed(0)}',
            icon: Icons.track_changes_rounded,
            color: const Color(0xFF675CF6),
          ),
        ),
      ],
    );
  }

  Widget _metricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.color
                        ?.withValues(alpha: 0.60),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader({
    required String title,
    required String action,
    required VoidCallback onTap,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
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

  Widget _categoryRow() {
    return Row(
      children: [
        _category(
          icon: Icons.restaurant_rounded,
          title: 'Food',
          amount: _categoryTotal(
            ExpenseCategory.food,
          ),
          color: Colors.teal,
        ),
        const SizedBox(width: 10),
        _category(
          icon: Icons.directions_car_rounded,
          title: 'Transport',
          amount: _categoryTotal(
            ExpenseCategory.transport,
          ),
          color: Colors.blue,
        ),
        const SizedBox(width: 10),
        _category(
          icon: Icons.shopping_bag_rounded,
          title: 'Shopping',
          amount: _categoryTotal(
            ExpenseCategory.shopping,
          ),
          color: Colors.purple,
        ),
        const SizedBox(width: 10),
        _category(
          icon: Icons.receipt_long_rounded,
          title: 'Bills',
          amount: _categoryTotal(
            ExpenseCategory.bills,
          ),
          color: Colors.orange,
        ),
      ],
    );
  }

  Widget _category({
    required IconData icon,
    required String title,
    required double amount,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 5,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor:
              color.withValues(alpha: 0.10),
              child: Icon(
                icon,
                color: color,
                size: 19,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '₹${amount.toStringAsFixed(0)}',
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
        ),
      ),
    );
  }

  Widget _recentExpenses() {
    if (expenses.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF675CF6)
                    .withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.receipt_long_rounded,
                color: Color(0xFF675CF6),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Your recent expenses will appear here.',
                style: TextStyle(
                  color: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.color,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: expenses
          .take(3)
          .map(
            (expense) => Padding(
          padding: const EdgeInsets.only(
            bottom: 10,
          ),
          child: _expensePreview(expense),
        ),
      )
          .toList(),
    );
  }

  Widget _expensePreview(Expense expense) {
    final color =
    _categoryColor(expense.category);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color:
              color.withValues(alpha: 0.10),
              borderRadius:
              BorderRadius.circular(14),
            ),
            child: Icon(
              _categoryIcon(expense.category),
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  expense.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${_categoryName(expense.category)} • ${_formatDate(expense.date)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.color
                        ?.withValues(alpha: 0.60),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '- ₹${expense.amount.toStringAsFixed(0)}',
            style: const TextStyle(
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _goalsPreview() {
    return Column(
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Your Goals',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            GestureDetector(
              onTap: _openGoals,
              child: const Text(
                'Manage',
                style: TextStyle(
                  color: Color(0xFF675CF6),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _openGoals,
          child: Container(
            padding: const EdgeInsets.all(17),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius:
              BorderRadius.circular(22),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 25,
                  backgroundColor: Color(0xFFEDEBFF),
                  child: Icon(
                    Icons.laptop_mac_rounded,
                    color: Color(0xFF675CF6),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'New Laptop',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹12,000 of ₹25,000 saved',
                        style: TextStyle(
                          color: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.color
                              ?.withValues(alpha: 0.60),
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const ClipRRect(
                        borderRadius:
                        BorderRadius.all(
                          Radius.circular(20),
                        ),
                        child: LinearProgressIndicator(
                          value: 0.48,
                          minHeight: 7,
                          backgroundColor:
                          Color(0xFFE9E8F1),
                          valueColor:
                          AlwaysStoppedAnimation<
                              Color>(
                            Color(0xFF2EC7D1),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 15,
                  color: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.color,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _smartInsightCard() {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = 3;
        });
      },
      child: Container(
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
                crossAxisAlignment:
                CrossAxisAlignment.start,
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
    );
  }

  double _categoryTotal(ExpenseCategory category) {
    return expenses
        .where(
          (expense) => expense.category == category,
    )
        .fold(
      0.0,
          (sum, expense) => sum + expense.amount,
    );
  }

  Color _categoryColor(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.food:
        return const Color(0xFF13BFA3);
      case ExpenseCategory.transport:
        return const Color(0xFF5B8DEF);
      case ExpenseCategory.shopping:
        return const Color(0xFFA16AF4);
      case ExpenseCategory.bills:
        return const Color(0xFFFFA83D);
      case ExpenseCategory.health:
        return const Color(0xFFFF6482);
      case ExpenseCategory.education:
        return const Color(0xFF42A5D5);
      case ExpenseCategory.entertainment:
        return const Color(0xFFED8C57);
      case ExpenseCategory.other:
        return const Color(0xFF6C6FF1);
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

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${date.day} ${months[date.month - 1]}';
  }
}