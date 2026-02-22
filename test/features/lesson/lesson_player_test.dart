import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lang_app/core/models/content_models.dart';
import 'package:lang_app/features/lesson/widgets/lesson_player.dart';

Widget _wrap(Widget child) {
  return MaterialApp(home: Scaffold(body: child));
}

Question _question({required int correctIndex}) {
  return Question(
    id: 'q1',
    type: QuestionType.mcq,
    prompt: 'Pick one',
    options: const ['A', 'B'],
    correctIndex: correctIndex,
  );
}

void main() {
  testWidgets('Reading lesson shows passage and completes with payload', (
    tester,
  ) async {
    LessonResultPayload? result;

    final lesson = Lesson(
      id: 'reading1',
      unitId: 'u1',
      module: ModuleType.reading,
      level: Level.a1,
      title: 'Reading',
      passageText: 'Short passage text.',
      audioAsset: null,
      explanationMarkdown: null,
      examples: const [],
      questions: [_question(correctIndex: 0)],
    );

    await tester.pumpWidget(
      _wrap(
        LessonPlayer(
          lesson: lesson,
          onCompleted: (payload) {
            result = payload;
          },
        ),
      ),
    );

    expect(find.text('Short passage text.'), findsOneWidget);
    await tester.tap(find.widgetWithText(InkWell, 'A'));
    await tester.pump();
    await tester.tap(find.text('Check Answer'));
    await tester.pump();
    await tester.tap(find.text('Finish Lesson'));
    await tester.pump();

    expect(result, isNotNull);
    expect(result!.lessonId, 'reading1');
    expect(result!.score, 1);
    expect(result!.total, 1);
  });

  testWidgets('Listening lesson with audio toggles play and pause', (
    tester,
  ) async {
    final lesson = Lesson(
      id: 'listening1',
      unitId: 'u1',
      module: ModuleType.listening,
      level: Level.a1,
      title: 'Listening',
      passageText: 'Listen and answer.',
      audioAsset: 'assets/audio/x.mp3',
      explanationMarkdown: null,
      examples: const [],
      questions: [_question(correctIndex: 0)],
    );

    await tester.pumpWidget(
      _wrap(LessonPlayer(lesson: lesson, onCompleted: (_) {})),
    );

    expect(find.text('Paused'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.play_circle));
    await tester.pump();
    expect(find.text('Playing (placeholder)'), findsOneWidget);
  });

  testWidgets('Listening lesson without audio shows disabled note', (
    tester,
  ) async {
    final lesson = Lesson(
      id: 'listening2',
      unitId: 'u1',
      module: ModuleType.listening,
      level: Level.a1,
      title: 'Listening',
      passageText: 'Listen and answer.',
      audioAsset: null,
      explanationMarkdown: null,
      examples: const [],
      questions: [_question(correctIndex: 0)],
    );

    await tester.pumpWidget(
      _wrap(LessonPlayer(lesson: lesson, onCompleted: (_) {})),
    );

    expect(
      find.text('Audio not available for this lesson yet.'),
      findsOneWidget,
    );
    expect(find.text('Playback is disabled for now.'), findsOneWidget);
  });

  testWidgets('Grammar lesson renders markdown and examples', (tester) async {
    final lesson = Lesson(
      id: 'grammar1',
      unitId: 'u1',
      module: ModuleType.grammar,
      level: Level.a1,
      title: 'Grammar',
      passageText: null,
      audioAsset: null,
      explanationMarkdown: 'Use **am** with I.',
      examples: const ['I am ready.', 'You are ready.'],
      questions: [_question(correctIndex: 0)],
    );

    await tester.pumpWidget(
      _wrap(LessonPlayer(lesson: lesson, onCompleted: (_) {})),
    );

    expect(find.textContaining('Use'), findsOneWidget);
    expect(find.text('Examples'), findsOneWidget);
    expect(find.text('• I am ready.'), findsOneWidget);
    expect(find.text('• You are ready.'), findsOneWidget);
  });
}
