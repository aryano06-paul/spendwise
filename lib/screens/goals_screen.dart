import 'package:flutter/material.dart';

class Goal {
  final String title;
  final String subtitle;
  final double target;
  final double saved;
  final IconData icon;

  const Goal({
    required this.title,
    required this.subtitle,
    required this.target,
    required this.saved,
    required this.icon,
  });

  double get progress {
    if (target <= 0) {
      return 0.0;
    }

    return (saved / target).clamp(0.0, 1.0);
  }
}

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  static const List<Goal> goals = [
    Goal(
      title: 'New Laptop',
      subtitle: 'MacBook / Gaming Laptop',
      target: 25000,
      saved: 12000,
      icon: Icons.laptop_mac_rounded,
    ),
    Goal(
      title: 'Germany Trip',
      subtitle: 'Travel fund',
      target: 100000,
      saved: 30000,
      icon: Icons.flight_takeoff_rounded,
    ),
    Goal(
      title: 'Emergency Fund',
      subtitle: 'Safety net',
      target: 250000,
      saved: 50000,
      icon: Icons.shield_rounded,
    ),
  ];

  static double get totalTarget {
    return goals.fold(
      0.0,
          (sum, goal) => sum + goal.target,
    );
  }

  static double get totalSaved {
    return goals.fold(
      0.0,
          (sum, goal) => sum + goal.saved,
    );
  }

  static double get overallProgress {
    if (totalTarget <= 0) {
      return 0.0;
    }

    return (totalSaved / totalTarget)
        .clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
      Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Goals',
          style: TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          20,
          6,
          20,
          30,
        ),
        children: [
          Text(
            'Give your money somewhere to go.',
            style: TextStyle(
              color: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.color
                  ?.withValues(alpha: 0.60),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 18),
          _summaryCard(context),
          const SizedBox(height: 24),
          ...goals.map(
                (goal) => Padding(
              padding: const EdgeInsets.only(
                bottom: 12,
              ),
              child: _goalCard(
                context,
                goal,
              ),
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 54,
            child: FilledButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context)
                    .showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Goal creation will be added next.',
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.add_rounded),
              label: const Text(
                'Create New Goal',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor:
                const Color(0xFF675CF6),
                shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(18),
                ),
              ),
            ),
          ),
        ],
      ),
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
          colors: [
            Color(0xFF252152),
            Color(0xFF675CF6),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          const Text(
            'Overall progress',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            '₹${totalSaved.toStringAsFixed(0)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 31,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'of ₹${totalTarget.toStringAsFixed(0)} in goals',
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius:
            BorderRadius.circular(50),
            child: LinearProgressIndicator(
              value: overallProgress,
              minHeight: 9,
              backgroundColor: Colors.white24,
              valueColor:
              const AlwaysStoppedAnimation<
                  Color>(
                Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(overallProgress * 100).round()}% complete',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _goalCard(
      BuildContext context,
      Goal goal,
      ) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius:
        BorderRadius.circular(23),
        border: Border.all(
          color: Theme.of(context)
              .dividerColor
              .withValues(alpha: 0.06),
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
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
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
                '${(goal.progress * 100).round()}%',
                style: const TextStyle(
                  color: Color(0xFF675CF6),
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius:
                  BorderRadius.circular(50),
                  child: LinearProgressIndicator(
                    value: goal.progress,
                    minHeight: 8,
                    backgroundColor:
                    Theme.of(context)
                        .dividerColor
                        .withValues(alpha: 0.10),
                    valueColor:
                    const AlwaysStoppedAnimation<
                        Color>(
                      Color(0xFF2EC7D1),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '₹${goal.saved.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
              ),
              Text(
                ' / ₹${goal.target.toStringAsFixed(0)}',
                style: TextStyle(
                  color: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.color
                      ?.withValues(alpha: 0.60),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
