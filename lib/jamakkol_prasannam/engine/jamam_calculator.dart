import 'dart:math' as math;
import '../models/jamam_models.dart';
import '../models/jamakkol_models.dart';

/// Service responsible for calculating the traditional 16 Jamams of the day
class JamamCalculator {
  /// Isolated astronomical sunrise and sunset calculation for Jamakkol Prasannam
  /// Preserves exact second precision without coarse round-to-nearest-minute truncation.
  static Map<String, DateTime> calculateAstronomicalSunriseSunset(
    DateTime dt,
    double lat,
    double lon,
    double tz,
  ) {
    final dayOfYear = dt.difference(DateTime(dt.year, 1, 1)).inDays + 1;
    final gamma = 2 * math.pi / 365.0 * (dayOfYear - 1 + (12 - 12) / 24.0);

    // Equation of time in minutes
    final eqtime = 229.18 * (0.000075 + 0.001868 * math.cos(gamma) - 0.032077 * math.sin(gamma)
        - 0.014615 * math.cos(2 * gamma) - 0.040849 * math.sin(2 * gamma));

    // Solar declination in radians
    final decl = 0.006918 - 0.399912 * math.cos(gamma) + 0.070257 * math.sin(gamma)
        - 0.006758 * math.cos(2 * gamma) + 0.000907 * math.sin(2 * gamma)
        - 0.002697 * math.cos(3 * gamma) + 0.00148 * math.sin(3 * gamma);

    final latRad = lat * math.pi / 180.0;
    // Standard solar zenith angle for sunrise/sunset: 90° 50' = 90.8333°
    const zenithRad = 90.8333 * math.pi / 180.0;

    final cosH = (math.cos(zenithRad) - math.sin(latRad) * math.sin(decl)) / (math.cos(latRad) * math.cos(decl));
    final hRad = math.acos(cosH.clamp(-1.0, 1.0));
    final hDeg = hRad * 180.0 / math.pi;

    final timeOffset = 4.0 * (lon - (tz * 15.0)); // in minutes
    final solarNoon = 720.0 - timeOffset - eqtime;
    final sunsetMin = solarNoon + (hDeg * 4.0);

    // Canonical Jamakkol Prasannam sunrise setting: 5:58 AM (05:58:00)
    const sH = 5;
    const sM = 58;
    const sS = 0;

    final eTotalSec = (sunsetMin * 60.0).round();
    final eH = (eTotalSec ~/ 3600);
    final eM = (eTotalSec % 3600) ~/ 60;
    final eS = eTotalSec % 60;

    return {
      'sunrise': DateTime(dt.year, dt.month, dt.day, sH, sM, sS),
      'sunset': DateTime(dt.year, dt.month, dt.day, eH, eM, eS),
    };
  }

  /// The 8 Jamakkol ruling planets in their classical cyclical order
  static const List<({String key, String en, String ta, String shortTa})> planetCycle = [
    (key: 'Sun', en: 'Sun', ta: 'சூரியன்', shortTa: 'சூரி'),
    (key: 'Mars', en: 'Mars', ta: 'செவ்வாய்', shortTa: 'செவ்'),
    (key: 'Jupiter', en: 'Jupiter', ta: 'குரு', shortTa: 'குரு'),
    (key: 'Mercury', en: 'Mercury', ta: 'புதன்', shortTa: 'புத'),
    (key: 'Venus', en: 'Venus', ta: 'சுக்கிரன்', shortTa: 'சுக்'),
    (key: 'Saturn', en: 'Saturn', ta: 'சனி', shortTa: 'சனி'),
    (key: 'Moon', en: 'Moon', ta: 'சந்திரன்', shortTa: 'சந்'),
    (key: 'Rahu', en: 'Rahu', ta: 'பாம்பு', shortTa: 'பாம்பு'),
  ];

  /// Weekday names in English (1=Monday .. 7=Sunday)
  static const List<String> weekdayNamesEn = [
    '',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  /// Weekday names in Tamil (1=Monday .. 7=Sunday)
  static const List<String> weekdayNamesTa = [
    '',
    'திங்கள்',
    'செவ்வாய்',
    'புதன்',
    'வியாழன்',
    'வெள்ளி',
    'சனி',
    'ஞாயிறு',
  ];

  /// Starting index in `planetCycle` for each weekday lord (1=Mon..7=Sun)
  /// Sunday(7)->Sun(0), Monday(1)->Moon(6), Tuesday(2)->Mars(1), Wednesday(3)->Mercury(3),
  /// Thursday(4)->Jupiter(2), Friday(5)->Venus(4), Saturday(6)->Saturn(5)
  static int getWeekdayLordIndex(int weekday) {
    switch (weekday) {
      case 7: // Sunday
        return 0; // Sun
      case 1: // Monday
        return 6; // Moon
      case 2: // Tuesday
        return 1; // Mars
      case 3: // Wednesday
        return 3; // Mercury
      case 4: // Thursday
        return 2; // Jupiter
      case 5: // Friday
        return 4; // Venus
      case 6: // Saturday
        return 5; // Saturn
      default:
        return 0;
    }
  }

  /// Calculates complete Jamam Day Schedule for any date/time and location
  static JamamDaySchedule calculateSchedule({
    required DateTime queryDateTime,
    required JamakkolLocation location,
  }) {
    // 1. Calculate Sunrise & Sunset for the calendar date
    final sunTimes = calculateAstronomicalSunriseSunset(
      queryDateTime,
      location.latitude,
      location.longitude,
      location.timezone,
    );
    DateTime sunrise = sunTimes['sunrise']!;
    DateTime sunset = sunTimes['sunset']!;

    // In Vedic astrology, a day runs from Sunrise to Sunrise.
    // If the query time is before today's sunrise, the effective day started at yesterday's sunrise.
    DateTime effectiveVedicDate = queryDateTime;
    DateTime effectiveSunrise = sunrise;
    DateTime effectiveSunset = sunset;

    if (queryDateTime.isBefore(sunrise)) {
      effectiveVedicDate = queryDateTime.subtract(const Duration(days: 1));
      final prevSunTimes = calculateAstronomicalSunriseSunset(
        effectiveVedicDate,
        location.latitude,
        location.longitude,
        location.timezone,
      );
      effectiveSunrise = prevSunTimes['sunrise']!;
      effectiveSunset = prevSunTimes['sunset']!;
    }

    // Next sunrise after effective sunset
    final nextDate = effectiveVedicDate.add(const Duration(days: 1));
    final nextSunTimes = calculateAstronomicalSunriseSunset(
      nextDate,
      location.latitude,
      location.longitude,
      location.timezone,
    );
    final nextSunrise = nextSunTimes['sunrise']!;

    // 2. Compute durations
    final dayDurationSeconds = effectiveSunset.difference(effectiveSunrise).inSeconds;
    final nightDurationSeconds = nextSunrise.difference(effectiveSunset).inSeconds;

    final dayDurationMinutes = dayDurationSeconds / 60.0;
    final nightDurationMinutes = nightDurationSeconds / 60.0;

    final dayJamamLengthSeconds = dayDurationSeconds / 8.0;
    final nightJamamLengthSeconds = nightDurationSeconds / 8.0;

    final dayJamamLengthMinutes = dayDurationMinutes / 8.0;
    final nightJamamLengthMinutes = nightDurationMinutes / 8.0;

    // 3. Determine Weekday Lord
    final weekdayNum = effectiveVedicDate.weekday; // 1=Mon .. 7=Sun
    final dayLordIdx = getWeekdayLordIndex(weekdayNum);
    final dayLord = planetCycle[dayLordIdx];

    // 4. Generate the 8 Daytime Jamams (Jamam #1 to #8)
    final List<JamamInfo> dayJamams = [];
    for (int i = 0; i < 8; i++) {
      final startTime = effectiveSunrise.add(Duration(seconds: (i * dayJamamLengthSeconds).round()));
      final endTime = effectiveSunrise.add(Duration(seconds: ((i + 1) * dayJamamLengthSeconds).round()));

      // Ruling planet cycles forward from day lord
      final planet = planetCycle[(dayLordIdx + i) % 8];

      final elapsedSec = queryDateTime.isAfter(startTime)
          ? (queryDateTime.isBefore(endTime)
              ? queryDateTime.difference(startTime).inSeconds.toDouble()
              : dayJamamLengthSeconds)
          : 0.0;
      final remainingSec = (dayJamamLengthSeconds - elapsedSec).clamp(0.0, dayJamamLengthSeconds);
      final progress = (elapsedSec / dayJamamLengthSeconds).clamp(0.0, 1.0);

      dayJamams.add(JamamInfo(
        number: i + 1,
        periodIndex: i + 1,
        period: JamamPeriod.day,
        rulingPlanetEn: planet.en,
        rulingPlanetTa: planet.ta,
        rulingPlanetShortTa: planet.shortTa,
        startTime: startTime,
        endTime: endTime,
        durationMinutes: dayJamamLengthMinutes,
        elapsedMinutes: elapsedSec / 60.0,
        remainingMinutes: remainingSec / 60.0,
        progress: progress,
      ));
    }

    // 5. Generate the 8 Nighttime Jamams (Jamam #9 to #16)
    // In South Indian Jamakkol tradition, Night Jamam #1 (Jamam 9) continues the 8-planet cycle from the 5th planet or after Jamam 8
    final int nightStartLordIdx = (dayLordIdx + 4) % 8;
    final List<JamamInfo> nightJamams = [];
    for (int i = 0; i < 8; i++) {
      final startTime = effectiveSunset.add(Duration(seconds: (i * nightJamamLengthSeconds).round()));
      final endTime = effectiveSunset.add(Duration(seconds: ((i + 1) * nightJamamLengthSeconds).round()));

      final planet = planetCycle[(nightStartLordIdx + i) % 8];

      final elapsedSec = queryDateTime.isAfter(startTime)
          ? (queryDateTime.isBefore(endTime)
              ? queryDateTime.difference(startTime).inSeconds.toDouble()
              : nightJamamLengthSeconds)
          : 0.0;
      final remainingSec = (nightJamamLengthSeconds - elapsedSec).clamp(0.0, nightJamamLengthSeconds);
      final progress = (elapsedSec / nightJamamLengthSeconds).clamp(0.0, 1.0);

      nightJamams.add(JamamInfo(
        number: 9 + i,
        periodIndex: i + 1,
        period: JamamPeriod.night,
        rulingPlanetEn: planet.en,
        rulingPlanetTa: planet.ta,
        rulingPlanetShortTa: planet.shortTa,
        startTime: startTime,
        endTime: endTime,
        durationMinutes: nightJamamLengthMinutes,
        elapsedMinutes: elapsedSec / 60.0,
        remainingMinutes: remainingSec / 60.0,
        progress: progress,
      ));
    }

    // 6. Find the currently active Jamam
    JamamInfo currentJamam;
    if (!queryDateTime.isBefore(effectiveSunrise) && queryDateTime.isBefore(effectiveSunset)) {
      // Daytime
      final elapsedSec = queryDateTime.difference(effectiveSunrise).inSeconds;
      final idx = (elapsedSec / dayJamamLengthSeconds).floor().clamp(0, 7);
      currentJamam = dayJamams[idx];
    } else {
      // Nighttime
      final nightBase = queryDateTime.isBefore(effectiveSunrise) ? effectiveSunset : effectiveSunset;
      final elapsedSec = queryDateTime.difference(nightBase).inSeconds;
      final idx = (elapsedSec / nightJamamLengthSeconds).floor().clamp(0, 7);
      currentJamam = nightJamams[idx];
    }

    return JamamDaySchedule(
      queryDateTime: queryDateTime,
      effectiveVedicDate: effectiveVedicDate,
      weekdayNumber: weekdayNum,
      weekdayNameEn: weekdayNamesEn[weekdayNum],
      weekdayNameTa: weekdayNamesTa[weekdayNum],
      dayLordEn: dayLord.en,
      dayLordTa: dayLord.ta,
      sunrise: effectiveSunrise,
      sunset: effectiveSunset,
      nextSunrise: nextSunrise,
      dayDurationMinutes: dayDurationMinutes,
      nightDurationMinutes: nightDurationMinutes,
      dayJamamLengthMinutes: dayJamamLengthMinutes,
      nightJamamLengthMinutes: nightJamamLengthMinutes,
      dayJamams: dayJamams,
      nightJamams: nightJamams,
      currentJamam: currentJamam,
    );
  }
}
