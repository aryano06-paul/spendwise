import 'package:flutter/material.dart';
import '../models/goal.dart';

class GoalCard extends StatelessWidget {
  final Goal goal;
  final VoidCallback? onTap;

  const GoalCard({
    super.key,
    required this.goal,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (goal.progress * 100).round();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(23),
      child: Container(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(23),
          border: Border.all(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.06),
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF9A94FF),
                        Color(0xFF675CF6),
                      ],
                    ),
                  ),
                  child: Icon(
                    goal.icon,
                    color: Colors.white,
                    size: 23,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        goal.subtitle,
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
                  '$percent%',
                  style: const TextStyle(
                    color: Color(0xFF675CF6),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: LinearProgressIndicator(
                value: goal.progress,
                minHeight: 8,
                backgroundColor: const Color(0xFF675CF6).withValues(alpha: 0.10),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF675CF6),
                ),
              ),
            ),
            const SizedBox(height: 9),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '₹${goal.saved.toStringAsFixed(0)} saved',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '₹${goal.target.toStringAsFixed(0)} target',
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
          ],
        ),
      ),
    );
  }
}
