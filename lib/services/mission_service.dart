// lib/services/mission_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/lesson_model.dart';
import '../config/firebase_config.dart';

final missionServiceProvider =
    Provider<MissionService>((ref) => MissionService());

class MissionService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference get _missions =>
      _db.collection(FirebaseConfig.missionsCollection);

  /// Returns today's missions for [userId], generating them if needed.
  Future<List<MissionModel>> getDailyMissions(String userId) async {
    final today = DateTime.now();
    final dateKey =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    final snap = await _missions
        .where('userId', isEqualTo: userId)
        .where('date', isEqualTo: dateKey)
        .get();

    if (snap.docs.isNotEmpty) {
      return snap.docs
          .map((d) =>
              MissionModel.fromMap(d.data() as Map<String, dynamic>))
          .toList();
    }

    return _generateDailyMissions(userId, dateKey);
  }

  Future<List<MissionModel>> _generateDailyMissions(
      String userId, String dateKey) async {
    final templates = [
      {
        'title': 'Math Blitz',
        'description': 'Answer 10 Math questions',
        'type': MissionType.answerQuestions,
        'subjectId': 'math',
        'targetCount': 10,
        'xpReward': 50,
        'coinReward': 25,
      },
      {
        'title': 'Science Quest',
        'description': 'Complete a Science quiz',
        'type': MissionType.completeQuiz,
        'subjectId': 'science',
        'targetCount': 1,
        'xpReward': 50,
        'coinReward': 25,
      },
      {
        'title': 'Word Master',
        'description': 'Learn 5 new English words',
        'type': MissionType.learnWords,
        'subjectId': 'english',
        'targetCount': 5,
        'xpReward': 30,
        'coinReward': 15,
      },
      {
        'title': 'World Explorer',
        'description': 'Study any Geography lesson',
        'type': MissionType.studySubject,
        'subjectId': 'geography',
        'targetCount': 1,
        'xpReward': 30,
        'coinReward': 15,
      },
      {
        'title': 'Daily Learner',
        'description': 'Complete any 3 lessons today',
        'type': MissionType.studySubject,
        'subjectId': null,
        'targetCount': 3,
        'xpReward': 40,
        'coinReward': 20,
      },
    ];

    // Shuffle and pick 3
    templates.shuffle();
    final selected = templates.take(3).toList();
    final batch = _db.batch();
    final missions = <MissionModel>[];

    for (var i = 0; i < selected.length; i++) {
      final t = selected[i];
      final missionId = '${userId}_${dateKey}_$i';
      final mission = MissionModel(
        id: missionId,
        title: t['title'] as String,
        description: t['description'] as String,
        type: t['type'] as MissionType,
        subjectId: t['subjectId'] as String?,
        targetCount: t['targetCount'] as int,
        xpReward: t['xpReward'] as int,
        coinReward: t['coinReward'] as int,
        date: DateTime.parse(dateKey),
      );
      batch.set(_missions.doc(missionId), {
        ...mission.toMap(),
        'userId': userId,
        'date': dateKey,
      });
      missions.add(mission);
    }

    await batch.commit();
    return missions;
  }

  Future<void> updateMissionProgress(
      String userId, String missionId, int newCount) async {
    await _missions.doc(missionId).update({
      'currentCount': newCount,
      'isCompleted': true,
    });
  }

  Future<void> completeMission(String missionId) async {
    await _missions.doc(missionId).update({
      'isCompleted': true,
      'currentCount': -1, // sentinel: force complete
    });
  }
}
