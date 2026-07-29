import 'package:hive/hive.dart';
import '../models/scoreboard_entry.dart';

class HiveStorageService {
  static const String boxName = 'scoreboard_entries';

  Future<Box<ScoreboardEntry>> _openBox() async {
    return await Hive.openBox<ScoreboardEntry>(boxName);
  }

  Future<void> saveScoreEntry(ScoreboardEntry entry) async {
    final box = await _openBox();
    await box.put(entry.id, entry);
  }

  Future<List<ScoreboardEntry>> getScoreHistory() async {
    final box = await _openBox();
    final list = box.values.toList();
    // Sort descending by timestamp (newest first)
    list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return list;
  }

  Future<void> clearScoreHistory() async {
    final box = await _openBox();
    await box.clear();
  }
}
