import 'package:flutter_test/flutter_test.dart';
import 'package:astrocall/kp_method_model_1/kp_method_model_1.dart';

void main() {
  group('KP Method Model 1 Engine & Advantage Filter Unit Tests', () {
    test('1. Advantage Filter - Rule 1: STAR=EVEN, SUB=ODD -> SUB Priority', () {
      final res = KPAdvantageFilter.filterAdvantageHouses(
        starHouses: [2, 4, 6],
        subHouses: [3, 7, 9],
      );
      expect(res, [3, 7, 9]);
    });

    test('2. Advantage Filter - Rule 2: STAR=ODD, SUB=EVEN -> STAR Priority', () {
      final res = KPAdvantageFilter.filterAdvantageHouses(
        starHouses: [1, 5, 9],
        subHouses: [2, 4, 8],
      );
      expect(res, [1, 5, 9]);
    });

    test('3. Advantage Filter - Rule 3: Mixed Odd/Even -> ODD Priority', () {
      final res = KPAdvantageFilter.filterAdvantageHouses(
        starHouses: [2, 5],
        subHouses: [4, 7],
      );
      expect(res, [5, 7]);
    });

    test('4. Advantage Filter - Rule 4: 1 + 12 Occur Together -> Remove 1, Keep 12', () {
      // When Star has 1 and Sub has 12: 1 + 12 occur together -> 1 removed, 12 kept
      final res = KPAdvantageFilter.filterAdvantageHouses(
        starHouses: [1, 3],
        subHouses: [6, 12],
      );
      // 1 removed, 12 kept. Odds priority gives 3, plus 12 kept -> [3, 12]
      expect(res, [3, 12]);

      // When candidates explicitly contain 1 and 12
      final resWithBoth = KPAdvantageFilter.filterAdvantageHouses(
        starHouses: [2, 4],
        subHouses: [1, 5, 12],
      );
      expect(resWithBoth, [5, 12]);

      // Direct normalizeHouses helper test
      final normalized = KPAdvantageFilter.normalizeHouses([1, 4, 7, 12]);
      expect(normalized, [4, 7, 12]);
    });

    test('5. KPAyanamsaEngine: Standard KP Ayanamsa calculation is deterministic', () {
      final dt = DateTime(1996, 6, 15, 8, 30);
      final ayanamsa = KPAyanamsaEngine.calculateAyanamsa(dt, utcOffsetHours: 5.5);
      expect(ayanamsa, greaterThan(23.5));
      expect(ayanamsa, lessThan(24.5));
    });

    test('6. KPNakshatraEngine: 27 Nakshatras & Vimshottari Lords', () {
      // 0° Mesham -> Ashwini, Ketu
      final n0 = KPNakshatraEngine.calculate(0.0);
      expect(n0.nameEn, 'Ashwini');
      expect(n0.lordEn, 'Ketu');
      expect(n0.pada, 1);

      // 10° Mesham -> Ashwini, Pada 4
      final n10 = KPNakshatraEngine.calculate(10.5);
      expect(n10.nameEn, 'Ashwini');
      expect(n10.pada, 4);

      // 14° Mesham -> Bharani, Venus
      final n14 = KPNakshatraEngine.calculate(14.0);
      expect(n14.nameEn, 'Bharani');
      expect(n14.lordEn, 'Venus');
      expect(n14.pada, 1);
    });

    test('7. KPSubLordEngine: Proportional Vimshottari Sub-Lord divisions', () {
      // In Ashwini (Ketu Star, 0° to 13°20'):
      // First sub is Ketu (7/120 * 800' = 46.666' = 0.7777°)
      final sub0 = KPSubLordEngine.calculate(0.1);
      expect(sub0.subLordEn, 'Ketu');

      // Second sub is Venus (20/120 * 800' = 133.333' = 2.222°)
      final sub1 = KPSubLordEngine.calculate(1.0);
      expect(sub1.subLordEn, 'Venus');
    });

    test('8. KPCompleteEngine: End-to-end Astronomical Calculation & Models', () async {
      final testBirth = KPBirthData(
        dateTime: DateTime(1996, 6, 15, 8, 30),
        latitude: 13.0827,
        longitude: 80.2707,
        placeName: 'Chennai, India',
        timeZone: const Duration(hours: 5, minutes: 30),
      );

      final engine = KPCompleteEngine();
      final result = await engine.calculate(birth: testBirth);

      expect(result.isEngineAvailable, true);
      expect(result.planets.length, 9);
      expect(result.cusps.length, 12);
      expect(result.planetSignificators.length, 9);
      expect(result.houseSignificators.length, 12);
      expect(result.rulingPlanets.uniqueRulingPlanets.isNotEmpty, true);
      expect(result.dashaHierarchy.birthBalance.planet.isNotEmpty, true);

      // Verify Ascendant Cusp 1
      final cusp1 = result.cusps.first;
      expect(cusp1.houseNumber, 1);
      expect(cusp1.subLord.isNotEmpty, true);
      expect(cusp1.subSubLord.isNotEmpty, true);

      // Verify Moon Planet
      final moon = result.planets.firstWhere((p) => p.planet == KPPlanet.moon);
      expect(moon.nakshatraNameEn, 'Rohini');
      expect(moon.starLord, 'Moon');
    });

    test('9. KPRectificationEngine: Candidate Generation and Scoring', () {
      final testBirth = KPBirthData(
        dateTime: DateTime(1996, 6, 15, 8, 30),
        latitude: 13.0827,
        longitude: 80.2707,
        placeName: 'Chennai, India',
        timeZone: const Duration(hours: 5, minutes: 30),
      );

      final ruling = KPRulingPlanets(
        dayLord: 'Saturn',
        moonSignLord: 'Venus',
        moonStarLord: 'Moon',
        moonSubLord: 'Saturn',
        ascendantSignLord: 'Moon',
        ascendantStarLord: 'Saturn',
        ascendantSubLord: 'Mercury',
        uniqueRulingPlanets: ['Saturn', 'Venus', 'Moon', 'Mercury'],
      );

      final candidates = KPRectificationEngine.rectify(
        birthData: testBirth,
        rulingPlanets: ruling,
        searchRangeMinutes: 2,
        stepSeconds: 60,
      );

      expect(candidates.isNotEmpty, true);
      expect(candidates.any((c) => c.isBestCandidate), true);
    });
  });
}
