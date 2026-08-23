import '../models/nazhigai_result.dart';
import 'astrology_calculator.dart';

class NazhigaiCalculator {
  /// 1 Nazhigai = 24 minutes = 1,440 seconds
  static const double secondsPerNazhigai = 1440.0;

  /// 1 Vinazhigai = 24 seconds
  static const double secondsPerVinazhigai = 24.0;

  /// Calculates Udayadhi Nazhigai & Vinazhigai from Sunrise to Event Time
  static NazhigaiResult calculateNazhigai({
    required DateTime eventTime,
    required DateTime sunriseTime,
  }) {
    late DateTime effectiveSunrise = sunriseTime;

    // Handle overnight boundary where eventTime is before sunrise on the same date
    if (eventTime.isBefore(sunriseTime)) {
      // Shift back by 24 hours to use previous day's sunrise
      effectiveSunrise = sunriseTime.subtract(const Duration(days: 1));
    }

    final totalElapsedMs = eventTime.difference(effectiveSunrise).inMilliseconds.toDouble();
    final totalElapsedSeconds = totalElapsedMs / 1000.0;

    final totalNazhigai = totalElapsedSeconds / secondsPerNazhigai;
    final nazhigaiInt = totalNazhigai.floor();

    final remainderNazhigaiFrac = totalNazhigai - nazhigaiInt;
    final totalVinazhigai = remainderNazhigaiFrac * 60.0;
    final vinazhigaiInt = totalVinazhigai.floor();

    final remainingSeconds = (totalVinazhigai - vinazhigaiInt) * secondsPerVinazhigai;

    final formattedTa = "$nazhigaiInt நாழிகை ${vinazhigaiInt.toString().padLeft(2, '0')} விநாழிகை";
    final formattedEn = "$nazhigaiInt Nazhi ${vinazhigaiInt.toString().padLeft(2, '0')} Vinazhi";

    return NazhigaiResult(
      nazhigai: nazhigaiInt,
      vinazhigai: vinazhigaiInt,
      remainingSeconds: remainingSeconds,
      totalElapsedSeconds: totalElapsedSeconds,
      formattedValueTa: formattedTa,
      formattedValueEn: formattedEn,
      sunriseTime: effectiveSunrise,
      eventTime: eventTime,
    );
  }

  /// Conveniece calculator taking Date, Time, Lat, Long
  static NazhigaiResult calculateUdayadhiNazhigaiForLocation({
    required DateTime eventTime,
    required double latitude,
    required double longitude,
    double utcOffsetHours = 5.5,
  }) {
    final sun = AstrologyCalculator.calculateSunriseSunset(eventTime, latitude, longitude, utcOffsetHours);
    final sunrise = sun['sunrise']!;

    return calculateNazhigai(eventTime: eventTime, sunriseTime: sunrise);
  }
}
