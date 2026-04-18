class PrayerTimesModel {
  final String date;
  final HijriDate hijriDate;
  final Map<String, String> prayers;
  final LocationInfo location;

  PrayerTimesModel({
    required this.date,
    required this.hijriDate,
    required this.prayers,
    required this.location,
  });

  factory PrayerTimesModel.fromJson(Map<String, dynamic> json) {
    return PrayerTimesModel(
      date: json['date'] ?? '',
      hijriDate: HijriDate.fromJson(json['hijriDate'] ?? {}),
      prayers: Map<String, String>.from(json['prayers'] ?? {}),
      location: LocationInfo.fromJson(json['location'] ?? {}),
    );
  }
}

class HijriDate {
  final String day;
  final String month;
  final String monthAr;
  final String year;
  final String readable;

  HijriDate({
    required this.day,
    required this.month,
    required this.monthAr,
    required this.year,
    required this.readable,
  });

  factory HijriDate.fromJson(Map<String, dynamic> json) {
    return HijriDate(
      day: json['day'] ?? '',
      month: json['month'] ?? '',
      monthAr: json['monthAr'] ?? '',
      year: json['year'] ?? '',
      readable: json['readable'] ?? '',
    );
  }
}

class LocationInfo {
  final double lat;
  final double lon;
  final String city;

  LocationInfo({
    required this.lat,
    required this.lon,
    required this.city,
  });

  factory LocationInfo.fromJson(Map<String, dynamic> json) {
    return LocationInfo(
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lon: (json['lon'] as num?)?.toDouble() ?? 0.0,
      city: json['city'] ?? '',
    );
  }
}
