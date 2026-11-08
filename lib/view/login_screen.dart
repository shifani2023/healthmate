import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';
import '../widgets/background_image.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _auth = AuthController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _isRegister = false;
  bool _hidePassword = true;
  bool _isBusy = false;
  String? _errorText;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isBusy = true;
      _errorText = null;
    });

    try {
      if (_isRegister) {
        final error = await _auth.register(
          _usernameController.text,
          _passwordController.text,
        );
        if (error != null) {
          setState(() => _errorText = error);
          return;
        }
      } else {
        final ok = await _auth.login(
          _usernameController.text,
          _passwordController.text,
        );
        if (!ok) {
          setState(() => _errorText = 'Wrong username or password.');
          return;
        }
      }

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    } catch (e) {
      // Technical details go to the Terminal only
      debugPrint('Login error: $e');
      if (!mounted) return;
      setState(() => _errorText = 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  void _switchMode() {
    setState(() {
      _isRegister = !_isRegister;
      _errorText = null;
      _passwordController.clear();
      _confirmController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundImage(
      asset: 'images/login.png',
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Icon(Icons.favorite, size: 64, color: Colors.green),
                  const SizedBox(height: 8),
                  Text(
                    'HealthMate',
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text('Your personal health and wellness tracker'),
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            Text(
                              _isRegister ? 'Create an account' : 'Log in',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _usernameController,
                              decoration: const InputDecoration(
                                labelText: 'Username',
                                prefixIcon: Icon(Icons.person),
                              ),
                              validator: (v) =>
                                  (v == null || v.trim().length < 3)
                                      ? 'Username must be at least 3 characters'
                                      : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _hidePassword,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                prefixIcon: const Icon(Icons.lock),
                                suffixIcon: IconButton(
                                  onPressed: () => setState(
                                      () => _hidePassword = !_hidePassword),
                                  icon: Icon(_hidePassword
                                      ? Icons.visibility
                                      : Icons.visibility_off),
                                ),
                              ),
                              validator: (v) => (v == null || v.length < 6)
                                  ? 'Password must be at least 6 characters'
                                  : null,
                            ),
                            if (_isRegister) ...[
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _confirmController,
                                obscureText: _hidePassword,
                                decoration: const InputDecoration(
                                  labelText: 'Confirm password',
                                  prefixIcon: Icon(Icons.lock_outline),
                                ),
                                validator: (v) => v != _passwordController.text
                                    ? 'Passwords do not match'
                                    : null,
                              ),
                            ],
                            if (_errorText != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Text(
                                  _errorText!,
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: _isBusy ? null : _submit,
                                child: Text(_isBusy
                                    ? 'Please wait...'
                                    : (_isRegister ? 'Create account' : 'Log in')),
                              ),
                            ),
                            TextButton(
                              onPressed: _isBusy ? null : _switchMode,
                              child: Text(_isRegister
                                  ? 'I already have an account – Log in'
                                  : 'New here? Create an account'),
                            ),
                          ],
                        ),
                      ),
                    ),
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