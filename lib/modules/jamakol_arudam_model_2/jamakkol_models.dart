import 'package:flutter/material.dart';
import '../../models/planet_position.dart';

/// 12 Zodiac Rasi Names in Tamil
const List<String> kJamakkolRasiNamesTa = [
  'மேஷம்',
  'ரிஷபம்',
  'மிதுனம்',
  'கடகம்',
  'சிம்மம்',
  'கன்னி',
  'துலாம்',
  'விருச்சிகம்',
  'தனுசு',
  'மகரம்',
  'கும்பம்',
  'மீனம்',
];

/// 12 Zodiac Rasi Names in English
const List<String> kJamakkolRasiNamesEn = [
  'Aries',
  'Taurus',
  'Gemini',
  'Cancer',
  'Leo',
  'Virgo',
  'Libra',
  'Scorpio',
  'Sagittarius',
  'Capricorn',
  'Aquarius',
  'Pisces',
];

/// Special Jamakkol Mark Position (உதயம், ஆருடம், கவிப்பு)
class MarkPosition {
  final String name; // 'Udhayam', 'Arudham', 'Kavippu'
  final String tamilName; // 'உதயம்', 'ஆருடம்', 'கவிப்பு'
  final double longitude; // 0.0 <= lon < 360.0
  final int rasiIndex; // 0 to 11
  final String rasiName; // e.g. 'மேஷம்'
  final double degreeInRasi; // 0.0 <= deg < 30.0
  final int house; // 1 to 12 from Udhayam
  final Color color;
  final String symbol; // 'உ', 'ஆ', 'கவி'

  const MarkPosition({
    required this.name,
    required this.tamilName,
    required this.longitude,
    required this.rasiIndex,
    required this.rasiName,
    required this.degreeInRasi,
    required this.house,
    required this.color,
    required this.symbol,
  });

  String get formattedDegree {
    final d = degreeInRasi.floor();
    final m = ((degreeInRasi - d) * 60.0).floor();
    return "${d.toString().padLeft(2, '0')}° ${m.toString().padLeft(2, '0')}′";
  }
}

/// Snapshot of input data required for Jamakkol Model 2
class JamakkolSnapshot {
  final DateTime dateTime;
  final String location;
  final double latitude;
  final double longitude;
  final double udhayamLongitude;
  final double arudhamLongitude;
  final double kavippuLongitude;
  final Map<String, double> outerPlanetsLongitudes; // Planet name -> longitude
  final Map<String, double> transitPlanetsLongitudes; // Planet name -> longitude
  final Map<String, bool> retrogradeStatus; // Planet name -> isRetrograde
  final int jamamNumber; // 1 to 8
  final bool isDayJamam;
  final String jamamLord;

  const JamakkolSnapshot({
    required this.dateTime,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.udhayamLongitude,
    required this.arudhamLongitude,
    required this.kavippuLongitude,
    required this.outerPlanetsLongitudes,
    required this.transitPlanetsLongitudes,
    this.retrogradeStatus = const {},
    this.jamamNumber = 1,
    this.isDayJamam = true,
    this.jamamLord = 'சூரியன்',
  });
}

/// Jamakkol Planet representation with house calculation and formatting
class JamakkolPlanetInfo {
  final PlanetPosition position;
  final String name;
  final String tamilName;
  final String symbol;
  final int house; // 1 to 12 from Udhayam
  final bool isOuterPlanet;

  const JamakkolPlanetInfo({
    required this.position,
    required this.name,
    required this.tamilName,
    required this.symbol,
    required this.house,
    this.isOuterPlanet = false,
  });

  int get rasiIndex => position.rasiIndex;
  double get longitude => position.longitude;
  bool get isRetrograde => position.retrograde;
  double get degreeInRasi => (position.longitude % 30.0 + 30.0) % 30.0;

  String get formattedDegree {
    final d = degreeInRasi.floor();
    final m = ((degreeInRasi - d) * 60.0).floor();
    return "${d.toString().padLeft(2, '0')}° ${m.toString().padLeft(2, '0')}′";
  }
}

/// Calculation and Rule Evaluation Result for Jamakkol Model 2
class JamakkolResult {
  final DateTime dateTime;
  final String location;
  final MarkPosition udhayam;
  final MarkPosition arudham;
  final MarkPosition kavippu;
  final List<JamakkolPlanetInfo> outerPlanets;
  final List<JamakkolPlanetInfo> transitPlanets;
  final Map<int, List<JamakkolPlanetInfo>> outerPlanetsByRasi;
  final Map<int, List<JamakkolPlanetInfo>> transitPlanetsByRasi;
  final Map<int, List<MarkPosition>> marksByRasi;
  final List<String> predictions;
  final int jamamNumber;
  final bool isDayJamam;
  final String jamamLord;

  const JamakkolResult({
    required this.dateTime,
    required this.location,
    required this.udhayam,
    required this.arudham,
    required this.kavippu,
    required this.outerPlanets,
    required this.transitPlanets,
    required this.outerPlanetsByRasi,
    required this.transitPlanetsByRasi,
    required this.marksByRasi,
    required this.predictions,
    required this.jamamNumber,
    required this.isDayJamam,
    required this.jamamLord,
  });
}

/// Convenience extensions on existing PlanetPosition for Jamakkol Model 2
extension JamakkolPlanetExt on PlanetPosition {
  String get tamilName {
    switch (planet) {
      case Planet.sun:
        return 'சூரியன்';
      case Planet.moon:
        return 'சந்திரன்';
      case Planet.mars:
        return 'செவ்வாய்';
      case Planet.mercury:
        return 'புதன்';
      case Planet.jupiter:
        return 'குரு';
      case Planet.venus:
        return 'சுக்கிரன்';
      case Planet.saturn:
        return 'சனி';
      case Planet.rahu:
        return 'ராகு';
      case Planet.ketu:
        return 'கேது';
      case Planet.mandi:
        return 'மாந்தி';
      case Planet.lagna:
        return 'லக்னம்';
    }
  }

  String get shortTamilName {
    switch (planet) {
      case Planet.sun:
        return 'சூரி';
      case Planet.moon:
        return 'சந்';
      case Planet.mars:
        return 'செவ்';
      case Planet.mercury:
        return 'புத';
      case Planet.jupiter:
        return 'குரு';
      case Planet.venus:
        return 'சுக்';
      case Planet.saturn:
        return 'சனி';
      case Planet.rahu:
        return 'ராகு';
      case Planet.ketu:
        return 'கேது';
      case Planet.mandi:
        return 'மாந்';
      case Planet.lagna:
        return 'லக்';
    }
  }
}
