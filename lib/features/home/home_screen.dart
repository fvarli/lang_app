import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/models/content_models.dart';
import '../../core/state/app_state_scope.dart';
import '../../core/ui/module_card.dart';
import '../../core/ui/primary_button.dart';
import '../../core/ui/progress_bar.dart';
import '../../core/ui/stat_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final content = appState.content;

    if (!appState.isReady || content == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final modules = content.modules;
    final nextLessonId = _firstUnfinishedLessonId(
      content: content,
      level: appState.progress.selectedLevel,
      completedLessonIds: appState.progress.completedLessonIds,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Focus Board'),
        actions: [
          IconButton(
            onPressed: () => context.push(AppRoutes.settings),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 860;
          final statsWide = constraints.maxWidth >= 600;

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              Text('Today', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 6),
              Text(
                'Stay consistent with short focused sessions.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 14),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Today: ${appState.progress.completedLessonsToday} / ${appState.progress.dailyGoalMinutes}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const Spacer(),
                          Text(
                            '${(appState.progress.todayProgressRatio * 100).round()}%',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ProgressBar(value: appState.progress.todayProgressRatio),
                      const SizedBox(height: 14),
                      PrimaryButton(
                        label: nextLessonId == null
                            ? 'All lessons completed'
                            : 'Continue',
                        icon: nextLessonId == null
                            ? Icons.check_circle_outline
                            : Icons.play_arrow_rounded,
                        compact: true,
                        onPressed: nextLessonId == null
                            ? null
                            : () {
                                context.push(
                                  '${AppRoutes.lesson}?lesson=$nextLessonId',
                                );
                              },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: statsWide ? 3 : 1,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: statsWide ? 1.6 : 3.3,
                children: [
                  StatCard(
                    label: 'Level',
                    value: appState.progress.selectedLevel.name.toUpperCase(),
                    icon: Icons.school_outlined,
                  ),
                  StatCard(
                    label: 'Goal',
                    value: '${appState.progress.dailyGoalMinutes} min',
                    icon: Icons.timer_outlined,
                  ),
                  StatCard(
                    label: 'Streak',
                    value: '${appState.progress.streak} day',
                    icon: Icons.local_fire_department_outlined,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text('Modules', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 10),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: modules.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isWide ? 3 : 1,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: isWide ? 1.05 : 1.28,
                ),
                itemBuilder: (context, index) {
                  final module = modules[index];
                  final lessons = content.lessonsForLevelAndModule(
                    level: appState.progress.selectedLevel,
                    module: module.type,
                  );
                  final completed = lessons
                      .where(
                        (lesson) => appState.progress.completedLessonIds
                            .contains(lesson.id),
                      )
                      .length;
                  final percent = lessons.isEmpty
                      ? 0
                      : ((completed / lessons.length) * 100).round();

                  return ModuleCard(
                    module: module,
                    completedCount: completed,
                    totalCount: lessons.length,
                    progressPercent: percent,
                    onTap: () {
                      context.push(
                        '${AppRoutes.moduleList}?module=${module.id}',
                      );
                    },
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

String? _firstUnfinishedLessonId({
  required ContentBundle content,
  required Level level,
  required Set<String> completedLessonIds,
}) {
  for (final module in content.modules) {
    final lessons = content.lessonsForLevelAndModule(
      level: level,
      module: module.type,
    );
    for (final lesson in lessons) {
      if (!completedLessonIds.contains(lesson.id)) {
        return lesson.id;
      }
    }
  }
  return null;
}
