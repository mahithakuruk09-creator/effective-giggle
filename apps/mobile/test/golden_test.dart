import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/screens/screens.dart';

void main() {
  testWidgets('Dashboard renders', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    expect(find.text('Dashboard'), findsOneWidget);
  });
}
