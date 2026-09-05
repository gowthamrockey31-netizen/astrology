import 'kp2_planet.dart';

/// KP Method 2 Ruling Planets (ஆளும் கிரகங்கள்)
class KP2RulingPlanets {
  final KP2Planet dayLord;
  final KP2Planet moonSignLord;
  final KP2Planet moonStarLord;
  final KP2Planet moonSubLord;
  final KP2Planet ascSignLord;
  final KP2Planet ascStarLord;
  final KP2Planet ascSubLord;

  const KP2RulingPlanets({
    required this.dayLord,
    required this.moonSignLord,
    required this.moonStarLord,
    required this.moonSubLord,
    required this.ascSignLord,
    required this.ascStarLord,
    required this.ascSubLord,
  });

  List<KP2Planet> get allPlanets => [
        dayLord,
        moonSignLord,
        moonStarLord,
        moonSubLord,
        ascSignLord,
        ascStarLord,
        ascSubLord,
      ];

  /// Deduplicated ordered list of distinct Ruling Planets
  List<KP2Planet> get uniqueRulingPlanets {
    final seen = <KP2Planet>{};
    final result = <KP2Planet>[];
    for (final p in allPlanets) {
      if (seen.add(p)) {
        result.add(p);
      }
    }
    return result;
  }

  List<KP2Planet> get uniquePlanets => uniqueRulingPlanets;
}
