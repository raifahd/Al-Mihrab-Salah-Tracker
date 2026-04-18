import 'user_model.dart';

class PrayerLogModel {
  final String date;
  final Streak streak;
  final Map<String, PrayerStatus> prayers;

  PrayerLogModel({
    required this.date,
    required this.streak,
    required this.prayers,
  });

  factory PrayerLogModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> prayersJson = json['prayers'] ?? {};
    final Map<String, PrayerStatus> prayersMap = {};
    
    prayersJson.forEach((key, value) {
      prayersMap[key] = PrayerStatus.fromJson(value);
    });

    return PrayerLogModel(
      date: json['date'] ?? '',
      streak: Streak.fromJson(json['streak'] ?? {}),
      prayers: prayersMap,
    );
  }
}

class PrayerStatus {
  final String status;
  final String? markedAt;

  PrayerStatus({
    required this.status,
    this.markedAt,
  });

  factory PrayerStatus.fromJson(Map<String, dynamic> json) {
    return PrayerStatus(
      status: json['status'] ?? 'empty',
      markedAt: json['markedAt'],
    );
  }
}
