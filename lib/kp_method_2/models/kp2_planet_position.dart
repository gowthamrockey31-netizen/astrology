import 'kp2_planet.dart';

/// Single Planet Astronomical & Sidereal Position in KP Method 2
class KP2PlanetPosition {
  final KP2Planet planet;
  final double tropicalLongitude;
  final double siderealLongitude;
  final int rasiIndex;
  final String rasiNameTa;
  final String rasiNameEn;
  final double degreeInRasi;
  final String formattedDms;
  final int nakshatraIndex;
  final String nakshatraNameTa;
  final int pada;
  final KP2Planet starLord;
  final KP2Planet subLord;
  final KP2Planet subSubLord;
  final int occupiedHouse;
  final bool isRetrograde;

  const KP2PlanetPosition({
    required this.planet,
    required this.tropicalLongitude,
    required this.siderealLongitude,
    required this.rasiIndex,
    required this.rasiNameTa,
    required this.rasiNameEn,
    required this.degreeInRasi,
    required this.formattedDms,
    required this.nakshatraIndex,
    required this.nakshatraNameTa,
    required this.pada,
    required this.starLord,
    required this.subLord,
    required this.subSubLord,
    required this.occupiedHouse,
    this.isRetrograde = false,
  });
}
