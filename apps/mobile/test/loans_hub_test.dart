import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../lib/features/loans_p2p_cards/hub_screen.dart';

void main() {
  testWidgets('Loans hub shows tabs', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: LoansP2PCardsHub())));
    await tester.pumpAndSettle();
    expect(find.text('Borrow'), findsOneWidget);
    expect(find.text('Invest'), findsOneWidget);
    expect(find.text('Credit Cards'), findsOneWidget);
  });
}

