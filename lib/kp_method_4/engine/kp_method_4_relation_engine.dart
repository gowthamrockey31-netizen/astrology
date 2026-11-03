import '../models/kp4_models.dart';

/// Centralized Relationship Engine for KP Method 4
/// Evaluates:
/// 1. Planet Relations (Graha Thodarbhu):
///    - Priority 1: Check Sub Lord relationship
///    - Priority 2: If none, check Sub-Sub Lord relationship (marked with '$')
///    - Priority 3: If none, check Star Lord relationship (marked with '*')
/// 2. Planet-to-Bhava Contact Mapping:
///    - Dynamically maps each of the 9 planets to the Bhavas it contacts/represents
///    - Strictly retains sourceLevel (SUB_LORD, SUB_SUB_LORD, STAR_LORD)
/// 3. Bhava Relations (Bhava Graha Thodarbhu):
///    - Bhava Sub Lord relations
///    - Star Lord of Bhava Sub Lord relations
/// 4. Dasha Relations:
///    - Dasha / Bhukti / Antara / Sookshma relations derived directly from Planet Relations
class KpMethod4RelationEngine {
  /// Resolves the contacts for a target planet across all 12 Bhavas
  /// according to the strict KP Lord hierarchy:
  /// Priority 1: Check Sub Lord relationship
  /// Priority 2: If none, check Sub-Sub Lord relationship
  /// Priority 3: If none, check Star Lord relationship
  static ({
    List<BhavaContact> contacts,
    List<KpHouseNumber> houses,
    KpSourceLevel? sourceLevel,
  }) resolvePlanetContacts({
    required String targetPlanet,
    required List<CuspPosition> cusps,
  }) {
    // Priority 1: Sub Lord relationship
    final subLordCusps = cusps
        .where((c) =>
            _isSamePlanet(c.subLord, targetPlanet) ||
            _isSamePlanet(c.subLordTa, targetPlanet))
        .toList();
    if (subLordCusps.isNotEmpty) {
      final contacts = subLordCusps
          .map((c) => BhavaContact(
                bhava: c.cuspNumber,
                planet: targetPlanet,
                sourceLevel: KpSourceLevel.SUB_LORD,
              ))
          .toList();
      final houses = subLordCusps
          .map((c) => KpHouseNumber(
                c.cuspNumber,
                isSubSubFallback: false,
                isStarLordFallback: false,
                sourceLevel: KpSourceLevel.SUB_LORD,
              ))
          .toList();
      return (
        contacts: contacts,
        houses: houses,
        sourceLevel: KpSourceLevel.SUB_LORD,
      );
    }

    // Priority 2: Sub-Sub Lord relationship
    final subSubLordCusps = cusps
        .where((c) =>
            _isSamePlanet(c.subSubLord, targetPlanet) ||
            _isSamePlanet(c.subSubLordTa, targetPlanet))
        .toList();
    if (subSubLordCusps.isNotEmpty) {
      final contacts = subSubLordCusps
          .map((c) => BhavaContact(
                bhava: c.cuspNumber,
                planet: targetPlanet,
                sourceLevel: KpSourceLevel.SUB_SUB_LORD,
              ))
          .toList();
      final houses = subSubLordCusps
          .map((c) => KpHouseNumber(
                c.cuspNumber,
                isSubSubFallback: true,
                isStarLordFallback: false,
                sourceLevel: KpSourceLevel.SUB_SUB_LORD,
              ))
          .toList();
      return (
        contacts: contacts,
        houses: houses,
        sourceLevel: KpSourceLevel.SUB_SUB_LORD,
      );
    }

    // Priority 3: Star Lord relationship
    final starLordCusps = cusps
        .where((c) =>
            _isSamePlanet(c.starLord, targetPlanet) ||
            _isSamePlanet(c.starLordTa, targetPlanet))
        .toList();
    if (starLordCusps.isNotEmpty) {
      final contacts = starLordCusps
          .map((c) => BhavaContact(
                bhava: c.cuspNumber,
                planet: targetPlanet,
                sourceLevel: KpSourceLevel.STAR_LORD,
              ))
          .toList();
      final houses = starLordCusps
          .map((c) => KpHouseNumber(
                c.cuspNumber,
                isSubSubFallback: false,
                isStarLordFallback: true,
                sourceLevel: KpSourceLevel.STAR_LORD,
              ))
          .toList();
      return (
        contacts: contacts,
        houses: houses,
        sourceLevel: KpSourceLevel.STAR_LORD,
      );
    }

    return (
      contacts: <BhavaContact>[],
      houses: <KpHouseNumber>[],
      sourceLevel: null,
    );
  }

  /// Resolves the contact for a single Bhava and planet according to hierarchy:
  /// Priority 1: Sub Lord -> Priority 2: Sub-Sub Lord -> Priority 3: Star Lord
  static BhavaContact? resolveBhavaPlanetContact({
    required CuspPosition cusp,
    required String planet,
  }) {
    if (_isSamePlanet(cusp.subLord, planet) || _isSamePlanet(cusp.subLordTa, planet)) {
      return BhavaContact(
        bhava: cusp.cuspNumber,
        planet: planet,
        sourceLevel: KpSourceLevel.SUB_LORD,
      );
    }
    if (_isSamePlanet(cusp.subSubLord, planet) || _isSamePlanet(cusp.subSubLordTa, planet)) {
      return BhavaContact(
        bhava: cusp.cuspNumber,
        planet: planet,
        sourceLevel: KpSourceLevel.SUB_SUB_LORD,
      );
    }
    if (_isSamePlanet(cusp.starLord, planet) || _isSamePlanet(cusp.starLordTa, planet)) {
      return BhavaContact(
        bhava: cusp.cuspNumber,
        planet: planet,
        sourceLevel: KpSourceLevel.STAR_LORD,
      );
    }
    return null;
  }

  /// Determines which house (1..12) a planet occupies based on KP house cusps (Placidus).
  /// Reuses the existing KP house-cusp boundary logic.
  /// Returns null if cusps or planet longitude is missing or invalid.
  static int? determineOccupiedHouse({
    required double planetLongitude,
    required List<CuspPosition> cusps,
  }) {
    if (cusps.length < 12) return null;
    if (planetLongitude.isNaN || planetLongitude.isInfinite) return null;

    final sortedCusps = List<CuspPosition>.from(cusps)
      ..sort((a, b) => a.cuspNumber.compareTo(b.cuspNumber));

    // Ensure all 12 cusps 1..12 are present with valid numeric coordinates
    for (int i = 0; i < 12; i++) {
      if (sortedCusps[i].cuspNumber != i + 1) return null;
      if (sortedCusps[i].longitude.isNaN || sortedCusps[i].longitude.isInfinite) {
        return null;
      }
    }

    final normLong = (planetLongitude % 360.0 + 360.0) % 360.0;

    for (int i = 0; i < 12; i++) {
      final cur = (sortedCusps[i].longitude % 360.0 + 360.0) % 360.0;
      final next = (sortedCusps[(i + 1) % 12].longitude % 360.0 + 360.0) % 360.0;

      if (next > cur) {
        if (normLong >= cur && normLong < next) {
          return sortedCusps[i].cuspNumber;
        }
      } else if (cur > next) {
        // Straddles 0° Aries
        if (normLong >= cur || normLong < next) {
          return sortedCusps[i].cuspNumber;
        }
      } else {
        if (normLong == cur) {
          return sortedCusps[i].cuspNumber;
        }
      }
    }

    return sortedCusps.first.cuspNumber;
  }

  /// Calculates house number from the planet's sign index and ascendant longitude
  /// Formula: ((signIndex - ascSign + 12) % 12) + 1 where ascSign = (ascendantLongitude / 30).floor()
  static int houseFromAscendantSign({
    required int signIndex,
    required double ascendantLongitude,
  }) {
    final ascSign = (ascendantLongitude / 30).floor();
    return ((signIndex - ascSign + 12) % 12) + 1;
  }

  /// Calculates the fallback house number by counting the planet's occupied zodiac sign
  /// from the Lagna (Ascendant) sign, treating the Lagna sign as the 1st house and
  /// counting zodiac signs in order.
  static int calculateFallbackHouseFromLagna({
    required int planetSignIndex,
    required int ascendantSignIndex,
  }) {
    return ((planetSignIndex - ascendantSignIndex + 12) % 12) + 1;
  }

  /// Evaluates related houses and applies fallback occupied house if empty
  static List<int> applyFallbackHouse({
    required List<int> relatedHouses,
    required int planetSignIndex,
    required double ascendantLongitude,
  }) {
    final houses = relatedHouses
        .where((h) => h >= 1 && h <= 12)
        .toSet()
        .toList()
      ..sort();

    if (houses.isNotEmpty) {
      return houses;
    }

    final fallbackHouse = houseFromAscendantSign(
      signIndex: planetSignIndex,
      ascendantLongitude: ascendantLongitude,
    );

    return [fallbackHouse];
  }

  /// Checks whether a planet appears in Part 2 Planetary Positions under
  /// Star Lord, Sub Lord, or Sub-Sub Lord columns.
  static bool appearsInPart2LordColumns({
    required PlanetPosition planet,
    required List<PlanetPosition> planetaryPositions,
  }) {
    for (final p in planetaryPositions) {
      if (_isSamePlanet(p.starLord, planet.planet) ||
          _isSamePlanet(p.starLordTa, planet.planet) ||
          _isSamePlanet(p.starLord, planet.planetTa) ||
          _isSamePlanet(p.starLordTa, planet.planetTa) ||
          _isSamePlanet(p.subLord, planet.planet) ||
          _isSamePlanet(p.subLordTa, planet.planet) ||
          _isSamePlanet(p.subLord, planet.planetTa) ||
          _isSamePlanet(p.subLordTa, planet.planetTa) ||
          _isSamePlanet(p.subSubLord, planet.planet) ||
          _isSamePlanet(p.subSubLordTa, planet.planet) ||
          _isSamePlanet(p.subSubLord, planet.planetTa) ||
          _isSamePlanet(p.subSubLordTa, planet.planetTa)) {
        return true;
      }
    }
    return false;
  }

  /// Calculate Planet-to-Bhava contact mapping for all 9 planets
  /// Planet -> [BhavaContact] with retained sourceLevel
  static Map<String, List<BhavaContact>> calculatePlanetToBhavaContacts({
    required List<PlanetPosition> planets,
    required List<CuspPosition> cusps,
    double? ascendantDegree,
  }) {
    final Map<String, List<BhavaContact>> mapping = {};

    final double ascLong = ascendantDegree ??
        (cusps.isNotEmpty
            ? cusps.firstWhere((c) => c.cuspNumber == 1, orElse: () => cusps.first).longitude
            : 0.0);

    for (final planet in planets) {
      // 1. Calculate the planet's existing KP house connections using the current calculation engine
      final resolved = resolvePlanetContacts(
        targetPlanet: planet.planet,
        cusps: cusps,
      );

      // 2. If any valid house connections exist, preserve the existing result
      if (resolved.contacts.isNotEmpty) {
        mapping[planet.planet] = resolved.contacts;
        continue;
      }

      // If data is missing or invalid, do not invent a result
      if (planet.longitude.isNaN || planet.longitude.isInfinite || cusps.isEmpty || ascLong.isNaN) {
        mapping[planet.planet] = const [];
        continue;
      }

      // 3. Fallback: occupied house from Lagna using user-supplied applyFallbackHouse
      final int planetSignIndex = (planet.longitude / 30).floor();
      final List<int> relatedHouseInts = resolved.contacts.map((c) => c.bhava).toList();

      final List<int> fallbackHouses = applyFallbackHouse(
        relatedHouses: relatedHouseInts,
        planetSignIndex: planetSignIndex,
        ascendantLongitude: ascLong,
      );

      mapping[planet.planet] = fallbackHouses
          .map((h) => BhavaContact(
                bhava: h,
                planet: planet.planet,
                sourceLevel: KpSourceLevel.SUB_LORD,
              ))
          .toList();
    }
    return mapping;
  }

  /// Calculate Planet-to-Bhava numbers mapping (Planet -> [Bhava numbers])
  static Map<String, List<KpHouseNumber>> calculatePlanetToBhavaHouses({
    required List<PlanetPosition> planets,
    required List<CuspPosition> cusps,
    double? ascendantDegree,
  }) {
    final Map<String, List<KpHouseNumber>> mapping = {};

    final double ascLong = ascendantDegree ??
        (cusps.isNotEmpty
            ? cusps.firstWhere((c) => c.cuspNumber == 1, orElse: () => cusps.first).longitude
            : 0.0);

    for (final planet in planets) {
      // 1. Calculate the planet's existing KP house connections using the current calculation engine
      final resolved = resolvePlanetContacts(
        targetPlanet: planet.planet,
        cusps: cusps,
      );

      // 2. If any valid house connections exist, preserve the existing result
      if (resolved.houses.isNotEmpty) {
        mapping[planet.planet] = resolved.houses;
        continue;
      }

      // If data is missing or invalid, do not invent a result
      if (planet.longitude.isNaN || planet.longitude.isInfinite || cusps.isEmpty || ascLong.isNaN) {
        mapping[planet.planet] = const [];
        continue;
      }

      // 3. Fallback: occupied house from Lagna using user-supplied applyFallbackHouse
      final int planetSignIndex = (planet.longitude / 30).floor();
      final List<int> relatedHouseInts = resolved.houses.map((h) => h.house).toList();

      final List<int> fallbackHouses = applyFallbackHouse(
        relatedHouses: relatedHouseInts,
        planetSignIndex: planetSignIndex,
        ascendantLongitude: ascLong,
      );

      mapping[planet.planet] = fallbackHouses.map((h) => KpHouseNumber(h)).toList();
    }
    return mapping;
  }

  /// Calculate Graha Thodarbhu (Planet Relations) for all 9 planets
  static List<PlanetRelation> calculatePlanetRelations({
    required List<PlanetPosition> planets,
    required List<CuspPosition> cusps,
    double? ascendantDegree,
    Map<String, List<KpHouseNumber>>? planetToBhavas,
  }) {
    final List<PlanetRelation> relations = [];

    final double ascLong = ascendantDegree ??
        (cusps.isNotEmpty
            ? cusps.firstWhere((c) => c.cuspNumber == 1, orElse: () => cusps.first).longitude
            : 0.0);

    List<KpHouseNumber> getLordHouses(String lordName) {
      if (planetToBhavas != null) {
        for (final entry in planetToBhavas.entries) {
          if (_isSamePlanet(entry.key, lordName) && entry.value.isNotEmpty) {
            return entry.value;
          }
        }
      }
      final res = resolvePlanetContacts(targetPlanet: lordName, cusps: cusps);
      if (res.houses.isNotEmpty) {
        return res.houses;
      }
      // Fallback: calculate occupied house from Lagna
      final lordPos = planets.firstWhere(
        (p) => _isSamePlanet(p.planet, lordName) || _isSamePlanet(p.planetTa, lordName),
        orElse: () => planets.first,
      );
      final signIdx = (lordPos.longitude / 30).floor();
      final fbHouse = houseFromAscendantSign(signIndex: signIdx, ascendantLongitude: ascLong);
      return [KpHouseNumber(fbHouse)];
    }

    for (final planet in planets) {
      // Step 1: Check Star Lord using corrected 3-priority hierarchy + fallback
      final starRes = resolvePlanetContacts(
        targetPlanet: planet.starLord,
        cusps: cusps,
      );
      final bool isStarFallback = starRes.sourceLevel != null &&
          starRes.sourceLevel != KpSourceLevel.SUB_LORD;
      final List<KpHouseNumber> starHouses = getLordHouses(planet.starLord);

      // Step 2: Check Sub Lord using corrected 3-priority hierarchy + fallback
      final subRes = resolvePlanetContacts(
        targetPlanet: planet.subLord,
        cusps: cusps,
      );
      final bool isSubFallback = subRes.sourceLevel != null &&
          subRes.sourceLevel != KpSourceLevel.SUB_LORD;
      final List<KpHouseNumber> subHouses = getLordHouses(planet.subLord);

      // Step 3: Direct Planet's contacts using corrected 3-priority hierarchy + fallback
      final directRes = resolvePlanetContacts(
        targetPlanet: planet.planet,
        cusps: cusps,
      );
      final List<KpHouseNumber> directHouses = getLordHouses(planet.planet);

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
          starLordSourceLevel: starRes.sourceLevel ?? KpSourceLevel.SUB_LORD,
          subLord: planet.subLord,
          subLordTa: planet.subLordTa,
          subLordHouses: subHouses,
          isSubLordFallback: isSubFallback,
          subLordSourceLevel: subRes.sourceLevel ?? KpSourceLevel.SUB_LORD,
          subSubLord: planet.subSubLord,
          subSubLordTa: planet.subSubLordTa,
          combinedHouses: combined,
          planetHouses: directHouses,
          planetContacts: directRes.contacts,
          planetSourceLevel: directRes.sourceLevel,
        ),
      );
    }

    return relations;
  }

  /// Merge and sort unique house numbers (prefer higher priority sourceLevel if duplicate)
  static List<KpHouseNumber> _mergeAndSortHouses(
    List<KpHouseNumber> list1,
    List<KpHouseNumber> list2,
  ) {
    final Map<int, KpHouseNumber> map = {};
    for (final h in [...list1, ...list2]) {
      if (!map.containsKey(h.house)) {
        map[h.house] = h;
      } else {
        // Prefer SUB_LORD (0) over SUB_SUB_LORD (1) over STAR_LORD (2)
        final existing = map[h.house]!;
        if (h.sourceLevel.index < existing.sourceLevel.index) {
          map[h.house] = h;
        }
      }
    }
    final sortedKeys = map.keys.toList()..sort();
    return sortedKeys.map((k) => map[k]!).toList();
  }

  /// Calculate Bhava Graha Thodarbhu (Bhava Planetary Connections) for 12 Bhavas
  /// Populated directly from the existing Planetary Connections (Planet Relations) data source.
  /// Step 1: Read the Bhava Sub Lord from Bhava Positions
  /// Step 2: Find that planet in Planetary Connections
  /// Step 3: Read that planet's existing Planetary Connections data (Connected Bhavas, Star Lord, Sub Lord)
  /// Step 4: Associate and display under the corresponding Bhava
  static List<HouseRelation> calculateHouseRelations({
    required List<CuspPosition> cusps,
    required List<PlanetPosition> planets,
    required List<PlanetRelation> planetRelations,
  }) {
    final List<HouseRelation> houseRelations = [];

    for (final cusp in cusps) {
      // Step 1: Read the Bhava Sub Lord
      final subLordName = cusp.subLord;

      // Step 2 & 3: Find that planet in Planetary Connections and read its existing data
      final planetRel = _findRelation(planetRelations, subLordName);

      final connectedHouses = planetRel?.combinedHouses ?? [];
      final starLordName = planetRel?.starLord ?? '';
      final starLordTa = planetRel?.starLordTa ?? '';
      final starLordHouses = planetRel?.starLordHouses ?? [];
      final isStarFallback = planetRel?.isStarLordFallback ?? false;

      final subLordPlanetName = planetRel?.subLord ?? '';
      final subLordPlanetTa = planetRel?.subLordTa ?? '';
      final subLordHouses = planetRel?.subLordHouses ?? [];
      final isSubFallback = planetRel?.isSubLordFallback ?? false;

      // Step 4: Associate the existing Planetary Connections data with the Bhava
      houseRelations.add(
        HouseRelation(
          houseNumber: cusp.cuspNumber,
          cuspSubLord: subLordName,
          cuspSubLordTa: cusp.subLordTa,
          cuspSubLordRelations: connectedHouses,
          cuspSubLordStarLord: starLordName,
          cuspSubLordStarLordTa: starLordTa,
          cuspSubLordStarLordRelations: starLordHouses,
          cuspSubLordSubLord: subLordPlanetName,
          cuspSubLordSubLordTa: subLordPlanetTa,
          cuspSubLordSubLordRelations: subLordHouses,
          combinedHouses: connectedHouses,
          planetRelation: planetRel,
          isStarLordFallback: isStarFallback,
          isSubLordFallback: isSubFallback,
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
        (r) => _isSamePlanet(r.planet, planet) || _isSamePlanet(r.planetTa, planet),
      );
    } catch (_) {
      return null;
    }
  }

  static bool _isSamePlanet(String a, String b) {
    return KpPlanetUtils.isSamePlanet(a, b);
  }
}
