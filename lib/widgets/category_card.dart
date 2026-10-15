import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../utils/app_format.dart';

class CategoryCard extends StatelessWidget {
  final ExpenseCategory category;
  final double amount;
  final String currencyCode;
  final VoidCallback? onTap;

  const CategoryCard({
    super.key,
    required this.category,
    required this.amount,
    required this.currencyCode,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 136,
      child: Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(backgroundColor: category.color.withValues(alpha: 0.13), foregroundColor: category.color, child: Icon(category.icon)),
                const Spacer(),
                Text(category.label, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 3),
                FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Text(formatMoney(amount, currencyCode), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
