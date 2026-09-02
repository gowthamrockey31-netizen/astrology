import '../models/kp_cusp.dart';
import '../models/kp_planet_position.dart';
import '../models/kp_significator.dart';
import 'kp_advantage_filter.dart';

/// Calculation engine for KP Planet-level Significators
class KPSignificatorEngine {
  /// Calculate significators for all 9 planets
  static List<KPPlanetSignificator> calculatePlanetSignificators({
    required List<KPPlanetPosition> planets,
    required List<KPCusp> cusps,
  }) {
    // Map each planet name to its occupied and owned houses
    final Map<String, List<int>> planetHouseMap = {};
    for (final p in planets) {
      planetHouseMap[p.planet.nameEn] = p.relatedHouses;
    }

    final List<KPPlanetSignificator> result = [];

    for (final p in planets) {
      final planetName = p.planet.nameEn;
      final planetHouses = p.relatedHouses;

      final starLord = p.starLord;
      final starLordHouses = planetHouseMap[starLord] ?? [];

      final subLord = p.subLord;
      final subLordHouses = planetHouseMap[subLord] ?? [];

      // Apply Model 1 Advantage Filter
      final advantageHouses = KPAdvantageFilter.filterAdvantageHouses(
        starHouses: starLordHouses,
        subHouses: subLordHouses,
      );

      result.add(KPPlanetSignificator(
        planet: planetName,
        planetHouses: planetHouses,
        starLord: starLord,
        starLordHouses: starLordHouses,
        subLord: subLord,
        subLordHouses: subLordHouses,
        advantageHouses: advantageHouses,
      ));
    }

    return result;
  }
}
