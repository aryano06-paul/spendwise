import 'package:flutter/material.dart';

import '../app_state.dart';
import '../utils/app_format.dart';
import '../widgets/editor_sheets.dart';
import '../widgets/goal_card.dart';

class GoalsScreen extends StatelessWidget {
  final SpendWiseState state;
  const GoalsScreen({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalTarget = state.goals.fold<double>(0, (sum, goal) => sum + goal.targetAmount);
    final totalSaved = state.goals.fold<double>(0, (sum, goal) => sum + goal.savedAmount);
    final completed = state.goals.where((goal) => goal.savedAmount >= goal.targetAmount).length;
    final sortedGoals = [...state.goals]..sort((a, b) => b.progress.compareTo(a.progress));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Goals in motion', style: TextStyle(fontWeight: FontWeight.w900)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showGoalEditor(context, state),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New goal'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 5, 18, 95),
        children: [
          Container(
            padding: const EdgeInsets.all(21),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              gradient: LinearGradient(
                colors: [
                  state.accentColor,
                  Color.lerp(state.accentColor, const Color(0xFF17172D), 0.72)!,
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'YOUR SAVINGS SNAPSHOT',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: Colors.white70,
                    letterSpacing: 1.1,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  formatMoney(totalSaved, state.currencyCode),
                  style: theme.textTheme.headlineLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'saved toward ${formatMoney(totalTarget, state.currencyCode)}',
                  style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(child: _GoalMiniStat(label: 'Active goals', value: '${state.goals.length}')),
                    Expanded(child: _GoalMiniStat(label: 'Completed', value: '$completed')),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Your goals',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
              ),
              Text('${state.goals.length} total', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            ],
          ),
          const SizedBox(height: 12),
          if (sortedGoals.isEmpty)
            Container(
              padding: const EdgeInsets.all(26),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(23),
                border: Border.all(color: theme.dividerColor.withValues(alpha: 0.6)),
              ),
              child: Column(
                children: [
                  Icon(Icons.flag_rounded, size: 52, color: state.accentColor),
                  const SizedBox(height: 14),
                  Text('Give your money a mission', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 7),
                  Text(
                    'Create a goal for a trip, a new device, an emergency fund, or anything you are saving for.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () => showGoalEditor(context, state),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Create your first goal'),
                  ),
                ],
              ),
            )
          else
            ...sortedGoals.map(
              (goal) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GoalCard(
                  goal: goal,
                  currencyCode: state.currencyCode,
                  onContribute: () => showGoalContributionDialog(context, state, goal),
                  onEdit: () => showGoalEditor(context, state, existing: goal),
                  onDelete: () async {
                    final confirmed = await confirmDelete(
                      context,
                      title: 'Delete goal?',
                      message: '${goal.title} and its progress will be removed.',
                    );
                    if (confirmed) state.deleteGoal(goal.id);
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _GoalMiniStat extends StatelessWidget {
  final String label;
  final String value;
  const _GoalMiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w900)),
          const SizedBox(height: 2),
          Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70)),
        ],
      );
}
