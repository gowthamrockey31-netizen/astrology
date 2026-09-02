import 'kp_planet.dart';

/// Detailed planetary position model for KP Method Model 1
class KPPlanetPosition {
  final KPPlanet planet;
  final double longitude;
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
  });

  /// Formatted DMS string within the rasi (e.g. 14° 22' 45")
  String get dmsFormatted {
    final secInt = second.round();
    final degStr = degree.toString().padLeft(2, '0');
    final minStr = minute.toString().padLeft(2, '0');
    final secStr = secInt.toString().padLeft(2, '0');
    return "$degStr° $minStr' $secStr\"";
  }

  /// Total houses directly related to this planet (occupied + owned)
  List<int> get relatedHouses {
    final list = <int>{occupiedHouse, ...ownedHouses}.toList();
    list.sort();
    return list;
  }
}
