import 'package:flutter/material.dart';
import '../app_state.dart';
import '../models/expense.dart';
import '../utils/app_format.dart';
import '../widgets/expense_card.dart';
import '../widgets/editor_sheets.dart';

class ExpenseScreen extends StatefulWidget {
  final SpendWiseState state;
  const ExpenseScreen({super.key, required this.state});
  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  final TextEditingController _searchController = TextEditingController();
  ExpenseCategory? _category;
  String _period = 'This month';
  String _sort = 'Newest';

  @override
  void dispose() { _searchController.dispose(); super.dispose(); }

  List<Expense> _filtered() {
    final now = DateTime.now();
    var items = widget.state.expenses.where((expense) {
      final query = _searchController.text.trim().toLowerCase();
      final matchesText = query.isEmpty || expense.title.toLowerCase().contains(query) || expense.note.toLowerCase().contains(query) || expense.category.label.toLowerCase().contains(query);
      final matchesCategory = _category == null || expense.category == _category;
      final matchesPeriod = switch (_period) {
        'This month' => isSameMonth(expense.date, now),
        'Last 30 days' => expense.date.isAfter(now.subtract(const Duration(days: 30))) && !expense.date.isAfter(now),
        _ => true,
      };
      return matchesText && matchesCategory && matchesPeriod;
    }).toList();
    switch (_sort) {
      case 'Oldest':
        items.sort((a, b) => a.date.compareTo(b.date));
        break;
      case 'Highest':
        items.sort((a, b) => b.amount.compareTo(a.amount));
        break;
      case 'Lowest':
        items.sort((a, b) => a.amount.compareTo(b.amount));
        break;
      default:
        items.sort((a, b) => b.date.compareTo(a.date));
        break;
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filtered = _filtered();
    final total = filtered.fold(0.0, (sum, expense) => sum + expense.amount);
    return Scaffold(
      appBar: AppBar(title: const Text('Expenses', style: TextStyle(fontWeight: FontWeight.w900)), actions: [IconButton(tooltip: 'Add expense', onPressed: () => showExpenseEditor(context, widget.state), icon: const Icon(Icons.add_circle_outline_rounded)), const SizedBox(width: 6)]),
      floatingActionButton: FloatingActionButton.extended(onPressed: () => showExpenseEditor(context, widget.state), icon: const Icon(Icons.add_rounded), label: const Text('Add expense')),
      body: Column(children: [
        Padding(padding: const EdgeInsets.fromLTRB(18, 2, 18, 14), child: Container(width: double.infinity, padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: widget.state.accentColor.withValues(alpha: 0.09), borderRadius: BorderRadius.circular(23)), child: Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(_period == 'All time' ? 'Total shown' : 'Total · $_period', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)), const SizedBox(height: 5), Text(formatMoney(total, widget.state.currencyCode), style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)), const SizedBox(height: 4), Text('${filtered.length} transaction${filtered.length == 1 ? '' : 's'}', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant))])), Container(width: 46, height: 46, decoration: BoxDecoration(color: widget.state.accentColor.withValues(alpha: 0.13), borderRadius: BorderRadius.circular(15)), child: Icon(Icons.receipt_long_rounded, color: widget.state.accentColor))]))),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 18), child: TextField(controller: _searchController, onChanged: (_) => setState(() {}), decoration: const InputDecoration(hintText: 'Search expenses or notes', prefixIcon: Icon(Icons.search_rounded), suffixIcon: Icon(Icons.tune_rounded))),),
        const SizedBox(height: 11),
        SizedBox(height: 38, child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 18), children: [
          _categoryChip('All', null),
          ...ExpenseCategory.values.map((category) => _categoryChip(category.label, category)),
        ])),
        Padding(padding: const EdgeInsets.fromLTRB(18, 8, 18, 4), child: Row(children: [Text('Transactions', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)), const Spacer(), DropdownButton<String>(value: _period, underline: const SizedBox.shrink(), items: const [DropdownMenuItem(value: 'This month', child: Text('This month')), DropdownMenuItem(value: 'Last 30 days', child: Text('Last 30 days')), DropdownMenuItem(value: 'All time', child: Text('All time'))], onChanged: (value) => setState(() => _period = value ?? 'This month')), const SizedBox(width: 8), PopupMenuButton<String>(tooltip: 'Sort expenses', icon: const Icon(Icons.sort_rounded), onSelected: (value) => setState(() => _sort = value), itemBuilder: (_) => const [PopupMenuItem(value: 'Newest', child: Text('Newest first')), PopupMenuItem(value: 'Oldest', child: Text('Oldest first')), PopupMenuItem(value: 'Highest', child: Text('Highest amount')), PopupMenuItem(value: 'Lowest', child: Text('Lowest amount'))])])),
        Expanded(child: filtered.isEmpty ? _emptyState(context) : ListView.separated(padding: const EdgeInsets.fromLTRB(18, 5, 18, 24), itemCount: filtered.length, separatorBuilder: (_, _) => const SizedBox(height: 8), itemBuilder: (context, index) {
          final expense = filtered[index];
          return Dismissible(
            key: ValueKey(expense.id),
            direction: DismissDirection.endToStart,
            background: Container(alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 22), decoration: BoxDecoration(color: theme.colorScheme.error, borderRadius: BorderRadius.circular(22)), child: const Icon(Icons.delete_outline_rounded, color: Colors.white)),
            confirmDismiss: (_) => confirmDelete(context, title: 'Delete expense?', message: '“${expense.title}” will be removed from your history.'),
            onDismissed: (_) { widget.state.deleteExpense(expense.id); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Expense deleted'))); },
            child: ExpenseCard(expense: expense, currencyCode: widget.state.currencyCode, onTap: () => showExpenseEditor(context, widget.state, existing: expense)),
          );
        })),
      ]),
    );
  }

  Widget _categoryChip(String label, ExpenseCategory? category) => Padding(padding: const EdgeInsets.only(right: 7), child: ChoiceChip(label: Text(label), selected: _category == category, onSelected: (_) => setState(() => _category = category)));

  Widget _emptyState(BuildContext context) {
    final theme = Theme.of(context);
    final hasFilter = _searchController.text.trim().isNotEmpty || _category != null || _period != 'All time';
    return Center(child: Padding(padding: const EdgeInsets.all(28), child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.receipt_long_rounded, size: 54, color: widget.state.accentColor), const SizedBox(height: 14), Text(hasFilter ? 'No matching expenses' : 'Your history starts here', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)), const SizedBox(height: 7), Text(hasFilter ? 'Try changing the search or filters.' : 'Add expenses as they happen to keep your money map accurate.', textAlign: TextAlign.center, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)), if (hasFilter) TextButton(onPressed: () => setState(() { _searchController.clear(); _category = null; _period = 'All time'; }), child: const Text('Clear filters')) else const SizedBox(height: 15), if (!hasFilter) FilledButton.icon(onPressed: () => showExpenseEditor(context, widget.state), icon: const Icon(Icons.add_rounded), label: const Text('Add first expense'))])));
  }
}
