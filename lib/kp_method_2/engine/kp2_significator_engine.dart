import '../models/kp2_planet.dart';
import '../models/kp2_planet_position.dart';
import '../models/kp2_cusp.dart';
import '../models/kp2_significator.dart';
import 'kp2_advantage_filter.dart';

/// Engine to compute Planet Significators and House Significators for KP Method 2
class KP2SignificatorEngine {
  /// Computes planet and house significators
  static (List<KP2PlanetSignificator>, List<KP2HouseSignificator>) calculate({
    required List<KP2PlanetPosition> positions,
    required List<KP2Cusp> cusps,
  }) {
    // 1. Map each planet to its occupied house and owned houses
    final Map<KP2Planet, int> occupiedHouses = {};
    for (final pos in positions) {
      occupiedHouses[pos.planet] = pos.occupiedHouse;
    }

    final Map<KP2Planet, List<int>> ownedHouses = {};
    for (final p in KP2Planet.values) {
      ownedHouses[p] = [];
    }

    for (final cusp in cusps) {
      final lord = cusp.signLord;
      ownedHouses[lord]?.add(cusp.house);
    }

    // Helper to get all houses signified by a planet (occupied + owned)
    List<int> getPlanetAllHouses(KP2Planet p) {
      final houses = <int>{};
      final occ = occupiedHouses[p];
      if (occ != null) houses.add(occ);
      final owned = ownedHouses[p];
      if (owned != null) houses.addAll(owned);
      final sorted = houses.toList()..sort();
      return sorted;
    }

    // 2. Generate Planet Significators
    final planetSigs = <KP2PlanetSignificator>[];
    for (final pos in positions) {
      final p = pos.planet;
      final occ = pos.occupiedHouse;
      final star = pos.starLord;
      final sub = pos.subLord;
      final subSub = pos.subSubLord;

      planetSigs.add(KP2PlanetSignificator(
        planet: p,
        occupiedHouse: occ,
        starLord: star,
        starLordHouses: getPlanetAllHouses(star),
        subLord: sub,
        subLordHouses: getPlanetAllHouses(sub),
        subSubLord: subSub,
        subSubLordHouses: getPlanetAllHouses(subSub),
      ));
    }

    // 3. Generate House Significators with Advantage Filter
    final houseSigs = <KP2HouseSignificator>[];
    for (final cusp in cusps) {
      final h = cusp.house;
      final sub = cusp.subLord;
      final star = cusp.starLord;
      final subSub = cusp.subSubLord;

      final subHouses = getPlanetAllHouses(sub);
      final starHouses = getPlanetAllHouses(star);
      final subSubHouses = getPlanetAllHouses(subSub);

      final advantageHouses = KP2AdvantageFilter.filter(
        starHouses: starHouses,
        subHouses: subHouses,
      );

      houseSigs.add(KP2HouseSignificator(
        house: h,
        cuspSubLord: sub,
        subLordHouses: subHouses,
        starLord: star,
        starLordHouses: starHouses,
        subSubLord: subSub,
        subSubLordHouses: subSubHouses,
        advantageHouses: advantageHouses,
      ));
    }

    return (planetSigs, houseSigs);
  }
}
