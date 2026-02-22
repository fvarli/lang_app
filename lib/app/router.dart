import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/state/app_state.dart';
import '../features/home/home_screen.dart';
import '../features/lesson/lesson_screen.dart';
import '../features/module_list/module_list_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/result/result_screen.dart';
import '../features/settings/settings_screen.dart';

class AppRoutes {
  static const onboarding = '/onboarding';
  static const home = '/';
  static const moduleList = '/modules';
  static const lesson = '/lesson';
  static const result = '/result';
  static const settings = '/settings';
}

GoRouter buildRouter(AppState appState) {
  return GoRouter(
    initialLocation: AppRoutes.onboarding,
    refreshListenable: appState,
    redirect: (context, state) {
      if (!appState.isReady) {
        return null;
      }
      final onOnboarding = state.uri.path == AppRoutes.onboarding;
      if (!appState.hasCompletedOnboarding && !onOnboarding) {
        return AppRoutes.onboarding;
      }
      if (appState.hasCompletedOnboarding && onOnboarding) {
        return AppRoutes.home;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.moduleList,
        builder: (context, state) {
          final module = state.uri.queryParameters['module'];
          if (module == null || module.isEmpty) {
            return const _RouteErrorScreen(message: 'Module is required.');
          }
          return ModuleListScreen(moduleId: module);
        },
      ),
      GoRoute(
        path: AppRoutes.lesson,
        builder: (context, state) {
          final lessonId = state.uri.queryParameters['lesson'];
          if (lessonId == null || lessonId.isEmpty) {
            return const _RouteErrorScreen(message: 'Lesson id is required.');
          }
          return LessonScreen(lessonId: lessonId);
        },
      ),
      GoRoute(
        path: AppRoutes.result,
        builder: (context, state) => const ResultScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
}

class _RouteErrorScreen extends StatelessWidget {
  const _RouteErrorScreen({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text(message)));
  }
}
