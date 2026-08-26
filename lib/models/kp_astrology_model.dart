/// KP Cusp Detail (Placidus / KP House System)
class KpCuspDetail {
  final int cuspNumber; // 1..12
  final double cuspLongitude;
  final int rasiIndex;
  final String rasiNameTa;
  final String rasiNameEn;
  final double degreeInRasi;
  final String degreeFormatted;
  final String signLordTa;
  final String starLordTa;
  final String subLordTa;
  final String subSubLordTa;

  const KpCuspDetail({
    required this.cuspNumber,
    required this.cuspLongitude,
    required this.rasiIndex,
    required this.rasiNameTa,
    required this.rasiNameEn,
    required this.degreeInRasi,
    required this.degreeFormatted,
    required this.signLordTa,
    required this.starLordTa,
    required this.subLordTa,
    required this.subSubLordTa,
  });
}

/// KP Planet Position with Sub-Lord and Sub-Sub-Lord
class KpPlanetDetail {
  final String planetNameEn;
  final String planetNameTa;
  final String symbol;
  final double longitude;
  final int rasiIndex;
  final String rasiNameTa;
  final double degreeInRasi;
  final String degreeFormatted;
  final String signLordTa;
  final String starLordTa;
  final String subLordTa;
  final String subSubLordTa;
  final int cuspOccupied;
  final bool isRetrograde;

  const KpPlanetDetail({
    required this.planetNameEn,
    required this.planetNameTa,
    required this.symbol,
    required this.longitude,
    required this.rasiIndex,
    required this.rasiNameTa,
    required this.degreeInRasi,
    required this.degreeFormatted,
    required this.signLordTa,
    required this.starLordTa,
    required this.subLordTa,
    required this.subSubLordTa,
    required this.cuspOccupied,
    required this.isRetrograde,
  });
}

/// KP Significator Table (Levels A, B, C, D)
class KpPlanetSignificator {
  final String planetNameTa;
  final List<int> levelA; // Occupant of Star Lord's house
  final List<int> levelB; // Planet's own house occupied
  final List<int> levelC; // Houses owned by Star Lord
  final List<int> levelD; // Houses owned by Planet

  const KpPlanetSignificator({
    required this.planetNameTa,
    required this.levelA,
    required this.levelB,
    required this.levelC,
    required this.levelD,
  });
}

/// KP Cusp Sub Lord House Relation Result (KP பாவ உப நட்சத்திராதிபதி தொடர்பு)
class KpCuspHouseRelationResult {
  final int houseNumber; // 1..12
  final double cuspLongitude;
  final String nakshatraNameTa;
  final String nakshatraNameEn;
  final String cuspStarLordTa;
  final String cuspSubLordTa;

  // Sub Lord breakdown
  final List<int> subLordOccupiedHouses;
  final List<int> subLordOwnedHouses;

  // Sub Lord's Star Lord breakdown
  final String subLordStarLordTa;
  final List<int> starLordOccupiedHouses;
  final List<int> starLordOwnedHouses;

  // Node breakdown (if Sub Lord or Star Lord is Rahu / Ketu)
  final bool isSubLordNode;
  final String? nodeSignLordTa;
  final List<int> nodeSignLordHouses;
  final List<String> conjunctPlanetsTa;
  final List<int> conjunctPlanetsHouses;

  // Final unique, sorted house numbers (1..12)
  final List<int> finalRelatedHouses;

  const KpCuspHouseRelationResult({
    required this.houseNumber,
    required this.cuspLongitude,
    required this.nakshatraNameTa,
    required this.nakshatraNameEn,
    required this.cuspStarLordTa,
    required this.cuspSubLordTa,
    required this.subLordOccupiedHouses,
    required this.subLordOwnedHouses,
    required this.subLordStarLordTa,
    required this.starLordOccupiedHouses,
    required this.starLordOwnedHouses,
    this.isSubLordNode = false,
    this.nodeSignLordTa,
    this.nodeSignLordHouses = const [],
    this.conjunctPlanetsTa = const [],
    this.conjunctPlanetsHouses = const [],
    required this.finalRelatedHouses,
  });

  String get finalRelatedHousesFormatted =>
      finalRelatedHouses.isEmpty ? '-' : finalRelatedHouses.join(', ');
}

/// Complete KP Astrology Calculation Result
class KpAstrologyResult {
  final double kpAyanamsa;
  final String kpAyanamsaFormatted;
  final List<KpCuspDetail> cusps;
  final List<KpPlanetDetail> planets;
  final List<KpPlanetSignificator> significators;
  final Map<String, String> rulingPlanets;
  final List<KpCuspHouseRelationResult> cuspHouseRelations;

  const KpAstrologyResult({
    required this.kpAyanamsa,
    required this.kpAyanamsaFormatted,
    required this.cusps,
    required this.planets,
    required this.significators,
    required this.rulingPlanets,
    this.cuspHouseRelations = const [],
  });
}

