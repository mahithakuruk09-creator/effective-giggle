import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:scredex_design_system/design_system.dart';
import '../../services/auth_service.dart';

class PasswordResetScreen extends StatefulWidget {
  const PasswordResetScreen({super.key});

  @override
  State<PasswordResetScreen> createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  final _email = TextEditingController();
  bool _sent = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ScredexColors.background,
      appBar: AppBar(title: const Text('Reset Password')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: _sent
            ? Column(
                children: [
                  const Text("We've sent you instructions"),
                  const SizedBox(height: 12),
                  ScredexButton(
                      label: 'Back to Login',
                      onPressed: () => context.go('/login')),
                ],
              )
            : Column(
                children: [
                  TextField(
                    controller: _email,
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                  const SizedBox(height: 24),
                  ScredexButton(
                    label: 'Send Reset Link',
                    onPressed: () async {
                      await AuthService().resetPassword(_email.text);
                      setState(() => _sent = true);
                    },
                  )
                ],
              ),
      ),
    );
  }
}
