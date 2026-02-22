import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/models/content_models.dart';
import '../../core/state/app_state_scope.dart';
import '../../core/theme/design_tokens.dart';

class ModuleListScreen extends StatelessWidget {
  const ModuleListScreen({super.key, required this.moduleId});

  final String moduleId;

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final content = state.content;

    if (!state.isReady || content == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final selectedModule = content.moduleById(moduleId);
    if (selectedModule == null) {
      return const Scaffold(
        body: Center(child: Text('Module not found for this route.')),
      );
    }
    final lessons = content.lessonsForLevelAndModuleId(
      level: state.progress.selectedLevel,
      moduleId: moduleId,
    );
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(selectedModule.title)),
      body: ListView.builder(
        itemCount: lessons.length,
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.xxl,
        ),
        itemBuilder: (context, index) {
          final lesson = lessons[index];
          final done = state.progress.completedLessonIds.contains(lesson.id);
          return Card(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              leading: CircleAvatar(
                backgroundColor: scheme.primaryContainer,
                foregroundColor: scheme.primary,
                child: Text('${index + 1}'),
              ),
              title: Text(lesson.title),
              subtitle: Text(
                _subtitleForLesson(content: content, lesson: lesson),
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    done ? Icons.check_circle : Icons.play_circle,
                    color: done ? AppColors.success : null,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  if (done)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'Completed',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.success,
                        ),
                      ),
                    ),
                ],
              ),
              onTap: () =>
                  context.push('${AppRoutes.lesson}?lesson=${lesson.id}'),
            ),
          );
        },
      ),
    );
  }

  String _subtitleForLesson({
    required ContentBundle content,
    required Lesson lesson,
  }) {
    Unit? unit;
    for (final candidate in content.units) {
      if (candidate.id == lesson.unitId) {
        unit = candidate;
        break;
      }
    }
    if (unit == null) {
      return 'Level ${lesson.level.name.toUpperCase()}';
    }
    return '${unit.title} • ${lesson.level.name.toUpperCase()}';
  }
}
