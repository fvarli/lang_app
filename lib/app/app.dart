import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/state/app_state_scope.dart';
import '../core/theme/app_theme.dart';
import 'router.dart';

class LangApp extends StatelessWidget {
  const LangApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppStateScope(child: const _AppRouterHost());
  }
}

class _AppRouterHost extends StatefulWidget {
  const _AppRouterHost();

  @override
  State<_AppRouterHost> createState() => _AppRouterHostState();
}

class _AppRouterHostState extends State<_AppRouterHost> {
  GoRouter? _router;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _router ??= buildRouter(AppStateScope.of(context));
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final router = _router;
    if (router == null) {
      return const SizedBox.shrink();
    }
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'LangRoutine',
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: appState.themeMode,
          routerConfig: router,
        );
      },
    );
  }
}
