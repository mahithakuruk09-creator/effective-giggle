import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../lib/features/insights_notifications/insights_screen.dart';
import '../lib/features/insights_notifications/repo.dart';

void main() {
  testWidgets('Insights renders pie and trend', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [insightsRepoProvider.overrideWithValue(InsightsRepoFake())],
      child: const MaterialApp(home: InsightsScreen()),
    ));
    await tester.pumpAndSettle();
    expect(find.text("This Month's Spend"), findsOneWidget);
    // Pie chart and trend line are CustomPaint widgets
    expect(find.byType(CustomPaint), findsWidgets);
  });
}

