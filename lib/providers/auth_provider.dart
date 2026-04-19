import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

enum AuthStatus {
  initial,
  onboarding,
  unauthenticated,
  authenticating,
  authenticated,
  error,
}

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  AuthStatus _status = AuthStatus.initial;
  String? _error;

  AuthStatus get status => _status;
  String? get error => _error;
  UserModel? get user => _user;
  Map<String, dynamic>? get analytics => _analytics;

  UserModel? _user;
  Map<String, dynamic>? _analytics;

  AuthProvider() {
    checkAuth();
  }

  Future<void> checkAuth() async {
    // Elegant artificial delay to expose the glorious Splash Screen sequence
    await Future.delayed(const Duration(milliseconds: 2500));

    final prefs = await SharedPreferences.getInstance();
    
    // Check if onboarding completed
    final onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;
    if (!onboardingCompleted) {
      _status = AuthStatus.onboarding;
      notifyListeners();
      return;
    }

    // Check if token exists
    final token = prefs.getString('auth_token');
    if (token != null) {
      _status = AuthStatus.authenticated;
      notifyListeners();
      fetchProfile();
    } else {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    }
  }

  Future<void> fetchProfile() async {
    try {
      final results = await Future.wait([
        _apiService.getProfile(),
        _apiService.getPrayerAnalytics(),
      ]);
      _user = results[0] as UserModel;
      _analytics = results[1] as Map<String, dynamic>;
      notifyListeners();
    } catch (e) {
      debugPrint('[Auth] Error fetching profile: $e');
      if (e is DioException && e.response?.statusCode == 401) {
        logout();
      }
    }
  }

  Future<bool> login(String email, String password) async {
    debugPrint('\x1B[33m[Auth] Attempting login: $email\x1B[0m');
    _status = AuthStatus.authenticating;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.login(email, password);
      debugPrint('\x1B[32m[Auth] Login success (Status: ${response.statusCode})\x1B[0m');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final token = response.data['token'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        _status = AuthStatus.authenticated;
        notifyListeners();
        fetchProfile();
        return true;
      } else {
        _error = response.data['message'] ?? 'Login failed';
        debugPrint('\x1B[31m[Auth] Login failure: $_error\x1B[0m');
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return false;
      }
    } catch (e) {
      if (e is DioException) {
        _error = e.response?.data['message'] ?? 'Login failed';
        if (e.type == DioExceptionType.connectionError) {
          _error = 'Connection refused. Is the backend running on port 5000?';
          debugPrint('\x1B[31m[Auth] Error: Backend not reachable on port 5000\x1B[0m');
        } else {
          debugPrint('\x1B[31m[Auth] API Error ($email): ${e.response?.statusCode} - ${e.response?.data}\x1B[0m');
        }
      } else {
        _error = 'An error occurred during login';
        debugPrint('\x1B[31m[Auth] Unexpected Error: $e\x1B[0m');
      }
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signup(String name, String email, String password) async {
    debugPrint('\x1B[33m[Auth] Attempting signup: $email\x1B[0m');
    _status = AuthStatus.authenticating;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.signup({
        'name': name,
        'email': email,
        'password': password,
      });
      debugPrint('\x1B[32m[Auth] Signup success (Status: ${response.statusCode})\x1B[0m');

      if (response.statusCode == 201) {
        // We don't save the token here anymore because the user needs to log in manually
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return true;
      } else {
        _error = response.data['message'] ?? 'Signup failed';
        debugPrint('\x1B[31m[Auth] Signup failure: $_error\x1B[0m');
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return false;
      }
    } catch (e) {
      if (e is DioException) {
        _error = e.response?.data['message'] ?? 'Signup failed';
        if (e.type == DioExceptionType.connectionError) {
          _error = 'Connection refused. Is the backend running on port 5000?';
          debugPrint('\x1B[31m[Auth] Error: Backend not reachable on port 5000\x1B[0m');
        } else {
          debugPrint('\x1B[31m[Auth] API Error during Signup: ${e.response?.statusCode} - ${e.response?.data}\x1B[0m');
        }
      } else {
        _error = 'An error occurred during signup';
        debugPrint('\x1B[31m[Auth] Unexpected Error: $e\x1B[0m');
      }
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<void> logout() async {
    debugPrint('\x1B[33m[Auth] Logging out...\x1B[0m');
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    _user = null;
    _analytics = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<void> updateProfile({String? name, Map<String, dynamic>? settings}) async {
    try {
      final updateData = <String, dynamic>{};
      if (name != null) updateData['name'] = name;
      if (settings != null) updateData['settings'] = settings;

      final updatedUser = await _apiService.updateProfile(updateData);
      _user = updatedUser;
      notifyListeners();
    } catch (e) {
      debugPrint('[Auth] Error updating profile: $e');
    }
  }
}
