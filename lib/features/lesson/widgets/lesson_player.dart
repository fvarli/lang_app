import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../../core/models/content_models.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/ui/lesson_content_card.dart';
import '../../../core/ui/primary_button.dart';

class LessonResultPayload {
  const LessonResultPayload({
    required this.lessonId,
    required this.moduleName,
    required this.score,
    required this.total,
  });

  final String lessonId;
  final String moduleName;
  final int score;
  final int total;
}

class LessonPlayer extends StatefulWidget {
  const LessonPlayer({
    super.key,
    required this.lesson,
    required this.onCompleted,
  });

  final Lesson lesson;
  final ValueChanged<LessonResultPayload> onCompleted;

  @override
  State<LessonPlayer> createState() => _LessonPlayerState();
}

class _LessonPlayerState extends State<LessonPlayer> {
  int _questionIndex = 0;
  int _score = 0;
  int? _selected;
  bool _isPlaying = false;

  @override
  Widget build(BuildContext context) {
    final lesson = widget.lesson;
    final question = lesson.questions[_questionIndex];
    final scheme = Theme.of(context).colorScheme;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            LessonContentCard(
              moduleLabel: lesson.module.name,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _buildLessonContent(context: context, lesson: lesson),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Question ${_questionIndex + 1}/${lesson.questions.length}',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 10),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(question.prompt),
                    const SizedBox(height: 10),
                    for (var i = 0; i < question.options.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: Material(
                          color: _selected == i
                              ? scheme.primaryContainer
                              : scheme.surfaceContainerHighest,
                          borderRadius: AppRadius.mdAll,
                          child: InkWell(
                            borderRadius: AppRadius.mdAll,
                            onTap: () => setState(() => _selected = i),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.lg,
                                vertical: 14,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    _selected == i
                                        ? Icons.radio_button_checked
                                        : Icons.radio_button_off,
                                    color: _selected == i
                                        ? scheme.primary
                                        : scheme.outline,
                                    size: 20,
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                  Expanded(child: Text(question.options[i])),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            PrimaryButton(
              label: _questionIndex < lesson.questions.length - 1
                  ? 'Next Question'
                  : 'Finish Lesson',
              onPressed: _selected == null
                  ? null
                  : () {
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

                      widget.onCompleted(
                        LessonResultPayload(
                          lessonId: lesson.id,
                          moduleName: lesson.module.name,
                          score: _score,
                          total: lesson.questions.length,
                        ),
                      );
                    },
            ),
          ],
        ),
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
        final hasAudio =
            lesson.audioAsset != null && lesson.audioAsset!.isNotEmpty;
        return [
          if (lesson.passageText != null)
            Text(
              lesson.passageText!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          const SizedBox(height: AppSpacing.md),
          Card(
            margin: EdgeInsets.zero,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              leading: IconButton(
                onPressed: hasAudio
                    ? () => setState(() => _isPlaying = !_isPlaying)
                    : null,
                icon: Icon(_isPlaying ? Icons.pause_circle : Icons.play_circle),
              ),
              title: Text(
                hasAudio
                    ? 'Audio placeholder: ${lesson.audioAsset}'
                    : 'Audio not available for this lesson yet.',
              ),
              subtitle: Text(
                hasAudio
                    ? (_isPlaying ? 'Playing (placeholder)' : 'Paused')
                    : 'Playback is disabled for now.',
              ),
            ),
          ),
        ];
      case ModuleType.grammar:
        return [
          if (lesson.explanationMarkdown != null)
            MarkdownBody(data: lesson.explanationMarkdown!)
          else
            Text(
              'No explanation available.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          if (lesson.examples.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text('Examples', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            for (final example in lesson.examples)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: Text('• $example'),
              ),
          ],
        ];
    }
  }
}
