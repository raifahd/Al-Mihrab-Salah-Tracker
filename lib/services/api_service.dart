import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/prayer_times_model.dart';
import '../models/prayer_log_model.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://localhost:5000/api/',
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 3),
  ));

  ApiService() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        debugPrint('\x1B[35m[API Request] ${options.method} ${options.path}\x1B[0m');
        if (options.data != null) debugPrint('Payload: ${options.data}');
        
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('auth_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        debugPrint('\x1B[36m[API Response] ${response.statusCode} from ${response.requestOptions.path}\x1B[0m');
        return handler.next(response);
      },
      onError: (e, handler) {
        debugPrint('\x1B[31m[API Error] ${e.type}: ${e.message}\x1B[0m');
        if (e.response != null) {
          debugPrint('Error Response: ${e.response?.data}');
        }
        return handler.next(e);
      },
    ));
  }

  // Auth
  Future<Response> signup(Map<String, dynamic> userData) async {
    return await _dio.post('auth/signup', data: userData);
  }

  Future<Response> login(String email, String password) async {
    return await _dio.post('auth/login', data: {
      'email': email,
      'password': password,
    });
  }

  // User Profile
  Future<UserModel> getProfile() async {
    final response = await _dio.get('user/profile');
    return UserModel.fromJson(response.data);
  }

  Future<UserModel> updateProfile(Map<String, dynamic> updateData) async {
    final response = await _dio.patch('user/profile', data: updateData);
    return UserModel.fromJson(response.data);
  }

  // Prayer Times
  Future<PrayerTimesModel> getPrayerTimes(String date) async {
    final response = await _dio.get('prayer/times', queryParameters: {'date': date});
    return PrayerTimesModel.fromJson(response.data);
  }

  // Today's Prayer Log
  Future<PrayerLogModel> getTodayLog(String date) async {
    final response = await _dio.get('prayer/today', queryParameters: {'date': date});
    return PrayerLogModel.fromJson(response.data);
  }

  // Mark Prayer
  Future<Map<String, dynamic>> markPrayer({
    required String date,
    required String prayer,
    required String status,
    String? markedAt,
  }) async {
    final response = await _dio.post('prayer/mark', data: {
      'date': date,
      'prayer': prayer,
      'status': status,
      'markedAt': markedAt,
    });
    return response.data;
  }

  // Prayer Analytics
  Future<Map<String, dynamic>> getPrayerAnalytics() async {
    final response = await _dio.get('prayer/analytics');
    return response.data;
  }
}
