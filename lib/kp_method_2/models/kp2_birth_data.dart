import 'package:intl/intl.dart';
import '../../models/user_model.dart';

/// Complete Birth Input Data for KP Method 2
class KP2BirthData {
  final DateTime date;
  final String time; // e.g. "01:25 PM" or "13:25"
  final String place;
  final double latitude;
  final double longitude;
  final double timezone;

  const KP2BirthData({
    required this.date,
    required this.time,
    required this.place,
    required this.latitude,
    required this.longitude,
    required this.timezone,
  });

  /// Parse the local DateTime combining date and time string
  DateTime get localDateTime {
    final cleanTime = time.trim().toUpperCase();
    final parts = cleanTime.replaceAll(RegExp(r'[^0-9:]'), '').split(':');
    int hour = 12;
    int minute = 0;
    int second = 0;

    if (parts.isNotEmpty) hour = int.tryParse(parts[0]) ?? 12;
    if (parts.length > 1) minute = int.tryParse(parts[1]) ?? 0;
    if (parts.length > 2) second = int.tryParse(parts[2]) ?? 0;

    if (cleanTime.contains('PM') && hour < 12) hour += 12;
    if (cleanTime.contains('AM') && hour == 12) hour = 0;

    return DateTime(date.year, date.month, date.day, hour, minute, second);
  }

  /// UTC DateTime computed from local DateTime and timezone offset
  DateTime get utcDateTime {
    final local = localDateTime;
    final offsetMinutes = (timezone * 60).round();
    return local.subtract(Duration(minutes: offsetMinutes));
  }

  /// Non-intrusive Adapter for existing UserModel without modifying UserModel
  factory KP2BirthData.fromUserModel(UserModel user) {
    DateTime parsedDate;
    try {
      parsedDate = DateTime.tryParse(user.dob) ??
          DateFormat('dd-MM-yyyy').tryParse(user.dob) ??
          DateFormat('yyyy-MM-dd').tryParse(user.dob) ??
          DateTime(1995, 8, 15);
    } catch (_) {
      parsedDate = DateTime(1995, 8, 15);
    }

    return KP2BirthData(
      date: parsedDate,
      time: user.timeOfBirth.isNotEmpty ? user.timeOfBirth : '01:25 PM',
      place: user.placeOfBirth.isNotEmpty ? user.placeOfBirth : 'Erode',
      latitude: user.latitude != 0.0 ? user.latitude : 11.3410,
      longitude: user.longitude != 0.0 ? user.longitude : 77.7172,
      timezone: user.timezone != 0.0 ? user.timezone : 5.5,
    );
  }

  /// Default reference test profile: 15-08-1995, 1:25 PM, Erode (11.3410, 77.7172, UTC+5.5)
  factory KP2BirthData.defaultTestProfile() {
    return KP2BirthData(
      date: DateTime(1995, 8, 15),
      time: '01:25 PM',
      place: 'Erode, Tamil Nadu',
      latitude: 11.3410,
      longitude: 77.7172,
      timezone: 5.5,
    );
  }
}
