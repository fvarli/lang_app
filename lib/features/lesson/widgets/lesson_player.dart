import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../../core/models/content_models.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/ui/answer_tile.dart';
import '../../../core/ui/lesson_content_card.dart';
import '../../../core/ui/primary_button.dart';
import '../../../core/ui/question_stepper.dart';

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
  bool _revealed = false;
  final Set<int> _completedSteps = {};

  AnswerTileState _computeTileState(int index, Question question) {
    if (!_revealed) {
      if (_selected == index) return AnswerTileState.selected;
      return AnswerTileState.idle;
    }
    if (_selected == index) {
      return index == question.correctIndex
          ? AnswerTileState.correct
          : AnswerTileState.incorrect;
    }
    return AnswerTileState.idle;
  }

  bool _shouldShowCorrectHighlight(int index, Question question) {
    if (!_revealed) return false;
    if (_selected == question.correctIndex) return false;
    return index == question.correctIndex;
  }

  void _checkAnswer(Question question) {
    setState(() {
      _revealed = true;
      if (_selected == question.correctIndex) {
        _score += 1;
      }
      _completedSteps.add(_questionIndex);
    });
  }

  void _advance() {
    final lesson = widget.lesson;
    if (_questionIndex < lesson.questions.length - 1) {
      setState(() {
        _questionIndex += 1;
        _selected = null;
        _revealed = false;
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
  }

  @override
  Widget build(BuildContext context) {
    final lesson = widget.lesson;
    final question = lesson.questions[_questionIndex];
    final scheme = Theme.of(context).colorScheme;
    final isLastQuestion = _questionIndex >= lesson.questions.length - 1;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            QuestionStepper(
              totalSteps: lesson.questions.length,
              currentStep: _questionIndex,
              completedSteps: _completedSteps,
            ),
            const SizedBox(height: AppSpacing.md),
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
                      AnswerTile(
                        label: question.options[i],
                        state: _computeTileState(i, question),
                        showCorrectHighlight: _shouldShowCorrectHighlight(
                          i,
                          question,
                        ),
                        onTap: _revealed
                            ? null
                            : () => setState(() => _selected = i),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            PrimaryButton(
              label: _revealed
                  ? (isLastQuestion ? 'Finish Lesson' : 'Next Question')
                  : 'Check Answer',
              onPressed: _selected == null
                  ? null
                  : () {
                      if (!_revealed) {
                        _checkAnswer(question);
                        return;
                      }
                      _advance();
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
