import 'kp2_birth_data.dart';
import 'kp2_planet.dart';
import 'kp2_planet_position.dart';
import 'kp2_cusp.dart';
import 'kp2_ruling_planet.dart';
import 'kp2_significator.dart';
import 'kp2_dasha.dart';

/// Complete Encapsulated KP Method 2 Result
class KP2Result {
  final KP2BirthData birthData;
  final double julianDay;
  final double ayanamsa;
  final String ayanamsaDms;
  final List<KP2PlanetPosition> planetPositions;
  final List<KP2Cusp> cusps;
  final KP2RulingPlanets rulingPlanets;
  final List<KP2PlanetSignificator> planetSignificators;
  final List<KP2HouseSignificator> houseSignificators;
  final KP2DashaBalance dashaBalance;
  final List<KP2DashaPeriod> dashaTimeline;

  const KP2Result({
    required this.birthData,
    required this.julianDay,
    required this.ayanamsa,
    required this.ayanamsaDms,
    required this.planetPositions,
    required this.cusps,
    required this.rulingPlanets,
    required this.planetSignificators,
    required this.houseSignificators,
    required this.dashaBalance,
    required this.dashaTimeline,
  });

  KP2PlanetPosition getPosition(KP2Planet planet) {
    return planetPositions.firstWhere(
      (p) => p.planet == planet,
      orElse: () => planetPositions.first,
    );
  }

  KP2Cusp getCusp(int houseNumber) {
    return cusps.firstWhere(
      (c) => c.house == houseNumber,
      orElse: () => cusps.first,
    );
  }
}
