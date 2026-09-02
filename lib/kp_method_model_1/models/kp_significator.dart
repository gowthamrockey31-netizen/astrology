/// Model representing Planet-level Significators in KP Method Model 1
class KPPlanetSignificator {
  final String planet;
  final List<int> planetHouses;
  final String starLord;
  final List<int> starLordHouses;
  final String subLord;
  final List<int> subLordHouses;
  final List<int> advantageHouses;

  const KPPlanetSignificator({
    required this.planet,
    required this.planetHouses,
    required this.starLord,
    required this.starLordHouses,
    required this.subLord,
    required this.subLordHouses,
    required this.advantageHouses,
  });
}

/// Model representing House-level Significators in KP Method Model 1
class KPHouseSignificator {
  final int houseNumber;
  final String cuspSubLord;
  final List<int> cuspSubLordHouses;
  final String starLord;
  final List<int> starLordHouses;
  final String subLord;
  final List<int> subLordHouses;
  final List<int> finalAdvantageHouses;

  const KPHouseSignificator({
    required this.houseNumber,
    required this.cuspSubLord,
    required this.cuspSubLordHouses,
    required this.starLord,
    required this.starLordHouses,
    required this.subLord,
    required this.subLordHouses,
    required this.finalAdvantageHouses,
  });
}
