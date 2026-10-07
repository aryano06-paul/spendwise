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

  double get remaining {
    final value = target - saved;
    return value < 0 ? 0.0 : value;
  }
}