import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/prayer_times_model.dart';
import '../models/prayer_log_model.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://ruzsalah-backend-production.up.railway.app/api/',
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 20),
  ));

  SharedPreferences? _prefs;

  ApiService() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        debugPrint('\x1B[35m[API Request] ${options.method} ${options.path}\x1B[0m');
        
        _prefs ??= await SharedPreferences.getInstance();
        final token = _prefs?.getString('auth_token');
        
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

  Future<Response> changePassword(String currentPassword, String newPassword) async {
    return await _dio.patch('user/change-password', data: {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    });
  }

  // Prayer Times
  Future<PrayerTimesModel> getPrayerTimes(String date) async {
    final response = await _dio.get('prayer/times', queryParameters: {'date': date});
    final prayerTimes = PrayerTimesModel.fromJson(response.data);

    if (prayerTimes.prayers['sunrise'] == null || prayerTimes.prayers['sunset'] == null) {
      try {
        final dioAlt = Dio();
        final lat = prayerTimes.location.lat != 0.0 ? prayerTimes.location.lat : 31.5204;
        final lon = prayerTimes.location.lon != 0.0 ? prayerTimes.location.lon : 74.3587;
        final aladhan = await dioAlt.get('http://api.aladhan.com/v1/timings/$date', queryParameters: {
          'latitude': lat,
          'longitude': lon,
          'method': 1
        });
        final timings = aladhan.data['data']['timings'];
        if (timings['Sunrise'] != null) prayerTimes.prayers['sunrise'] = timings['Sunrise'];
        if (timings['Sunset'] != null) prayerTimes.prayers['sunset'] = timings['Sunset'];
      } catch (e) {
        debugPrint('Fallback Aladhan API failed: $e');
      }
    }
    
    return prayerTimes;
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
