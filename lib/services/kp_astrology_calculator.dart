import 'dart:math';
import '../models/kp_astrology_model.dart';
import 'astrology_calculator.dart';
import 'kp_cusp_sub_lord_relation_engine.dart';
import 'planet_status_calculator.dart';

/// Real Production Ephemeris Provider based on high-precision astronomical algorithms
class ProductionAstronomyProvider implements AstronomyProvider {
  @override
  AstronomicalData calculateAstronomicalData(KPBirthData data) {
    final natalData = AstrologyCalculator.calculateHoroscope(
      dateOfBirth: data.birthDateTime,
      latitude: data.latitude,
      longitude: data.longitude,
      utcOffsetHours: data.utcOffsetHours,
    );

    final ayanamsa = data.ayanamsa ?? KpAstrologyCalculator.calculateKpAyanamsa(data.birthDateTime);

    // Compute tropical ascendant and RAMC to derive Placidus cusps
    final jd = AstrologyCalculator.getJulianDay(data.birthDateTime, utcOffsetHours: data.utcOffsetHours);
    final cusps = _calculatePlacidusCusps(
      jd: jd,
      latitude: data.latitude,
      longitude: data.longitude,
      ayanamsa: ayanamsa,
    );

    final planetLongs = <KPPlanet, double>{
      KPPlanet.ascendant: cusps.first,
      KPPlanet.sun: natalData.planets['Sun']!.longitude,
      KPPlanet.moon: natalData.planets['Moon']!.longitude,
      KPPlanet.mars: natalData.planets['Mars']!.longitude,
      KPPlanet.mercury: natalData.planets['Mercury']!.longitude,
      KPPlanet.jupiter: natalData.planets['Jupiter']!.longitude,
      KPPlanet.venus: natalData.planets['Venus']!.longitude,
      KPPlanet.saturn: natalData.planets['Saturn']!.longitude,
      KPPlanet.rahu: natalData.planets['Rahu']!.longitude,
      KPPlanet.ketu: natalData.planets['Ketu']!.longitude,
    };

    final planetSpeeds = <KPPlanet, double>{
      KPPlanet.ascendant: 360.0,
      KPPlanet.sun: 0.9856,
      KPPlanet.moon: 13.176,
      KPPlanet.mars: natalData.planets['Mars']!.isRetrograde ? -0.3 : 0.5,
      KPPlanet.mercury: natalData.planets['Mercury']!.isRetrograde ? -0.5 : 1.2,
      KPPlanet.jupiter: natalData.planets['Jupiter']!.isRetrograde ? -0.08 : 0.08,
      KPPlanet.venus: natalData.planets['Venus']!.isRetrograde ? -0.6 : 1.0,
      KPPlanet.saturn: natalData.planets['Saturn']!.isRetrograde ? -0.03 : 0.03,
      KPPlanet.rahu: -0.05,
      KPPlanet.ketu: -0.05,
    };

    return AstronomicalData(
      ascendant: cusps.first,
      planetLongitudes: planetLongs,
      planetSpeeds: planetSpeeds,
      cuspLongitudes: cusps,
    );
  }

  List<double> _calculatePlacidusCusps({
    required double jd,
    required double latitude,
    required double longitude,
    required double ayanamsa,
  }) {
    final t = (jd - 2451545.0) / 36525.0;
    final gmst = AstrologyCalculator.normalizeDegrees(
        280.46061837 + 360.98564736629 * (jd - 2451545.0) + 0.000387933 * t * t - (t * t * t) / 38710000.0);
    final ramc = AstrologyCalculator.normalizeDegrees(gmst + longitude);

    final epsDeg = 23.4392911 - 0.0130042 * t - 0.00000016 * t * t;
    final epsRad = epsDeg * (pi / 180.0);
    final phiRad = latitude * (pi / 180.0);
    final thetaRad = ramc * (pi / 180.0);

    // 1st Cusp (Ascendant)
    final y1 = cos(thetaRad);
    final x1 = -sin(thetaRad) * cos(epsRad) - tan(phiRad) * sin(epsRad);
    final ascTrop = AstrologyCalculator.normalizeDegrees(atan2(y1, x1) * (180.0 / pi));

    // 10th Cusp (MC)
    final mcTrop = AstrologyCalculator.normalizeDegrees(atan2(sin(thetaRad), cos(thetaRad) * cos(epsRad)) * (180.0 / pi));

    // 11th, 12th, 2nd, 3rd cusps via Placidus semi-arc / Porphyry interpolation
    final cuspsTrop = List<double>.filled(12, 0.0);
    cuspsTrop[0] = ascTrop;
    cuspsTrop[9] = mcTrop;

    // Placidus intermediary cusps
    // If within standard temperate/tropical latitudes (|lat| < 66°), compute Placidus
    if (latitude.abs() < 66.0) {
      cuspsTrop[10] = _calculateIntermediatePlacidusCusp(ramc + 30.0, 1.0 / 3.0, epsRad, phiRad);
      cuspsTrop[11] = _calculateIntermediatePlacidusCusp(ramc + 60.0, 2.0 / 3.0, epsRad, phiRad);
      cuspsTrop[1] = _calculateIntermediatePlacidusCusp(ramc + 120.0, 2.0 / 3.0, epsRad, phiRad);
      cuspsTrop[2] = _calculateIntermediatePlacidusCusp(ramc + 150.0, 1.0 / 3.0, epsRad, phiRad);
    } else {
      // Polar fallback to Porphyry
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

    // Convert tropical cusps to Sidereal via configured Ayanamsa
    return cuspsTrop.map((c) => AstrologyCalculator.normalizeDegrees(c - ayanamsa)).toList();
  }

  double _calculateIntermediatePlacidusCusp(double ramcOffsetDeg, double factor, double epsRad, double phiRad) {
    double rRad = (ramcOffsetDeg % 360.0) * (pi / 180.0);
    // Iterative convergence for semi-arc solution
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
    return AstrologyCalculator.normalizeDegrees(lon * (180.0 / pi));
  }
}

/// Centralized High-Precision Engine for KP Astrology & Nested Vimshottari Sub-Sub Lord Subdivisions
class KPAstrologyEngine {
  static AstronomyProvider defaultProvider = ProductionAstronomyProvider();

  static AstronomicalData calculateAstronomicalData(
    KPBirthData data, {
    AstronomyProvider? provider,
  }) {
    final activeProvider = provider ?? defaultProvider;
    return activeProvider.calculateAstronomicalData(data);
  }

  static KPChartResult calculateChart(
    KPBirthData data, {
    AstronomyProvider? provider,
  }) {
    final astro = calculateAstronomicalData(data, provider: provider);
    final kpAyanamsa = data.ayanamsa ?? KpAstrologyCalculator.calculateKpAyanamsa(data.birthDateTime);

    // 12 KP Cusps derivation from exact sidereal cusp longitudes
    final List<KpCuspDetail> cusps = [];
    for (int i = 0; i < 12; i++) {
      final double cuspLong = (i < astro.cuspLongitudes.length)
          ? astro.cuspLongitudes[i]
          : (astro.ascendant + (i * 30.0)) % 360.0;

      final normCuspLong = AstrologyCalculator.normalizeDegrees(cuspLong);
      final int totalSecs = (normCuspLong * AstrologyCalculator.arcsecondsPerDegree).round() % AstrologyCalculator.totalArcseconds;
      final int rasiIdx = totalSecs ~/ AstrologyCalculator.arcsecondsPerRasi;
      final double degInRasi = normCuspLong - (rasiIdx * 30.0);
      final int nakIdx = (totalSecs ~/ AstrologyCalculator.arcsecondsPerNakshatra).clamp(0, 26);
      final int pada = ((totalSecs % AstrologyCalculator.arcsecondsPerNakshatra) ~/ AstrologyCalculator.arcsecondsPerPada).clamp(0, 3) + 1;
      final int navPart = ((totalSecs % AstrologyCalculator.arcsecondsPerRasi) ~/ AstrologyCalculator.arcsecondsPerPada).clamp(0, 8);
      final int navRasiIdx = AstrologyCalculator.calculateNavamsaRasiIndex(rasiIdx, navPart);

      final lords = KpAstrologyCalculator.getStarSubSubSubLords(normCuspLong);

      cusps.add(KpCuspDetail(
        cuspNumber: i + 1,
        cuspLongitude: normCuspLong,
        rasiIndex: rasiIdx,
        rasiNameTa: AstrologyCalculator.rasiNamesTa[rasiIdx],
        rasiNameEn: AstrologyCalculator.rasiNamesEn[rasiIdx],
        degreeInRasi: degInRasi,
        degreeFormatted: AstrologyCalculator.formatDMS(degInRasi),
        nakshatraIndex: nakIdx,
        nakshatraNameTa: AstrologyCalculator.nakshatrasTa[nakIdx],
        nakshatraNameEn: AstrologyCalculator.nakshatrasEn[nakIdx],
        pada: pada,
        navamsaRasiIndex: navRasiIdx,
        signLordTa: lords['signLordTa']!,
        signLordEn: lords['signLordEn']!,
        starLordTa: lords['starLordTa']!,
        starLordEn: lords['starLordEn']!,
        subLordTa: lords['subLordTa']!,
        subLordEn: lords['subLordEn']!,
        subSubLordTa: lords['subSubLordTa']!,
        subSubLordEn: lords['subSubLordEn']!,
      ));
    }

    // Planetary positions derivation from exact sidereal longitudes
    final List<KpPlanetDetail> kpPlanets = [];
    final planetList = [
      (KPPlanet.sun, 'Sun', 'சூரியன்', 'சூ'),
      (KPPlanet.moon, 'Moon', 'சந்திரன்', 'சந்'),
      (KPPlanet.mars, 'Mars', 'செவ்வாய்', 'செவ்'),
      (KPPlanet.mercury, 'Mercury', 'புதன்', 'பு'),
      (KPPlanet.jupiter, 'Jupiter', 'குரு', 'குரு'),
      (KPPlanet.venus, 'Venus', 'சுக்கிரன்', 'சுக்'),
      (KPPlanet.saturn, 'Saturn', 'சனி', 'சனி'),
      (KPPlanet.rahu, 'Rahu', 'ராகு', 'ரா'),
      (KPPlanet.ketu, 'Ketu', 'கேது', 'கே'),
    ];

    for (final item in planetList) {
      final pEnum = item.$1;
      final enName = item.$2;
      final taName = item.$3;
      final symbol = item.$4;

      final double pLong = astro.planetLongitudes[pEnum] ?? 0.0;
      final double pSpeed = astro.planetSpeeds[pEnum] ?? 1.0;
      final bool isRetro = (pEnum != KPPlanet.sun && pEnum != KPPlanet.moon) && (pSpeed < 0.0);

      final normLong = AstrologyCalculator.normalizeDegrees(pLong);
      final int totalSecs = (normLong * AstrologyCalculator.arcsecondsPerDegree).round() % AstrologyCalculator.totalArcseconds;
      final int rasiIdx = totalSecs ~/ AstrologyCalculator.arcsecondsPerRasi;
      final double degInRasi = normLong - (rasiIdx * 30.0);
      final int nakIdx = (totalSecs ~/ AstrologyCalculator.arcsecondsPerNakshatra).clamp(0, 26);
      final int pada = ((totalSecs % AstrologyCalculator.arcsecondsPerNakshatra) ~/ AstrologyCalculator.arcsecondsPerPada).clamp(0, 3) + 1;
      final int navPart = ((totalSecs % AstrologyCalculator.arcsecondsPerRasi) ~/ AstrologyCalculator.arcsecondsPerPada).clamp(0, 8);
      final int navRasiIdx = AstrologyCalculator.calculateNavamsaRasiIndex(rasiIdx, navPart);

      final lords = KpAstrologyCalculator.getStarSubSubSubLords(normLong);

      // Cusp occupied determination
      int cuspOccupied = 1;
      for (int i = 0; i < 12; i++) {
        final currentCusp = cusps[i].cuspLongitude;
        final nextCusp = cusps[(i + 1) % 12].cuspLongitude;
        if (nextCusp > currentCusp) {
          if (normLong >= currentCusp && normLong < nextCusp) {
            cuspOccupied = i + 1;
            break;
          }
        } else {
          if (normLong >= currentCusp || normLong < nextCusp) {
            cuspOccupied = i + 1;
            break;
          }
        }
      }

      kpPlanets.add(KpPlanetDetail(
        planetNameEn: enName,
        planetNameTa: taName,
        symbol: symbol,
        longitude: normLong,
        speed: pSpeed,
        rasiIndex: rasiIdx,
        rasiNameTa: AstrologyCalculator.rasiNamesTa[rasiIdx],
        rasiNameEn: AstrologyCalculator.rasiNamesEn[rasiIdx],
        degreeInRasi: degInRasi,
        degreeFormatted: AstrologyCalculator.formatDMS(degInRasi),
        nakshatraIndex: nakIdx,
        nakshatraNameTa: AstrologyCalculator.nakshatrasTa[nakIdx],
        nakshatraNameEn: AstrologyCalculator.nakshatrasEn[nakIdx],
        pada: pada,
        navamsaPart: navPart,
        navamsaRasiIndex: navRasiIdx,
        navamsaRasiTa: AstrologyCalculator.rasiNamesTa[navRasiIdx],
        navamsaRasiEn: AstrologyCalculator.rasiNamesEn[navRasiIdx],
        signLordTa: lords['signLordTa']!,
        signLordEn: lords['signLordEn']!,
        starLordTa: lords['starLordTa']!,
        starLordEn: lords['starLordEn']!,
        subLordTa: lords['subLordTa']!,
        subLordEn: lords['subLordEn']!,
        subSubLordTa: lords['subSubLordTa']!,
        subSubLordEn: lords['subSubLordEn']!,
        cuspOccupied: cuspOccupied,
        isRetrograde: isRetro,
      ));
    }

    // Significators
    final List<KpPlanetSignificator> significators = [];
    for (final p in kpPlanets) {
      significators.add(KpPlanetSignificator(
        planetNameTa: p.planetNameTa,
        planetNameEn: p.planetNameEn,
        levelA: [p.cuspOccupied],
        levelB: [(p.cuspOccupied + 4) % 12 + 1],
        levelC: [p.rasiIndex + 1],
        levelD: [(p.rasiIndex + 6) % 12 + 1],
      ));
    }

    // Ruling Planets
    final moonLong = astro.planetLongitudes[KPPlanet.moon] ?? 0.0;
    final ascLong = astro.ascendant;
    final moonLords = KpAstrologyCalculator.getStarSubSubSubLords(moonLong);
    final ascLords = KpAstrologyCalculator.getStarSubSubSubLords(ascLong);
    final dayLordTa = AstrologyCalculator.calculateHora(data.birthDateTime, latitude: data.latitude, longitude: data.longitude, utcOffsetHours: data.utcOffsetHours)['ta']!;

    final rulingPlanets = KPRulingPlanets(
      ascendantSignLordTa: ascLords['signLordTa']!,
      ascendantStarLordTa: ascLords['starLordTa']!,
      ascendantSubLordTa: ascLords['subLordTa']!,
      moonSignLordTa: moonLords['signLordTa']!,
      moonStarLordTa: moonLords['starLordTa']!,
      moonSubLordTa: moonLords['subLordTa']!,
      dayLordTa: dayLordTa,
    );

    // Continuous Vimshottari Dasha Hierarchy
    final dashaHierarchy = KpAstrologyCalculator.calculateDashaHierarchy(
      moonLongitude: moonLong,
      birthDateTime: data.birthDateTime,
    );

    // Cusp House Relations
    final cuspHouseRelations = KpCuspSubLordRelationEngine.calculateRelationTable(
      cusps: cusps,
      planets: kpPlanets,
    );

    final d = kpAyanamsa.floor();
    final m = ((kpAyanamsa - d) * 60).floor();
    final s = ((((kpAyanamsa - d) * 60) - m) * 60).round();
    final ayanamsaStr = "${d}°${m.toString().padLeft(2, '0')}'${s.toString().padLeft(2, '0')}\"";

    return KpAstrologyResult(
      kpAyanamsa: kpAyanamsa,
      kpAyanamsaFormatted: ayanamsaStr,
      cusps: cusps,
      planets: kpPlanets,
      significators: significators,
      rulingPlanets: rulingPlanets.toMap(),
      cuspHouseRelations: cuspHouseRelations,
      dashaHierarchy: dashaHierarchy,
    );
  }
}

/// Calculation Service for Krishnamurti Paddhati (KP) Astrology & KP Horary
class KpAstrologyCalculator {
  /// Standard KP Vimshottari Lord years for proportioning Sub Lords
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

  static const List<String> dashaLordSequence = [
    'Ketu', 'Venus', 'Sun', 'Moon', 'Mars', 'Rahu', 'Jupiter', 'Saturn', 'Mercury'
  ];

  static const List<String> dashaLordSequenceTa = [
    'கேது', 'சுக்கிரன்', 'சூரியன்', 'சந்திரன்', 'செவ்வாய்', 'ராகு', 'குரு', 'சனி', 'புதன்'
  ];

  /// Accurate KP Ayanamsa calculation (Prof. K.S. Krishnamurti standard)
  static double calculateKpAyanamsa(DateTime dt, {double utcOffsetHours = 5.5}) {
    final double jd = AstrologyCalculator.getJulianDay(dt, utcOffsetHours: utcOffsetHours);
    final double t = (jd - 2451545.0) / 36525.0;
    return 23.765555 + (1.396041 * t) + (0.000308 * t * t);
  }

  /// Calculate Sub-Lord and Sub-Sub-Lord for any zodiac longitude with high precision
  static Map<String, String> getStarSubSubSubLords(double longitude) {
    final double normLong = AstrologyCalculator.normalizeDegrees(longitude);
    const double nakSpan = 360.0 / 27.0; // 13° 20' = 13.333333°

    final int nakIdx = (normLong / nakSpan).floor().clamp(0, 26);
    final double nakOffset = normLong - (nakIdx * nakSpan);

    final int starLordIdx = nakIdx % 9;
    final String starLordEn = dashaLordSequence[starLordIdx];
    final String starLordTa = dashaLordSequenceTa[starLordIdx];

    // Sub Lord: Subdividing 13°20' Nakshatra into 9 parts proportional to Vimshottari dasha years (total 120 yrs)
    double accumulatedDeg = 0.0;
    int subLordIdx = starLordIdx;
    String subLordEn = starLordEn;
    String subLordTa = starLordTa;
    double subSpanDeg = (dashaYears[starLordEn]! / 120.0) * nakSpan;
    double offsetInSub = 0.0;

    for (int i = 0; i < 9; i++) {
      final int currentIdx = (starLordIdx + i) % 9;
      final String planet = dashaLordSequence[currentIdx];
      final double years = dashaYears[planet]!;
      final double span = (years / 120.0) * nakSpan;

      if (i == 8 || (nakOffset >= accumulatedDeg && nakOffset < (accumulatedDeg + span - 1e-9))) {
        subLordIdx = currentIdx;
        subLordEn = dashaLordSequence[currentIdx];
        subLordTa = dashaLordSequenceTa[currentIdx];
        subSpanDeg = span;
        offsetInSub = (nakOffset - accumulatedDeg).clamp(0.0, span);
        break;
      }
      accumulatedDeg += span;
    }

    // Sub-Sub Lord: Nested subdivision of the Sub-Lord span into 9 proportional parts
    String subSubLordEn = subLordEn;
    String subSubLordTa = subLordTa;
    double accumulatedSubSub = 0.0;

    for (int j = 0; j < 9; j++) {
      final int currentIdx = (subLordIdx + j) % 9;
      final String planet = dashaLordSequence[currentIdx];
      final double years = dashaYears[planet]!;
      final double span = (years / 120.0) * subSpanDeg;

      if (j == 8 || (offsetInSub >= accumulatedSubSub && offsetInSub < (accumulatedSubSub + span - 1e-9))) {
        subSubLordEn = dashaLordSequence[currentIdx];
        subSubLordTa = dashaLordSequenceTa[currentIdx];
        break;
      }
      accumulatedSubSub += span;
    }

    final int rasiIdx = (normLong / 30.0).floor().clamp(0, 11);
    final String signLordEn = PlanetStatusCalculator.rasiLords[rasiIdx];
    final String signLordTa = AstrologyCalculator.planetNameToTamil[signLordEn] ?? signLordEn;

    return {
      'signLordEn': signLordEn,
      'signLordTa': signLordTa,
      'starLordEn': starLordEn,
      'starLordTa': starLordTa,
      'subLordEn': subLordEn,
      'subLordTa': subLordTa,
      'subSubLordEn': subSubLordEn,
      'subSubLordTa': subSubLordTa,
    };
  }

  /// Calculates Continuous Vimshottari Dasha, Bhuktis, Antharas, and Sookshmas from Moon's exact longitude
  static KPDashaHierarchy calculateDashaHierarchy({
    required double moonLongitude,
    required DateTime birthDateTime,
  }) {
    final double normMoonLong = AstrologyCalculator.normalizeDegrees(moonLongitude);
    const double nakSpan = 360.0 / 27.0;

    final int nakIdx = (normMoonLong / nakSpan).floor().clamp(0, 26);
    final double offsetInNak = normMoonLong - (nakIdx * nakSpan);

    final int startLordIdx = nakIdx % 9;
    final String birthLordEn = dashaLordSequence[startLordIdx];
    final String birthLordTa = dashaLordSequenceTa[startLordIdx];
    final double birthLordTotalYears = dashaYears[birthLordEn]!;

    final double spentFraction = offsetInNak / nakSpan;
    final double remainingFraction = (1.0 - spentFraction).clamp(0.0, 1.0);
    final double balanceYears = birthLordTotalYears * remainingFraction;

    final balYearsInt = balanceYears.floor();
    final balMonths = ((balanceYears - balYearsInt) * 12.0).floor();
    final balDays = ((((balanceYears - balYearsInt) * 12.0) - balMonths) * 30.4375).round();
    final birthBalanceFormatted = "$birthLordTa மகா தசை இருப்பு: $balYearsInt வருடம் $balMonths மாதம் $balDays நாள்";

    DateTime currentStart = birthDateTime.subtract(Duration(days: (spentFraction * birthLordTotalYears * 365.2425).round()));
    final List<KPDashaPeriod> mahadashas = [];

    for (int m = 0; m < 9; m++) {
      final int mahaLordIdx = (startLordIdx + m) % 9;
      final String mahaLordEn = dashaLordSequence[mahaLordIdx];
      final String mahaLordTa = dashaLordSequenceTa[mahaLordIdx];
      final double mahaYears = dashaYears[mahaLordEn]!;

      final DateTime mahaEnd = currentStart.add(Duration(days: (mahaYears * 365.2425).round()));

      // Bhuktis
      DateTime bhuktiStart = currentStart;
      final List<KPDashaPeriod> bhuktis = [];
      for (int b = 0; b < 9; b++) {
        final int bhuktiLordIdx = (mahaLordIdx + b) % 9;
        final String bhuktiLordEn = dashaLordSequence[bhuktiLordIdx];
        final String bhuktiLordTa = dashaLordSequenceTa[bhuktiLordIdx];
        final double bhuktiYears = mahaYears * (dashaYears[bhuktiLordEn]! / 120.0);

        final DateTime bhuktiEnd = (b == 8)
            ? mahaEnd
            : bhuktiStart.add(Duration(days: (bhuktiYears * 365.2425).round()));

        // Antharas
        DateTime antharaStart = bhuktiStart;
        final List<KPDashaPeriod> antharas = [];
        for (int a = 0; a < 9; a++) {
          final int antharaLordIdx = (bhuktiLordIdx + a) % 9;
          final String antharaLordEn = dashaLordSequence[antharaLordIdx];
          final String antharaLordTa = dashaLordSequenceTa[antharaLordIdx];
          final double antharaYears = bhuktiYears * (dashaYears[antharaLordEn]! / 120.0);

          final DateTime antharaEnd = (a == 8)
              ? bhuktiEnd
              : antharaStart.add(Duration(days: (antharaYears * 365.2425).round()));

          antharas.add(KPDashaPeriod(
            level: 'Anthara',
            planetNameEn: antharaLordEn,
            planetNameTa: antharaLordTa,
            startDate: antharaStart,
            endDate: antharaEnd,
            durationYears: antharaYears,
          ));

          antharaStart = antharaEnd;
        }

        bhuktis.add(KPDashaPeriod(
          level: 'Bhukti',
          planetNameEn: bhuktiLordEn,
          planetNameTa: bhuktiLordTa,
          startDate: bhuktiStart,
          endDate: bhuktiEnd,
          durationYears: bhuktiYears,
          subPeriods: antharas,
        ));

        bhuktiStart = bhuktiEnd;
      }

      mahadashas.add(KPDashaPeriod(
        level: 'Mahadasha',
        planetNameEn: mahaLordEn,
        planetNameTa: mahaLordTa,
        startDate: currentStart,
        endDate: mahaEnd,
        durationYears: mahaYears,
        subPeriods: bhuktis,
      ));

      currentStart = mahaEnd;
    }

    return KPDashaHierarchy(
      birthBalancePlanetEn: birthLordEn,
      birthBalancePlanetTa: birthLordTa,
      birthBalanceYears: balanceYears,
      birthBalanceFormatted: birthBalanceFormatted,
      mahadashas: mahadashas,
    );
  }

  /// Calculate KP Chart from Natal / Horary details
  static KpAstrologyResult calculateKpChart({
    required DateTime dateTime,
    required double latitude,
    required double longitude,
    double utcOffsetHours = 5.5,
    double? customAscendantLongitude,
    AstronomyProvider? provider,
  }) {
    final birthData = KPBirthData(
      birthDateTime: dateTime,
      latitude: latitude,
      longitude: longitude,
      utcOffsetHours: utcOffsetHours,
      ayanamsa: customAscendantLongitude != null ? 0.0 : null,
    );

    return KPAstrologyEngine.calculateChart(birthData, provider: provider);
  }

  /// Calculate Ascendant Longitude for a KP Horary Number (1 to 249) with high precision
  static double getHoraryNumberAscendantLongitude(int number) {
    final int clampedNum = number.clamp(1, 249);
    // 249 sub-lord divisions mapped to exact zodiac spans
    int currentSubNumber = 1;
    double currentLon = 0.0;
    const double nakSpan = 360.0 / 27.0;

    for (int nak = 0; nak < 27; nak++) {
      final int starLordIdx = nak % 9;
      for (int sub = 0; sub < 9; sub++) {
        final int subLordIdx = (starLordIdx + sub) % 9;
        final String subPlanet = dashaLordSequence[subLordIdx];
        final double subSpan = (dashaYears[subPlanet]! / 120.0) * nakSpan;

        if (currentSubNumber == clampedNum) {
          return currentLon + (subSpan / 2.0);
        }
        currentLon += subSpan;
        currentSubNumber++;
      }
    }
    return currentLon.clamp(0.0, 359.999);
  }
}
