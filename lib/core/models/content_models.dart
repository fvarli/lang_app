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

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as String,
      type: _questionTypeFromJson(json['type'] as String),
      prompt: json['prompt'] as String,
      options: (json['options'] as List<dynamic>)
          .map((e) => e as String)
          .toList(growable: false),
      correctIndex: json['correctIndex'] as int,
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

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'] as String,
      unitId: json['unitId'] as String?,
      module: _moduleTypeFromJson(json['module'] as String),
      level: _levelFromJson(json['level'] as String),
      title: json['title'] as String,
      passageText: json['passageText'] as String?,
      audioAsset: json['audioAsset'] as String?,
      explanationMarkdown: json['explanationMarkdown'] as String?,
      examples: (json['examples'] as List<dynamic>? ?? const <dynamic>[])
          .map((e) => e as String)
          .toList(growable: false),
      questions: (json['questions'] as List<dynamic>)
          .map((e) => Question.fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
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

  factory Module.fromJson(Map<String, dynamic> json) {
    return Module(
      id: json['id'] as String,
      type: _moduleTypeFromJson(json['type'] as String),
      title: json['title'] as String,
      description: json['description'] as String,
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

  factory Unit.fromJson(Map<String, dynamic> json) {
    return Unit(
      id: json['id'] as String,
      module: _moduleTypeFromJson(json['module'] as String),
      level: _levelFromJson(json['level'] as String),
      title: json['title'] as String,
    );
  }
}

class ContentBundle {
  const ContentBundle({
    required this.modules,
    required this.units,
    required this.lessons,
  });

  final List<Module> modules;
  final List<Unit> units;
  final List<Lesson> lessons;

  factory ContentBundle.fromJson(Map<String, dynamic> json) {
    return ContentBundle(
      modules: (json['modules'] as List<dynamic>)
          .map((e) => Module.fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
      units: (json['units'] as List<dynamic>? ?? const <dynamic>[])
          .map((e) => Unit.fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
      lessons: (json['lessons'] as List<dynamic>)
          .map((e) => Lesson.fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
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
}

class UserProgress {
  const UserProgress({
    required this.selectedLevel,
    required this.dailyGoalMinutes,
    required this.streak,
    required this.completedLessonIds,
    required this.darkMode,
  });

  final Level selectedLevel;
  final int dailyGoalMinutes;
  final int streak;
  final Set<String> completedLessonIds;
  final bool darkMode;

  UserProgress copyWith({
    Level? selectedLevel,
    int? dailyGoalMinutes,
    int? streak,
    Set<String>? completedLessonIds,
    bool? darkMode,
  }) {
    return UserProgress(
      selectedLevel: selectedLevel ?? this.selectedLevel,
      dailyGoalMinutes: dailyGoalMinutes ?? this.dailyGoalMinutes,
      streak: streak ?? this.streak,
      completedLessonIds: completedLessonIds ?? this.completedLessonIds,
      darkMode: darkMode ?? this.darkMode,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'selectedLevel': selectedLevel.name,
      'dailyGoalMinutes': dailyGoalMinutes,
      'streak': streak,
      'completedLessonIds': completedLessonIds.toList(growable: false),
      'darkMode': darkMode,
    };
  }

  factory UserProgress.fromJson(Map<String, dynamic> json) {
    return UserProgress(
      selectedLevel: _levelFromJson(json['selectedLevel'] as String),
      dailyGoalMinutes: json['dailyGoalMinutes'] as int,
      streak: json['streak'] as int,
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
      streak: 0,
      completedLessonIds: <String>{},
      darkMode: false,
    );
  }
}

Level _levelFromJson(String value) {
  return Level.values.firstWhere((e) => e.name == value.toLowerCase());
}

ModuleType _moduleTypeFromJson(String value) {
  return ModuleType.values.firstWhere((e) => e.name == value.toLowerCase());
}

QuestionType _questionTypeFromJson(String value) {
  if (value.toLowerCase() == 'true_false') {
    return QuestionType.trueFalse;
  }
  return QuestionType.mcq;
}
