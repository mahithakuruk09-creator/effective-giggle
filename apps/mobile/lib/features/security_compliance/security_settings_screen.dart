import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import 'security_repo.dart';
import 'pin_setup_screen.dart';
import 'otp_screen.dart';

final securityRepoProvider = Provider<SecurityRepo>((_) => SecurityRepoHttp());

class SecuritySettingsScreen extends ConsumerStatefulWidget {
  const SecuritySettingsScreen({super.key});
  @override
  ConsumerState<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends ConsumerState<SecuritySettingsScreen> {
  bool bio = false;
  bool loading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Security & Compliance')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        GlassCard(child: SwitchListTile(
          value: bio,
          title: const Text('Biometric login'),
          subtitle: const Text('FaceID/TouchID (mock toggle)'),
          onChanged: (v) async {
            setState(()=> bio = v); await ref.read(securityRepoProvider).toggleBiometric(v);
          },
        )),
        const SizedBox(height: 12),
        GlassCard(child: ListTile(
          leading: const Icon(Icons.lock_outline),
          title: const Text('Set/Reset PIN'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_)=> const PinSetupScreen())),
        )),
        const SizedBox(height: 12),
        GlassCard(child: ListTile(
          leading: const Icon(Icons.verified_user_outlined),
          title: const Text('Enable 2FA'),
          subtitle: const Text('Mock SMS/Email OTP'),
          trailing: AppButtons.primary(label: 'Enable', onPressed: () async {
            final code = await ref.read(securityRepoProvider).sendOtp();
            if(!mounted) return; final ok = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_)=> OtpScreen(suggested: code)));
            if(ok == true) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('2FA enabled')));
          }),
        )),
        const SizedBox(height: 16),
        const Text('Privacy & Compliance'),
        const SizedBox(height: 8),
        GlassCard(child: ListTile(
          leading: const Icon(Icons.file_download_outlined),
          title: const Text('Download My Data'),
          onTap: () async {
            final data = await ref.read(securityRepoProvider).downloadData();
            if(!mounted) return; showModalBottomSheet(context: context, showDragHandle: true, builder: (_)=> Padding(padding: const EdgeInsets.all(16), child: Text(data.toString())));
          },
        )),
        const SizedBox(height: 8),
        GlassCard(child: ListTile(
          leading: const Icon(Icons.delete_outline),
          title: const Text('Delete My Account (mock)'),
          onTap: () async { await ref.read(securityRepoProvider).deleteAccount(); if(!mounted) return; ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account deleted (mock)'))); },
        )),
      ]),
    );
  }
}

