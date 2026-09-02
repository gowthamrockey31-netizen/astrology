import '../../models/user_model.dart';

/// KP Birth Data model containing exact spacetime coordinates for astronomical calculation
class KPBirthData {
  final DateTime dateTime;
  final double latitude;
  final double longitude;
  final String placeName;
  final Duration timeZone;

  const KPBirthData({
    required this.dateTime,
    required this.latitude,
    required this.longitude,
    required this.placeName,
    required this.timeZone,
  });

  /// UTC offset in decimal hours (e.g. 5.5 for IST)
  double get utcOffsetHours => timeZone.inMinutes / 60.0;

  /// Construct from existing UserModel / Horoscope Profile
  factory KPBirthData.fromUser(UserModel user) {
    final parsedDob = DateTime.tryParse(user.dob) ?? DateTime(1996, 6, 15);
    final tobParts = user.timeOfBirth.split(':');
    int hour = 8;
    int minute = 30;
    if (tobParts.length >= 2) {
      hour = int.tryParse(tobParts[0].replaceAll(RegExp(r'[^0-9]'), '')) ?? 8;
      minute = int.tryParse(tobParts[1].replaceAll(RegExp(r'[^0-9]'), '')) ?? 30;
      if (user.timeOfBirth.toUpperCase().contains('PM') && hour < 12) hour += 12;
      if (user.timeOfBirth.toUpperCase().contains('AM') && hour == 12) hour = 0;
    }

    final birthDt = DateTime(parsedDob.year, parsedDob.month, parsedDob.day, hour, minute);
    final tzHours = user.timezone != 0.0 ? user.timezone : 5.5;
    final tzMinutes = (tzHours * 60).round();

    return KPBirthData(
      dateTime: birthDt,
      latitude: user.latitude != 0.0 ? user.latitude : 13.0827,
      longitude: user.longitude != 0.0 ? user.longitude : 80.2707,
      placeName: user.placeOfBirth.isNotEmpty
          ? user.placeOfBirth
          : (user.city.isNotEmpty ? user.city : 'Chennai, India'),
      timeZone: Duration(minutes: tzMinutes),
    );
  }

  /// Default fallback birth data
  factory KPBirthData.defaultData() {
    return KPBirthData(
      dateTime: DateTime(1996, 6, 15, 8, 30),
      latitude: 13.0827,
      longitude: 80.2707,
      placeName: 'Chennai, Tamil Nadu, India',
      timeZone: const Duration(hours: 5, minutes: 30),
    );
  }

  KPBirthData copyWith({
    DateTime? dateTime,
    double? latitude,
    double? longitude,
    String? placeName,
    Duration? timeZone,
  }) {
    return KPBirthData(
      dateTime: dateTime ?? this.dateTime,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      placeName: placeName ?? this.placeName,
      timeZone: timeZone ?? this.timeZone,
    );
  }

  @override
  String toString() =>
      'KPBirthData(dt: $dateTime, lat: $latitude, lon: $longitude, place: $placeName, tz: $timeZone)';
}
