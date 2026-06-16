// lib/models/quiz_model.dart
import 'package:equatable/equatable.dart';

enum QuestionType { multipleChoice, trueFalse, fillBlank }

class QuizQuestion extends Equatable {
  final String id;
  final String question;
  final QuestionType type;
  final List<String> options;
  final String correctAnswer;
  final String explanation;
  final int xpReward;
  final int coinReward;
  final String? imageUrl;

  const QuizQuestion({
    required this.id,
    required this.question,
    required this.type,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
    this.xpReward = 10,
    this.coinReward = 5,
    this.imageUrl,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'question': question,
        'type': type.name,
        'options': options,
        'correctAnswer': correctAnswer,
        'explanation': explanation,
        'xpReward': xpReward,
        'coinReward': coinReward,
        'imageUrl': imageUrl,
      };

  factory QuizQuestion.fromMap(Map<String, dynamic> map) => QuizQuestion(
        id: map['id'] as String,
        question: map['question'] as String,
        type: QuestionType.values.byName(map['type'] as String),
        options: List<String>.from(map['options'] as List),
        correctAnswer: map['correctAnswer'] as String,
        explanation: map['explanation'] as String,
        xpReward: (map['xpReward'] as num?)?.toInt() ?? 10,
        coinReward: (map['coinReward'] as num?)?.toInt() ?? 5,
        imageUrl: map['imageUrl'] as String?,
      );

  @override
  List<Object?> get props => [id, question, type, options, correctAnswer];
}

class QuizModel extends Equatable {
  final String id;
  final String title;
  final String subjectId;
  final String lessonId;
  final List<QuizQuestion> questions;
  final int totalXp;
  final int totalCoins;
  final int passingScore;
  final DateTime createdAt;

  const QuizModel({
    required this.id,
    required this.title,
    required this.subjectId,
    required this.lessonId,
    required this.questions,
    this.totalXp = 100,
    this.totalCoins = 50,
    this.passingScore = 70,
    required this.createdAt,
  });

  int get questionCount => questions.length;

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'subjectId': subjectId,
        'lessonId': lessonId,
        'questions': questions.map((q) => q.toMap()).toList(),
        'totalXp': totalXp,
        'totalCoins': totalCoins,
        'passingScore': passingScore,
        'createdAt': createdAt.toIso8601String(),
      };

  factory QuizModel.fromMap(Map<String, dynamic> map) => QuizModel(
        id: map['id'] as String,
        title: map['title'] as String,
        subjectId: map['subjectId'] as String,
        lessonId: map['lessonId'] as String,
        questions: (map['questions'] as List)
            .map((q) => QuizQuestion.fromMap(q as Map<String, dynamic>))
            .toList(),
        totalXp: (map['totalXp'] as num?)?.toInt() ?? 100,
        totalCoins: (map['totalCoins'] as num?)?.toInt() ?? 50,
        passingScore: (map['passingScore'] as num?)?.toInt() ?? 70,
        createdAt: map['createdAt'] != null
            ? DateTime.parse(map['createdAt'] as String)
            : DateTime.now(),
      );

  @override
  List<Object?> get props => [id, title, subjectId, lessonId];
}

class QuizAttempt extends Equatable {
  final String id;
  final String userId;
  final String quizId;
  final int score;
  final int totalQuestions;
  final int xpEarned;
  final int coinsEarned;
  final int starsEarned;
  final List<String> answeredQuestions;
  final DateTime completedAt;

  const QuizAttempt({
    required this.id,
    required this.userId,
    required this.quizId,
    required this.score,
    required this.totalQuestions,
    required this.xpEarned,
    required this.coinsEarned,
    required this.starsEarned,
    required this.answeredQuestions,
    required this.completedAt,
  });

  double get percentage => totalQuestions > 0 ? score / totalQuestions * 100 : 0;
  bool get passed => percentage >= 70;

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'quizId': quizId,
        'score': score,
        'totalQuestions': totalQuestions,
        'xpEarned': xpEarned,
        'coinsEarned': coinsEarned,
        'starsEarned': starsEarned,
        'answeredQuestions': answeredQuestions,
        'completedAt': completedAt.toIso8601String(),
      };

  factory QuizAttempt.fromMap(Map<String, dynamic> map) => QuizAttempt(
        id: map['id'] as String,
        userId: map['userId'] as String,
        quizId: map['quizId'] as String,
        score: (map['score'] as num).toInt(),
        totalQuestions: (map['totalQuestions'] as num).toInt(),
        xpEarned: (map['xpEarned'] as num).toInt(),
        coinsEarned: (map['coinsEarned'] as num).toInt(),
        starsEarned: (map['starsEarned'] as num).toInt(),
        answeredQuestions:
            List<String>.from(map['answeredQuestions'] as List),
        completedAt: DateTime.parse(map['completedAt'] as String),
      );

  @override
  List<Object?> get props => [id, userId, quizId, score, completedAt];
}
