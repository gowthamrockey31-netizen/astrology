import 'package:flutter_test/flutter_test.dart';
import 'package:astrocall/modules/bnn_method_2/bnn_method_2.dart';

void main() {
  group('BNN Method 2 Unit Tests', () {
    test('1. directionOrder strictly matches [1, 5, 9, 3, 11, 7, 2, 12]', () {
      expect(
        BNNMethod2Engine.directionOrder,
        equals([1, 5, 9, 3, 11, 7, 2, 12]),
      );
      expect(BNNMethod2Engine.directionOrder.length, 8);
    });

    test('2. Relative house calculation ((target - source) % 12) + 1', () {
      expect(BNNMethod2Engine.calculateRelativeHouse(1, 1), 1);
      expect(BNNMethod2Engine.calculateRelativeHouse(1, 5), 5);
      expect(BNNMethod2Engine.calculateRelativeHouse(1, 9), 9);
      expect(BNNMethod2Engine.calculateRelativeHouse(1, 3), 3);
      expect(BNNMethod2Engine.calculateRelativeHouse(1, 11), 11);
      expect(BNNMethod2Engine.calculateRelativeHouse(1, 7), 7);
      expect(BNNMethod2Engine.calculateRelativeHouse(1, 2), 2);
      expect(BNNMethod2Engine.calculateRelativeHouse(1, 12), 12);

      // Circular wrap around
      expect(BNNMethod2Engine.calculateRelativeHouse(12, 1), 2);
      expect(BNNMethod2Engine.calculateRelativeHouse(10, 2), 5);
      expect(BNNMethod2Engine.calculateRelativeHouse(5, 1), 9);
      expect(BNNMethod2Engine.calculateRelativeHouse(12, 11), 12);
    });

    test('3. Direction filtering only allows houses in directionOrder', () {
      // Valid: 1, 5, 9, 3, 11, 7, 2, 12
      for (final h in [1, 5, 9, 3, 11, 7, 2, 12]) {
        expect(BNNMethod2Engine.isValidDirection(h), isTrue);
      }
      // Invalid (4, 6, 8, 10)
      for (final h in [4, 6, 8, 10]) {
        expect(BNNMethod2Engine.isValidDirection(h), isFalse);
      }
    });

    test('4. Connection sorting: first by directionOrder index, then by target degree', () {
      final source = const BNNMethod2PlanetPosition(
        planetKey: 'Jupiter',
        tamilName: 'குரு',
        englishName: 'Jupiter',
        sign: 1,
        signNameTa: 'மேஷம்',
        signNameEn: 'Aries',
        house: 1,
        degreeInSign: 10.0,
        absoluteLongitude: 10.0,
        degree: 10,
        minute: 0,
        second: 0,
      );

      // Create target planets in different directions and degrees
      final pMars = const BNNMethod2PlanetPosition(
        planetKey: 'Mars',
        tamilName: 'செவ்வாய்',
        englishName: 'Mars',
        sign: 5,
        signNameTa: 'சிம்மம்',
        signNameEn: 'Leo',
        house: 5, // Rel house 5 (Index 1)
        degreeInSign: 18.0,
        absoluteLongitude: 138.0,
        degree: 18,
        minute: 0,
        second: 0,
      );

      final pSun = const BNNMethod2PlanetPosition(
        planetKey: 'Sun',
        tamilName: 'சூரியன்',
        englishName: 'Sun',
        sign: 5,
        signNameTa: 'சிம்மம்',
        signNameEn: 'Leo',
        house: 5, // Rel house 5 (Index 1)
        degreeInSign: 12.0, // Smaller degree than Mars in house 5
        absoluteLongitude: 132.0,
        degree: 12,
        minute: 0,
        second: 0,
      );

      final pMoon = const BNNMethod2PlanetPosition(
        planetKey: 'Moon',
        tamilName: 'சந்திரன்',
        englishName: 'Moon',
        sign: 1,
        signNameTa: 'மேஷம்',
        signNameEn: 'Aries',
        house: 1, // Rel house 1 (Index 0)
        degreeInSign: 25.0,
        absoluteLongitude: 25.0,
        degree: 25,
        minute: 0,
        second: 0,
      );

      final pSaturn = const BNNMethod2PlanetPosition(
        planetKey: 'Saturn',
        tamilName: 'சனி',
        englishName: 'Saturn',
        sign: 7,
        signNameTa: 'துலாம்',
        signNameEn: 'Libra',
        house: 7, // Rel house 7 (Index 5)
        degreeInSign: 5.0,
        absoluteLongitude: 185.0,
        degree: 5,
        minute: 0,
        second: 0,
      );

      final targets = [pMars, pSaturn, pMoon, pSun];
      final conns = BNNMethod2Engine.calculateConnections(
        sourcePlanet: source,
        allPlanets: targets,
      );

      // Order should be:
      // 1. Moon (rel house 1, directionOrder index 0)
      // 2. Sun (rel house 5, directionOrder index 1, deg 12.0)
      // 3. Mars (rel house 5, directionOrder index 1, deg 18.0)
      // 4. Saturn (rel house 7, directionOrder index 5, deg 5.0)
      expect(conns.length, 4);
      expect(conns[0].targetPlanet.planetKey, 'Moon');
      expect(conns[1].targetPlanet.planetKey, 'Sun');
      expect(conns[2].targetPlanet.planetKey, 'Mars');
      expect(conns[3].targetPlanet.planetKey, 'Saturn');
    });

    test('5. Planet Karakas has exactly 10 items for each planet', () {
      const planets = [
        'Sun',
        'Moon',
        'Mars',
        'Mercury',
        'Jupiter',
        'Venus',
        'Saturn',
        'Rahu',
        'Ketu',
      ];
      for (final p in planets) {
        final karakas = BNNMethod2PlanetKaraka.get(p);
        expect(karakas.length, 10, reason: '$p must have exactly 10 karakas');
      }
    });

    test('6. Disease Karakas has exactly 5 items for each planet', () {
      const planets = [
        'Sun',
        'Moon',
        'Mars',
        'Mercury',
        'Jupiter',
        'Venus',
        'Saturn',
        'Rahu',
        'Ketu',
      ];
      for (final p in planets) {
        final diseases = BNNMethod2DiseaseKaraka.get(p);
        expect(diseases.length, 5, reason: '$p must have exactly 5 disease karakas');
      }
    });

    test('7. House Karakas has exactly 10 items for each of the 12 houses', () {
      for (int h = 1; h <= 12; h++) {
        final houseKarakas = BNNMethod2HouseKaraka.get(h);
        expect(houseKarakas.length, 10, reason: 'House $h must have exactly 10 karakas');
      }
    });

    test('8. Planet Relation Table accurately evaluates Friend, Enemy, Neutral', () {
      // Sun -> Moon (Friend), Venus (Enemy), Mercury (Neutral)
      expect(
        BNNMethod2PlanetRelationTable.getRelation('Sun', 'Moon'),
        BNNMethod2RelationType.friend,
      );
      expect(
        BNNMethod2PlanetRelationTable.getRelation('Sun', 'Venus'),
        BNNMethod2RelationType.enemy,
      );
      expect(
        BNNMethod2PlanetRelationTable.getRelation('Sun', 'Mercury'),
        BNNMethod2RelationType.neutral,
      );

      // Jupiter -> Mars (Friend), Mercury (Enemy), Saturn (Neutral)
      expect(
        BNNMethod2PlanetRelationTable.getRelation('Jupiter', 'Mars'),
        BNNMethod2RelationType.friend,
      );
      expect(
        BNNMethod2PlanetRelationTable.getRelation('Jupiter', 'Mercury'),
        BNNMethod2RelationType.enemy,
      );
      expect(
        BNNMethod2PlanetRelationTable.getRelation('Jupiter', 'Saturn'),
        BNNMethod2RelationType.neutral,
      );
    });
  });
}
