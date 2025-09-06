import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:scredex_design_system/design_system.dart';
import '../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ScredexColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _email,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => v != null && v.contains('@') ? null : 'Enter email',
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _password,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (v) => v != null && v.length >= 8 ? null : 'Min 8 chars',
                ),
                const SizedBox(height: 24),
                ScredexButton(
                  label: 'Login',
                  onPressed: _loading
                      ? null
                      : () async {
                          if (!_formKey.currentState!.validate()) return;
                          setState(() => _loading = true);
                          final token = await AuthService()
                              .login(_email.text, _password.text);
                          setState(() => _loading = false);
                          if (!mounted) return;
                          context.go('/2fa', extra: token);
                        },
                ),
                TextButton(
                  onPressed: () => context.go('/reset-password'),
                  child: const Text('Forgot Password?'),
                ),
                TextButton(
                  onPressed: () => context.go('/signup'),
                  child: const Text('Login with Phone / Signup'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
