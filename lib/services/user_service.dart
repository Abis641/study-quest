// lib/services/user_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../config/firebase_config.dart';

final userServiceProvider = Provider<UserService>((ref) => UserService());

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference get _users =>
      _db.collection(FirebaseConfig.usersCollection);

  Future<void> createUser(UserModel user) async {
    await _users.doc(user.uid).set(user.toMap());
  }

  Future<UserModel?> getUser(String uid) async {
    final doc = await _users.doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data() as Map<String, dynamic>);
  }

  Stream<UserModel?> watchUser(String uid) {
    return _users.doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromMap(doc.data() as Map<String, dynamic>);
    });
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _users.doc(uid).update(data);
  }

  Future<void> addXp(String uid, int amount) async {
    await _db.runTransaction((transaction) async {
      final userDoc = _users.doc(uid);
      final snap = await transaction.get(userDoc);
      final user = UserModel.fromMap(snap.data() as Map<String, dynamic>);

      int newXp = user.xp + amount;
      int newLevel = user.level;

      // Level up logic
      while (newXp >= newLevel * 100) {
        newXp -= newLevel * 100;
        newLevel++;
      }

      transaction.update(userDoc, {
        'xp': newXp,
        'level': newLevel,
      });
    });
  }

  Future<void> addCoins(String uid, int amount) async {
    await _users.doc(uid).update({
      'coins': FieldValue.increment(amount),
    });
  }

  Future<void> addStars(String uid, int amount) async {
    await _users.doc(uid).update({
      'stars': FieldValue.increment(amount),
    });
  }

  Future<void> updateStreak(String uid) async {
    await _db.runTransaction((transaction) async {
      final userDoc = _users.doc(uid);
      final snap = await transaction.get(userDoc);
      final user = UserModel.fromMap(snap.data() as Map<String, dynamic>);

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      if (user.lastActiveDate == null) {
        transaction.update(userDoc, {
          'currentStreak': 1,
          'longestStreak': 1,
          'lastActiveDate': today.toIso8601String(),
        });
        return;
      }

      final lastActive = DateTime(
        user.lastActiveDate!.year,
        user.lastActiveDate!.month,
        user.lastActiveDate!.day,
      );

      if (lastActive == today) return; // Already counted today

      final difference = today.difference(lastActive).inDays;
      int newStreak;

      if (difference == 1) {
        newStreak = user.currentStreak + 1;
      } else {
        newStreak = 1; // Streak broken
      }

      transaction.update(userDoc, {
        'currentStreak': newStreak,
        'longestStreak':
            newStreak > user.longestStreak ? newStreak : user.longestStreak,
        'lastActiveDate': today.toIso8601String(),
      });
    });
  }
}
