import 'package:flutter/foundation.dart';
import 'package:quiz_app/models/user.dart';
import 'package:quiz_app/repository/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  User? _user;
  User? get user => _user;

  AuthProvider({AuthRepository? authRepository})
    : _authRepository = authRepository ?? AuthRepository();

  Future<void> signup(String email, String password) async {
    _setLoading(true);
    try {
      _user = await _authRepository.signup(email, password);
      debugPrint('User signed up: ${_user?.uid}');
      _setErrorMessage(null);
    } catch (e) {
      _setErrorMessage(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> login(String email, String password) async {
    _setLoading(true);
    try {
      _user = await _authRepository.login(email, password);
      debugPrint('User logged in: ${_user?.uid}');
      _setErrorMessage(null);
    } catch (e) {
      _setErrorMessage(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loginWithGoogle() async {
    _setLoading(true);
    try {
      _user = await _authRepository.loginWithGoogle();
      debugPrint('User logged in with Google: ${_user?.uid}');
      _setErrorMessage(null);
    } catch (e) {
      _setErrorMessage(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    try {
      await _authRepository.logout();
      _user = null;
      _setErrorMessage(null);
    } catch (e) {
      _setErrorMessage(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setErrorMessage(String? value) {
    _errorMessage = value;
    notifyListeners();
  }
}
