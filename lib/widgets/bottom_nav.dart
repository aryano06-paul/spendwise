import 'package:flutter/material.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const Color activeColor = Color(0xFF675CF6);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inactiveColor = isDark ? Colors.white54 : Colors.black38;

    return BottomAppBar(
      height: 76,
      color: Theme.of(context).cardColor,
      elevation: 10,
      child: Row(
        children: [
          _item(
            context,
            icon: Icons.home_rounded,
            label: 'Home',
            index: 0,
            inactiveColor: inactiveColor,
          ),
          _item(
            context,
            icon: Icons.account_balance_wallet_rounded,
            label: 'Expenses',
            index: 1,
            inactiveColor: inactiveColor,
          ),
          _item(
            context,
            icon: Icons.checklist_rounded,
            label: 'Todo',
            index: 2,
            inactiveColor: inactiveColor,
          ),
          _item(
            context,
            icon: Icons.auto_awesome_rounded,
            label: 'Insights',
            index: 3,
            inactiveColor: inactiveColor,
          ),
        ],
      ),
    );
  }

  Widget _item(
      BuildContext context, {
        required IconData icon,
        required String label,
        required int index,
        required Color inactiveColor,
      }) {
    final selected = currentIndex == index;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onTap(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 23,
              color: selected ? activeColor : inactiveColor,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: selected
                    ? FontWeight.w800
                    : FontWeight.w500,
                color: selected ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
