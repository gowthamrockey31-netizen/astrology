import '../models/kp2_planet.dart';
import '../models/kp2_dasha.dart';

/// Engine to compute Vimshottari Dasha, Bhukti, Antara, and Birth Balance
class KP2DashaEngine {
  /// Vimshottari sequence of 9 planets
  static const List<KP2Planet> sequence = [
    KP2Planet.ketu,
    KP2Planet.venus,
    KP2Planet.sun,
    KP2Planet.moon,
    KP2Planet.mars,
    KP2Planet.rahu,
    KP2Planet.jupiter,
    KP2Planet.saturn,
    KP2Planet.mercury,
  ];

  /// Calculates birth balance and dasha timeline
  static (KP2DashaBalance, List<KP2DashaPeriod>) calculate({
    required double moonLongitude,
    required DateTime birthDateTime,
  }) {
    // 1. Determine Moon nakshatra and lord
    const nakSpan = 360.0 / 27.0; // 13°20' = 13.333333333333334
    final normMoon = (moonLongitude % 360.0 + 360.0) % 360.0;
    final nakIndex = (normMoon / nakSpan).floor();
    final lord = sequence[nakIndex % 9];

    final progressDeg = normMoon - (nakIndex * nakSpan);
    final fractionElapsed = (progressDeg / nakSpan).clamp(0.0, 1.0);
    final fractionRemaining = (1.0 - fractionElapsed).clamp(0.0, 1.0);

    final totalDashaYears = lord.dashaYears.toDouble();
    final balanceYearsExact = fractionRemaining * totalDashaYears;

    final bYears = balanceYearsExact.floor();
    final remAfterYears = balanceYearsExact - bYears;
    final bMonthsExact = remAfterYears * 12.0;
    int bMonths = bMonthsExact.floor();
    final remAfterMonths = bMonthsExact - bMonths;
    int bDays = (remAfterMonths * 30.4375).round();

    if (bDays >= 30) {
      bMonths += 1;
      bDays -= 30;
    }
    int finalYears = bYears;
    int finalMonths = bMonths;
    if (finalMonths >= 12) {
      finalYears += 1;
      finalMonths -= 12;
    }

    final balance = KP2DashaBalance(
      lord: lord,
      years: finalYears,
      months: finalMonths,
      days: bDays,
      balanceYears: balanceYearsExact,
    );

    // 2. Generate Timeline (up to 120 years from birth)
    final timeline = _generateTimeline(
      startLord: lord,
      balanceYears: balanceYearsExact,
      birthDateTime: birthDateTime,
    );

    return (balance, timeline);
  }

  static List<KP2DashaPeriod> _generateTimeline({
    required KP2Planet startLord,
    required double balanceYears,
    required DateTime birthDateTime,
  }) {
    final List<KP2DashaPeriod> mahaList = [];
    final startIndex = sequence.indexOf(startLord);

    DateTime currentStart = birthDateTime;

    // First Mahadasha with balance
    final firstDurationDays = (balanceYears * 365.2425).round();
    DateTime currentEnd = currentStart.add(Duration(days: firstDurationDays));

    mahaList.add(KP2DashaPeriod(
      lord: startLord,
      level: 1,
      startDate: currentStart,
      endDate: currentEnd,
      subPeriods: _generateBhuktis(
        mahaLord: startLord,
        mahaStart: currentStart,
        mahaEnd: currentEnd,
        isFirstMaha: true,
        fullMahaYears: startLord.dashaYears.toDouble(),
      ),
    ));

    currentStart = currentEnd;

    // Remaining 8 Mahadashas (or until ~120 years total)
    for (int i = 1; i < 9; i++) {
      final lord = sequence[(startIndex + i) % 9];
      final durationDays = (lord.dashaYears * 365.2425).round();
      currentEnd = currentStart.add(Duration(days: durationDays));

      mahaList.add(KP2DashaPeriod(
        lord: lord,
        level: 1,
        startDate: currentStart,
        endDate: currentEnd,
        subPeriods: _generateBhuktis(
          mahaLord: lord,
          mahaStart: currentStart,
          mahaEnd: currentEnd,
          isFirstMaha: false,
          fullMahaYears: lord.dashaYears.toDouble(),
        ),
      ));

      currentStart = currentEnd;
    }

    return mahaList;
  }

  static List<KP2DashaPeriod> _generateBhuktis({
    required KP2Planet mahaLord,
    required DateTime mahaStart,
    required DateTime mahaEnd,
    required bool isFirstMaha,
    required double fullMahaYears,
  }) {
    final bhuktis = <KP2DashaPeriod>[];
    final startIndex = sequence.indexOf(mahaLord);

    // Calculate ideal durations of all 9 bhuktis
    // Bhukti years = (MahaYears * BhuktiYears) / 120.0
    final totalMahaDurationMs = mahaEnd.difference(mahaStart).inMilliseconds;

    DateTime bStart = mahaStart;

    for (int i = 0; i < 9; i++) {
      final bLord = sequence[(startIndex + i) % 9];
      // Fractional proportion of this Bhukti in this Mahadasha
      final proportion = bLord.dashaYears / 120.0;
      final bhuktiMs = (totalMahaDurationMs * proportion).round();

      DateTime bEnd = (i == 8) ? mahaEnd : bStart.add(Duration(milliseconds: bhuktiMs));
      if (bEnd.isAfter(mahaEnd)) bEnd = mahaEnd;

      bhuktis.add(KP2DashaPeriod(
        lord: bLord,
        level: 2,
        startDate: bStart,
        endDate: bEnd,
        subPeriods: _generateAntaras(
          mahaLord: mahaLord,
          bhuktiLord: bLord,
          bhuktiStart: bStart,
          bhuktiEnd: bEnd,
        ),
      ));

      bStart = bEnd;
      if (bStart.isAfter(mahaEnd) || bStart.isAtSameMomentAs(mahaEnd)) break;
    }

    return bhuktis;
  }

  static List<KP2DashaPeriod> _generateAntaras({
    required KP2Planet mahaLord,
    required KP2Planet bhuktiLord,
    required DateTime bhuktiStart,
    required DateTime bhuktiEnd,
  }) {
    final antaras = <KP2DashaPeriod>[];
    final startIndex = sequence.indexOf(bhuktiLord);
    final totalBhuktiMs = bhuktiEnd.difference(bhuktiStart).inMilliseconds;

    DateTime aStart = bhuktiStart;

    for (int i = 0; i < 9; i++) {
      final aLord = sequence[(startIndex + i) % 9];
      final proportion = aLord.dashaYears / 120.0;
      final antaraMs = (totalBhuktiMs * proportion).round();

      DateTime aEnd = (i == 8) ? bhuktiEnd : aStart.add(Duration(milliseconds: antaraMs));
      if (aEnd.isAfter(bhuktiEnd)) aEnd = bhuktiEnd;

      antaras.add(KP2DashaPeriod(
        lord: aLord,
        level: 3,
        startDate: aStart,
        endDate: aEnd,
      ));

      aStart = aEnd;
      if (aStart.isAfter(bhuktiEnd) || aStart.isAtSameMomentAs(bhuktiEnd)) break;
    }

    return antaras;
  }
}
