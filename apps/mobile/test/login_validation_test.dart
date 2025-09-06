import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:scredex_mobile/features/auth/login_screen.dart';

void main() {
  testWidgets('login validation', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
    await tester.enterText(find.byType(TextFormField).first, 'bad');
    await tester.tap(find.text('Login'));
    await tester.pump();
    expect(find.text('Enter email'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).first, 'user@example.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'short');
    await tester.tap(find.text('Login'));
    await tester.pump();
    expect(find.text('Min 8 chars'), findsOneWidget);
  });
}
