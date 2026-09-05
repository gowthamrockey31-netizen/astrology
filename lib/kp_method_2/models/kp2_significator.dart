import 'kp2_planet.dart';

/// Planet Significator row in KP Method 2 (கிரக தொடர்புகள்)
class KP2PlanetSignificator {
  final KP2Planet planet;
  final int occupiedHouse;
  final KP2Planet starLord;
  final List<int> starLordHouses;
  final KP2Planet subLord;
  final List<int> subLordHouses;
  final KP2Planet subSubLord;
  final List<int> subSubLordHouses;

  const KP2PlanetSignificator({
    required this.planet,
    required this.occupiedHouse,
    required this.starLord,
    required this.starLordHouses,
    required this.subLord,
    required this.subLordHouses,
    required this.subSubLord,
    required this.subSubLordHouses,
  });
}

/// House Significator row in KP Method 2 (பாவ தொடர்புகள் & Advantage Houses)
class KP2HouseSignificator {
  final int house;
  final KP2Planet cuspSubLord;
  final List<int> subLordHouses;
  final KP2Planet starLord;
  final List<int> starLordHouses;
  final KP2Planet subSubLord;
  final List<int> subSubLordHouses;
  final List<int> advantageHouses;

  const KP2HouseSignificator({
    required this.house,
    required this.cuspSubLord,
    required this.subLordHouses,
    required this.starLord,
    required this.starLordHouses,
    required this.subSubLord,
    required this.subSubLordHouses,
    required this.advantageHouses,
  });
}
