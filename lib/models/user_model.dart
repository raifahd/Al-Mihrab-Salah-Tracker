class UserModel {
  final String id;
  final String name;
  final String email;
  final Location? location;
  final Streak streak;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.location,
    required this.streak,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      location: json['location'] != null ? Location.fromJson(json['location']) : null,
      streak: Streak.fromJson(json['streak'] ?? {}),
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
