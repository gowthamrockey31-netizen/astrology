import '../models/kp_cusp.dart';
import '../models/kp_planet_position.dart';
import '../models/kp_significator.dart';
import 'kp_advantage_filter.dart';

/// Calculation engine for KP House-level Significators and Sub-Lord House Relations
class KPHouseRelationEngine {
  /// Calculate House Significators for all 12 cusps
  static List<KPHouseSignificator> calculateHouseSignificators({
    required List<KPCusp> cusps,
    required List<KPPlanetPosition> planets,
  }) {
    // Map each planet name to its occupied and owned houses
    final Map<String, List<int>> planetHouseMap = {};
    final Map<String, KPPlanetPosition> planetMap = {};
    for (final p in planets) {
      planetHouseMap[p.planet.nameEn] = p.relatedHouses;
      planetMap[p.planet.nameEn] = p;
    }

    final List<KPHouseSignificator> result = [];

    for (final cusp in cusps) {
      final cuspSubLord = cusp.subLord;
      final cuspSubLordHouses = planetHouseMap[cuspSubLord] ?? cusp.subLordHouses;

      // Find the star lord and sub lord of the Cusp's Sub Lord
      final subLordPlanet = planetMap[cuspSubLord];
      final starLord = subLordPlanet?.starLord ?? cusp.starLord;
      final starLordHouses = planetHouseMap[starLord] ?? [];

      final subLord = subLordPlanet?.subLord ?? cuspSubLord;
      final subLordHouses = planetHouseMap[subLord] ?? [];

      // Apply Model 1 Advantage Filter
      final finalAdvantageHouses = KPAdvantageFilter.filterAdvantageHouses(
        starHouses: starLordHouses,
        subHouses: subLordHouses,
      );

      result.add(KPHouseSignificator(
        houseNumber: cusp.houseNumber,
        cuspSubLord: cuspSubLord,
        cuspSubLordHouses: cuspSubLordHouses,
        starLord: starLord,
        starLordHouses: starLordHouses,
        subLord: subLord,
        subLordHouses: subLordHouses,
        finalAdvantageHouses: finalAdvantageHouses,
      ));
    }

    return result;
  }
}
