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
  });
}
