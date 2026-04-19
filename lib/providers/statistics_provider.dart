import 'package:flutter/material.dart';
import '../services/api_service.dart';

// ─── Analytics Models ───────────────────────────────────────────────────────

class AnalyticsSummary {
  final int totalLogged;
  final int completed;
  final int missed;
  final int late;
  final int onTime;
  final int congregation;
  final int overallCompletionRate;
  final int consistencyScore;

  const AnalyticsSummary({
    required this.totalLogged,
    required this.completed,
    required this.missed,
    required this.late,
    required this.onTime,
    required this.congregation,
    required this.overallCompletionRate,
    required this.consistencyScore,
  });

  factory AnalyticsSummary.fromJson(Map<String, dynamic> json) =>
      AnalyticsSummary(
        totalLogged: json['totalLogged'] ?? 0,
        completed: json['completed'] ?? 0,
        missed: json['missed'] ?? 0,
        late: json['late'] ?? 0,
        onTime: json['onTime'] ?? 0,
        congregation: json['congregation'] ?? 0,
        overallCompletionRate: json['overallCompletionRate'] ?? 0,
        consistencyScore: json['consistencyScore'] ?? 0,
      );
}

class StreakInfo {
  final int current;
  final int longest;

  const StreakInfo({required this.current, required this.longest});

  factory StreakInfo.fromJson(Map<String, dynamic> json) => StreakInfo(
        current: json['current'] ?? 0,
        longest: json['longest'] ?? 0,
      );
}

class PerPrayerStat {
  final int completionRate;
  final int onTimeRate;
  final int lateRate;
  final int congregationRate;

  const PerPrayerStat({
    required this.completionRate,
    required this.onTimeRate,
    required this.lateRate,
    required this.congregationRate,
  });

  factory PerPrayerStat.fromJson(Map<String, dynamic> json) => PerPrayerStat(
        completionRate: json['completionRate'] ?? 0,
        onTimeRate: json['onTimeRate'] ?? 0,
        lateRate: json['lateRate'] ?? 0,
        congregationRate: json['congregationRate'] ?? 0,
      );
}

class HeatmapEntry {
  final String date; // dd-MM-yyyy
  final int score;   // 0–15
  final int completedCount; // 0-5

  const HeatmapEntry({required this.date, required this.score, this.completedCount = 0});

  factory HeatmapEntry.fromJson(Map<String, dynamic> json) {
    int completed = 0;
    final prayersObj = json['prayers'];
    if (prayersObj != null && prayersObj is Map) {
      prayersObj.forEach((key, value) {
        final status = value is String ? value : (value as Map<String, dynamic>?)?['status'] ?? 'missed';
        if (status != 'missed') {
          completed++;
        }
      });
    }

    return HeatmapEntry(
      date: json['date'] ?? '',
      score: json['score'] ?? 0,
      completedCount: completed,
    );
  }
}

class AnalyticsData {
  final AnalyticsSummary summary;
  final StreakInfo streak;
  final Map<String, PerPrayerStat> perPrayer;
  final String bestPrayer;
  final String worstPrayer;
  final List<HeatmapEntry> heatmap;

  const AnalyticsData({
    required this.summary,
    required this.streak,
    required this.perPrayer,
    required this.bestPrayer,
    required this.worstPrayer,
    required this.heatmap,
  });

  factory AnalyticsData.fromJson(Map<String, dynamic> json) {
    final perPrayerMap = <String, PerPrayerStat>{};
    final perPrayerJson = json['perPrayer'] as Map<String, dynamic>? ?? {};
    perPrayerJson.forEach((key, value) {
      perPrayerMap[key] = PerPrayerStat.fromJson(value as Map<String, dynamic>);
    });

    final heatmapList = (json['heatmap'] as List<dynamic>? ?? [])
        .map((e) => HeatmapEntry.fromJson(e as Map<String, dynamic>))
        .toList();

    return AnalyticsData(
      summary: AnalyticsSummary.fromJson(json['summary'] as Map<String, dynamic>? ?? {}),
      streak: StreakInfo.fromJson(json['streak'] as Map<String, dynamic>? ?? {}),
      perPrayer: perPrayerMap,
      bestPrayer: (json['bestPrayer'] as Map<String, dynamic>?)?['name'] ?? '',
      worstPrayer: (json['worstPrayer'] as Map<String, dynamic>?)?['name'] ?? '',
      heatmap: heatmapList,
    );
  }
}

// ─── Provider ────────────────────────────────────────────────────────────────

class StatisticsProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  AnalyticsData? _data;
  bool _isLoading = false;
  String? _error;

  AnalyticsData? get data => _data;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchAnalytics() async {
    if (_isLoading) return;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final json = await _apiService.getPrayerAnalytics();
      _data = AnalyticsData.fromJson(json);
      _error = null;
    } catch (e) {
      _error = e.toString();
      debugPrint('StatisticsProvider Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
