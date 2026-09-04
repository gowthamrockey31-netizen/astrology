import '../models/planet_position.dart';

class Avastha {
  final String name;
  final String symbol;
  final String description;

  const Avastha({
    required this.name,
    required this.symbol,
    required this.description,
  });

  String get tag => '$symbol $name';

  @override
  String toString() => tag;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is Avastha) return name == other.name;
    if (other is String) return name == other || tag == other;
    return false;
  }

  @override
  int get hashCode => name.hashCode;
}

class AvasthaEngine {
  static List<Avastha> calculate({
    required PlanetPosition planet,
    required double sunLongitude,
  }) {
    final result = <Avastha>[];

    // வக்ரம்
    if (planet.retrograde) {
      result.add(
        const Avastha(
          name: 'வக்ரம்',
          symbol: '↺',
          description: 'கிரகம் வக்ர இயக்கத்தில் உள்ளது',
        ),
      );
    }

    // வர்கோத்தமம்
    if (planet.rasi == planet.navamsa) {
      result.add(
        const Avastha(
          name: 'வர்கோத்தமம்',
          symbol: '★',
          description: 'ராசி மற்றும் நவாம்சம் ஒரே ராசி',
        ),
      );
    }

    // அஸ்தமனம்
    if (_isCombust(
      planet.planet,
      planet.longitude,
      sunLongitude,
    )) {
      result.add(
        const Avastha(
          name: 'அஸ்தமனம்',
          symbol: '☀',
          description: 'சூரியனுக்கு அருகில் கிரகம் உள்ளது',
        ),
      );
    }

    return result;
  }

  static bool _isCombust(
    Planet planet,
    double planetLongitude,
    double sunLongitude,
  ) {
    const limits = {
      Planet.moon: 12.0,
      Planet.mars: 17.0,
      Planet.mercury: 14.0,
      Planet.jupiter: 11.0,
      Planet.venus: 10.0,
      Planet.saturn: 15.0,
    };

    final limit = limits[planet];

    if (limit == null) return false;

    var difference = (planetLongitude - sunLongitude).abs();

    if (difference > 180) {
      difference = 360 - difference;
    }

    return difference <= limit;
  }

  /// Public accessor for angular distance
  static double angularDistance(double a, double b) {
    var d = (a - b).abs();
    if (d > 180) {
      d = 360 - d;
    }
    return d;
  }

  /// Public accessor for combustion limit by Planet enum or String key
  static double? combustionLimit(dynamic planetOrKey) {
    const limits = {
      Planet.moon: 12.0,
      Planet.mars: 17.0,
      Planet.mercury: 14.0,
      Planet.jupiter: 11.0,
      Planet.venus: 10.0,
      Planet.saturn: 15.0,
    };

    if (planetOrKey is Planet) {
      return limits[planetOrKey];
    }
    if (planetOrKey is String) {
      final key = planetOrKey.toLowerCase().trim();
      for (final p in Planet.values) {
        if (p.name.toLowerCase() == key) {
          return limits[p];
        }
      }
    }
    return null;
  }

  /// Check if a planet is combust based on angular separation from Sun
  static bool isCombust(dynamic planetOrKey, double longitude, double sunLongitude) {
    final limit = combustionLimit(planetOrKey);
    if (limit == null) return false;
    return angularDistance(longitude, sunLongitude) <= limit;
  }
}
