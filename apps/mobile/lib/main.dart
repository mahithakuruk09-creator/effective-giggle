import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router.dart';

void main() => runApp(const ProviderScope(child: ScredexApp()));

class ScredexApp extends StatelessWidget {
  const ScredexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Scredex',
      routerConfig: router,
      theme: ThemeData.dark(),
    );
  }
}
