import 'package:quiz_app/models/user.dart' as app_user;
import 'package:quiz_app/services/auth_service.dart';
import 'package:quiz_app/services/firestore_service.dart';

class AuthRepository {
  final AuthService _authService;
  final FirestoreService _firestoreService;

  AuthRepository({AuthService? authService, FirestoreService? firestoreService})
      : _authService = authService ?? AuthService(),
        _firestoreService = firestoreService ?? FirestoreService();

  Future<app_user.User> signup(String email, String password) async {
    final credentials = await _authService.signup(email, password);
    final user = app_user.User(
      uid: credentials.user?.uid ?? '',
      displayName: credentials.user?.email?.split('@')[0],
      email: credentials.user?.email ?? '',
      createdAt: DateTime.now(),
    );

    await _firestoreService.saveUserProfile(user);
    return user;
  }

  Future<app_user.User> login(String email, String password) async {
    final credentials = await _authService.login(email, password);
    final user = app_user.User(
      uid: credentials.user?.uid ?? '',
      email: credentials.user?.email ?? '',
      displayName: credentials.user?.email?.split('@')[0],
    );

    await _firestoreService.saveUserProfile(user);
    return user;
  }

  Future<app_user.User> loginWithGoogle() async {
    final credentials = await _authService.loginWithGoogle();
    if (credentials == null || credentials.user == null) {
      throw Exception('Google sign in failed or was cancelled.');
    }
    
    final user = app_user.User(
      uid: credentials.user!.uid,
      email: credentials.user!.email ?? '',
      displayName: credentials.user!.email?.split('@')[0],
    );

    await _firestoreService.saveUserProfile(user);
    return user;
  }

  Future<void> logout() async {
    await _authService.logout();
  }
}
