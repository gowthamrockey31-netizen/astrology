import '../models/kp_dasha.dart';
import '../models/kp_planet_position.dart';
import 'kp_nakshatra_engine.dart';

/// Vimshottari Dasha, Bhukti, Antara, Sookshma calculation engine
class KPDashaEngine {
  /// Calculate full Dasha hierarchy from Moon's sidereal longitude and birth DateTime
  static KPDashaHierarchy calculate({
    required double moonLongitude,
    required DateTime birthDateTime,
    DateTime? targetDateTime,
    List<KPPlanetPosition> planets = const [],
  }) {
    final target = targetDateTime ?? DateTime.now();

    // Map each planet to its related houses
    final Map<String, List<int>> planetHouseMap = {};
    for (final p in planets) {
      planetHouseMap[p.planet.nameEn] = p.relatedHouses;
    }

    final nakInfo = KPNakshatraEngine.calculate(moonLongitude);
    final birthLord = nakInfo.lordEn;
    final double totalYears = KPNakshatraEngine.vimshottariYears[birthLord]!;
    final double fractionRemaining = (nakInfo.remainingMinutes / 800.0).clamp(0.0, 1.0);

    final double balanceYearsExact = totalYears * fractionRemaining;
    final int balanceYears = balanceYearsExact.floor();
    final double remMonthsExact = (balanceYearsExact - balanceYears) * 12.0;
    final int balanceMonths = remMonthsExact.floor();
    final int balanceDays = ((remMonthsExact - balanceMonths) * 30.4375).round();

    final int totalBalanceDays = (balanceYearsExact * 365.2425).round();
    final birthDashaEnd = birthDateTime.add(Duration(days: totalBalanceDays));

    final birthBalance = KPBirthDashaBalance(
      planet: birthLord,
      years: balanceYears,
      months: balanceMonths,
      days: balanceDays,
      startDate: birthDateTime,
      endDate: birthDashaEnd,
    );

    // Build the 9 Mahadasha sequence
    final int startLordIdx = KPNakshatraEngine.dashaLordSequenceEn.indexOf(birthLord);
    final List<KPDashaPeriod> mahadashas = [];
    DateTime currentPeriodStart = birthDateTime;

    KPDashaPeriod? activeMaha;
    KPDashaPeriod? activeBhukti;
    KPDashaPeriod? activeAntara;
    KPDashaPeriod? activeSookshma;

    for (int i = 0; i < 9; i++) {
      final int lordIdx = (startLordIdx + i) % 9;
      final String lord = KPNakshatraEngine.dashaLordSequenceEn[lordIdx];
      final double lordTotalYears = KPNakshatraEngine.vimshottariYears[lord]!;

      final DateTime periodEnd;
      if (i == 0) {
        periodEnd = birthDashaEnd;
      } else {
        final days = (lordTotalYears * 365.2425).round();
        periodEnd = currentPeriodStart.add(Duration(days: days));
      }

      final bool isCurrentMaha = target.isAfter(currentPeriodStart) && target.isBefore(periodEnd);

      // Calculate Bhuktis for this Mahadasha
      final List<KPDashaPeriod> bhuktis = [];
      DateTime currentBhuktiStart = currentPeriodStart;

      final double mahaDurationDays = periodEnd.difference(currentPeriodStart).inDays.toDouble();

      for (int b = 0; b < 9; b++) {
        final int bIdx = (lordIdx + b) % 9;
        final String bLord = KPNakshatraEngine.dashaLordSequenceEn[bIdx];
        final double bYears = KPNakshatraEngine.vimshottariYears[bLord]!;
        final double bhuktiDays = (bYears / 120.0) * (i == 0 ? (lordTotalYears * 365.2425) : mahaDurationDays);

        DateTime bhuktiEnd = currentBhuktiStart.add(Duration(days: bhuktiDays.round()));
        if (b == 8 || bhuktiEnd.isAfter(periodEnd)) {
          bhuktiEnd = periodEnd;
        }

        final bool isCurrentBhukti = isCurrentMaha && target.isAfter(currentBhuktiStart) && target.isBefore(bhuktiEnd);

        // If current Bhukti, calculate Antaras
        final List<KPDashaPeriod> antaras = [];
        if (isCurrentBhukti) {
          DateTime currentAntaraStart = currentBhuktiStart;
          final double bhuktiDurationDays = bhuktiEnd.difference(currentBhuktiStart).inDays.toDouble();

          for (int a = 0; a < 9; a++) {
            final int aIdx = (bIdx + a) % 9;
            final String aLord = KPNakshatraEngine.dashaLordSequenceEn[aIdx];
            final double aYears = KPNakshatraEngine.vimshottariYears[aLord]!;
            final double antaraDays = (aYears / 120.0) * bhuktiDurationDays;

            DateTime antaraEnd = currentAntaraStart.add(Duration(days: antaraDays.round()));
            if (a == 8 || antaraEnd.isAfter(bhuktiEnd)) {
              antaraEnd = bhuktiEnd;
            }

            final bool isCurrentAntara = target.isAfter(currentAntaraStart) && target.isBefore(antaraEnd);

            // If current Antara, calculate Sookshmas
            final List<KPDashaPeriod> sookshmas = [];
            if (isCurrentAntara) {
              DateTime currentSookshmaStart = currentAntaraStart;
              final double antaraDurationDays = antaraEnd.difference(currentAntaraStart).inDays.toDouble();

              for (int s = 0; s < 9; s++) {
                final int sIdx = (aIdx + s) % 9;
                final String sLord = KPNakshatraEngine.dashaLordSequenceEn[sIdx];
                final double sYears = KPNakshatraEngine.vimshottariYears[sLord]!;
                final double sookshmaDays = (sYears / 120.0) * antaraDurationDays;

                DateTime sookshmaEnd = currentSookshmaStart.add(Duration(days: sookshmaDays.round()));
                if (s == 8 || sookshmaEnd.isAfter(antaraEnd)) {
                  sookshmaEnd = antaraEnd;
                }

                final bool isCurrentSookshma = target.isAfter(currentSookshmaStart) && target.isBefore(sookshmaEnd);

                final sookshmaPeriod = KPDashaPeriod(
                  planet: sLord,
                  level: 'Sookshma',
                  startDate: currentSookshmaStart,
                  endDate: sookshmaEnd,
                  relatedHouses: planetHouseMap[sLord] ?? [],
                  isCurrent: isCurrentSookshma,
                );
                sookshmas.add(sookshmaPeriod);

                if (isCurrentSookshma) {
                  activeSookshma = sookshmaPeriod;
                }

                currentSookshmaStart = sookshmaEnd;
              }
            }

            final antaraPeriod = KPDashaPeriod(
              planet: aLord,
              level: 'Antara',
              startDate: currentAntaraStart,
              endDate: antaraEnd,
              relatedHouses: planetHouseMap[aLord] ?? [],
              isCurrent: isCurrentAntara,
              children: sookshmas,
            );
            antaras.add(antaraPeriod);

            if (isCurrentAntara) {
              activeAntara = antaraPeriod;
            }

            currentAntaraStart = antaraEnd;
          }
        }

        final bhuktiPeriod = KPDashaPeriod(
          planet: bLord,
          level: 'Bhukti',
          startDate: currentBhuktiStart,
          endDate: bhuktiEnd,
          relatedHouses: planetHouseMap[bLord] ?? [],
          isCurrent: isCurrentBhukti,
          children: antaras,
        );
        bhuktis.add(bhuktiPeriod);

        if (isCurrentBhukti) {
          activeBhukti = bhuktiPeriod;
        }

        currentBhuktiStart = bhuktiEnd;
      }

      final mahaPeriod = KPDashaPeriod(
        planet: lord,
        level: 'Mahadasha',
        startDate: currentPeriodStart,
        endDate: periodEnd,
        relatedHouses: planetHouseMap[lord] ?? [],
        isCurrent: isCurrentMaha,
        children: bhuktis,
      );
      mahadashas.add(mahaPeriod);

      if (isCurrentMaha) {
        activeMaha = mahaPeriod;
      }

      currentPeriodStart = periodEnd;
    }

    return KPDashaHierarchy(
      birthBalance: birthBalance,
      currentMahadasha: activeMaha,
      currentBhukti: activeBhukti,
      currentAntara: activeAntara,
      currentSookshma: activeSookshma,
      mahadashas: mahadashas,
    );
  }
}
