import 'package:flutter_test/flutter_test.dart';
import 'package:astrocall/engine/avastha_engine.dart';
import 'package:astrocall/models/planet_position.dart';

void main() {
  group('AvasthaEngine & Combustion (அஸ்தமனம்) Tests', () {
    test('Angular distance calculation across 0/360 boundary', () {
      // 5 degrees and 355 degrees -> 10 degrees separation
      expect(AvasthaEngine.angularDistance(5.0, 355.0), 10.0);
      expect(AvasthaEngine.angularDistance(355.0, 5.0), 10.0);
      expect(AvasthaEngine.angularDistance(100.0, 100.0), 0.0);
      expect(AvasthaEngine.angularDistance(10.0, 190.0), 180.0);
      expect(AvasthaEngine.angularDistance(10.0, 200.0), 170.0);
    });

    test('Combustion degree limits for all classical planets', () {
      // User-defined combustion limits:
      // Moon: 12°
      // Mars: 17°
      // Mercury: 14°
      // Jupiter: 11°
      // Venus: 10°
      // Saturn: 15°
      expect(AvasthaEngine.combustionLimit(Planet.moon), 12.0);
      expect(AvasthaEngine.combustionLimit(Planet.mars), 17.0);
      expect(AvasthaEngine.combustionLimit(Planet.mercury), 14.0);
      expect(AvasthaEngine.combustionLimit(Planet.jupiter), 11.0);
      expect(AvasthaEngine.combustionLimit(Planet.venus), 10.0);
      expect(AvasthaEngine.combustionLimit(Planet.saturn), 15.0);

      // Non-combustible entities
      expect(AvasthaEngine.combustionLimit(Planet.sun), isNull);
      expect(AvasthaEngine.combustionLimit(Planet.rahu), isNull);
      expect(AvasthaEngine.combustionLimit(Planet.ketu), isNull);
      expect(AvasthaEngine.combustionLimit(Planet.mandi), isNull);
      expect(AvasthaEngine.combustionLimit(Planet.lagna), isNull);

      // String key lookup support
      expect(AvasthaEngine.combustionLimit('Moon'), 12.0);
      expect(AvasthaEngine.combustionLimit('Mars'), 17.0);
      expect(AvasthaEngine.combustionLimit('Venus'), 10.0);
      expect(AvasthaEngine.combustionLimit('Saturn'), 15.0);
    });

    test('Moon combustion within 12 degrees', () {
      const sunLong = 120.0;

      // Within limit (11.5 deg) -> Combust
      final moonCombust = PlanetPosition(planet: Planet.moon, longitude: 131.5);
      final tags1 = AvasthaEngine.calculate(planet: moonCombust, sunLongitude: sunLong);
      expect(tags1.any((a) => a.name == 'அஸ்தமனம்'), isTrue);

      // Exactly at limit (12.0 deg) -> Combust
      final moonEdge = PlanetPosition(planet: Planet.moon, longitude: 132.0);
      final tags2 = AvasthaEngine.calculate(planet: moonEdge, sunLongitude: sunLong);
      expect(tags2.any((a) => a.name == 'அஸ்தமனம்'), isTrue);

      // Beyond limit (12.1 deg) -> Not combust
      final moonSafe = PlanetPosition(planet: Planet.moon, longitude: 132.1);
      final tags3 = AvasthaEngine.calculate(planet: moonSafe, sunLongitude: sunLong);
      expect(tags3.any((a) => a.name == 'அஸ்தமனம்'), isFalse);
    });

    test('Venus combustion within 10 degrees and retrograde handling', () {
      const sunLong = 100.0;

      // Venus at 108.0 deg (8 deg diff) + retrograde -> Combust & Retrograde tags
      final venusCombust = PlanetPosition(
        planet: Planet.venus,
        longitude: 108.0,
        retrograde: true,
      );
      final tags = AvasthaEngine.calculate(planet: venusCombust, sunLongitude: sunLong);
      expect(tags.any((a) => a.name == 'வக்ரம்'), isTrue);
      expect(tags.any((a) => a.name == 'அஸ்தமனம்'), isTrue);

      // Venus at 111.0 deg (11 deg diff) -> Not combust
      final venusSafe = PlanetPosition(
        planet: Planet.venus,
        longitude: 111.0,
        retrograde: false,
      );
      final safeTags = AvasthaEngine.calculate(planet: venusSafe, sunLongitude: sunLong);
      expect(safeTags.any((a) => a.name == 'அஸ்தமனம்'), isFalse);
    });

    test('Saturn combustion within 15 degrees and Mars within 17 degrees', () {
      const sunLong = 50.0;

      final saturnCombust = PlanetPosition(planet: Planet.saturn, longitude: 64.0); // diff = 14° <= 15°
      expect(AvasthaEngine.calculate(planet: saturnCombust, sunLongitude: sunLong).any((a) => a.name == 'அஸ்தமனம்'), isTrue);

      final saturnSafe = PlanetPosition(planet: Planet.saturn, longitude: 66.0); // diff = 16° > 15°
      expect(AvasthaEngine.calculate(planet: saturnSafe, sunLongitude: sunLong).any((a) => a.name == 'அஸ்தமனம்'), isFalse);

      final marsCombust = PlanetPosition(planet: Planet.mars, longitude: 34.0); // diff = 16° <= 17°
      expect(AvasthaEngine.calculate(planet: marsCombust, sunLongitude: sunLong).any((a) => a.name == 'அஸ்தமனம்'), isTrue);

      final marsSafe = PlanetPosition(planet: Planet.mars, longitude: 32.0); // diff = 18° > 17°
      expect(AvasthaEngine.calculate(planet: marsSafe, sunLongitude: sunLong).any((a) => a.name == 'அஸ்தமனம்'), isFalse);
    });

    test('Vargottamam (வர்கோத்தமம்) when rasi == navamsa', () {
      const sunLong = 180.0;

      // Movable sign (Mesham = 0): 0° to 3°20' has Navamsa = 0 (Mesham) -> Vargottamam
      final vargottamaPlanet = PlanetPosition(
        planet: Planet.jupiter,
        longitude: 2.0, // rasi = 0, navamsa = 0
        rasiIndex: 0,
        navamsaIndex: 0,
      );
      final avasthas = AvasthaEngine.calculate(planet: vargottamaPlanet, sunLongitude: sunLong);
      expect(avasthas.any((a) => a.name == 'வர்கோத்தமம்'), isTrue);
      expect(avasthas.firstWhere((a) => a.name == 'வர்கோத்தமம்').symbol, '★');

      // Non-vargottama planet: rasi 0, navamsa 1
      final nonVargottama = PlanetPosition(
        planet: Planet.jupiter,
        longitude: 5.0,
        rasiIndex: 0,
        navamsaIndex: 1,
      );
      final nonVargAvasthas = AvasthaEngine.calculate(planet: nonVargottama, sunLongitude: sunLong);
      expect(nonVargAvasthas.any((a) => a.name == 'வர்கோத்தமம்'), isFalse);
    });

    test('PlanetPosition.fromKey maps correctly and supports navamsaIndex', () {
      final p1 = PlanetPosition.fromKey('Venus', 105.0, isRetrograde: true, rasiIndex: 3, navamsaIndex: 3);
      expect(p1.planet, Planet.venus);
      expect(p1.longitude, 105.0);
      expect(p1.retrograde, isTrue);
      expect(p1.rasi, Rasi.kadagam);
      expect(p1.navamsa, Rasi.kadagam);
      expect(p1.rasiIndex, 3);
      expect(p1.navamsaIndex, 3);

      final p2 = PlanetPosition.fromKey('Jupiter', 240.0);
      expect(p2.planet, Planet.jupiter);
      expect(p2.longitude, 240.0);
      expect(p2.retrograde, isFalse);
    });
  });
}
