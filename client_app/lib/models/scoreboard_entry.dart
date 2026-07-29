import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

part 'scoreboard_entry.g.dart';

@HiveType(typeId: 0)
class ScoreboardEntry extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String categoryName;

  @HiveField(2)
  final int correctCount;

  @HiveField(3)
  final int totalQuestions;

  @HiveField(4)
  final DateTime timestamp;

  @HiveField(5)
  final String? userId;

  @HiveField(6)
  final String? displayName;

  ScoreboardEntry({
    required this.id,
    required this.categoryName,
    required this.correctCount,
    required this.totalQuestions,
    required this.timestamp,
    this.userId,
    this.displayName,
  });

  double get accuracy => totalQuestions == 0 ? 0.0 : correctCount / totalQuestions;

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'categoryName': categoryName,
      'correctCount': correctCount,
      'totalQuestions': totalQuestions,
      'timestamp': timestamp,
      'userId': userId,
      'displayName': displayName,
    };
  }

  factory ScoreboardEntry.fromFirestore(Map<String, dynamic> data) {
    return ScoreboardEntry(
      id: data['id'] as String? ?? '',
      categoryName: data['categoryName'] as String? ?? '',
      correctCount: data['correctCount'] as int? ?? 0,
      totalQuestions: data['totalQuestions'] as int? ?? 0,
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      userId: data['userId'] as String? ?? '',
      displayName: data['displayName'] as String? ?? 'Unknown',
    );
  }
}
