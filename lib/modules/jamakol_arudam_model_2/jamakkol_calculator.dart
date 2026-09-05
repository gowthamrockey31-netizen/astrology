import 'package:flutter/material.dart';
import '../../models/planet_position.dart';
import '../../services/astrology_calculator.dart';
import 'jamakkol_models.dart';
import 'jamakkol_rule_engine.dart';

/// Calculation Service for ஜாமகோள் ஆருடம் Model 2
class JamakkolCalculator {
  static const List<String> jamamLordsDay = [
    'சூரியன்',
    'செவ்வாய்',
    'குரு',
    'புதன்',
    'சுக்கிரன்',
    'சனி',
    'சந்திரன்',
    'ராகு',
  ];

  static const List<String> jamamLordsNight = [
    'சந்திரன்',
    'சனி',
    'சுக்கிரன்',
    'புதன்',
    'குரு',
    'செவ்வாய்',
    'சூரியன்',
    'கேது',
  ];

  /// Standard outer planet rasi assignments based on Jamam lord progression
  static const Map<String, int> defaultOuterPlanetRasis = {
    'Sun': 0, // மேஷம் (Mesham)
    'Mars': 7, // விருச்சிகம் (Viruchigam)
    'Jupiter': 8, // தனுசு (Dhanusu)
    'Mercury': 2, // மிதுனம் (Mithunam)
    'Venus': 1, // ரிஷபம் (Rishabam)
    'Saturn': 9, // மகரம் (Magaram)
    'Moon': 3, // கடகம் (Kadagam)
    'Rahu': 10, // கும்பம் (Kumbam)
    'Ketu': 4, // சிம்மம் (Simmam)
    'Mandi': 11, // மீனம் (Meenam)
  };

  /// 1. Normalize angle strictly into 0.0 <= longitude < 360.0
  static double normalize(double deg) {
    if (deg.isNaN || deg.isInfinite) return 0.0;
    double norm = deg % 360.0;
    if (norm < 0) norm += 360.0;
    return norm;
  }

  /// 2. Get Rasi index (0 to 11) from longitude
  static int rasiFromLongitude(double lon) {
    return (normalize(lon) / 30.0).floor() % 12;
  }

  /// 3. Calculate 1-based house from reference mark (e.g. Udhayam) to target longitude
  static int houseFromLongitudes(double refLon, double targetLon) {
    final refRasi = rasiFromLongitude(refLon);
    final targetRasi = rasiFromLongitude(targetLon);
    return (((targetRasi - refRasi) % 12 + 12) % 12) + 1;
  }

  /// 4. Format degree as DD° MM′
  static String formatDegree(double deg) {
    final normInRasi = (normalize(deg) % 30.0);
    final d = normInRasi.floor();
    final m = ((normInRasi - d) * 60.0).floor();
    return "${d.toString().padLeft(2, '0')}° ${m.toString().padLeft(2, '0')}′";
  }

  /// 5. Make a MarkPosition (உதயம், ஆருடம், கவிப்பு)
  static MarkPosition makeMark(
    String name,
    String tamilName,
    double longitude,
    Color color,
    String symbol, {
    double? refUdhayamLon,
  }) {
    final norm = normalize(longitude);
    final rasiIdx = rasiFromLongitude(norm);
    final degInRasi = norm % 30.0;
    final house = refUdhayamLon != null
        ? houseFromLongitudes(refUdhayamLon, norm)
        : 1;

    return MarkPosition(
      name: name,
      tamilName: tamilName,
      longitude: norm,
      rasiIndex: rasiIdx,
      rasiName: kJamakkolRasiNamesTa[rasiIdx],
      degreeInRasi: degInRasi,
      house: house,
      color: color,
      symbol: symbol,
    );
  }

  /// Demo snapshot for verification and testing
  static JamakkolSnapshot demoJamakkol() {
    final now = DateTime(2026, 9, 5, 10, 30);
    return JamakkolSnapshot(
      dateTime: now,
      location: 'Chennai, Tamil Nadu',
      latitude: 13.0827,
      longitude: 80.2707,
      udhayamLongitude: 142.5, // சிம்மம் (Leo) ~ 22° 30'
      arudhamLongitude: 38.0, // ரிஷபம் (Taurus) ~ 8° 00'
      kavippuLongitude: 218.0, // விருச்சிகம் (Scorpio) ~ 8° 00'
      outerPlanetsLongitudes: {
        'Sun': 15.0, // மேஷம்
        'Moon': 105.0, // கடகம்
        'Mars': 225.0, // விருச்சிகம்
        'Mercury': 75.0, // மிதுனம்
        'Jupiter': 255.0, // தனுசு
        'Venus': 45.0, // ரிஷபம்
        'Saturn': 285.0, // மகரம்
        'Rahu': 315.0, // கும்பம்
        'Ketu': 135.0, // சிம்மம்
        'Mandi': 345.0, // மீனம்
      },
      transitPlanetsLongitudes: {
        'Sun': 139.5, // சிம்மம்
        'Moon': 62.4, // மிதுனம்
        'Mars': 84.1, // மிதுனம்
        'Mercury': 128.9, // கடகம்
        'Jupiter': 78.3, // மிதுனம்
        'Venus': 165.2, // கன்னி
        'Saturn': 340.5, // மீனம்
        'Rahu': 324.7, // கும்பம்
        'Ketu': 144.7, // சிம்மம்
      },
      retrogradeStatus: {
        'Saturn': true,
        'Rahu': true,
        'Ketu': true,
      },
      jamamNumber: 3,
      isDayJamam: true,
      jamamLord: 'குரு',
    );
  }

  /// Create live snapshot from query time and coordinates using application ephemeris
  static JamakkolSnapshot createLiveSnapshot({
    required DateTime queryTime,
    required double latitude,
    required double longitude,
    required String location,
    int? customAarudamNumber,
    double utcOffsetHours = 5.5,
  }) {
    // 1. Calculate Sun rise and set
    final sunTimes = AstrologyCalculator.calculateSunriseSunset(
      queryTime,
      latitude,
      longitude,
      utcOffsetHours,
    );
    final sunrise = sunTimes['sunrise']!;
    final sunset = sunTimes['sunset']!;

    final bool isDay = !queryTime.isBefore(sunrise) && queryTime.isBefore(sunset);

    double totalMinutes;
    double elapsedMinutes;
    if (isDay) {
      totalMinutes = sunset.difference(sunrise).inMinutes.toDouble();
      elapsedMinutes = queryTime.difference(sunrise).inMinutes.toDouble().clamp(0.0, totalMinutes);
    } else {
      final nextSunrise = sunrise.add(const Duration(days: 1));
      totalMinutes = nextSunrise.difference(sunset).inMinutes.toDouble();
      elapsedMinutes = queryTime.isAfter(sunset)
          ? queryTime.difference(sunset).inMinutes.toDouble()
          : queryTime.difference(sunset.subtract(const Duration(days: 1))).inMinutes.toDouble();
    }

    final double jamamDuration = totalMinutes > 0 ? (totalMinutes / 8.0) : 90.0;
    final int jamamIdx = (elapsedMinutes / jamamDuration).floor().clamp(0, 7);
    final int jamamNum = jamamIdx + 1;
    final String jamamLord = isDay ? jamamLordsDay[jamamIdx] : jamamLordsNight[jamamIdx];

    // 2. Ephemeris calculations for Lagna and Transit planets
    final horoscope = AstrologyCalculator.calculateHoroscope(
      dateOfBirth: queryTime,
      latitude: latitude,
      longitude: longitude,
      utcOffsetHours: utcOffsetHours,
    );

    // Udhayam longitude = exact Lagna longitude
    final double udhayamLon = normalize(horoscope.lagna.longitude);
    final int udhayamRasi = rasiFromLongitude(udhayamLon);

    // Arudham calculation:
    // If custom number 1..12 given, that sign; otherwise computed based on Udhayam & Jamam
    final int aarudamRasi = (customAarudamNumber != null && customAarudamNumber >= 1 && customAarudamNumber <= 12)
        ? (customAarudamNumber - 1)
        : ((udhayamRasi + (jamamIdx * 2) + 1) % 12);
    final double arudhamLon = normalize((aarudamRasi * 30.0) + (udhayamLon % 30.0));

    // Kavippu calculation: 6 signs from Arudham in classical Jamakkol
    final int kavippuRasi = (aarudamRasi + 6) % 12;
    final double kavippuLon = normalize((kavippuRasi * 30.0) + (arudhamLon % 30.0));

    // Outer planets longitudes based on Jamam shift
    final Map<String, double> outerLons = {};
    final shift = jamamIdx;
    outerLons['Sun'] = normalize(((defaultOuterPlanetRasis['Sun']! + shift) % 12) * 30.0 + 15.0);
    outerLons['Mars'] = normalize(((defaultOuterPlanetRasis['Mars']! + shift) % 12) * 30.0 + 15.0);
    outerLons['Jupiter'] = normalize(((defaultOuterPlanetRasis['Jupiter']! + shift) % 12) * 30.0 + 15.0);
    outerLons['Mercury'] = normalize(((defaultOuterPlanetRasis['Mercury']! + shift) % 12) * 30.0 + 15.0);
    outerLons['Venus'] = normalize(((defaultOuterPlanetRasis['Venus']! + shift) % 12) * 30.0 + 15.0);
    outerLons['Saturn'] = normalize(((defaultOuterPlanetRasis['Saturn']! + shift) % 12) * 30.0 + 15.0);
    outerLons['Moon'] = normalize(((defaultOuterPlanetRasis['Moon']! + shift) % 12) * 30.0 + 15.0);
    outerLons['Rahu'] = normalize(((defaultOuterPlanetRasis['Rahu']! + shift) % 12) * 30.0 + 15.0);
    outerLons['Ketu'] = normalize(((defaultOuterPlanetRasis['Ketu']! + shift) % 12) * 30.0 + 15.0);
    outerLons['Mandi'] = normalize(((defaultOuterPlanetRasis['Mandi']! + shift) % 12) * 30.0 + 15.0);

    // Transit ephemeris planets
    final Map<String, double> transitLons = {
      'Sun': horoscope.sun.longitude,
      'Moon': horoscope.moon.longitude,
      'Mars': horoscope.planets['Mars']?.longitude ?? 0.0,
      'Mercury': horoscope.planets['Mercury']?.longitude ?? 0.0,
      'Jupiter': horoscope.planets['Jupiter']?.longitude ?? 0.0,
      'Venus': horoscope.planets['Venus']?.longitude ?? 0.0,
      'Saturn': horoscope.planets['Saturn']?.longitude ?? 0.0,
      'Rahu': horoscope.planets['Rahu']?.longitude ?? 0.0,
      'Ketu': horoscope.planets['Ketu']?.longitude ?? 0.0,
    };

    final Map<String, bool> retrogrades = {
      'Mars': horoscope.planets['Mars']?.isRetrograde ?? false,
      'Mercury': horoscope.planets['Mercury']?.isRetrograde ?? false,
      'Jupiter': horoscope.planets['Jupiter']?.isRetrograde ?? false,
      'Venus': horoscope.planets['Venus']?.isRetrograde ?? false,
      'Saturn': horoscope.planets['Saturn']?.isRetrograde ?? false,
      'Rahu': true,
      'Ketu': true,
    };

    return JamakkolSnapshot(
      dateTime: queryTime,
      location: location,
      latitude: latitude,
      longitude: longitude,
      udhayamLongitude: udhayamLon,
      arudhamLongitude: arudhamLon,
      kavippuLongitude: kavippuLon,
      outerPlanetsLongitudes: outerLons,
      transitPlanetsLongitudes: transitLons,
      retrogradeStatus: retrogrades,
      jamamNumber: jamamNum,
      isDayJamam: isDay,
      jamamLord: jamamLord,
    );
  }

  /// 6. Primary calculate method for Jamakkol Model 2
  static JamakkolResult calculate(JamakkolSnapshot snapshot) {
    // 1. Create Core Marks
    final udhayam = makeMark(
      'Udhayam',
      'உதயம்',
      snapshot.udhayamLongitude,
      const Color(0xFF00E676), // Bright Green
      'உ',
      refUdhayamLon: snapshot.udhayamLongitude,
    );

    final arudham = makeMark(
      'Arudham',
      'ஆருடம்',
      snapshot.arudhamLongitude,
      const Color(0xFFFFD700), // Gold / Amber
      'ஆ',
      refUdhayamLon: snapshot.udhayamLongitude,
    );

    final kavippu = makeMark(
      'Kavippu',
      'கவிப்பு',
      snapshot.kavippuLongitude,
      const Color(0xFFFF3D00), // Crimson / Red
      'கவி',
      refUdhayamLon: snapshot.udhayamLongitude,
    );

    // 2. Process Outer Planets
    final List<JamakkolPlanetInfo> outerPlanets = [];
    final Map<int, List<JamakkolPlanetInfo>> outerByRasi = {
      for (int i = 0; i < 12; i++) i: [],
    };

    snapshot.outerPlanetsLongitudes.forEach((key, lon) {
      final normLon = normalize(lon);
      final rasiIdx = rasiFromLongitude(normLon);
      final planetEnum = _planetKeyToEnum(key);
      final house = houseFromLongitudes(snapshot.udhayamLongitude, normLon);

      final pos = PlanetPosition(
        planet: planetEnum,
        longitude: normLon,
        retrograde: snapshot.retrogradeStatus[key] ?? false,
        rasiIndex: rasiIdx,
      );

      final info = JamakkolPlanetInfo(
        position: pos,
        name: key,
        tamilName: _tamilNameFromKey(key),
        symbol: _symbolFromKey(key),
        house: house,
        isOuterPlanet: true,
      );

      outerPlanets.add(info);
      outerByRasi[rasiIdx]!.add(info);
    });

    // 3. Process Transit Planets
    final List<JamakkolPlanetInfo> transitPlanets = [];
    final Map<int, List<JamakkolPlanetInfo>> transitByRasi = {
      for (int i = 0; i < 12; i++) i: [],
    };

    snapshot.transitPlanetsLongitudes.forEach((key, lon) {
      final normLon = normalize(lon);
      final rasiIdx = rasiFromLongitude(normLon);
      final planetEnum = _planetKeyToEnum(key);
      final house = houseFromLongitudes(snapshot.udhayamLongitude, normLon);
      final isRetro = snapshot.retrogradeStatus[key] ?? (key == 'Rahu' || key == 'Ketu');

      final pos = PlanetPosition(
        planet: planetEnum,
        longitude: normLon,
        retrograde: isRetro,
        rasiIndex: rasiIdx,
      );

      final info = JamakkolPlanetInfo(
        position: pos,
        name: key,
        tamilName: _tamilNameFromKey(key),
        symbol: _symbolFromKey(key),
        house: house,
        isOuterPlanet: false,
      );

      transitPlanets.add(info);
      transitByRasi[rasiIdx]!.add(info);
    });

    // 4. Map marks by Rasi
    final Map<int, List<MarkPosition>> marksByRasi = {
      for (int i = 0; i < 12; i++) i: [],
    };
    marksByRasi[udhayam.rasiIndex]!.add(udhayam);
    marksByRasi[arudham.rasiIndex]!.add(arudham);
    marksByRasi[kavippu.rasiIndex]!.add(kavippu);

    // 5. Generate Rule Predictions
    final predictions = JamakkolRuleEngine.predict(
      udhayam: udhayam,
      arudham: arudham,
      kavippu: kavippu,
      outerPlanets: outerPlanets,
      transitPlanets: transitPlanets,
      jamamLord: snapshot.jamamLord,
      isDayJamam: snapshot.isDayJamam,
    );

    return JamakkolResult(
      dateTime: snapshot.dateTime,
      location: snapshot.location,
      udhayam: udhayam,
      arudham: arudham,
      kavippu: kavippu,
      outerPlanets: outerPlanets,
      transitPlanets: transitPlanets,
      outerPlanetsByRasi: outerByRasi,
      transitPlanetsByRasi: transitByRasi,
      marksByRasi: marksByRasi,
      predictions: predictions,
      jamamNumber: snapshot.jamamNumber,
      isDayJamam: snapshot.isDayJamam,
      jamamLord: snapshot.jamamLord,
    );
  }

  static Planet _planetKeyToEnum(String key) {
    switch (key.toLowerCase()) {
      case 'sun':
      case 'சூரியன்':
        return Planet.sun;
      case 'moon':
      case 'சந்திரன்':
        return Planet.moon;
      case 'mars':
      case 'செவ்வாய்':
        return Planet.mars;
      case 'mercury':
      case 'புதன்':
        return Planet.mercury;
      case 'jupiter':
      case 'குரு':
        return Planet.jupiter;
      case 'venus':
      case 'சுக்கிரன்':
        return Planet.venus;
      case 'saturn':
      case 'சனி':
        return Planet.saturn;
      case 'rahu':
      case 'ராகு':
        return Planet.rahu;
      case 'ketu':
      case 'கேது':
        return Planet.ketu;
      case 'mandi':
      case 'மாந்தி':
        return Planet.mandi;
      default:
        return Planet.sun;
    }
  }

  static String _tamilNameFromKey(String key) {
    switch (key.toLowerCase()) {
      case 'sun':
        return 'சூரியன்';
      case 'moon':
        return 'சந்திரன்';
      case 'mars':
        return 'செவ்வாய்';
      case 'mercury':
        return 'புதன்';
      case 'jupiter':
        return 'குரு';
      case 'venus':
        return 'சுக்கிரன்';
      case 'saturn':
        return 'சனி';
      case 'rahu':
        return 'ராகு';
      case 'ketu':
        return 'கேது';
      case 'mandi':
        return 'மாந்தி';
      default:
        return key;
    }
  }

  static String _symbolFromKey(String key) {
    switch (key.toLowerCase()) {
      case 'sun':
      case 'சூரியன்':
        return 'சூரி';
      case 'moon':
      case 'சந்திரன்':
        return 'சந்';
      case 'mars':
      case 'செவ்வாய்':
        return 'செவ்';
      case 'mercury':
      case 'புதன்':
        return 'புத';
      case 'jupiter':
      case 'குரு':
        return 'குரு';
      case 'venus':
      case 'சுக்கிரன்':
        return 'சுக்';
      case 'saturn':
      case 'சனி':
        return 'சனி';
      case 'rahu':
      case 'ராகு':
        return 'ராகு';
      case 'ketu':
      case 'கேது':
        return 'கேது';
      case 'mandi':
      case 'மாந்தி':
        return 'மாந்';
      default:
        return key.length > 3 ? key.substring(0, 3) : key;
    }
  }
}
