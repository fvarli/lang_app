import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/models/content_models.dart';
import '../../core/state/app_state_scope.dart';

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

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 580),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Lesson Complete',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '$score / $total',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 4),
                      Text('$pct% accuracy'),
                      const SizedBox(height: 18),
                      FilledButton(
                        onPressed: () {
                          if (module == null || module.isEmpty) {
                            context.go(AppRoutes.home);
                            return;
                          }
                          context.go('${AppRoutes.moduleList}?module=$module');
                        },
                        child: const Text('Back to Module'),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton(
                        onPressed: () {
                          if (module == null || module.isEmpty) {
                            context.go(AppRoutes.home);
                            return;
                          }
                          if (nextLessonId != null) {
                            context.go(
                              '${AppRoutes.lesson}?lesson=$nextLessonId',
                            );
                            return;
                          }
                          context.go('${AppRoutes.moduleList}?module=$module');
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

  ModuleType? moduleType;
  for (final candidate in ModuleType.values) {
    if (candidate.name == moduleId) {
      moduleType = candidate;
      break;
    }
  }
  if (moduleType == null) {
    return null;
  }

  final lessons = content.lessonsForLevelAndModule(
    level: level,
    module: moduleType,
  );

  for (var i = 0; i < lessons.length; i++) {
    if (lessons[i].id == currentLessonId && i + 1 < lessons.length) {
      return lessons[i + 1].id;
    }
  }
  return null;
}
