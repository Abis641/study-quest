// lib/models/user_model.dart
import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String uid;
  final String email;
  final String name;
  final int age;
  final int grade;
  final String favoriteSubject;
  final String? avatarUrl;
  final String? localAvatarPath;
  final int level;
  final int xp;
  final int coins;
  final int stars;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastActiveDate;
  final DateTime createdAt;

  const UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.age,
    required this.grade,
    required this.favoriteSubject,
    this.avatarUrl,
    this.localAvatarPath,
    this.level = 1,
    this.xp = 0,
    this.coins = 0,
    this.stars = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastActiveDate,
    required this.createdAt,
  });

  int get xpForNextLevel => level * 100;
  double get levelProgress => xp / xpForNextLevel;

  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    int? age,
    int? grade,
    String? favoriteSubject,
    String? avatarUrl,
    String? localAvatarPath,
    int? level,
    int? xp,
    int? coins,
    int? stars,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastActiveDate,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      age: age ?? this.age,
      grade: grade ?? this.grade,
      favoriteSubject: favoriteSubject ?? this.favoriteSubject,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      localAvatarPath: localAvatarPath ?? this.localAvatarPath,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      coins: coins ?? this.coins,
      stars: stars ?? this.stars,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'age': age,
      'grade': grade,
      'favoriteSubject': favoriteSubject,
      'avatarUrl': avatarUrl,
      'localAvatarPath': localAvatarPath,
      'level': level,
      'xp': xp,
      'coins': coins,
      'stars': stars,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastActiveDate': lastActiveDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String,
      email: map['email'] as String,
      name: map['name'] as String,
      age: (map['age'] as num).toInt(),
      grade: (map['grade'] as num).toInt(),
      favoriteSubject: map['favoriteSubject'] as String,
      avatarUrl: map['avatarUrl'] as String?,
      localAvatarPath: map['localAvatarPath'] as String?,
      level: (map['level'] as num?)?.toInt() ?? 1,
      xp: (map['xp'] as num?)?.toInt() ?? 0,
      coins: (map['coins'] as num?)?.toInt() ?? 0,
      stars: (map['stars'] as num?)?.toInt() ?? 0,
      currentStreak: (map['currentStreak'] as num?)?.toInt() ?? 0,
      longestStreak: (map['longestStreak'] as num?)?.toInt() ?? 0,
      lastActiveDate: map['lastActiveDate'] != null
          ? DateTime.parse(map['lastActiveDate'] as String)
          : null,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        uid, email, name, age, grade, favoriteSubject,
        avatarUrl, localAvatarPath, level, xp, coins, stars,
        currentStreak, longestStreak, lastActiveDate, createdAt,
      ];
}
