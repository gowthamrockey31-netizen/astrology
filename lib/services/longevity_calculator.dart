import '../models/longevity_result.dart';
import 'astrology_calculator.dart';

/// Longevity Configuration Rule Set for Pindayu Calculation
class PindayuConfig {
  static const Map<String, double> exaltationLongitudes = {
    'Sun': 10.0,
    'Moon': 33.0,
    'Mars': 298.0,
    'Mercury': 165.0,
    'Jupiter': 95.0,
    'Venus': 357.0,
    'Saturn': 200.0,
  };

  static const Map<String, double> maxPindayuYears = {
    'Sun': 19.0,
    'Moon': 25.0,
    'Mars': 15.0,
    'Mercury': 12.0,
    'Jupiter': 15.0,
    'Venus': 21.0,
    'Saturn': 20.0,
  };

  static const Map<String, String> planetTamilNames = {
    'Sun': 'சூரியன்',
    'Moon': 'சந்திரன்',
    'Mars': 'செவ்வாய்',
    'Mercury': 'புதன்',
    'Jupiter': 'குரு',
    'Venus': 'சுக்கிரன்',
    'Saturn': 'சனி',
  };

  /// Planetary Sign Lords (0=Mesham .. 11=Meenam)
  static const List<String> rasiLords = [
    'Mars',    // 0: Mesham
    'Venus',   // 1: Rishabam
    'Mercury', // 2: Mithunam
    'Moon',    // 3: Kadagam
    'Sun',     // 4: Simmam
    'Mercury', // 5: Kanni
    'Venus',   // 6: Thulam
    'Mars',    // 7: Viruchigam
    'Jupiter', // 8: Dhanusu
    'Saturn',  // 9: Makaram
    'Saturn',  // 10: Kumbam
    'Jupiter', // 11: Meenam
  ];

  /// Natural Enemies of 7 Planets
  static const Map<String, List<String>> naturalEnemies = {
    'Sun': ['Saturn', 'Venus'],
    'Moon': [],
    'Mars': ['Mercury'],
    'Mercury': ['Moon'],
    'Jupiter': ['Mercury', 'Venus'],
    'Venus': ['Sun', 'Moon'],
    'Saturn': ['Sun', 'Moon', 'Mars'],
  };
}

class LongevityCalculator {
  /// Reusable Pindayu Longevity Engine
  static LongevityResult calculatePindayuLongevity({
    required Map<String, PlanetDetail> planets,
    required PlanetDetail lagna,
  }) {
    final details = <PlanetaryLongevityDetail>[];
    double totalBasic = 0.0;
    double totalReductions = 0.0;

    final classicalPlanetKeys = ['Sun', 'Moon', 'Mars', 'Mercury', 'Jupiter', 'Venus', 'Saturn'];
    final sunDetail = planets['Sun'];

    for (final planetKey in classicalPlanetKeys) {
      final planet = planets[planetKey];
      if (planet == null) continue;

      final exaltDeg = PindayuConfig.exaltationLongitudes[planetKey] ?? 0.0;
      final maxYears = PindayuConfig.maxPindayuYears[planetKey] ?? 0.0;
      final planetLong = planet.longitude;

      // 1. Calculate circular angular distance to exaltation point
      double dist = (planetLong - exaltDeg).abs();
      if (dist > 180.0) {
        dist = 360.0 - dist;
      }

      // 2. Basic Pindayu Contribution = MaxYears * (1 - (dist / 360))
      final basicContribution = maxYears * (1.0 - (dist / 360.0));
      totalBasic += basicContribution;

      // 3. Enemy House Check
      final rasiLord = PindayuConfig.rasiLords[planet.rasiIndex];
      final isEnemySign = PindayuConfig.naturalEnemies[planetKey]?.contains(rasiLord) ?? false;
      final isRetro = planet.isRetrograde;

      // Enemy reduction = 1/3 of basic contribution (EXEMPT if Retrograde)
      double enemyReduction = 0.0;
      if (isEnemySign && !isRetro && planetKey != rasiLord) {
        enemyReduction = basicContribution * (1.0 / 3.0);
      }

      // 4. Combustion Check
      bool isCombust = false;
      if (planetKey != 'Sun' && sunDetail != null) {
        double sunDist = (planetLong - sunDetail.longitude).abs();
        if (sunDist > 180.0) sunDist = 360.0 - sunDist;

        final orbMap = {
          'Mars': 17.0,
          'Mercury': 13.0,
          'Jupiter': 11.0,
          'Venus': 10.0,
          'Saturn': 15.0,
        };
        final maxOrb = orbMap[planetKey] ?? 12.0;
        isCombust = sunDist <= maxOrb;
      }

      // Combustion reduction = 1/2 of basic contribution
      // TRADITIONAL EXCEPTION: Saturn and Venus are exempt from combustion reduction in Pindayu
      double combustionReduction = 0.0;
      if (isCombust && planetKey != 'Saturn' && planetKey != 'Venus') {
        combustionReduction = basicContribution * (1.0 / 2.0);
      }

      final netReductionsForPlanet = enemyReduction + combustionReduction;
      final finalPlanetYears = (basicContribution - netReductionsForPlanet).clamp(0.0, maxYears);

      totalReductions += netReductionsForPlanet;

      details.add(PlanetaryLongevityDetail(
        planetNameEn: planetKey,
        planetNameTa: PindayuConfig.planetTamilNames[planetKey] ?? planetKey,
        longitude: planetLong,
        exaltationLongitude: exaltDeg,
        angularDistance: dist,
        maxYears: maxYears,
        basicYears: basicContribution,
        isEnemySign: isEnemySign,
        isCombust: isCombust,
        isRetrograde: isRetro,
        enemyReduction: enemyReduction,
        combustionReduction: combustionReduction,
        finalYears: finalPlanetYears,
      ));
    }

    // 5. Lagna Contribution = Lagna Degree in Sign / 30.0 * 1.0 Year
    final lagnaContribution = (lagna.degreeInRasi / 30.0) * 1.0;

    final grossYears = totalBasic - totalReductions + lagnaContribution;
    final finalYears = grossYears.clamp(0.0, 120.0);

    // 6. Category Determination
    late LongevityCategory cat;
    late String catTa;
    late String catEn;

    if (finalYears < 32.0) {
      cat = LongevityCategory.alpayu;
      catEn = 'Alpayu';
      catTa = 'அல்பாயுள் (Alpayu < 32 yrs)';
    } else if (finalYears <= 70.0) {
      cat = LongevityCategory.madhyayu;
      catEn = 'Madhyayu';
      catTa = 'மத்தியாயுள் (Madhyayu 32–70 yrs)';
    } else {
      cat = LongevityCategory.deerghayu;
      catEn = 'Deerghayu';
      catTa = 'தீர்க்காயுள் (Deerghayu > 70 yrs)';
    }

    return LongevityResult(
      totalBasicYears: totalBasic,
      totalReductions: totalReductions,
      lagnaContribution: lagnaContribution,
      finalYears: finalYears,
      category: cat,
      categoryNameEn: catEn,
      categoryNameTa: catTa,
      planetaryBreakdown: details,
      disclaimer: 'Note: Ayurmatham (Pindayu) longevity calculation is a traditional mathematical model based on planetary strengths at birth. It represents astrological potential and should not be interpreted as a deterministic prediction of actual lifespan.',
    );
  }
}
