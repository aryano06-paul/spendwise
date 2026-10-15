import 'package:flutter/material.dart';

String currencySymbol(String code) => switch (code) {
      'USD' => r'$',
      'EUR' => '€',
      'GBP' => '£',
      'INR' => '₹',
      _ => '₹',
    };

String formatMoney(double value, String currencyCode, {bool decimals = false}) {
  final negative = value < 0;
  final absValue = value.abs();
  final fixed = absValue.toStringAsFixed(decimals ? 2 : (absValue == absValue.roundToDouble() ? 0 : 2));
  final parts = fixed.split('.');
  final whole = parts[0];
  String grouped;
  if (currencyCode == 'INR') {
    if (whole.length <= 3) {
      grouped = whole;
    } else {
      final lastThree = whole.substring(whole.length - 3);
      var prefix = whole.substring(0, whole.length - 3);
      final groups = <String>[];
      while (prefix.length > 2) {
        groups.insert(0, prefix.substring(prefix.length - 2));
        prefix = prefix.substring(0, prefix.length - 2);
      }
      if (prefix.isNotEmpty) groups.insert(0, prefix);
      grouped = '${groups.join(',')},$lastThree';
    }
  } else {
    final buffer = StringBuffer();
    for (var i = 0; i < whole.length; i++) {
      if (i > 0 && (whole.length - i) % 3 == 0) buffer.write(',');
      buffer.write(whole[i]);
    }
    grouped = buffer.toString();
  }
  final showDecimals = decimals || (parts.length > 1 && parts[1] != '00');
  return '${currencySymbol(currencyCode)}${negative ? '-' : ''}$grouped${showDecimals && parts.length > 1 ? '.${parts[1]}' : ''}';
}

String formatDate(DateTime date) {
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

String formatMonth(DateTime date) {
  const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
  return '${months[date.month - 1]} ${date.year}';
}

String formatDayLabel(DateTime date) {
  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return days[date.weekday - 1];
}

bool isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

bool isSameMonth(DateTime a, DateTime b) => a.year == b.year && a.month == b.month;

DateTime startOfMonth(DateTime date) => DateTime(date.year, date.month);

DateTime startOfWeek(DateTime date) => DateTime(date.year, date.month, date.day - (date.weekday - 1));

Color surfaceTint(BuildContext context) => Theme.of(context).colorScheme.primary.withValues(alpha: 0.09);

String greetingForNow() {
  final hour = DateTime.now().hour;
  if (hour < 12) return 'Good morning';
  if (hour < 17) return 'Good afternoon';
  return 'Good evening';
}
