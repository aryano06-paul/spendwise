import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const SpendWiseApp());
}

class SpendWiseApp extends StatefulWidget {
  const SpendWiseApp({super.key});

  @override
  State<SpendWiseApp> createState() => _SpendWiseAppState();
}

class _SpendWiseAppState extends State<SpendWiseApp> {
  ThemeMode themeMode = ThemeMode.light;

  void changeTheme(ThemeMode mode) {
    setState(() {
      themeMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Spendwise',
      themeMode: themeMode,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF7F7FC),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF675CF6),
          brightness: Brightness.light,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0D1020),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7C73FF),
          brightness: Brightness.dark,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF171A2A),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      home: HomeScreen(
        currentTheme: themeMode,
        onThemeChanged: changeTheme,
      ),
    );
  }
}
