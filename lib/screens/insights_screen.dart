import 'package:flutter/material.dart';

import '../app_state.dart';
import '../models/expense.dart';
import '../utils/app_format.dart';
import '../widgets/dashboard_metric_card.dart';
import 'analytics_screen.dart';
import 'goals_screen.dart';

class InsightsScreen extends StatelessWidget {
  final SpendWiseState state;
  const InsightsScreen({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final currentMonth = state.expenses.where((e) => isSameMonth(e.date, now)).toList();
    final previousMonthDate = DateTime(now.year, now.month - 1);
    final previousMonth = state.expenses.where((e) => isSameMonth(e.date, previousMonthDate)).toList();
    final previousMonthAtSamePoint = previousMonth.where((e) => e.date.day <= now.day).fold<double>(0, (sum, e) => sum + e.amount);
    final delta = previousMonthAtSamePoint == 0 ? 0.0 : ((state.totalSpentThisMonth - previousMonthAtSamePoint) / previousMonthAtSamePoint) * 100;
    final categories = <ExpenseCategory, double>{};
    for (final expense in currentMonth) {
      categories[expense.category] = (categories[expense.category] ?? 0) + expense.amount;
    }
    final sorted = categories.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final largest = [...currentMonth]..sort((a, b) => b.amount.compareTo(a.amount));
    final progress = state.budgetProgress;
    final messages = <_InsightData>[];

    if (currentMonth.isEmpty) {
      messages.add(_InsightData(
        icon: Icons.lightbulb_outline_rounded,
        title: 'Start with one expense',
        description: 'Log a few transactions to unlock spending patterns and useful comparisons.',
        color: state.accentColor,
      ));
    } else {
      if (progress >= 1) {
        messages.add(_InsightData(
          icon: Icons.warning_amber_rounded,
          title: 'You’ve crossed your budget',
          description: 'You have spent ${formatMoney(state.totalSpentThisMonth - state.monthlyBudget, state.currencyCode)} over your monthly plan. Consider pausing non-essential purchases.',
          color: theme.colorScheme.error,
        ));
      } else if (progress >= 0.75) {
        messages.add(_InsightData(
          icon: Icons.speed_rounded,
          title: 'Budget watch',
          description: 'You have used ${(progress * 100).round()}% of your monthly budget. ${formatMoney(state.remainingBudget, state.currencyCode)} remains.',
          color: const Color(0xFFDA9631),
        ));
      } else {
        messages.add(_InsightData(
          icon: Icons.check_circle_outline_rounded,
          title: 'Budget is on track',
          description: 'You have used ${(progress * 100).round()}% of your planned monthly budget.',
          color: const Color(0xFF229878),
        ));
      }
      if (sorted.isNotEmpty) {
        final share = state.totalSpentThisMonth <= 0 ? 0.0 : sorted.first.value / state.totalSpentThisMonth * 100;
        messages.add(_InsightData(
          icon: Icons.donut_large_rounded,
          title: '${sorted.first.key.label} leads spending',
          description: 'This category accounts for ${share.round()}% of your spending so far this month (${formatMoney(sorted.first.value, state.currencyCode)}).',
          color: state.accentColor,
        ));
      }
      if (largest.isNotEmpty) {
        messages.add(_InsightData(
          icon: Icons.receipt_long_rounded,
          title: 'Your largest purchase',
          description: '${largest.first.title} is your biggest logged transaction this month at ${formatMoney(largest.first.amount, state.currencyCode)}.',
          color: const Color(0xFF4D83F5),
        ));
      }
      if (previousMonthAtSamePoint > 0) {
        final isHigher = state.totalSpentThisMonth > previousMonthAtSamePoint;
        messages.add(_InsightData(
          icon: isHigher ? Icons.trending_up_rounded : Icons.trending_down_rounded,
          title: 'Compared with last month',
          description: 'Spending is ${delta.abs().round()}% ${isHigher ? 'higher' : 'lower'} than last month over the first ${now.day} days of last month.',
          color: isHigher ? const Color(0xFFDA9631) : const Color(0xFF229878),
        ));
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart insights', style: TextStyle(fontWeight: FontWeight.w900)),
        actions: [
          IconButton(
            tooltip: 'Full analytics',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AnalyticsScreen(state: state))),
            icon: const Icon(Icons.insights_rounded),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 5, 18, 26),
        children: [
          Container(
            padding: const EdgeInsets.all(21),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [state.accentColor.withValues(alpha: 0.17), theme.colorScheme.surface],
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(color: state.accentColor.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(17)),
                  child: Icon(Icons.auto_awesome_rounded, color: state.accentColor, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Your spending, decoded', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                      const SizedBox(height: 4),
                      Text('Practical observations calculated from your logged data. No bank connection required.', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 17),
          Row(
            children: [
              Expanded(child: DashboardMetricCard(title: 'Spent this month', value: formatMoney(state.totalSpentThisMonth, state.currencyCode), caption: formatMonth(now), icon: Icons.payments_outlined, color: state.accentColor)),
              const SizedBox(width: 12),
              Expanded(child: DashboardMetricCard(title: 'Transactions', value: '${currentMonth.length}', caption: 'This month', icon: Icons.receipt_long_outlined, color: const Color(0xFF4D83F5))),
            ],
          ),
          const SizedBox(height: 23),
          Text('What stands out', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 11),
          ...messages.map((message) => Padding(padding: const EdgeInsets.only(bottom: 10), child: _InsightCard(data: message))),
          const SizedBox(height: 15),
          Text('Small moves, better habits', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 11),
          const _TipCard(icon: Icons.edit_calendar_rounded, title: 'Log it as it happens', subtitle: 'A quick daily log makes category and week-to-week patterns more useful.'),
          const SizedBox(height: 9),
          _TipCard(icon: Icons.flag_outlined, title: 'Give spare money a destination', subtitle: 'A clear goal can make it easier to decide what is worth spending on.', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => GoalsScreen(state: state)))),
          const SizedBox(height: 9),
          _TipCard(icon: Icons.query_stats_rounded, title: 'Look beyond one day', subtitle: 'Use the weekly view to spot patterns instead of overreacting to a single purchase.', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AnalyticsScreen(state: state)))),
          const SizedBox(height: 15),
          SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AnalyticsScreen(state: state))), icon: const Icon(Icons.bar_chart_rounded), label: const Text('View full analytics'))),
        ],
      ),
    );
  }
}

class _InsightData {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  const _InsightData({required this.icon, required this.title, required this.description, required this.color});
}

class _InsightCard extends StatelessWidget {
  final _InsightData data;
  const _InsightCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 43,
              height: 43,
              decoration: BoxDecoration(color: data.color.withValues(alpha: 0.13), borderRadius: BorderRadius.circular(14)),
              child: Icon(data.icon, color: data.color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(data.title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 5),
                  Text(data.description, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  const _TipCard({required this.icon, required this.title, required this.subtitle, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: theme.colorScheme.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text(subtitle),
        trailing: onTap == null ? null : const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}
