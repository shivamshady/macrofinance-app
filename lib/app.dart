import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';

/// MacroFinance v2 — Root Application Widget
/// Riverpod-powered with light/dark theme support
class MacroFinanceApp extends ConsumerWidget {
  const MacroFinanceApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'MacroFinance',
      debugShowCheckedModeBanner: false,

      // Light-first with dark mode support
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,

      routerConfig: AppRouter.router,
    );
  }
}
