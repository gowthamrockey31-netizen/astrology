import '../models/hora_result.dart';
import 'astrology_calculator.dart';

class HoraCalculator {
  /// Standard Chaldean Hora planetary sequence:
  /// Sun -> Venus -> Mercury -> Moon -> Saturn -> Jupiter -> Mars -> repeat
  static const List<Map<String, String>> _horaSequence = [
    {'en': 'Sun', 'ta': 'சூரியன்', 'symbol': 'சூ'},
    {'en': 'Venus', 'ta': 'சுக்கிரன்', 'symbol': 'சு'},
    {'en': 'Mercury', 'ta': 'புதன்', 'symbol': 'பு'},
    {'en': 'Moon', 'ta': 'சந்திரன்', 'symbol': 'சந்'},
    {'en': 'Saturn', 'ta': 'சனி', 'symbol': 'சனி'},
    {'en': 'Jupiter', 'ta': 'குரு', 'symbol': 'குரு'},
    {'en': 'Mars', 'ta': 'செவ்வாய்', 'symbol': 'செவ்'},
  ];

  /// Weekday (1=Mon ... 7=Sun) starting planet index in _horaSequence
  /// Sun (Sunday=7) -> Index 0
  /// Moon (Monday=1) -> Index 3
  /// Mars (Tuesday=2) -> Index 6
  /// Mercury (Wednesday=3) -> Index 2
  /// Jupiter (Thursday=4) -> Index 5
  /// Venus (Friday=5) -> Index 1
  /// Saturn (Saturday=6) -> Index 4
  static int _getWeekdayStartHoraIndex(int weekday) {
    switch (weekday) {
      case DateTime.sunday:
        return 0; // Sun
      case DateTime.monday:
        return 3; // Moon
      case DateTime.tuesday:
        return 6; // Mars
      case DateTime.wednesday:
        return 2; // Mercury
      case DateTime.thursday:
        return 5; // Jupiter
      case DateTime.friday:
        return 1; // Venus
      case DateTime.saturday:
        return 4; // Saturn
      default:
        return 0;
    }
  }

  /// Calculates structured HoraResult for a specific target DateTime and Location
  static HoraResult calculateHora({
    required DateTime targetTime,
    required double latitude,
    required double longitude,
    double utcOffsetHours = 5.5,
  }) {
    final now = targetTime.toUtc();

    // 1. Calculate Sunrises and Sunsets for Yesterday, Today, and Tomorrow
    final todayLocal = targetTime;
    final yesterdayLocal = todayLocal.subtract(const Duration(days: 1));
    final tomorrowLocal = todayLocal.add(const Duration(days: 1));

    final sunToday = AstrologyCalculator.calculateSunriseSunset(todayLocal, latitude, longitude, utcOffsetHours);
    final sunYesterday = AstrologyCalculator.calculateSunriseSunset(yesterdayLocal, latitude, longitude, utcOffsetHours);
    final sunTomorrow = AstrologyCalculator.calculateSunriseSunset(tomorrowLocal, latitude, longitude, utcOffsetHours);

    final sunriseToday = sunToday['sunrise']!;
    final sunsetToday = sunToday['sunset']!;

    late DateTime astrologicalSunrise;
    late DateTime astrologicalSunset;
    late DateTime nextSunrise;
    late int astrologicalWeekday;
    late bool isDaytime;

    if (now.isBefore(sunriseToday.toUtc())) {
      // Overnight case: Between midnight and today's sunrise
      // Belongs to Yesterday's astrological day cycle
      final sunriseYesterday = sunYesterday['sunrise']!;
      final sunsetYesterday = sunYesterday['sunset']!;

      astrologicalSunrise = sunriseYesterday;
      astrologicalSunset = sunsetYesterday;
      nextSunrise = sunriseToday;
      astrologicalWeekday = yesterdayLocal.weekday;
      isDaytime = false;
    } else if (now.isBefore(sunsetToday.toUtc())) {
      // Daytime case: Between today's sunrise and today's sunset
      final sunriseTomorrow = sunTomorrow['sunrise']!;

      astrologicalSunrise = sunriseToday;
      astrologicalSunset = sunsetToday;
      nextSunrise = sunriseTomorrow;
      astrologicalWeekday = todayLocal.weekday;
      isDaytime = true;
    } else {
      // Nighttime case: Between today's sunset and midnight
      final sunriseTomorrow = sunTomorrow['sunrise']!;

      astrologicalSunrise = sunriseToday;
      astrologicalSunset = sunsetToday;
      nextSunrise = sunriseTomorrow;
      astrologicalWeekday = todayLocal.weekday;
      isDaytime = false;
    }

    // 2. Compute dynamic Hora duration
    late double horaDurationMs;
    late DateTime phaseStart;
    late int horaIndexInPhase; // 0..11

    if (isDaytime) {
      final totalDaylightMs = astrologicalSunset.difference(astrologicalSunrise).inMilliseconds.toDouble();
      horaDurationMs = totalDaylightMs / 12.0;
      phaseStart = astrologicalSunrise;

      final elapsedMs = now.difference(astrologicalSunrise.toUtc()).inMilliseconds.toDouble();
      horaIndexInPhase = (elapsedMs / horaDurationMs).floor().clamp(0, 11);
    } else {
      final totalNightlightMs = nextSunrise.difference(astrologicalSunset).inMilliseconds.toDouble();
      horaDurationMs = totalNightlightMs / 12.0;
      phaseStart = astrologicalSunset;

      final elapsedMs = now.difference(astrologicalSunset.toUtc()).inMilliseconds.toDouble();
      horaIndexInPhase = (elapsedMs / horaDurationMs).floor().clamp(0, 11);
    }

    // Overall Hora index in 24-hora cycle (0..23)
    final totalHoraIndex = isDaytime ? horaIndexInPhase : (12 + horaIndexInPhase);

    // 3. Determine planetary ruler for current and next Hora
    final startHoraIndex = _getWeekdayStartHoraIndex(astrologicalWeekday);
    final currentPlanetIdx = (startHoraIndex + totalHoraIndex) % 7;
    final nextPlanetIdx = (currentPlanetIdx + 1) % 7;

    final currentPlanet = _horaSequence[currentPlanetIdx];
    final nextPlanet = _horaSequence[nextPlanetIdx];

    final dayRuler = _horaSequence[startHoraIndex];

    // 4. Determine start and end times for current Hora slot
    final horaStart = phaseStart.add(Duration(milliseconds: (horaIndexInPhase * horaDurationMs).round()));
    final horaEnd = phaseStart.add(Duration(milliseconds: ((horaIndexInPhase + 1) * horaDurationMs).round()));

    final remaining = horaEnd.toUtc().difference(now);
    final elapsed = now.difference(horaStart.toUtc());

    final totalSlotMs = horaEnd.difference(horaStart).inMilliseconds.toDouble();
    final progress = totalSlotMs > 0 ? (elapsed.inMilliseconds / totalSlotMs).clamp(0.0, 1.0) : 0.0;

    return HoraResult(
      currentHoraNameEn: currentPlanet['en']!,
      currentHoraNameTa: currentPlanet['ta']!,
      currentHoraSymbol: currentPlanet['symbol']!,
      nextHoraNameEn: nextPlanet['en']!,
      nextHoraNameTa: nextPlanet['ta']!,
      horaNumber: horaIndexInPhase + 1,
      isDaytime: isDaytime,
      horaStartTime: horaStart,
      horaEndTime: horaEnd,
      remainingDuration: remaining.isNegative ? Duration.zero : remaining,
      elapsedDuration: elapsed.isNegative ? Duration.zero : elapsed,
      totalHoraDuration: Duration(milliseconds: totalSlotMs.round()),
      progressRatio: progress,
      astrologicalDate: astrologicalSunrise,
      dayRulerEn: dayRuler['en']!,
      dayRulerTa: dayRuler['ta']!,
      sunrise: astrologicalSunrise,
      sunset: astrologicalSunset,
    );
  }

  /// Helper to get full 24-Hora schedule for a given day
  static List<HoraResult> getFullDayHoraSchedule({
    required DateTime date,
    required double latitude,
    required double longitude,
    double utcOffsetHours = 5.5,
  }) {
    final schedule = <HoraResult>[];
    final sun = AstrologyCalculator.calculateSunriseSunset(date, latitude, longitude, utcOffsetHours);
    final sunrise = sun['sunrise']!;
    final sunset = sun['sunset']!;

    final dayDurationMs = sunset.difference(sunrise).inMilliseconds.toDouble() / 12.0;

    // 12 Daytime Horas
    for (int i = 0; i < 12; i++) {
      final sampleTime = sunrise.add(Duration(milliseconds: (i * dayDurationMs + dayDurationMs / 2).round()));
      schedule.add(calculateHora(
        targetTime: sampleTime,
        latitude: latitude,
        longitude: longitude,
        utcOffsetHours: utcOffsetHours,
      ));
    }

    // 12 Nighttime Horas
    final tomorrow = date.add(const Duration(days: 1));
    final sunTomorrow = AstrologyCalculator.calculateSunriseSunset(tomorrow, latitude, longitude, utcOffsetHours);
    final nextSunrise = sunTomorrow['sunrise']!;
    final nightDurationMs = nextSunrise.difference(sunset).inMilliseconds.toDouble() / 12.0;

    for (int i = 0; i < 12; i++) {
      final sampleTime = sunset.add(Duration(milliseconds: (i * nightDurationMs + nightDurationMs / 2).round()));
      schedule.add(calculateHora(
        targetTime: sampleTime,
        latitude: latitude,
        longitude: longitude,
        utcOffsetHours: utcOffsetHours,
      ));
    }

    return schedule;
  }
}
