import 'kp2_planet.dart';

/// KP Method 2 Ruling Planets (ஆளும் கிரகங்கள்)
/// Contains 5 Transit Ascendant and 5 Transit Moon Ruling Planet levels (Total 10 positions) + Day Lord
class KP2RulingPlanets {
  final KP2Planet dayLord;

  // Transit Ascendant — Five Ruling Planets
  final KP2Planet ascSignLord;
  final KP2Planet ascStarLord;
  final KP2Planet ascSubLord;
  final KP2Planet ascSubSubLord;
  final KP2Planet ascSubSubSubLord;

  // Transit Moon — Five Ruling Planets
  final KP2Planet moonSignLord;
  final KP2Planet moonStarLord;
  final KP2Planet moonSubLord;
  final KP2Planet moonSubSubLord;
  final KP2Planet moonSubSubSubLord;

  const KP2RulingPlanets({
    required this.dayLord,
    required this.ascSignLord,
    required this.ascStarLord,
    required this.ascSubLord,
    required this.ascSubSubLord,
    required this.ascSubSubSubLord,
    required this.moonSignLord,
    required this.moonStarLord,
    required this.moonSubLord,
    required this.moonSubSubLord,
    required this.moonSubSubSubLord,
  });

  /// 5 Transit Ascendant Ruling Planets
  List<KP2Planet> get ascendantRulingPlanets => [
        ascSignLord,
        ascStarLord,
        ascSubLord,
        ascSubSubLord,
        ascSubSubSubLord,
      ];

  /// 5 Transit Moon Ruling Planets
  List<KP2Planet> get moonRulingPlanets => [
        moonSignLord,
        moonStarLord,
        moonSubLord,
        moonSubSubLord,
        moonSubSubSubLord,
      ];

  /// All 10 Transit Ruling Planets in order
  List<KP2Planet> get tenRulingPlanets => [
        ascSignLord,
        ascStarLord,
        ascSubLord,
        ascSubSubLord,
        ascSubSubSubLord,
        moonSignLord,
        moonStarLord,
        moonSubLord,
        moonSubSubLord,
        moonSubSubSubLord,
      ];

  List<KP2Planet> get allPlanets => [
        dayLord,
        ...tenRulingPlanets,
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
