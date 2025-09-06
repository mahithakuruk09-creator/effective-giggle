import 'package:flutter/material.dart';
import 'package:scredex_design_system/design_system.dart';
import 'router.dart';

void main() => runApp(const ScredexApp());

class ScredexApp extends StatelessWidget {
  const ScredexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Scredex',
      routerConfig: router,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: ScredexColors.background,
        textTheme: ScredexTypography.textTheme,
        colorScheme: const ColorScheme.dark(
          surface: ScredexColors.background,
          primary: ScredexColors.primary,
          secondary: ScredexColors.accent,
        ),
      ),
    );
  }
}
