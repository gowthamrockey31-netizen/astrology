import '../services/astrology_calculator.dart';
import '../services/tithi_calculator.dart';

/// Centralized Immutable Source of Truth for Horoscope Calculations
class HoroscopeCalculationResult {
  final DateTime dateOfBirth;
  final double latitude;
  final double longitude;
  final double utcOffsetHours;
  final double julianDay;
  final double ayanamsa;
  final Map<String, PlanetDetail> planets;
  final PlanetDetail lagna;
  final PlanetDetail moon;
  final PlanetDetail sun;
  final TithiDetail tithi;
  final int karanaIndex;
  final String karanaNameTa;
  final String karanaNameEn;
  final int yogaIndex;
  final String yogaNameTa;
  final String yogaNameEn;
  final String tamilMonthTa;
  final int tamilDay;
  final String tamilDateFormatted;
  final String birthHoraLordTa;
  final String birthHoraLordEn;
  final DateTime sunrise;
  final DateTime sunset;
  final String udayathiNazhiStr;
  final String nakshatraNazhiStr;

  const HoroscopeCalculationResult({
    required this.dateOfBirth,
    required this.latitude,
    required this.longitude,
    required this.utcOffsetHours,
    required this.julianDay,
    required this.ayanamsa,
    required this.planets,
    required this.lagna,
    required this.moon,
    required this.sun,
    required this.tithi,
    required this.karanaIndex,
    required this.karanaNameTa,
    required this.karanaNameEn,
    required this.yogaIndex,
    required this.yogaNameTa,
    required this.yogaNameEn,
    required this.tamilMonthTa,
    required this.tamilDay,
    required this.tamilDateFormatted,
    required this.birthHoraLordTa,
    required this.birthHoraLordEn,
    required this.sunrise,
    required this.sunset,
    required this.udayathiNazhiStr,
    required this.nakshatraNazhiStr,
  });

  /// Operator [] for backwards compatibility with legacy Map access
  dynamic operator [](String key) {
    switch (key) {
      case 'ayanamsa':
        return ayanamsa;
      case 'planets':
        return planets;
      case 'lagna':
        return lagna;
      case 'moon':
        return moon;
      case 'sun':
        return sun;
      case 'tithi':
        return tithi;
      default:
        return null;
    }
  }

  /// Format Ayanamsa as degrees, minutes, seconds (e.g. 23°51'25")
  String get ayanamsaFormatted {
    final ayDeg = ayanamsa.floor();
    final ayMin = ((ayanamsa - ayDeg) * 60).floor();
    final aySec = (((ayanamsa - ayDeg) * 60 - ayMin) * 60).round();
    return "$ayDeg°${ayMin.toString().padLeft(2, '0')}'${aySec.toString().padLeft(2, '0')}\"";
  }
}
