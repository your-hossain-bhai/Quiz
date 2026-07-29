import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quiz_app/models/user.dart';

import '../models/scoreboard_entry.dart';

class FirestoreService {
  final FirebaseFirestore _firestore;

  FirestoreService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> saveScoreboardEntry(ScoreboardEntry entry) async {
    await _firestore
        .collection('scoreboard')
        .doc(entry.id)
        .set(entry.toFirestore());
  }

  Future<QuerySnapshot> getGlobalScoreboard(
    DocumentSnapshot? startAfter,
    int limit, {
    String filter = 'all',
  }) async {
    Query query = _firestore
        .collection('scoreboard')
        .orderBy('correctCount', descending: true)
        .orderBy('timestamp', descending: true)
        .limit(limit);

    final now = DateTime.now();
    DateTime? start;
    if (filter == 'week') {
      start = DateTime(now.year, now.month, now.day - now.weekday + 1);
    } else if (filter == 'month') {
      start = DateTime(now.year, now.month, 1);
    }

    if (start != null) {
      query = query.where(
        'timestamp',
        isGreaterThanOrEqualTo: Timestamp.fromDate(start),
      );
    }

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    return await query.get();
  }

  Future<List<ScoreboardEntry>> getUserScoreboard(
    String userId, {
    String filter = 'Monthly',
  }) async {
    Query query = _firestore
        .collection('scoreboard')
        .where('userId', isEqualTo: userId);

    final now = DateTime.now();
    if (filter == 'Daily') {
      final start = DateTime(now.year, now.month, now.day);
      query = query.where('timestamp', isGreaterThanOrEqualTo: start);
    } else if (filter == 'Monthly') {
      final start = DateTime(now.year, now.month, 1);
      query = query.where('timestamp', isGreaterThanOrEqualTo: start);
    } else if (filter == 'Yearly') {
      final start = DateTime(now.year, 1, 1);
      query = query.where('timestamp', isGreaterThanOrEqualTo: start);
    }

    final snapshot = await query.orderBy('timestamp', descending: true).get();

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id; // Include document ID in the data
      return ScoreboardEntry.fromFirestore(data);
    }).toList();
  }

  Future<int> getUserHighScore(String userId) async {
    final snapshot = await _firestore
        .collection('scoreboard')
        .where('userId', isEqualTo: userId)
        .orderBy('correctCount', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final data = snapshot.docs.first.data();
      return data['correctCount'] as int? ?? 0;
    }
    return 0;
  }

  Future<void> updateScoreboardEntry(
    String resultId,
    ScoreboardEntry updatedResult,
  ) async {
    await _firestore
        .collection('scoreboard')
        .doc(resultId)
        .update(updatedResult.toFirestore());
  }

  Future<void> deleteScoreboardEntry(String resultId) async {
    await _firestore.collection('scoreboard').doc(resultId).delete();
  }

  Future<void> saveUserProfile(User user) async {
    final userRef = _firestore.collection('users').doc(user.uid);
    final userDoc = await userRef.get();

    if (userDoc.exists) {
      await userRef.update(user.toMap());
    } else {
      await userRef.set(user.toMap());
    }
  }

  Future<User?> getUserProfile(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (doc.exists && doc.data() != null) {
      return User.fromMap(doc.data()!);
    }
    return null;
  }

  Future<void> updateUserProfile(User profile) async {
    final userRef = _firestore.collection('users').doc(profile.uid);
    await userRef.set(profile.toMap(), SetOptions(merge: true));
  }

  Future<void> saveGeneratedQuiz(String category, List<dynamic> questionsJson) async {
    await _firestore.collection('generated_quizzes').add({
      'category': category,
      'questions': questionsJson,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
