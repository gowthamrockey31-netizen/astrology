import 'package:flutter_test/flutter_test.dart';
import 'package:astrocall/kp_method_2/kp_method_2.dart';

void main() {
  group('KP Method 2 Engine Tests', () {
    test('Calculates Complete KP2 Result for Default Erode Profile', () {
      final profile = KP2BirthData.defaultTestProfile();
      final result = KP2CompleteEngine.calculate(profile);

      // Verify Julian Day & Ayanamsa
      expect(result.julianDay, greaterThan(2449944.0));
      expect(result.ayanamsa, closeTo(23.79, 0.5)); // ~23° 47' in 1995
      expect(result.ayanamsaDms, contains('°'));

      // Verify 9 Planets
      expect(result.planetPositions.length, equals(9));
      final sun = result.getPosition(KP2Planet.sun);
      final moon = result.getPosition(KP2Planet.moon);
      final jupiter = result.getPosition(KP2Planet.jupiter);

      // On 15 Aug 1995: Sun is entering Leo (Simmam) or late Cancer
      expect(sun.rasiNameTa, isNotEmpty);
      expect(sun.formattedDms, contains('°'));
      expect(sun.starLord, isNotNull);
      expect(sun.subLord, isNotNull);
      expect(sun.subSubLord, isNotNull);

      // Moon in Revati (Pisces/Meenam) on 15 Aug 1995
      expect(moon.nakshatraNameTa, isNotEmpty);
      expect(moon.occupiedHouse, inInclusiveRange(1, 12));

      // Verify 12 Placidus Cusps
      expect(result.cusps.length, equals(12));
      for (int i = 0; i < 12; i++) {
        final cusp = result.cusps[i];
        expect(cusp.house, equals(i + 1));
        expect(cusp.rasiNameTa, isNotEmpty);
        expect(cusp.signLord, isNotNull);
        expect(cusp.starLord, isNotNull);
        expect(cusp.subLord, isNotNull);
        expect(cusp.subSubLord, isNotNull);
      }

      // Verify Ruling Planets (5 Transit Ascendant + 5 Transit Moon = 10 positions + Day Lord = 11 total)
      expect(result.rulingPlanets.allPlanets.length, equals(11));
      expect(result.rulingPlanets.tenRulingPlanets.length, equals(10));
      expect(result.rulingPlanets.ascendantRulingPlanets.length, equals(5));
      expect(result.rulingPlanets.moonRulingPlanets.length, equals(5));
      expect(result.rulingPlanets.uniquePlanets.length, inInclusiveRange(1, 9));
      expect(result.rulingPlanets.dayLord, isNotNull);

      // Verify Transit Ascendant 5 Rulers
      expect(result.rulingPlanets.ascSignLord, isNotNull);
      expect(result.rulingPlanets.ascStarLord, isNotNull);
      expect(result.rulingPlanets.ascSubLord, isNotNull);
      expect(result.rulingPlanets.ascSubSubLord, isNotNull);
      expect(result.rulingPlanets.ascSubSubSubLord, isNotNull);

      // Verify Transit Moon 5 Rulers
      expect(result.rulingPlanets.moonSignLord, isNotNull);
      expect(result.rulingPlanets.moonStarLord, isNotNull);
      expect(result.rulingPlanets.moonSubLord, isNotNull);
      expect(result.rulingPlanets.moonSubSubLord, isNotNull);
      expect(result.rulingPlanets.moonSubSubSubLord, isNotNull);

      // Verify Significators & Advantage Filter
      expect(result.planetSignificators.length, equals(9));
      expect(result.houseSignificators.length, equals(12));

      // Verify Dasha Balance & Timeline
      expect(result.dashaBalance.years, inInclusiveRange(0, 20));
      expect(result.dashaBalance.formattedTamil, contains('தசா இருப்பு'));
      expect(result.dashaTimeline.isNotEmpty, isTrue);
      expect(result.dashaTimeline.length, equals(9));
      expect(result.dashaTimeline.first.subPeriods.length, equals(9));
    });

    test('KP2 Advantage Filter Rules', () {
      // Rule 1: Star Even + Sub Odd -> Sub priority
      final r1 = KP2AdvantageFilter.filter(
        starHouses: [2, 4, 6],
        subHouses: [3, 5, 7],
      );
      expect(r1, equals([3, 5, 7]));

      // Rule 2: Star Odd + Sub Even -> Star priority
      final r2 = KP2AdvantageFilter.filter(
        starHouses: [1, 5, 9],
        subHouses: [2, 6, 10],
      );
      // Note: [1, 5, 9] does not contain 12, so 1 remains
      expect(r2, equals([1, 5, 9]));

      // Rule 4: 1 + 12 together -> 12 ONLY
      final r4 = KP2AdvantageFilter.cleanHouses([1, 4, 7, 10, 12]);
      expect(r4, equals([4, 7, 10, 12]));
      expect(r4.contains(1), isFalse);
    });
  });
}
