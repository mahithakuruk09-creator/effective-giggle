import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:scredex_mobile/features/auth/twofa_screen.dart';

void main() {
  testWidgets('shows error on wrong otp', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: TwoFAScreen(token: 't')));
    for (int i = 0; i < 6; i++) {
      await tester.enterText(find.byType(TextField).at(i), '0');
    }
    await tester.tap(find.text('Verify'));
    await tester.pump();
    expect(find.text('Invalid code'), findsOneWidget);
  });
}
