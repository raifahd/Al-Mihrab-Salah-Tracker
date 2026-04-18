class UserModel {
  final String id;
  final String name;
  final String email;
  final Location? location;
  final Streak streak;
  final UserSettings settings;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.location,
    required this.streak,
    required this.settings,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      location: json['location'] != null ? Location.fromJson(json['location']) : null,
      streak: Streak.fromJson(json['streak'] ?? {}),
      settings: UserSettings.fromJson(json['settings'] ?? {}),
    );
  }
}

class UserSettings {
  final int school;
  final int calculationMethod;
  final String language;
  final bool is24HourFormat;

  UserSettings({
    required this.school,
    required this.calculationMethod,
    required this.language,
    required this.is24HourFormat,
  });

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      school: json['school'] ?? 0,
      calculationMethod: json['calculationMethod'] ?? 1,
      language: json['language'] ?? 'en',
      is24HourFormat: json['is24HourFormat'] ?? false,
    );
  }
}

class Location {
  final String city;
  final String country;
  final double? latitude;
  final double? longitude;

  Location({
    required this.city,
    required this.country,
    this.latitude,
    this.longitude,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      city: json['city'] ?? '',
      country: json['country'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }
}

class Streak {
  final int current;
  final int longest;
  final String? lastCompletedDate;

  Streak({
    required this.current,
    required this.longest,
    this.lastCompletedDate,
  });

  factory Streak.fromJson(Map<String, dynamic> json) {
    return Streak(
      current: json['current'] ?? 0,
      longest: json['longest'] ?? 0,
      lastCompletedDate: json['lastCompletedDate'],
    );
  }
}
