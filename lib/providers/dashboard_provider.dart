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
  /// Prayer times for the active (Islamic) day. During the pre-Fajr window
  /// this is *yesterday's* times so the tracker card states are correct.
  PrayerTimesModel? _trackerTimes;
  PrayerLogModel? _todayLog;
  bool _isLoading = false;
  String? _error;
  final Set<String> _expandedPrayers = {};

  /// The "active" date used for logging. Stays on the previous calendar
  /// date until Fajr of the new day arrives, so users who pray Isha after
  /// midnight can still log it against the correct Islamic day.
  String? _activeDate;

  UserModel? get user => _user;
  /// Today's prayer times — used for the header countdown card.
  PrayerTimesModel? get prayerTimes => _prayerTimes;
  /// Prayer times for the active Islamic day — used for the tracker card states.
  /// Equals [prayerTimes] normally; equals yesterday's times during pre-Fajr window.
  PrayerTimesModel? get trackerTimes => _trackerTimes ?? _prayerTimes;
  /// True when the current clock time is before today's Fajr (i.e., we are
  /// still in the previous Islamic day).
  bool get isPreFajrWindow => _activeDate != null && _activeDate != _calendarDate;
  PrayerLogModel? get todayLog => _todayLog;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool isExpanded(String id) => _expandedPrayers.contains(id);

  /// Returns the date string (dd-MM-yyyy) for the current calendar day.
  String get _calendarDate =>
      DateFormat('dd-MM-yyyy').format(DateTime.now());

  /// Returns the effective Islamic date for logging prayers.
  /// If [_activeDate] has been computed (i.e., prayer times are loaded) use it,
  /// otherwise fall back to the calendar date.
  String get _logDate => _activeDate ?? _calendarDate;

  /// Determines the effective logging date given today's Fajr time string
  /// (format "HH:mm"). If current clock time is before Fajr, the previous
  /// calendar day is still the active Islamic day.
  String _computeActiveDate(String? fajrTime) {
    if (fajrTime == null || fajrTime == '--:--') return _calendarDate;
    try {
      final cleanFajr = fajrTime.split(' ').first; // strip timezone suffix
      final parts = cleanFajr.split(':');
      final now = DateTime.now();
      final fajrDt = DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(parts[0]),
        int.parse(parts[1]),
      );
      // Before Fajr → still the previous Islamic day
      if (now.isBefore(fajrDt)) {
        final yesterday = now.subtract(const Duration(days: 1));
        return DateFormat('dd-MM-yyyy').format(yesterday);
      }
    } catch (_) {}
    return _calendarDate;
  }

  Future<void> init() async {
    await fetchDashboardData();
  }

  PrayerLogModel _filterLog(PrayerLogModel raw) {
    Map<String, PrayerStatus> filtered = {};
    raw.prayers.forEach((key, value) {
      if (!(value.status == 'missed' && value.markedAt == null)) {
        filtered[key] = value;
      }
    });
    return PrayerLogModel(
      date: raw.date,
      streak: raw.streak,
      prayers: filtered,
    );
  }

  Future<void> fetchDashboardData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Step 1: Fetch profile & TODAY's prayer times in parallel.
      // We always fetch times for the calendar date to show the correct
      // upcoming prayer card countdown.
      final step1 = await Future.wait([
        _apiService.getProfile(),
        _apiService.getPrayerTimes(_calendarDate),
      ]);

      _user = step1[0] as UserModel;
      _prayerTimes = step1[1] as PrayerTimesModel;

      // Step 2: Determine effective Islamic date using today's Fajr.
      _activeDate = _computeActiveDate(_prayerTimes!.prayers['fajr']);

      // Step 3: If we are in the pre-Fajr window, fetch YESTERDAY's prayer
      // times so the tracker card states (past/current/upcoming) are correct.
      // After midnight but before Fajr, all of today's prayers are in the
      // future relative to the wall clock, making them all look "upcoming".
      if (_activeDate != _calendarDate) {
        final results = await Future.wait([
          _apiService.getPrayerTimes(_activeDate!), // yesterday's times
          _apiService.getTodayLog(_activeDate!),
        ]);
        _trackerTimes = results[0] as PrayerTimesModel;
        _todayLog = _filterLog(results[1] as PrayerLogModel);
      } else {
        _trackerTimes = null; // same day — no separate tracker times needed
        final rawLog = await _apiService.getTodayLog(_activeDate!);
        _todayLog = _filterLog(rawLog);
      }

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

  void toggleCard(String prayerId) {
    final alreadyMarked =
        (_todayLog?.prayers[prayerId]?.status ?? 'empty') != 'empty';
    if (alreadyMarked) {
      // It is permanently expanded once marked; clicking the box does nothing.
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

    if (status != 'empty') _expandedPrayers.add(key);

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
      date: _todayLog?.date ?? _logDate,
      streak: _todayLog?.streak ?? Streak(current: 0, longest: 0),
      prayers: currentPrayers,
    );
    notifyListeners();

    if (status == 'empty') return;

    try {
      final markedAt = DateFormat('HH:mm').format(DateTime.now());

      final result = await _apiService.markPrayer(
        date: _logDate,
        prayer: key,
        status: status.toLowerCase().replaceAll(' ', '_'),
        markedAt: markedAt,
      );

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
        final rawLog = PrayerLogModel.fromJson(result['todayLog']);
        _todayLog = _filterLog(rawLog);

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

