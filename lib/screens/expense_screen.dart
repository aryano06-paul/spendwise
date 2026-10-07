import 'package:flutter/material.dart';
import '../models/expense.dart';

class ExpenseScreen extends StatefulWidget {
  final List<Expense> expenses;
  final void Function(Expense) onAddExpense;
  final void Function(Expense) onDeleteExpense;

  const ExpenseScreen({
    super.key,
    required this.expenses,
    required this.onAddExpense,
    required this.onDeleteExpense,
  });

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  final TextEditingController _titleController =
  TextEditingController();

  final TextEditingController _amountController =
  TextEditingController();

  ExpenseCategory _selectedCategory =
      ExpenseCategory.food;

  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  double get totalSpent {
    return widget.expenses.fold(
      0.0,
          (sum, expense) => sum + expense.amount,
    );
  }

  void _addExpense() {
    final title = _titleController.text.trim();
    final amount =
    double.tryParse(_amountController.text.trim());

    if (title.isEmpty || amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter a title and a valid amount.',
          ),
        ),
      );
      return;
    }

    final expense = Expense(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
      amount: amount,
      category: _selectedCategory,
      date: _selectedDate,
    );

    widget.onAddExpense(expense);

    _titleController.clear();
    _amountController.clear();

    setState(() {
      _selectedCategory = ExpenseCategory.food;
      _selectedDate = DateTime.now();
    });

    Navigator.of(context).pop();
  }

  void _openAddExpenseSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _AddExpenseSheet(
          titleController: _titleController,
          amountController: _amountController,
          selectedCategory: _selectedCategory,
          selectedDate: _selectedDate,
          onCategoryChanged: (category) {
            setState(() {
              _selectedCategory = category;
            });
          },
          onDateChanged: (date) {
            setState(() {
              _selectedDate = date;
            });
          },
          onSave: _addExpense,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    final secondaryText =
    isDark ? Colors.white70 : Colors.black54;

    return Scaffold(
      backgroundColor:
      Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                20,
                22,
                20,
                10,
              ),
              sliver: SliverToBoxAdapter(
                child: _header(context, secondaryText),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              sliver: SliverToBoxAdapter(
                child: _summaryCard(context),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                20,
                28,
                20,
                12,
              ),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'All transactions',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Text(
                      '${widget.expenses.length}',
                      style: const TextStyle(
                        color: Color(0xFF675CF6),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (widget.expenses.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _emptyState(context),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  0,
                  20,
                  120,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final expense =
                      widget.expenses[index];

                      return Padding(
                        padding:
                        const EdgeInsets.only(
                          bottom: 10,
                        ),
                        child: _expenseCard(
                          context,
                          expense,
                        ),
                      );
                    },
                    childCount:
                    widget.expenses.length,
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddExpenseSheet,
        backgroundColor: const Color(0xFF675CF6),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Add Expense',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Widget _header(
      BuildContext context,
      Color secondaryText,
      ) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                'My Expenses',
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
                'Every rupee, organised.',
                style: TextStyle(
                  color: secondaryText,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.tune_rounded,
            size: 21,
          ),
        ),
      ],
    );
  }

  Widget _summaryCard(BuildContext context) {
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
            Color(0xFF24204F),
            Color(0xFF675CF6),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          const Text(
            'This month',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            '₹${totalSpent.toStringAsFixed(0)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Total spending',
            style: TextStyle(
              color: Colors.white60,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _summaryPill(
                Icons.receipt_long_rounded,
                '${widget.expenses.length} transactions',
              ),
              const SizedBox(width: 8),
              _summaryPill(
                Icons.auto_graph_rounded,
                'Live total',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryPill(
      IconData icon,
      String text,
      ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: Colors.white70,
          ),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _expenseCard(
      BuildContext context,
      Expense expense,
      ) {
    final color = _categoryColor(expense.category);

    return Dismissible(
      key: ValueKey(expense.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        widget.onDeleteExpense(expense);
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(
          right: 22,
        ),
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(21),
        ),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: Colors.white,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(15),
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
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color:
                color.withValues(alpha: 0.11),
                borderRadius:
                BorderRadius.circular(15),
              ),
              child: Icon(
                _categoryIcon(expense.category),
                color: color,
                size: 22,
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
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
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(35),
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
                Icons.account_balance_wallet_rounded,
                color: Color(0xFF675CF6),
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Nothing here yet',
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
              'Add your first expense and start building your money story.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.color
                    ?.withValues(alpha: 0.60),
                height: 1.5,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 22),
            FilledButton.icon(
              onPressed: _openAddExpenseSheet,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add first expense'),
              style: FilledButton.styleFrom(
                backgroundColor:
                const Color(0xFF675CF6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _categoryColor(
      ExpenseCategory category,
      ) {
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

  IconData _categoryIcon(
      ExpenseCategory category,
      ) {
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

  String _categoryName(
      ExpenseCategory category,
      ) {
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
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];

    return '${date.day} ${months[date.month - 1]}';
  }
}

class _AddExpenseSheet extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController amountController;
  final ExpenseCategory selectedCategory;
  final DateTime selectedDate;
  final ValueChanged<ExpenseCategory> onCategoryChanged;
  final ValueChanged<DateTime> onDateChanged;
  final VoidCallback onSave;

  const _AddExpenseSheet({
    required this.titleController,
    required this.amountController,
    required this.selectedCategory,
    required this.selectedDate,
    required this.onCategoryChanged,
    required this.onDateChanged,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final bottom =
        MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.fromLTRB(
          20,
          12,
          20,
          20 + bottom,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(30),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .dividerColor
                        .withValues(alpha: 0.20),
                    borderRadius:
                    BorderRadius.circular(30),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Add Expense',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'e.g. Lunch at Zomato',
                  prefixIcon:
                  Icon(Icons.storefront_rounded),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountController,
                keyboardType:
                const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixText: '₹ ',
                  prefixIcon:
                  Icon(Icons.payments_rounded),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Category',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                ExpenseCategory.values.map(
                      (category) {
                    return ChoiceChip(
                      label: Text(
                        _categoryText(category),
                      ),
                      selected:
                      selectedCategory ==
                          category,
                      onSelected: (_) =>
                          onCategoryChanged(
                            category,
                          ),
                    );
                  },
                ).toList(),
              ),
              const SizedBox(height: 18),
              InkWell(
                onTap: () async {
                  final picked =
                  await showDatePicker(
                    context: context,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2035),
                    initialDate: selectedDate,
                  );

                  if (picked != null) {
                    onDateChanged(picked);
                  }
                },
                borderRadius:
                BorderRadius.circular(18),
                child: Ink(
                  padding:
                  const EdgeInsets.all(17),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius:
                    BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_month_rounded,
                        color:
                        Color(0xFF675CF6),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Date',
                          style: TextStyle(
                            fontWeight:
                            FontWeight.w700,
                          ),
                        ),
                      ),
                      Text(
                        _formatFullDate(selectedDate),
                        style: const TextStyle(
                          fontWeight:
                          FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: FilledButton(
                  onPressed: onSave,
                  style:
                  FilledButton.styleFrom(
                    backgroundColor:
                    const Color(0xFF675CF6),
                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    'Save Expense',
                    style: TextStyle(
                      fontWeight:
                      FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _categoryText(ExpenseCategory category) {
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

  String _formatFullDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
