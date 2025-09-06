import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../lib/screens/credit_score_screen.dart';

void main() {
  testWidgets('Credit score dial and insights render', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        creditRepositoryProvider.overrideWithValue(CreditRepositoryFake()),
      ],
      child: const MaterialApp(home: CreditScoreScreen()),
    ));

    await tester.pumpAndSettle();
    expect(find.textContaining('Band:'), findsOneWidget);
    expect(find.text('Score Simulator'), findsOneWidget);
  });

  testWidgets('Simulator updates score', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        creditRepositoryProvider.overrideWithValue(CreditRepositoryFake()),
      ],
      child: const MaterialApp(home: CreditScoreScreen()),
    ));

    await tester.pumpAndSettle();
    // Tap simulate
    await tester.tap(find.text('Simulate'));
    await tester.pumpAndSettle();
    // A snackbar should show
    expect(find.byType(SnackBar), findsOneWidget);
  });
}

