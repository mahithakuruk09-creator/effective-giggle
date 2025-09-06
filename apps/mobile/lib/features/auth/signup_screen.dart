import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:scredex_design_system/design_system.dart';
import '../../services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  bool _accepted = false;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ScredexColors.background,
      appBar: AppBar(title: const Text('Create Account')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Full name'),
                validator: (v) => v != null && v.isNotEmpty ? null : 'Required',
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _email,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (v) => v != null && v.contains('@') ? null : 'Enter email',
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phone,
                decoration: const InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
                validator: (v) => v != null && v.length >= 10 ? null : 'Enter phone',
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _password,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (v) => v != null && v.length >= 8 ? null : 'Min 8 chars',
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Checkbox(value: _accepted, onChanged: (v) => setState(() => _accepted = v ?? false)),
                  const Expanded(child: Text('I accept the terms & conditions')),
                ],
              ),
              const SizedBox(height: 24),
              LinearProgressIndicator(value: _loading ? null : (_accepted ? 1 : 0)),
              const SizedBox(height: 24),
              ScredexButton(
                label: 'Create Account',
                onPressed: (!_accepted || _loading)
                    ? null
                    : () async {
                        if (!_formKey.currentState!.validate()) return;
                        setState(() => _loading = true);
                        await AuthService().signup(
                            _name.text, _email.text, _phone.text, _password.text);
                        setState(() => _loading = false);
                        if (!mounted) return;
                        context.go('/login');
                      },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
