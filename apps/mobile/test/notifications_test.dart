import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../lib/features/insights_notifications/notifications_screen.dart';
import '../lib/features/insights_notifications/repo.dart';

class _Fake extends InsightsRepoFake {
  bool acted = false;
  @override
  Future<void> act(String id) async { acted = true; }
}

void main() {
  testWidgets('Notifications show feed and CTA', (tester) async {
    final fake = _Fake();
    await tester.pumpWidget(ProviderScope(
      overrides: [insightsRepoProvider.overrideWithValue(fake)],
      child: const MaterialApp(home: NotificationsScreen()),
    ));
    await tester.pumpAndSettle();
    expect(find.textContaining('Pintos earned'), findsOneWidget);
    final cta = find.text('Redeem');
    expect(cta, findsOneWidget);
    await tester.tap(cta);
    await tester.pumpAndSettle();
  });
}

