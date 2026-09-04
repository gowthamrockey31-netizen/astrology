import 'package:flutter_test/flutter_test.dart';
import 'package:astrocall/services/astrology_calculator.dart';

void main() {
  group('Birth Chart Planetary Degree Calculation & Formatting Tests', () {
    test('Test 1: Aries (15.425° -> Aries 15° 25\' 30")', () {
      const double lon = 15.425;
      final int rasiIdx = (lon / 30.0).floor() % 12;
      final double degInRasi = lon - (rasiIdx * 30.0);
      final String formatted = AstrologyCalculator.formatDMS(degInRasi);

      expect(rasiIdx, 0); // Aries / Mesham
      expect(AstrologyCalculator.rasiNamesEn[rasiIdx], 'Aries');
      expect(AstrologyCalculator.rasiNamesTa[rasiIdx], 'மேஷம்');
      expect(formatted, "15°25'30\"");
    });

    test('Test 2: Taurus (45.425° -> Taurus 15° 25\' 30")', () {
      const double lon = 45.425;
      final int rasiIdx = (lon / 30.0).floor() % 12;
      final double degInRasi = lon - (rasiIdx * 30.0);
      final String formatted = AstrologyCalculator.formatDMS(degInRasi);

      expect(rasiIdx, 1); // Taurus / Rishabam
      expect(AstrologyCalculator.rasiNamesEn[rasiIdx], 'Taurus');
      expect(AstrologyCalculator.rasiNamesTa[rasiIdx], 'ரிஷபம்');
      expect(formatted, "15°25'30\"");
    });

    test('Test 3: Rasi Boundary (29.999° -> Aries 29° 59\' 56" and never 30°)', () {
      const double lon = 29.999;
      final int rasiIdx = (lon / 30.0).floor() % 12;
      final double degInRasi = lon - (rasiIdx * 30.0);
      final String formatted = AstrologyCalculator.formatDMS(degInRasi);

      expect(rasiIdx, 0); // Aries
      expect(formatted, isNot(contains('30°')));
      expect(formatted, isNot(contains("60'")));
      expect(formatted, isNot(contains('60"')));
      expect(formatted, "29°59'56\"");
    });

    test('Test 4: Next Rasi Boundary (30.000° -> Taurus 00° 00\' 00")', () {
      const double lon = 30.000;
      final int rasiIdx = (lon / 30.0).floor() % 12;
      final double degInRasi = lon - (rasiIdx * 30.0);
      final String formatted = AstrologyCalculator.formatDMS(degInRasi);

      expect(rasiIdx, 1); // Taurus
      expect(formatted, "00°00'00\"");
    });

    test('Test 5: Zodiac End (359.999° -> Pisces 29° 59\' 56")', () {
      const double lon = 359.999;
      final int rasiIdx = (lon / 30.0).floor() % 12;
      final double degInRasi = lon - (rasiIdx * 30.0);
      final String formatted = AstrologyCalculator.formatDMS(degInRasi);

      expect(rasiIdx, 11); // Pisces
      expect(AstrologyCalculator.rasiNamesEn[rasiIdx], 'Pisces');
      expect(formatted, isNot(contains('30°')));
      expect(formatted, "29°59'56\"");
    });

    test('Test 6: 360° Normalization (360.0° -> Aries 00° 00\' 00")', () {
      const double lon = 360.0;
      final normLon = ((lon % 360.0) + 360.0) % 360.0;
      final int rasiIdx = (normLon / 30.0).floor() % 12;
      final double degInRasi = normLon - (rasiIdx * 30.0);
      final String formatted = AstrologyCalculator.formatDMS(degInRasi);

      expect(rasiIdx, 0); // Aries
      expect(formatted, "00°00'00\"");
    });

    test('Test 7: Negative Longitude Normalization (-0.5° -> Pisces 29° 30\' 00")', () {
      const double lon = -0.5;
      final normLon = ((lon % 360.0) + 360.0) % 360.0;
      final int rasiIdx = (normLon / 30.0).floor() % 12;
      final double degInRasi = normLon - (rasiIdx * 30.0);
      final String formatted = AstrologyCalculator.formatDMS(degInRasi);

      expect(normLon, 359.5);
      expect(rasiIdx, 11); // Pisces
      expect(formatted, "29°30'00\"");
    });

    test('Test 8: Decimal Conversion (15.25° -> 15° 15\' 00" NOT 15° 25\')', () {
      final String formatted = AstrologyCalculator.formatDMS(15.25);
      expect(formatted, "15°15'00\"");
      expect(formatted, isNot("15°25'00\""));
    });

    test('Test 9: All Planets in calculateHoroscope have valid ranges & DMS', () {
      final horoscope = AstrologyCalculator.calculateHoroscope(
        dateOfBirth: DateTime(1996, 6, 15, 8, 30, 45),
        latitude: 13.0827,
        longitude: 80.2707,
        utcOffsetHours: 5.5,
      );

      final planets = horoscope.planets;
      expect(planets.length, 11);

      final dmsPattern = RegExp(r'^[0-2][0-9]°[0-5][0-9]\x27[0-5][0-9]"$');

      for (final entry in planets.entries) {
        final p = entry.value;

        // Longitude must be within 0° to 360°
        expect(p.longitude, greaterThanOrEqualTo(0.0));
        expect(p.longitude, lessThan(360.0));

        // Rasi index must be 0..11
        expect(p.rasiIndex, inInclusiveRange(0, 11));

        // Degree in Rasi must be strictly in [0.0, 30.0)
        expect(p.degreeInRasi, greaterThanOrEqualTo(0.0));
        expect(p.degreeInRasi, lessThan(30.0));

        // DMS formatted must match DD°MM'SS" with valid ranges
        expect(
          dmsPattern.hasMatch(p.degreeFormatted),
          isTrue,
          reason: 'Planet ${p.name} formatted as ${p.degreeFormatted} is invalid',
        );

        // Nakshatra and Pada must be valid
        expect(p.nakshatraIndex, inInclusiveRange(0, 26));
        expect(p.pada, inInclusiveRange(1, 4));
      }
    });

    test('Test 10: Dynamic Calculation with different coordinates & dates', () {
      final chart1 = AstrologyCalculator.calculateHoroscope(
        dateOfBirth: DateTime(1985, 11, 2, 5, 45),
        latitude: 10.7905,
        longitude: 78.7047,
        utcOffsetHours: 5.5,
      );

      final chart2 = AstrologyCalculator.calculateHoroscope(
        dateOfBirth: DateTime(2000, 1, 1, 12, 0),
        latitude: 28.6139,
        longitude: 77.2090,
        utcOffsetHours: 5.5,
      );

      expect(chart1.sun.rasiNameEn, isNotEmpty);
      expect(chart2.sun.rasiNameEn, isNotEmpty);
      expect(chart1.sun.degreeFormatted, isNotEmpty);
      expect(chart2.sun.degreeFormatted, isNotEmpty);
    });

    test('User Specification Boundary Tests (Cases 1 to 5)', () {
      // CASE 1: longitude = 0.0 -> Expected: மேஷம் 00°00'00"
      final p1 = PlanetDetail.fromSiderealLongitude(name: 'Sun', tamilName: 'சூரியன்', symbol: 'சூ', longitude: 0.0);
      expect(p1.rasiNameTa, 'மேஷம்');
      expect(p1.degreeFormatted, '00°00\'00"');
      expect(AstrologyCalculator.formatRasiDegree(0.0), '00°00\'00"');

      // CASE 2: longitude = 29.999999 -> Expected: Next valid Rasi (ரிஷபம்) 00°00'00", never 29°59'60" or 30°
      final p2 = PlanetDetail.fromSiderealLongitude(name: 'Sun', tamilName: 'சூரியன்', symbol: 'சூ', longitude: 29.999999);
      expect(p2.rasiNameTa, 'ரிஷபம்');
      expect(p2.degreeFormatted, '00°00\'00"');
      expect(p2.degreeFormatted, isNot(contains('30°')));
      expect(p2.degreeFormatted, isNot(contains('60"')));
      expect(AstrologyCalculator.formatRasiDegree(29.999999), '00°00\'00"');

      // CASE 3: longitude = 30.0 -> Expected: ரிஷபம் 00°00'00"
      final p3 = PlanetDetail.fromSiderealLongitude(name: 'Sun', tamilName: 'சூரியன்', symbol: 'சூ', longitude: 30.0);
      expect(p3.rasiNameTa, 'ரிஷபம்');
      expect(p3.degreeFormatted, '00°00\'00"');
      expect(AstrologyCalculator.formatRasiDegree(30.0), '00°00\'00"');

      // CASE 4: longitude = 53.234444 -> Expected: ரிஷபம் 23°14'04"
      final p4 = PlanetDetail.fromSiderealLongitude(name: 'Sun', tamilName: 'சூரியன்', symbol: 'சூ', longitude: 53.234444);
      expect(p4.rasiNameTa, 'ரிஷபம்');
      expect(p4.degreeFormatted, '23°14\'04"');
      expect(AstrologyCalculator.formatRasiDegree(53.234444), '23°14\'04"');

      // CASE 5: longitude = 359.999999 -> Expected: மீனம் with correct final DMS rounding and no invalid 30°
      final p5 = PlanetDetail.fromSiderealLongitude(name: 'Sun', tamilName: 'சூரியன்', symbol: 'சூ', longitude: 359.999999);
      expect(p5.rasiNameTa, 'மீனம்');
      expect(p5.degreeFormatted, isNot(contains('30°')));
      expect(p5.degreeFormatted, isNot(contains('60"')));
      expect(p5.degreeFormatted, '29°59\'59"');
      expect(AstrologyCalculator.formatRasiDegree(359.999999), '29°59\'59"');
    });

    test('User Specification Test with Birth Data (15-08-1995, 1:25 PM, Erode, TN)', () {
      final dt = DateTime(1995, 8, 15, 13, 25);
      final result = AstrologyCalculator.calculateHoroscope(
        dateOfBirth: dt,
        latitude: 11.3410,
        longitude: 77.7172,
        utcOffsetHours: 5.5,
      );

      final dmsPattern = RegExp(r'^[0-2][0-9]°[0-5][0-9]\x27[0-5][0-9]"$');

      for (final entry in result.planets.entries) {
        final p = entry.value;

        // Longitude must be within 0° to 360°
        expect(p.longitude, greaterThanOrEqualTo(0.0));
        expect(p.longitude, lessThan(360.0));

        // Rasi index must be 0..11
        expect(p.rasiIndex, inInclusiveRange(0, 11));

        // Degree in Rasi must be strictly in [0.0, 30.0)
        expect(p.degreeInRasi, greaterThanOrEqualTo(0.0));
        expect(p.degreeInRasi, lessThan(30.0));

        // Formatted degree must be strictly 2-digit DD°MM'SS" and NEVER absolute longitude
        expect(dmsPattern.hasMatch(p.degreeFormatted), isTrue);
        expect(p.degreeFormatted.length, 9); // e.g. "23°14'04"" is exactly 9 characters
        expect(int.parse(p.degreeFormatted.substring(0, 2)), lessThan(30)); // First 2 digits < 30
      }
    });
  });
}
