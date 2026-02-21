import 'package:flutter/material.dart';

import '../core/state/app_state_scope.dart';
import '../core/theme/app_theme.dart';
import 'router.dart';

class LangApp extends StatelessWidget {
  const LangApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppStateScope(
      child: Builder(
        builder: (context) {
          final appState = AppStateScope.of(context);
          return AnimatedBuilder(
            animation: appState,
            builder: (context, _) {
              return MaterialApp.router(
                debugShowCheckedModeBanner: false,
                title: 'Lang App',
                theme: AppTheme.light,
                darkTheme: AppTheme.dark,
                themeMode: appState.themeMode,
                routerConfig: buildRouter(),
              );
            },
          );
        },
      ),
    );
  }
}
