import 'package:flutter/material.dart';

import '../data/content_repository.dart';
import '../models/content_models.dart';
import '../persistence/progress_store.dart';

class AppState extends ChangeNotifier {
  AppState({
    required ContentRepository contentRepository,
    required ProgressStore progressStore,
    DateTime Function()? nowProvider,
  }) : _contentRepository = contentRepository,
       _progressStore = progressStore,
       _nowProvider = nowProvider ?? DateTime.now;

  final ContentRepository _contentRepository;
  final ProgressStore _progressStore;
  final DateTime Function() _nowProvider;

  ContentBundle? content;
  UserProgress progress = UserProgress.empty();
  bool isReady = false;

  ThemeMode get themeMode =>
      progress.darkMode ? ThemeMode.dark : ThemeMode.light;

  Future<void> bootstrap() async {
    content = await _contentRepository.loadContent();
    progress = await _progressStore.read();
    final today = _todayKey();
    if (progress.completedOnDate != null &&
        progress.completedOnDate != today &&
        progress.completedLessonsToday > 0) {
      progress = progress.copyWith(
        completedLessonsToday: 0,
        completedOnDate: today,
      );
      await _progressStore.write(progress);
    }
    isReady = true;
    notifyListeners();
  }

  Future<void> saveOnboarding({
    required Level level,
    required int dailyGoalMinutes,
  }) async {
    progress = progress.copyWith(
      selectedLevel: level,
      dailyGoalMinutes: dailyGoalMinutes,
    );
    await _progressStore.write(progress);
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    progress = progress.copyWith(darkMode: !progress.darkMode);
    await _progressStore.write(progress);
    notifyListeners();
  }

  Future<void> completeLesson(String lessonId) async {
    final today = _todayKey();
    final todayCount = progress.completedOnDate == today
        ? progress.completedLessonsToday
        : 0;
    final completed = {...progress.completedLessonIds, lessonId};
    progress = progress.copyWith(
      completedLessonsToday: todayCount + 1,
      completedOnDate: today,
      completedLessonIds: completed,
      streak: progress.streak + 1,
    );
    await _progressStore.write(progress);
    notifyListeners();
  }

  Future<void> resetProgress() async {
    await _progressStore.reset();
    progress = UserProgress.empty();
    notifyListeners();
  }

  String _todayKey() {
    final now = _nowProvider();
    final year = now.year.toString().padLeft(4, '0');
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}
