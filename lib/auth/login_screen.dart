import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

/// Sign in / create account screen. After a successful sign-in the app
/// switches to the main screens automatically (see `main.dart`).
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _creatingAccount = false;
  bool _busy = false;
  bool _hidePassword = true;
  String? _error;
  String? _info;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _setMode(bool creating) {
    setState(() {
      _creatingAccount = creating;
      _error = null;
      _info = null;
    });
  }

  Future<void> _submit() async {
    if (_busy) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    setState(() {
      _busy = true;
      _error = null;
      _info = null;
    });

    try {
      if (_creatingAccount) {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
      } else {
        await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      }
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      setState(() => _error = _friendlyMessage(error));
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
      _info = null;
    });

    try {
      final provider = GoogleAuthProvider();
      if (kIsWeb) {
        await FirebaseAuth.instance.signInWithPopup(provider);
      } else {
        await FirebaseAuth.instance.signInWithProvider(provider);
      }
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      // Closing the Google window is not an error worth showing.
      if (error.code != 'popup-closed-by-user' && error.code != 'cancelled-popup-request' && error.code != 'canceled') {
        setState(() => _error = _friendlyMessage(error));
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Google sign-in failed. Please try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    if (!email.contains('@') || !email.contains('.')) {
      setState(() {
        _error = 'Type your email address above first, then tap "Forgot password?" again.';
        _info = null;
      });
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
      _info = null;
    });

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (!mounted) return;
      setState(() => _info = 'If an account exists for $email, a password reset link is on its way. Check your spam folder too.');
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      setState(() => _error = _friendlyMessage(error));
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Could not send the reset email. Please try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _friendlyMessage(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
        return 'That email address does not look right.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'An account with this email already exists. Try signing in instead.';
      case 'weak-password':
        return 'Choose a stronger password (at least 6 characters).';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a few minutes and try again.';
      case 'network-request-failed':
        return 'No internet connection. Check your network and try again.';
      case 'operation-not-allowed':
        return 'This sign-in method is not turned on yet in Firebase.';
      case 'unauthorized-domain':
        return 'This website address is not authorised in Firebase yet.';
      case 'popup-blocked':
        return 'Your browser blocked the Google window. Allow pop-ups for this site and try again.';
      default:
        return 'Sign-in failed (${error.code}). Please try again.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: AutofillGroup(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.account_balance_wallet_rounded, color: scheme.primary, size: 30),
                              const SizedBox(width: 10),
                              Text('SpendWise', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _creatingAccount ? 'Create your account to keep your money data safe and private.' : 'Sign in to see your expenses, tasks and goals.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                          ),
                          const SizedBox(height: 22),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.email],
                            enabled: !_busy,
                            decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.mail_outline_rounded)),
                            validator: (value) {
                              final email = value?.trim() ?? '';
                              if (email.isEmpty) return 'Enter your email';
                              if (!email.contains('@') || !email.contains('.')) return 'Enter a valid email address';
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _hidePassword,
                            textInputAction: TextInputAction.done,
                            autofillHints: [_creatingAccount ? AutofillHints.newPassword : AutofillHints.password],
                            enabled: !_busy,
                            onFieldSubmitted: (_) => _submit(),
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock_outline_rounded),
                              suffixIcon: IconButton(
                                tooltip: _hidePassword ? 'Show password' : 'Hide password',
                                onPressed: () => setState(() => _hidePassword = !_hidePassword),
                                icon: Icon(_hidePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                              ),
                            ),
                            validator: (value) {
                              final password = value ?? '';
                              if (password.isEmpty) return 'Enter your password';
                              if (_creatingAccount && password.length < 6) return 'Use at least 6 characters';
                              return null;
                            },
                          ),
                          if (!_creatingAccount)
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(onPressed: _busy ? null : _resetPassword, child: const Text('Forgot password?')),
                            )
                          else
                            const SizedBox(height: 12),
                          if (_error != null) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: scheme.errorContainer, borderRadius: BorderRadius.circular(12)),
                              child: Text(_error!, style: TextStyle(color: scheme.onErrorContainer)),
                            ),
                            const SizedBox(height: 12),
                          ],
                          if (_info != null) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: scheme.primaryContainer, borderRadius: BorderRadius.circular(12)),
                              child: Text(_info!, style: TextStyle(color: scheme.onPrimaryContainer)),
                            ),
                            const SizedBox(height: 12),
                          ],
                          SizedBox(
                            height: 50,
                            child: FilledButton(
                              onPressed: _busy ? null : _submit,
                              child: _busy
                                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5))
                                  : Text(_creatingAccount ? 'Create account' : 'Sign in', style: const TextStyle(fontWeight: FontWeight.w800)),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Expanded(child: Divider()),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: Text('or', style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
                              ),
                              const Expanded(child: Divider()),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 50,
                            child: OutlinedButton.icon(
                              onPressed: _busy ? null : _signInWithGoogle,
                              icon: const Icon(Icons.g_mobiledata_rounded, size: 30),
                              label: const Text('Continue with Google', style: TextStyle(fontWeight: FontWeight.w700)),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(_creatingAccount ? 'Already have an account?' : 'New to SpendWise?', style: theme.textTheme.bodyMedium),
                              TextButton(
                                onPressed: _busy ? null : () => _setMode(!_creatingAccount),
                                child: Text(_creatingAccount ? 'Sign in' : 'Create account'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
