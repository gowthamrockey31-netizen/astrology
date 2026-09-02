import 'kp_planet.dart';
import '../engine/kp_degree_formatter.dart';

/// Detailed planetary position model for KP Method Model 1
class KPPlanetPosition {
  final KPPlanet planet;

  /// Sidereal Longitude (0 <= siderealLongitude < 360)
  final double longitude;

  /// Tropical Longitude before Ayanamsa subtraction
  final double tropicalLongitude;

  /// Sidereal Longitude
  final double siderealLongitude;

  final int rasiIndex;
  final String rasiNameEn;
  final String rasiNameTa;

  final int degree;
  final int minute;
  final double second;

  final int nakshatraIndex;
  final String nakshatraNameEn;
  final String nakshatraNameTa;
  final int pada;

  final String starLord;
  final String subLord;
  final String subSubLord;

  final int occupiedHouse;
  final List<int> ownedHouses;
  final bool isRetrograde;
  final double speed;

  const KPPlanetPosition({
    required this.planet,
    required this.longitude,
    double? tropicalLongitude,
    double? siderealLongitude,
    required this.rasiIndex,
    required this.rasiNameEn,
    required this.rasiNameTa,
    required this.degree,
    required this.minute,
    required this.second,
    required this.nakshatraIndex,
    required this.nakshatraNameEn,
    required this.nakshatraNameTa,
    required this.pada,
    required this.starLord,
    required this.subLord,
    required this.subSubLord,
    required this.occupiedHouse,
    required this.ownedHouses,
    required this.isRetrograde,
    this.speed = 1.0,
  })  : tropicalLongitude = tropicalLongitude ?? longitude,
        siderealLongitude = siderealLongitude ?? longitude;

  /// Rasi name in Tamil (convenience getter as per requirements)
  String get rasi => rasiNameTa;

  /// Nakshatra name in Tamil
  String get nakshatra => nakshatraNameTa;

  /// Formatted DMS string within the rasi (DD°MM'SS" with NO spaces, e.g. 23°14'04")
  String get dmsFormatted => KPDegreeFormatter.formatRasiDegree(longitude);

  /// Degree formatted string alias
  String get degreeFormatted => dmsFormatted;

  /// Tamil formatted label with retrograde notation, e.g. "புதன் (வ)"
  String get displayNameTa {
    if (isRetrograde && planet != KPPlanet.sun && planet != KPPlanet.moon && planet != KPPlanet.rahu && planet != KPPlanet.ketu) {
      return '${planet.nameTa} (வ)';
    }
    return planet.nameTa;
  }

  /// Nakshatra with Pada in Tamil, e.g. "பரணி (3)"
  String get nakshatraWithPadaTa => '$nakshatraNameTa ($pada)';

  /// Total houses directly related to this planet (occupied + owned)
  List<int> get relatedHouses {
    final list = <int>{occupiedHouse, ...ownedHouses}.toList();
    list.sort();
    return list;
  }
}
