/// Reusable High-Precision Degree Formatter for KP Astrology
/// Converts any longitude into exact DD°MM'SS" format inside its Zodiac Sign (0°..30°)
class KPDegreeFormatter {
  /// Format degree inside zodiac sign (0..30°) as DD°MM'SS"
  ///
  /// Algorithm:
  /// 1. Normalize longitude to 0–360.
  /// 2. Get degree inside sign: signDegree = longitude % 30.
  /// 3. degree = signDegree.floor()
  /// 4. remainingMinutes = (signDegree - degree) * 60
  /// 5. minute = remainingMinutes.floor()
  /// 6. second = ((remainingMinutes - minute) * 60).round()
  /// 7. Handle rounding overflow:
  ///    if second == 60: second = 0; minute++;
  ///    if minute == 60: minute = 0; degree++;
  ///    if degree == 30: degree = 29, minute = 59, second = 59 (or 0 for next sign boundary)
  /// 8. Format: DD°MM'SS" with two-digit padding. Example: 23°14'04"
  static String formatRasiDegree(double longitude) {
    // 1. Normalize longitude to 0 <= longitude < 360
    double norm = longitude % 360.0;
    if (norm < 0) norm += 360.0;

    int rasiIndex = (norm / 30.0).floor().clamp(0, 11);

    // 2. Degree inside sign (0 <= signDegree < 30)
    double signDegree = norm % 30.0;

    // 3. Extract degree
    int degree = signDegree.floor();

    // 4. Extract remaining minutes
    double remainingMinutes = (signDegree - degree) * 60.0;

    // 5. Extract minute
    int minute = remainingMinutes.floor();

    // 6. Extract second
    int second = ((remainingMinutes - minute) * 60.0).round();

    // 7. Handle rounding overflow
    if (second >= 60) {
      second = 0;
      minute += 1;
    }
    if (minute >= 60) {
      minute = 0;
      degree += 1;
    }
    if (degree >= 30) {
      if (rasiIndex == 11 && norm >= 359.999) {
        // Pisces boundary: stays in Meenam at max valid second, preventing invalid 30°
        degree = 29;
        minute = 59;
        second = 59;
      } else {
        // Moves to next sign boundary at 00°00'00"
        degree = 0;
        minute = 0;
        second = 0;
      }
    }

    // 8. Return DD°MM'SS"
    final degStr = degree.toString().padLeft(2, '0');
    final minStr = minute.toString().padLeft(2, '0');
    final secStr = second.toString().padLeft(2, '0');

    return '$degStr°$minStr\'$secStr"';
  }

  /// Format absolute longitude (0..360°) as DDD°MM'SS"
  static String formatAbsoluteDegree(double longitude) {
    double norm = longitude % 360.0;
    if (norm < 0) norm += 360.0;

    int degree = norm.floor();
    double remMin = (norm - degree) * 60.0;
    int minute = remMin.floor();
    int second = ((remMin - minute) * 60.0).round();

    if (second >= 60) {
      second = 0;
      minute += 1;
    }
    if (minute >= 60) {
      minute = 0;
      degree += 1;
    }
    if (degree >= 360) {
      degree = 0;
    }

    final degStr = degree.toString().padLeft(2, '0');
    final minStr = minute.toString().padLeft(2, '0');
    final secStr = second.toString().padLeft(2, '0');

    return '$degStr°$minStr\'$secStr"';
  }
}
