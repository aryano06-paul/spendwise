import 'package:flutter/material.dart';

import '../app_state.dart';
import '../models/expense.dart';
import '../utils/app_format.dart';

class AnalyticsScreen extends StatelessWidget {
  final SpendWiseState state;
  const AnalyticsScreen({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final thisMonth = state.expenses.where((e) => isSameMonth(e.date, now)).toList();
    final lastMonthDate = DateTime(now.year, now.month - 1);
    final lastMonth = state.expenses.where((e) => isSameMonth(e.date, lastMonthDate)).toList();
    final lastMonthTotal = lastMonth.fold<double>(0, (sum, e) => sum + e.amount);
    final lastMonthAtSamePoint = lastMonth.where((e) => e.date.day <= now.day).fold<double>(0, (sum, e) => sum + e.amount);
    final currentTotal = thisMonth.fold<double>(0, (sum, e) => sum + e.amount);
    final day = now.day;
    final difference = currentTotal - lastMonthAtSamePoint;
    final weekStart = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 6));
    final dailyTotals = List<double>.generate(7, (index) {
      final date = weekStart.add(Duration(days: index));
      return state.expenses.where((e) => isSameDay(e.date, date)).fold<double>(0, (sum, e) => sum + e.amount);
    });
    final maxDaily = dailyTotals.fold<double>(0, (max, value) => value > max ? value : max);
    final weekTotal = dailyTotals.fold<double>(0, (sum, amount) => sum + amount);
    final categories = <ExpenseCategory, double>{};
    for (final expense in thisMonth) {
      categories[expense.category] = (categories[expense.category] ?? 0) + expense.amount;
    }
    final categoryEntries = categories.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final averageTransaction = thisMonth.isEmpty ? 0.0 : currentTotal / thisMonth.length;
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final projected = day == 0 ? currentTotal : currentTotal / day * daysInMonth;

    return Scaffold(
      appBar: AppBar(title: const Text('Analytics', style: TextStyle(fontWeight: FontWeight.w900))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 5, 18, 25),
        children: [
          Container(
            padding: const EdgeInsets.all(21),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              gradient: LinearGradient(
                colors: [state.accentColor, Color.lerp(state.accentColor, const Color(0xFF17172D), 0.72)!],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(formatMonth(now).toUpperCase(), style: theme.textTheme.labelMedium?.copyWith(color: Colors.white70, letterSpacing: 1.2, fontWeight: FontWeight.w800)),
                const SizedBox(height: 10),
                Text(formatMoney(currentTotal, state.currencyCode), style: theme.textTheme.headlineLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text('across ${thisMonth.length} transactions', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70)),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: _HeroStat(label: 'Daily average', value: formatMoney(day == 0 ? 0 : currentTotal / day, state.currencyCode))),
                    Expanded(child: _HeroStat(label: 'Month-end pace*', value: formatMoney(projected, state.currencyCode))),
                  ],
                ),
                const SizedBox(height: 9),
                Text('*Projection assumes your daily average remains constant.', style: theme.textTheme.labelSmall?.copyWith(color: Colors.white60)),
              ],
            ),
          ),
          const SizedBox(height: 17),
          Row(
            children: [
              Expanded(child: _SummaryCard(title: 'Budget used', value: '${(state.budgetProgress * 100).round()}%', caption: '${formatMoney(state.remainingBudget, state.currencyCode)} remaining', icon: Icons.track_changes_rounded, color: state.accentColor)),
              const SizedBox(width: 10),
              Expanded(child: _SummaryCard(title: 'Avg. transaction', value: formatMoney(averageTransaction, state.currencyCode), caption: 'This month', icon: Icons.receipt_long_rounded, color: const Color(0xFF209A78))),
            ],
          ),
          const SizedBox(height: 24),
          Text('Last 7 days', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text('Total ${formatMoney(weekTotal, state.currencyCode)}', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(15, 18, 15, 14),
              child: SizedBox(
                height: 185,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(7, (index) {
                    final date = weekStart.add(Duration(days: index));
                    final amount = dailyTotals[index];
                    final ratio = maxDaily <= 0 ? 0.04 : (amount / maxDaily).clamp(0.04, 1.0).toDouble();
                    final selected = isSameDay(date, now);
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Tooltip(
                              message: formatMoney(amount, state.currencyCode),
                              child: Container(
                                height: 108 * ratio,
                                decoration: BoxDecoration(
                                  color: selected ? state.accentColor : state.accentColor.withValues(alpha: amount == 0 ? 0.10 : 0.45),
                                  borderRadius: BorderRadius.circular(9),
                                ),
                              ),
                            ),
                            const SizedBox(height: 9),
                            Text(formatDayLabel(date), style: theme.textTheme.labelSmall?.copyWith(fontWeight: selected ? FontWeight.w900 : FontWeight.w500, color: selected ? state.accentColor : theme.colorScheme.onSurfaceVariant)),
                            const SizedBox(height: 3),
                            Text(date.day.toString(), style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
          const SizedBox(height: 23),
          Text('Category breakdown', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 5),
          Text('Ranked by this month’s spending', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 12),
          if (categoryEntries.isEmpty)
            Card(child: Padding(padding: const EdgeInsets.all(22), child: Center(child: Text('Add expenses to see category analytics.', style: theme.textTheme.bodyMedium))))
          else
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: categoryEntries.map((entry) {
                    final fraction = currentTotal <= 0 ? 0.0 : entry.value / currentTotal;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(width: 35, height: 35, decoration: BoxDecoration(color: entry.key.color.withValues(alpha: 0.13), borderRadius: BorderRadius.circular(11)), child: Icon(entry.key.icon, size: 19, color: entry.key.color)),
                              const SizedBox(width: 10),
                              Expanded(child: Text(entry.key.label, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800))),
                              Text(formatMoney(entry.value, state.currencyCode), style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w900)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(borderRadius: BorderRadius.circular(20), child: LinearProgressIndicator(value: fraction, minHeight: 7, color: entry.key.color, backgroundColor: entry.key.color.withValues(alpha: 0.10))),
                          const SizedBox(height: 3),
                          Align(alignment: Alignment.centerRight, child: Text('${(fraction * 100).round()}% of spending', style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant))),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          const SizedBox(height: 20),
          Text('Month-over-month', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(17),
              child: Row(
                children: [
                  Container(
                    width: 43,
                    height: 43,
                    decoration: BoxDecoration(color: (difference > 0 ? theme.colorScheme.error : const Color(0xFF209A78)).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(14)),
                    child: Icon(difference > 0 ? Icons.trending_up_rounded : Icons.trending_down_rounded, color: difference > 0 ? theme.colorScheme.error : const Color(0xFF209A78)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(difference > 0 ? 'Higher than last month' : 'Lower than last month', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900)),
                        const SizedBox(height: 4),
                        Text(lastMonth.isEmpty ? 'There is not enough previous-month data to compare yet.' : '${formatMoney(difference.abs(), state.currencyCode)} difference against the first $day days of last month.', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 7),
          Text('Last month total: ${formatMoney(lastMonthTotal, state.currencyCode)}', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  final String label;
  final String value;
  const _HeroStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70)),
        ],
      );
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final String caption;
  final IconData icon;
  final Color color;
  const _SummaryCard({required this.title, required this.value, required this.caption, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 12),
            Text(title, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 4),
            FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Text(value, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900))),
            const SizedBox(height: 4),
            Text(caption, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}
