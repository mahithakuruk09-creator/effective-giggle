import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../lib/features/security_compliance/security_settings_screen.dart';
import '../lib/features/security_compliance/security_repo.dart';

void main() {
  testWidgets('Security settings renders toggles and actions', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [securityRepoProvider.overrideWithValue(SecurityRepoFake())],
      child: const MaterialApp(home: SecuritySettingsScreen()),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Biometric login'), findsOneWidget);
    expect(find.text('Set/Reset PIN'), findsOneWidget);
    expect(find.text('Enable 2FA'), findsOneWidget);
  });
}

