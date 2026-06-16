// lib/services/achievement_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/lesson_model.dart';
import '../config/firebase_config.dart';

final achievementServiceProvider =
    Provider<AchievementService>((ref) => AchievementService());

class AchievementService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference get _achievements =>
      _db.collection(FirebaseConfig.achievementsCollection);

  Future<List<AchievementModel>> getUserAchievements(String userId) async {
    final snap =
        await _achievements.where('userId', isEqualTo: userId).get();

    final unlocked =
        snap.docs.map((d) => d.data() as Map<String, dynamic>).toList();

    return AchievementData.all.map((achievement) {
      final found = unlocked.firstWhere(
        (a) => a['id'] == achievement.id,
        orElse: () => {},
      );
      if (found.isEmpty) return achievement;
      return AchievementModel(
        id: achievement.id,
        title: achievement.title,
        description: achievement.description,
        emoji: achievement.emoji,
        isUnlocked: found['isUnlocked'] as bool? ?? false,
        unlockedAt: found['unlockedAt'] != null
            ? DateTime.parse(found['unlockedAt'] as String)
            : null,
      );
    }).toList();
  }

  Future<void> unlockAchievement(String userId, String achievementId) async {
    final docId = '${userId}_$achievementId';
    try {
      final existing = await _achievements.doc(docId).get();
      if (existing.exists) {
        final data = existing.data() as Map<String, dynamic>;
        if (data['isUnlocked'] == true) return;
      }
    } catch (_) {}

    final achievement = AchievementData.all.firstWhere(
      (a) => a.id == achievementId,
      orElse: () => throw Exception('Achievement not found: $achievementId'),
    );

    await _achievements.doc(docId).set({
      ...achievement.toMap(),
      'userId': userId,
      'isUnlocked': true,
      'unlockedAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> checkAndUnlockAchievements(
      String userId, Map<String, dynamic> context) async {
    final streak = context['streak'] as int? ?? 0;
    final level = context['level'] as int? ?? 1;
    final coins = context['coins'] as int? ?? 0;
    final perfectScore = context['perfectScore'] as bool? ?? false;

    if (streak >= 7) await unlockAchievement(userId, 'streak_7');
    if (streak >= 30) await unlockAchievement(userId, 'streak_30');
    if (level >= 5) await unlockAchievement(userId, 'level_5');
    if (coins >= 500) await unlockAchievement(userId, 'coin_collector');
    if (perfectScore) await unlockAchievement(userId, 'quiz_champion');
  }
}
