import 'package:flutter/material.dart';
import 'app_state.dart';
import 'screens/app_shell.dart';
import 'utils/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final state = SpendWiseState();
  await state.load();
  runApp(SpendWiseApp(state: state));
}

class SpendWiseApp extends StatelessWidget {
  final SpendWiseState state;
  const SpendWiseApp({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: state,
      builder: (context, _) => MaterialApp(
        title: 'SpendWise',
        debugShowCheckedModeBanner: false,
        theme: SpendWiseTheme.light(state.accentColor),
        darkTheme: SpendWiseTheme.dark(state.accentColor),
        themeMode: state.themeMode,
        home: AppShell(state: state),
      ),
    );
  }
}
