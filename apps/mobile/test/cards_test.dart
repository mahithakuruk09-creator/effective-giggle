import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../lib/screens/cards_screen.dart';

void main() {
  testWidgets('Cards carousel renders and freeze action exists', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [cardsRepositoryProvider.overrideWithValue(CardsRepositoryFake())],
      child: const MaterialApp(home: CardsScreen()),
    ));
    await tester.pumpAndSettle();
    expect(find.byType(PageView), findsOneWidget);
    expect(find.textContaining('Freeze'), findsOneWidget);
  });
}

