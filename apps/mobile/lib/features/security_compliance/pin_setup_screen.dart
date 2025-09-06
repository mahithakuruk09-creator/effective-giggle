import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import 'security_repo.dart';

class PinSetupScreen extends ConsumerStatefulWidget {
  const PinSetupScreen({super.key});
  @override
  ConsumerState<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends ConsumerState<PinSetupScreen> {
  final _a = TextEditingController();
  final _b = TextEditingController();
  bool saving = false;
  String? error;
  @override
  void dispose(){ _a.dispose(); _b.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context){
    return Scaffold(appBar: AppBar(title: const Text('Set PIN')), body: Padding(padding: const EdgeInsets.all(16), child: GlassCard(child: Column(mainAxisSize: MainAxisSize.min, children:[
      const SizedBox(height: 12),
      TextField(controller: _a, decoration: const InputDecoration(labelText: 'Enter PIN (4–6 digits)'), keyboardType: TextInputType.number, obscureText: true, maxLength: 6),
      TextField(controller: _b, decoration: const InputDecoration(labelText: 'Confirm PIN'), keyboardType: TextInputType.number, obscureText: true, maxLength: 6),
      if(error!=null) Padding(padding: const EdgeInsets.only(top:8), child: Text(error!, style: const TextStyle(color: Colors.redAccent))),
      const SizedBox(height: 8),
      Align(alignment: Alignment.centerRight, child: AppButtons.primary(label: saving? 'Saving…':'Save', onPressed: saving? null : () async {
        final a = _a.text.trim(), b = _b.text.trim();
        if(a != b || a.length < 4 || a.length > 6){ setState(()=> error = 'PIN mismatch/length'); return; }
        setState(()=> saving = true);
        await ref.read(securityRepoProvider).setPin(a);
        if(!mounted) return; Navigator.pop(context, true);
      }))
    ]))));
  }
}

