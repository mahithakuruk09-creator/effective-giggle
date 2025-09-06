import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import 'security_repo.dart';

class OtpScreen extends ConsumerStatefulWidget {
  final String? suggested;
  const OtpScreen({super.key, this.suggested});
  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _otp = TextEditingController();
  bool sending = false;
  String? error;
  @override
  void initState(){ super.initState(); if(widget.suggested!=null) _otp.text = widget.suggested!; }
  @override
  void dispose(){ _otp.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context){
    return Scaffold(appBar: AppBar(title: const Text('Enter OTP')), body: Padding(padding: const EdgeInsets.all(16), child: GlassCard(child: Column(mainAxisSize: MainAxisSize.min, children:[
      const SizedBox(height: 12),
      TextField(controller: _otp, decoration: const InputDecoration(labelText: '6‑digit code'), keyboardType: TextInputType.number, maxLength: 6),
      if(error!=null) Text(error!, style: const TextStyle(color: Colors.redAccent)),
      const SizedBox(height: 8),
      Row(children:[
        Expanded(child: OutlinedButton(onPressed: sending? null : () async { final code = await ref.read(securityRepoProvider).sendOtp(); if(mounted) setState(()=> _otp.text = code); }, child: const Text('Resend'))),
        const SizedBox(width: 12),
        Expanded(child: AppButtons.primary(label: sending? 'Verifying…' : 'Verify', onPressed: sending? null : () async { setState(()=> sending = true); final ok = await ref.read(securityRepoProvider).verifyOtp(_otp.text.trim()); if(!mounted) return; if(ok){ Navigator.pop(context, true); } else { setState(()=> error = 'Invalid code'); } setState(()=> sending = false); }))
      ])
    ]))));
  }
}

