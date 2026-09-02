/// Model representing the Ruling Planets in KP Astrology
class KPRulingPlanets {
  final String dayLord;
  final String moonSignLord;
  final String moonStarLord;
  final String moonSubLord;
  final String ascendantSignLord;
  final String ascendantStarLord;
  final String ascendantSubLord;
  final List<String> uniqueRulingPlanets;

  const KPRulingPlanets({
    required this.dayLord,
    required this.moonSignLord,
    required this.moonStarLord,
    required this.moonSubLord,
    required this.ascendantSignLord,
    required this.ascendantStarLord,
    required this.ascendantSubLord,
    required this.uniqueRulingPlanets,
  });

  factory KPRulingPlanets.empty() {
    return const KPRulingPlanets(
      dayLord: '---',
      moonSignLord: '---',
      moonStarLord: '---',
      moonSubLord: '---',
      ascendantSignLord: '---',
      ascendantStarLord: '---',
      ascendantSubLord: '---',
      uniqueRulingPlanets: [],
    );
  }
}
