import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quiz_app/models/scoreboard_entry.dart';
import 'package:quiz_app/services/firestore_service.dart';
import 'package:quiz_app/services/hive_storage_service.dart';

class PaginatedScoreboardResult {
  final List<ScoreboardEntry> entries;
  final DocumentSnapshot? lastDoc;

  PaginatedScoreboardResult(this.entries, this.lastDoc);
}

class ScoreboardRepository {
  final FirestoreService _firestoreService;
  final HiveStorageService _hiveStorageService;

  ScoreboardRepository({
    FirestoreService? firestoreService,
    HiveStorageService? hiveStorageService,
  })  : _firestoreService = firestoreService ?? FirestoreService(),
        _hiveStorageService = hiveStorageService ?? HiveStorageService();

  Future<void> addEntry(ScoreboardEntry entry) async {
    await _firestoreService.saveScoreboardEntry(entry);
    await _hiveStorageService.saveScoreEntry(entry);
  }



  Future<PaginatedScoreboardResult> getGlobalScoreboard(
      DocumentSnapshot? startAfter, int limit, String filter) async {
    final snapshot = await _firestoreService.getGlobalScoreboard(
      startAfter,
      limit,
      filter: filter,
    );

    DocumentSnapshot? lastDoc;
    List<ScoreboardEntry> entries = [];
    
    if (snapshot.docs.isNotEmpty) {
      lastDoc = snapshot.docs.last;
      entries = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Include document ID in the data
        return ScoreboardEntry.fromFirestore(data);
      }).toList();
    }

    return PaginatedScoreboardResult(entries, lastDoc);
  }

  Future<void> deleteResult(String resultId) async {
    await _firestoreService.deleteScoreboardEntry(resultId);
  }
}
