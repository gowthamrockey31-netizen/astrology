import 'package:flutter_test/flutter_test.dart';
import 'package:astrocall/services/astrology_calculator.dart';

void main() {
  group('Astrology Calculation Standardization & Accuracy Tests', () {
    // Helper to construct longitude from DMS
    double dmsToDeg(int deg, int min, [double sec = 0.0]) {
      return deg + (min / 60.0) + (sec / 3600.0);
    }

    // ==========================================
    // TEST A: RASI BOUNDARIES
    // ==========================================
    test('TEST A: Rasi Boundaries & Arcsecond Mapping', () {
      final testCases = [
        {'dms': dmsToDeg(0, 0, 0), 'expectedRasi': 0, 'nameTa': 'மேஷம்', 'nameEn': 'Aries'},
        {'dms': dmsToDeg(29, 59, 59), 'expectedRasi': 0, 'nameTa': 'மேஷம்', 'nameEn': 'Aries'},
        {'dms': dmsToDeg(30, 0, 0), 'expectedRasi': 1, 'nameTa': 'ரிஷபம்', 'nameEn': 'Taurus'},
        {'dms': dmsToDeg(59, 59, 59), 'expectedRasi': 1, 'nameTa': 'ரிஷபம்', 'nameEn': 'Taurus'},
        {'dms': dmsToDeg(60, 0, 0), 'expectedRasi': 2, 'nameTa': 'மிதுனம்', 'nameEn': 'Gemini'},
        {'dms': dmsToDeg(359, 59, 59), 'expectedRasi': 11, 'nameTa': 'மீனம்', 'nameEn': 'Pisces'},
      ];

      for (final tc in testCases) {
        final double lon = tc['dms'] as double;
        final detail = AstrologyCalculator.calculateNakshatraPadaFromLongitude(lon);
        expect(detail['nakshatraIndex'], inInclusiveRange(0, 26));
        final int totalSecs = (lon * 3600.0).round() % AstrologyCalculator.totalArcseconds;
        final int rasiIdx = totalSecs ~/ AstrologyCalculator.arcsecondsPerRasi;

        expect(rasiIdx, tc['expectedRasi'], reason: 'Failed for degree: $lon');
        expect(AstrologyCalculator.rasiNamesTa[rasiIdx], tc['nameTa']);
        expect(AstrologyCalculator.rasiNamesEn[rasiIdx], tc['nameEn']);
      }
    });

    // ==========================================
    // TEST B: NAKSHATRA / PADA BOUNDARIES
    // ==========================================
    test('TEST B: Nakshatra & Pada Exact Boundaries', () {
      final boundaryCases = [
        // 0°00'00" -> Nakshatra 0 (Ashwini), Pada 1
        {'lon': dmsToDeg(0, 0, 0), 'nak': 0, 'pada': 1, 'nameTa': 'அஸ்வினி', 'nameEn': 'Ashwini'},
        // 3°19'59" -> Pada 1
        {'lon': dmsToDeg(3, 19, 59), 'nak': 0, 'pada': 1, 'nameTa': 'அஸ்வினி', 'nameEn': 'Ashwini'},
        // 3°20'00" -> Pada 2
        {'lon': dmsToDeg(3, 20, 0), 'nak': 0, 'pada': 2, 'nameTa': 'அஸ்வினி', 'nameEn': 'Ashwini'},
        // 6°39'59" -> Pada 2
        {'lon': dmsToDeg(6, 39, 59), 'nak': 0, 'pada': 2, 'nameTa': 'அஸ்வினி', 'nameEn': 'Ashwini'},
        // 6°40'00" -> Pada 3
        {'lon': dmsToDeg(6, 40, 0), 'nak': 0, 'pada': 3, 'nameTa': 'அஸ்வினி', 'nameEn': 'Ashwini'},
        // 9°59'59" -> Pada 3
        {'lon': dmsToDeg(9, 59, 59), 'nak': 0, 'pada': 3, 'nameTa': 'அஸ்வினி', 'nameEn': 'Ashwini'},
        // 10°00'00" -> Pada 4
        {'lon': dmsToDeg(10, 0, 0), 'nak': 0, 'pada': 4, 'nameTa': 'அஸ்வினி', 'nameEn': 'Ashwini'},
        // 13°19'59" -> Current Nakshatra (Ashwini), Pada 4
        {'lon': dmsToDeg(13, 19, 59), 'nak': 0, 'pada': 4, 'nameTa': 'அஸ்வினி', 'nameEn': 'Ashwini'},
        // 13°20'00" -> Next Nakshatra (Bharani), Pada 1
        {'lon': dmsToDeg(13, 20, 0), 'nak': 1, 'pada': 1, 'nameTa': 'பரணி', 'nameEn': 'Bharani'},
      ];

      for (final bc in boundaryCases) {
        final double lon = bc['lon'] as double;
        final res = AstrologyCalculator.calculateNakshatraPadaFromLongitude(lon);

        expect(res['nakshatraIndex'], bc['nak'], reason: 'Failed nakshatra at lon $lon');
        expect(res['pada'], bc['pada'], reason: 'Failed pada at lon $lon');
        expect(res['nakshatraNameTa'], bc['nameTa']);
        expect(res['nakshatraNameEn'], bc['nameEn']);
      }
    });

    // ==========================================
    // TEST C: NAVAMSA DIVISIONS & SEQUENCES (ALL 12 RASIS, 108 NAVAMSA PADAS)
    // ==========================================
    test('TEST C: Navamsa sequence for Movable, Fixed, and Dual Rasis across all 12 Signs', () {
      final divisionOffsets = [
        dmsToDeg(0, 0, 0),   // Part 0 (0°00')
        dmsToDeg(3, 20, 0),  // Part 1 (3°20')
        dmsToDeg(6, 40, 0),  // Part 2 (6°40')
        dmsToDeg(10, 0, 0),  // Part 3 (10°00')
        dmsToDeg(13, 20, 0), // Part 4 (13°20')
        dmsToDeg(16, 40, 0), // Part 5 (16°40')
        dmsToDeg(20, 0, 0),  // Part 6 (20°00')
        dmsToDeg(23, 20, 0), // Part 7 (23°20')
        dmsToDeg(26, 40, 0), // Part 8 (26°40')
      ];

      // Test all 12 Signs
      final expectedStarts = [
        0, // Mesham (Movable) -> 0 (Mesham)
        9, // Rishabam (Fixed) -> 9 (Magaram)
        6, // Mithunam (Dual) -> 6 (Thulam)
        3, // Kadagam (Movable) -> 3 (Kadagam)
        0, // Simmam (Fixed) -> 0 (Mesham)
        9, // Kanni (Dual) -> 9 (Magaram)
        6, // Thulam (Movable) -> 6 (Thulam)
        3, // Viruchigam (Fixed) -> 3 (Kadagam)
        0, // Dhanusu (Dual) -> 0 (Mesham)
        9, // Magaram (Movable) -> 9 (Magaram)
        6, // Kumbam (Fixed) -> 6 (Thulam)
        3, // Meenam (Dual) -> 3 (Kadagam)
      ];

      for (int rasi = 0; rasi < 12; rasi++) {
        final expectedStart = expectedStarts[rasi];
        expect(AstrologyCalculator.calculateNavamsaStartIndex(rasi), expectedStart,
            reason: 'Navamsa start index mismatch for Rasi $rasi (${AstrologyCalculator.rasiNamesEn[rasi]})');

        for (int part = 0; part < 9; part++) {
          final double lon = (rasi * 30.0) + divisionOffsets[part];
          final int totalSecs = (lon * 3600.0).round() % AstrologyCalculator.totalArcseconds;
          final int rasiIdx = totalSecs ~/ AstrologyCalculator.arcsecondsPerRasi;
          final int rasiSecs = totalSecs % AstrologyCalculator.arcsecondsPerRasi;
          final int navPart = rasiSecs ~/ AstrologyCalculator.arcsecondsPerPada;
          final int navRasi = AstrologyCalculator.calculateNavamsaRasiIndex(rasiIdx, navPart);

          expect(rasiIdx, rasi);
          expect(navPart, part);
          expect(navRasi, (expectedStart + part) % 12,
              reason: 'Navamsa mismatch for Rasi $rasi, Part $part');
        }
      }
    });

    // ==========================================
    // TEST D: FULL PLANET CONSISTENCY & INTEGRATION
    // ==========================================
    test('TEST D: Complete Horoscope All Planets derive from Single Source Longitude', () {
      final horoscope = AstrologyCalculator.calculateHoroscope(
        dateOfBirth: DateTime(1996, 6, 15, 8, 30, 0),
        latitude: 13.0827,
        longitude: 80.2707,
        utcOffsetHours: 5.5,
      );

      final planetKeys = ['Lagna', 'Sun', 'Moon', 'Mars', 'Mercury', 'Jupiter', 'Venus', 'Saturn', 'Rahu', 'Ketu', 'Mandi'];

      for (final key in planetKeys) {
        final p = horoscope.planets[key]!;

        // 1. Longitude within [0, 360)
        expect(p.longitude, greaterThanOrEqualTo(0.0));
        expect(p.longitude, lessThan(360.0));

        // 2. Arcsecond Source Consistency
        final int expectedArcsecs = (p.longitude * 3600.0).round() % 1296000;
        expect(p.totalArcseconds, expectedArcsecs);

        // 3. Rasi derivation from exact arcseconds
        final int expectedRasi = expectedArcsecs ~/ 108000;
        expect(p.rasiIndex, expectedRasi);
        expect(p.degreeInRasi, closeTo(p.longitude - (expectedRasi * 30.0), 1e-7));

        // 4. Nakshatra derivation from exact arcseconds
        final int expectedNak = expectedArcsecs ~/ 48000;
        expect(p.nakshatraIndex, expectedNak);

        // 5. Pada derivation from exact arcseconds
        final int expectedPada = ((expectedArcsecs % 48000) ~/ 12000) + 1;
        expect(p.pada, expectedPada);
        expect(p.pada, inInclusiveRange(1, 4));

        // 6. Navamsa derivation from exact arcseconds
        final int expectedNavPart = (expectedArcsecs % 108000) ~/ 12000;
        final int expectedNavRasi = AstrologyCalculator.calculateNavamsaRasiIndex(expectedRasi, expectedNavPart);
        expect(p.navamsaPart, expectedNavPart);
        expect(p.navamsaIndex, expectedNavRasi);
        expect(p.navamsaRasiTa, AstrologyCalculator.rasiNamesTa[expectedNavRasi]);
        expect(p.navamsaRasiEn, AstrologyCalculator.rasiNamesEn[expectedNavRasi]);
      }

      // Verify Rahu / Ketu exact 180° opposition
      final rahu = horoscope.planets['Rahu']!;
      final ketu = horoscope.planets['Ketu']!;
      final expectedKetuLong = (rahu.longitude + 180.0) % 360.0;
      expect(ketu.longitude, closeTo(expectedKetuLong, 1e-4));
    });
  });
}
