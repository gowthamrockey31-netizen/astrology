import '../../services/astrology_calculator.dart' as service;

class AstrologyCalculator {
  /// Calculate Sidereal Zodiac sign based on birth date
  static String calculateZodiac(DateTime dob) {
    final astroData = service.AstrologyCalculator.calculateHoroscope(
      dateOfBirth: dob,
      latitude: 13.0827,
      longitude: 80.2707,
      utcOffsetHours: 5.5,
    );
    final moon = astroData.moon;
    return "${moon.rasiNameEn} (${moon.rasiNameTa})";
  }

  /// Calculate Nakshatra based on birth date and time
  static String calculateNakshatra(DateTime dob, String timeOfBirth) {
    final timeParts = timeOfBirth.split(':');
    int hour = 8;
    int minute = 30;
    if (timeParts.length >= 2) {
      hour = int.tryParse(timeParts[0].replaceAll(RegExp(r'[^0-9]'), '')) ?? 8;
      minute = int.tryParse(timeParts[1].replaceAll(RegExp(r'[^0-9]'), '')) ?? 30;
      if (timeOfBirth.toUpperCase().contains('PM') && hour < 12) hour += 12;
      if (timeOfBirth.toUpperCase().contains('AM') && hour == 12) hour = 0;
    }
    final dt = DateTime(dob.year, dob.month, dob.day, hour, minute);
    final astroData = service.AstrologyCalculator.calculateHoroscope(
      dateOfBirth: dt,
      latitude: 13.0827,
      longitude: 80.2707,
      utcOffsetHours: 5.5,
    );
    final moon = astroData.moon;
    return "${moon.nakshatraNameTa} (${moon.nakshatraNameEn})";
  }

  /// Calculate Lagna (Ascendant) based on exact date and time of birth
  static String calculateLagna(String timeOfBirth, {DateTime? birthDate}) {
    final baseDate = birthDate ?? DateTime(1996, 6, 15);
    final timeParts = timeOfBirth.split(':');
    int hour = 8;
    int minute = 30;
    if (timeParts.length >= 2) {
      hour = int.tryParse(timeParts[0].replaceAll(RegExp(r'[^0-9]'), '')) ?? 8;
      minute = int.tryParse(timeParts[1].replaceAll(RegExp(r'[^0-9]'), '')) ?? 30;
      if (timeOfBirth.toUpperCase().contains('PM') && hour < 12) hour += 12;
      if (timeOfBirth.toUpperCase().contains('AM') && hour == 12) hour = 0;
    }
    final dt = DateTime(baseDate.year, baseDate.month, baseDate.day, hour, minute);
    final astroData = service.AstrologyCalculator.calculateHoroscope(
      dateOfBirth: dt,
      latitude: 13.0827,
      longitude: 80.2707,
      utcOffsetHours: 5.5,
    );
    final lagna = astroData.lagna;
    return "${lagna.rasiNameTa} (${lagna.rasiNameEn})";
  }

  /// Calculate Current Mahadasha Lord
  static String calculateCurrentDasha(DateTime dob) {
    final astroData = service.AstrologyCalculator.calculateHoroscope(
      dateOfBirth: dob,
      latitude: 13.0827,
      longitude: 80.2707,
      utcOffsetHours: 5.5,
    );
    final moon = astroData.moon;
    return "${moon.starLord} Mahadasha";
  }
}
