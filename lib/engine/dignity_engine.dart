import '../models/planet_position.dart';

class DignityResult {
  final String title;
  final String symbol;
  final String explanation;

  const DignityResult({
    required this.title,
    required this.symbol,
    required this.explanation,
  });

  /// Alias for backward compatibility with existing usages
  String get name => title;

  String get formatted => '$symbol $title';
}

class DignityEngine {
  static const Map<Planet, Rasi> exaltation = {
    Planet.sun: Rasi.mesham,
    Planet.moon: Rasi.rishabam,
    Planet.mars: Rasi.magaram,
    Planet.mercury: Rasi.kanni,
    Planet.jupiter: Rasi.kadagam,
    Planet.venus: Rasi.meenam,
    Planet.saturn: Rasi.thulam,
  };

  static const Map<Planet, Rasi> debilitation = {
    Planet.sun: Rasi.thulam,
    Planet.moon: Rasi.viruchigam,
    Planet.mars: Rasi.kadagam,
    Planet.mercury: Rasi.meenam,
    Planet.jupiter: Rasi.magaram,
    Planet.venus: Rasi.kanni,
    Planet.saturn: Rasi.mesham,
  };

  static DignityResult? calculate(PlanetPosition p) {
    if (exaltation[p.planet] == p.rasi) {
      return const DignityResult(
        title: 'உச்சம்',
        symbol: '↑',
        explanation: 'கிரகம் உச்ச ராசியில் உள்ளது',
      );
    }

    if (debilitation[p.planet] == p.rasi) {
      return const DignityResult(
        title: 'நீசம்',
        symbol: '↓',
        explanation: 'கிரகம் நீச ராசியில் உள்ளது',
      );
    }

    return null;
  }

  /// Alias for calculate for backward compatibility
  static DignityResult? get(PlanetPosition planet) => calculate(planet);

  /// Convenience method to evaluate dignity directly from string key and rasi index
  static DignityResult? getFromKey(
    String key,
    int rasiIndex, {
    double longitude = 0.0,
    bool isRetrograde = false,
  }) {
    final pos = PlanetPosition.fromKey(
      key,
      longitude,
      isRetrograde: isRetrograde,
      rasiIndex: rasiIndex,
    );
    return calculate(pos);
  }
}
