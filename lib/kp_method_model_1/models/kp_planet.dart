/// The 9 Classical Planets utilized in Krishnamurti Padhdhati (KP) Astrology
enum KPPlanet {
  sun,
  moon,
  mars,
  mercury,
  jupiter,
  venus,
  saturn,
  rahu,
  ketu;

  String get nameEn {
    switch (this) {
      case KPPlanet.sun:
        return 'Sun';
      case KPPlanet.moon:
        return 'Moon';
      case KPPlanet.mars:
        return 'Mars';
      case KPPlanet.mercury:
        return 'Mercury';
      case KPPlanet.jupiter:
        return 'Jupiter';
      case KPPlanet.venus:
        return 'Venus';
      case KPPlanet.saturn:
        return 'Saturn';
      case KPPlanet.rahu:
        return 'Rahu';
      case KPPlanet.ketu:
        return 'Ketu';
    }
  }

  String get nameTa {
    switch (this) {
      case KPPlanet.sun:
        return 'சூரியன்';
      case KPPlanet.moon:
        return 'சந்திரன்';
      case KPPlanet.mars:
        return 'செவ்வாய்';
      case KPPlanet.mercury:
        return 'புதன்';
      case KPPlanet.jupiter:
        return 'குரு';
      case KPPlanet.venus:
        return 'சுக்கிரன்';
      case KPPlanet.saturn:
        return 'சனி';
      case KPPlanet.rahu:
        return 'ராகு';
      case KPPlanet.ketu:
        return 'கேது';
    }
  }

  String get symbol {
    switch (this) {
      case KPPlanet.sun:
        return '☉';
      case KPPlanet.moon:
        return '☽';
      case KPPlanet.mars:
        return '♂';
      case KPPlanet.mercury:
        return '☿';
      case KPPlanet.jupiter:
        return '♃';
      case KPPlanet.venus:
        return '♀';
      case KPPlanet.saturn:
        return '♄';
      case KPPlanet.rahu:
        return '☊';
      case KPPlanet.ketu:
        return '☋';
    }
  }

  static KPPlanet? fromString(String name) {
    final clean = name.trim().toLowerCase();
    for (final p in KPPlanet.values) {
      if (p.nameEn.toLowerCase() == clean || p.nameTa == name.trim()) {
        return p;
      }
    }
    return null;
  }
}
