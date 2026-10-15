import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app_state.dart';
import 'auth/login_screen.dart';
import 'auth/status_screens.dart';
import 'firebase_options.dart';
import 'screens/app_shell.dart';
import 'services/cloud_store.dart';
import 'utils/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!SpendWiseFirebase.isConfigured) {
    runApp(const SetupNeededApp());
    return;
  }

  await Firebase.initializeApp(options: SpendWiseFirebase.options);
  runApp(const SpendWiseApp());
}

/// Root of the app. Watches who is signed in and creates one
/// [SpendWiseState] per signed-in user, so two people can never see
/// each other's data.
class SpendWiseApp extends StatefulWidget {
  const SpendWiseApp({super.key});

  @override
  State<SpendWiseApp> createState() => _SpendWiseAppState();
}

class _SpendWiseAppState extends State<SpendWiseApp> {
  StreamSubscription<User?>? _authSubscription;
  bool _authResolved = false;
  User? _user;
  SpendWiseState? _state;

  @override
  void initState() {
    super.initState();
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen(_onUserChanged);
  }

  void _onUserChanged(User? user) {
    if (!mounted) return;

    // Same person (for example a token refresh): keep the loaded data.
    if (_authResolved && user?.uid == _user?.uid) {
      setState(() => _user = user);
      return;
    }

    final oldState = _state;
    final newState = user == null ? null : SpendWiseState(store: CloudStore(user.uid));

    setState(() {
      _authResolved = true;
      _user = user;
      _state = newState;
    });

    // Dispose the old state only after the screens using it are gone.
    if (oldState != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => oldState.dispose());
    }
    newState?.load();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _state?.dispose();
    super.dispose();
  }

  Future<void> _signOut() => FirebaseAuth.instance.signOut();

  @override
  Widget build(BuildContext context) {
    final state = _state;
    if (state == null) {
      return _buildApp(
        accent: SpendWiseState.accentOptions.first,
        themeMode: ThemeMode.system,
        home: _authResolved ? const LoginScreen() : const LoadingScreen(message: 'Starting SpendWise…'),
      );
    }

    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        final Widget home;
        if (state.loadError != null) {
          home = LoadingScreen(error: state.loadError, onRetry: state.load, onSignOut: _signOut);
        } else if (!state.isLoaded) {
          home = const LoadingScreen(message: 'Loading your data…');
        } else {
          home = AppShell(key: ValueKey(_user?.uid), state: state);
        }
        return _buildApp(accent: state.accentColor, themeMode: state.themeMode, home: home);
      },
    );
  }

  Widget _buildApp({required Color accent, required ThemeMode themeMode, required Widget home}) {
    return MaterialApp(
      title: 'SpendWise',
      debugShowCheckedModeBanner: false,
      theme: SpendWiseTheme.light(accent),
      darkTheme: SpendWiseTheme.dark(accent),
      themeMode: themeMode,
      home: home,
    );
  }
}
