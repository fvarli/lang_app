# Content Format (MVP)

This project uses `assets/content/mvp_content.json` as the single offline content source.

## Root schema

```json
{
  "schemaVersion": 1,
  "levels": ["a1", "a2", "b1", "b2", "c1", "c2"],
  "modules": [],
  "units": [],
  "lessons": []
}
```

## Rules

- `schemaVersion` is required and must be `1`.
- IDs must be stable and unique:
  - levels (unique names)
  - `module.id`
  - `unit.id`
  - `lesson.id`
  - `question.id` (global uniqueness)
- `lesson.module` and `lesson.level` must exist in root lists.
- If `lesson.unitId` is set, the unit must exist and match lesson module+level.
- Question rules:
  - `options` length >= 2
  - `correctIndex` in options range
  - `true_false` type must have exactly 2 options

## Entity examples

### Module

```json
{ "id": "reading", "type": "reading", "title": "Reading", "description": "..." }
```

### Unit

```json
{ "id": "unit_reading_a1_basics", "module": "reading", "level": "a1", "title": "Everyday Signs" }
```

### Reading lesson

```json
{
  "id": "reading_a1_signs_1",
  "unitId": "unit_reading_a1_basics",
  "module": "reading",
  "level": "a1",
  "title": "Cafe Opening Times",
  "passageText": "Sign text...",
  "questions": []
}
```

### Listening lesson

```json
{
  "id": "listening_a1_station_1",
  "unitId": "unit_listening_a1_basics",
  "module": "listening",
  "level": "a1",
  "title": "Train Platform Announcement",
  "passageText": "Listen and answer.",
  "audioAsset": "assets/audio/listening_a1_station_1.mp3",
  "questions": []
}
```

### Grammar lesson

```json
{
  "id": "grammar_a1_be_1",
  "unitId": "unit_grammar_a1_basics",
  "module": "grammar",
  "level": "a1",
  "title": "Verb To Be",
  "explanationMarkdown": "Use **am**...",
  "examples": ["I am..."],
  "questions": []
}
```

## Quick workflow to add lessons

1. Duplicate a lesson object in the same module/unit.
2. Create a new stable lesson ID (do not rename old IDs).
3. Create new globally unique question IDs.
4. Keep each lesson 2–3 questions for MVP consistency.
5. Run validation:

```bash
dart run tool/validate_content.dart
flutter test
```
