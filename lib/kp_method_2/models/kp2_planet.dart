/// The 9 Classical Planets utilized in KP Method 2
enum KP2Planet {
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
      case KP2Planet.sun:
        return 'Sun';
      case KP2Planet.moon:
        return 'Moon';
      case KP2Planet.mars:
        return 'Mars';
      case KP2Planet.mercury:
        return 'Mercury';
      case KP2Planet.jupiter:
        return 'Jupiter';
      case KP2Planet.venus:
        return 'Venus';
      case KP2Planet.saturn:
        return 'Saturn';
      case KP2Planet.rahu:
        return 'Rahu';
      case KP2Planet.ketu:
        return 'Ketu';
    }
  }

  String get nameTa {
    switch (this) {
      case KP2Planet.sun:
        return 'சூரியன்';
      case KP2Planet.moon:
        return 'சந்திரன்';
      case KP2Planet.mars:
        return 'செவ்வாய்';
      case KP2Planet.mercury:
        return 'புதன்';
      case KP2Planet.jupiter:
        return 'குரு';
      case KP2Planet.venus:
        return 'சுக்கிரன்';
      case KP2Planet.saturn:
        return 'சனி';
      case KP2Planet.rahu:
        return 'ராகு';
      case KP2Planet.ketu:
        return 'கேது';
    }
  }

  String get symbol {
    switch (this) {
      case KP2Planet.sun:
        return 'சூ';
      case KP2Planet.moon:
        return 'சந்';
      case KP2Planet.mars:
        return 'செவ்';
      case KP2Planet.mercury:
        return 'பு';
      case KP2Planet.jupiter:
        return 'குரு';
      case KP2Planet.venus:
        return 'சுக்';
      case KP2Planet.saturn:
        return 'சனி';
      case KP2Planet.rahu:
        return 'ரா';
      case KP2Planet.ketu:
        return 'கே';
    }
  }

  int get dashaYears {
    switch (this) {
      case KP2Planet.ketu:
        return 7;
      case KP2Planet.venus:
        return 20;
      case KP2Planet.sun:
        return 6;
      case KP2Planet.moon:
        return 10;
      case KP2Planet.mars:
        return 7;
      case KP2Planet.rahu:
        return 18;
      case KP2Planet.jupiter:
        return 16;
      case KP2Planet.saturn:
        return 19;
      case KP2Planet.mercury:
        return 17;
    }
  }

  static KP2Planet fromName(String name) {
    final lower = name.toLowerCase().trim();
    for (final p in KP2Planet.values) {
      if (p.nameEn.toLowerCase() == lower ||
          p.nameTa == name ||
          p.symbol == name ||
          p.name == lower) {
        return p;
      }
    }
    return KP2Planet.sun;
  }
}
