import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:lang_app/core/models/content_models.dart';

void main() {
  test('ContentBundle parses unified schema JSON', () {
    const raw = '''
    {
      "modules": [
        {
          "id": "reading",
          "type": "reading",
          "title": "Reading",
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
              "id": "q1",
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

    expect(bundle.modules, hasLength(1));
    expect(bundle.units, hasLength(1));
    expect(bundle.lessons, hasLength(1));
    expect(bundle.lessons.first.module, ModuleType.reading);
    expect(bundle.lessons.first.level, Level.a1);
    expect(bundle.lessons.first.passageText, 'Text');
    expect(bundle.lessons.first.unitId, 'unit_reading_a1');
    expect(bundle.lessons.first.questions.first.options.first, 'A');
  });

  test('ContentBundle filters lessons by level and module', () {
    const raw = '''
    {
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
          "questions": [{"id": "q1", "type": "mcq", "prompt": "Prompt", "options": ["A", "B"], "correctIndex": 0}]
        },
        {
          "id": "grammar_a1_1",
          "module": "grammar",
          "level": "a1",
          "title": "G1",
          "explanationMarkdown": "x",
          "examples": ["e1"],
          "questions": [{"id": "q1", "type": "mcq", "prompt": "Prompt", "options": ["A", "B"], "correctIndex": 0}]
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
}
