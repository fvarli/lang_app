class ContentValidationException implements Exception {
  ContentValidationException(this.message);

  final String message;

  @override
  String toString() => 'ContentValidationException: $message';
}

enum Level { a1, a2, b1, b2, c1, c2 }

enum ModuleType { reading, listening, grammar }

enum QuestionType { mcq, trueFalse }

class Question {
  const Question({
    required this.id,
    required this.type,
    required this.prompt,
    required this.options,
    required this.correctIndex,
  });

  final String id;
  final QuestionType type;
  final String prompt;
  final List<String> options;
  final int correctIndex;

  factory Question.fromJson(
    Map<String, dynamic> json, {
    required String context,
  }) {
    final id = _requireString(json, 'id', context);
    final typeRaw = _requireString(json, 'type', '$context($id)');
    final prompt = _requireString(json, 'prompt', '$context($id)');
    final options = _requireStringList(json, 'options', '$context($id)');
    final correctIndex = _requireInt(json, 'correctIndex', '$context($id)');

    if (options.length < 2) {
      throw ContentValidationException(
        '$context($id).options must contain at least 2 values',
      );
    }
    if (correctIndex < 0 || correctIndex >= options.length) {
      throw ContentValidationException(
        '$context($id).correctIndex out of range for options length ${options.length}',
      );
    }

    final type = _questionTypeFromJson(typeRaw, '$context($id).type');
    if (type == QuestionType.trueFalse && options.length != 2) {
      throw ContentValidationException(
        '$context($id) true_false questions must provide exactly 2 options',
      );
    }

    return Question(
      id: id,
      type: type,
      prompt: prompt,
      options: options,
      correctIndex: correctIndex,
    );
  }
}

class Lesson {
  const Lesson({
    required this.id,
    required this.unitId,
    required this.module,
    required this.level,
    required this.title,
    required this.passageText,
    required this.audioAsset,
    required this.explanationMarkdown,
    required this.examples,
    required this.questions,
  });

  final String id;
  final String? unitId;
  final ModuleType module;
  final Level level;
  final String title;
  final String? passageText;
  final String? audioAsset;
  final String? explanationMarkdown;
  final List<String> examples;
  final List<Question> questions;

  factory Lesson.fromJson(
    Map<String, dynamic> json, {
    required String context,
  }) {
    final id = _requireString(json, 'id', context);
    final moduleRaw = _requireString(json, 'module', '$context($id)');
    final levelRaw = _requireString(json, 'level', '$context($id)');

    final questionsRaw = _requireList(json, 'questions', '$context($id)');
    final parsedQuestions = <Question>[];
    for (var i = 0; i < questionsRaw.length; i++) {
      final entry = questionsRaw[i];
      if (entry is! Map<String, dynamic>) {
        throw ContentValidationException(
          '$context($id).questions[$i] must be an object',
        );
      }
      parsedQuestions.add(
        Question.fromJson(entry, context: '$context($id).question'),
      );
    }

    return Lesson(
      id: id,
      unitId: _optionalString(json, 'unitId', '$context($id)'),
      module: _moduleTypeFromJson(moduleRaw, '$context($id).module'),
      level: _levelFromJson(levelRaw, '$context($id).level'),
      title: _requireString(json, 'title', '$context($id)'),
      passageText: _optionalString(json, 'passageText', '$context($id)'),
      audioAsset: _optionalString(json, 'audioAsset', '$context($id)'),
      explanationMarkdown: _optionalString(
        json,
        'explanationMarkdown',
        '$context($id)',
      ),
      examples: _optionalStringList(json, 'examples', '$context($id)'),
      questions: parsedQuestions,
    );
  }
}

class Module {
  const Module({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
  });

  final String id;
  final ModuleType type;
  final String title;
  final String description;

  factory Module.fromJson(
    Map<String, dynamic> json, {
    required String context,
  }) {
    final id = _requireString(json, 'id', context);
    return Module(
      id: id,
      type: _moduleTypeFromJson(
        _requireString(json, 'type', '$context($id)'),
        '$context($id).type',
      ),
      title: _requireString(json, 'title', '$context($id)'),
      description: _requireString(json, 'description', '$context($id)'),
    );
  }
}

class Unit {
  const Unit({
    required this.id,
    required this.module,
    required this.level,
    required this.title,
  });

  final String id;
  final ModuleType module;
  final Level level;
  final String title;

  factory Unit.fromJson(Map<String, dynamic> json, {required String context}) {
    final id = _requireString(json, 'id', context);
    return Unit(
      id: id,
      module: _moduleTypeFromJson(
        _requireString(json, 'module', '$context($id)'),
        '$context($id).module',
      ),
      level: _levelFromJson(
        _requireString(json, 'level', '$context($id)'),
        '$context($id).level',
      ),
      title: _requireString(json, 'title', '$context($id)'),
    );
  }
}

class ContentBundle {
  const ContentBundle({
    required this.schemaVersion,
    required this.levels,
    required this.modules,
    required this.units,
    required this.lessons,
  });

  final int schemaVersion;
  final List<Level> levels;
  final List<Module> modules;
  final List<Unit> units;
  final List<Lesson> lessons;

  factory ContentBundle.fromJson(Map<String, dynamic> json) {
    final schemaVersion = _requireInt(json, 'schemaVersion', 'root');
    if (schemaVersion != 1) {
      throw ContentValidationException(
        'Unsupported schemaVersion=$schemaVersion (expected 1)',
      );
    }

    final levelsRaw = _requireStringList(json, 'levels', 'root');
    final parsedLevels = <Level>[];
    final levelSet = <Level>{};
    for (final levelRaw in levelsRaw) {
      final level = _levelFromJson(levelRaw, 'root.levels');
      if (!levelSet.add(level)) {
        throw ContentValidationException(
          'Duplicate level "$levelRaw" in root.levels',
        );
      }
      parsedLevels.add(level);
    }

    final modulesRaw = _requireList(json, 'modules', 'root');
    final parsedModules = <Module>[];
    final moduleIdSet = <String>{};
    for (var i = 0; i < modulesRaw.length; i++) {
      final item = modulesRaw[i];
      if (item is! Map<String, dynamic>) {
        throw ContentValidationException('root.modules[$i] must be an object');
      }
      final module = Module.fromJson(item, context: 'module');
      if (!moduleIdSet.add(module.id)) {
        throw ContentValidationException('Duplicate module id "${module.id}"');
      }
      if (module.id != module.type.name) {
        throw ContentValidationException(
          'Module "${module.id}" must match type "${module.type.name}"',
        );
      }
      parsedModules.add(module);
    }

    final unitsRaw = _optionalList(json, 'units', 'root') ?? const <dynamic>[];
    final parsedUnits = <Unit>[];
    final unitIdSet = <String>{};
    for (var i = 0; i < unitsRaw.length; i++) {
      final item = unitsRaw[i];
      if (item is! Map<String, dynamic>) {
        throw ContentValidationException('root.units[$i] must be an object');
      }
      final unit = Unit.fromJson(item, context: 'unit');
      if (!unitIdSet.add(unit.id)) {
        throw ContentValidationException('Duplicate unit id "${unit.id}"');
      }
      if (!moduleIdSet.contains(unit.module.name)) {
        throw ContentValidationException(
          'Unit "${unit.id}" references missing module "${unit.module.name}"',
        );
      }
      if (!levelSet.contains(unit.level)) {
        throw ContentValidationException(
          'Unit "${unit.id}" references missing level "${unit.level.name}"',
        );
      }
      parsedUnits.add(unit);
    }

    final lessonsRaw = _requireList(json, 'lessons', 'root');
    final parsedLessons = <Lesson>[];
    final lessonIdSet = <String>{};
    final questionIdSet = <String>{};

    for (var i = 0; i < lessonsRaw.length; i++) {
      final item = lessonsRaw[i];
      if (item is! Map<String, dynamic>) {
        throw ContentValidationException('root.lessons[$i] must be an object');
      }
      final lesson = Lesson.fromJson(item, context: 'lesson');

      if (!lessonIdSet.add(lesson.id)) {
        throw ContentValidationException('Duplicate lesson id "${lesson.id}"');
      }
      if (!moduleIdSet.contains(lesson.module.name)) {
        throw ContentValidationException(
          'Lesson "${lesson.id}" references missing module "${lesson.module.name}"',
        );
      }
      if (!levelSet.contains(lesson.level)) {
        throw ContentValidationException(
          'Lesson "${lesson.id}" references missing level "${lesson.level.name}"',
        );
      }

      if (lesson.unitId != null) {
        Unit? unit;
        for (final candidate in parsedUnits) {
          if (candidate.id == lesson.unitId) {
            unit = candidate;
            break;
          }
        }
        if (unit == null) {
          throw ContentValidationException(
            'Lesson "${lesson.id}" references missing unit "${lesson.unitId}"',
          );
        }
        if (unit.module != lesson.module) {
          throw ContentValidationException(
            'Lesson "${lesson.id}" unit/module mismatch: unit=${unit.module.name}, lesson=${lesson.module.name}',
          );
        }
        if (unit.level != lesson.level) {
          throw ContentValidationException(
            'Lesson "${lesson.id}" unit/level mismatch: unit=${unit.level.name}, lesson=${lesson.level.name}',
          );
        }
      }

      for (final question in lesson.questions) {
        if (!questionIdSet.add(question.id)) {
          throw ContentValidationException(
            'Duplicate question id "${question.id}" across lessons',
          );
        }
      }

      parsedLessons.add(lesson);
    }

    return ContentBundle(
      schemaVersion: schemaVersion,
      levels: parsedLevels,
      modules: parsedModules,
      units: parsedUnits,
      lessons: parsedLessons,
    );
  }

  List<Lesson> lessonsForModule(ModuleType type) {
    return lessons.where((e) => e.module == type).toList(growable: false);
  }

  List<Lesson> lessonsForLevelAndModule({
    required Level level,
    required ModuleType module,
  }) {
    return lessons
        .where((lesson) => lesson.module == module && lesson.level == level)
        .toList(growable: false);
  }

  Module? moduleById(String moduleId) {
    for (final module in modules) {
      if (module.id == moduleId) {
        return module;
      }
    }
    return null;
  }

  ModuleType? moduleTypeById(String moduleId) {
    final module = moduleById(moduleId);
    return module?.type;
  }

  List<Lesson> lessonsForLevelAndModuleId({
    required Level level,
    required String moduleId,
  }) {
    final moduleType = moduleTypeById(moduleId);
    if (moduleType == null) {
      return const <Lesson>[];
    }
    return lessonsForLevelAndModule(level: level, module: moduleType);
  }
}

class UserProgress {
  const UserProgress({
    required this.selectedLevel,
    required this.dailyGoalMinutes,
    required this.onboardingCompleted,
    required this.completedLessonsToday,
    required this.completedOnDate,
    required this.streak,
    required this.completedLessonIds,
    required this.darkMode,
  });

  final Level selectedLevel;
  final int dailyGoalMinutes;
  final bool onboardingCompleted;
  final int completedLessonsToday;
  final String? completedOnDate;
  final int streak;
  final Set<String> completedLessonIds;
  final bool darkMode;

  double get todayProgressRatio {
    if (dailyGoalMinutes <= 0) {
      return 0;
    }
    final ratio = completedLessonsToday / dailyGoalMinutes;
    if (ratio < 0) {
      return 0;
    }
    if (ratio > 1) {
      return 1;
    }
    return ratio;
  }

  UserProgress copyWith({
    Level? selectedLevel,
    int? dailyGoalMinutes,
    bool? onboardingCompleted,
    int? completedLessonsToday,
    String? completedOnDate,
    int? streak,
    Set<String>? completedLessonIds,
    bool? darkMode,
  }) {
    return UserProgress(
      selectedLevel: selectedLevel ?? this.selectedLevel,
      dailyGoalMinutes: dailyGoalMinutes ?? this.dailyGoalMinutes,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      completedLessonsToday:
          completedLessonsToday ?? this.completedLessonsToday,
      completedOnDate: completedOnDate ?? this.completedOnDate,
      streak: streak ?? this.streak,
      completedLessonIds: completedLessonIds ?? this.completedLessonIds,
      darkMode: darkMode ?? this.darkMode,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'selectedLevel': selectedLevel.name,
      'dailyGoalMinutes': dailyGoalMinutes,
      'onboardingCompleted': onboardingCompleted,
      'completedLessonsToday': completedLessonsToday,
      'completedOnDate': completedOnDate,
      'streak': streak,
      'completedLessonIds': completedLessonIds.toList(growable: false),
      'darkMode': darkMode,
    };
  }

  factory UserProgress.fromJson(Map<String, dynamic> json) {
    return UserProgress(
      selectedLevel: _levelFromJson(
        _requireString(json, 'selectedLevel', 'userProgress'),
        'userProgress.selectedLevel',
      ),
      dailyGoalMinutes: _requireInt(json, 'dailyGoalMinutes', 'userProgress'),
      onboardingCompleted: json['onboardingCompleted'] as bool? ?? false,
      completedLessonsToday: json['completedLessonsToday'] as int? ?? 0,
      completedOnDate: json['completedOnDate'] as String?,
      streak: _requireInt(json, 'streak', 'userProgress'),
      completedLessonIds: (json['completedLessonIds'] as List<dynamic>)
          .map((e) => e as String)
          .toSet(),
      darkMode: json['darkMode'] as bool,
    );
  }

  factory UserProgress.empty() {
    return const UserProgress(
      selectedLevel: Level.a1,
      dailyGoalMinutes: 5,
      onboardingCompleted: false,
      completedLessonsToday: 0,
      completedOnDate: null,
      streak: 0,
      completedLessonIds: <String>{},
      darkMode: false,
    );
  }
}

String _requireString(Map<String, dynamic> map, String key, String context) {
  final value = map[key];
  if (value is! String || value.isEmpty) {
    throw ContentValidationException(
      '$context.$key is required and must be a non-empty string',
    );
  }
  return value;
}

String? _optionalString(Map<String, dynamic> map, String key, String context) {
  final value = map[key];
  if (value == null) {
    return null;
  }
  if (value is! String) {
    throw ContentValidationException(
      '$context.$key must be a string when present',
    );
  }
  return value;
}

int _requireInt(Map<String, dynamic> map, String key, String context) {
  final value = map[key];
  if (value is! int) {
    throw ContentValidationException(
      '$context.$key is required and must be an int',
    );
  }
  return value;
}

List<dynamic> _requireList(
  Map<String, dynamic> map,
  String key,
  String context,
) {
  final value = map[key];
  if (value is! List<dynamic>) {
    throw ContentValidationException(
      '$context.$key is required and must be a list',
    );
  }
  return value;
}

List<dynamic>? _optionalList(
  Map<String, dynamic> map,
  String key,
  String context,
) {
  final value = map[key];
  if (value == null) {
    return null;
  }
  if (value is! List<dynamic>) {
    throw ContentValidationException(
      '$context.$key must be a list when present',
    );
  }
  return value;
}

List<String> _requireStringList(
  Map<String, dynamic> map,
  String key,
  String context,
) {
  final raw = _requireList(map, key, context);
  final result = <String>[];
  for (var i = 0; i < raw.length; i++) {
    final value = raw[i];
    if (value is! String || value.isEmpty) {
      throw ContentValidationException(
        '$context.$key[$i] must be a non-empty string',
      );
    }
    result.add(value);
  }
  return result;
}

List<String> _optionalStringList(
  Map<String, dynamic> map,
  String key,
  String context,
) {
  final raw = _optionalList(map, key, context);
  if (raw == null) {
    return const <String>[];
  }
  final result = <String>[];
  for (var i = 0; i < raw.length; i++) {
    final value = raw[i];
    if (value is! String || value.isEmpty) {
      throw ContentValidationException(
        '$context.$key[$i] must be a non-empty string',
      );
    }
    result.add(value);
  }
  return result;
}

Level _levelFromJson(String value, String context) {
  for (final level in Level.values) {
    if (level.name == value.toLowerCase()) {
      return level;
    }
  }
  throw ContentValidationException('$context has unsupported level "$value"');
}

ModuleType _moduleTypeFromJson(String value, String context) {
  for (final module in ModuleType.values) {
    if (module.name == value.toLowerCase()) {
      return module;
    }
  }
  throw ContentValidationException('$context has unsupported module "$value"');
}

QuestionType _questionTypeFromJson(String value, String context) {
  final normalized = value.toLowerCase();
  if (normalized == 'true_false') {
    return QuestionType.trueFalse;
  }
  if (normalized == 'mcq') {
    return QuestionType.mcq;
  }
  throw ContentValidationException(
    '$context has unsupported question type "$value"',
  );
}
