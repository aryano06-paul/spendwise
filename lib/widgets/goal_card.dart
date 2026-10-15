import 'package:flutter/material.dart';
import '../models/goal.dart';
import '../utils/app_format.dart';

IconData goalIcon(String key) => switch (key) {
      'travel' => Icons.flight_takeoff_rounded,
      'laptop' => Icons.laptop_mac_rounded,
      'home' => Icons.home_work_rounded,
      'education' => Icons.school_rounded,
      'emergency' => Icons.health_and_safety_rounded,
      _ => Icons.savings_rounded,
    };

class GoalCard extends StatelessWidget {
  final Goal goal;
  final String currencyCode;
  final VoidCallback onContribute;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const GoalCard({super.key, required this.goal, required this.currencyCode, required this.onContribute, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.primary;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(17),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(width: 46, height: 46, decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(15)), child: Icon(goalIcon(goal.iconKey), color: color)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(goal.title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)), if (goal.description.isNotEmpty) Text(goal.description, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant))])),
              PopupMenuButton<String>(onSelected: (value) { if (value == 'add') onContribute(); if (value == 'edit') onEdit(); if (value == 'delete') onDelete(); }, itemBuilder: (_) => const [PopupMenuItem(value: 'add', child: Text('Add savings')), PopupMenuItem(value: 'edit', child: Text('Edit goal')), PopupMenuItem(value: 'delete', child: Text('Delete goal'))]),
            ]),
            const SizedBox(height: 18),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(formatMoney(goal.savedAmount, currencyCode), style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)), Text('of ${formatMoney(goal.targetAmount, currencyCode)}', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant))]),
            const SizedBox(height: 9),
            ClipRRect(borderRadius: BorderRadius.circular(20), child: LinearProgressIndicator(value: goal.progress, minHeight: 9, backgroundColor: theme.colorScheme.surfaceContainerHighest)),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('${(goal.progress * 100).round()}% saved', style: theme.textTheme.bodySmall), if (goal.deadline != null) Text('Due ${formatDate(goal.deadline!)}', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant))]),
            const SizedBox(height: 12),
            SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: onContribute, icon: const Icon(Icons.add_rounded), label: const Text('Add to goal'))),
          ],
        ),
      ),
    );
  }
}
