import 'package:flutter/material.dart';
import '../app_state.dart';
import '../widgets/bottom_nav.dart';
import 'dashboard_screen.dart';
import 'expense_screen.dart';
import 'insights_screen.dart';
import 'todo_screen.dart';

class AppShell extends StatefulWidget {
  final SpendWiseState state;
  const AppShell({super.key, required this.state});
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  void _navigate(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: [
        DashboardScreen(state: widget.state, onNavigate: _navigate),
        ExpenseScreen(state: widget.state),
        TodoScreen(state: widget.state),
        InsightsScreen(state: widget.state),
      ]),
      bottomNavigationBar: SpendWiseBottomNav(selectedIndex: _selectedIndex, onSelected: _navigate),
    );
  }
}
