import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/state/app_state_scope.dart';
import '../../core/ui/module_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);

    if (!appState.isReady || appState.content == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final modules = appState.content!.modules;

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
          final isWide = constraints.maxWidth >= 820;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'Welcome back',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 6),
              Text(
                'Your daily progress and lesson modules',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 14),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      Expanded(
                        child: _StatTile(
                          label: 'Level',
                          value: appState.progress.selectedLevel.name
                              .toUpperCase(),
                        ),
                      ),
                      Expanded(
                        child: _StatTile(
                          label: 'Goal',
                          value: '${appState.progress.dailyGoalMinutes} min',
                        ),
                      ),
                      Expanded(
                        child: _StatTile(
                          label: 'Streak',
                          value: '${appState.progress.streak} day',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Today: ${appState.progress.completedLessonsToday} / ${appState.progress.dailyGoalMinutes}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: appState.progress.todayProgressRatio,
                          minHeight: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: modules.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isWide ? 3 : 1,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: isWide ? 1.1 : 1.35,
                ),
                itemBuilder: (context, index) {
                  final module = modules[index];
                  final lessons = appState.content!.lessonsForLevelAndModule(
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

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(value, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}
