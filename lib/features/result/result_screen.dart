import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/models/content_models.dart';
import '../../core/state/app_state_scope.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/ui/score_ring.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final content = appState.content;
    final uri = GoRouterState.of(context).uri;
    final score = int.tryParse(uri.queryParameters['score'] ?? '0') ?? 0;
    final total = int.tryParse(uri.queryParameters['total'] ?? '0') ?? 0;
    final module = uri.queryParameters['module'];
    final lessonId = uri.queryParameters['lesson'];
    final pct = total == 0 ? 0 : ((score / total) * 100).round();
    final nextLessonId = _nextLessonId(
      content: content,
      level: appState.progress.selectedLevel,
      moduleId: module,
      currentLessonId: lessonId,
    );

    String performanceMessage;
    if (pct >= 90) {
      performanceMessage = 'Excellent!';
    } else if (pct >= 80) {
      performanceMessage = 'Great work!';
    } else if (pct >= 60) {
      performanceMessage = 'Good effort!';
    } else {
      performanceMessage = 'Keep practicing!';
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }
        _goToModuleOrHome(context: context, moduleId: module);
      },
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 580),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xxl),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xxl),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Lesson Complete',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        ScoreRing(score: score, total: total),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          performanceMessage,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        FilledButton(
                          onPressed: () {
                            _goToModuleOrHome(
                              context: context,
                              moduleId: module,
                            );
                          },
                          child: const Text('Back to Module'),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        OutlinedButton(
                          onPressed: () {
                            if (nextLessonId != null) {
                              context.go(
                                '${AppRoutes.lesson}?lesson=$nextLessonId',
                              );
                              return;
                            }
                            _goToModuleOrHome(
                              context: context,
                              moduleId: module,
                            );
                          },
                          child: const Text('Continue'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? _nextLessonId({
    required ContentBundle? content,
    required Level level,
    required String? moduleId,
    required String? currentLessonId,
  }) {
    return nextLessonIdForModule(
      content: content,
      level: level,
      moduleId: moduleId,
      currentLessonId: currentLessonId,
    );
  }
}

void _goToModuleOrHome({
  required BuildContext context,
  required String? moduleId,
}) {
  if (moduleId == null || moduleId.isEmpty) {
    context.go(AppRoutes.home);
    return;
  }
  context.go('${AppRoutes.moduleList}?module=$moduleId');
}

String? nextLessonIdForModule({
  required ContentBundle? content,
  required Level level,
  required String? moduleId,
  required String? currentLessonId,
}) {
  if (content == null ||
      moduleId == null ||
      moduleId.isEmpty ||
      currentLessonId == null ||
      currentLessonId.isEmpty) {
    return null;
  }

  final lessons = content.lessonsForLevelAndModuleId(
    level: level,
    moduleId: moduleId,
  );

  for (var i = 0; i < lessons.length; i++) {
    if (lessons[i].id == currentLessonId && i + 1 < lessons.length) {
      return lessons[i + 1].id;
    }
  }
  return null;
}
