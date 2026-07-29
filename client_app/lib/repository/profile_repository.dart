import 'dart:io';
import 'package:quiz_app/models/user.dart';
import 'package:quiz_app/models/scoreboard_entry.dart';
import 'package:quiz_app/services/firestore_service.dart';
import 'package:quiz_app/services/storage_service.dart';

class ProfileRepository {
  final FirestoreService _firestoreService;
  final StorageService _storageService;

  ProfileRepository({
    FirestoreService? firestoreService,
    StorageService? storageService,
  })  : _firestoreService = firestoreService ?? FirestoreService(),
        _storageService = storageService ?? StorageService();

  Future<String> uploadProfileImage({
    required String userId,
    required File imageFile,
  }) async {
    final user = await _firestoreService.getUserProfile(userId);
    if (user == null) {
      throw Exception('User not found');
    }

    final ext = imageFile.path.split('.').last;
    final extension = ext.isNotEmpty ? ext : 'jpg';
    final path = 'profile_images/$userId/profile_image.$extension';

    final downloadUrl = await _storageService.uploadFile(path, imageFile);

    final updatedUser = user.copyWith(avatarUrl: downloadUrl);
    await _firestoreService.updateUserProfile(updatedUser);

    return downloadUrl;
  }

  Future<User?> getUserProfile(String userId) async {
    return await _firestoreService.getUserProfile(userId);
  }

  Future<void> updateUserProfile(User profile) async {
    return await _firestoreService.updateUserProfile(profile);
  }

  Future<List<ScoreboardEntry>> getPersonalResults(String userId, String filter) async {
    return await _firestoreService.getUserScoreboard(userId, filter: filter);
  }
}
