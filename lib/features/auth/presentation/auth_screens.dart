import 'package:flutter/material.dart';

import '../../../data/demo/demo_store.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController(text: 'olivia@taskflow.demo');
  final passwordController = TextEditingController(text: 'demo123');
  String? error;
  bool showRegister = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = DemoScope.of(context);
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      child: const Text('TF'),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      showRegister
                          ? 'Create your TaskFlow account'
                          : 'Welcome to TaskFlow',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Run the portfolio demo instantly, or connect Supabase later for real auth.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.mail_outline),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                    ),
                    if (error != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        error!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: () {
                        final result = showRegister
                            ? store.login(
                                emailController.text,
                                passwordController.text,
                              )
                            : store.login(
                                emailController.text,
                                passwordController.text,
                              );
                        setState(() => error = result);
                      },
                      icon: Icon(
                        showRegister ? Icons.person_add_alt : Icons.login,
                      ),
                      label: Text(
                        showRegister ? 'Register demo account' : 'Sign in',
                      ),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: store.demoLogin,
                      icon: const Icon(Icons.rocket_launch_outlined),
                      label: const Text('Continue in demo mode'),
                    ),
                    TextButton(
                      onPressed: () => setState(() {
                        showRegister = !showRegister;
                        error = null;
                      }),
                      child: Text(
                        showRegister
                            ? 'Already have an account?'
                            : 'Create an account',
                      ),
                    ),
                    const Divider(height: 28),
                    const Text(
                      'Demo emails: olivia@taskflow.demo, alex@taskflow.demo, mia@taskflow.demo, victor@taskflow.demo',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
