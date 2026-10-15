import 'package:flutter/material.dart';
import '../app_state.dart';
import 'dashboard_screen.dart';

/// Compatibility wrapper for projects that already refer to HomeScreen.
class HomeScreen extends StatelessWidget {
  final SpendWiseState state;
  final ValueChanged<int> onNavigate;
  const HomeScreen({super.key, required this.state, required this.onNavigate});

  @override
  Widget build(BuildContext context) => DashboardScreen(state: state, onNavigate: onNavigate);
}
