import 'dart:math';
import '../../services/swiss_ephemeris_calculator.dart';
import '../models/kp3_models.dart';

/// Pure Astronomical Calculation Engine for KP Method Model 3
class KPAstronomy {
  /// Julian Day calculation
  static double getJulianDay(BirthData data) {
    return SwissEphemerisCalculator.getJulianDay(
      data.dateTime,
      utcOffsetHours: data.timezone,
    );
  }

  /// Official Krishnamurti (KP) Ayanamsa
  /// Formula: KP Ayanamsa = Lahiri - 0° 06' 00" (or 23.857092 - 0.1 + precession)
  static double getKPAyanamsa(double jd) {
    final lahiri = SwissEphemerisCalculator.calculateLahiriAyanamsa(jd);
    // KP Ayanamsa offset: - 6 arcminutes = -0.1 degrees
    return lahiri - (6.0 / 60.0);
  }

  /// Normalize degrees into 0.0 <= d < 360.0
  static double normalize(double d) {
    return SwissEphemerisCalculator.normalizeDegrees(d);
  }

  /// Calculate Sidereal Ascendant (Lagna)
  static double calculateAscendant({
    required double jd,
    required double latitude,
    required double longitude,
    required double ayanamsa,
  }) {
    return SwissEphemerisCalculator.calculateAscendantSidereal(
      jd: jd,
      latitude: latitude,
      longitude: longitude,
      ayanamsa: ayanamsa,
    );
  }

  /// Calculate 12 Placidus Cusps converted to Sidereal via KP Ayanamsa
  static List<double> calculatePlacidusCusps({
    required double jd,
    required double latitude,
    required double longitude,
    required double ayanamsa,
  }) {
    final t = (jd - 2451545.0) / 36525.0;
    final gmst = normalize(
      280.46061837 + 360.98564736629 * (jd - 2451545.0) + 0.000387933 * t * t - (t * t * t) / 38710000.0,
    );
    final ramc = normalize(gmst + longitude);

    final epsDeg = 23.4392911 - 0.0130042 * t - 0.00000016 * t * t;
    final epsRad = epsDeg * (pi / 180.0);
    final phiRad = latitude * (pi / 180.0);
    final thetaRad = ramc * (pi / 180.0);

    // 1st Cusp (Ascendant / Lagna)
    final y1 = cos(thetaRad);
    final x1 = -sin(thetaRad) * cos(epsRad) - tan(phiRad) * sin(epsRad);
    final ascTrop = normalize(atan2(y1, x1) * (180.0 / pi));

    // 10th Cusp (MC / Midheaven)
    final mcTrop = normalize(atan2(sin(thetaRad), cos(thetaRad) * cos(epsRad)) * (180.0 / pi));

    final cuspsTrop = List<double>.filled(12, 0.0);
    cuspsTrop[0] = ascTrop; // 1st house
    cuspsTrop[9] = mcTrop;  // 10th house

    if (latitude.abs() < 66.0) {
      cuspsTrop[10] = _calcIntermediatePlacidus(ramc + 30.0, 1.0 / 3.0, epsRad, phiRad); // 11th
      cuspsTrop[11] = _calcIntermediatePlacidus(ramc + 60.0, 2.0 / 3.0, epsRad, phiRad); // 12th
      cuspsTrop[1] = _calcIntermediatePlacidus(ramc + 120.0, 2.0 / 3.0, epsRad, phiRad); // 2nd
      cuspsTrop[2] = _calcIntermediatePlacidus(ramc + 150.0, 1.0 / 3.0, epsRad, phiRad); // 3rd
    } else {
      // Polar fallback
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

    // Opposite cusps (4, 5, 6, 7, 8, 9)
    cuspsTrop[3] = (cuspsTrop[9] + 180.0) % 360.0; // 4th
    cuspsTrop[4] = (cuspsTrop[10] + 180.0) % 360.0; // 5th
    cuspsTrop[5] = (cuspsTrop[11] + 180.0) % 360.0; // 6th
    cuspsTrop[6] = (cuspsTrop[0] + 180.0) % 360.0; // 7th
    cuspsTrop[7] = (cuspsTrop[1] + 180.0) % 360.0; // 8th
    cuspsTrop[8] = (cuspsTrop[2] + 180.0) % 360.0; // 9th

    // Convert tropical cusps to Sidereal via KP Ayanamsa
    return cuspsTrop.map((c) => normalize(c - ayanamsa)).toList();
  }

  static double _calcIntermediatePlacidus(
    double ramcOffsetDeg, double factor, double epsRad, double phiRad,
  ) {
    double rRad = (ramcOffsetDeg % 360.0) * (pi / 180.0);
    double lon = rRad;
    for (int iter = 0; iter < 10; iter++) {
      final sinDecl = sin(epsRad) * sin(lon);
      final cosDecl = sqrt(max(0.0, 1.0 - sinDecl * sinDecl));
      final tanDecl = sinDecl / max(0.0001, cosDecl);
      final ascDiff = asin((tan(phiRad) * tanDecl).clamp(-1.0, 1.0));
      final newR = rRad + factor * ascDiff;
      final y = sin(newR);
      final x = cos(newR) * cos(epsRad) - tanDecl * sin(epsRad);
      final newLon = atan2(y, x);
      if ((newLon - lon).abs() < 1e-6) break;
      lon = newLon;
    }
    return normalize(lon * (180.0 / pi));
  }
}

/// Nakshatra, Sub, Sub-Sub, and Sub-Sub-Sub Lord Engine for KP Method Model 3
class KPNakshatraEngine {
  static const double nakshatraSpan = 13.333333333333334; // 13° 20' = 800 arcminutes
  static const List<String> sequence = KPConstants.planetsEn; // Ketu, Venus, Sun, Moon, Mars, Rahu, Jupiter, Saturn, Mercury

  static int getNakshatraIndex(double lon) {
    final norm = KPAstronomy.normalize(lon);
    return (norm / nakshatraSpan).floor().clamp(0, 26);
  }

  static int getPada(double lon) {
    final norm = KPAstronomy.normalize(lon);
    final padaSpan = nakshatraSpan / 4.0; // 3° 20'
    final elapsedInNak = norm % nakshatraSpan;
    return (elapsedInNak / padaSpan).floor().clamp(0, 3) + 1;
  }

  static String getStarLord(double lon) {
    final nakIdx = getNakshatraIndex(lon);
    return sequence[nakIdx % 9];
  }

  /// Get Sub Lord details within nakshatra
  static Map<String, dynamic> getSubLordSpan(double lon) {
    final norm = KPAstronomy.normalize(lon);
    final int nakIdx = (norm / nakshatraSpan).floor().clamp(0, 26);
    final double elapsedInNakMinutes = (norm % nakshatraSpan) * 60.0;

    final int startLordIdx = nakIdx % 9;
    double startMin = 0.0;

    for (int i = 0; i < 9; i++) {
      final currentLordIdx = (startLordIdx + i) % 9;
      final planet = sequence[currentLordIdx];
      final double spanMin = (KPConstants.dashaYears[planet]! / 120.0) * 800.0;

      if (elapsedInNakMinutes < startMin + spanMin || i == 8) {
        return {
          'subLord': planet,
          'startMinutes': startMin,
          'spanMinutes': spanMin,
          'elapsedInSubMinutes': elapsedInNakMinutes - startMin,
        };
      }
      startMin += spanMin;
    }
    return {
      'subLord': sequence[startLordIdx],
      'startMinutes': 0.0,
      'spanMinutes': 800.0,
      'elapsedInSubMinutes': 0.0,
    };
  }

  static String getSubLord(double lon) {
    return getSubLordSpan(lon)['subLord'] as String;
  }

  /// Get Sub-Sub Lord details within sub lord span
  static Map<String, dynamic> getSubSubLordSpan(double lon) {
    final subSpan = getSubLordSpan(lon);
    final String subLord = subSpan['subLord'] as String;
    final double totalSubSpanMinutes = subSpan['spanMinutes'] as double;
    final double elapsedInSubMinutes = subSpan['elapsedInSubMinutes'] as double;

    final int startLordIdx = sequence.indexOf(subLord);
    double startMin = 0.0;

    for (int i = 0; i < 9; i++) {
      final currentLordIdx = (startLordIdx + i) % 9;
      final planet = sequence[currentLordIdx];
      final double spanMin = (KPConstants.dashaYears[planet]! / 120.0) * totalSubSpanMinutes;

      if (elapsedInSubMinutes < startMin + spanMin || i == 8) {
        return {
          'subSubLord': planet,
          'startMinutes': startMin,
          'spanMinutes': spanMin,
          'elapsedInSubSubMinutes': elapsedInSubMinutes - startMin,
        };
      }
      startMin += spanMin;
    }
    return {
      'subSubLord': subLord,
      'startMinutes': 0.0,
      'spanMinutes': totalSubSpanMinutes,
      'elapsedInSubSubMinutes': 0.0,
    };
  }

  static String getSubSubLord(double lon) {
    return getSubSubLordSpan(lon)['subSubLord'] as String;
  }

  /// Sub-Sub-Sub Lord determination (4th tier sub-division)
  static String getSubSubSubLord(double lon) {
    final subSubSpan = getSubSubLordSpan(lon);
    final String subSubLord = subSubSpan['subSubLord'] as String;
    final double totalSubSubSpanMinutes = subSubSpan['spanMinutes'] as double;
    final double elapsedInSubSubMinutes = subSubSpan['elapsedInSubSubMinutes'] as double;

    final int startLordIdx = sequence.indexOf(subSubLord);
    double accumulatedMinutes = 0.0;

    for (int i = 0; i < 9; i++) {
      final currentLordIdx = (startLordIdx + i) % 9;
      final planet = sequence[currentLordIdx];
      final double subSubSubSpanMinutes = (KPConstants.dashaYears[planet]! / 120.0) * totalSubSubSpanMinutes;

      accumulatedMinutes += subSubSubSpanMinutes;
      if (elapsedInSubSubMinutes < accumulatedMinutes || i == 8) {
        return planet;
      }
    }
    return subSubLord;
  }
}

/// House and Cusp Calculation Engine for KP Method Model 3
class KPHouseEngine {
  /// Calculate 12 Cusps
  static List<CuspPosition> calculateCusps({
    required BirthData birthData,
    required double jd,
    required double ayanamsa,
  }) {
    final rawLongitudes = KPAstronomy.calculatePlacidusCusps(
      jd: jd,
      latitude: birthData.latitude,
      longitude: birthData.longitude,
      ayanamsa: ayanamsa,
    );

    final List<CuspPosition> cusps = [];

    for (int i = 0; i < 12; i++) {
      final double cLong = KPAstronomy.normalize(rawLongitudes[i]);
      final int signIdx = (cLong / 30.0).floor().clamp(0, 11);
      final double degInSign = cLong % 30.0;
      final String degreeFormatted = kpDegree(cLong);

      final int nakIdx = KPNakshatraEngine.getNakshatraIndex(cLong);
      final int pada = KPNakshatraEngine.getPada(cLong);

      final signLord = KPConstants.signLords[signIdx];
      final starLord = KPNakshatraEngine.getStarLord(cLong);
      final subLord = KPNakshatraEngine.getSubLord(cLong);
      final subSubLord = KPNakshatraEngine.getSubSubLord(cLong);
      final subSubSubLord = KPNakshatraEngine.getSubSubSubLord(cLong);

      cusps.add(
        CuspPosition(
          cuspNumber: i + 1,
          longitude: cLong,
          degreeInRasi: degInSign,
          degreeStr: degreeFormatted,
          signIndex: signIdx,
          signName: KPConstants.signsEn[signIdx],
          signNameTa: KPConstants.signsTa[signIdx],
          signLord: signLord,
          starLord: starLord,
          subLord: subLord,
          subSubLord: subSubLord,
          subSubSubLord: subSubSubLord,
          nakshatraIndex: nakIdx,
          nakshatraName: KPConstants.nakshatrasEn[nakIdx],
          nakshatraNameTa: KPConstants.nakshatrasTa[nakIdx],
          pada: pada,
        ),
      );
    }
    return cusps;
  }

  /// Determine occupied house for a given longitude from Placidus cusps
  static int determineOccupiedHouse(double longitude, List<CuspPosition> cusps) {
    final norm = KPAstronomy.normalize(longitude);
    for (int i = 0; i < 12; i++) {
      final cur = cusps[i].longitude;
      final next = cusps[(i + 1) % 12].longitude;
      if (next > cur) {
        if (norm >= cur && norm < next) return i + 1;
      } else {
        // Straddles 0° Aries
        if (norm >= cur || norm < next) return i + 1;
      }
    }
    return 1;
  }
}

/// 9 Planetary Positions Engine for KP Method Model 3
class KPPlanetEngine {
  static List<PlanetPosition> calculatePositions({
    required BirthData birthData,
    required double jd,
    required double ayanamsa,
    required List<CuspPosition> cusps,
  }) {
    final ephem = SwissEphemerisCalculator.calculatePlanetaryPositions(
      jd: jd,
      ayanamsa: ayanamsa,
    );

    // Determine owned houses for each planet based on cusp sign lords
    final Map<String, List<int>> ownedHousesMap = {};
    for (final c in cusps) {
      ownedHousesMap.putIfAbsent(c.signLord, () => []).add(c.cuspNumber);
    }

    final List<PlanetPosition> positions = [];
    final planetList = [
      'Sun', 'Moon', 'Mars', 'Mercury', 'Jupiter', 'Venus', 'Saturn', 'Rahu', 'Ketu'
    ];

    for (final pName in planetList) {
      final info = ephem[pName]!;
      final double siderealLong = KPAstronomy.normalize(info.longitude);
      final int signIdx = (siderealLong / 30.0).floor().clamp(0, 11);
      final double degInSign = siderealLong % 30.0;
      final String degreeFormatted = kpDegree(siderealLong);

      final int nakIdx = KPNakshatraEngine.getNakshatraIndex(siderealLong);
      final int pada = KPNakshatraEngine.getPada(siderealLong);

      final signLord = KPConstants.signLords[signIdx];
      final starLord = KPNakshatraEngine.getStarLord(siderealLong);
      final subLord = KPNakshatraEngine.getSubLord(siderealLong);
      final subSubLord = KPNakshatraEngine.getSubSubLord(siderealLong);
      final subSubSubLord = KPNakshatraEngine.getSubSubSubLord(siderealLong);

      final occupiedHouse = KPHouseEngine.determineOccupiedHouse(siderealLong, cusps);
      final ownedHouses = ownedHousesMap[pName] ?? [];

      positions.add(
        PlanetPosition(
          planet: pName,
          planetTa: KPConstants.planetToTamil(pName),
          longitude: siderealLong,
          degreeInRasi: degInSign,
          degreeStr: degreeFormatted,
          house: occupiedHouse,
          signIndex: signIdx,
          signName: KPConstants.signsEn[signIdx],
          signNameTa: KPConstants.signsTa[signIdx],
          signLord: signLord,
          starLord: starLord,
          subLord: subLord,
          subSubLord: subSubLord,
          subSubSubLord: subSubSubLord,
          nakshatraIndex: nakIdx,
          nakshatraName: KPConstants.nakshatrasEn[nakIdx],
          nakshatraNameTa: KPConstants.nakshatrasTa[nakIdx],
          pada: pada,
          ownedHouses: ownedHouses,
          isRetrograde: info.isRetrograde,
        ),
      );
    }
    return positions;
  }
}

/// 4-Fold KP Significations Engine for KP Method Model 3
class KPSignificationEngine {
  static List<Signification> calculateSignifications({
    required List<PlanetPosition> planets,
    required List<CuspPosition> cusps,
  }) {
    final Map<String, PlanetPosition> planetMap = {for (var p in planets) p.planet: p};
    final List<Signification> significations = [];

    for (final p in planets) {
      final starLordPlanet = planetMap[p.starLord];

      // Level A: Houses occupied by the star lord of planet P
      final List<int> levelA = starLordPlanet != null ? [starLordPlanet.house] : [];

      // Level B: House occupied by planet P
      final List<int> levelB = [p.house];

      // Level C: Houses owned by the star lord of planet P
      final List<int> levelC = starLordPlanet != null ? starLordPlanet.ownedHouses : [];

      // Level D: Houses owned by planet P
      final List<int> levelD = p.ownedHouses;

      final allSet = <int>{...levelA, ...levelB, ...levelC, ...levelD};
      final sortedAll = allSet.toList()..sort();

      significations.add(
        Signification(
          planet: p.planet,
          levelA: levelA,
          levelB: levelB,
          levelC: levelC,
          levelD: levelD,
          allHouses: sortedAll,
        ),
      );
    }
    return significations;
  }
}

/// Cusp Relations and Red/Blue House Classification Engine for KP Method Model 3
class KPHouseRuleEngine {
  static List<CuspRelationResult> calculateCuspRelations({
    required List<CuspPosition> cusps,
    required List<Signification> significations,
  }) {
    final Map<String, Signification> sigMap = {for (var s in significations) s.planet: s};
    final List<CuspRelationResult> results = [];

    // Favorable and Unfavorable rules per Cusp in KP Tamil Tradition
    const Map<int, List<int>> positiveCuspMap = {
      1: [1, 3, 5, 9, 11],
      2: [2, 6, 10, 11],
      3: [1, 3, 11],
      4: [2, 4, 11, 12],
      5: [2, 5, 11],
      6: [2, 6, 10, 11],
      7: [2, 7, 11],
      8: [1, 5, 11],
      9: [2, 9, 11],
      10: [2, 6, 10, 11],
      11: [1, 2, 3, 10, 11],
      12: [2, 3, 9, 11, 12],
    };

    const Map<int, List<int>> negativeCuspMap = {
      1: [6, 8, 12],
      2: [8, 12],
      3: [12],
      4: [3, 6, 8],
      5: [4, 10, 12],
      6: [5, 8, 12],
      7: [1, 6, 10, 12],
      8: [6, 8, 12],
      9: [8, 12],
      10: [5, 8, 12],
      11: [12],
      12: [6, 8],
    };

    for (final c in cusps) {
      final starSig = sigMap[c.starLord];
      final subSig = sigMap[c.subLord];

      final starHouses = starSig != null ? starSig.allHouses : <int>[];
      final subHouses = subSig != null ? subSig.allHouses : <int>[];

      final finalSet = <int>{...starHouses, ...subHouses};
      final finalHouses = finalSet.toList()..sort();

      final positiveGuide = positiveCuspMap[c.cuspNumber] ?? [1, 2, 3, 10, 11];
      final negativeGuide = negativeCuspMap[c.cuspNumber] ?? [6, 8, 12];

      final blueHouses = finalHouses.where((h) => positiveGuide.contains(h)).toList();
      final redHouses = finalHouses.where((h) => negativeGuide.contains(h)).toList();

      results.add(
        CuspRelationResult(
          cuspNumber: c.cuspNumber,
          starLord: c.starLord,
          subLord: c.subLord,
          subSubLord: c.subSubLord,
          starHouses: starHouses,
          subHouses: subHouses,
          finalHouses: finalHouses,
          redHouses: redHouses,
          blueHouses: blueHouses,
        ),
      );
    }
    return results;
  }
}

/// 5-Tier Ruling Planets Engine (ரா.அ, ந.அ, உ.அ, உ.உ, உ.உ.உ) for Model 3
class KPRulingPlanetEngine {
  static List<RulingPlanet> calculateRulingPlanets({
    required BirthData birthData,
    required double ascendantDegree,
    required double moonDegree,
    required List<PlanetPosition> planets,
  }) {
    final Map<String, PlanetPosition> planetMap = {for (var p in planets) p.planet: p};
    List<int> getHouses(String planetName) {
      final p = planetMap[planetName];
      if (p == null) return [];
      final list = [p.house, ...p.ownedHouses];
      return list.toSet().toList()..sort();
    }

    final List<RulingPlanet> rpList = [];

    // 1. Ascendant (லக்னம்) Ruling Planets
    final int ascSignIdx = (ascendantDegree / 30.0).floor().clamp(0, 11);
    final ascSignLord = KPConstants.signLords[ascSignIdx];
    final ascStarLord = KPNakshatraEngine.getStarLord(ascendantDegree);
    final ascSubLord = KPNakshatraEngine.getSubLord(ascendantDegree);
    final ascSubSubLord = KPNakshatraEngine.getSubSubLord(ascendantDegree);
    final ascSubSubSubLord = KPNakshatraEngine.getSubSubSubLord(ascendantDegree);

    rpList.add(RulingPlanet(
      category: 'ரா.அ',
      categoryEn: 'Sign Lord',
      source: 'லக்னம் (Ascendant)',
      planet: ascSignLord,
      planetTa: KPConstants.planetToTamil(ascSignLord),
      houses: getHouses(ascSignLord),
    ));
    rpList.add(RulingPlanet(
      category: 'ந.அ',
      categoryEn: 'Star Lord',
      source: 'லக்னம் (Ascendant)',
      planet: ascStarLord,
      planetTa: KPConstants.planetToTamil(ascStarLord),
      houses: getHouses(ascStarLord),
    ));
    rpList.add(RulingPlanet(
      category: 'உ.அ',
      categoryEn: 'Sub Lord',
      source: 'லக்னம் (Ascendant)',
      planet: ascSubLord,
      planetTa: KPConstants.planetToTamil(ascSubLord),
      houses: getHouses(ascSubLord),
    ));
    rpList.add(RulingPlanet(
      category: 'உ.உ',
      categoryEn: 'Sub-Sub Lord',
      source: 'லக்னம் (Ascendant)',
      planet: ascSubSubLord,
      planetTa: KPConstants.planetToTamil(ascSubSubLord),
      houses: getHouses(ascSubSubLord),
    ));
    rpList.add(RulingPlanet(
      category: 'உ.உ.உ',
      categoryEn: 'Sub-Sub-Sub Lord',
      source: 'லக்னம் (Ascendant)',
      planet: ascSubSubSubLord,
      planetTa: KPConstants.planetToTamil(ascSubSubSubLord),
      houses: getHouses(ascSubSubSubLord),
    ));

    // 2. Moon (சந்திரன்) Ruling Planets
    final int moonSignIdx = (moonDegree / 30.0).floor().clamp(0, 11);
    final moonSignLord = KPConstants.signLords[moonSignIdx];
    final moonStarLord = KPNakshatraEngine.getStarLord(moonDegree);
    final moonSubLord = KPNakshatraEngine.getSubLord(moonDegree);
    final moonSubSubLord = KPNakshatraEngine.getSubSubLord(moonDegree);
    final moonSubSubSubLord = KPNakshatraEngine.getSubSubSubLord(moonDegree);

    rpList.add(RulingPlanet(
      category: 'ரா.அ',
      categoryEn: 'Sign Lord',
      source: 'சந்திரன் (Moon)',
      planet: moonSignLord,
      planetTa: KPConstants.planetToTamil(moonSignLord),
      houses: getHouses(moonSignLord),
    ));
    rpList.add(RulingPlanet(
      category: 'ந.அ',
      categoryEn: 'Star Lord',
      source: 'சந்திரன் (Moon)',
      planet: moonStarLord,
      planetTa: KPConstants.planetToTamil(moonStarLord),
      houses: getHouses(moonStarLord),
    ));
    rpList.add(RulingPlanet(
      category: 'உ.அ',
      categoryEn: 'Sub Lord',
      source: 'சந்திரன் (Moon)',
      planet: moonSubLord,
      planetTa: KPConstants.planetToTamil(moonSubLord),
      houses: getHouses(moonSubLord),
    ));
    rpList.add(RulingPlanet(
      category: 'உ.உ',
      categoryEn: 'Sub-Sub Lord',
      source: 'சந்திரன் (Moon)',
      planet: moonSubSubLord,
      planetTa: KPConstants.planetToTamil(moonSubSubLord),
      houses: getHouses(moonSubSubLord),
    ));
    rpList.add(RulingPlanet(
      category: 'உ.உ.உ',
      categoryEn: 'Sub-Sub-Sub Lord',
      source: 'சந்திரன் (Moon)',
      planet: moonSubSubSubLord,
      planetTa: KPConstants.planetToTamil(moonSubSubSubLord),
      houses: getHouses(moonSubSubSubLord),
    ));

    // 3. Day Lord (கிழமை நாதன்)
    // Sunday=0..Saturday=6 in standard weekday calculation
    final dayPlanets = ['Sun', 'Moon', 'Mars', 'Mercury', 'Jupiter', 'Venus', 'Saturn'];
    final dayLord = dayPlanets[birthData.dateTime.weekday % 7];
    rpList.add(RulingPlanet(
      category: 'ரா.அ',
      categoryEn: 'Day Lord',
      source: 'கிழமை நாதன் (Day Lord)',
      planet: dayLord,
      planetTa: KPConstants.planetToTamil(dayLord),
      houses: getHouses(dayLord),
    ));

    return rpList;
  }
}

/// Vimshottari Dasha Engine for KP Method Model 3
class KPDashaEngine {
  static List<DashaPeriod> calculateDashaTimeline({
    required double moonDegree,
    required DateTime birthDate,
    required List<Signification> significations,
  }) {
    final Map<String, List<int>> houseMap = {
      for (var s in significations) s.planet: s.allHouses
    };

    final int nakIdx = KPNakshatraEngine.getNakshatraIndex(moonDegree);
    final int startLordIdx = nakIdx % 9;
    final String balanceLord = KPConstants.planetsEn[startLordIdx];

    final double elapsedInNak = (moonDegree % KPNakshatraEngine.nakshatraSpan);
    final double fractionElapsed = elapsedInNak / KPNakshatraEngine.nakshatraSpan;
    final double fractionRemaining = (1.0 - fractionElapsed).clamp(0.0, 1.0);

    final double totalYears = KPConstants.dashaYears[balanceLord]!;
    final double balanceYears = totalYears * fractionRemaining;

    final List<DashaPeriod> periods = [];
    DateTime curStart = birthDate;

    // First Dasha (Balance)
    final firstEndDays = (balanceYears * 365.2425).round();
    DateTime curEnd = curStart.add(Duration(days: firstEndDays));

    periods.add(
      DashaPeriod(
        planet: balanceLord,
        planetTa: KPConstants.planetToTamil(balanceLord),
        startDate: curStart,
        endDate: curEnd,
        startDateFormatted: kpDate(curStart),
        endDateFormatted: kpDate(curEnd),
        relatedHouses: houseMap[balanceLord] ?? [],
        level: 1,
      ),
    );

    // Remaining Mahadashas (Full Cycle)
    for (int i = 1; i < 9; i++) {
      final lordIdx = (startLordIdx + i) % 9;
      final pName = KPConstants.planetsEn[lordIdx];
      final pYears = KPConstants.dashaYears[pName]!;
      curStart = curEnd;
      curEnd = curStart.add(Duration(days: (pYears * 365.2425).round()));

      periods.add(
        DashaPeriod(
          planet: pName,
          planetTa: KPConstants.planetToTamil(pName),
          startDate: curStart,
          endDate: curEnd,
          startDateFormatted: kpDate(curStart),
          endDateFormatted: kpDate(curEnd),
          relatedHouses: houseMap[pName] ?? [],
          level: 1,
        ),
      );
    }
    return periods;
  }
}

/// Birth Time Rectification Engine using KP Ruling Planets methodology
class KPBirthTimeRectifier {
  static BirthTimeRectificationResult rectify(BirthData birthData) {
    final originalJd = KPAstronomy.getJulianDay(birthData);
    final originalAyanamsa = KPAstronomy.getKPAyanamsa(originalJd);
    final originalAsc = KPAstronomy.calculateAscendant(
      jd: originalJd,
      latitude: birthData.latitude,
      longitude: birthData.longitude,
      ayanamsa: originalAyanamsa,
    );

    // Get ruling planets at original birth time
    final moonEphem = SwissEphemerisCalculator.calculatePlanetaryPositions(
      jd: originalJd,
      ayanamsa: originalAyanamsa,
    )['Moon']!;
    final moonDegree = KPAstronomy.normalize(moonEphem.longitude);

    final cusps = KPHouseEngine.calculateCusps(
      birthData: birthData,
      jd: originalJd,
      ayanamsa: originalAyanamsa,
    );
    final planets = KPPlanetEngine.calculatePositions(
      birthData: birthData,
      jd: originalJd,
      ayanamsa: originalAyanamsa,
      cusps: cusps,
    );

    final rpList = KPRulingPlanetEngine.calculateRulingPlanets(
      birthData: birthData,
      ascendantDegree: originalAsc,
      moonDegree: moonDegree,
      planets: planets,
    );
    final Set<String> rpNames = rpList.map((rp) => rp.planet).toSet();

    // Evaluate candidate birth times within +/- 15 minutes (in 30s steps)
    int bestOffset = 0;
    double bestScore = -1.0;
    double bestAsc = originalAsc;
    String bestSubLord = KPNakshatraEngine.getSubLord(originalAsc);
    String bestSubSubLord = KPNakshatraEngine.getSubSubLord(originalAsc);
    List<String> bestMatchedRPs = [];

    for (int offset = -900; offset <= 900; offset += 30) {
      final candidateDt = birthData.dateTime.add(Duration(seconds: offset));
      final candidateBirth = birthData.copyWith(dateTime: candidateDt);
      final candJd = KPAstronomy.getJulianDay(candidateBirth);
      final candAsc = KPAstronomy.calculateAscendant(
        jd: candJd,
        latitude: candidateBirth.latitude,
        longitude: candidateBirth.longitude,
        ayanamsa: originalAyanamsa,
      );

      final candSignIdx = (candAsc / 30.0).floor().clamp(0, 11);
      final candSignLord = KPConstants.signLords[candSignIdx];
      final candStarLord = KPNakshatraEngine.getStarLord(candAsc);
      final candSubLord = KPNakshatraEngine.getSubLord(candAsc);
      final candSubSubLord = KPNakshatraEngine.getSubSubLord(candAsc);

      double score = 0.0;
      final matched = <String>[];

      if (rpNames.contains(candSubLord)) {
        score += 45.0;
        matched.add('Sub Lord: $candSubLord');
      }
      if (rpNames.contains(candSubSubLord)) {
        score += 30.0;
        matched.add('Sub-Sub Lord: $candSubSubLord');
      }
      if (rpNames.contains(candStarLord)) {
        score += 15.0;
        matched.add('Star Lord: $candStarLord');
      }
      if (rpNames.contains(candSignLord)) {
        score += 10.0;
        matched.add('Sign Lord: $candSignLord');
      }

      // Penalty for larger offset distance
      final distancePenalty = (offset.abs() / 900.0) * 8.0;
      final finalScore = (score - distancePenalty).clamp(0.0, 100.0);

      if (finalScore > bestScore) {
        bestScore = finalScore;
        bestOffset = offset;
        bestAsc = candAsc;
        bestSubLord = candSubLord;
        bestSubSubLord = candSubSubLord;
        bestMatchedRPs = matched;
      }
    }

    final rectifiedDt = birthData.dateTime.add(Duration(seconds: bestOffset));
    final h12 = rectifiedDt.hour % 12 == 0 ? 12 : rectifiedDt.hour % 12;
    final ampm = rectifiedDt.hour >= 12 ? 'PM' : 'AM';
    final rectifiedTimeStr = '${h12.toString().padLeft(2, '0')}:${rectifiedDt.minute.toString().padLeft(2, '0')}:${rectifiedDt.second.toString().padLeft(2, '0')} $ampm';
    final rectifiedBirthData = birthData.copyWith(
      dateTime: rectifiedDt,
      time: rectifiedTimeStr,
    );

    final sign = bestOffset >= 0 ? '+' : '-';
    final absSec = bestOffset.abs();
    final mins = absSec ~/ 60;
    final secs = absSec % 60;
    final offsetFormatted = '$sign${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')} min';

    final explanationTa = 'ஆளும் கிரகங்கள் (Ruling Planets: ${rpNames.join(', ')}) விதியின்படி லக்ன உப நாதர் ($bestSubLord) மற்றும் உப-உப நாதர் ($bestSubSubLord) உடன் $offsetFormatted கால வேறுபாட்டில் ${bestScore.toStringAsFixed(1)}% துல்லியப் பொருத்தம் கண்டறியப்பட்டது.';
    final explanationEn = 'According to KP Ruling Planets rule (${rpNames.join(', ')}), the Ascendant Sub Lord ($bestSubLord) and Sub-Sub Lord ($bestSubSubLord) achieved a ${bestScore.toStringAsFixed(1)}% congruence score at an offset of $offsetFormatted.';

    return BirthTimeRectificationResult(
      originalBirthData: birthData,
      rectifiedBirthData: rectifiedBirthData,
      offsetSeconds: bestOffset,
      offsetFormatted: offsetFormatted,
      originalAscendant: originalAsc,
      rectifiedAscendant: bestAsc,
      rectifiedLagnaDegreeStr: kpDegree(bestAsc),
      rectifiedSubLord: bestSubLord,
      rectifiedSubSubLord: bestSubSubLord,
      congruenceScore: bestScore,
      matchedRulingPlanets: bestMatchedRPs,
      explanationTa: explanationTa,
      explanationEn: explanationEn,
    );
  }
}

/// Central Complete KP Module (Model 3)
class CompleteKPModule {
  /// Calculate complete KP Method Model 3 Chart
  KPResult calculate(BirthData birthData) {
    // 1. Julian Day and KP Ayanamsa
    final jd = KPAstronomy.getJulianDay(birthData);
    final ayanamsa = KPAstronomy.getKPAyanamsa(jd);
    final ayanamsaStr = kpDegree(ayanamsa);

    // 2. Ascendant (Lagna)
    final ascLong = KPAstronomy.calculateAscendant(
      jd: jd,
      latitude: birthData.latitude,
      longitude: birthData.longitude,
      ayanamsa: ayanamsa,
    );
    final ascSignIdx = (ascLong / 30.0).floor().clamp(0, 11);
    final ascNakIdx = KPNakshatraEngine.getNakshatraIndex(ascLong);
    final ascPada = KPNakshatraEngine.getPada(ascLong);
    final ascStarLord = KPNakshatraEngine.getStarLord(ascLong);
    final ascSubLord = KPNakshatraEngine.getSubLord(ascLong);
    final ascSubSubLord = KPNakshatraEngine.getSubSubLord(ascLong);

    // 3. 12 Placidus Cusps
    final cusps = KPHouseEngine.calculateCusps(
      birthData: birthData,
      jd: jd,
      ayanamsa: ayanamsa,
    );

    // 4. 9 Planetary Positions
    final planets = KPPlanetEngine.calculatePositions(
      birthData: birthData,
      jd: jd,
      ayanamsa: ayanamsa,
      cusps: cusps,
    );

    // 5. 4-Fold KP Significations
    final significations = KPSignificationEngine.calculateSignifications(
      planets: planets,
      cusps: cusps,
    );

    // 6. Cusp Relations with Red/Blue Houses
    final cuspRelations = KPHouseRuleEngine.calculateCuspRelations(
      cusps: cusps,
      significations: significations,
    );

    // 7. 5-Tier Ruling Planets
    final moonPlanet = planets.firstWhere((p) => p.planet == 'Moon');
    final rulingPlanets = KPRulingPlanetEngine.calculateRulingPlanets(
      birthData: birthData,
      ascendantDegree: ascLong,
      moonDegree: moonPlanet.longitude,
      planets: planets,
    );

    // 8. Vimshottari Dasha Timeline
    final dashaPeriods = KPDashaEngine.calculateDashaTimeline(
      moonDegree: moonPlanet.longitude,
      birthDate: birthData.dateTime,
      significations: significations,
    );

    return KPResult(
      birthData: birthData,
      ascendantDegree: ascLong,
      ascendantDegreeStr: kpDegree(ascLong),
      ascendantSignTa: KPConstants.signsTa[ascSignIdx],
      ascendantNakshatraTa: KPConstants.nakshatrasTa[ascNakIdx],
      ascendantPada: ascPada,
      ascendantStarLord: ascStarLord,
      ascendantSubLord: ascSubLord,
      ascendantSubSubLord: ascSubSubLord,
      ayanamsa: ayanamsa,
      ayanamsaStr: ayanamsaStr,
      planetPositions: planets,
      cusps: cusps,
      rulingPlanets: rulingPlanets,
      significations: significations,
      cuspRelations: cuspRelations,
      dashaPeriods: dashaPeriods,
    );
  }

  /// Birth Time Rectification functionality
  static BirthTimeRectificationResult rectifyBirthTime(BirthData birthData) {
    return KPBirthTimeRectifier.rectify(birthData);
  }
}
