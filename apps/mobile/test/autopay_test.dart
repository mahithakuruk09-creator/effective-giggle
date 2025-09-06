import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../lib/models/autopay_model.dart';
import '../lib/screens/autopay_manager_screen.dart';

void main() {
  testWidgets('Autopay screen shows empty state and adds item', (tester) async {
    final repo = AutopayRepositoryFake();

    await tester.pumpWidget(ProviderScope(
      overrides: [
        autopayRepositoryProvider.overrideWithValue(repo),
      ],
      child: const MaterialApp(home: AutopayManagerScreen()),
    ));

    // initial load
    await tester.pumpAndSettle();
    expect(find.textContaining('No autopay set up yet'), findsOneWidget);

    // open add sheet
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(find.text('Payment type'), findsOneWidget);

    // Save with defaults
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // List should now have one tile
    expect(find.byType(ListTile), findsOneWidget);
  });

  testWidgets('Toggle updates state', (tester) async {
    final repo = AutopayRepositoryFake([
      AutopayConfig(
        autopayId: 'ap_001',
        billerId: 'b123',
        type: AutopayType.minimum,
        cap: null,
        preAlertDays: 0,
        enabled: false,
      )
    ]);

    await tester.pumpWidget(ProviderScope(
      overrides: [
        autopayRepositoryProvider.overrideWithValue(repo),
      ],
      child: const MaterialApp(home: AutopayManagerScreen()),
    ));

    await tester.pumpAndSettle();

    final switchFinder = find.byType(Switch);
    expect(switchFinder, findsOneWidget);

    await tester.tap(switchFinder);
    await tester.pumpAndSettle();
  });
}

