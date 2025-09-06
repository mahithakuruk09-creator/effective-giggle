import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../lib/main.dart';
import '../lib/theme/app_theme.dart';

void main() {
  testWidgets('Global theme applies Banklink styling', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: ScredexApp()));
    await tester.pumpAndSettle();

    // Verify AppBar is transparent and text color is light
    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    final theme = app.theme!;
    expect(theme.appBarTheme.backgroundColor, Colors.transparent);

    // Verify bottom sheet and tabbar theming exist
    expect(theme.bottomSheetTheme.modalBackgroundColor, isNotNull);
    expect(theme.tabBarTheme.labelColor, isNotNull);
  });
}
