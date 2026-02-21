import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/state/app_state_scope.dart';
import 'widgets/lesson_player.dart';

class LessonScreen extends StatelessWidget {
  const LessonScreen({super.key, required this.lessonId});

  final String lessonId;

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final content = appState.content;

    if (!appState.isReady || content == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final lesson = content.lessons.where((e) => e.id == lessonId).first;

    return Scaffold(
      appBar: AppBar(title: Text(lesson.title)),
      body: LessonPlayer(
        lesson: lesson,
        onCompleted: (result) async {
          await appState.completeLesson(result.lessonId);
          if (!context.mounted) {
            return;
          }
          context.go(
            '${AppRoutes.result}?score=${result.score}&total=${result.total}&module=${result.moduleName}&lesson=${result.lessonId}',
          );
        },
      ),
    );
  }
}
