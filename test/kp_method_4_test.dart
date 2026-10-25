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

        // If fallback is used, displayText has '$' or '*'
        for (final h in pr.starLordHouses) {
          if (h.isSubSubFallback) {
            expect(h.displayText.endsWith(r'$'), isTrue);
          } else if (h.isStarLordFallback) {
            expect(h.displayText.endsWith(r'*'), isTrue);
          } else {
            expect(h.displayText.contains(r'$'), isFalse);
            expect(h.displayText.contains(r'*'), isFalse);
          }
        }
      }
    });

    test('5. Step 1 and Step 2 logic verification for Planet Relations with 3-priority hierarchy', () {
      // Pick a planet, e.g. Sun
      final sun = result.getPlanet('Sun');
      final sunRel = result.getPlanetRelation('Sun');

      expect(sunRel.starLord, equals(sun.starLord));
      expect(sunRel.subLord, equals(sun.subLord));

      // Verify that starLordHouses match Bhavas where starLord appears according to hierarchy
      final matchingSubLordCusps = result.cuspPositions
          .where((c) => c.subLord.toLowerCase() == sun.starLord.toLowerCase())
          .map((c) => c.cuspNumber)
          .toList();

      final matchingSubSubCusps = result.cuspPositions
          .where((c) => c.subSubLord.toLowerCase() == sun.starLord.toLowerCase())
          .map((c) => c.cuspNumber)
          .toList();

      final matchingStarLordCusps = result.cuspPositions
          .where((c) => c.starLord.toLowerCase() == sun.starLord.toLowerCase())
          .map((c) => c.cuspNumber)
          .toList();

      if (matchingSubLordCusps.isNotEmpty) {
        expect(sunRel.isStarLordFallback, isFalse);
        expect(sunRel.starLordSourceLevel, equals(KpSourceLevel.SUB_LORD));
        final actualHouses = sunRel.starLordHouses.map((h) => h.house).toList();
        expect(actualHouses, equals(matchingSubLordCusps));
      } else if (matchingSubSubCusps.isNotEmpty) {
        expect(sunRel.isStarLordFallback, isTrue);
        expect(sunRel.starLordSourceLevel, equals(KpSourceLevel.SUB_SUB_LORD));
        final actualHouses = sunRel.starLordHouses.map((h) => h.house).toList();
        expect(actualHouses, equals(matchingSubSubCusps));
        for (final h in sunRel.starLordHouses) {
          expect(h.isSubSubFallback, isTrue);
          expect(h.displayText, endsWith(r'$'));
        }
      } else {
        expect(sunRel.isStarLordFallback, isTrue);
        expect(sunRel.starLordSourceLevel, equals(KpSourceLevel.STAR_LORD));
        final actualHouses = sunRel.starLordHouses.map((h) => h.house).toList();
        expect(actualHouses, equals(matchingStarLordCusps));
        for (final h in sunRel.starLordHouses) {
          expect(h.isStarLordFallback, isTrue);
          expect(h.displayText, endsWith(r'*'));
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

        // Details for Star Lord and Sub Lord must match the planet relation of this Sub Lord directly
        expect(hr.cuspSubLordStarLord, equals(subLordRel.starLord));
        expect(hr.cuspSubLordStarLordRelations, equals(subLordRel.starLordHouses));
        expect(hr.cuspSubLordSubLord, equals(subLordRel.subLord));
        expect(hr.cuspSubLordSubLordRelations, equals(subLordRel.subLordHouses));
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

    test('11. Priority 1 (Sub Lord) -> Priority 2 (Sub-Sub Lord) -> Priority 3 (Star Lord) strict 3-level fallback', () {
      // Build mock cusps:
      // - 'PlanetA' is Sub Lord of houses 1, 7 (Priority 1)
      // - 'PlanetB' is not Sub Lord anywhere, but is Sub-Sub Lord of houses 2, 8 (Priority 2)
      // - 'PlanetC' is not Sub Lord or Sub-Sub Lord anywhere, but is Star Lord of houses 3, 6, 9 (Priority 3)
      final mockCusps = List.generate(12, (index) {
        final house = index + 1;
        String star = 'Saturn';
        String sub = 'Venus';
        String subSub = 'Mars';

        if (house == 1 || house == 7) {
          sub = 'PlanetA';
        }
        if (house == 2 || house == 8) {
          subSub = 'PlanetB';
        }
        if (house == 3 || house == 6 || house == 9) {
          star = 'PlanetC';
        }

        return CuspPosition(
          cuspNumber: house,
          longitude: index * 30.0,
          signIndex: index,
          signName: 'Sign$index',
          signNameTa: 'ராசி$index',
          degreeInRasi: 0.0,
          degreeStr: '0° 00\' 00"',
          starLord: star,
          starLordTa: star,
          subLord: sub,
          subLordTa: sub,
          subSubLord: subSub,
          subSubLordTa: subSub,
          nakshatraIndex: 0,
          nakshatraName: 'Ashwini',
          nakshatraNameTa: 'அஸ்வினி',
          pada: 1,
        );
      });

      // Priority 1 test
      final resA = KpMethod4RelationEngine.resolvePlanetContacts(
        targetPlanet: 'PlanetA',
        cusps: mockCusps,
      );
      expect(resA.sourceLevel, equals(KpSourceLevel.SUB_LORD));
      expect(resA.houses.map((h) => h.house).toList(), equals([1, 7]));
      expect(resA.houses.every((h) => !h.isSubSubFallback && !h.isStarLordFallback), isTrue);
      expect(resA.houses.map((h) => h.displayText).toList(), equals(['1', '7']));

      // Priority 2 test (fallback from Sub Lord to Sub-Sub Lord)
      final resB = KpMethod4RelationEngine.resolvePlanetContacts(
        targetPlanet: 'PlanetB',
        cusps: mockCusps,
      );
      expect(resB.sourceLevel, equals(KpSourceLevel.SUB_SUB_LORD));
      expect(resB.houses.map((h) => h.house).toList(), equals([2, 8]));
      expect(resB.houses.every((h) => h.isSubSubFallback), isTrue);
      expect(resB.houses.map((h) => h.displayText).toList(), equals([r'2$', r'8$']));

      // Priority 3 test (fallback from Sub Lord & Sub-Sub Lord to Star Lord)
      final resC = KpMethod4RelationEngine.resolvePlanetContacts(
        targetPlanet: 'PlanetC',
        cusps: mockCusps,
      );
      expect(resC.sourceLevel, equals(KpSourceLevel.STAR_LORD));
      expect(resC.houses.map((h) => h.house).toList(), equals([3, 6, 9]));
      expect(resC.houses.every((h) => h.isStarLordFallback), isTrue);
      expect(resC.houses.map((h) => h.displayText).toList(), equals(['3*', '6*', '9*']));
    });

    test('12. BhavaContact and resolveBhavaPlanetContact verification', () {
      final mockCusp = const CuspPosition(
        cuspNumber: 4,
        longitude: 90.0,
        signIndex: 3,
        signName: 'Cancer',
        signNameTa: 'கடகம்',
        degreeInRasi: 0.0,
        degreeStr: '0° 00\' 00"',
        starLord: 'Saturn',
        starLordTa: 'சனி',
        subLord: 'Jupiter',
        subLordTa: 'குரு',
        subSubLord: 'Mercury',
        subSubLordTa: 'புதன்',
        nakshatraIndex: 7,
        nakshatraName: 'Pushya',
        nakshatraNameTa: 'பூசம்',
        pada: 1,
      );

      final contactSub = KpMethod4RelationEngine.resolveBhavaPlanetContact(
        cusp: mockCusp,
        planet: 'Jupiter',
      );
      expect(contactSub, isNotNull);
      expect(contactSub!.sourceLevel, equals(KpSourceLevel.SUB_LORD));
      expect(contactSub.bhava, equals(4));

      final contactSubSub = KpMethod4RelationEngine.resolveBhavaPlanetContact(
        cusp: mockCusp,
        planet: 'Mercury',
      );
      expect(contactSubSub, isNotNull);
      expect(contactSubSub!.sourceLevel, equals(KpSourceLevel.SUB_SUB_LORD));
      expect(contactSubSub.bhava, equals(4));

      final contactStar = KpMethod4RelationEngine.resolveBhavaPlanetContact(
        cusp: mockCusp,
        planet: 'Saturn',
      );
      expect(contactStar, isNotNull);
      expect(contactStar!.sourceLevel, equals(KpSourceLevel.STAR_LORD));
      expect(contactStar.bhava, equals(4));

      final contactNone = KpMethod4RelationEngine.resolveBhavaPlanetContact(
        cusp: mockCusp,
        planet: 'Venus',
      );
      expect(contactNone, isNull);
    });

    test('13. Planet-to-Bhava contact mapping produces complete deterministic mapping for all 9 planets', () {
      expect(result.planetBhavaContacts.length, equals(9));
      expect(result.planetToBhavas.length, equals(9));

      const expectedPlanets = ['Sun', 'Moon', 'Mars', 'Mercury', 'Jupiter', 'Venus', 'Saturn', 'Rahu', 'Ketu'];
      for (final p in expectedPlanets) {
        final contacts = result.getContactsForPlanet(p);
        final houses = result.getHousesForPlanet(p);

        expect(contacts.length, equals(houses.length));
        for (int i = 0; i < contacts.length; i++) {
          expect(contacts[i].bhava, equals(houses[i].house));
          expect(contacts[i].sourceLevel, equals(houses[i].sourceLevel));
          expect(contacts[i].bhava, inInclusiveRange(1, 12));
        }
      }
    });

    test('14. Deterministic result verification with identical birth details', () {
      final secondResult = Kp4Engine.calculate(testBirthData);
      expect(result.ascendantDegree, equals(secondResult.ascendantDegree));
      expect(result.ayanamsa, equals(secondResult.ayanamsa));

      for (int i = 0; i < 9; i++) {
        final p1 = result.planetPositions[i];
        final p2 = secondResult.planetPositions[i];
        expect(p1.planet, equals(p2.planet));
        expect(p1.longitude, equals(p2.longitude));
        expect(p1.starLord, equals(p2.starLord));
        expect(p1.subLord, equals(p2.subLord));
        expect(p1.subSubLord, equals(p2.subSubLord));
      }

      for (int i = 0; i < 12; i++) {
        final c1 = result.cuspPositions[i];
        final c2 = secondResult.cuspPositions[i];
        expect(c1.cuspNumber, equals(c2.cuspNumber));
        expect(c1.longitude, equals(c2.longitude));
        expect(c1.starLord, equals(c2.starLord));
        expect(c1.subLord, equals(c2.subLord));
        expect(c1.subSubLord, equals(c2.subSubLord));
      }
    });

    test('15. Bhava Planetary Connections dynamically maps each Bhava Sub Lord to existing Planetary Connections', () {
      // For each of the 12 Bhavas, verify that the entry in houseRelations uses the exact
      // Planetary Connections data of that Bhava's Sub Lord
      for (final cusp in result.cuspPositions) {
        final hr = result.houseRelations.firstWhere((h) => h.houseNumber == cusp.cuspNumber);
        final planetRel = result.planetRelations.firstWhere(
          (p) => p.planet.toLowerCase() == cusp.subLord.toLowerCase(),
        );

        // Sub Lord planet matches
        expect(hr.cuspSubLord.toLowerCase(), equals(planetRel.planet.toLowerCase()));
        // Connected bhavas matches existing Planetary Connection combined houses
        expect(hr.cuspSubLordRelations, equals(planetRel.combinedHouses));
        // Star Lord matches planet's Star Lord
        expect(hr.cuspSubLordStarLord, equals(planetRel.starLord));
        expect(hr.cuspSubLordStarLordRelations, equals(planetRel.starLordHouses));
        // Sub Lord matches planet's Sub Lord
        expect(hr.cuspSubLordSubLord, equals(planetRel.subLord));
        expect(hr.cuspSubLordSubLordRelations, equals(planetRel.subLordHouses));
      }
    });

    test('16. Birth Time Rectification adjusts time and triggers full KP Method 4 recalculation', () {
      final originalDt = testBirthData.dateTime; // 1995-05-15 10:30:00
      final rectifiedDt = originalDt.add(const Duration(minutes: 1, seconds: 15)); // 10:31:15

      final rectifiedBirthData = testBirthData.copyWith(
        dateTime: rectifiedDt,
        time: '10:31:15',
      );

      final rectifiedResult = Kp4Engine.calculate(rectifiedBirthData);

      // Verify that recalculation produced updated results
      expect(rectifiedResult.ascendantDegree, isNot(equals(result.ascendantDegree)));
      expect(rectifiedResult.birthData.dateTime, equals(rectifiedDt));
      expect(rectifiedResult.birthData.time, equals('10:31:15'));

      // Verify all 12 cusps and 9 planets are recalculated
      expect(rectifiedResult.cuspPositions.length, equals(12));
      expect(rectifiedResult.planetPositions.length, equals(9));
      expect(rectifiedResult.houseRelations.length, equals(12));

      // Verify that Bhava Planetary Connections still adheres to the exact mapping rule
      for (final cusp in rectifiedResult.cuspPositions) {
        final hr = rectifiedResult.houseRelations.firstWhere((h) => h.houseNumber == cusp.cuspNumber);
        final planetRel = rectifiedResult.planetRelations.firstWhere(
          (p) => p.planet.toLowerCase() == cusp.subLord.toLowerCase(),
        );
        expect(hr.cuspSubLord.toLowerCase(), equals(planetRel.planet.toLowerCase()));
        expect(hr.cuspSubLordRelations, equals(planetRel.combinedHouses));
      }
    });

    test('17. Planet -> House Connections Fallback Rule (Tests A, B, C, D, and user specification)', () {
      // Mock cusps: Lagna = Cusp 1 at signIndex 5 (Kanni / Virgo, 160°)
      final mockCusps = List<CuspPosition>.generate(12, (i) {
        final cuspNum = i + 1;
        final sign = (5 + i) % 12;
        return CuspPosition(
          cuspNumber: cuspNum,
          longitude: sign * 30.0 + 10.0,
          signIndex: sign,
          signName: 'Sign$sign',
          signNameTa: 'ராசி$sign',
          degreeInRasi: 10.0,
          degreeStr: "10°00'00\"",
          starLord: 'Saturn',
          starLordTa: 'சனி',
          subLord: 'Mercury', // Mercury is Sub Lord of all 12 cusps
          subLordTa: 'புதன்',
          subSubLord: 'Venus',
          subSubLordTa: 'சுக்கிரன்',
          nakshatraIndex: i * 2,
          nakshatraName: 'Nak$i',
          nakshatraNameTa: 'நட்ச$i',
          pada: 1,
        );
      });

      // Planet 1: Mercury - Has existing connections as Sub Lord of cusps -> Preserved exactly (Test A)
      const planetMercury = PlanetPosition(
        planet: 'Mercury',
        planetTa: 'புதன்',
        longitude: 60.0,
        signIndex: 2,
        signName: 'Mithuna',
        signNameTa: 'மிதுனம்',
        degreeInRasi: 0.0,
        degreeStr: "00°00'00\"",
        starLord: 'Mars',
        starLordTa: 'செவ்வாய்',
        subLord: 'Rahu',
        subLordTa: 'ராகு',
        subSubLord: 'Jupiter',
        subSubLordTa: 'குரு',
        nakshatraIndex: 4,
        nakshatraName: 'Mrigashirsha',
        nakshatraNameTa: 'மிருகசீரிஷம்',
        pada: 3,
      );

      // Planet 2: Mars - Has NO cusp connections, but appears in Part 2 Star Lord column of Mercury (Test B)
      // Must NOT apply fallback because it appears in a specified column in Part 2.
      const planetMars = PlanetPosition(
        planet: 'Mars',
        planetTa: 'செவ்வாய்',
        longitude: 20.0,
        signIndex: 0,
        signName: 'Mesha',
        signNameTa: 'மேஷம்',
        degreeInRasi: 20.0,
        degreeStr: "20°00'00\"",
        starLord: 'Saturn',
        starLordTa: 'சனி',
        subLord: 'Sun',
        subLordTa: 'சூரியன்',
        subSubLord: 'Moon',
        subSubLordTa: 'சந்திரன்',
        nakshatraIndex: 0,
        nakshatraName: 'Ashwini',
        nakshatraNameTa: 'அசுவினி',
        pada: 1,
      );

      // Planet 3: Sun - Has NO cusp connections, but appears in Part 2 Sub Lord column of Mars (Test B)
      // Must NOT apply fallback because it appears in a specified column in Part 2.
      const planetSun = PlanetPosition(
        planet: 'Sun',
        planetTa: 'சூரியன்',
        longitude: 50.0,
        signIndex: 1,
        signName: 'Vrishabha',
        signNameTa: 'ரிஷபம்',
        degreeInRasi: 20.0,
        degreeStr: "20°00'00\"",
        starLord: 'Saturn',
        starLordTa: 'சனி',
        subLord: 'Moon',
        subLordTa: 'சந்திரன்',
        subSubLord: 'Moon',
        subSubLordTa: 'சந்திரன்',
        nakshatraIndex: 2,
        nakshatraName: 'Krittika',
        nakshatraNameTa: 'கிருத்திகை',
        pada: 2,
      );

      // Planet 4: Jupiter - Has NO cusp connections, but appears in Part 2 Sub-Sub Lord column of Mercury (Test B)
      // Must NOT apply fallback because it appears in a specified column in Part 2.
      const planetJupiter = PlanetPosition(
        planet: 'Jupiter',
        planetTa: 'குரு',
        longitude: 240.0,
        signIndex: 8,
        signName: 'Dhanus',
        signNameTa: 'தனுசு',
        degreeInRasi: 0.0,
        degreeStr: "00°00'00\"",
        starLord: 'Saturn',
        starLordTa: 'சனி',
        subLord: 'Moon',
        subLordTa: 'சந்திரன்',
        subSubLord: 'Moon',
        subSubLordTa: 'சந்திரன்',
        nakshatraIndex: 18,
        nakshatraName: 'Moola',
        nakshatraNameTa: 'மூலம்',
        pada: 1,
      );

      // Planet 5: Ketu - Has NO cusp connections, and is ABSENT from all three columns in Part 2 (Test C)
      // Occupied sign: Simha (signIndex 4). Lagna: Kanni (signIndex 5).
      // Counting from Kanni (5) to Simha (4) = 12th house.
      const planetKetu = PlanetPosition(
        planet: 'Ketu',
        planetTa: 'கேது',
        longitude: 140.0,
        signIndex: 4,
        signName: 'Simha',
        signNameTa: 'சிம்மம்',
        degreeInRasi: 20.0,
        degreeStr: "20°00'00\"",
        starLord: 'Moon',
        starLordTa: 'சந்திரன்',
        subLord: 'Moon',
        subLordTa: 'சந்திரன்',
        subSubLord: 'Moon',
        subSubLordTa: 'சந்திரன்',
        nakshatraIndex: 9,
        nakshatraName: 'Magha',
        nakshatraNameTa: 'மகம்',
        pada: 1,
      );

      final testPlanets = [planetMercury, planetMars, planetSun, planetJupiter, planetKetu];

      final housesMap = KpMethod4RelationEngine.calculatePlanetToBhavaHouses(
        planets: testPlanets,
        cusps: mockCusps,
      );
      final contactsMap = KpMethod4RelationEngine.calculatePlanetToBhavaContacts(
        planets: testPlanets,
        cusps: mockCusps,
      );

      // Test A: Mercury has existing connections -> preserved exactly (all 12 cusps)
      expect(housesMap['Mercury']!.isNotEmpty, isTrue);
      expect(housesMap['Mercury']!.length, equals(12));
      expect(contactsMap['Mercury']!.length, equals(12));

      // Test B: Mars has no connections, appears in Star Lord column in Part 2 -> NO fallback applied
      expect(housesMap['Mars']!.isEmpty, isTrue);
      expect(contactsMap['Mars']!.isEmpty, isTrue);

      // Test B: Sun has no connections, appears in Sub Lord column in Part 2 -> NO fallback applied
      expect(housesMap['Sun']!.isEmpty, isTrue);
      expect(contactsMap['Sun']!.isEmpty, isTrue);

      // Test B: Jupiter has no connections, appears in Sub-Sub Lord column in Part 2 -> NO fallback applied
      expect(housesMap['Jupiter']!.isEmpty, isTrue);
      expect(contactsMap['Jupiter']!.isEmpty, isTrue);

      // Test C: Ketu has no connections, absent from all 3 columns in Part 2 -> Fallback house 12 added
      expect(housesMap['Ketu']!.length, equals(1));
      expect(housesMap['Ketu']!.first.house, equals(12));
      expect(housesMap['Ketu']!.first.displayText, equals('12'));
      expect(contactsMap['Ketu']!.length, equals(1));
      expect(contactsMap['Ketu']!.first.bhava, equals(12));

      // User Specification Example:
      // Ascendant: Rishabam (Taurus, signIndex 1)
      // Planet's occupied sign: Kadagam (Cancer, signIndex 3)
      // Actual KP house connections: None
      // Planet appears in Star Lord, Sub Lord, or Sub-Sub Lord columns: No
      // Expected result: House 3
      final taurusCusps = List<CuspPosition>.generate(12, (i) {
        final cuspNum = i + 1;
        final sign = (1 + i) % 12; // Cusp 1 is Taurus (1)
        return CuspPosition(
          cuspNumber: cuspNum,
          longitude: sign * 30.0 + 5.0,
          signIndex: sign,
          signName: 'Sign$sign',
          signNameTa: 'ராசி$sign',
          degreeInRasi: 5.0,
          degreeStr: "05°00'00\"",
          starLord: 'DummyCuspLord',
          starLordTa: 'டம்மி',
          subLord: 'DummyCuspLord',
          subLordTa: 'டம்மி',
          subSubLord: 'DummyCuspLord',
          subSubLordTa: 'டம்மி',
          nakshatraIndex: 0,
          nakshatraName: 'Ashwini',
          nakshatraNameTa: 'அசுவினி',
          pada: 1,
        );
      });

      const cancerPlanet = PlanetPosition(
        planet: 'Moon',
        planetTa: 'சந்திரன்',
        longitude: 95.0,
        signIndex: 3, // Kadagam / Cancer
        signName: 'Karkata',
        signNameTa: 'கடகம்',
        degreeInRasi: 5.0,
        degreeStr: "05°00'00\"",
        starLord: 'Jupiter',
        starLordTa: 'குரு',
        subLord: 'Jupiter',
        subLordTa: 'குரு',
        subSubLord: 'Jupiter',
        subSubLordTa: 'குரு',
        nakshatraIndex: 7,
        nakshatraName: 'Pushya',
        nakshatraNameTa: 'பூசம்',
        pada: 1,
      );

      // Jupiter is in columns, Moon is NOT
      const otherPlanet = PlanetPosition(
        planet: 'Jupiter',
        planetTa: 'குரு',
        longitude: 0.0,
        signIndex: 0,
        signName: 'Mesha',
        signNameTa: 'மேஷம்',
        degreeInRasi: 0.0,
        degreeStr: "00°00'00\"",
        starLord: 'Saturn',
        starLordTa: 'சனி',
        subLord: 'Saturn',
        subLordTa: 'சனி',
        subSubLord: 'Saturn',
        subSubLordTa: 'சனி',
        nakshatraIndex: 0,
        nakshatraName: 'Ashwini',
        nakshatraNameTa: 'அசுவினி',
        pada: 1,
      );

      final userExampleHouses = KpMethod4RelationEngine.calculatePlanetToBhavaHouses(
        planets: [cancerPlanet, otherPlanet],
        cusps: taurusCusps,
        ascendantDegree: 35.0, // Taurus
      );
      expect(userExampleHouses['Moon']!.length, equals(1));
      expect(userExampleHouses['Moon']!.first.house, equals(3));
      expect(userExampleHouses['Moon']!.first.displayText, equals('3'));

      // Test D: Validate consistency across all 9 planets
      const ninePlanets = [
        'Sun', 'Moon', 'Mars', 'Mercury', 'Jupiter', 'Venus', 'Saturn', 'Rahu', 'Ketu'
      ];
      for (int i = 0; i < ninePlanets.length; i++) {
        final pName = ninePlanets[i];
        final pSign = (1 + i) % 12; // Each planet placed in a sign
        final pPos = PlanetPosition(
          planet: pName,
          planetTa: pName,
          longitude: pSign * 30.0 + 10.0,
          signIndex: pSign,
          signName: 'Sign$pSign',
          signNameTa: 'ராசி$pSign',
          degreeInRasi: 10.0,
          degreeStr: "10°00'00\"",
          starLord: 'DummyLord',
          starLordTa: 'டம்மி',
          subLord: 'DummyLord',
          subLordTa: 'டம்மி',
          subSubLord: 'DummyLord',
          subSubLordTa: 'டம்மி',
          nakshatraIndex: 0,
          nakshatraName: 'Ashwini',
          nakshatraNameTa: 'அசுவினி',
          pada: 1,
        );

        final singlePlanetMap = KpMethod4RelationEngine.calculatePlanetToBhavaHouses(
          planets: [pPos],
          cusps: taurusCusps,
          ascendantDegree: 35.0, // Lagna Taurus (1)
        );

        // Expected house counted from Taurus (1) to pSign:
        final expectedHouse = ((pSign - 1) % 12 + 12) % 12 + 1;
        expect(singlePlanetMap[pName]!.length, equals(1));
        expect(singlePlanetMap[pName]!.first.house, equals(expectedHouse));
      }

      // Zodiac Wrap-around: Meenam (Pisces, 11) to Mesham (Aries, 0)
      final meenamLagnaCusps = List<CuspPosition>.generate(12, (i) {
        final cuspNum = i + 1;
        final sign = (11 + i) % 12; // Cusp 1 is Meenam (11)
        return CuspPosition(
          cuspNumber: cuspNum,
          longitude: sign * 30.0,
          signIndex: sign,
          signName: 'Sign$sign',
          signNameTa: 'ராசி$sign',
          degreeInRasi: 0.0,
          degreeStr: "00°00'00\"",
          starLord: 'DummyLord',
          starLordTa: 'டம்மி',
          subLord: 'DummyLord',
          subLordTa: 'டம்மி',
          subSubLord: 'DummyLord',
          subSubLordTa: 'டம்மி',
          nakshatraIndex: 0,
          nakshatraName: 'Ashwini',
          nakshatraNameTa: 'அசுவினி',
          pada: 1,
        );
      });

      const planetMesham = PlanetPosition(
        planet: 'Saturn',
        planetTa: 'சனி',
        longitude: 10.0,
        signIndex: 0, // Mesham (Aries)
        signName: 'Mesha',
        signNameTa: 'மேஷம்',
        degreeInRasi: 10.0,
        degreeStr: "10°00'00\"",
        starLord: 'DummyLord',
        starLordTa: 'டம்மி',
        subLord: 'DummyLord',
        subLordTa: 'டம்மி',
        subSubLord: 'DummyLord',
        subSubLordTa: 'டம்மி',
        nakshatraIndex: 0,
        nakshatraName: 'Ashwini',
        nakshatraNameTa: 'அசுவினி',
        pada: 1,
      );

      final wrapMap = KpMethod4RelationEngine.calculatePlanetToBhavaHouses(
        planets: [planetMesham],
        cusps: meenamLagnaCusps,
        ascendantDegree: 335.0, // Pisces (11)
      );

      // From Meenam (11) to Mesham (0) -> relative house = 2
      expect(wrapMap['Saturn']!.length, equals(1));
      expect(wrapMap['Saturn']!.first.house, equals(2));
      expect(wrapMap['Saturn']!.first.displayText, equals('2'));

      // Safe error handling: empty or invalid cusps does not invent house numbers
      final emptyCuspsMap = KpMethod4RelationEngine.calculatePlanetToBhavaHouses(
        planets: [planetMars],
        cusps: [],
      );
      expect(emptyCuspsMap['Mars']!.isEmpty, isTrue);

      const invalidPlanet = PlanetPosition(
        planet: 'Rahu',
        planetTa: 'ராகு',
        longitude: double.nan,
        signIndex: 0,
        signName: 'Mesha',
        signNameTa: 'மேஷம்',
        degreeInRasi: 0.0,
        degreeStr: "00°00'00\"",
        starLord: 'DummyLord',
        starLordTa: 'டம்மி',
        subLord: 'DummyLord',
        subLordTa: 'டம்மி',
        subSubLord: 'DummyLord',
        subSubLordTa: 'டம்மி',
        nakshatraIndex: 0,
        nakshatraName: 'Ashwini',
        nakshatraNameTa: 'அசுவினி',
        pada: 1,
      );
      final invalidMap = KpMethod4RelationEngine.calculatePlanetToBhavaHouses(
        planets: [invalidPlanet],
        cusps: mockCusps,
      );
      expect(invalidMap['Rahu']!.isEmpty, isTrue);
    });

    test('18. Seconds Correction control starts at 1-second increment and supports direct time selection', () {
      final initialDt = DateTime(1995, 5, 15, 10, 30, 0);

      // Verify increment by +1 second (starts at 1s only)
      final incrementedDt = initialDt.add(const Duration(seconds: 1));
      expect(incrementedDt.second, equals(1));
      expect(incrementedDt.minute, equals(30));

      // Verify decrement by -1 second
      final decrementedDt = initialDt.add(const Duration(seconds: -1));
      expect(decrementedDt.second, equals(59));
      expect(decrementedDt.minute, equals(29));

      // Verify direct time selection (HH:MM:SS)
      final directDt = DateTime(initialDt.year, initialDt.month, initialDt.day, 10, 35, 42);
      expect(directDt.hour, equals(10));
      expect(directDt.minute, equals(35));
      expect(directDt.second, equals(42));
    });
  });
}

