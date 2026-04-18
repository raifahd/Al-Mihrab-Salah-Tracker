import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/user_model.dart';
import '../models/prayer_times_model.dart';
import '../models/prayer_log_model.dart';
import '../services/api_service.dart';

class DashboardProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  UserModel? _user;
  PrayerTimesModel? _prayerTimes;
  PrayerLogModel? _todayLog;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  PrayerTimesModel? get prayerTimes => _prayerTimes;
  PrayerLogModel? get todayLog => _todayLog;
  bool get isLoading => _isLoading;
  String? get error => _error;

  String get _todayDate {
    return DateFormat('dd-MM-yyyy').format(DateTime.now());
  }

  Future<void> init() async {
    await fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _apiService.getProfile(),
        _apiService.getPrayerTimes(_todayDate),
        _apiService.getTodayLog(_todayDate),
      ]);

      _user = results[0] as UserModel;
      _prayerTimes = results[1] as PrayerTimesModel;
      _todayLog = results[2] as PrayerLogModel;
      
      _error = null;
    } catch (e) {
      _error = e.toString();
      print('DashboardProvider Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markPrayer(String prayerName, String status) async {
    try {
      final now = DateTime.now();
      final markedAt = DateFormat('HH:mm').format(now);
      
      final result = await _apiService.markPrayer(
        date: _todayDate,
        prayer: prayerName.toLowerCase(),
        status: status.toLowerCase().replaceAll(' ', '_'),
        markedAt: markedAt,
      );

      // Update local streak and log from response
      if (result['streak'] != null) {
        _user = UserModel(
          id: _user!.id,
          name: _user!.name,
          email: _user!.email,
          location: _user!.location,
          streak: Streak.fromJson(result['streak']),
          settings: _user!.settings,
        );
      }

      if (result['todayLog'] != null) {
        _todayLog = PrayerLogModel.fromJson(result['todayLog']);
      }

      notifyListeners();
    } catch (e) {
      print('Error marking prayer: $e');
      // In a real app, you might want to show a SnackBar or handle this error
    }
  }
}
