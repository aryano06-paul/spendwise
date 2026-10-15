import 'package:flutter/material.dart';

/// Shown while the app checks who is signed in, and while a user's data loads.
/// If loading failed it shows the problem with Retry and Sign out buttons.
class LoadingScreen extends StatelessWidget {
  final String message;
  final String? error;
  final VoidCallback? onRetry;
  final VoidCallback? onSignOut;

  const LoadingScreen({
    super.key,
    this.message = 'Loading…',
    this.error,
    this.onRetry,
    this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (error == null) ...[
                  const CircularProgressIndicator(),
                  const SizedBox(height: 18),
                  Text(message, style: theme.textTheme.bodyMedium),
                ] else ...[
                  Icon(Icons.cloud_off_rounded, size: 44, color: theme.colorScheme.error),
                  const SizedBox(height: 14),
                  Text(error!, textAlign: TextAlign.center, style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 18),
                  if (onRetry != null) FilledButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh_rounded), label: const Text('Try again')),
                  if (onSignOut != null) TextButton(onPressed: onSignOut, child: const Text('Sign out')),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Shown instead of the app when the Firebase values in
/// `lib/firebase_options.dart` have not been filled in yet.
class SetupNeededApp extends StatelessWidget {
  const SetupNeededApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SpendWise',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.settings_rounded, size: 44),
                  SizedBox(height: 14),
                  Text('SpendWise needs one more setup step', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800), textAlign: TextAlign.center),
                  SizedBox(height: 10),
                  Text(
                    'Open lib/firebase_options.dart and replace the six PASTE_ values with the ones from your Firebase project, then run the app again.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
