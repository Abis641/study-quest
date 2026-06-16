// lib/models/lesson_model.dart
import 'package:equatable/equatable.dart';

class LessonContent extends Equatable {
  final String type; // 'text', 'image', 'fact'
  final String content;
  final String? imageUrl;

  const LessonContent({
    required this.type,
    required this.content,
    this.imageUrl,
  });

  Map<String, dynamic> toMap() => {
        'type': type,
        'content': content,
        'imageUrl': imageUrl,
      };

  factory LessonContent.fromMap(Map<String, dynamic> map) => LessonContent(
        type: map['type'] as String,
        content: map['content'] as String,
        imageUrl: map['imageUrl'] as String?,
      );

  @override
  List<Object?> get props => [type, content];
}

class LessonModel extends Equatable {
  final String id;
  final String title;
  final String subjectId;
  final String description;
  final List<LessonContent> content;
  final String? quizId;
  final int order;
  final String emoji;
  final bool isLocked;
  final DateTime createdAt;

  const LessonModel({
    required this.id,
    required this.title,
    required this.subjectId,
    required this.description,
    required this.content,
    this.quizId,
    required this.order,
    required this.emoji,
    this.isLocked = false,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'subjectId': subjectId,
        'description': description,
        'content': content.map((c) => c.toMap()).toList(),
        'quizId': quizId,
        'order': order,
        'emoji': emoji,
        'isLocked': isLocked,
        'createdAt': createdAt.toIso8601String(),
      };

  factory LessonModel.fromMap(Map<String, dynamic> map) => LessonModel(
        id: map['id'] as String,
        title: map['title'] as String,
        subjectId: map['subjectId'] as String,
        description: map['description'] as String,
        content: map['content'] != null
            ? (map['content'] as List)
                .map((c) => LessonContent.fromMap(c as Map<String, dynamic>))
                .toList()
            : [],
        quizId: map['quizId'] as String?,
        order: (map['order'] as num).toInt(),
        emoji: map['emoji'] as String? ?? '📚',
        isLocked: map['isLocked'] as bool? ?? false,
        createdAt: map['createdAt'] != null
            ? DateTime.parse(map['createdAt'] as String)
            : DateTime.now(),
      );

  @override
  List<Object?> get props => [id, title, subjectId, order];
}

// lib/models/subject_model.dart
class SubjectModel extends Equatable {
  final String id;
  final String name;
  final String emoji;
  final String description;
  final String colorHex;
  final int lessonCount;
  final int quizCount;

  const SubjectModel({
    required this.id,
    required this.name,
    required this.emoji,
    required this.description,
    required this.colorHex,
    this.lessonCount = 0,
    this.quizCount = 0,
  });

  @override
  List<Object?> get props => [id, name];
}

// Static subject definitions
class SubjectData {
  static const List<SubjectModel> all = [
    SubjectModel(
      id: 'math',
      name: 'Math',
      emoji: '🔢',
      description: 'Numbers, equations, and cool patterns!',
      colorHex: '6C63FF',
    ),
    SubjectModel(
      id: 'science',
      name: 'Science',
      emoji: '🔬',
      description: 'Discover how the world works!',
      colorHex: '06D6A0',
    ),
    SubjectModel(
      id: 'english',
      name: 'English',
      emoji: '📖',
      description: 'Words, stories, and expressions!',
      colorHex: 'FF6B6B',
    ),
    SubjectModel(
      id: 'geography',
      name: 'Geography',
      emoji: '🌍',
      description: 'Explore every corner of our planet!',
      colorHex: 'FFD166',
    ),
  ];

  static SubjectModel? findById(String id) {
    try {
      return all.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }
}

// lib/models/achievement_model.dart
class AchievementModel extends Equatable {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  const AchievementModel({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  AchievementModel copyWith({bool? isUnlocked, DateTime? unlockedAt}) =>
      AchievementModel(
        id: id,
        title: title,
        description: description,
        emoji: emoji,
        isUnlocked: isUnlocked ?? this.isUnlocked,
        unlockedAt: unlockedAt ?? this.unlockedAt,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'description': description,
        'emoji': emoji,
        'isUnlocked': isUnlocked,
        'unlockedAt': unlockedAt?.toIso8601String(),
      };

  factory AchievementModel.fromMap(Map<String, dynamic> map) =>
      AchievementModel(
        id: map['id'] as String,
        title: map['title'] as String,
        description: map['description'] as String,
        emoji: map['emoji'] as String,
        isUnlocked: map['isUnlocked'] as bool? ?? false,
        unlockedAt: map['unlockedAt'] != null
            ? DateTime.parse(map['unlockedAt'] as String)
            : null,
      );

  @override
  List<Object?> get props => [id, isUnlocked, unlockedAt];
}

class AchievementData {
  static const List<AchievementModel> all = [
    AchievementModel(
      id: 'math_master',
      title: 'Math Master',
      description: 'Complete all Math lessons',
      emoji: '🏆',
    ),
    AchievementModel(
      id: 'science_explorer',
      title: 'Science Explorer',
      description: 'Complete all Science lessons',
      emoji: '🔬',
    ),
    AchievementModel(
      id: 'word_wizard',
      title: 'Word Wizard',
      description: 'Complete all English lessons',
      emoji: '📖',
    ),
    AchievementModel(
      id: 'world_traveler',
      title: 'World Traveler',
      description: 'Complete all Geography lessons',
      emoji: '🌍',
    ),
    AchievementModel(
      id: 'quiz_champion',
      title: 'Quiz Champion',
      description: 'Score 100% on any quiz',
      emoji: '🎯',
    ),
    AchievementModel(
      id: 'streak_7',
      title: '7 Day Streak',
      description: 'Study 7 days in a row',
      emoji: '🔥',
    ),
    AchievementModel(
      id: 'streak_30',
      title: '30 Day Streak',
      description: 'Study 30 days in a row',
      emoji: '💫',
    ),
    AchievementModel(
      id: 'first_quest',
      title: 'First Quest',
      description: 'Complete your first quiz',
      emoji: '⚔️',
    ),
    AchievementModel(
      id: 'coin_collector',
      title: 'Coin Collector',
      description: 'Earn 500 coins total',
      emoji: '🪙',
    ),
    AchievementModel(
      id: 'level_5',
      title: 'Level 5 Scholar',
      description: 'Reach Level 5',
      emoji: '🌟',
    ),
  ];
}

// lib/models/mission_model.dart
enum MissionType { answerQuestions, completeQuiz, learnWords, studySubject }

class MissionModel extends Equatable {
  final String id;
  final String title;
  final String description;
  final MissionType type;
  final String? subjectId;
  final int targetCount;
  final int currentCount;
  final int xpReward;
  final int coinReward;
  final bool isCompleted;
  final DateTime date;

  const MissionModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    this.subjectId,
    required this.targetCount,
    this.currentCount = 0,
    required this.xpReward,
    required this.coinReward,
    this.isCompleted = false,
    required this.date,
  });

  double get progress => targetCount > 0 ? currentCount / targetCount : 0;
  bool get isComplete => currentCount >= targetCount;

  MissionModel copyWith({
    int? currentCount,
    bool? isCompleted,
  }) =>
      MissionModel(
        id: id,
        title: title,
        description: description,
        type: type,
        subjectId: subjectId,
        targetCount: targetCount,
        currentCount: currentCount ?? this.currentCount,
        xpReward: xpReward,
        coinReward: coinReward,
        isCompleted: isCompleted ?? this.isCompleted,
        date: date,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'description': description,
        'type': type.name,
        'subjectId': subjectId,
        'targetCount': targetCount,
        'currentCount': currentCount,
        'xpReward': xpReward,
        'coinReward': coinReward,
        'isCompleted': isCompleted,
        'date': date.toIso8601String(),
      };

  factory MissionModel.fromMap(Map<String, dynamic> map) => MissionModel(
        id: map['id'] as String,
        title: map['title'] as String,
        description: map['description'] as String,
        type: MissionType.values.byName(map['type'] as String),
        subjectId: map['subjectId'] as String?,
        targetCount: (map['targetCount'] as num).toInt(),
        currentCount: (map['currentCount'] as num?)?.toInt() ?? 0,
        xpReward: (map['xpReward'] as num).toInt(),
        coinReward: (map['coinReward'] as num).toInt(),
        isCompleted: map['isCompleted'] as bool? ?? false,
        date: DateTime.parse(map['date'] as String),
      );

  @override
  List<Object?> get props => [id, currentCount, isCompleted];
}

// lib/models/progress_model.dart
class ProgressModel extends Equatable {
  final String userId;
  final String subjectId;
  final List<String> completedLessons;
  final List<String> completedQuizzes;
  final int totalXpEarned;
  final int totalQuestionsAnswered;
  final int totalCorrectAnswers;
  final DateTime lastStudied;

  const ProgressModel({
    required this.userId,
    required this.subjectId,
    this.completedLessons = const [],
    this.completedQuizzes = const [],
    this.totalXpEarned = 0,
    this.totalQuestionsAnswered = 0,
    this.totalCorrectAnswers = 0,
    required this.lastStudied,
  });

  double get accuracy => totalQuestionsAnswered > 0
      ? totalCorrectAnswers / totalQuestionsAnswered * 100
      : 0;

  ProgressModel copyWith({
    List<String>? completedLessons,
    List<String>? completedQuizzes,
    int? totalXpEarned,
    int? totalQuestionsAnswered,
    int? totalCorrectAnswers,
    DateTime? lastStudied,
  }) =>
      ProgressModel(
        userId: userId,
        subjectId: subjectId,
        completedLessons: completedLessons ?? this.completedLessons,
        completedQuizzes: completedQuizzes ?? this.completedQuizzes,
        totalXpEarned: totalXpEarned ?? this.totalXpEarned,
        totalQuestionsAnswered:
            totalQuestionsAnswered ?? this.totalQuestionsAnswered,
        totalCorrectAnswers: totalCorrectAnswers ?? this.totalCorrectAnswers,
        lastStudied: lastStudied ?? this.lastStudied,
      );

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'subjectId': subjectId,
        'completedLessons': completedLessons,
        'completedQuizzes': completedQuizzes,
        'totalXpEarned': totalXpEarned,
        'totalQuestionsAnswered': totalQuestionsAnswered,
        'totalCorrectAnswers': totalCorrectAnswers,
        'lastStudied': lastStudied.toIso8601String(),
      };

  factory ProgressModel.fromMap(Map<String, dynamic> map) => ProgressModel(
        userId: map['userId'] as String,
        subjectId: map['subjectId'] as String,
        completedLessons: List<String>.from(map['completedLessons'] as List),
        completedQuizzes: List<String>.from(map['completedQuizzes'] as List),
        totalXpEarned: (map['totalXpEarned'] as num?)?.toInt() ?? 0,
        totalQuestionsAnswered:
            (map['totalQuestionsAnswered'] as num?)?.toInt() ?? 0,
        totalCorrectAnswers:
            (map['totalCorrectAnswers'] as num?)?.toInt() ?? 0,
        lastStudied: DateTime.parse(map['lastStudied'] as String),
      );

  @override
  List<Object?> get props => [userId, subjectId, completedLessons, completedQuizzes];
}
