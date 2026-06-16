// lib/services/progress_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/lesson_model.dart';
import '../config/firebase_config.dart';

final progressServiceProvider =
    Provider<ProgressService>((ref) => ProgressService());

class ProgressService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference get _progress =>
      _db.collection(FirebaseConfig.progressCollection);

  String _docId(String userId, String subjectId) => '${userId}_$subjectId';

  Future<ProgressModel?> getProgress(String userId, String subjectId) async {
    final doc = await _progress.doc(_docId(userId, subjectId)).get();
    if (!doc.exists) return null;
    return ProgressModel.fromMap(doc.data() as Map<String, dynamic>);
  }

  Stream<ProgressModel?> watchProgress(String userId, String subjectId) {
    return _progress.doc(_docId(userId, subjectId)).snapshots().map((doc) {
      if (!doc.exists) return null;
      return ProgressModel.fromMap(doc.data() as Map<String, dynamic>);
    });
  }

  Future<void> markLessonComplete(
      String userId, String subjectId, String lessonId) async {
    final docRef = _progress.doc(_docId(userId, subjectId));
    final doc = await docRef.get();

    if (!doc.exists) {
      final progress = ProgressModel(
        userId: userId,
        subjectId: subjectId,
        completedLessons: [lessonId],
        lastStudied: DateTime.now(),
      );
      await docRef.set(progress.toMap());
    } else {
      await docRef.update({
        'completedLessons': FieldValue.arrayUnion([lessonId]),
        'lastStudied': DateTime.now().toIso8601String(),
      });
    }
  }

  Future<void> markQuizComplete(String userId, String subjectId,
      String quizId, int xpEarned, int correct, int total) async {
    final docRef = _progress.doc(_docId(userId, subjectId));
    final doc = await docRef.get();

    if (!doc.exists) {
      final progress = ProgressModel(
        userId: userId,
        subjectId: subjectId,
        completedQuizzes: [quizId],
        totalXpEarned: xpEarned,
        totalQuestionsAnswered: total,
        totalCorrectAnswers: correct,
        lastStudied: DateTime.now(),
      );
      await docRef.set(progress.toMap());
    } else {
      await docRef.update({
        'completedQuizzes': FieldValue.arrayUnion([quizId]),
        'totalXpEarned': FieldValue.increment(xpEarned),
        'totalQuestionsAnswered': FieldValue.increment(total),
        'totalCorrectAnswers': FieldValue.increment(correct),
        'lastStudied': DateTime.now().toIso8601String(),
      });
    }
  }
}
