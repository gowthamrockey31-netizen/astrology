// ===============================================================
// GOWRI PANCHANGAM ENGINE (கௌரி பஞ்சாங்கம்)
// Authoritative calculation of Day & Night Gowri periods
// ===============================================================

import 'package:intl/intl.dart';
import '../models/daily_calendar_models.dart';

/// 8 Traditional Gowri Types with authoritative Tamil labels & nature
enum GowriType {
  uthi,
  amirtham,
  rogam,
  labham,
  dhanam,
  sugam,
  soram,
  visham;

  String get tamilName {
    switch (this) {
      case GowriType.uthi:
        return 'உத்தி';
      case GowriType.amirtham:
        return 'அமிர்தம்';
      case GowriType.rogam:
        return 'ரோகம்';
      case GowriType.labham:
        return 'லாபம்';
      case GowriType.dhanam:
        return 'தனம்';
      case GowriType.sugam:
        return 'சுகம்';
      case GowriType.soram:
        return 'சோரம்';
      case GowriType.visham:
        return 'விஷம்';
    }
  }

  bool get isGood {
    switch (this) {
      case GowriType.uthi:
      case GowriType.amirtham:
      case GowriType.labham:
      case GowriType.dhanam:
      case GowriType.sugam:
        return true;
      case GowriType.rogam:
      case GowriType.soram:
      case GowriType.visham:
        return false;
    }
  }

  String get natureTa => isGood ? 'சுபம் (நன்மை)' : 'அசுபம் (தவிர்க்கவும்)';
}

/// Result of currently active Gowri period
class CurrentGowriResult {
  final GowriPeriod period;
  final bool isDay;
  final String dayNightTa;

  const CurrentGowriResult({
    required this.period,
    required this.isDay,
    required this.dayNightTa,
  });

  String get nameTa => period.nameTa;
  String get timeRange => period.timeRange;
  bool get isGood => period.isGood;
  String get natureTa => period.natureTa;
}

class GowriPanchangamEngine {
  /// Weekday mapping:
  /// Sunday    = 0
  /// Monday    = 1
  /// Tuesday   = 2
  /// Wednesday = 3
  /// Thursday  = 4
  /// Friday    = 5
  /// Saturday  = 6
  static int toGowriWeekdayIndex(int dateTimeWeekday) => dateTimeWeekday % 7;

  /// Tamil weekday names matching Sunday=0 ... Saturday=6
  static const List<String> weekdaysTa = [
    'ஞாயிறு', 'திங்கள்', 'செவ்வாய்', 'புதன்', 'வியாழன்', 'வெள்ளி', 'சனி'
  ];

  /// English weekday names matching Sunday=0 ... Saturday=6
  static const List<String> weekdaysEn = [
    'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'
  ];

  /// Standard Day Gowri time intervals for reference display
  static const List<String> standardSlotsDay = [
    '06:00 AM - 07:30 AM',
    '07:30 AM - 09:00 AM',
    '09:00 AM - 10:30 AM',
    '10:30 AM - 12:00 PM',
    '12:00 PM - 01:30 PM',
    '01:30 PM - 03:00 PM',
    '03:00 PM - 04:30 PM',
    '04:30 PM - 06:00 PM',
  ];

  /// Standard Night Gowri time intervals for reference display
  static const List<String> standardSlotsNight = [
    '06:00 PM - 07:30 PM',
    '07:30 PM - 09:00 PM',
    '09:00 PM - 10:30 PM',
    '10:30 PM - 12:00 AM',
    '12:00 AM - 01:30 AM',
    '01:30 AM - 03:00 AM',
    '03:00 AM - 04:30 AM',
    '04:30 AM - 06:00 AM',
  ];

  /// DAY GOWRI Weekly Reference Table (Slots 1 to 8)
  static const Map<int, List<GowriType>> dayGowri = {
    // 0: Sunday (உத்தி, அமிர்தம், ரோகம், லாபம், தனம், சுகம், சோரம், விஷம்)
    0: [
      GowriType.uthi,
      GowriType.amirtham,
      GowriType.rogam,
      GowriType.labham,
      GowriType.dhanam,
      GowriType.sugam,
      GowriType.soram,
      GowriType.visham,
    ],
    // 1: Monday (அமிர்தம், விஷம், ரோகம், லாபம், தனம், சுகம், சோரம், உத்தி)
    1: [
      GowriType.amirtham,
      GowriType.visham,
      GowriType.rogam,
      GowriType.labham,
      GowriType.dhanam,
      GowriType.sugam,
      GowriType.soram,
      GowriType.uthi,
    ],
    // 2: Tuesday (ரோகம், லாபம், தனம், சுகம், சோரம், உத்தி, விஷம், அமிர்தம்)
    2: [
      GowriType.rogam,
      GowriType.labham,
      GowriType.dhanam,
      GowriType.sugam,
      GowriType.soram,
      GowriType.uthi,
      GowriType.visham,
      GowriType.amirtham,
    ],
    // 3: Wednesday (லாபம், தனம், சுகம், சோரம், விஷம், உத்தி, அமிர்தம், ரோகம்)
    3: [
      GowriType.labham,
      GowriType.dhanam,
      GowriType.sugam,
      GowriType.soram,
      GowriType.visham,
      GowriType.uthi,
      GowriType.amirtham,
      GowriType.rogam,
    ],
    // 4: Thursday (தனம், சுகம், சோரம், உத்தி, அமிர்தம், விஷம், ரோகம், லாபம்)
    4: [
      GowriType.dhanam,
      GowriType.sugam,
      GowriType.soram,
      GowriType.uthi,
      GowriType.amirtham,
      GowriType.visham,
      GowriType.rogam,
      GowriType.labham,
    ],
    // 5: Friday (சுகம், சோரம், உத்தி, விஷம், அமிர்தம், ரோகம், லாபம், தனம்)
    5: [
      GowriType.sugam,
      GowriType.soram,
      GowriType.uthi,
      GowriType.visham,
      GowriType.amirtham,
      GowriType.rogam,
      GowriType.labham,
      GowriType.dhanam,
    ],
    // 6: Saturday (சோரம், உத்தி, விஷம், அமிர்தம், ரோகம், லாபம், தனம், சுகம்)
    6: [
      GowriType.soram,
      GowriType.uthi,
      GowriType.visham,
      GowriType.amirtham,
      GowriType.rogam,
      GowriType.labham,
      GowriType.dhanam,
      GowriType.sugam,
    ],
  };

  /// NIGHT GOWRI Weekly Reference Table (Slots 1 to 8)
  static const Map<int, List<GowriType>> nightGowri = {
    // 0: Sunday (தனம், சுகம், சோரம், விஷம், உத்தி, அமிர்தம், ரோகம், லாபம்)
    0: [
      GowriType.dhanam,
      GowriType.sugam,
      GowriType.soram,
      GowriType.visham,
      GowriType.uthi,
      GowriType.amirtham,
      GowriType.rogam,
      GowriType.labham,
    ],
    // 1: Monday (சுகம், சோரம், உத்தி, அமிர்தம், விஷம், ரோகம், லாபம், தனம்)
    1: [
      GowriType.sugam,
      GowriType.soram,
      GowriType.uthi,
      GowriType.amirtham,
      GowriType.visham,
      GowriType.rogam,
      GowriType.labham,
      GowriType.dhanam,
    ],
    // 2: Tuesday (சோரம், உத்தி, விஷம், அமிர்தம், ரோகம், லாபம், தனம், சுகம்)
    2: [
      GowriType.soram,
      GowriType.uthi,
      GowriType.visham,
      GowriType.amirtham,
      GowriType.rogam,
      GowriType.labham,
      GowriType.dhanam,
      GowriType.sugam,
    ],
    // 3: Wednesday (உத்தி, அமிர்தம், ரோகம், லாபம், தனம், சுகம், சோரம், விஷம்)
    3: [
      GowriType.uthi,
      GowriType.amirtham,
      GowriType.rogam,
      GowriType.labham,
      GowriType.dhanam,
      GowriType.sugam,
      GowriType.soram,
      GowriType.visham,
    ],
    // 4: Thursday (அமிர்தம், விஷம், ரோகம், லாபம், தனம், சுகம், சோரம், உத்தி)
    4: [
      GowriType.amirtham,
      GowriType.visham,
      GowriType.rogam,
      GowriType.labham,
      GowriType.dhanam,
      GowriType.sugam,
      GowriType.soram,
      GowriType.uthi,
    ],
    // 5: Friday (ரோகம், லாபம், தனம், சுகம், சோரம், உத்தி, விஷம், அமிர்தம்)
    5: [
      GowriType.rogam,
      GowriType.labham,
      GowriType.dhanam,
      GowriType.sugam,
      GowriType.soram,
      GowriType.uthi,
      GowriType.visham,
      GowriType.amirtham,
    ],
    // 6: Saturday (லாபம், தனம், சுகம், சோரம், உத்தி, விஷம், அமிர்தம், ரோகம்)
    6: [
      GowriType.labham,
      GowriType.dhanam,
      GowriType.sugam,
      GowriType.soram,
      GowriType.uthi,
      GowriType.visham,
      GowriType.amirtham,
      GowriType.rogam,
    ],
  };

  /// Calculate Day Gowri periods from Sunrise to Sunset divided into 8 equal parts
  /// 1. Sunrise → Sunrise + 1 period
  /// 2. Period 1 end → Period 2 end
  /// ...
  /// 8. Period 7 end → Sunset
  static List<GowriPeriod> calculateDayGowriPeriods({
    required DateTime sunrise,
    required DateTime sunset,
    required int weekdayIndex, // 0=Sunday ... 6=Saturday
    DateTime? currentTime,
  }) {
    final types = dayGowri[weekdayIndex % 7] ?? dayGowri[0]!;
    final totalMins = sunset.difference(sunrise).inMinutes;
    final sliceMins = totalMins / 8.0;
    final formatter = DateFormat('hh:mm a');
    final List<GowriPeriod> list = [];

    final now = currentTime ?? DateTime.now();
    DateTime currentStart = sunrise;

    for (int i = 0; i < 8; i++) {
      // Period 1 ends at Sunrise + 1 period, ..., Period 8 ends exactly at Sunset
      final DateTime currentEnd = (i == 7)
          ? sunset
          : sunrise.add(Duration(minutes: ((i + 1) * sliceMins).round()));
      final type = types[i];
      final isCurrent = !now.isBefore(currentStart) && now.isBefore(currentEnd);

      list.add(GowriPeriod(
        periodNumber: i + 1,
        nameTa: type.tamilName,
        timeRange: '${formatter.format(currentStart)} - ${formatter.format(currentEnd)}',
        isGood: type.isGood,
        natureTa: type.natureTa,
        startTime: currentStart,
        endTime: currentEnd,
        isDay: true,
        isCurrent: isCurrent,
      ));

      currentStart = currentEnd;
    }
    return list;
  }

  /// Calculate Night Gowri periods from Sunset to next day's Sunrise divided into 8 equal parts
  /// Important: Night belongs to the date on which the night starts
  /// 1. Sunset → Sunset + 1 period
  /// ...
  /// 8. Period 7 end → Next Sunrise
  static List<GowriPeriod> calculateNightGowriPeriods({
    required DateTime sunset,
    required DateTime nextSunrise,
    required int weekdayIndex, // 0=Sunday ... 6=Saturday
    DateTime? currentTime,
  }) {
    final types = nightGowri[weekdayIndex % 7] ?? nightGowri[0]!;
    final totalMins = nextSunrise.difference(sunset).inMinutes;
    final sliceMins = totalMins / 8.0;
    final formatter = DateFormat('hh:mm a');
    final List<GowriPeriod> list = [];

    final now = currentTime ?? DateTime.now();
    DateTime currentStart = sunset;

    for (int i = 0; i < 8; i++) {
      // Period 1 ends at Sunset + 1 period, ..., Period 8 ends exactly at Next Sunrise
      final DateTime currentEnd = (i == 7)
          ? nextSunrise
          : sunset.add(Duration(minutes: ((i + 1) * sliceMins).round()));
      final type = types[i];
      final isCurrent = !now.isBefore(currentStart) && now.isBefore(currentEnd);

      list.add(GowriPeriod(
        periodNumber: i + 1,
        nameTa: type.tamilName,
        timeRange: '${formatter.format(currentStart)} - ${formatter.format(currentEnd)}',
        isGood: type.isGood,
        natureTa: type.natureTa,
        startTime: currentStart,
        endTime: currentEnd,
        isDay: false,
        isCurrent: isCurrent,
      ));

      currentStart = currentEnd;
    }
    return list;
  }

  /// Identify currently active Gowri period based on date, time, sunrise & sunset
  static CurrentGowriResult? getCurrentGowriPeriod({
    required List<GowriPeriod> dayPeriods,
    required List<GowriPeriod> nightPeriods,
    DateTime? currentTime,
    int? weekdayIndex,
    DateTime? prevSunset,
  }) {
    final now = currentTime ?? DateTime.now();

    // 1. Check day periods
    for (final p in dayPeriods) {
      if (p.startTime != null && p.endTime != null) {
        if (!now.isBefore(p.startTime!) && now.isBefore(p.endTime!)) {
          return CurrentGowriResult(
            period: p,
            isDay: true,
            dayNightTa: 'பகல் கௌரி (Day)',
          );
        }
      }
    }

    // 2. Check night periods
    for (final p in nightPeriods) {
      if (p.startTime != null && p.endTime != null) {
        if (!now.isBefore(p.startTime!) && now.isBefore(p.endTime!)) {
          return CurrentGowriResult(
            period: p,
            isDay: false,
            dayNightTa: 'இரவு கௌரி (Night)',
          );
        }
      }
    }

    // 3. If currentTime is before today's sunrise (e.g. 00:00 to Sunrise),
    // it belongs to previous day's Night Gowri cycle.
    if (dayPeriods.isNotEmpty && nightPeriods.isNotEmpty) {
      final todaySunrise = dayPeriods.first.startTime;
      final todaySunset = nightPeriods.first.startTime;
      if (todaySunrise != null && todaySunset != null && now.isBefore(todaySunrise)) {
        final effectivePrevSunset = prevSunset ?? todaySunset.subtract(const Duration(days: 1));
        final effectiveWk = weekdayIndex ?? toGowriWeekdayIndex(todaySunrise.weekday);
        final prevWeekday = (effectiveWk - 1 + 7) % 7;
        final prevNightPeriods = calculateNightGowriPeriods(
          sunset: effectivePrevSunset,
          nextSunrise: todaySunrise,
          weekdayIndex: prevWeekday,
          currentTime: now,
        );
        for (final p in prevNightPeriods) {
          if (p.startTime != null && p.endTime != null) {
            if (!now.isBefore(p.startTime!) && now.isBefore(p.endTime!)) {
              return CurrentGowriResult(
                period: p,
                isDay: false,
                dayNightTa: 'இரவு கௌரி (Night)',
              );
            }
          }
        }
      }
    }

    return null;
  }
}
