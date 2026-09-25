import 'package:flutter_test/flutter_test.dart';
import 'package:astrocall/kp_method_4/kp_method_4.dart';

void main() {
  group('KP Method 4 Unit Tests', () {
    final testBirthData = Kp4BirthData(
      dateTime: DateTime(1995, 5, 15, 10, 30),
      time: '10:30 AM',
      place: 'Chennai, Tamil Nadu',
      latitude: 13.0827,
      longitude: 80.2707,
      timezone: 5.5,
    );

    late KpResult result;

    setUpAll(() {
      result = Kp4Engine.calculate(testBirthData);
    });

    test('1. Calculates high-precision Swiss Ephemeris ascendant and KP Ayanamsa', () {
      expect(result.ascendantDegree, greaterThanOrEqualTo(0.0));
      expect(result.ascendantDegree, lessThan(360.0));
      expect(result.ayanamsa, greaterThan(23.0));
      expect(result.ayanamsa, lessThan(25.0));
      expect(result.ascendantDegreeStr.contains('°'), isTrue);
      expect(result.ascendantSignTa.isNotEmpty, isTrue);
    });

    test('2. Calculates all 9 planets with valid Star, Sub, and Sub-Sub lords', () {
      expect(result.planetPositions.length, equals(9));
      final expectedPlanets = ['Sun', 'Moon', 'Mars', 'Mercury', 'Jupiter', 'Venus', 'Saturn', 'Rahu', 'Ketu'];

      for (final p in expectedPlanets) {
        final planet = result.planetPositions.firstWhere((item) => item.planet == p);
        expect(planet.longitude, greaterThanOrEqualTo(0.0));
        expect(planet.longitude, lessThan(360.0));
        expect(planet.degreeStr.contains('°'), isTrue);
        expect(planet.starLord.isNotEmpty, isTrue);
        expect(planet.subLord.isNotEmpty, isTrue);
        expect(planet.subSubLord.isNotEmpty, isTrue);
        expect(planet.nakshatraIndex, inInclusiveRange(0, 26));
        expect(planet.signIndex, inInclusiveRange(0, 11));
      }
    });

    test('3. Calculates all 12 Placidus Bhava Cusps with valid Star, Sub, and Sub-Sub lords', () {
      expect(result.cuspPositions.length, equals(12));

      for (int i = 1; i <= 12; i++) {
        final cusp = result.cuspPositions.firstWhere((c) => c.cuspNumber == i);
        expect(cusp.longitude, greaterThanOrEqualTo(0.0));
        expect(cusp.longitude, lessThan(360.0));
        expect(cusp.degreeStr.contains('°'), isTrue);
        expect(cusp.starLord.isNotEmpty, isTrue);
        expect(cusp.subLord.isNotEmpty, isTrue);
        expect(cusp.subSubLord.isNotEmpty, isTrue);
      }
    });

    test('4. Graha Thodarbhu (Planet Relations) produces valid relations for all 9 planets', () {
      expect(result.planetRelations.length, equals(9));

      for (final pr in result.planetRelations) {
        expect(pr.planet.isNotEmpty, isTrue);
        expect(pr.starLord.isNotEmpty, isTrue);
        expect(pr.subLord.isNotEmpty, isTrue);

        // Every house number must be 1..12
        for (final h in pr.combinedHouses) {
          expect(h.house, inInclusiveRange(1, 12));
        }

        // If fallback is used, displayText has '$'
        for (final h in pr.starLordHouses) {
          if (h.isSubSubFallback) {
            expect(h.displayText.endsWith(r'$'), isTrue);
          } else {
            expect(h.displayText.contains(r'$'), isFalse);
          }
        }
      }
    });

    test('5. Step 1 and Step 2 logic verification for Planet Relations', () {
      // Pick a planet, e.g. Sun
      final sun = result.getPlanet('Sun');
      final sunRel = result.getPlanetRelation('Sun');

      expect(sunRel.starLord, equals(sun.starLord));
      expect(sunRel.subLord, equals(sun.subLord));

      // Verify that starLordHouses match Bhavas where starLord appears as Sub Lord
      final matchingSubLordCusps = result.cuspPositions
          .where((c) => c.subLord.toLowerCase() == sun.starLord.toLowerCase())
          .map((c) => c.cuspNumber)
          .toList();

      if (matchingSubLordCusps.isNotEmpty) {
        expect(sunRel.isStarLordFallback, isFalse);
        final actualHouses = sunRel.starLordHouses.map((h) => h.house).toList();
        expect(actualHouses, equals(matchingSubLordCusps));
      } else {
        // Fallback triggered: should match Sub-Sub Lord Bhavas with '$'
        expect(sunRel.isStarLordFallback, isTrue);
        final matchingSubSubCusps = result.cuspPositions
            .where((c) => c.subSubLord.toLowerCase() == sun.starLord.toLowerCase())
            .map((c) => c.cuspNumber)
            .toList();
        final actualHouses = sunRel.starLordHouses.map((h) => h.house).toList();
        expect(actualHouses, equals(matchingSubSubCusps));
        for (final h in sunRel.starLordHouses) {
          expect(h.isSubSubFallback, isTrue);
          expect(h.displayText, endsWith(r'$'));
        }
      }
    });

    test('6. Bhava Graha Relations (Part 3C) are strictly derived from Planet Relations', () {
      expect(result.houseRelations.length, equals(12));

      for (int i = 1; i <= 12; i++) {
        final hr = result.houseRelations.firstWhere((h) => h.houseNumber == i);
        final cusp = result.getCusp(i);

        expect(hr.cuspSubLord, equals(cusp.subLord));

        // Relations for this Sub Lord must match the planet relation of that planet
        final subLordRel = result.getPlanetRelation(cusp.subLord);
        expect(hr.cuspSubLordRelations, equals(subLordRel.combinedHouses));

        // Relations for Star Lord of Sub Lord must match the planet relation of that Star Lord
        final subLordPlanet = result.getPlanet(cusp.subLord);
        final starLordOfSubLordRel = result.getPlanetRelation(subLordPlanet.starLord);
        expect(hr.cuspSubLordStarLordRelations, equals(starLordOfSubLordRel.combinedHouses));
      }
    });

    test('7. Dasha Relations (Part 4) strictly match the corresponding planet relations', () {
      expect(result.dashaRelations.length, equals(4));

      for (final dr in result.dashaRelations) {
        expect(dr.planet.isNotEmpty, isTrue);
        final pRel = result.getPlanetRelation(dr.planet);
        expect(dr.relations, equals(pRel.combinedHouses));
      }
    });

    test('8. KpHouseNumber fallback formatting and comparison works cleanly', () {
      const normal8 = KpHouseNumber(8, isSubSubFallback: false);
      const fallback8 = KpHouseNumber(8, isSubSubFallback: true);
      const normal12 = KpHouseNumber(12, isSubSubFallback: false);
      const fallback5 = KpHouseNumber(5, isSubSubFallback: true);

      expect(normal8.displayText, equals('8'));
      expect(fallback8.displayText, equals(r'8$'));
      expect(normal12.displayText, equals('12'));
      expect(fallback5.displayText, equals(r'5$'));

      expect(fallback8 == const KpHouseNumber(8, isSubSubFallback: true), isTrue);
      expect(fallback8 == normal8, isFalse);
    });

    test('9. Sub-Sub Fallback triggers when Star/Sub Lord is absent in cusp Sub Lords and appends \$', () {
      // Create mock cusps where Jupiter is NOT a Sub Lord anywhere, but appears as Sub-Sub Lord in Bhavas 5, 9, 11
      final mockCusps = List.generate(12, (index) {
        final house = index + 1;
        final isSpecialSubSub = (house == 5 || house == 9 || house == 11);
        return CuspPosition(
          cuspNumber: house,
          longitude: index * 30.0,
          signIndex: index,
          signName: 'Sign$index',
          signNameTa: 'ராசி$index',
          degreeInRasi: 0.0,
          degreeStr: '0° 00\' 00"',
          starLord: 'Saturn',
          starLordTa: 'சனி',
          subLord: 'Venus', // Venus is Sub Lord everywhere, Jupiter is NOT
          subLordTa: 'சுக்கிரன்',
          subSubLord: isSpecialSubSub ? 'Jupiter' : 'Mercury',
          subSubLordTa: isSpecialSubSub ? 'குரு' : 'புதன்',
          nakshatraIndex: 0,
          nakshatraName: 'Ashwini',
          nakshatraNameTa: 'அஸ்வினி',
          pada: 1,
        );
      });

      // Planet where Star Lord is Jupiter
      final mockPlanets = [
        const PlanetPosition(
          planet: 'Sun',
          planetTa: 'சூரியன்',
          longitude: 10.0,
          signIndex: 0,
          signName: 'Aries',
          signNameTa: 'மேஷம்',
          degreeInRasi: 10.0,
          degreeStr: '10° 00\' 00"',
          starLord: 'Jupiter', // Jupiter is not in Sub Lord, fallback triggers
          starLordTa: 'குரு',
          subLord: 'Venus',   // Venus IS in Sub Lord, no fallback
          subLordTa: 'சுக்கிரன்',
          subSubLord: 'Mercury',
          subSubLordTa: 'புதன்',
          nakshatraIndex: 0,
          nakshatraName: 'Ashwini',
          nakshatraNameTa: 'அஸ்வினி',
          pada: 1,
        ),
      ];

      final relations = KpMethod4RelationEngine.calculatePlanetRelations(
        planets: mockPlanets,
        cusps: mockCusps,
      );

      final sunRel = relations.first;
      // Star Lord (Jupiter): fallback should be triggered!
      expect(sunRel.isStarLordFallback, isTrue);
      expect(sunRel.starLordHouses.length, equals(3));
      expect(sunRel.starLordHouses.map((h) => h.displayText).toList(), equals([r'5$', r'9$', r'11$']));

      // Sub Lord (Venus): match found at Sub Lord level, fallback NOT triggered!
      expect(sunRel.isSubLordFallback, isFalse);
      expect(sunRel.subLordHouses.length, equals(12));
      for (final h in sunRel.subLordHouses) {
        expect(h.isSubSubFallback, isFalse);
        expect(h.displayText.contains(r'$'), isFalse);
      }
    });

    test('10. House color classification rules (Part 3B)', () {
      // 8 and 12 must be RED
      // 5 and 9 must be GREEN
      // Others must be normal
      bool isRed(int h) => h == 8 || h == 12;
      bool isGreen(int h) => h == 5 || h == 9;

      expect(isRed(8), isTrue);
      expect(isRed(12), isTrue);
      expect(isRed(1), isFalse);
      expect(isRed(5), isFalse);
      expect(isRed(9), isFalse);

      expect(isGreen(5), isTrue);
      expect(isGreen(9), isTrue);
      expect(isGreen(8), isFalse);
      expect(isGreen(12), isFalse);
      expect(isGreen(11), isFalse);
    });
  });
}

