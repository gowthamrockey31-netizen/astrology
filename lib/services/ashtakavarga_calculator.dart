import 'astrology_calculator.dart';

class AshtakavargaResult {
  /// Map of Planet Name -> List of 12 Bindu scores for each Rasi (0..11)
  final Map<String, List<int>> bhinnashtakavarga;

  /// List of 12 Sarvashtakavarga (SAV) total bindu scores for each Rasi (0..11)
  final List<int> sarvashtakavarga;

  /// Total SAV points (should equal 337)
  final int totalSavPoints;

  const AshtakavargaResult({
    required this.bhinnashtakavarga,
    required this.sarvashtakavarga,
    required this.totalSavPoints,
  });
}

class AshtakavargaCalculator {
  /// Reference house numbers (1-indexed) where each planet contributes a bindu
  static const Map<String, Map<String, List<int>>> _ashtakavargaRules = {
    'Sun': {
      'Sun': [1, 2, 4, 7, 8, 9, 10, 11],
      'Moon': [3, 6, 10, 11],
      'Mars': [1, 2, 4, 7, 8, 9, 10, 11],
      'Mercury': [3, 5, 6, 9, 10, 11, 12],
      'Jupiter': [5, 6, 9, 11],
      'Venus': [6, 7, 12],
      'Saturn': [1, 2, 4, 7, 8, 9, 10, 11],
      'Lagna': [3, 4, 6, 10, 11, 12],
    },
    'Moon': {
      'Sun': [3, 6, 7, 8, 10, 11],
      'Moon': [1, 3, 6, 7, 10, 11],
      'Mars': [2, 3, 5, 6, 9, 10, 11],
      'Mercury': [1, 3, 4, 5, 7, 8, 10, 11],
      'Jupiter': [1, 4, 7, 8, 10, 11, 12],
      'Venus': [3, 4, 5, 7, 9, 10, 11],
      'Saturn': [3, 5, 6, 11],
      'Lagna': [3, 6, 10, 11],
    },
    'Mars': {
      'Sun': [3, 5, 6, 10, 11],
      'Moon': [3, 6, 11],
      'Mars': [1, 2, 4, 7, 8, 10, 11],
      'Mercury': [3, 5, 6, 11],
      'Jupiter': [6, 10, 11, 12],
      'Venus': [6, 8, 11, 12],
      'Saturn': [1, 4, 7, 8, 9, 10, 11],
      'Lagna': [1, 3, 6, 10, 11],
    },
    'Mercury': {
      'Sun': [5, 6, 9, 11, 12],
      'Moon': [2, 4, 6, 8, 10, 11],
      'Mars': [1, 2, 4, 7, 8, 9, 10, 11],
      'Mercury': [1, 3, 5, 6, 9, 10, 11, 12],
      'Jupiter': [6, 8, 11, 12],
      'Venus': [1, 2, 3, 4, 5, 8, 9, 11],
      'Saturn': [1, 2, 4, 7, 8, 9, 10, 11],
      'Lagna': [1, 2, 4, 6, 8, 10, 11],
    },
    'Jupiter': {
      'Sun': [1, 2, 3, 4, 7, 8, 9, 10, 11],
      'Moon': [2, 5, 7, 9, 11],
      'Mars': [1, 2, 4, 7, 8, 10, 11],
      'Mercury': [1, 2, 4, 5, 6, 9, 10, 11],
      'Jupiter': [1, 2, 3, 4, 7, 8, 10, 11],
      'Venus': [2, 5, 6, 9, 10, 11],
      'Saturn': [3, 5, 6, 12],
      'Lagna': [1, 2, 4, 5, 6, 7, 9, 10, 11],
    },
    'Venus': {
      'Sun': [8, 11, 12],
      'Moon': [1, 2, 3, 4, 5, 8, 9, 11, 12],
      'Mars': [3, 5, 6, 9, 11, 12],
      'Mercury': [3, 5, 6, 9, 11],
      'Jupiter': [5, 8, 9, 10, 11],
      'Venus': [1, 2, 3, 4, 5, 8, 9, 10, 11],
      'Saturn': [3, 4, 5, 8, 9, 10, 11],
      'Lagna': [1, 2, 3, 4, 5, 8, 9, 11],
    },
    'Saturn': {
      'Sun': [1, 2, 4, 7, 8, 10, 11],
      'Moon': [3, 6, 11],
      'Mars': [3, 5, 6, 10, 11, 12],
      'Mercury': [6, 8, 9, 10, 11, 12],
      'Jupiter': [5, 6, 11, 12],
      'Venus': [6, 11, 12],
      'Saturn': [3, 5, 6, 11],
      'Lagna': [1, 3, 4, 6, 10, 11],
    },
  };

  /// Calculate complete Ashtakavarga (BAV for 7 planets & SAV for 12 Rasis)
  static AshtakavargaResult calculateAshtakavarga(Map<String, PlanetDetail> planets) {
    final Map<String, List<int>> bav = {};
    final List<int> sav = List.filled(12, 0);

    final targetPlanets = ['Sun', 'Moon', 'Mars', 'Mercury', 'Jupiter', 'Venus', 'Saturn'];
    final referencePoints = ['Sun', 'Moon', 'Mars', 'Mercury', 'Jupiter', 'Venus', 'Saturn', 'Lagna'];

    for (final target in targetPlanets) {
      final List<int> planetBindus = List.filled(12, 0);
      final rules = _ashtakavargaRules[target]!;

      for (final ref in referencePoints) {
        final refRasi = planets[ref]?.rasiIndex ?? 0;
        final beneficHouses = rules[ref] ?? [];

        for (final house in beneficHouses) {
          final targetRasi = (refRasi + (house - 1)) % 12;
          planetBindus[targetRasi] += 1;
        }
      }

      bav[target] = planetBindus;

      // Add to Sarvashtakavarga totals
      for (int i = 0; i < 12; i++) {
        sav[i] += planetBindus[i];
      }
    }

    int totalSavPoints = sav.reduce((a, b) => a + b);

    return AshtakavargaResult(
      bhinnashtakavarga: bav,
      sarvashtakavarga: sav,
      totalSavPoints: totalSavPoints,
    );
  }
}
