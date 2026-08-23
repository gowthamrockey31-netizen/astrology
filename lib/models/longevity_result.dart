/// Detail item for individual planetary contribution in Pindayu Longevity
class PlanetaryLongevityDetail {
  final String planetNameEn;
  final String planetNameTa;
  final double longitude;
  final double exaltationLongitude;
  final double angularDistance;
  final double maxYears;
  final double basicYears;
  final bool isEnemySign;
  final bool isCombust;
  final bool isRetrograde;
  final double enemyReduction;
  final double combustionReduction;
  final double finalYears;

  const PlanetaryLongevityDetail({
    required this.planetNameEn,
    required this.planetNameTa,
    required this.longitude,
    required this.exaltationLongitude,
    required this.angularDistance,
    required this.maxYears,
    required this.basicYears,
    required this.isEnemySign,
    required this.isCombust,
    required this.isRetrograde,
    required this.enemyReduction,
    required this.combustionReduction,
    required this.finalYears,
  });
}

/// Longevity Category Enum
enum LongevityCategory {
  alpayu,   // < 32 years
  madhyayu, // 32 - 70 years
  deerghayu // > 70 years
}

/// Structured immutable data model for Pindayu Longevity calculation result
class LongevityResult {
  final double totalBasicYears;
  final double totalReductions;
  final double lagnaContribution;
  final double finalYears; // Gross Longevity Years
  final LongevityCategory category;
  final String categoryNameEn;
  final String categoryNameTa;
  final List<PlanetaryLongevityDetail> planetaryBreakdown;
  final String disclaimer;

  const LongevityResult({
    required this.totalBasicYears,
    required this.totalReductions,
    required this.lagnaContribution,
    required this.finalYears,
    required this.category,
    required this.categoryNameEn,
    required this.categoryNameTa,
    required this.planetaryBreakdown,
    required this.disclaimer,
  });
}
