import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
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

  AuthProvider() {
    checkAuth();
  }

  Future<void> checkAuth() async {
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
    } else {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
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
        debugPrint('\x1B[31m[Auth] API Error ($email): ${e.response?.statusCode} - ${e.response?.data}\x1B[0m');
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
        final token = response.data['token'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        _status = AuthStatus.authenticated;
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
        debugPrint('\x1B[31m[Auth] API Error during Signup: ${e.response?.statusCode} - ${e.response?.data}\x1B[0m');
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
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
