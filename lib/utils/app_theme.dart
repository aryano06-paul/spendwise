import 'package:flutter/material.dart';

class SpendWiseTheme {
  static ThemeData light(Color accent) => _build(accent, Brightness.light);
  static ThemeData dark(Color accent) => _build(accent, Brightness.dark);

  static ThemeData _build(Color accent, Brightness brightness) {
    final scheme = ColorScheme.fromSeed(seedColor: accent, brightness: brightness);
    final isDark = brightness == Brightness.dark;
    final background = isDark ? const Color(0xFF101117) : const Color(0xFFF6F7FB);
    final surface = isDark ? const Color(0xFF1A1C25) : Colors.white;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      canvasColor: background,
      dividerColor: isDark ? const Color(0xFF343744) : const Color(0xFFE6E8F0),
      cardColor: surface,
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 46),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        backgroundColor: surface,
        indicatorColor: scheme.primary.withValues(alpha: 0.13),
        labelTextStyle: WidgetStateProperty.resolveWith((states) => TextStyle(
          fontSize: 11,
          fontWeight: states.contains(WidgetState.selected) ? FontWeight.w800 : FontWeight.w500,
        )),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: scheme.primary),
    );
  }
}
