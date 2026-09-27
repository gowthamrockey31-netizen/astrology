import 'package:flutter/foundation.dart';

/// Represents day or night period for Jamams
enum JamamPeriod {
  day,
  night,
}

/// Information about a single Jamam division (1 of 16 in a complete day)
@immutable
class JamamInfo {
  final int number; // 1 to 16 (1..8 Daytime, 9..16 Nighttime)
  final int periodIndex; // 1 to 8 within day or night
  final JamamPeriod period;
  final String rulingPlanetEn;
  final String rulingPlanetTa;
  final String rulingPlanetShortTa;
  final DateTime startTime;
  final DateTime endTime;
  final double durationMinutes;
  final double elapsedMinutes;
  final double remainingMinutes;
  final double progress; // 0.0 to 1.0

  const JamamInfo({
    required this.number,
    required this.periodIndex,
    required this.period,
    required this.rulingPlanetEn,
    required this.rulingPlanetTa,
    required this.rulingPlanetShortTa,
    required this.startTime,
    required this.endTime,
    required this.durationMinutes,
    required this.elapsedMinutes,
    required this.remainingMinutes,
    required this.progress,
  });

  bool get isDay => period == JamamPeriod.day;

  String get periodLabelTa => isDay ? 'பகல் ஜாமம்' : 'இரவு ஜாமம்';
  String get periodLabelEn => isDay ? 'Day Jamam' : 'Night Jamam';

  String get displayNameTa => '$periodLabelTa #$periodIndex (மொத்த ஜாமம் #$number)';
  String get displayNameEn => '$periodLabelEn #$periodIndex (Overall Jamam #$number)';
}

/// Complete day schedule containing all 16 Jamams (8 day + 8 night)
@immutable
class JamamDaySchedule {
  final DateTime queryDateTime;
  final DateTime effectiveVedicDate;
  final int weekdayNumber; // 1=Mon .. 7=Sun
  final String weekdayNameEn;
  final String weekdayNameTa;
  final String dayLordEn;
  final String dayLordTa;
  final DateTime sunrise;
  final DateTime sunset;
  final DateTime nextSunrise;
  final double dayDurationMinutes;
  final double nightDurationMinutes;
  final double dayJamamLengthMinutes;
  final double nightJamamLengthMinutes;
  final List<JamamInfo> dayJamams;
  final List<JamamInfo> nightJamams;
  final JamamInfo currentJamam;

  const JamamDaySchedule({
    required this.queryDateTime,
    required this.effectiveVedicDate,
    required this.weekdayNumber,
    required this.weekdayNameEn,
    required this.weekdayNameTa,
    required this.dayLordEn,
    required this.dayLordTa,
    required this.sunrise,
    required this.sunset,
    required this.nextSunrise,
    required this.dayDurationMinutes,
    required this.nightDurationMinutes,
    required this.dayJamamLengthMinutes,
    required this.nightJamamLengthMinutes,
    required this.dayJamams,
    required this.nightJamams,
    required this.currentJamam,
  });

  List<JamamInfo> get allJamams => [...dayJamams, ...nightJamams];
}
