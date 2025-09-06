import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../lib/screens/loans_screen.dart';

void main() {
  testWidgets('Loans screen shows offers and CTAs', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [loansRepositoryProvider.overrideWithValue(LoansRepositoryFake())],
      child: const MaterialApp(home: LoansScreen()),
    ));
    await tester.pumpAndSettle();
    expect(find.textContaining('eligible'), findsOneWidget);
    expect(find.text('Apply for Loan'), findsOneWidget);
    expect(find.text('Explore P2P Lending'), findsOneWidget);
  });
}

