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

/// Complete KP Astrology Calculation Result
class KpAstrologyResult {
  final double kpAyanamsa;
  final String kpAyanamsaFormatted;
  final List<KpCuspDetail> cusps;
  final List<KpPlanetDetail> planets;
  final List<KpPlanetSignificator> significators;
  final Map<String, String> rulingPlanets;

  const KpAstrologyResult({
    required this.kpAyanamsa,
    required this.kpAyanamsaFormatted,
    required this.cusps,
    required this.planets,
    required this.significators,
    required this.rulingPlanets,
  });
}
