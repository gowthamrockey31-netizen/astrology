import 'dart:math';
import '../models/kp_astrology_model.dart';
import 'astrology_calculator.dart';
import 'kp_cusp_sub_lord_relation_engine.dart';
import 'planet_status_calculator.dart';

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
  static double calculateKpAyanamsa(DateTime dt) {
    // KP Ayanamsa for J2000.0 is ~23° 45' 56" = 23.765555°
    final double jd = (dt.millisecondsSinceEpoch / 86400000.0) + 2440587.5;
    final double t = (jd - 2451545.0) / 36525.0;
    return 23.765555 + (1.396041 * t) + (0.000308 * t * t);
  }

  /// Calculate Sub-Lord and Sub-Sub-Lord for any zodiac longitude
  static Map<String, String> getStarSubSubSubLords(double longitude) {
    final double normLong = (longitude % 360.0 + 360.0) % 360.0;
    const double nakSpan = 360.0 / 27.0; // 13° 20' = 13.333333°

    final int nakIdx = (normLong / nakSpan).floor() % 27;
    final double nakOffset = normLong - (nakIdx * nakSpan);

    final int starLordIdx = nakIdx % 9;
    final String starLordEn = dashaLordSequence[starLordIdx];
    final String starLordTa = dashaLordSequenceTa[starLordIdx];

    // Sub Lord: Subdividing the 13°20' Nakshatra into 9 parts proportional to Vimshottari dasha years (total 120 yrs)
    double accumulatedDeg = 0.0;
    int subLordIdx = starLordIdx;
    String subLordEn = starLordEn;
    String subLordTa = starLordTa;
    double subSpanDeg = 0.0;
    double offsetInSub = 0.0;

    for (int i = 0; i < 9; i++) {
      final int currentIdx = (starLordIdx + i) % 9;
      final String planet = dashaLordSequence[currentIdx];
      final double years = dashaYears[planet]!;
      final double span = (years / 120.0) * nakSpan; // proportional span in degrees

      if (nakOffset >= accumulatedDeg && nakOffset < (accumulatedDeg + span + 0.000001)) {
        subLordIdx = currentIdx;
        subLordEn = dashaLordSequence[currentIdx];
        subLordTa = dashaLordSequenceTa[currentIdx];
        subSpanDeg = span;
        offsetInSub = nakOffset - accumulatedDeg;
        break;
      }
      accumulatedDeg += span;
    }

    // Sub-Sub Lord: Subdividing the Sub-Lord span into 9 parts
    String subSubLordTa = subLordTa;
    double accumulatedSubSub = 0.0;
    for (int i = 0; i < 9; i++) {
      final int currentIdx = (subLordIdx + i) % 9;
      final String planet = dashaLordSequence[currentIdx];
      final double years = dashaYears[planet]!;
      final double span = (years / 120.0) * subSpanDeg;

      if (offsetInSub >= accumulatedSubSub && offsetInSub < (accumulatedSubSub + span + 0.000001)) {
        subSubLordTa = dashaLordSequenceTa[currentIdx];
        break;
      }
      accumulatedSubSub += span;
    }

    final int rasiIdx = (normLong / 30.0).floor() % 12;
    final String signLordEn = PlanetStatusCalculator.rasiLords[rasiIdx];
    final String signLordTa = AstrologyCalculator.planetNameToTamil[signLordEn] ?? signLordEn;

    return {
      'signLordTa': signLordTa,
      'starLordTa': starLordTa,
      'subLordTa': subLordTa,
      'subSubLordTa': subSubLordTa,
    };
  }

  /// Calculate KP Chart from Natal / Horary details
  static KpAstrologyResult calculateKpChart({
    required DateTime dateTime,
    required double latitude,
    required double longitude,
    double utcOffsetHours = 5.5,
    double? customAscendantLongitude,
  }) {
    final kpAyanamsa = calculateKpAyanamsa(dateTime);
    final natalData = AstrologyCalculator.calculateHoroscope(
      dateOfBirth: dateTime,
      latitude: latitude,
      longitude: longitude,
      utcOffsetHours: utcOffsetHours,
    );

    final double lagnaLong = customAscendantLongitude ?? natalData.lagna.longitude;

    // 12 KP Cusps (Placidus / Equal Cusp Houses from Ascendant)
    final List<KpCuspDetail> cusps = [];
    for (int i = 0; i < 12; i++) {
      final double cuspLong = (lagnaLong + (i * 30.0)) % 360.0;
      final int rasiIdx = (cuspLong / 30.0).floor() % 12;
      final double degInRasi = cuspLong % 30.0;

      final lords = getStarSubSubSubLords(cuspLong);

      final d = degInRasi.floor();
      final m = ((degInRasi - d) * 60).floor();
      final s = ((((degInRasi - d) * 60) - m) * 60).round();
      final degStr = "${d.toString().padLeft(2, '0')}°${m.toString().padLeft(2, '0')}'${s.toString().padLeft(2, '0')}\"";

      cusps.add(KpCuspDetail(
        cuspNumber: i + 1,
        cuspLongitude: cuspLong,
        rasiIndex: rasiIdx,
        rasiNameTa: AstrologyCalculator.rasiNamesTa[rasiIdx],
        rasiNameEn: AstrologyCalculator.rasiNamesEn[rasiIdx],
        degreeInRasi: degInRasi,
        degreeFormatted: degStr,
        signLordTa: lords['signLordTa']!,
        starLordTa: lords['starLordTa']!,
        subLordTa: lords['subLordTa']!,
        subSubLordTa: lords['subSubLordTa']!,
      ));
    }

    // KP Planet Details
    final List<KpPlanetDetail> kpPlanets = [];
    for (final p in natalData.planets.values) {
      final lords = getStarSubSubSubLords(p.longitude);

      // Determine Cusp Occupied
      int cuspOccupied = 1;
      for (int i = 0; i < 12; i++) {
        final currentCusp = cusps[i].cuspLongitude;
        final nextCusp = cusps[(i + 1) % 12].cuspLongitude;
        if (nextCusp > currentCusp) {
          if (p.longitude >= currentCusp && p.longitude < nextCusp) {
            cuspOccupied = i + 1;
            break;
          }
        } else {
          // Wrap around 360°
          if (p.longitude >= currentCusp || p.longitude < nextCusp) {
            cuspOccupied = i + 1;
            break;
          }
        }
      }

      kpPlanets.add(KpPlanetDetail(
        planetNameEn: p.name,
        planetNameTa: p.tamilName,
        symbol: p.symbol,
        longitude: p.longitude,
        rasiIndex: p.rasiIndex,
        rasiNameTa: p.rasiNameTa,
        degreeInRasi: p.degreeInRasi,
        degreeFormatted: p.degreeFormatted,
        signLordTa: lords['signLordTa']!,
        starLordTa: lords['starLordTa']!,
        subLordTa: lords['subLordTa']!,
        subSubLordTa: lords['subSubLordTa']!,
        cuspOccupied: cuspOccupied,
        isRetrograde: p.isRetrograde,
      ));
    }

    // KP Significator Table (Levels A, B, C, D)
    final List<KpPlanetSignificator> significators = [];
    for (final p in kpPlanets) {
      significators.add(KpPlanetSignificator(
        planetNameTa: p.planetNameTa,
        levelA: [p.cuspOccupied],
        levelB: [(p.cuspOccupied + 4) % 12 + 1],
        levelC: [p.rasiIndex + 1],
        levelD: [(p.rasiIndex + 6) % 12 + 1],
      ));
    }

    // Ruling Planets (RP) at calculation moment
    final moonLords = getStarSubSubSubLords(natalData.moon.longitude);
    final ascLords = getStarSubSubSubLords(lagnaLong);
    final dayLordTa = natalData.birthHoraLordTa;

    final Map<String, String> rulingPlanets = {
      'Ascendant Sign Lord': ascLords['signLordTa']!,
      'Ascendant Star Lord': ascLords['starLordTa']!,
      'Ascendant Sub Lord': ascLords['subLordTa']!,
      'Moon Sign Lord': moonLords['signLordTa']!,
      'Moon Star Lord': moonLords['starLordTa']!,
      'Day Lord': dayLordTa,
    };

    final d = kpAyanamsa.floor();
    final m = ((kpAyanamsa - d) * 60).floor();
    final s = ((((kpAyanamsa - d) * 60) - m) * 60).round();
    final ayanamsaStr = "${d}°${m}'${s}\"";

    // KP Cusp Sub Lord House Relations (12 Cusps)
    final cuspHouseRelations = KpCuspSubLordRelationEngine.calculateRelationTable(
      cusps: cusps,
      planets: kpPlanets,
    );

    return KpAstrologyResult(
      kpAyanamsa: kpAyanamsa,
      kpAyanamsaFormatted: ayanamsaStr,
      cusps: cusps,
      planets: kpPlanets,
      significators: significators,
      rulingPlanets: rulingPlanets,
      cuspHouseRelations: cuspHouseRelations,
    );
  }

  /// Calculate Ascendant Longitude for a KP Horary Number (1 to 249)
  static double getHoraryNumberAscendantLongitude(int number) {
    final int clampedNum = number.clamp(1, 249);
    // 249 sub-lord divisions in the zodiac (360° total / 249 segments approx)
    const double approxSpan = 360.0 / 249.0;
    return (clampedNum - 1) * approxSpan + (approxSpan / 2.0);
  }
}
