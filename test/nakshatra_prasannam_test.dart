import 'package:flutter_test/flutter_test.dart';
import 'package:astrocall/modules/nakshatra_prasannam/nakshatra_prasannam_data.dart';
import 'package:astrocall/modules/nakshatra_prasannam/nakshatra_prasannam_models.dart';
import 'package:astrocall/modules/nakshatra_prasannam/nakshatra_prasannam_calculator.dart';
import 'package:astrocall/modules/nakshatra_prasannam/nakshatra_prasannam_engine.dart';

void main() {
  group('Nakshatra Prasannam Test Suite', () {
    // 1. Ashwini Test (0.0 to 13.3333 degrees)
    test('1. Ashwini verification', () {
      final pos = NakshatraPrasannaCalculator.getNakshatraPosition(5.0);
      expect(pos.nakshatraIndex, equals(0));
      expect(pos.nakshatraNameTamil, equals('அசுவினி'));
      expect(pos.nakshatraNameEnglish, equals('Ashwini'));
      expect(pos.lord, equals(Planet.ketu));
      expect(pos.pada, equals(2)); // 5.0 deg is in Pada 2 (3.333 - 6.666)
    });

    // 2. Bharani Test (13.3333 to 26.6667 degrees)
    test('2. Bharani verification', () {
      final pos = NakshatraPrasannaCalculator.getNakshatraPosition(20.0);
      expect(pos.nakshatraIndex, equals(1));
      expect(pos.nakshatraNameTamil, equals('பரணி'));
      expect(pos.nakshatraNameEnglish, equals('Bharani'));
      expect(pos.lord, equals(Planet.venus));
    });

    // 3. Krittika Test (26.6667 to 40.0 degrees)
    test('3. Krittika verification', () {
      final pos = NakshatraPrasannaCalculator.getNakshatraPosition(30.0);
      expect(pos.nakshatraIndex, equals(2));
      expect(pos.nakshatraNameTamil, equals('கார்த்திகை'));
      expect(pos.nakshatraNameEnglish, equals('Krittika'));
      expect(pos.lord, equals(Planet.sun));
    });

    // 4. Nakshatra boundary test (exactly 13°20' = 13.333333333333334)
    test('4. Nakshatra boundary verification', () {
      final posJustBefore = NakshatraPrasannaCalculator.getNakshatraPosition(13.3333);
      expect(posJustBefore.nakshatraIndex, equals(0)); // Still Ashwini

      final posAtBoundary = NakshatraPrasannaCalculator.getNakshatraPosition(40.0 / 3.0);
      expect(posAtBoundary.nakshatraIndex, equals(1)); // Exactly Bharani start
      expect(posAtBoundary.pada, equals(1));
      expect(posAtBoundary.traversedDegrees, closeTo(0.0, 0.0001));
    });

    // 5. Pada boundary test (e.g. 3°20' = 3.3333333333333335)
    test('5. Pada boundary verification', () {
      final pada1 = NakshatraPrasannaCalculator.getNakshatraPosition(1.0);
      expect(pada1.pada, equals(1));

      final pada2 = NakshatraPrasannaCalculator.getNakshatraPosition(3.3334);
      expect(pada2.pada, equals(2));

      final pada3 = NakshatraPrasannaCalculator.getNakshatraPosition(6.6668);
      expect(pada3.pada, equals(3));

      final pada4 = NakshatraPrasannaCalculator.getNakshatraPosition(10.0001);
      expect(pada4.pada, equals(4));
    });

    // 6. 360° longitude normalization test
    test('6. 360 degree longitude normalization verification', () {
      expect(NakshatraPrasannaCalculator.normalizeLongitude(360.0), closeTo(0.0, 0.0001));
      expect(NakshatraPrasannaCalculator.normalizeLongitude(725.5), closeTo(5.5, 0.0001));
      expect(NakshatraPrasannaCalculator.normalizeLongitude(-10.0), closeTo(350.0, 0.0001));

      final posRevatiEnd = NakshatraPrasannaCalculator.getNakshatraPosition(359.99);
      expect(posRevatiEnd.nakshatraIndex, equals(26));
      expect(posRevatiEnd.nakshatraNameTamil, equals('ரேவதி'));
      expect(posRevatiEnd.lord, equals(Planet.mercury));
    });

    // 7. Sunrise exactly equal to question time test
    test('7. Sunrise exactly equal to question time', () {
      final sunrise = DateTime(2026, 9, 25, 6, 0, 0);
      final question = DateTime(2026, 9, 25, 6, 0, 0);

      final input = PrasannaInput(
        questionDateTime: question,
        sunriseDateTime: sunrise,
        place: 'Chennai',
        latitude: 13.0827,
        longitude: 80.2707,
        moonSunriseLongitude: 10.0, // Ashwini
        planetLongitudes: {
          Planet.sun: 160.0,
          Planet.moon: 10.0,
          Planet.mars: 45.0,
          Planet.mercury: 155.0,
          Planet.jupiter: 75.0,
          Planet.venus: 130.0,
          Planet.saturn: 340.0,
          Planet.rahu: 330.0,
          Planet.ketu: 150.0,
        },
        ascendantLongitude: 165.0,
      );

      final errors = NakshatraPrasannaEngine.validateInput(input);
      expect(errors.isEmpty, isTrue);

      final result = NakshatraPrasannaEngine.calculate(input);
      expect(result.hrm.hrmPlanet, equals(result.drm.lord)); // Must be DRM lord at sunrise!
      expect(result.hrm.elapsedMinutes, equals(0.0));
      expect(result.hrm.startTime, equals(sunrise));
    });

    // 8. Question time after multiple Nakshatra transitions (e.g. 10 hours after sunrise)
    test('8. Question time after multiple transitions', () {
      final sunrise = DateTime(2026, 9, 25, 6, 0, 0);
      final question = DateTime(2026, 9, 25, 16, 30, 0); // 10.5 hours later

      final input = PrasannaInput(
        questionDateTime: question,
        sunriseDateTime: sunrise,
        place: 'Chennai',
        latitude: 13.0827,
        longitude: 80.2707,
        moonSunriseLongitude: 10.0,
        planetLongitudes: {
          Planet.sun: 160.0,
          Planet.moon: 15.0,
          Planet.mars: 45.0,
          Planet.mercury: 155.0,
          Planet.jupiter: 75.0,
          Planet.venus: 130.0,
          Planet.saturn: 340.0,
          Planet.rahu: 330.0,
          Planet.ketu: 150.0,
        },
        ascendantLongitude: 210.0,
      );

      final result = NakshatraPrasannaEngine.calculate(input);
      expect(result.hrm.timeline.isNotEmpty, isTrue);
      expect(result.hrm.startTime.isBefore(question) || result.hrm.startTime.isAtSameMomentAs(question), isTrue);
      expect(result.hrm.endTime.isAfter(question), isTrue);
    });

    // 9. Missing Ascendant test (Ensures no crash)
    test('9. Missing Ascendant does not crash', () {
      final sunrise = DateTime(2026, 9, 25, 6, 0, 0);
      final question = DateTime(2026, 9, 25, 9, 0, 0);

      final input = PrasannaInput(
        questionDateTime: question,
        sunriseDateTime: sunrise,
        place: 'Chennai',
        latitude: 13.0827,
        longitude: 80.2707,
        moonSunriseLongitude: 45.0, // Rohini
        planetLongitudes: {
          Planet.sun: 160.0,
          Planet.moon: 45.0,
          Planet.mars: 45.0,
          Planet.mercury: 155.0,
          Planet.jupiter: 75.0,
          Planet.venus: 130.0,
          Planet.saturn: 340.0,
          Planet.rahu: 330.0,
          Planet.ketu: 150.0,
        },
        ascendantLongitude: null, // MISSING ASCENDANT
      );

      final result = NakshatraPrasannaEngine.calculate(input);
      expect(result.drm.nakshatraNameTamil, equals('ரோகிணி'));
      expect(result.npl, isNotNull);
      // NPL default bhava calculation without crash
      expect(result.npl!.bhava, equals(1));
    });

    // 10. Missing HRM planet longitude (Ensures no crash)
    test('10. Missing HRM planet longitude does not crash', () {
      final sunrise = DateTime(2026, 9, 25, 6, 0, 0);
      final question = DateTime(2026, 9, 25, 6, 10, 0);

      final input = PrasannaInput(
        questionDateTime: question,
        sunriseDateTime: sunrise,
        place: 'Chennai',
        latitude: 13.0827,
        longitude: 80.2707,
        moonSunriseLongitude: 5.0, // Ashwini -> Lord Ketu
        planetLongitudes: {
          // Ketu intentionally omitted from map!
          Planet.sun: 160.0,
          Planet.moon: 5.0,
          Planet.mars: 45.0,
          Planet.mercury: 155.0,
          Planet.jupiter: 75.0,
          Planet.venus: 130.0,
          Planet.saturn: 340.0,
          Planet.rahu: 330.0,
        },
        ascendantLongitude: 100.0,
      );

      expect(() => NakshatraPrasannaEngine.calculate(input), returnsNormally);
      final result = NakshatraPrasannaEngine.calculate(input);
      expect(result.hrm.hrmPlanet, equals(Planet.ketu));
      // Handled gracefully without crash
    });
  });
}
