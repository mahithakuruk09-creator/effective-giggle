import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../features/security_compliance/security_settings_screen.dart';

class ProfileSettingsScreen extends ConsumerWidget {
  const ProfileSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final highContrast = ref.watch(highContrastProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Profile & Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text('High contrast mode'),
            subtitle: const Text('Improves readability and contrast'),
            value: highContrast,
            onChanged: (v) => ref.read(highContrastProvider.notifier).state = v,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.security_outlined),
            title: const Text('Security & Compliance'),
            subtitle: const Text('PIN, Biometrics, 2FA, GDPR'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_)=> const SecuritySettingsScreen())),
          ),
          const Divider(),
          const ListTile(
            title: Text('Account'),
            subtitle: Text('Manage your profile and security'),
            leading: Icon(Icons.person_outline),
          ),
        ],
      ),
    );
  }
}
