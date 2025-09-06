import 'package:flutter_test/flutter_test.dart';
import 'package:scredex_mobile/main.dart';

void main() {
  testWidgets('App builds', (tester) async {
    await tester.pumpWidget(const ScredexApp());
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.text('Skip'), findsOneWidget);
  });
}
