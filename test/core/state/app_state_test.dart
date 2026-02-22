import 'package:flutter_test/flutter_test.dart';
import 'package:lang_app/core/data/content_repository.dart';
import 'package:lang_app/core/models/content_models.dart';
import 'package:lang_app/core/persistence/progress_store.dart';
import 'package:lang_app/core/state/app_state.dart';

class _FakeContentRepository extends ContentRepository {
  _FakeContentRepository(this.bundle);

  final ContentBundle bundle;

  @override
  Future<ContentBundle> loadContent() async => bundle;
}

class _FakeProgressStore extends ProgressStore {
  _FakeProgressStore(this.current);

  UserProgress current;

  @override
  Future<UserProgress> read() async => current;

  @override
  Future<void> write(UserProgress progress) async {
    current = progress;
  }
}

ContentBundle _bundle() {
  return const ContentBundle(
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
        id: 'reading_a1_1',
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
}

void main() {
  test('completeLesson increments today count on same day', () async {
    final store = _FakeProgressStore(
      const UserProgress(
        selectedLevel: Level.a1,
        dailyGoalMinutes: 10,
        onboardingCompleted: true,
        completedLessonsToday: 2,
        completedOnDate: '2026-02-21',
        streak: 0,
        completedLessonIds: <String>{},
        darkMode: false,
      ),
    );

    final appState = AppState(
      contentRepository: _FakeContentRepository(_bundle()),
      progressStore: store,
      nowProvider: () => DateTime(2026, 2, 21),
    );

    await appState.bootstrap();
    await appState.completeLesson('reading_a1_1');

    expect(appState.progress.completedLessonsToday, 3);
    expect(appState.progress.completedOnDate, '2026-02-21');
    expect(
      appState.progress.completedLessonIds.contains('reading_a1_1'),
      isTrue,
    );
  });

  test('completeLesson resets today count when date changes', () async {
    final store = _FakeProgressStore(
      const UserProgress(
        selectedLevel: Level.a1,
        dailyGoalMinutes: 10,
        onboardingCompleted: true,
        completedLessonsToday: 5,
        completedOnDate: '2026-02-20',
        streak: 0,
        completedLessonIds: <String>{},
        darkMode: false,
      ),
    );

    final appState = AppState(
      contentRepository: _FakeContentRepository(_bundle()),
      progressStore: store,
      nowProvider: () => DateTime(2026, 2, 21),
    );

    await appState.bootstrap();
    await appState.completeLesson('reading_a1_1');

    expect(appState.progress.completedLessonsToday, 1);
    expect(appState.progress.completedOnDate, '2026-02-21');
  });

  test('bootstrap resets stale today count before completion', () async {
    final store = _FakeProgressStore(
      const UserProgress(
        selectedLevel: Level.a1,
        dailyGoalMinutes: 10,
        onboardingCompleted: true,
        completedLessonsToday: 4,
        completedOnDate: '2026-02-20',
        streak: 0,
        completedLessonIds: <String>{},
        darkMode: false,
      ),
    );

    final appState = AppState(
      contentRepository: _FakeContentRepository(_bundle()),
      progressStore: store,
      nowProvider: () => DateTime(2026, 2, 21),
    );

    await appState.bootstrap();

    expect(appState.progress.completedLessonsToday, 0);
    expect(appState.progress.completedOnDate, '2026-02-21');
  });

  test('saveOnboarding persists level, goal, and completion flag', () async {
    final store = _FakeProgressStore(UserProgress.empty());
    final appState = AppState(
      contentRepository: _FakeContentRepository(_bundle()),
      progressStore: store,
      nowProvider: () => DateTime(2026, 2, 21),
    );

    await appState.bootstrap();
    await appState.saveOnboarding(level: Level.b1, dailyGoalMinutes: 15);

    expect(appState.progress.selectedLevel, Level.b1);
    expect(appState.progress.dailyGoalMinutes, 15);
    expect(appState.progress.onboardingCompleted, isTrue);
    expect(store.current.onboardingCompleted, isTrue);
  });

  test('completeLesson persists completed ids for subsequent reads', () async {
    final store = _FakeProgressStore(UserProgress.empty());
    final appState = AppState(
      contentRepository: _FakeContentRepository(_bundle()),
      progressStore: store,
      nowProvider: () => DateTime(2026, 2, 21),
    );

    await appState.bootstrap();
    await appState.completeLesson('reading_a1_1');

    final reloaded = await store.read();
    expect(reloaded.completedLessonIds.contains('reading_a1_1'), isTrue);
  });
}
