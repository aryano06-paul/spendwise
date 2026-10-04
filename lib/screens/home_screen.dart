import 'package:flutter/material.dart';
import '../models/expense.dart';
import 'expense_screen.dart';

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

  final List<Expense> expenses = [];

  double get totalSpent {
    return expenses.fold(
      0,
          (sum, expense) => sum + expense.amount,
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FC),

      body: SafeArea(
        child: IndexedStack(
          index: selectedIndex,
          children: [
            _dashboard(),
            ExpenseScreen(
              expenses: expenses,
              onAddExpense: _addExpense,
              onDeleteExpense: (expense) => _deleteExpense(expense.id),
            ),
            _todoPage(),
            _insightsPage(),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (selectedIndex == 1) {
            _showAddExpense();
          }
        },
        backgroundColor: const Color(0xFF675CF6),
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),

      floatingActionButtonLocation:
      FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: BottomAppBar(
        height: 75,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(
              Icons.home_rounded,
              'Home',
              0,
            ),
            _navItem(
              Icons.account_balance_wallet_rounded,
              'Expenses',
              1,
            ),
            const SizedBox(width: 50),
            _navItem(
              Icons.checklist_rounded,
              'Todo',
              2,
            ),
            _navItem(
              Icons.auto_awesome_rounded,
              'Insights',
              3,
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
        100,
      ),
      children: [
        Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    'Good Morning,',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Aryan 👋',
                    style: TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),

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
        ),

        const SizedBox(height: 25),

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
            crossAxisAlignment:
            CrossAxisAlignment.start,
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
                '1 – 30 Sep 2026',
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 20),

              ClipRRect(
                borderRadius:
                BorderRadius.circular(50),
                child: const LinearProgressIndicator(
                  value: 0.35,
                  minHeight: 9,
                  backgroundColor:
                  Colors.white24,
                  valueColor:
                  AlwaysStoppedAnimation<Color>(
                    Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                '35% of monthly budget used',
                style: TextStyle(
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
              child: _metricCard(
                'Remaining',
                '₹16,250',
                Icons.arrow_downward_rounded,
                Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _metricCard(
                'Budget',
                '₹25,000',
                Icons.track_changes_rounded,
                const Color(0xFF675CF6),
              ),
            ),
          ],
        ),

        const SizedBox(height: 28),

        const Text(
          'Category Breakdown',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 13),

        Row(
          children: [
            _category(
              Icons.restaurant_rounded,
              'Food',
              '₹1,200',
              Colors.teal,
            ),
            const SizedBox(width: 10),
            _category(
              Icons.directions_car_rounded,
              'Transport',
              '₹850',
              Colors.blue,
            ),
            const SizedBox(width: 10),
            _category(
              Icons.shopping_bag_rounded,
              'Shopping',
              '₹1,100',
              Colors.purple,
            ),
            const SizedBox(width: 10),
            _category(
              Icons.receipt_long_rounded,
              'Bills',
              '₹868',
              Colors.orange,
            ),
          ],
        ),

        const SizedBox(height: 28),

        const Text(
          'Recent Expenses',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 13),

        _expensePreview(
          'Zomato',
          'Food',
          '₹450',
          Icons.restaurant_rounded,
        ),

        _expensePreview(
          'Uber',
          'Transport',
          '₹320',
          Icons.directions_car_rounded,
        ),

        _expensePreview(
          'Amazon',
          'Shopping',
          '₹1,299',
          Icons.shopping_bag_rounded,
        ),

        const SizedBox(height: 20),

        GestureDetector(
          onTap: () {
            setState(() {
              selectedIndex = 3;
            });
          },
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius:
              BorderRadius.circular(24),
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
                  backgroundColor:
                  Color(0xFF675CF6),
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
                          fontWeight:
                          FontWeight.w800,
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

  Widget _metricCard(
      String title,
      String value,
      IconData icon,
      Color color,
      ) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color:Colors.white.withValues(alpha: 0.1),
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
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _category(
      IconData icon,
      String title,
      String amount,
      Color color,
      ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 5,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
          BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor:
              const Color(0xFF675CF6).withValues(alpha: 0.1),
              child: Icon(
                icon,
                color: color,
                size: 19,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              title,
              style: const TextStyle(
                fontSize: 10,
                fontWeight:
                FontWeight.w700,
              ),
              overflow:
              TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              amount,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _expensePreview(
      String title,
      String category,
      String amount,
      IconData icon,
      ) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 10,
      ),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: const Color(
                0xFF675CF6,
              ).withValues(alpha: 0.1),
              borderRadius:
              BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color:
              const Color(0xFF675CF6),
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
                  style: const TextStyle(
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  category,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '- $amount',
            style: const TextStyle(
              fontWeight:
              FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _navItem(
      IconData icon,
      String label,
      int index,
      ) {
    final selected =
        selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
      },
      child: Column(
        mainAxisAlignment:
        MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: selected
                ? const Color(
              0xFF675CF6,
            )
                : Colors.black38,
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: selected
                  ? const Color(
                0xFF675CF6,
              )
                  : Colors.black38,
              fontWeight: selected
                  ? FontWeight.w700
                  : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _todoPage() {
    return const Center(
      child: Text(
        'Todo\nComing next',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _insightsPage() {
    return const Center(
      child: Text(
        '✨ Smart Insights\nComing next',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  void _showAddExpense() {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          'Add Expense screen will be connected next.',
        ),
      ),
    );
  }
}