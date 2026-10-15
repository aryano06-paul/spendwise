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
      body: Column(
        children: [
          ListenableBuilder(
            listenable: widget.state,
            builder: (context, _) {
              final message = widget.state.syncError;
              if (message == null) return const SizedBox.shrink();
              final scheme = Theme.of(context).colorScheme;
              return Material(
                color: scheme.errorContainer,
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Row(
                      children: [
                        Icon(Icons.cloud_off_rounded, size: 18, color: scheme.onErrorContainer),
                        const SizedBox(width: 10),
                        Expanded(child: Text(message, style: TextStyle(color: scheme.onErrorContainer, fontSize: 13))),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          Expanded(
            child: IndexedStack(index: _selectedIndex, children: [
              DashboardScreen(state: widget.state, onNavigate: _navigate),
              ExpenseScreen(state: widget.state),
              TodoScreen(state: widget.state),
              InsightsScreen(state: widget.state),
            ]),
          ),
        ],
      ),
      bottomNavigationBar: SpendWiseBottomNav(selectedIndex: _selectedIndex, onSelected: _navigate),
    );
  }
}
