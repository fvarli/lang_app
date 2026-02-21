import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:lang_app/core/models/content_models.dart';

void main() {
  test('ContentBundle parses unified schema JSON', () {
    const raw = '''
    {
      "schemaVersion": 1,
      "levels": ["a1", "a2", "b1", "b2", "c1", "c2"],
      "modules": [
        {
          "id": "reading",
          "type": "reading",
          "title": "Reading",
          "description": "desc"
        },
        {
          "id": "listening",
          "type": "listening",
          "title": "Listening",
          "description": "desc"
        },
        {
          "id": "grammar",
          "type": "grammar",
          "title": "Grammar",
          "description": "desc"
        }
      ],
      "units": [
        {
          "id": "unit_reading_a1",
          "module": "reading",
          "level": "a1",
          "title": "Unit 1"
        }
      ],
      "lessons": [
        {
          "id": "reading_a1_1",
          "unitId": "unit_reading_a1",
          "module": "reading",
          "level": "a1",
          "title": "Lesson",
          "passageText": "Text",
          "questions": [
            {
              "id": "rq1",
              "type": "mcq",
              "prompt": "Prompt",
              "options": ["A", "B"],
              "correctIndex": 0
            }
          ]
        },
        {
          "id": "listening_a1_1",
          "module": "listening",
          "level": "a1",
          "title": "L1",
          "audioAsset": "assets/audio/l1.mp3",
          "questions": [
            {
              "id": "lq1",
              "type": "mcq",
              "prompt": "Prompt",
              "options": ["A", "B"],
              "correctIndex": 0
            }
          ]
        },
        {
          "id": "grammar_a1_1",
          "module": "grammar",
          "level": "a1",
          "title": "G1",
          "explanationMarkdown": "Use **am**",
          "examples": ["I am fine."],
          "questions": [
            {
              "id": "gq1",
              "type": "mcq",
              "prompt": "Prompt",
              "options": ["A", "B"],
              "correctIndex": 0
            }
          ]
        }
      ]
    }
    ''';

    final bundle = ContentBundle.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
    );

    expect(bundle.schemaVersion, 1);
    expect(bundle.levels, hasLength(6));
    expect(bundle.modules, hasLength(3));
    expect(bundle.units, hasLength(1));
    expect(bundle.lessons, hasLength(3));
    expect(bundle.lessons.first.module, ModuleType.reading);
    expect(bundle.lessons.first.level, Level.a1);
    expect(bundle.lessons.first.passageText, 'Text');
    expect(bundle.lessons.first.unitId, 'unit_reading_a1');
    expect(bundle.lessons.first.questions.first.options.first, 'A');
    expect(bundle.lessons[1].audioAsset, 'assets/audio/l1.mp3');
    expect(bundle.lessons[2].explanationMarkdown, 'Use **am**');
    expect(bundle.lessons[2].examples.first, 'I am fine.');
  });

  test('ContentBundle filters lessons by level and module', () {
    const raw = '''
    {
      "schemaVersion": 1,
      "levels": ["a1", "a2", "b1", "b2", "c1", "c2"],
      "modules": [
        {"id": "reading", "type": "reading", "title": "Reading", "description": "desc"},
        {"id": "grammar", "type": "grammar", "title": "Grammar", "description": "desc"}
      ],
      "units": [],
      "lessons": [
        {
          "id": "reading_a1_1",
          "module": "reading",
          "level": "a1",
          "title": "R1",
          "passageText": "Text",
          "questions": [{"id": "q1", "type": "mcq", "prompt": "Prompt", "options": ["A", "B"], "correctIndex": 0}]
        },
        {
          "id": "reading_b1_1",
          "module": "reading",
          "level": "b1",
          "title": "R2",
          "passageText": "Text",
          "questions": [{"id": "q2", "type": "mcq", "prompt": "Prompt", "options": ["A", "B"], "correctIndex": 0}]
        },
        {
          "id": "grammar_a1_1",
          "module": "grammar",
          "level": "a1",
          "title": "G1",
          "explanationMarkdown": "x",
          "examples": ["e1"],
          "questions": [{"id": "q3", "type": "mcq", "prompt": "Prompt", "options": ["A", "B"], "correctIndex": 0}]
        }
      ]
    }
    ''';

    final bundle = ContentBundle.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
    );

    final readingA1 = bundle.lessonsForLevelAndModule(
      level: Level.a1,
      module: ModuleType.reading,
    );
    final grammarA1 = bundle.lessonsForLevelAndModule(
      level: Level.a1,
      module: ModuleType.grammar,
    );

    expect(readingA1, hasLength(1));
    expect(readingA1.first.id, 'reading_a1_1');
    expect(grammarA1, hasLength(1));
    expect(grammarA1.first.id, 'grammar_a1_1');
  });

  test('ContentBundle fails with clear message on duplicate lesson IDs', () {
    const raw = '''
    {
      "schemaVersion": 1,
      "levels": ["a1", "a2", "b1", "b2", "c1", "c2"],
      "modules": [
        {"id": "reading", "type": "reading", "title": "Reading", "description": "desc"}
      ],
      "units": [],
      "lessons": [
        {
          "id": "same_id",
          "module": "reading",
          "level": "a1",
          "title": "L1",
          "passageText": "Text",
          "questions": [{"id": "q1", "type": "mcq", "prompt": "Prompt", "options": ["A", "B"], "correctIndex": 0}]
        },
        {
          "id": "same_id",
          "module": "reading",
          "level": "a1",
          "title": "L2",
          "passageText": "Text",
          "questions": [{"id": "q2", "type": "mcq", "prompt": "Prompt", "options": ["A", "B"], "correctIndex": 0}]
        }
      ]
    }
    ''';

    expect(
      () => ContentBundle.fromJson(jsonDecode(raw) as Map<String, dynamic>),
      throwsA(
        isA<ContentValidationException>().having(
          (e) => e.message,
          'message',
          contains('Duplicate lesson id'),
        ),
      ),
    );
  });

  test('ContentBundle fails when schemaVersion is missing', () {
    const raw = '''
    {
      "levels": ["a1", "a2", "b1", "b2", "c1", "c2"],
      "modules": [],
      "lessons": []
    }
    ''';

    expect(
      () => ContentBundle.fromJson(jsonDecode(raw) as Map<String, dynamic>),
      throwsA(isA<ContentValidationException>()),
    );
  });
}
