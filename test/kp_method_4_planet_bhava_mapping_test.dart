import 'package:flutter_test/flutter_test.dart';
import 'package:astrocall/kp_method_4/kp_method_4.dart';

void main() {
  group('KP Method 4 Planet → Bhava Mapping Tests', () {
    test('1. Mars receives C5 with Star Lord fallback indicator (5*) when C5 has Mars as Star Lord', () {
      // Mock 12 cusps where C5 has Mars as Star Lord
      final mockCusps = List<CuspPosition>.generate(12, (i) {
        final cuspNum = i + 1;
        final isC5 = (cuspNum == 5);
        return CuspPosition(
          cuspNumber: cuspNum,
          longitude: i * 30.0 + 10.0,
          signIndex: i,
          signName: 'Sign$i',
          signNameTa: 'ராசி$i',
          degreeInRasi: 10.0,
          degreeStr: "10°00'00\"",
          starLord: isC5 ? 'Mars' : 'Jupiter',
          starLordTa: isC5 ? 'செவ்வாய்' : 'குரு',
          subLord: 'Saturn',
          subLordTa: 'சனி',
          subSubLord: 'Mercury',
          subSubLordTa: 'புதன்',
          nakshatraIndex: i * 2,
          nakshatraName: 'Nak$i',
          nakshatraNameTa: 'நட்ச$i',
          pada: 1,
        );
      });

      const marsPlanet = PlanetPosition(
        planet: 'Mars',
        planetTa: 'செவ்வாய்',
        longitude: 20.0,
        signIndex: 0,
        signName: 'Mesha',
        signNameTa: 'மேஷம்',
        degreeInRasi: 20.0,
        degreeStr: "20°00'00\"",
        starLord: 'Venus',
        starLordTa: 'சுக்கிரன்',
        subLord: 'Venus',
        subLordTa: 'சுக்கிரன்',
        subSubLord: 'Venus',
        subSubLordTa: 'சுக்கிரன்',
        nakshatraIndex: 1,
        nakshatraName: 'Bharani',
        nakshatraNameTa: 'பரணி',
        pada: 1,
      );

      final housesMap = KpMethod4RelationEngine.calculatePlanetToBhavaHouses(
        planets: [marsPlanet],
        cusps: mockCusps,
      );
      final contactsMap = KpMethod4RelationEngine.calculatePlanetToBhavaContacts(
        planets: [marsPlanet],
        cusps: mockCusps,
      );

      expect(housesMap['Mars'], isNotNull);
      expect(housesMap['Mars']!.length, equals(1));
      expect(housesMap['Mars']!.first.house, equals(5));
      expect(housesMap['Mars']!.first.isStarLordFallback, isTrue);
      expect(housesMap['Mars']!.first.displayText, equals('5*'));

      expect(contactsMap['Mars'], isNotNull);
      expect(contactsMap['Mars']!.length, equals(1));
      expect(contactsMap['Mars']!.first.bhava, equals(5));
      expect(contactsMap['Mars']!.first.sourceLevel, equals(KpSourceLevel.STAR_LORD));
    });

    test('2. Mars mapping works seamlessly with Tamil name and bilingual formatting in cusps', () {
      // Cusp 5 with Tamil and bilingual text
      final mockCusps = List<CuspPosition>.generate(12, (i) {
        final cuspNum = i + 1;
        final isC5 = (cuspNum == 5);
        return CuspPosition(
          cuspNumber: cuspNum,
          longitude: i * 30.0 + 10.0,
          signIndex: i,
          signName: 'Sign$i',
          signNameTa: 'ராசி$i',
          degreeInRasi: 10.0,
          degreeStr: "10°00'00\"",
          starLord: isC5 ? 'செவ்வாய் (Mars)' : 'Sun',
          starLordTa: isC5 ? 'செவ்வாய்' : 'சூரியன்',
          subLord: 'Saturn',
          subLordTa: 'சனி',
          subSubLord: 'Mercury',
          subSubLordTa: 'புதன்',
          nakshatraIndex: i * 2,
          nakshatraName: 'Nak$i',
          nakshatraNameTa: 'நட்ச$i',
          pada: 1,
        );
      });

      final res = KpMethod4RelationEngine.resolvePlanetContacts(
        targetPlanet: 'செவ்வாய்',
        cusps: mockCusps,
      );

      expect(res.houses.length, equals(1));
      expect(res.houses.first.house, equals(5));
      expect(res.houses.first.displayText, equals('5*'));
      expect(res.sourceLevel, equals(KpSourceLevel.STAR_LORD));
    });

    test('3. Ketu mapping correctly resolves when Ketu is Sub Lord, Sub-Sub Lord, or Star Lord', () {
      // Cusp 10 has Ketu as Sub Lord
      final mockCusps = List<CuspPosition>.generate(12, (i) {
        final cuspNum = i + 1;
        final isC10 = (cuspNum == 10);
        return CuspPosition(
          cuspNumber: cuspNum,
          longitude: i * 30.0 + 10.0,
          signIndex: i,
          signName: 'Sign$i',
          signNameTa: 'ராசி$i',
          degreeInRasi: 10.0,
          degreeStr: "10°00'00\"",
          starLord: 'Jupiter',
          starLordTa: 'குரு',
          subLord: isC10 ? 'Ketu' : 'Saturn',
          subLordTa: isC10 ? 'கேது' : 'சனி',
          subSubLord: 'Mercury',
          subSubLordTa: 'புதன்',
          nakshatraIndex: i * 2,
          nakshatraName: 'Nak$i',
          nakshatraNameTa: 'நட்ச$i',
          pada: 1,
        );
      });

      const ketuPlanet = PlanetPosition(
        planet: 'Ketu',
        planetTa: 'கேது',
        longitude: 140.0,
        signIndex: 4,
        signName: 'Simha',
        signNameTa: 'சிம்மம்',
        degreeInRasi: 20.0,
        degreeStr: "20°00'00\"",
        starLord: 'Venus',
        starLordTa: 'சுக்கிரன்',
        subLord: 'Venus',
        subLordTa: 'சுக்கிரன்',
        subSubLord: 'Venus',
        subSubLordTa: 'சுக்கிரன்',
        nakshatraIndex: 10,
        nakshatraName: 'Magha',
        nakshatraNameTa: 'மகம்',
        pada: 1,
      );

      final housesMap = KpMethod4RelationEngine.calculatePlanetToBhavaHouses(
        planets: [ketuPlanet],
        cusps: mockCusps,
      );

      expect(housesMap['Ketu'], isNotNull);
      expect(housesMap['Ketu']!.length, equals(1));
      expect(housesMap['Ketu']!.first.house, equals(10));
      expect(housesMap['Ketu']!.first.displayText, equals('10'));
    });

    test('4. KpResult lookup functions work seamlessly with English, Tamil, and bilingual queries', () {
      final dummyBirthData = Kp4BirthData(
        dateTime: DateTime(1995, 5, 15, 10, 30),
        time: '10:30 AM',
        place: 'Chennai',
        latitude: 13.0827,
        longitude: 80.2707,
      );

      final dummyResult = KpResult(
        birthData: dummyBirthData,
        ascendantDegree: 10.0,
        ascendantDegreeStr: "10°00'00\"",
        ascendantSignTa: 'மேஷம்',
        ayanamsa: 23.8,
        ayanamsaStr: "23°48'00\"",
        planetPositions: const [
          PlanetPosition(
            planet: 'Mars',
            planetTa: 'செவ்வாய்',
            longitude: 25.0,
            signIndex: 0,
            signName: 'Mesha',
            signNameTa: 'மேஷம்',
            degreeInRasi: 25.0,
            degreeStr: "25°00'00\"",
            starLord: 'Venus',
            starLordTa: 'சுக்கிரன்',
            subLord: 'Mercury',
            subLordTa: 'புதன்',
            subSubLord: 'Moon',
            subSubLordTa: 'சந்திரன்',
            nakshatraIndex: 1,
            nakshatraName: 'Bharani',
            nakshatraNameTa: 'பரணி',
            pada: 4,
          ),
        ],
        cuspPositions: const [],
        planetRelations: const [],
        houseRelations: const [],
        dashaRelations: const [],
        planetToBhavas: {
          'Mars': [KpHouseNumber(5, isStarLordFallback: true)],
        },
        planetBhavaContacts: {
          'Mars': [
            const BhavaContact(bhava: 5, planet: 'Mars', sourceLevel: KpSourceLevel.STAR_LORD),
          ],
        },
      );

      // Lookup by English
      expect(dummyResult.getHousesForPlanet('Mars').first.displayText, equals('5*'));
      expect(dummyResult.getContactsForPlanet('Mars').first.bhava, equals(5));
      expect(dummyResult.getPlanet('Mars').planet, equals('Mars'));

      // Lookup by Tamil
      expect(dummyResult.getHousesForPlanet('செவ்வாய்').first.displayText, equals('5*'));
      expect(dummyResult.getContactsForPlanet('செவ்வாய்').first.bhava, equals(5));
      expect(dummyResult.getPlanet('செவ்வாய்').planet, equals('Mars'));

      // Lookup by bilingual
      expect(dummyResult.getHousesForPlanet('செவ்வாய் (Mars)').first.displayText, equals('5*'));
      expect(dummyResult.getContactsForPlanet('செவ்வாய் (Mars)').first.bhava, equals(5));
    });

    test('5. KpPlanetUtils accurately normalizes all 9 Vedic planets across languages and formats', () {
      final expectations = {
        'Sun': ['Sun', 'sun', 'SURYA', 'suryan', 'சூரியன்', 'சூரி', 'சூரியன் (Sun)', 'Sun (சூரியன்)'],
        'Moon': ['Moon', 'moon', 'Chandra', 'chandran', 'சந்திரன்', 'சந்', 'சந்திரன் (Moon)'],
        'Mars': ['Mars', 'mars', 'Mangal', 'Kuja', 'Sevvai', 'chevvai', 'செவ்வாய்', 'செவ்', 'செவ்வாய் (Mars)'],
        'Mercury': ['Mercury', 'mercury', 'Budha', 'budhan', 'புதன்', 'புத', 'புதன் (Mercury)'],
        'Jupiter': ['Jupiter', 'jupiter', 'Guru', 'guru', 'Brihaspati', 'குரு', 'குரு (Jupiter)'],
        'Venus': ['Venus', 'venus', 'Sukra', 'sukran', 'shukra', 'சுக்கிரன்', 'சுக்', 'சுக்கிரன் (Venus)'],
        'Saturn': ['Saturn', 'saturn', 'Sani', 'shani', 'சனி', 'சனி (Saturn)'],
        'Rahu': ['Rahu', 'rahu', 'raahu', 'ராகு', 'ராகு (Rahu)'],
        'Ketu': ['Ketu', 'ketu', 'kethu', 'கேது', 'கேது (Ketu)'],
      };

      for (final entry in expectations.entries) {
        final canonical = entry.key;
        for (final alias in entry.value) {
          expect(KpPlanetUtils.normalize(alias), equals(canonical),
              reason: 'Failed normalizing "$alias" to "$canonical"');
          expect(KpPlanetUtils.isSamePlanet(alias, canonical), isTrue,
              reason: 'Failed matching "$alias" with "$canonical"');
        }
      }

      // Negative check: Venus and Mars must never match
      expect(KpPlanetUtils.isSamePlanet('Venus', 'Mars'), isFalse);
      expect(KpPlanetUtils.isSamePlanet('சுக்கிரன் (Venus)', 'செவ்வாய் (Mars)'), isFalse);
      expect(KpPlanetUtils.isSamePlanet('சுக்கிரன்', 'செவ்வாய்'), isFalse);
    });

    group('Missing House Connection Fallback - Verification of All 4 Steps & 9 Planets', () {
      // Helper to generate cusps where none of the cusps use the target planet
      List<CuspPosition> createIsolatedCusps({required int lagnaSignIndex}) {
        return List<CuspPosition>.generate(12, (i) {
          final cuspNum = i + 1;
          final sign = (lagnaSignIndex + i) % 12;
          return CuspPosition(
            cuspNumber: cuspNum,
            longitude: sign * 30.0 + 5.0,
            signIndex: sign,
            signName: 'Sign$sign',
            signNameTa: 'ராசி$sign',
            degreeInRasi: 5.0,
            degreeStr: "05°00'00\"",
            starLord: 'OtherLordA',
            starLordTa: 'வேறுA',
            subLord: 'OtherLordB',
            subLordTa: 'வேறுB',
            subSubLord: 'OtherLordC',
            subSubLordTa: 'வேறுC',
            nakshatraIndex: i,
            nakshatraName: 'Nak$i',
            nakshatraNameTa: 'நட்ச$i',
            pada: 1,
          );
        });
      }

      // Helper to generate a planet position
      PlanetPosition createPlanet({
        required String name,
        required String nameTa,
        required int signIndex,
        String starLord = 'OtherLordA',
        String subLord = 'OtherLordB',
        String subSubLord = 'OtherLordC',
        double longitude = 15.0,
      }) {
        return PlanetPosition(
          planet: name,
          planetTa: nameTa,
          longitude: signIndex * 30.0 + (longitude % 30.0),
          signIndex: signIndex,
          signName: 'Sign$signIndex',
          signNameTa: 'ராசி$signIndex',
          degreeInRasi: 15.0,
          degreeStr: "15°00'00\"",
          starLord: starLord,
          starLordTa: starLord,
          subLord: subLord,
          subLordTa: subLord,
          subSubLord: subSubLord,
          subSubLordTa: subSubLord,
          nakshatraIndex: 0,
          nakshatraName: 'Nak0',
          nakshatraNameTa: 'நட்ச0',
          pada: 1,
        );
      }

      const allNinePlanets = [
        ('Sun', 'சூரியன்'),
        ('Moon', 'சந்திரன்'),
        ('Mars', 'செவ்வாய்'),
        ('Mercury', 'புதன்'),
        ('Jupiter', 'குரு'),
        ('Venus', 'சுக்கிரன்'),
        ('Saturn', 'சனி'),
        ('Rahu', 'ராகு'),
        ('Ketu', 'கேது'),
      ];

      test('Step 1: Preserves existing house connections exactly and never adds fallback to connected planets', () {
        // Cusp 2 has Sun as Sub Lord, Cusp 6 has Moon as Sub-Sub Lord, Cusp 9 has Mars as Star Lord
        final cusps = createIsolatedCusps(lagnaSignIndex: 0);
        cusps[1] = CuspPosition(
          cuspNumber: 2,
          longitude: 35.0,
          signIndex: 1,
          signName: 'Taurus',
          signNameTa: 'ரிஷபம்',
          degreeInRasi: 5.0,
          degreeStr: "05°00'00\"",
          starLord: 'OtherLordA',
          starLordTa: 'வேறுA',
          subLord: 'Sun',
          subLordTa: 'சூரியன்',
          subSubLord: 'OtherLordC',
          subSubLordTa: 'வேறுC',
          nakshatraIndex: 1,
          nakshatraName: 'Nak1',
          nakshatraNameTa: 'நட்ச1',
          pada: 1,
        );
        cusps[5] = CuspPosition(
          cuspNumber: 6,
          longitude: 155.0,
          signIndex: 5,
          signName: 'Virgo',
          signNameTa: 'கன்னி',
          degreeInRasi: 5.0,
          degreeStr: "05°00'00\"",
          starLord: 'OtherLordA',
          starLordTa: 'வேறுA',
          subLord: 'OtherLordB',
          subLordTa: 'வேறுB',
          subSubLord: 'Moon',
          subSubLordTa: 'சந்திரன்',
          nakshatraIndex: 5,
          nakshatraName: 'Nak5',
          nakshatraNameTa: 'நட்ச5',
          pada: 1,
        );
        cusps[8] = CuspPosition(
          cuspNumber: 9,
          longitude: 245.0,
          signIndex: 8,
          signName: 'Sagittarius',
          signNameTa: 'தனுசு',
          degreeInRasi: 5.0,
          degreeStr: "05°00'00\"",
          starLord: 'Mars',
          starLordTa: 'செவ்வாய்',
          subLord: 'OtherLordB',
          subLordTa: 'வேறுB',
          subSubLord: 'OtherLordC',
          subSubLordTa: 'வேறுC',
          nakshatraIndex: 8,
          nakshatraName: 'Nak8',
          nakshatraNameTa: 'நட்ச8',
          pada: 1,
        );

        final sun = createPlanet(name: 'Sun', nameTa: 'சூரியன்', signIndex: 4); // Leo (Sign 4) -> 5th house
        final moon = createPlanet(name: 'Moon', nameTa: 'சந்திரன்', signIndex: 6); // Libra (Sign 6) -> 7th house
        final mars = createPlanet(name: 'Mars', nameTa: 'செவ்வாய்', signIndex: 10); // Aquarius (Sign 10) -> 11th house

        final housesMap = KpMethod4RelationEngine.calculatePlanetToBhavaHouses(
          planets: [sun, moon, mars],
          cusps: cusps,
          ascendantDegree: 5.0, // Lagna Aries (0)
        );

        // Sun retains Cusp 2 (Sub Lord) without fallback house 5
        expect(housesMap['Sun']!.map((h) => h.house).toList(), equals([2]));
        expect(housesMap['Sun']!.first.displayText, equals('2'));

        // Moon retains Cusp 6 (Sub-Sub Lord) without fallback house 7
        expect(housesMap['Moon']!.map((h) => h.house).toList(), equals([6]));
        expect(housesMap['Moon']!.first.displayText, equals('6\$'));

        // Mars retains Cusp 9 (Star Lord) without fallback house 11
        expect(housesMap['Mars']!.map((h) => h.house).toList(), equals([9]));
        expect(housesMap['Mars']!.first.displayText, equals('9*'));
      });

      test('Step 2: Planets with no cusp connections receive their fallback house from Lagna', () {
        final cusps = createIsolatedCusps(lagnaSignIndex: 0);

        final planetSun = createPlanet(
          name: 'Sun',
          nameTa: 'சூரியன்',
          signIndex: 0,
          starLord: 'Jupiter',
          subLord: 'Venus',
          subSubLord: 'Saturn',
        );
        final planetJupiter = createPlanet(name: 'Jupiter', nameTa: 'குரு', signIndex: 3);
        final planetVenus = createPlanet(name: 'Venus', nameTa: 'சுக்கிரன்', signIndex: 7);
        final planetSaturn = createPlanet(name: 'Saturn', nameTa: 'சனி', signIndex: 9);

        final housesMap = KpMethod4RelationEngine.calculatePlanetToBhavaHouses(
          planets: [planetSun, planetJupiter, planetVenus, planetSaturn],
          cusps: cusps,
          ascendantDegree: 5.0,
        );

        // All planets without cusp connections receive their occupied house from Lagna (0)
        expect(housesMap['Jupiter']!.map((h) => h.house).toList(), equals([4]));
        expect(housesMap['Venus']!.map((h) => h.house).toList(), equals([8]));
        expect(housesMap['Saturn']!.map((h) => h.house).toList(), equals([10]));
      });

      test('Step 3 & 4: Fallback house calculated accurately for each of all 9 planets independently', () {
        // Lagna at Taurus (Rishabam, signIndex = 1)
        final cusps = createIsolatedCusps(lagnaSignIndex: 1);

        for (int i = 0; i < allNinePlanets.length; i++) {
          final (pName, pNameTa) = allNinePlanets[i];
          // Assign each planet a distinct occupied zodiac sign (0..11)
          final occupiedSign = (i * 3 + 2) % 12;
          final planet = createPlanet(
            name: pName,
            nameTa: pNameTa,
            signIndex: occupiedSign,
            starLord: 'NeutralLord1',
            subLord: 'NeutralLord2',
            subSubLord: 'NeutralLord3',
          );

          final housesMap = KpMethod4RelationEngine.calculatePlanetToBhavaHouses(
            planets: [planet],
            cusps: cusps,
            ascendantDegree: 35.0, // Taurus (signIndex 1)
          );

          // Expected: ((occupiedSign - 1 + 12) % 12) + 1
          final expectedHouse = ((occupiedSign - 1 + 12) % 12) + 1;
          expect(housesMap[pName], isNotNull);
          expect(housesMap[pName]!.length, equals(1));
          expect(housesMap[pName]!.first.house, equals(expectedHouse));
          expect(housesMap[pName]!.first.displayText, equals('$expectedHouse'));
        }
      });

      test('Step 4: Multiple eligible planets evaluated together are handled independently without cross-interference or duplicates', () {
        // Lagna at Leo (Simham, signIndex = 4)
        final cusps = createIsolatedCusps(lagnaSignIndex: 4);

        // 3 eligible planets: Ketu (Cancer, sign 3), Rahu (Capricorn, sign 9), Mercury (Pisces, sign 11)
        final ketu = createPlanet(name: 'Ketu', nameTa: 'கேது', signIndex: 3);
        final rahu = createPlanet(name: 'Rahu', nameTa: 'ராகு', signIndex: 9);
        final mercury = createPlanet(name: 'Mercury', nameTa: 'புதன்', signIndex: 11);

        final housesMap = KpMethod4RelationEngine.calculatePlanetToBhavaHouses(
          planets: [ketu, rahu, mercury],
          cusps: cusps,
          ascendantDegree: 125.0, // Leo (4)
        );

        // Ketu: Cancer (3) from Leo (4) = 12th house
        expect(housesMap['Ketu']!.length, equals(1));
        expect(housesMap['Ketu']!.first.house, equals(12));

        // Rahu: Capricorn (9) from Leo (4) = 6th house
        expect(housesMap['Rahu']!.length, equals(1));
        expect(housesMap['Rahu']!.first.house, equals(6));

        // Mercury: Pisces (11) from Leo (4) = 8th house
        expect(housesMap['Mercury']!.length, equals(1));
        expect(housesMap['Mercury']!.first.house, equals(8));
      });

      test('Step 4: Safe handling: Invalid coordinates or missing cusp data does not invent house numbers', () {
        final cusps = createIsolatedCusps(lagnaSignIndex: 0);

        final nanPlanet = createPlanet(
          name: 'Sun',
          nameTa: 'சூரியன்',
          signIndex: 0,
          longitude: double.nan,
        );

        // 1. NaN planet longitude
        final nanResult = KpMethod4RelationEngine.calculatePlanetToBhavaHouses(
          planets: [nanPlanet],
          cusps: cusps,
          ascendantDegree: 10.0,
        );
        expect(nanResult['Sun']!.isEmpty, isTrue);

        // 2. Empty cusps list
        final validPlanet = createPlanet(name: 'Sun', nameTa: 'சூரியன்', signIndex: 2);
        final emptyCuspsResult = KpMethod4RelationEngine.calculatePlanetToBhavaHouses(
          planets: [validPlanet],
          cusps: const [],
          ascendantDegree: 10.0,
        );
        expect(emptyCuspsResult['Sun']!.isEmpty, isTrue);

        // 3. calculatePlanetToBhavaContacts also safely returns empty list
        final emptyContactsResult = KpMethod4RelationEngine.calculatePlanetToBhavaContacts(
          planets: [validPlanet],
          cusps: const [],
        );
        expect(emptyContactsResult['Sun']!.isEmpty, isTrue);
      });

      test('Direct verification of houseFromAscendantSign and applyFallbackHouse', () {
        // Test houseFromAscendantSign
        // e.g., Lagna in Taurus (ascendantLongitude: 35.0 -> ascSign = 1)
        // Planet in Cancer (signIndex = 3) -> ((3 - 1 + 12) % 12) + 1 = 3
        final house = KpMethod4RelationEngine.houseFromAscendantSign(
          signIndex: 3,
          ascendantLongitude: 35.0,
        );
        expect(house, equals(3));

        // When relatedHouses is NOT empty, applyFallbackHouse preserves existing sorted unique list
        final preserved = KpMethod4RelationEngine.applyFallbackHouse(
          relatedHouses: [5, 2, 5, 8],
          planetSignIndex: 3,
          ascendantLongitude: 35.0,
        );
        expect(preserved, equals([2, 5, 8]));

        // When relatedHouses IS empty, applyFallbackHouse returns [fallbackHouse]
        final fallback = KpMethod4RelationEngine.applyFallbackHouse(
          relatedHouses: [],
          planetSignIndex: 3,
          ascendantLongitude: 35.0,
        );
        expect(fallback, equals([3]));
      });
    });
  });
}

