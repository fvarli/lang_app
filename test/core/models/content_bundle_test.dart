import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:lang_app/core/models/content_models.dart';

void main() {
  test('ContentBundle parses module and lesson JSON', () {
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
      "lessons": [
        {
          "id": "reading_a1_1",
          "module": "reading",
          "level": "a1",
          "title": "Lesson",
          "content": "Text",
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
    expect(bundle.lessons, hasLength(1));
    expect(bundle.lessons.first.module, ModuleType.reading);
    expect(bundle.lessons.first.level, Level.a1);
    expect(bundle.lessons.first.questions.first.options.first, 'A');
  });
}
