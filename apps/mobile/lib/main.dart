import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router.dart';
import 'theme/app_theme.dart';
import 'services/push_stub.dart';

void main() => runApp(const ProviderScope(child: ScredexApp()));

class ScredexApp extends ConsumerWidget {
  const ScredexApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Initialize push plug points (Firebase/APNs can replace this stub)
    ref.watch(startupPushProvider);
    final theme = ref.watch(appThemeProvider);
    return MaterialApp.router(
      title: 'Scredex',
      routerConfig: router,
      theme: theme,
    );
  }
}
