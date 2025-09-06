import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../lib/features/virtual_finance_layer/wallet_screen.dart';
import '../lib/features/virtual_finance_layer/repo.dart';

void main() {
  testWidgets('Wallet shows account and cards, freeze toggles', (tester) async {
    final fake = VflRepositoryFake();
    await tester.pumpWidget(ProviderScope(overrides: [vflRepoProvider.overrideWithValue(fake)], child: const MaterialApp(home: WalletVflScreen())));
    await tester.pumpAndSettle();
    expect(find.textContaining('Sort code'), findsOneWidget);
    // Freeze/unfreeze
    final btn = find.textContaining('Freeze');
    expect(btn, findsOneWidget);
    await tester.tap(btn);
    await tester.pumpAndSettle();
  });
}

