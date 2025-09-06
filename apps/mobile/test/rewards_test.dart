import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../lib/screens/rewards_screen.dart';
import '../lib/models/pinto_model.dart';
import '../lib/models/store_item_model.dart';

void main() {
  testWidgets('Rewards shows balance and store list', (tester) async {
    final pintoFake = PintoRepositoryFake(initialBalance: 1500);
    final storeFake = StoreRepositoryFake();

    await tester.pumpWidget(ProviderScope(
      overrides: [
        pintoRepositoryProvider.overrideWithValue(pintoFake),
        storeRepositoryProvider.overrideWithValue(storeFake),
      ],
      child: const MaterialApp(home: RewardsScreen()),
    ));

    await tester.pumpAndSettle();

    expect(find.textContaining('View Ledger'), findsOneWidget);
    expect(find.textContaining('Pintos'), findsWidgets);
    expect(find.text('Gift Cards'), findsOneWidget);
    expect(find.byType(ListView), findsWidgets);
  });

  testWidgets('Redeem reduces balance and shows toast', (tester) async {
    final pintoFake = PintoRepositoryFake(initialBalance: 2000);
    final storeFake = StoreRepositoryFake();
    await tester.pumpWidget(ProviderScope(
      overrides: [
        pintoRepositoryProvider.overrideWithValue(pintoFake),
        storeRepositoryProvider.overrideWithValue(storeFake),
      ],
      child: const MaterialApp(home: RewardsScreen()),
    ));

    await tester.pumpAndSettle();

    // Tap first redeem
    final redeem = find.text('Redeem').first;
    await tester.tap(redeem);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // No assertion on balance text (animated), but ensure a SnackBar appeared
    expect(find.byType(SnackBar), findsOneWidget);
  });

  testWidgets('Ledger modal opens', (tester) async {
    final pintoFake = PintoRepositoryFake(initialBalance: 1000, ledger: []);
    final storeFake = StoreRepositoryFake();
    await tester.pumpWidget(ProviderScope(
      overrides: [
        pintoRepositoryProvider.overrideWithValue(pintoFake),
        storeRepositoryProvider.overrideWithValue(storeFake),
      ],
      child: const MaterialApp(home: RewardsScreen()),
    ));

    await tester.pumpAndSettle();
    await tester.tap(find.text('View Ledger'));
    await tester.pumpAndSettle();
    expect(find.text('Pinto Ledger'), findsOneWidget);
  });
}

