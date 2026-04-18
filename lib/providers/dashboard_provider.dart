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
  final Set<String> _expandedPrayers = {};

  UserModel? get user => _user;
  PrayerTimesModel? get prayerTimes => _prayerTimes;
  PrayerLogModel? get todayLog => _todayLog;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool isExpanded(String id) => _expandedPrayers.contains(id);

  String get _todayDate =>
      DateFormat('dd-MM-yyyy').format(DateTime.now());

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
      
      // Filter out default "missed" prayers that haven't been intentionally marked by the user
      final rawLog = results[2] as PrayerLogModel;
      Map<String, PrayerStatus> filteredPrayers = {};
      rawLog.prayers.forEach((key, value) {
        if (!(value.status == 'missed' && value.markedAt == null)) {
          filteredPrayers[key] = value;
        }
      });
      
      _todayLog = PrayerLogModel(
        date: rawLog.date,
        streak: rawLog.streak,
        prayers: filteredPrayers,
      );

      // Auto-expand naturally marked prayers
      _expandedPrayers.clear();
      _todayLog!.prayers.forEach((key, value) {
        if (value.status != 'empty') {
          _expandedPrayers.add(key);
        }
      });

      _error = null;
    } catch (e) {
      _error = e.toString();
      print('DashboardProvider Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Tapping the checkbox toggles the status-button section.
  /// - Collapsed & unmarked → expand.
  /// - Expanded & unmarked → collapse.
  /// - Already marked → always keep expanded (so user can re-pick).
  void toggleCard(String prayerId) {
    final alreadyMarked = (_todayLog?.prayers[prayerId]?.status ?? 'empty') != 'empty';
    if (alreadyMarked) {
      // Stay open; tapping again clears the status so user can re-pick
      markPrayer(prayerId, 'empty');
      return;
    }
    if (_expandedPrayers.contains(prayerId)) {
      _expandedPrayers.remove(prayerId);
    } else {
      _expandedPrayers.add(prayerId);
    }
    notifyListeners();
  }

  Future<void> markPrayer(String prayerName, String status) async {
    final key = prayerName.toLowerCase();

    // Auto-expand when a status is selected
    if (status != 'empty') _expandedPrayers.add(key);

    // Optimistic UI update
    final currentPrayers =
        Map<String, PrayerStatus>.from(_todayLog?.prayers ?? {});

    if (status == 'empty') {
      currentPrayers.remove(key);
    } else {
      currentPrayers[key] = PrayerStatus(
        status: status,
        markedAt: DateFormat('HH:mm').format(DateTime.now()),
      );
    }

    _todayLog = PrayerLogModel(
      date: _todayLog?.date ?? _todayDate,
      streak: _todayLog?.streak ?? Streak(current: 0, longest: 0),
      prayers: currentPrayers,
    );
    notifyListeners();

    if (status == 'empty') return; // No need to call API for un-marking

    try {
      final now = DateTime.now();
      final markedAt = DateFormat('HH:mm').format(now);

      final result = await _apiService.markPrayer(
        date: _todayDate,
        prayer: key,
        status: status.toLowerCase().replaceAll(' ', '_'),
        markedAt: markedAt,
      );

      // Sync streak from server
      if (result['streak'] != null && _user != null) {
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
        // Keep expanded for any prayer that has a status
        _todayLog!.prayers.forEach((k, v) {
          if (v.status != 'empty') _expandedPrayers.add(k);
        });
      }

      notifyListeners();
    } catch (e) {
      print('Error marking prayer: $e');
    }
  }
}
