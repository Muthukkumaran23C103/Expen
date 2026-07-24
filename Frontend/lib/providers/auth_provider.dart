import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_response.dart';
import '../models/dto_models.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthResponse? _user;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isInitialized = false;

  AuthResponse? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;
  bool get isInitialized => _isInitialized;

  String get role => _user?.role ?? '';
  bool get isAdmin => role.toLowerCase() == 'admin';
  bool get isManager => role.toLowerCase() == 'manager';
  bool get isEmployee => role.toLowerCase() == 'employee';

  AuthProvider() {
    _initSession();
  }

  Future<void> _initSession() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('auth_user');
      if (userJson != null) {
        final Map<String, dynamic> map = jsonDecode(userJson);
        final auth = AuthResponse.fromJson(map);
        
        // Check expiration
        if (auth.expiresAt.isAfter(DateTime.now())) {
          _user = auth;
          ApiService.setAuthToken(auth.token);
        } else {
          await prefs.remove('auth_user');
        }
      }
    } catch (e) {
      debugPrint('Error restoring auth session: $e');
    } finally {
      _isLoading = false;
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<bool> loginUser(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final dto = LoginUserDTO(email: email, password: password);
      _user = await _authService.loginUser(dto);
      await _saveSession(_user!);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> loginAdmin(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final dto = LoginUserDTO(email: email, password: password);
      _user = await _authService.loginAdmin(dto);
      await _saveSession(_user!);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUp(SignUpUserDTO dto) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.signUpUser(dto);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _user = null;
    ApiService.setAuthToken(null);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_user');
    notifyListeners();
  }

  Future<void> _saveSession(AuthResponse auth) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_user', jsonEncode(auth.toJson()));
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
