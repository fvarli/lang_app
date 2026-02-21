import 'package:flutter_test/flutter_test.dart';
import 'package:lang_app/core/models/content_models.dart';
import 'package:lang_app/features/result/result_screen.dart';

void main() {
  test(
    'nextLessonIdForModule returns next lesson in same module and level',
    () {
      const content = ContentBundle(
        schemaVersion: 1,
        levels: [Level.a1, Level.a2, Level.b1, Level.b2, Level.c1, Level.c2],
        modules: [
          Module(
            id: 'reading',
            type: ModuleType.reading,
            title: 'Reading',
            description: 'desc',
          ),
        ],
        units: [],
        lessons: [
          Lesson(
            id: 'l1',
            unitId: null,
            module: ModuleType.reading,
            level: Level.a1,
            title: 'L1',
            passageText: 'text',
            audioAsset: null,
            explanationMarkdown: null,
            examples: [],
            questions: [
              Question(
                id: 'q1',
                type: QuestionType.mcq,
                prompt: 'p',
                options: ['a', 'b'],
                correctIndex: 0,
              ),
            ],
          ),
          Lesson(
            id: 'l2',
            unitId: null,
            module: ModuleType.reading,
            level: Level.a1,
            title: 'L2',
            passageText: 'text',
            audioAsset: null,
            explanationMarkdown: null,
            examples: [],
            questions: [
              Question(
                id: 'q2',
                type: QuestionType.mcq,
                prompt: 'p',
                options: ['a', 'b'],
                correctIndex: 0,
              ),
            ],
          ),
        ],
      );

      final next = nextLessonIdForModule(
        content: content,
        level: Level.a1,
        moduleId: 'reading',
        currentLessonId: 'l1',
      );

      expect(next, 'l2');
    },
  );

  test('nextLessonIdForModule returns null on last lesson', () {
    const content = ContentBundle(
      schemaVersion: 1,
      levels: [Level.a1, Level.a2, Level.b1, Level.b2, Level.c1, Level.c2],
      modules: [
        Module(
          id: 'reading',
          type: ModuleType.reading,
          title: 'Reading',
          description: 'desc',
        ),
      ],
      units: [],
      lessons: [
        Lesson(
          id: 'l1',
          unitId: null,
          module: ModuleType.reading,
          level: Level.a1,
          title: 'L1',
          passageText: 'text',
          audioAsset: null,
          explanationMarkdown: null,
          examples: [],
          questions: [
            Question(
              id: 'q1',
              type: QuestionType.mcq,
              prompt: 'p',
              options: ['a', 'b'],
              correctIndex: 0,
            ),
          ],
        ),
      ],
    );

    final next = nextLessonIdForModule(
      content: content,
      level: Level.a1,
      moduleId: 'reading',
      currentLessonId: 'l1',
    );

    expect(next, isNull);
  });
}
