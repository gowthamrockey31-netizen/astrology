import '../../services/astrology_calculator.dart';

/// Isolated Krishnamurti Padhdhati (KP) Ayanamsa calculation engine
class KPAyanamsaEngine {
  /// Calculate standard KP Ayanamsa for a given DateTime and UTC offset
  /// Uses Prof. K.S. Krishnamurti standard epoch precession
  static double calculateAyanamsa(DateTime dateTime, {double utcOffsetHours = 5.5}) {
    final double jd = AstrologyCalculator.getJulianDay(dateTime, utcOffsetHours: utcOffsetHours);
    final double t = (jd - 2451545.0) / 36525.0; // Centuries from J2000.0
    // Standard KP polynomial formula
    final double ayanamsa = 23.765555 + (1.396041 * t) + (0.000308 * t * t);
    return ayanamsa;
  }
}
