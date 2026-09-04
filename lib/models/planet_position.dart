/// Planetary enum for Avastha, Combustion, and Dignity calculations
enum Planet {
  sun,
  moon,
  mars,
  mercury,
  jupiter,
  venus,
  saturn,
  rahu,
  ketu,
  mandi,
  lagna,
}

/// 12 Zodiac Rasis (Mesham = 0 ... Meenam = 11)
enum Rasi {
  mesham,
  rishabam,
  mithunam,
  kadagam,
  simmam,
  kanni,
  thulam,
  viruchigam,
  dhanusu,
  magaram,
  kumbam,
  meenam,
}

/// Planet position model representing celestial coordinates, retrograde status, and rasi index
class PlanetPosition {
  final Planet planet;
  final double longitude;
  final bool retrograde;
  final int? _rasiIndex;
  final int? _navamsaIndex;

  const PlanetPosition({
    required this.planet,
    required this.longitude,
    this.retrograde = false,
    int? rasiIndex,
    int? navamsaIndex,
  })  : _rasiIndex = rasiIndex,
        _navamsaIndex = navamsaIndex;

  /// Zodiac Rasi Index (0: Mesham ... 11: Meenam)
  int get rasiIndex => _rasiIndex ?? ((longitude / 30.0) >= 0 ? (longitude / 30.0).floor() % 12 : 0);

  /// Rasi Enum (0..11) for Dignity and Avastha calculation
  Rasi get rasi => Rasi.values[rasiIndex.clamp(0, 11)];

  /// Navamsha D9 Rasi Index (0: Mesham ... 11: Meenam)
  int get navamsaIndex {
    final nav = _navamsaIndex;
    if (nav != null) return nav;
    final normLong = (longitude % 360.0 + 360.0) % 360.0;
    final rIdx = (normLong / 30.0).floor() % 12;
    final degInRasi = normLong - (rIdx * 30.0);
    final navPart = (degInRasi / (30.0 / 9.0)).floor().clamp(0, 8);
    final startRasi = (rIdx % 4) * 9 % 12;
    return (startRasi + navPart) % 12;
  }

  /// Navamsha Rasi Enum (0..11) for Dignity and Avastha calculation
  Rasi get navamsa => Rasi.values[navamsaIndex.clamp(0, 11)];

  /// Factory helper to build from a string key (e.g. 'Sun', 'Venus') and longitude
  factory PlanetPosition.fromKey(
    String key,
    double longitude, {
    bool isRetrograde = false,
    int? rasiIndex,
    int? navamsaIndex,
  }) {
    final lower = key.toLowerCase().trim();
    Planet matched = Planet.sun;
    for (final p in Planet.values) {
      if (p.name.toLowerCase() == lower) {
        matched = p;
        break;
      }
    }
    return PlanetPosition(
      planet: matched,
      longitude: longitude,
      retrograde: isRetrograde,
      rasiIndex: rasiIndex ?? ((longitude / 30.0) >= 0 ? (longitude / 30.0).floor() % 12 : 0),
      navamsaIndex: navamsaIndex,
    );
  }
}
