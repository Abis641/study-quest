// lib/providers/user_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../models/lesson_model.dart';
import '../models/quiz_model.dart';
import '../services/user_service.dart';
import '../services/lesson_service.dart';
import '../services/progress_service.dart';
import '../services/achievement_service.dart';
import '../services/mission_service.dart';
import 'auth_provider.dart';

// ── User ──────────────────────────────────────────────────────────────────

final userStreamProvider = StreamProvider.autoDispose<UserModel?>((ref) {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return Stream.value(null);
  return ref.watch(userServiceProvider).watchUser(uid);
});

final userProvider = Provider.autoDispose<UserModel?>((ref) {
  return ref.watch(userStreamProvider).value;
});

// ── Lessons ───────────────────────────────────────────────────────────────

final lessonsProvider =
    FutureProvider.autoDispose.family<List<LessonModel>, String>(
  (ref, subjectId) async {
    return ref.watch(lessonServiceProvider).getLessonsForSubject(subjectId);
  },
);

final lessonProvider =
    FutureProvider.autoDispose.family<LessonModel?, String>(
  (ref, lessonId) async {
    return ref.watch(lessonServiceProvider).getLesson(lessonId);
  },
);

// ── Quiz ──────────────────────────────────────────────────────────────────

final quizProvider = FutureProvider.autoDispose.family<QuizModel?, String>(
  (ref, quizId) async {
    return ref.watch(lessonServiceProvider).getQuiz(quizId);
  },
);

// ── Progress ──────────────────────────────────────────────────────────────

final progressProvider =
    StreamProvider.autoDispose.family<ProgressModel?, String>(
  (ref, subjectId) {
    final uid = ref.watch(currentUserIdProvider);
    if (uid == null) return Stream.value(null);
    return ref.watch(progressServiceProvider).watchProgress(uid, subjectId);
  },
);

// ── Achievements ──────────────────────────────────────────────────────────

final achievementsProvider =
    FutureProvider.autoDispose<List<AchievementModel>>((ref) async {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return AchievementData.all;
  return ref.watch(achievementServiceProvider).getUserAchievements(uid);
});

// ── Missions ──────────────────────────────────────────────────────────────

final dailyMissionsProvider =
    FutureProvider.autoDispose<List<MissionModel>>((ref) async {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return [];
  return ref.watch(missionServiceProvider).getDailyMissions(uid);
});

// ── Quiz State ────────────────────────────────────────────────────────────

class QuizState {
  final QuizModel? quiz;
  final int currentIndex;
  final List<String?> answers;
  final bool isFinished;
  final int score;

  const QuizState({
    this.quiz,
    this.currentIndex = 0,
    this.answers = const [],
    this.isFinished = false,
    this.score = 0,
  });

  QuizQuestion? get currentQuestion =>
      quiz != null && currentIndex < quiz!.questions.length
          ? quiz!.questions[currentIndex]
          : null;

  bool get isLastQuestion =>
      quiz != null && currentIndex == quiz!.questions.length - 1;

  int get xpEarned => score * 10;
  int get coinsEarned => score * 5;
  int get starsEarned => quiz != null
      ? (score / quiz!.questions.length >= 1.0
          ? 3
          : score / quiz!.questions.length >= 0.7
              ? 2
              : score / quiz!.questions.length >= 0.5
                  ? 1
                  : 0)
      : 0;

  QuizState copyWith({
    QuizModel? quiz,
    int? currentIndex,
    List<String?>? answers,
    bool? isFinished,
    int? score,
  }) {
    return QuizState(
      quiz: quiz ?? this.quiz,
      currentIndex: currentIndex ?? this.currentIndex,
      answers: answers ?? this.answers,
      isFinished: isFinished ?? this.isFinished,
      score: score ?? this.score,
    );
  }
}

class QuizNotifier extends StateNotifier<QuizState> {
  final Ref _ref;

  QuizNotifier(this._ref) : super(const QuizState());

  void loadQuiz(QuizModel quiz) {
    state = QuizState(
      quiz: quiz,
      answers: List.filled(quiz.questions.length, null),
    );
  }

  void answerQuestion(String answer) {
    if (state.quiz == null) return;
    final question = state.currentQuestion;
    if (question == null) return;

    final isCorrect =
        answer.toLowerCase() == question.correctAnswer.toLowerCase();
    final newAnswers = List<String?>.from(state.answers);
    newAnswers[state.currentIndex] = answer;

    state = state.copyWith(
      answers: newAnswers,
      score: isCorrect ? state.score + 1 : state.score,
    );
  }

  void nextQuestion() {
    if (state.isLastQuestion) {
      state = state.copyWith(isFinished: true);
      _saveResults();
    } else {
      state = state.copyWith(currentIndex: state.currentIndex + 1);
    }
  }

  void _saveResults() async {
    final quiz = state.quiz;
    if (quiz == null) return;

    final uid = _ref.read(currentUserIdProvider);
    if (uid == null) return;

    final userService = _ref.read(userServiceProvider);
    final progressService = _ref.read(progressServiceProvider);
    final achievementService = _ref.read(achievementServiceProvider);

    await userService.addXp(uid, state.xpEarned);
    await userService.addCoins(uid, state.coinsEarned);
    if (state.starsEarned > 0) {
      await userService.addStars(uid, state.starsEarned);
    }
    await userService.updateStreak(uid);

    await progressService.markQuizComplete(
      uid,
      quiz.subjectId,
      quiz.id,
      state.xpEarned,
      state.score,
      quiz.questions.length,
    );

    // Check achievements
    final user = _ref.read(userProvider);
    if (user != null) {
      await achievementService.checkAndUnlockAchievements(uid, {
        'streak': user.currentStreak + 1,
        'level': user.level,
        'coins': user.coins + state.coinsEarned,
        'perfectScore': state.score == quiz.questions.length,
      });
    }

    // Mark first quest achievement
    await achievementService.unlockAchievement(uid, 'first_quest');
  }

  void reset() {
    state = const QuizState();
  }
}

final quizNotifierProvider =
    StateNotifierProvider.autoDispose<QuizNotifier, QuizState>(
  (ref) => QuizNotifier(ref),
);
