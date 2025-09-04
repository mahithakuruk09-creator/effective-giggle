import 'package:flutter_test/flutter_test.dart';
import '../lib/screens/screens.dart';

void main() {
  testWidgets('Home placeholder renders', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    expect(find.text('Home'), findsOneWidget);
  });
}
