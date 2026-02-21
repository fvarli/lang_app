import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/state/app_state_scope.dart';

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

    final selectedModule = content.modules.where((m) => m.id == moduleId).first;
    final lessons = content.lessons
        .where(
          (lesson) =>
              lesson.module.name == moduleId &&
              lesson.level.index <= state.progress.selectedLevel.index,
        )
        .toList(growable: false);

    return Scaffold(
      appBar: AppBar(title: Text(selectedModule.title)),
      body: ListView.builder(
        itemCount: lessons.length,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final lesson = lessons[index];
          final done = state.progress.completedLessonIds.contains(lesson.id);
          return Card(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: CircleAvatar(child: Text('${index + 1}')),
              title: Text(lesson.title),
              subtitle: Text('Level ${lesson.level.name.toUpperCase()}'),
              trailing: Icon(done ? Icons.check_circle : Icons.play_circle),
              onTap: () =>
                  context.push('${AppRoutes.lesson}?lesson=${lesson.id}'),
            ),
          );
        },
      ),
    );
  }
}
