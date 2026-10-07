import 'package:flutter/material.dart';

class AppearanceScreen extends StatelessWidget {
  final ThemeMode currentTheme;
  final void Function(ThemeMode) onThemeChanged;

  const AppearanceScreen({
    super.key,
    required this.currentTheme,
    required this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
      Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Appearance',
          style: TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          20,
          10,
          20,
          30,
        ),
        children: [
          Text(
            'Make Spendwise yours',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Choose how your money space looks and feels.',
            style: TextStyle(
              color: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.color
                  ?.withValues(alpha: 0.60),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 25),
          const Text(
            'Theme',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _themeCard(
                  context,
                  'Light',
                  Icons.light_mode_rounded,
                  ThemeMode.light,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _themeCard(
                  context,
                  'Dark',
                  Icons.dark_mode_rounded,
                  ThemeMode.dark,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _themeCard(
                  context,
                  'System',
                  Icons.settings_brightness_rounded,
                  ThemeMode.system,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          const Text(
            'Accent Color',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceAround,
              children: [
                _ColorDot(
                  color: Color(0xFF675CF6),
                  selected: true,
                ),
                _ColorDot(
                  color: Color(0xFF5B8DEF),
                ),
                _ColorDot(
                  color: Color(0xFF19BFA3),
                ),
                _ColorDot(
                  color: Color(0xFFFFB344),
                ),
                _ColorDot(
                  color: Color(0xFFFF6482),
                ),
                _ColorDot(
                  color: Color(0xFFD66AF4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            'App Style',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _styleCard(
                  context,
                  Icons.blur_on_rounded,
                  'Glass',
                  false,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _styleCard(
                  context,
                  Icons.crop_square_rounded,
                  'Minimal',
                  false,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _styleCard(
                  context,
                  Icons.bolt_rounded,
                  'Vibrant',
                  true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: const Color(0xFF675CF6)
                        .withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: Color(0xFF675CF6),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Theme changes are applied instantly across Spendwise.',
                    style: TextStyle(
                      color: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.color,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _themeCard(
      BuildContext context,
      String title,
      IconData icon,
      ThemeMode mode,
      ) {
    final selected = currentTheme == mode;
    const accent = Color(0xFF675CF6);

    return GestureDetector(
      onTap: () {
        onThemeChanged(mode);
      },
      child: Container(
        height: 115,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: selected
                ? accent
                : Theme.of(context)
                .dividerColor
                .withValues(alpha: 0.08),
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: selected
                  ? accent
                  : Theme.of(context).iconTheme.color,
              size: 28,
            ),
            const SizedBox(height: 9),
            Text(
              title,
              style: TextStyle(
                color: selected
                    ? accent
                    : Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.color,
                fontWeight: selected
                    ? FontWeight.w800
                    : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _styleCard(
      BuildContext context,
      IconData icon,
      String title,
      bool selected,
      ) {
    const accent = Color(0xFF675CF6);

    return Container(
      height: 105,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: selected
              ? accent
              : Theme.of(context)
              .dividerColor
              .withValues(alpha: 0.08),
          width: selected ? 2 : 1,
        ),
      ),
      child: Column(
        mainAxisAlignment:
        MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: selected
                ? accent
                : Theme.of(context).iconTheme.color,
            size: 27,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: selected
                  ? accent
                  : Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.color,
              fontWeight: selected
                  ? FontWeight.w800
                  : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  final Color color;
  final bool selected;

  const _ColorDot({
    required this.color,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected
              ? color
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.25),
              blurRadius: 10,
            ),
          ],
        ),
      ),
    );
  }
}
