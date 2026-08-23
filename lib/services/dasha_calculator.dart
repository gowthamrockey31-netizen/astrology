import 'astrology_calculator.dart';

class DashaPeriod {
  final String lordEn;
  final String lordTa;
  final int level; // 1: MahaDasha, 2: Bhukti, 3: Antharam, 4: Sookshmam
  final DateTime startDate;
  final DateTime endDate;
  final double durationYears;
  final bool isActive;
  final List<DashaPeriod> subPeriods;

  DashaPeriod({
    required this.lordEn,
    required this.lordTa,
    required this.level,
    required this.startDate,
    required this.endDate,
    required this.durationYears,
    required this.isActive,
    this.subPeriods = const [],
  });

  String get durationFormatted {
    final totalDays = endDate.difference(startDate).inDays;
    final years = totalDays ~/ 365;
    final remainingDays = totalDays % 365;
    final months = remainingDays ~/ 30;
    final days = remainingDays % 30;
    return "$years வ, $months மா, $days நா";
  }

  String get dateRangeFormatted {
    return "${_formatDate(startDate)} → ${_formatDate(endDate)}";
  }

  static String _formatDate(DateTime dt) {
    return "${dt.day.toString().padLeft(2, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.year}";
  }
}

class VimshottariDashaCalculator {
  static const List<String> lordsEn = [
    'Ketu', 'Venus', 'Sun', 'Moon', 'Mars', 'Rahu', 'Jupiter', 'Saturn', 'Mercury'
  ];

  static const List<String> lordsTa = [
    'கேது', 'சுக்கிரன்', 'சூரியன்', 'சந்திரன்', 'செவ்வாய்', 'ராகு', 'குரு', 'சனி', 'புதன்'
  ];

  static const Map<String, double> dashaYears = {
    'Ketu': 7.0,
    'Venus': 20.0,
    'Sun': 6.0,
    'Moon': 10.0,
    'Mars': 7.0,
    'Rahu': 18.0,
    'Jupiter': 16.0,
    'Saturn': 19.0,
    'Mercury': 17.0,
  };

  /// Compute 4-level Vimshottari Dasha timeline from Moon's sidereal longitude and birth DateTime
  static List<DashaPeriod> calculateDashaTimeline({
    required double moonLongitude,
    required DateTime dateOfBirth,
    DateTime? now,
  }) {
    final currentDate = now ?? DateTime.now();
    final nakshatraSpan = 360.0 / 27.0; // 13.333333°
    final nakshatraIndex = (moonLongitude / nakshatraSpan).floor() % 27;
    final nakshatraOffset = moonLongitude - (nakshatraIndex * nakshatraSpan);
    final fractionElapsed = nakshatraOffset / nakshatraSpan;

    final firstLordIndex = nakshatraIndex % 9;
    final firstLordEn = lordsEn[firstLordIndex];
    final firstLordTotalYears = dashaYears[firstLordEn]!;

    final birthDashaBalanceYears = (1.0 - fractionElapsed) * firstLordTotalYears;
    final elapsedYearsAtBirth = fractionElapsed * firstLordTotalYears;

    // Start date of the first Maha Dasha is DOB minus elapsed years
    DateTime dashaStart = dateOfBirth.subtract(Duration(days: (elapsedYearsAtBirth * 365.25).round()));

    final List<DashaPeriod> mahaDashas = [];

    for (int i = 0; i < 9; i++) {
      final lordIdx = (firstLordIndex + i) % 9;
      final lordEn = lordsEn[lordIdx];
      final lordTa = lordsTa[lordIdx];
      final duration = dashaYears[lordEn]!;

      final dashaEnd = dashaStart.add(Duration(days: (duration * 365.25).round()));
      final isMdActive = currentDate.isAfter(dashaStart) && currentDate.isBefore(dashaEnd);

      // Level 2: Bhuktis
      final List<DashaPeriod> bhuktis = _calculateBhuktis(
        mdLordIndex: lordIdx,
        mdStart: dashaStart,
        mdDurationYears: duration,
        currentDate: currentDate,
      );

      mahaDashas.add(DashaPeriod(
        lordEn: lordEn,
        lordTa: lordTa,
        level: 1,
        startDate: dashaStart,
        endDate: dashaEnd,
        durationYears: duration,
        isActive: isMdActive,
        subPeriods: bhuktis,
      ));

      dashaStart = dashaEnd;
    }

    return mahaDashas;
  }

  static List<DashaPeriod> _calculateBhuktis({
    required int mdLordIndex,
    required DateTime mdStart,
    required double mdDurationYears,
    required DateTime currentDate,
  }) {
    final List<DashaPeriod> bhuktis = [];
    DateTime bhuktiStart = mdStart;

    for (int i = 0; i < 9; i++) {
      final bhuktiLordIdx = (mdLordIndex + i) % 9;
      final bhuktiLordEn = lordsEn[bhuktiLordIdx];
      final bhuktiLordTa = lordsTa[bhuktiLordIdx];
      final bhuktiYears = (mdDurationYears * dashaYears[bhuktiLordEn]!) / 120.0;

      final bhuktiEnd = bhuktiStart.add(Duration(days: (bhuktiYears * 365.25).round()));
      final isBhActive = currentDate.isAfter(bhuktiStart) && currentDate.isBefore(bhuktiEnd);

      // Level 3: Antharams
      final List<DashaPeriod> antharams = _calculateAntharams(
        mdDurationYears: mdDurationYears,
        bhuktiLordEn: bhuktiLordEn,
        bhuktiLordIndex: bhuktiLordIdx,
        bhuktiStart: bhuktiStart,
        currentDate: currentDate,
      );

      bhuktis.add(DashaPeriod(
        lordEn: bhuktiLordEn,
        lordTa: bhuktiLordTa,
        level: 2,
        startDate: bhuktiStart,
        endDate: bhuktiEnd,
        durationYears: bhuktiYears,
        isActive: isBhActive,
        subPeriods: antharams,
      ));

      bhuktiStart = bhuktiEnd;
    }

    return bhuktis;
  }

  static List<DashaPeriod> _calculateAntharams({
    required double mdDurationYears,
    required String bhuktiLordEn,
    required int bhuktiLordIndex,
    required DateTime bhuktiStart,
    required DateTime currentDate,
  }) {
    final List<DashaPeriod> antharams = [];
    DateTime antStart = bhuktiStart;

    for (int i = 0; i < 9; i++) {
      final antLordIdx = (bhuktiLordIndex + i) % 9;
      final antLordEn = lordsEn[antLordIdx];
      final antLordTa = lordsTa[antLordIdx];
      final antYears = (mdDurationYears * dashaYears[bhuktiLordEn]! * dashaYears[antLordEn]!) / (120.0 * 120.0);

      final antEnd = antStart.add(Duration(days: (antYears * 365.25).round()));
      final isAntActive = currentDate.isAfter(antStart) && currentDate.isBefore(antEnd);

      // Level 4: Sookshmams
      final List<DashaPeriod> sookshmams = _calculateSookshmams(
        mdDurationYears: mdDurationYears,
        bhuktiLordEn: bhuktiLordEn,
        antLordEn: antLordEn,
        antLordIndex: antLordIdx,
        antStart: antStart,
        currentDate: currentDate,
      );

      antharams.add(DashaPeriod(
        lordEn: antLordEn,
        lordTa: antLordTa,
        level: 3,
        startDate: antStart,
        endDate: antEnd,
        durationYears: antYears,
        isActive: isAntActive,
        subPeriods: sookshmams,
      ));

      antStart = antEnd;
    }

    return antharams;
  }

  static List<DashaPeriod> _calculateSookshmams({
    required double mdDurationYears,
    required String bhuktiLordEn,
    required String antLordEn,
    required int antLordIndex,
    required DateTime antStart,
    required DateTime currentDate,
  }) {
    final List<DashaPeriod> sookshmams = [];
    DateTime sookStart = antStart;

    for (int i = 0; i < 9; i++) {
      final sookLordIdx = (antLordIndex + i) % 9;
      final sookLordEn = lordsEn[sookLordIdx];
      final sookLordTa = lordsTa[sookLordIdx];
      final sookYears = (mdDurationYears * dashaYears[bhuktiLordEn]! * dashaYears[antLordEn]! * dashaYears[sookLordEn]!) / (120.0 * 120.0 * 120.0);

      final sookEnd = sookStart.add(Duration(days: (sookYears * 365.25).round()));
      final isSookActive = currentDate.isAfter(sookStart) && currentDate.isBefore(sookEnd);

      sookshmams.add(DashaPeriod(
        lordEn: sookLordEn,
        lordTa: sookLordTa,
        level: 4,
        startDate: sookStart,
        endDate: sookEnd,
        durationYears: sookYears,
        isActive: isSookActive,
      ));

      sookStart = sookEnd;
    }

    return sookshmams;
  }

  /// Helper to get summary text of birth balance and current running Dasha
  static Map<String, String> getDashaSummary({
    required double moonLongitude,
    required DateTime dateOfBirth,
    DateTime? now,
  }) {
    final timeline = calculateDashaTimeline(moonLongitude: moonLongitude, dateOfBirth: dateOfBirth, now: now);

    DashaPeriod? activeMd;
    DashaPeriod? activeBh;

    for (final md in timeline) {
      if (md.isActive) {
        activeMd = md;
        for (final bh in md.subPeriods) {
          if (bh.isActive) {
            activeBh = bh;
            break;
          }
        }
        break;
      }
    }

    final nakshatraSpan = 360.0 / 27.0;
    final nakshatraIndex = (moonLongitude / nakshatraSpan).floor() % 27;
    final nakshatraOffset = moonLongitude - (nakshatraIndex * nakshatraSpan);
    final fractionElapsed = nakshatraOffset / nakshatraSpan;

    final firstLordIndex = nakshatraIndex % 9;
    final firstLordEn = lordsEn[firstLordIndex];
    final firstLordTa = lordsTa[firstLordIndex];
    final firstLordTotalYears = dashaYears[firstLordEn]!;
    final balanceYears = (1.0 - fractionElapsed) * firstLordTotalYears;

    final totalDays = (balanceYears * 365.25).round();
    final y = totalDays ~/ 365;
    final remDays = totalDays % 365;
    final m = remDays ~/ 30;
    final d = remDays % 30;

    return {
      'birthDashaLord': "$firstLordTa ($firstLordEn)",
      'birthDashaBalance': "$y வ, $m மா, $d நா",
      'currentMahaDasha': activeMd != null ? "${activeMd.lordTa} (${activeMd.lordEn})" : "—",
      'currentMahaDashaRange': activeMd != null ? activeMd.dateRangeFormatted : "—",
      'currentBhukti': activeBh != null ? "${activeBh.lordTa} (${activeBh.lordEn})" : "—",
      'currentBhuktiRange': activeBh != null ? activeBh.dateRangeFormatted : "—",
    };
  }
}
