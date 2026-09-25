import '../models/kp4_models.dart';

/// Centralized Relationship Engine for KP Method 4
/// Evaluates:
/// 1. Planet Relations (Graha Thodarbhu):
///    - Step 1: Star Lord -> Bhavas where Star Lord appears as cusp Sub Lord
///    - Step 2: Sub Lord -> Bhavas where Sub Lord appears as cusp Sub Lord
///    - Step 3: Sub-Sub Fallback -> if match is absent, check cusp Sub-Sub Lord with '$'
/// 2. Bhava Relations (Bhava Graha Thodarbhu):
///    - Bhava Sub Lord relations
///    - Star Lord of Bhava Sub Lord relations
/// 3. Dasha Relations:
///    - Dasha / Bhukti / Antara / Sookshma relations derived directly from Planet Relations
class KpMethod4RelationEngine {
  /// Calculate Graha Thodarbhu (Planet Relations) for all 9 planets
  static List<PlanetRelation> calculatePlanetRelations({
    required List<PlanetPosition> planets,
    required List<CuspPosition> cusps,
  }) {
    final List<PlanetRelation> relations = [];

    for (final planet in planets) {
      // Step 1: Check Star Lord
      final starLordMatches = _findCuspSubLordHouses(cusps, planet.starLord);
      final bool isStarFallback = starLordMatches.isEmpty;
      final List<KpHouseNumber> starHouses = isStarFallback
          ? _findCuspSubSubLordHouses(cusps, planet.starLord)
          : starLordMatches;

      // Step 2: Check Sub Lord
      final subLordMatches = _findCuspSubLordHouses(cusps, planet.subLord);
      final bool isSubFallback = subLordMatches.isEmpty;
      final List<KpHouseNumber> subHouses = isSubFallback
          ? _findCuspSubSubLordHouses(cusps, planet.subLord)
          : subLordMatches;

      // Combined unique houses
      final combined = _mergeAndSortHouses(starHouses, subHouses);

      relations.add(
        PlanetRelation(
          planet: planet.planet,
          planetTa: planet.planetTa,
          starLord: planet.starLord,
          starLordTa: planet.starLordTa,
          starLordHouses: starHouses,
          isStarLordFallback: isStarFallback,
          subLord: planet.subLord,
          subLordTa: planet.subLordTa,
          subLordHouses: subHouses,
          isSubLordFallback: isSubFallback,
          subSubLord: planet.subSubLord,
          subSubLordTa: planet.subSubLordTa,
          combinedHouses: combined,
        ),
      );
    }

    return relations;
  }

  /// Step 1 & 2: Find Bhavas where the target planet appears as Sub Lord
  static List<KpHouseNumber> _findCuspSubLordHouses(
    List<CuspPosition> cusps,
    String targetPlanet,
  ) {
    final result = <KpHouseNumber>[];
    for (final c in cusps) {
      if (_isSamePlanet(c.subLord, targetPlanet)) {
        result.add(KpHouseNumber(c.cuspNumber, isSubSubFallback: false));
      }
    }
    return result;
  }

  /// Step 3: Fallback - Find Bhavas where the target planet appears as Sub-Sub Lord
  /// Marked with isSubSubFallback = true ('$')
  static List<KpHouseNumber> _findCuspSubSubLordHouses(
    List<CuspPosition> cusps,
    String targetPlanet,
  ) {
    final result = <KpHouseNumber>[];
    for (final c in cusps) {
      if (_isSamePlanet(c.subSubLord, targetPlanet)) {
        result.add(KpHouseNumber(c.cuspNumber, isSubSubFallback: true));
      }
    }
    return result;
  }

  /// Merge and sort unique house numbers (prefer non-fallback if duplicate)
  static List<KpHouseNumber> _mergeAndSortHouses(
    List<KpHouseNumber> list1,
    List<KpHouseNumber> list2,
  ) {
    final Map<int, KpHouseNumber> map = {};
    for (final h in [...list1, ...list2]) {
      if (!map.containsKey(h.house)) {
        map[h.house] = h;
      } else {
        // If already exists but current is non-fallback, upgrade to non-fallback
        if (!h.isSubSubFallback && map[h.house]!.isSubSubFallback) {
          map[h.house] = h;
        }
      }
    }
    final sortedKeys = map.keys.toList()..sort();
    return sortedKeys.map((k) => map[k]!).toList();
  }

  /// Calculate Bhava Graha Thodarbhu (House Relations) for 12 Bhavas
  /// Derived strictly from the centralized planet relations
  static List<HouseRelation> calculateHouseRelations({
    required List<CuspPosition> cusps,
    required List<PlanetPosition> planets,
    required List<PlanetRelation> planetRelations,
  }) {
    final List<HouseRelation> houseRelations = [];

    for (final cusp in cusps) {
      // 1. Get Bhava's Sub Lord
      final subLordName = cusp.subLord;
      final subLordRelation = _findRelation(planetRelations, subLordName);
      final cuspSubLordRelations = subLordRelation?.combinedHouses ?? [];

      // 2. Get the Star Lord of the Bhava's Sub Lord
      final subLordPos = _findPlanetPosition(planets, subLordName);
      final subLordStarLordName = subLordPos?.starLord ?? '';
      final subLordStarLordRelation = _findRelation(planetRelations, subLordStarLordName);
      final cuspSubLordStarLordRelations = subLordStarLordRelation?.combinedHouses ?? [];

      // Combined unique
      final combined = _mergeAndSortHouses(
        cuspSubLordRelations,
        cuspSubLordStarLordRelations,
      );

      houseRelations.add(
        HouseRelation(
          houseNumber: cusp.cuspNumber,
          cuspSubLord: subLordName,
          cuspSubLordTa: cusp.subLordTa,
          cuspSubLordRelations: cuspSubLordRelations,
          cuspSubLordStarLord: subLordStarLordName,
          cuspSubLordStarLordTa: subLordPos?.starLordTa ?? '',
          cuspSubLordStarLordRelations: cuspSubLordStarLordRelations,
          combinedHouses: combined,
        ),
      );
    }

    return houseRelations;
  }

  /// Calculate Dasha Relations for active Vimshottari periods
  /// (Dasha -> Bhukti -> Antara -> Sookshma)
  /// Strictly retrieves the corresponding planet's calculated relationships from Graha Thodarbhu
  static List<DashaRelation> calculateDashaRelations({
    required String dashaLord,
    required String bhuktiLord,
    required String antaraLord,
    required String sookshmaLord,
    required List<PlanetRelation> planetRelations,
  }) {
    final levels = [
      (
        levelName: 'தசா நாதன்',
        levelNameEn: 'Dasha Lord',
        planet: dashaLord,
      ),
      (
        levelName: 'புத்தி நாதன்',
        levelNameEn: 'Bhukti Lord',
        planet: bhuktiLord,
      ),
      (
        levelName: 'அந்தரம் நாதன்',
        levelNameEn: 'Antara Lord',
        planet: antaraLord,
      ),
      (
        levelName: 'சூட்சும நாதன்',
        levelNameEn: 'Sookshma Lord',
        planet: sookshmaLord,
      ),
    ];

    final List<DashaRelation> dashaRelations = [];

    for (final lvl in levels) {
      final pRelation = _findRelation(planetRelations, lvl.planet);
      dashaRelations.add(
        DashaRelation(
          levelName: lvl.levelName,
          levelNameEn: lvl.levelNameEn,
          planet: lvl.planet,
          planetTa: pRelation?.planetTa ?? lvl.planet,
          relations: pRelation?.combinedHouses ?? [],
          starLordRelations: pRelation?.starLordHouses ?? [],
          subLordRelations: pRelation?.subLordHouses ?? [],
        ),
      );
    }

    return dashaRelations;
  }

  static PlanetRelation? _findRelation(List<PlanetRelation> relations, String planet) {
    try {
      return relations.firstWhere(
        (r) => _isSamePlanet(r.planet, planet),
      );
    } catch (_) {
      return null;
    }
  }

  static PlanetPosition? _findPlanetPosition(List<PlanetPosition> planets, String planet) {
    try {
      return planets.firstWhere(
        (p) => _isSamePlanet(p.planet, planet),
      );
    } catch (_) {
      return null;
    }
  }

  static bool _isSamePlanet(String a, String b) {
    return a.trim().toLowerCase() == b.trim().toLowerCase();
  }
}
