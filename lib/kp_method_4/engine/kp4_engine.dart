import 'dart:math';
import '../../services/swiss_ephemeris_calculator.dart';
import '../models/kp4_models.dart';
import 'kp_method_4_relation_engine.dart';

/// Complete Calculation Engine for KP Method 4
/// Uses high-precision Swiss Ephemeris data, Placidus cusps, and proportional Vimshottari arc divisions
class Kp4Engine {
  static const List<String> signsEn = [
    'Aries', 'Taurus', 'Gemini', 'Cancer',
    'Leo', 'Virgo', 'Libra', 'Scorpio',
    'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces',
  ];

  static const List<String> signsTa = [
    'மேஷம்', 'ரிஷபம்', 'மிதுனம்', 'கடகம்',
    'சிம்மம்', 'கன்னி', 'துலாம்', 'விருச்சிகம்',
    'தனுசு', 'மகரம்', 'கும்பம்', 'மீனம்',
  ];

  static const List<String> planetsEn = [
    'Sun', 'Moon', 'Mars', 'Mercury', 'Jupiter', 'Venus', 'Saturn', 'Rahu', 'Ketu',
  ];

  static const Map<String, String> planetsTa = {
    'Sun': 'சூரியன்',
    'Moon': 'சந்திரன்',
    'Mars': 'செவ்வாய்',
    'Mercury': 'புதன்',
    'Jupiter': 'குரு',
    'Venus': 'சுக்கிரன்',
    'Saturn': 'சனி',
    'Rahu': 'ராகு',
    'Ketu': 'கேது',
  };

  static const List<String> dashaLordSequence = [
    'Ketu', 'Venus', 'Sun', 'Moon', 'Mars', 'Rahu', 'Jupiter', 'Saturn', 'Mercury',
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

  static const List<String> nakshatrasEn = [
    'Ashwini', 'Bharani', 'Krittika', 'Rohini', 'Mrigashirsha', 'Ardra',
    'Punarvasu', 'Pushya', 'Ashlesha', 'Magha', 'Purva Phalguni', 'Uttara Phalguni',
    'Hasta', 'Chitra', 'Swati', 'Vishakha', 'Anuradha', 'Jyeshtha',
    'Mula', 'Purva Ashadha', 'Uttara Ashadha', 'Shravana', 'Dhanishta', 'Shatabhisha',
    'Purva Bhadrapada', 'Uttara Bhadrapada', 'Revati',
  ];

  static const List<String> nakshatrasTa = [
    'அஸ்வினி', 'பரணி', 'கிருத்திகை', 'ரோகிணி', 'மிருகசீரிஷம்', 'திருவாதிரை',
    'புனர்பூசம்', 'பூசம்', 'ஆயில்யம்', 'மகம்', 'பூரம்', 'உத்திரம்',
    'அஸ்தம்', 'சித்திரை', 'சுவாதி', 'விசாகம்', 'அனுஷம்', 'கேட்டை',
    'மூலம்', 'பூராடம்', 'உத்திராடம்', 'திருவோணம்', 'அவிட்டம்', 'சதயம்',
    'பூரட்டாதி', 'உத்திரட்டாதி', 'ரேவதி',
  ];

  /// Calculate complete KP Method 4 results
  static KpResult calculate(Kp4BirthData birthData, {DateTime? evaluationTime}) {
    // 1. Julian Day & KP Ayanamsa
    final jd = SwissEphemerisCalculator.getJulianDay(
      birthData.dateTime,
      utcOffsetHours: birthData.timezone,
    );
    final lahiriAyanamsa = SwissEphemerisCalculator.calculateLahiriAyanamsa(jd);
    // KP Ayanamsa offset: - 6 arcminutes (-0.1 degrees)
    final kpAyanamsa = lahiriAyanamsa - (6.0 / 60.0);
    final ayanamsaStr = formatDms(kpAyanamsa);

    // 2. Sidereal Ascendant (Lagna)
    final ascLong = SwissEphemerisCalculator.calculateAscendantSidereal(
      jd: jd,
      latitude: birthData.latitude,
      longitude: birthData.longitude,
      ayanamsa: kpAyanamsa,
    );
    final ascSignIdx = (ascLong / 30.0).floor().clamp(0, 11);
    final ascDegInRasi = ascLong % 30.0;
    final ascDegStr = formatDms(ascDegInRasi);

    // 3. 12 Placidus Cusps converted to Sidereal via KP Ayanamsa
    final rawCusps = _calculatePlacidusCusps(
      jd: jd,
      latitude: birthData.latitude,
      longitude: birthData.longitude,
      ayanamsa: kpAyanamsa,
    );

    final List<CuspPosition> cusps = [];
    for (int i = 0; i < 12; i++) {
      final double cLong = normalizeDegrees(rawCusps[i]);
      final int signIdx = (cLong / 30.0).floor().clamp(0, 11);
      final double degInRasi = cLong % 30.0;
      final kpDiv = _getKpDivision(cLong);

      cusps.add(
        CuspPosition(
          cuspNumber: i + 1,
          longitude: cLong,
          signIndex: signIdx,
          signName: signsEn[signIdx],
          signNameTa: signsTa[signIdx],
          degreeInRasi: degInRasi,
          degreeStr: formatDms(degInRasi),
          starLord: kpDiv.starLord,
          starLordTa: planetsTa[kpDiv.starLord] ?? kpDiv.starLord,
          subLord: kpDiv.subLord,
          subLordTa: planetsTa[kpDiv.subLord] ?? kpDiv.subLord,
          subSubLord: kpDiv.subSubLord,
          subSubLordTa: planetsTa[kpDiv.subSubLord] ?? kpDiv.subSubLord,
          nakshatraIndex: kpDiv.nakIndex,
          nakshatraName: nakshatrasEn[kpDiv.nakIndex],
          nakshatraNameTa: nakshatrasTa[kpDiv.nakIndex],
          pada: kpDiv.pada,
        ),
      );
    }

    // 4. 9 Planetary Positions
    final ephemPositions = SwissEphemerisCalculator.calculatePlanetaryPositions(
      jd: jd,
      ayanamsa: kpAyanamsa,
    );

    final List<PlanetPosition> planets = [];
    for (final pName in planetsEn) {
      final pos = ephemPositions[pName] ?? (longitude: 0.0, isRetrograde: false);
      final pLong = normalizeDegrees(pos.longitude);
      final int signIdx = (pLong / 30.0).floor().clamp(0, 11);
      final double degInRasi = pLong % 30.0;
      final kpDiv = _getKpDivision(pLong);

      planets.add(
        PlanetPosition(
          planet: pName,
          planetTa: planetsTa[pName] ?? pName,
          longitude: pLong,
          signIndex: signIdx,
          signName: signsEn[signIdx],
          signNameTa: signsTa[signIdx],
          degreeInRasi: degInRasi,
          degreeStr: formatDms(degInRasi),
          starLord: kpDiv.starLord,
          starLordTa: planetsTa[kpDiv.starLord] ?? kpDiv.starLord,
          subLord: kpDiv.subLord,
          subLordTa: planetsTa[kpDiv.subLord] ?? kpDiv.subLord,
          subSubLord: kpDiv.subSubLord,
          subSubLordTa: planetsTa[kpDiv.subSubLord] ?? kpDiv.subSubLord,
          nakshatraIndex: kpDiv.nakIndex,
          nakshatraName: nakshatrasEn[kpDiv.nakIndex],
          nakshatraNameTa: nakshatrasTa[kpDiv.nakIndex],
          pada: kpDiv.pada,
          isRetrograde: pos.isRetrograde,
        ),
      );
    }

    // 5. Graha Thodarbhu (Planet Relations) via centralized relation engine
    final planetRelations = KpMethod4RelationEngine.calculatePlanetRelations(
      planets: planets,
      cusps: cusps,
    );

    // 6. Bhava Graha Thodarbhu (House Relations)
    final houseRelations = KpMethod4RelationEngine.calculateHouseRelations(
      cusps: cusps,
      planets: planets,
      planetRelations: planetRelations,
    );

    // 7. Active Dasha / Bhukti / Antara / Sookshma
    final moonPlanet = planets.firstWhere((p) => p.planet == 'Moon');
    final activeDashaLords = _calculateActiveDashaLords(
      moonLongitude: moonPlanet.longitude,
      birthDateTime: birthData.dateTime,
      targetDateTime: evaluationTime ?? DateTime.now(),
    );

    final dashaRelations = KpMethod4RelationEngine.calculateDashaRelations(
      dashaLord: activeDashaLords.dasha,
      bhuktiLord: activeDashaLords.bhukti,
      antaraLord: activeDashaLords.antara,
      sookshmaLord: activeDashaLords.sookshma,
      planetRelations: planetRelations,
    );

    return KpResult(
      birthData: birthData,
      ascendantDegree: ascLong,
      ascendantDegreeStr: ascDegStr,
      ascendantSignTa: signsTa[ascSignIdx],
      ayanamsa: kpAyanamsa,
      ayanamsaStr: ayanamsaStr,
      planetPositions: planets,
      cuspPositions: cusps,
      planetRelations: planetRelations,
      houseRelations: houseRelations,
      dashaRelations: dashaRelations,
    );
  }

  /// Calculates Star Lord, Sub Lord, and Sub-Sub Lord proportionally
  static ({
    int nakIndex,
    int pada,
    String starLord,
    String subLord,
    String subSubLord,
  }) _getKpDivision(double longitude) {
    const double nakSpan = 360.0 / 27.0; // 13.333333333333334°
    final norm = normalizeDegrees(longitude);
    final int nakIdx = (norm / nakSpan).floor().clamp(0, 26);
    final double nakOffset = norm - (nakIdx * nakSpan);

    final pada = ((nakOffset / (nakSpan / 4.0)).floor() % 4) + 1;

    final int starLordIdx = nakIdx % 9;
    final starLord = dashaLordSequence[starLordIdx];

    // Sub Lord
    double accumulatedSub = 0.0;
    int subLordIdx = starLordIdx;
    double chosenSubStart = 0.0;
    double chosenSubSpan = 0.0;

    for (int i = 0; i < 9; i++) {
      final int currentIdx = (starLordIdx + i) % 9;
      final String planet = dashaLordSequence[currentIdx];
      final double years = dashaYears[planet]!;
      final double span = (years / 120.0) * nakSpan;

      if (i == 8 || (nakOffset >= accumulatedSub && nakOffset < (accumulatedSub + span - 1e-9))) {
        subLordIdx = currentIdx;
        chosenSubStart = accumulatedSub;
        chosenSubSpan = span;
        break;
      }
      accumulatedSub += span;
    }

    final subLord = dashaLordSequence[subLordIdx];
    final offsetInSub = (nakOffset - chosenSubStart).clamp(0.0, chosenSubSpan);

    // Sub-Sub Lord
    double accumulatedSubSub = 0.0;
    int subSubLordIdx = subLordIdx;

    for (int j = 0; j < 9; j++) {
      final int currentIdx = (subLordIdx + j) % 9;
      final String planet = dashaLordSequence[currentIdx];
      final double years = dashaYears[planet]!;
      final double span = (years / 120.0) * chosenSubSpan;

      if (j == 8 || (offsetInSub >= accumulatedSubSub && offsetInSub < (accumulatedSubSub + span - 1e-9))) {
        subSubLordIdx = currentIdx;
        break;
      }
      accumulatedSubSub += span;
    }

    final subSubLord = dashaLordSequence[subSubLordIdx];

    return (
      nakIndex: nakIdx,
      pada: pada,
      starLord: starLord,
      subLord: subLord,
      subSubLord: subSubLord,
    );
  }

  /// Calculates 12 Placidus Cusps in Tropical then converted to Sidereal via KP Ayanamsa
  static List<double> _calculatePlacidusCusps({
    required double jd,
    required double latitude,
    required double longitude,
    required double ayanamsa,
  }) {
    final t = (jd - 2451545.0) / 36525.0;
    final gmst = normalizeDegrees(
      280.46061837 + 360.98564736629 * (jd - 2451545.0) + 0.000387933 * t * t - (t * t * t) / 38710000.0,
    );
    final ramc = normalizeDegrees(gmst + longitude);

    final epsDeg = 23.4392911 - 0.0130042 * t - 0.00000016 * t * t;
    final epsRad = epsDeg * (pi / 180.0);
    final phiRad = latitude * (pi / 180.0);
    final thetaRad = ramc * (pi / 180.0);

    // 1st Cusp (Ascendant)
    final y1 = cos(thetaRad);
    final x1 = -sin(thetaRad) * cos(epsRad) - tan(phiRad) * sin(epsRad);
    final ascTrop = normalizeDegrees(atan2(y1, x1) * (180.0 / pi));

    // 10th Cusp (Midheaven / MC)
    final mcTrop = normalizeDegrees(atan2(sin(thetaRad), cos(thetaRad) * cos(epsRad)) * (180.0 / pi));

    final cuspsTrop = List<double>.filled(12, 0.0);
    cuspsTrop[0] = ascTrop;
    cuspsTrop[9] = mcTrop;

    if (latitude.abs() < 66.0) {
      cuspsTrop[10] = _calcIntermediatePlacidus(ramc + 30.0, 1.0 / 3.0, epsRad, phiRad);
      cuspsTrop[11] = _calcIntermediatePlacidus(ramc + 60.0, 2.0 / 3.0, epsRad, phiRad);
      cuspsTrop[1] = _calcIntermediatePlacidus(ramc + 120.0, 2.0 / 3.0, epsRad, phiRad);
      cuspsTrop[2] = _calcIntermediatePlacidus(ramc + 150.0, 1.0 / 3.0, epsRad, phiRad);
    } else {
      double diff1 = (ascTrop - mcTrop);
      if (diff1 < 0) diff1 += 360.0;
      cuspsTrop[10] = (mcTrop + diff1 / 3.0) % 360.0;
      cuspsTrop[11] = (mcTrop + (2.0 * diff1) / 3.0) % 360.0;

      final icTrop = (mcTrop + 180.0) % 360.0;
      double diff2 = (icTrop - ascTrop);
      if (diff2 < 0) diff2 += 360.0;
      cuspsTrop[1] = (ascTrop + diff2 / 3.0) % 360.0;
      cuspsTrop[2] = (ascTrop + (2.0 * diff2) / 3.0) % 360.0;
    }

    // Opposite Cusps
    cuspsTrop[3] = (cuspsTrop[9] + 180.0) % 360.0;
    cuspsTrop[4] = (cuspsTrop[10] + 180.0) % 360.0;
    cuspsTrop[5] = (cuspsTrop[11] + 180.0) % 360.0;
    cuspsTrop[6] = (cuspsTrop[0] + 180.0) % 360.0;
    cuspsTrop[7] = (cuspsTrop[1] + 180.0) % 360.0;
    cuspsTrop[8] = (cuspsTrop[2] + 180.0) % 360.0;

    return cuspsTrop.map((trop) => normalizeDegrees(trop - ayanamsa)).toList();
  }

  static double _calcIntermediatePlacidus(double rDeg, double f, double epsRad, double phiRad) {
    final rRad = normalizeDegrees(rDeg) * (pi / 180.0);
    double ra = rRad;

    for (int iter = 0; iter < 20; iter++) {
      final sinD = sin(epsRad) * sin(ra);
      final tanD = sinD / sqrt(max(1e-10, 1.0 - sinD * sinD));
      final dRa = f * asin((tan(phiRad) * tanD).clamp(-1.0, 1.0));
      final nextRa = rRad + dRa;
      if ((nextRa - ra).abs() < 1e-6) {
        ra = nextRa;
        break;
      }
      ra = nextRa;
    }

    final sinD = sin(epsRad) * sin(ra);
    final cosD = sqrt(max(1e-10, 1.0 - sinD * sinD));
    final y = sin(ra) * cos(epsRad) - (sinD / cosD) * sin(epsRad);
    final x = cos(ra);
    return normalizeDegrees(atan2(y, x) * (180.0 / pi));
  }

  /// Calculates current running Dasha, Bhukti, Antara, Sookshma lords
  static ({
    String dasha,
    String bhukti,
    String antara,
    String sookshma,
  }) _calculateActiveDashaLords({
    required double moonLongitude,
    required DateTime birthDateTime,
    required DateTime targetDateTime,
  }) {
    const nakSpan = 360.0 / 27.0;
    final normMoon = normalizeDegrees(moonLongitude);
    final nakIndex = (normMoon / nakSpan).floor().clamp(0, 26);
    final startLordIdx = nakIndex % 9;
    final startLord = dashaLordSequence[startLordIdx];

    final progressDeg = normMoon - (nakIndex * nakSpan);
    final fractionElapsed = (progressDeg / nakSpan).clamp(0.0, 1.0);
    final fractionRemaining = (1.0 - fractionElapsed).clamp(0.0, 1.0);

    final totalDashaYears = dashaYears[startLord]!;
    final balanceYears = fractionRemaining * totalDashaYears;

    double elapsedYears = targetDateTime.difference(birthDateTime).inDays / 365.2425;
    if (elapsedYears < 0) elapsedYears = 0.0;

    // Find Mahadasha
    String curMaha = startLord;
    double mahaTotalYears = totalDashaYears;
    double timeInMaha = 0.0;

    if (elapsedYears < balanceYears) {
      curMaha = startLord;
      mahaTotalYears = totalDashaYears;
      timeInMaha = (totalDashaYears - balanceYears) + elapsedYears;
    } else {
      double rem = elapsedYears - balanceYears;
      for (int i = 1; i < 9 * 3; i++) {
        final nextIdx = (startLordIdx + i) % 9;
        final p = dashaLordSequence[nextIdx];
        final span = dashaYears[p]!;
        if (rem < span) {
          curMaha = p;
          mahaTotalYears = span;
          timeInMaha = rem;
          break;
        }
        rem -= span;
      }
    }

    // Find Bhukti within Mahadasha
    final mahaIdx = dashaLordSequence.indexOf(curMaha);
    String curBhukti = curMaha;
    double bhuktiTotalYears = mahaTotalYears * (dashaYears[curBhukti]! / 120.0);
    double timeInBhukti = timeInMaha;

    double remBhukti = timeInMaha;
    for (int i = 0; i < 9; i++) {
      final bIdx = (mahaIdx + i) % 9;
      final bPlanet = dashaLordSequence[bIdx];
      final bSpan = mahaTotalYears * (dashaYears[bPlanet]! / 120.0);
      if (remBhukti < bSpan || i == 8) {
        curBhukti = bPlanet;
        bhuktiTotalYears = bSpan;
        timeInBhukti = remBhukti;
        break;
      }
      remBhukti -= bSpan;
    }

    // Find Antara within Bhukti
    final bhuktiIdx = dashaLordSequence.indexOf(curBhukti);
    String curAntara = curBhukti;
    double antaraTotalYears = bhuktiTotalYears * (dashaYears[curAntara]! / 120.0);
    double timeInAntara = timeInBhukti;

    double remAntara = timeInBhukti;
    for (int i = 0; i < 9; i++) {
      final aIdx = (bhuktiIdx + i) % 9;
      final aPlanet = dashaLordSequence[aIdx];
      final aSpan = bhuktiTotalYears * (dashaYears[aPlanet]! / 120.0);
      if (remAntara < aSpan || i == 8) {
        curAntara = aPlanet;
        antaraTotalYears = aSpan;
        timeInAntara = remAntara;
        break;
      }
      remAntara -= aSpan;
    }

    // Find Sookshma within Antara
    final antaraIdx = dashaLordSequence.indexOf(curAntara);
    String curSookshma = curAntara;
    double remSookshma = timeInAntara;
    for (int i = 0; i < 9; i++) {
      final sIdx = (antaraIdx + i) % 9;
      final sPlanet = dashaLordSequence[sIdx];
      final sSpan = antaraTotalYears * (dashaYears[sPlanet]! / 120.0);
      if (remSookshma < sSpan || i == 8) {
        curSookshma = sPlanet;
        break;
      }
      remSookshma -= sSpan;
    }

    return (
      dasha: curMaha,
      bhukti: curBhukti,
      antara: curAntara,
      sookshma: curSookshma,
    );
  }

  /// Format decimal degrees into standard DMS string: DD° MM' SS"
  static String formatDms(double deg) {
    double norm = deg % 360.0;
    if (norm < 0) norm += 360.0;
    final d = norm.floor();
    final mf = (norm - d) * 60.0;
    final m = mf.floor();
    final sf = (mf - m) * 60.0;
    final s = sf.round();
    final sClamped = s >= 60 ? 59 : s;
    return '$d° ${m.toString().padLeft(2, '0')}\' ${sClamped.toString().padLeft(2, '0')}"';
  }

  /// Normalize degree to [0, 360)
  static double normalizeDegrees(double deg) {
    double result = deg % 360.0;
    if (result < 0) result += 360.0;
    return result;
  }
}
