import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/models/content_models.dart';
import '../../core/state/app_state_scope.dart';

class LessonScreen extends StatefulWidget {
  const LessonScreen({super.key, required this.lessonId});

  final String lessonId;

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  int _questionIndex = 0;
  int _score = 0;
  int? _selected;

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final content = appState.content;

    if (!appState.isReady || content == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final lesson = content.lessons.where((e) => e.id == widget.lessonId).first;
    final question = lesson.questions[_questionIndex];

    return Scaffold(
      appBar: AppBar(title: Text(lesson.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(lesson.module.name.toUpperCase()),
                  const SizedBox(height: 8),
                  ..._buildLessonContent(context: context, lesson: lesson),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Question ${_questionIndex + 1}/${lesson.questions.length}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(question.prompt),
                  const SizedBox(height: 10),
                  for (var i = 0; i < question.options.length; i++)
                    Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        onTap: () => setState(() => _selected = i),
                        leading: Icon(
                          _selected == i
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                        ),
                        title: Text(question.options[i]),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          FilledButton(
            onPressed: _selected == null
                ? null
                : () async {
                    if (_selected == question.correctIndex) {
                      _score += 1;
                    }

                    if (_questionIndex < lesson.questions.length - 1) {
                      setState(() {
                        _questionIndex += 1;
                        _selected = null;
                      });
                      return;
                    }

                    await appState.completeLesson(lesson.id);
                    if (!context.mounted) {
                      return;
                    }
                    context.go(
                      '${AppRoutes.result}?score=$_score&total=${lesson.questions.length}&module=${lesson.module.name}',
                    );
                  },
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(54),
            ),
            child: Text(
              _questionIndex < lesson.questions.length - 1
                  ? 'Next Question'
                  : 'Finish Lesson',
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildLessonContent({
    required BuildContext context,
    required Lesson lesson,
  }) {
    switch (lesson.module) {
      case ModuleType.reading:
        return [
          Text(
            lesson.passageText ?? 'No passage text available.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ];
      case ModuleType.listening:
        return [
          if (lesson.passageText != null)
            Text(
              lesson.passageText!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          if (lesson.audioAsset != null) ...[
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.audiotrack),
              title: Text('Audio placeholder: ${lesson.audioAsset}'),
            ),
          ],
        ];
      case ModuleType.grammar:
        return [
          Text(
            lesson.explanationMarkdown ?? 'No explanation available.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (lesson.examples.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text('Examples', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            for (final example in lesson.examples)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('• $example'),
              ),
          ],
        ];
    }
  }
}
