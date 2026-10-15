import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../utils/app_format.dart';

class ExpenseCard extends StatelessWidget {
  final Expense expense;
  final String currencyCode;
  final VoidCallback? onTap;

  const ExpenseCard({super.key, required this.expense, required this.currencyCode, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        leading: Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(color: expense.category.color.withValues(alpha: 0.13), borderRadius: BorderRadius.circular(15)),
          child: Icon(expense.category.icon, color: expense.category.color),
        ),
        title: Text(expense.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text('${expense.category.label} · ${formatDate(expense.date)}', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ),
        trailing: Text('-${formatMoney(expense.amount, currencyCode)}', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900)),
      ),
    );
  }
}
