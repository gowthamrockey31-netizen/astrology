import 'dart:math';
import 'package:intl/intl.dart';
import '../models/daily_calendar_models.dart';
import 'astrology_calculator.dart';

/// Complete Model for an Astronomical Tithi with exact transition timings
class TithiData {
  final int index; // 0 to 29 (0=Prathamai Shukla, 14=Pournami, 15=Prathamai Krishna, 29=Amavasai)
  final int number; // 1 to 30
  final String name; // e.g. 'துவிதியை'
  final String fullNameTa; // e.g. 'கிருஷ்ணபட்சம் துவிதியை'
  final String paksha; // e.g. 'கிருஷ்ண பக்ஷம்'
  final String pakshaTamil; // e.g. 'கிருஷ்ண பக்ஷம் / தேய்பிறை'
  final DateTime start; // exact start local DateTime
  final DateTime end; // exact end local DateTime
  final double startAngle; // multiple of 12°
  final double endAngle; // next multiple of 12°
  final double elongation; // current Moon-Sun angular separation (0°..360°)

  const TithiData({
    required this.index,
    required this.number,
    required this.name,
    required this.fullNameTa,
    required this.paksha,
    required this.pakshaTamil,
    required this.start,
    required this.end,
    required this.startAngle,
    required this.endAngle,
    required this.elongation,
  });
}

/// Detailed Tithi structure for natal horoscope and daily panchangam compatibility
class TithiDetail {
  final int tithiNumber; // 1 to 30 (1..15 Shukla Paksha, 16..30 Krishna Paksha)
  final int tithiIndex; // 0 to 29
  final String tithiNameEn;
  final String tithiNameTa;
  final String pakshaEn;
  final String pakshaTa;
  final List<String> soonyamRasisEn;
  final List<String> soonyamRasisTa;
  final DateTime? startTime;
  final DateTime? endTime;
  final double? startAngle;
  final double? endAngle;
  final double? elongation;

  bool get isShuklaPaksha => tithiNumber <= 15;
  String get fullNameTa => (tithiIndex == 14 || tithiIndex == 29) ? tithiNameTa : '$pakshaTa $tithiNameTa';

  TithiDetail({
    required this.tithiNumber,
    int? tithiIndex,
    required this.tithiNameEn,
    required this.tithiNameTa,
    required this.pakshaEn,
    required this.pakshaTa,
    required this.soonyamRasisEn,
    required this.soonyamRasisTa,
    this.startTime,
    this.endTime,
    this.startAngle,
    this.endAngle,
    this.elongation,
  }) : tithiIndex = tithiIndex ?? (tithiNumber - 1);
}

/// High-Precision Astronomical Tithi Calculation Engine
class TithiCalculator {
  static const List<String> tithiNamesTa = [
    // Shukla Paksha (0..14)
    'பிரதமை', 'துவிதியை', 'திரிதியை', 'சதுர்த்தி', 'பஞ்சமி',
    'சஷ்டி', 'சப்தமி', 'அஷ்டமி', 'நவமி', 'தசமி',
    'ஏகாதசி', 'துவாதசி', 'திரயோதசி', 'சதுர்த்தசி', 'பௌர்ணமி',
    // Krishna Paksha (15..29)
    'பிரதமை', 'துவிதியை', 'திரிதியை', 'சதுர்த்தி', 'பஞ்சமி',
    'சஷ்டி', 'சப்தமி', 'அஷ்டமி', 'நவமி', 'தசமி',
    'ஏகாதசி', 'துவாதசி', 'திரயோதசி', 'சதுர்த்தசி', 'அமாவாசை',
  ];

  static const List<String> tithiNamesEn = [
    'Prathamai', 'Dvithiyai', 'Tritiyai', 'Chaturthi', 'Panchami',
    'Shashti', 'Sapthami', 'Ashtami', 'Navami', 'Dasami',
    'Ekadashi', 'Dwadashi', 'Trayodashi', 'Chaturdashi', 'Pournami',
    'Prathamai', 'Dvithiyai', 'Tritiyai', 'Chaturthi', 'Panchami',
    'Shashti', 'Sapthami', 'Ashtami', 'Navami', 'Dasami',
    'Ekadashi', 'Dwadashi', 'Trayodashi', 'Chaturdashi', 'Amavasai',
  ];

  /// Mapping from Tithi index (1..14) to Tithi Soonyam Rasis (English & Tamil)
  static final Map<int, Map<String, List<String>>> _soonyamMapping = {
    1: {'en': ['Libra', 'Capricorn'], 'ta': ['துலாம்', 'மகரம்']},
    2: {'en': ['Sagittarius', 'Pisces'], 'ta': ['தனுசு', 'மீனம்']},
    3: {'en': ['Capricorn', 'Leo'], 'ta': ['மகரம்', 'சிம்மம்']},
    4: {'en': ['Aquarius', 'Taurus'], 'ta': ['கும்பம்', 'ரிஷபம்']},
    5: {'en': ['Gemini', 'Virgo'], 'ta': ['மிதுனம்', 'கன்னி']},
    6: {'en': ['Aries', 'Leo'], 'ta': ['மேஷம்', 'சிம்மம்']},
    7: {'en': ['Cancer', 'Sagittarius'], 'ta': ['கடகம்', 'தனுசு']},
    8: {'en': ['Gemini', 'Virgo'], 'ta': ['மிதுனம்', 'கன்னி']},
    9: {'en': ['Leo', 'Scorpio'], 'ta': ['சிம்மம்', 'விருச்சிகம்']},
    10: {'en': ['Leo', 'Scorpio'], 'ta': ['சிம்மம்', 'விருச்சிகம்']},
    11: {'en': ['Sagittarius', 'Pisces'], 'ta': ['தனுசு', 'மீனம்']},
    12: {'en': ['Libra', 'Capricorn'], 'ta': ['துலாம்', 'மகரம்']},
    13: {'en': ['Taurus', 'Leo'], 'ta': ['ரிஷபம்', 'சிம்மம்']},
    14: {'en': ['Gemini', 'Virgo', 'Sagittarius', 'Pisces'], 'ta': ['மிதுனம்', 'கன்னி', 'தனுசு', 'மீனம்']},
  };

  /// Geocentric Ecliptic Moon - Sun elongation (0.0 <= angle < 360.0)
  static double getMoonSunElongation(
    DateTime dt, {
    double utcOffsetHours = 5.5,
  }) {
    final jd = AstrologyCalculator.getJulianDay(dt, utcOffsetHours: utcOffsetHours);
    final t = (jd - 2451545.0) / 36525.0;

    // Solar Longitude
    final l0 = AstrologyCalculator.normalizeDegrees(280.46646 + 36000.76983 * t + 0.0003032 * t * t);
    final mSun = AstrologyCalculator.normalizeDegrees(357.52911 + 35999.05029 * t - 0.0001537 * t * t);
    final cSun = (1.914602 - 0.004817 * t - 0.000014 * t * t) * sin(mSun * pi / 180.0) +
        (0.019993 - 0.000101 * t) * sin(2 * mSun * pi / 180.0) +
        0.000289 * sin(3 * mSun * pi / 180.0);
    final sunTrueTrop = AstrologyCalculator.normalizeDegrees(l0 + cSun);
    final sunTrop = AstrologyCalculator.normalizeDegrees(sunTrueTrop - 0.00569 - 0.00478 * sin((125.04 - 1934.136 * t) * pi / 180.0));

    // High-Precision Lunar Longitude (Moon) - ELP-2000 / Meeus theory
    final lMoon = AstrologyCalculator.normalizeDegrees(218.3164477 + 481267.88123421 * t - 0.0015786 * t * t + (t * t * t) / 538841.0);
    final d = AstrologyCalculator.normalizeDegrees(297.8501921 + 445267.1114034 * t - 0.0018819 * t * t + (t * t * t) / 545868.0);
    final mLunar = AstrologyCalculator.normalizeDegrees(134.9633964 + 477198.8675055 * t + 0.0087414 * t * t + (t * t * t) / 69699.0);
    final f = AstrologyCalculator.normalizeDegrees(93.2720950 + 483202.0175233 * t - 0.0036539 * t * t - (t * t * t) / 3526000.0);

    final moonPerturbDeg = (22640.0 * sin(mLunar * pi / 180.0) -
            4586.0 * sin((mLunar - 2 * d) * pi / 180.0) +
            2370.0 * sin(2 * d * pi / 180.0) +
            769.0 * sin(2 * mLunar * pi / 180.0) -
            668.0 * sin(mSun * pi / 180.0) -
            412.0 * sin(2 * f * pi / 180.0) -
            212.0 * sin((2 * mLunar - 2 * d) * pi / 180.0) -
            206.0 * sin((mLunar + mSun - 2 * d) * pi / 180.0) +
            192.0 * sin((mLunar + 2 * d) * pi / 180.0) -
            165.0 * sin((mSun - 2 * d) * pi / 180.0) -
            125.0 * sin(d * pi / 180.0) -
            110.0 * sin((mLunar + mSun) * pi / 180.0) +
            148.0 * sin((mLunar - mSun) * pi / 180.0) -
            55.0 * sin((2 * f - 2 * d) * pi / 180.0) -
            45.0 * sin((mLunar + 2 * f) * pi / 180.0) +
            40.0 * sin((mLunar - 2 * f) * pi / 180.0)) / 3600.0;

    final moonTrop = AstrologyCalculator.normalizeDegrees(lMoon + moonPerturbDeg);

    return AstrologyCalculator.normalizeDegrees(moonTrop - sunTrop);
  }

  /// Calculate Tithi from Sun and Moon longitudes
  static TithiDetail calculateTithi({
    required double sunLongitude,
    required double moonLongitude,
  }) {
    double diff = moonLongitude - sunLongitude;
    if (diff < 0) diff += 360.0;

    int tithiIdx = (diff / 12.0).floor() % 30; // 0 to 29
    int tithiNum = tithiIdx + 1; // 1 to 30

    final isShukla = tithiIdx < 15;
    final pakshaEn = isShukla ? 'Shukla Paksha' : 'Krishna Paksha';
    final pakshaTa = isShukla ? 'சுக்ல பக்ஷம்' : 'கிருஷ்ண பக்ஷம்';

    final tithiNameEn = tithiNamesEn[tithiIdx];
    final tithiNameTa = tithiNamesTa[tithiIdx];

    final soonyamKey = (tithiNum % 15 == 0) ? 0 : (tithiNum % 15);
    final soonyamMap = _soonyamMapping[soonyamKey] ?? {'en': [], 'ta': []};

    return TithiDetail(
      tithiNumber: tithiNum,
      tithiIndex: tithiIdx,
      tithiNameEn: tithiNameEn,
      tithiNameTa: tithiNameTa,
      pakshaEn: pakshaEn,
      pakshaTa: pakshaTa,
      soonyamRasisEn: soonyamMap['en']!,
      soonyamRasisTa: soonyamMap['ta']!,
      startAngle: tithiIdx * 12.0,
      endAngle: (tithiIdx + 1) * 12.0,
      elongation: diff,
    );
  }

  /// Calculates astronomical Tithi with exact start and end transition timestamps
  static TithiData calculateAstronomicalTithi({
    required DateTime dateTime,
    double utcOffsetHours = 5.5,
    double latitude = 13.0827,
    double longitude = 80.2707,
  }) {
    final elongation = getMoonSunElongation(dateTime, utcOffsetHours: utcOffsetHours);
    final int index = (elongation / 12.0).floor() % 30;
    final int number = index + 1;
    final String name = tithiNamesTa[index];
    final bool isShukla = index < 15;
    final String paksha = isShukla ? 'சுக்ல பக்ஷம்' : 'கிருஷ்ண பக்ஷம்';
    final String pakshaTamil = isShukla ? 'சுக்ல பக்ஷம் / வளர்பிறை' : 'கிருஷ்ண பக்ஷம் / தேய்பிறை';
    final String fullNameTa = (index == 14 || index == 29) ? name : '$paksha $name';

    final double startAngle = index * 12.0;
    final double endAngle = (index + 1) * 12.0;

    final DateTime start = findPreviousTithiTransition(dateTime, utcOffsetHours: utcOffsetHours);
    final DateTime end = findNextTithiTransition(dateTime, utcOffsetHours: utcOffsetHours);

    return TithiData(
      index: index,
      number: number,
      name: name,
      fullNameTa: fullNameTa,
      paksha: paksha,
      pakshaTamil: pakshaTamil,
      start: start,
      end: end,
      startAngle: startAngle,
      endAngle: endAngle,
      elongation: elongation,
    );
  }

  /// High-Precision Numerical Root Finding / Binary Search for the next 12° boundary crossing
  static DateTime findNextTithiTransition(
    DateTime startTime, {
    double utcOffsetHours = 5.5,
  }) {
    final currentElongation = getMoonSunElongation(startTime, utcOffsetHours: utcOffsetHours);
    final currentIdx = (currentElongation / 12.0).floor() % 30;
    final targetBoundary = (currentIdx + 1) * 12.0; // 12.0 to 360.0

    double remainingDeg = (targetBoundary == 360.0)
        ? (360.0 - currentElongation)
        : (targetBoundary - currentElongation);

    if (remainingDeg < 0.0001) remainingDeg = 12.0;

    // Approximate relative speed: ~0.508 degrees per hour
    final hoursEst = remainingDeg / 0.508;

    DateTime lower = startTime.add(Duration(minutes: ((hoursEst - 1.5).clamp(0.0, 40.0) * 60).round()));
    DateTime upper = startTime.add(Duration(minutes: ((hoursEst + 1.5).clamp(0.5, 45.0) * 60).round()));

    // Ensure bracket straddles the boundary
    while (_isPastBoundary(getMoonSunElongation(lower, utcOffsetHours: utcOffsetHours), currentIdx, targetBoundary)) {
      lower = lower.subtract(const Duration(minutes: 30));
    }
    while (!_isPastBoundary(getMoonSunElongation(upper, utcOffsetHours: utcOffsetHours), currentIdx, targetBoundary)) {
      upper = upper.add(const Duration(minutes: 30));
    }

    // Binary search (bisection) down to 2-second resolution
    while (upper.difference(lower).inSeconds > 2) {
      final mid = lower.add(Duration(milliseconds: upper.difference(lower).inMilliseconds ~/ 2));
      final eMid = getMoonSunElongation(mid, utcOffsetHours: utcOffsetHours);

      if (_isPastBoundary(eMid, currentIdx, targetBoundary)) {
        upper = mid;
      } else {
        lower = mid;
      }
    }

    final exact = lower.add(Duration(seconds: upper.difference(lower).inSeconds ~/ 2));
    final roundedMinute = (exact.second >= 30) ? exact.minute + 1 : exact.minute;
    return DateTime(exact.year, exact.month, exact.day, exact.hour, roundedMinute);
  }

  /// High-Precision Numerical Root Finding / Binary Search for the previous 12° boundary crossing
  static DateTime findPreviousTithiTransition(
    DateTime startTime, {
    double utcOffsetHours = 5.5,
  }) {
    final currentElongation = getMoonSunElongation(startTime, utcOffsetHours: utcOffsetHours);
    final currentIdx = (currentElongation / 12.0).floor() % 30;
    final targetBoundary = currentIdx * 12.0; // 0.0 to 348.0

    double elapsedDeg = (currentIdx == 0)
        ? currentElongation
        : (currentElongation - targetBoundary);

    if (elapsedDeg < 0.0001) elapsedDeg = 12.0;

    final hoursEst = elapsedDeg / 0.508;

    DateTime lower = startTime.subtract(Duration(minutes: ((hoursEst + 1.5).clamp(0.5, 45.0) * 60).round()));
    DateTime upper = startTime.subtract(Duration(minutes: ((hoursEst - 1.5).clamp(0.0, 40.0) * 60).round()));

    while (!_isPastBoundary(getMoonSunElongation(lower, utcOffsetHours: utcOffsetHours), (currentIdx - 1 + 30) % 30, targetBoundary == 0.0 ? 360.0 : targetBoundary)) {
      lower = lower.subtract(const Duration(minutes: 30));
    }
    while (_isPastBoundary(getMoonSunElongation(upper, utcOffsetHours: utcOffsetHours), (currentIdx - 1 + 30) % 30, targetBoundary == 0.0 ? 360.0 : targetBoundary)) {
      upper = upper.add(const Duration(minutes: 30));
    }

    final boundaryToCheck = (targetBoundary == 0.0) ? 360.0 : targetBoundary;
    final priorIdx = (currentIdx - 1 + 30) % 30;

    while (upper.difference(lower).inSeconds > 2) {
      final mid = lower.add(Duration(milliseconds: upper.difference(lower).inMilliseconds ~/ 2));
      final eMid = getMoonSunElongation(mid, utcOffsetHours: utcOffsetHours);

      if (_isPastBoundary(eMid, priorIdx, boundaryToCheck)) {
        lower = mid;
      } else {
        upper = mid;
      }
    }

    final exact = lower.add(Duration(seconds: upper.difference(lower).inSeconds ~/ 2));
    final roundedMinute = (exact.second >= 30) ? exact.minute + 1 : exact.minute;
    return DateTime(exact.year, exact.month, exact.day, exact.hour, roundedMinute);
  }

  static bool _isPastBoundary(double elongation, int baseIdx, double targetBoundary) {
    if (targetBoundary >= 360.0) {
      // Crossing 360°/0° boundary
      return elongation < 180.0;
    } else {
      if (baseIdx >= 28 && elongation < 90.0) return true; // wrapped around
      return elongation >= targetBoundary;
    }
  }

  /// Formats Tamil time-of-day period (காலை, மதியம், மாலை, இரவு, அதிகாலை)
  static String getTamilPeriod(DateTime dt) {
    final hour = dt.hour;
    if (hour >= 3 && hour < 6) return 'அதிகாலை';
    if (hour >= 6 && hour < 12) return 'காலை';
    if (hour >= 12 && hour < 16) return 'மதியம்';
    if (hour >= 16 && hour < 21) return 'மாலை';
    return 'இரவு';
  }

  /// Formats Tithi transition end time string
  static String formatTithiEndTime({
    required DateTime targetCalendarDate,
    required DateTime endDateTime,
  }) {
    final period = getTamilPeriod(endDateTime);
    final timeStr = DateFormat('hh:mm a').format(endDateTime);

    final isSameDay = targetCalendarDate.year == endDateTime.year &&
        targetCalendarDate.month == endDateTime.month &&
        targetCalendarDate.day == endDateTime.day;

    final nextDay = targetCalendarDate.add(const Duration(days: 1));
    final isNextDay = nextDay.year == endDateTime.year &&
        nextDay.month == endDateTime.month &&
        nextDay.day == endDateTime.day;

    if (isSameDay) {
      return 'இன்று $period $timeStr வரை';
    } else if (isNextDay) {
      return 'நாளை $period $timeStr வரை';
    } else {
      final dateStr = DateFormat('dd/MM/yyyy').format(endDateTime);
      return '$dateStr $timeStr வரை';
    }
  }

  /// Calculates complete PanchangamTransition object for the Daily Panchangam card
  static PanchangamTransition calculatePanchangamTransition({
    required DateTime targetDate,
    required DateTime referenceTime,
    double utcOffsetHours = 5.5,
    double latitude = 13.0827,
    double longitude = 80.2707,
  }) {
    final tithiData = calculateAstronomicalTithi(
      dateTime: referenceTime,
      utcOffsetHours: utcOffsetHours,
      latitude: latitude,
      longitude: longitude,
    );

    final prevIndex = (tithiData.index - 1 + 30) % 30;
    final nextIndex = (tithiData.index + 1) % 30;

    final prevName = tithiNamesTa[prevIndex];
    final nextName = tithiNamesTa[nextIndex];

    final timingStr = formatTithiEndTime(
      targetCalendarDate: targetDate,
      endDateTime: tithiData.end,
    );

    return PanchangamTransition(
      currentName: tithiData.fullNameTa,
      currentTiming: timingStr,
      previousName: prevName,
      previousTiming: 'முந்தைய திதி',
      nextName: nextName,
      nextTiming: 'அடுத்த திதி',
    );
  }

  /// Get TithiDetail for a specific manual Tithi selection (1..30)
  static TithiDetail getTithiByNumber(int tithiNumber) {
    final num = ((tithiNumber - 1) % 30 + 30) % 30 + 1; // 1 to 30
    final idx = num - 1; // 0 to 29
    final isShukla = idx < 15;
    final pakshaEn = isShukla ? 'Shukla Paksha' : 'Krishna Paksha';
    final pakshaTa = isShukla ? 'சுக்ல பக்ஷம்' : 'கிருஷ்ண பக்ஷம்';
    final nameTa = tithiNamesTa[idx];
    final nameEn = tithiNamesEn[idx];

    final soonyamKey = (num % 15 == 0) ? 0 : (num % 15);
    final soonyamMap = _soonyamMapping[soonyamKey] ?? {'en': [], 'ta': []};

    return TithiDetail(
      tithiNumber: num,
      tithiIndex: idx,
      tithiNameEn: nameEn,
      tithiNameTa: nameTa,
      pakshaEn: pakshaEn,
      pakshaTa: pakshaTa,
      soonyamRasisEn: soonyamMap['en']!,
      soonyamRasisTa: soonyamMap['ta']!,
      startAngle: idx * 12.0,
      endAngle: (idx + 1) * 12.0,
    );
  }
}
