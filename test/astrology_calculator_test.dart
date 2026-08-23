import 'package:flutter_test/flutter_test.dart';
import 'package:astrocall/services/astrology_calculator.dart';
import 'package:astrocall/core/utils/astrology_calculator.dart' as util;

void main() {
  group('AstrologyCalculator Core Engine Tests', () {
    test('calculateHoroscope returns valid 11 sidereal planet details', () {
      final dob = DateTime(1996, 6, 15, 8, 30);
      final res = AstrologyCalculator.calculateHoroscope(
        dateOfBirth: dob,
        latitude: 13.0827,
        longitude: 80.2707,
        utcOffsetHours: 5.5,
      );

      final Map<String, PlanetDetail> planets = res['planets'];
      expect(planets.length, equals(11));
      expect(planets.containsKey('Sun'), isTrue);
      expect(planets.containsKey('Moon'), isTrue);
      expect(planets.containsKey('Lagna'), isTrue);
      expect(planets.containsKey('Mandi'), isTrue);
    });

    test('getLahiriAyanamsa calculates ~23.85° to 24.10° for J2000 epoch', () {
      final ayanamsa = AstrologyCalculator.getLahiriAyanamsa(DateTime(2000, 1, 1));
      expect(ayanamsa, greaterThan(23.5));
      expect(ayanamsa, lessThan(24.5));
    });

    test('calculateZodiac returns valid non-empty string', () {
      final dob = DateTime(1995, 4, 10);
      final zodiac = util.AstrologyCalculator.calculateZodiac(dob);
      expect(zodiac.isNotEmpty, isTrue);
    });

    test('calculateNakshatra returns valid Nakshatra name', () {
      final dob = DateTime(1996, 6, 15);
      final nakshatra = util.AstrologyCalculator.calculateNakshatra(dob, '08:30 AM');
      expect(nakshatra.isNotEmpty, isTrue);
    });

    test('calculateLagna returns valid Lagna name', () {
      final lagna = util.AstrologyCalculator.calculateLagna('08:30 AM');
      expect(lagna.isNotEmpty, isTrue);
    });

    test('calculateCurrentDasha returns Dasha string', () {
      final dob = DateTime(1990, 1, 1);
      final dasha = util.AstrologyCalculator.calculateCurrentDasha(dob);
      expect(dasha, contains('Mahadasha'));
    });
  });
}
