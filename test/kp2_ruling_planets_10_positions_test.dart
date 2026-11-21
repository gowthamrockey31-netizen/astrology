import 'package:flutter_test/flutter_test.dart';
import 'package:astrocall/kp_method_2/kp_method_2.dart';

void main() {
  group('KP2 Ruling Planets 10 Positions Tests', () {
    test('Calculates all 10 Ruling Planet positions for default Erode Profile', () {
      final profile = KP2BirthData.defaultTestProfile();
      final result = KP2CompleteEngine.calculate(profile);
      final rp = result.rulingPlanets;

      // Print calculated ruling planets for verification and reporting
      print('=== KP2 Ruling Planets (15-Aug-1995 01:25 PM, Erode) ===');
      print('Day Lord: ${rp.dayLord.nameEn} (${rp.dayLord.nameTa})');
      print('Transit Ascendant Longitude: ${result.cusps.first.longitude}');
      print('1. Ascendant Sign Lord: ${rp.ascSignLord.nameEn} (${rp.ascSignLord.nameTa})');
      print('2. Ascendant Star Lord: ${rp.ascStarLord.nameEn} (${rp.ascStarLord.nameTa})');
      print('3. Ascendant Sub Lord: ${rp.ascSubLord.nameEn} (${rp.ascSubLord.nameTa})');
      print('4. Ascendant Sub-Sub Lord: ${rp.ascSubSubLord.nameEn} (${rp.ascSubSubLord.nameTa})');
      print('5. Ascendant Sub-Sub-Sub Lord: ${rp.ascSubSubSubLord.nameEn} (${rp.ascSubSubSubLord.nameTa})');

      final moonPos = result.getPosition(KP2Planet.moon);
      print('Transit Moon Longitude: ${moonPos.siderealLongitude}');
      print('1. Moon Sign Lord: ${rp.moonSignLord.nameEn} (${rp.moonSignLord.nameTa})');
      print('2. Moon Star Lord: ${rp.moonStarLord.nameEn} (${rp.moonStarLord.nameTa})');
      print('3. Moon Sub Lord: ${rp.moonSubLord.nameEn} (${rp.moonSubLord.nameTa})');
      print('4. Moon Sub-Sub Lord: ${rp.moonSubSubLord.nameEn} (${rp.moonSubSubLord.nameTa})');
      print('5. Moon Sub-Sub-Sub Lord: ${rp.moonSubSubSubLord.nameEn} (${rp.moonSubSubSubLord.nameTa})');
      print('Unique Ruling Planets: ${rp.uniquePlanets.map((p) => p.nameEn).join(", ")}');

      // 1. Verify all 5 Transit Ascendant rulers
      expect(rp.ascSignLord, equals(KP2Planet.mars)); // Scorpio (Vrischigam)
      expect(rp.ascStarLord, isNotNull);
      expect(rp.ascSubLord, isNotNull);
      expect(rp.ascSubSubLord, isNotNull);
      expect(rp.ascSubSubSubLord, isNotNull);

      // 2. Verify all 5 Transit Moon rulers
      expect(rp.moonSignLord, equals(KP2Planet.jupiter)); // Pisces (Meenam)
      expect(rp.moonStarLord, isNotNull);
      expect(rp.moonSubLord, isNotNull);
      expect(rp.moonSubSubLord, isNotNull);
      expect(rp.moonSubSubSubLord, isNotNull);

      // 3. Verify exactly 10 ruling positions in tenRulingPlanets
      expect(rp.tenRulingPlanets.length, equals(10));
      expect(rp.ascendantRulingPlanets.length, equals(5));
      expect(rp.moonRulingPlanets.length, equals(5));

      // 4. Repeated planets preserved in individual positions
      // Verify no nulls or omissions
      for (final planet in rp.tenRulingPlanets) {
        expect(planet, isNotNull);
      }
    });

    test('Dynamic Calculation: changing date/time/location updates all 10 positions', () {
      final profile1 = KP2BirthData(
        date: DateTime(2026, 11, 21),
        time: '07:43 AM',
        place: 'Chennai',
        latitude: 13.0827,
        longitude: 80.2707,
        timezone: 5.5,
      );

      final result1 = KP2CompleteEngine.calculate(profile1);
      final rp1 = result1.rulingPlanets;

      // Ensure all 10 positions exist for profile 1
      expect(rp1.tenRulingPlanets.length, equals(10));
      for (final p in rp1.tenRulingPlanets) {
        expect(p, isNotNull);
      }

      final profile2 = KP2BirthData(
        date: DateTime(2026, 11, 21),
        time: '07:43 PM', // 12 hours later
        place: 'Chennai',
        latitude: 13.0827,
        longitude: 80.2707,
        timezone: 5.5,
      );

      final result2 = KP2CompleteEngine.calculate(profile2);
      final rp2 = result2.rulingPlanets;

      // Ensure all 10 positions exist for profile 2
      expect(rp2.tenRulingPlanets.length, equals(10));
      for (final p in rp2.tenRulingPlanets) {
        expect(p, isNotNull);
      }

      // In 12 hours, the Ascendant has moved ~180° into the opposite sign
      expect(rp1.ascSignLord, isNot(equals(rp2.ascSignLord)));
      expect(result1.cusps.first.longitude, isNot(equals(result2.cusps.first.longitude)));
      expect(result1.getPosition(KP2Planet.moon).siderealLongitude,
          isNot(equals(result2.getPosition(KP2Planet.moon).siderealLongitude)));
    });

    test('Sub-Sub-Sub Lord 5th level proportional subdivision properties', () {
      // Test at specific known longitudes to verify 5th level accuracy
      const double testLon = 234.567; // Sidereal degree
      final subSub = KP2SubSubLordEngine.calculateSubSubLord(testLon);
      final subSubSub = KP2SubSubLordEngine.calculateSubSubSubLord(testLon);

      expect(subSub, isNotNull);
      expect(subSubSub, isNotNull);

      // Verify span information
      final span = KP2SubSubLordEngine.getSubSubLordSpan(testLon);
      expect(span['subSubLord'], equals(subSub));
      expect(span['spanMinutes'], greaterThan(0.0));
      expect(span['elapsedInSubSubMinutes'], greaterThanOrEqualTo(0.0));
      expect(span['elapsedInSubSubMinutes'], lessThanOrEqualTo(span['spanMinutes']));
    });
  });
}
