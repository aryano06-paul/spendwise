import 'package:flutter/material.dart';
import '../app_state.dart';
import '../models/expense.dart';
import '../utils/app_format.dart';
import '../widgets/category_card.dart';
import '../widgets/dashboard_metric_card.dart';
import '../widgets/expense_card.dart';
import '../widgets/goal_card.dart';
import '../widgets/todo_card.dart';
import '../widgets/editor_sheets.dart';
import 'appearance_screen.dart';
import 'goals_screen.dart';

class DashboardScreen extends StatelessWidget {
  final SpendWiseState state;
  final ValueChanged<int> onNavigate;

  const DashboardScreen({super.key, required this.state, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final monthExpenses = state.expenses.where((e) => isSameMonth(e.date, now)).toList();
    final categoryTotals = <ExpenseCategory, double>{};
    for (final category in ExpenseCategory.values) {
      categoryTotals[category] = monthExpenses.where((e) => e.category == category).fold(0.0, (sum, e) => sum + e.amount);
    }
    final categories = ExpenseCategory.values.where((category) => (categoryTotals[category] ?? 0) > 0).toList()
      ..sort((a, b) => (categoryTotals[b] ?? 0).compareTo(categoryTotals[a] ?? 0));
    final recent = [...state.expenses]..sort((a, b) => b.date.compareTo(a.date));
    final pending = state.todos.where((t) => !t.completed).toList()
      ..sort((a, b) {
        if (a.dueDate == null && b.dueDate == null) return a.createdAt.compareTo(b.createdAt);
        if (a.dueDate == null) return 1;
        if (b.dueDate == null) return -1;
        return a.dueDate!.compareTo(b.dueDate!);
      });
    final firstGoal = state.goals.isEmpty ? null : state.goals.first;
    final topCategory = categories.isEmpty ? null : categories.first;
    final progress = state.budgetProgress;
    final mainTitle = state.totalSpentThisMonth > state.monthlyBudget ? 'Budget exceeded' : 'You’re in control';
    final mainSubtitle = state.monthlyBudget <= 0 ? 'Set your monthly budget to get started.' : state.remainingBudget >= 0 ? '${formatMoney(state.remainingBudget, state.currencyCode)} left to spend this month' : '${formatMoney(state.remainingBudget.abs(), state.currencyCode)} over your monthly budget';

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(greetingForNow(), style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                const SizedBox(height: 3),
                Text('Your money, in motion.', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -0.7)),
              ])),
              IconButton.filledTonal(tooltip: 'Goals', onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => GoalsScreen(state: state))), icon: const Icon(Icons.flag_rounded)),
              const SizedBox(width: 5),
              IconButton.filledTonal(tooltip: 'Appearance and settings', onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AppearanceScreen(state: state))), icon: const Icon(Icons.tune_rounded)),
            ]),
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [state.accentColor, Color.lerp(state.accentColor, const Color(0xFF17172D), 0.75)!]),
                boxShadow: [BoxShadow(color: state.accentColor.withValues(alpha: 0.20), blurRadius: 28, offset: const Offset(0, 14))],
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [Expanded(child: Text('MONEY PULSE · ${formatMonth(now).toUpperCase()}', style: theme.textTheme.labelMedium?.copyWith(color: Colors.white.withValues(alpha: 0.77), letterSpacing: 1.2, fontWeight: FontWeight.w800))), const Icon(Icons.waves_rounded, color: Colors.white70)]),
                const SizedBox(height: 17),
                Text(formatMoney(state.totalSpentThisMonth, state.currencyCode), style: theme.textTheme.headlineLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: -1.4)),
                const SizedBox(height: 3),
                Text('spent this month', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white.withValues(alpha: 0.75))),
                const SizedBox(height: 23),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Monthly budget', style: theme.textTheme.bodySmall?.copyWith(color: Colors.white.withValues(alpha: 0.82))), Text('${(progress * 100).round()}%', style: theme.textTheme.bodySmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w900))]),
                const SizedBox(height: 9),
                ClipRRect(borderRadius: BorderRadius.circular(30), child: LinearProgressIndicator(value: progress, minHeight: 10, backgroundColor: Colors.white.withValues(alpha: 0.19), valueColor: const AlwaysStoppedAnimation<Color>(Colors.white))),
                const SizedBox(height: 11),
                Row(children: [const Icon(Icons.insights_rounded, color: Colors.white70, size: 17), const SizedBox(width: 7), Expanded(child: Text(mainSubtitle, style: theme.textTheme.bodySmall?.copyWith(color: Colors.white.withValues(alpha: 0.88))))]),
              ]),
            ),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(child: DashboardMetricCard(title: 'Remaining', value: formatMoney(state.remainingBudget, state.currencyCode), caption: 'This month', icon: Icons.south_west_rounded, color: state.remainingBudget >= 0 ? const Color(0xFF209A78) : theme.colorScheme.error)),
              const SizedBox(width: 12),
              Expanded(child: DashboardMetricCard(title: 'Tasks left', value: '${state.pendingTodoCount}', caption: '${state.completedTodoCount} completed', icon: Icons.check_circle_outline_rounded, color: state.accentColor)),
            ]),
            const SizedBox(height: 23),
            _SectionHeading(title: 'Quick actions', action: 'See all', onTap: () => onNavigate(1)),
            const SizedBox(height: 11),
            Row(children: [
              Expanded(child: _QuickAction(icon: Icons.add_card_rounded, label: 'Add expense', color: state.accentColor, onTap: () => showExpenseEditor(context, state))),
              const SizedBox(width: 10),
              Expanded(child: _QuickAction(icon: Icons.add_task_rounded, label: 'New task', color: const Color(0xFF209A78), onTap: () => showTodoEditor(context, state))),
              const SizedBox(width: 10),
              Expanded(child: _QuickAction(icon: Icons.savings_rounded, label: 'Goal', color: const Color(0xFFE7A03A), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => GoalsScreen(state: state))))),
            ]),
            const SizedBox(height: 25),
            _SectionHeading(title: 'Spending map', action: 'All expenses', onTap: () => onNavigate(1)),
            const SizedBox(height: 5),
            Text('Where your money went this month', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 12),
            if (categories.isEmpty)
              _EmptyHint(icon: Icons.pie_chart_outline_rounded, title: 'Your map starts here', message: 'Add an expense and the category breakdown will appear.')
            else
              SizedBox(height: 148, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: categories.length, separatorBuilder: (_, _) => const SizedBox(width: 10), itemBuilder: (context, index) { final category = categories[index]; return CategoryCard(category: category, amount: categoryTotals[category] ?? 0, currencyCode: state.currencyCode, onTap: () => onNavigate(1)); })),
            const SizedBox(height: 25),
            _SectionHeading(title: 'Recent activity', action: 'View all', onTap: () => onNavigate(1)),
            const SizedBox(height: 10),
            if (recent.isEmpty)
              _EmptyHint(icon: Icons.receipt_long_rounded, title: 'Nothing logged yet', message: 'Track your first expense to start seeing patterns.')
            else
              ...recent.take(4).map((expense) => Padding(padding: const EdgeInsets.only(bottom: 8), child: ExpenseCard(expense: expense, currencyCode: state.currencyCode, onTap: () => showExpenseEditor(context, state, existing: expense)))),
            const SizedBox(height: 18),
            _SectionHeading(title: 'Goals in motion', action: state.goals.isEmpty ? 'Create' : 'Manage', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => GoalsScreen(state: state)))),
            const SizedBox(height: 10),
            if (firstGoal == null)
              _EmptyHint(icon: Icons.flag_outlined, title: 'Give your money a mission', message: 'Create a savings goal and track progress as you contribute.')
            else
              GoalCard(goal: firstGoal, currencyCode: state.currencyCode, onContribute: () => showGoalContributionDialog(context, state, firstGoal), onEdit: () => showGoalEditor(context, state, existing: firstGoal), onDelete: () async { if (await confirmDelete(context, title: 'Delete goal?', message: 'This goal and its progress will be removed.')) state.deleteGoal(firstGoal.id); }),
            const SizedBox(height: 18),
            _SectionHeading(title: 'Focus queue', action: 'All tasks', onTap: () => onNavigate(2)),
            const SizedBox(height: 10),
            if (pending.isEmpty)
              _EmptyHint(icon: Icons.task_alt_rounded, title: 'You’re all caught up', message: 'Create a task to make your next money move.')
            else
              ...pending.take(3).map((todo) => Padding(padding: const EdgeInsets.only(bottom: 8), child: TodoCard(todo: todo, onTap: () => onNavigate(2)))),
            const SizedBox(height: 18),
            Card(color: state.accentColor.withValues(alpha: 0.08), child: InkWell(borderRadius: BorderRadius.circular(22), onTap: () => onNavigate(3), child: Padding(padding: const EdgeInsets.all(17), child: Row(children: [Container(width: 44, height: 44, decoration: BoxDecoration(color: state.accentColor.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(14)), child: Icon(Icons.auto_awesome_rounded, color: state.accentColor)), const SizedBox(width: 13), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Your money, decoded', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900)), const SizedBox(height: 3), Text(topCategory == null ? mainTitle : 'Your biggest category is ${topCategory.label}. Tap to explore the details.', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant))])), Icon(Icons.arrow_forward_rounded, color: state.accentColor)])))),
          ],
        ),
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  final String title;
  final String action;
  final VoidCallback onTap;
  const _SectionHeading({required this.title, required this.action, required this.onTap});
  @override
  Widget build(BuildContext context) => Row(children: [Expanded(child: Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -0.4))), TextButton(onPressed: onTap, child: Text(action))]);
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QuickAction({required this.icon, required this.label, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) => Card(child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(20), child: Padding(padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4), child: Column(children: [Container(width: 42, height: 42, decoration: BoxDecoration(color: color.withValues(alpha: 0.13), borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: color)), const SizedBox(height: 9), Text(label, textAlign: TextAlign.center, style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w800))]))));
}

class _EmptyHint extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  const _EmptyHint({required this.icon, required this.title, required this.message});
  @override
  Widget build(BuildContext context) { final theme = Theme.of(context); return Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: theme.dividerColor.withValues(alpha: 0.6))), child: Row(children: [Icon(icon, size: 27, color: theme.colorScheme.primary), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900)), const SizedBox(height: 3), Text(message, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant))]))])); }
}
