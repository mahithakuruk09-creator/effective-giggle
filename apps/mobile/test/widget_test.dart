import 'package:flutter_test/flutter_test.dart';
import 'package:scredex_mobile/main.dart';

void main() {
  testWidgets('App loads', (tester) async {
    await tester.pumpWidget(const ScredexApp());
    expect(find.text('Home'), findsNothing);
  });
}
