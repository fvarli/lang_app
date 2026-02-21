import 'package:flutter_test/flutter_test.dart';
import 'package:lang_app/core/models/content_models.dart';

void main() {
  test('UserProgress.fromJson defaults new daily fields when missing', () {
    final progress = UserProgress.fromJson({
      'selectedLevel': 'a1',
      'dailyGoalMinutes': 10,
      'streak': 2,
      'completedLessonIds': ['l1'],
      'darkMode': false,
    });

    expect(progress.completedLessonsToday, 0);
    expect(progress.completedOnDate, isNull);
  });

  test('UserProgress serializes daily fields', () {
    const progress = UserProgress(
      selectedLevel: Level.a1,
      dailyGoalMinutes: 10,
      completedLessonsToday: 4,
      completedOnDate: '2026-02-21',
      streak: 3,
      completedLessonIds: {'l1'},
      darkMode: true,
    );

    final json = progress.toJson();

    expect(json['completedLessonsToday'], 4);
    expect(json['completedOnDate'], '2026-02-21');
  });

  test('todayProgressRatio is clamped to 0..1', () {
    const progress = UserProgress(
      selectedLevel: Level.a1,
      dailyGoalMinutes: 10,
      completedLessonsToday: 20,
      completedOnDate: '2026-02-21',
      streak: 0,
      completedLessonIds: <String>{},
      darkMode: false,
    );

    expect(progress.todayProgressRatio, 1);
  });
}
