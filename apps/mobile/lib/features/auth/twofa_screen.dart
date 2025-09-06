import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:scredex_design_system/design_system.dart';
import '../../services/auth_service.dart';

class TwoFAScreen extends StatefulWidget {
  final String token;
  const TwoFAScreen({super.key, required this.token});

  @override
  State<TwoFAScreen> createState() => _TwoFAScreenState();
}

class _TwoFAScreenState extends State<TwoFAScreen> {
  final _controllers = List.generate(6, (_) => TextEditingController());
  String _error = '';
  int _seconds = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_seconds == 0) return;
      setState(() => _seconds--);
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _submit() async {
    final code = _controllers.map((c) => c.text).join();
    try {
      await AuthService().verifyOtp(widget.token, code);
      if (!mounted) return;
      context.go('/home');
    } catch (_) {
      setState(() => _error = 'Invalid code');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ScredexColors.background,
      appBar: AppBar(title: const Text('2FA Verification')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                6,
                (i) => SizedBox(
                  width: 40,
                  child: TextField(
                    controller: _controllers[i],
                    maxLength: 1,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(counterText: ''),
                    onChanged: (v) {
                      if (v.isNotEmpty && i < 5) {
                        FocusScope.of(context).nextFocus();
                      }
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_error.isNotEmpty) Text(_error, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            Text('$_seconds s'),
            TextButton(
              onPressed: _seconds == 0
                  ? () {
                      setState(() => _seconds = 60);
                    }
                  : null,
              child: const Text('Resend'),
            ),
            const SizedBox(height: 24),
            ScredexButton(label: 'Verify', onPressed: _submit),
          ],
        ),
      ),
    );
  }
}
