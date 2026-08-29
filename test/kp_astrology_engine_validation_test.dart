import 'package:flutter_test/flutter_test.dart';
import 'package:astrocall/models/kp_astrology_model.dart';
import 'package:astrocall/services/kp_astrology_calculator.dart';
import 'package:astrocall/services/astrology_calculator.dart';

void main() {
  group('KP Astrology Engine & High-Precision Ephemeris Validation Tests', () {
    final testBirthData = KPBirthData(
      birthDateTime: DateTime(1996, 6, 15, 8, 30, 0),
      latitude: 13.0827,
      longitude: 80.2707,
      utcOffsetHours: 5.5,
    );

    test('1. Deterministic Calculation: No Random() and identical repeated runs', () {
      final chart1 = KPAstrologyEngine.calculateChart(testBirthData);
      final chart2 = KPAstrologyEngine.calculateChart(testBirthData);

      // Verify exact equality across runs
      expect(chart1.cusps.length, 12);
      expect(chart1.planets.length, 9);

      for (int i = 0; i < 12; i++) {
        expect(chart1.cusps[i].cuspLongitude, chart2.cusps[i].cuspLongitude);
        expect(chart1.cusps[i].subLordTa, chart2.cusps[i].subLordTa);
        expect(chart1.cusps[i].subSubLordTa, chart2.cusps[i].subSubLordTa);
      }

      for (int i = 0; i < 9; i++) {
        expect(chart1.planets[i].longitude, chart2.planets[i].longitude);
        expect(chart1.planets[i].subLordTa, chart2.planets[i].subLordTa);
        expect(chart1.planets[i].subSubLordTa, chart2.planets[i].subSubLordTa);
      }
    });

    test('2. Single Source of Truth for all planetary derivations', () {
      final chart = KPAstrologyEngine.calculateChart(testBirthData);

      for (final p in chart.planets) {
        // 0 <= longitude < 360
        expect(p.longitude, greaterThanOrEqualTo(0.0));
        expect(p.longitude, lessThan(360.0));

        // Rasi
        final expectedRasi = (p.longitude / 30.0).floor();
        expect(p.rasiIndex, expectedRasi);
        expect(p.rasiNameTa, AstrologyCalculator.rasiNamesTa[expectedRasi]);

        // Nakshatra & Pada
        const nakSpan = 360.0 / 27.0;
        const padaSpan = 360.0 / 108.0;
        final expectedNak = (p.longitude / nakSpan).floor();
        final expectedPada = ((p.longitude % nakSpan) / padaSpan).floor() + 1;
        expect(p.nakshatraIndex, expectedNak);
        expect(p.pada, expectedPada);
        expect(p.pada, inInclusiveRange(1, 4));

        // Navamsa
        final expectedNavPart = (p.degreeInRasi / (30.0 / 9.0)).floor();
        final expectedNavRasi = AstrologyCalculator.calculateNavamsaRasiIndex(expectedRasi, expectedNavPart);
        expect(p.navamsaPart, expectedNavPart);
        expect(p.navamsaRasiIndex, expectedNavRasi);

        // Star, Sub, Sub-Sub lords
        final lords = KpAstrologyCalculator.getStarSubSubSubLords(p.longitude);
        expect(p.starLordTa, lords['starLordTa']);
        expect(p.subLordTa, lords['subLordTa']);
        expect(p.subSubLordTa, lords['subSubLordTa']);
      }
    });

    test('3. Rahu & Ketu exact 180° opposition and nodal consistency', () {
      final chart = KPAstrologyEngine.calculateChart(testBirthData);
      final rahu = chart.planets.firstWhere((p) => p.planetNameEn == 'Rahu');
      final ketu = chart.planets.firstWhere((p) => p.planetNameEn == 'Ketu');

      final expectedKetu = (rahu.longitude + 180.0) % 360.0;
      expect(ketu.longitude, closeTo(expectedKetu, 1e-4));
      expect(rahu.isRetrograde, true);
      expect(ketu.isRetrograde, true);
    });

    test('4. 12 Placidus Cusps validity and continuity', () {
      final chart = KPAstrologyEngine.calculateChart(testBirthData);
      expect(chart.cusps.length, 12);

      for (int i = 0; i < 12; i++) {
        final cusp = chart.cusps[i];
        expect(cusp.cuspNumber, i + 1);
        expect(cusp.cuspLongitude, greaterThanOrEqualTo(0.0));
        expect(cusp.cuspLongitude, lessThan(360.0));
        expect(cusp.subLordTa.isNotEmpty, true);
        expect(cusp.subSubLordTa.isNotEmpty, true);
      }

      // Opposite cusps must be separated by 180°
      for (int i = 0; i < 6; i++) {
        final c1 = chart.cusps[i].cuspLongitude;
        final c2 = chart.cusps[i + 6].cuspLongitude;
        final diff = (c2 - c1 + 360.0) % 360.0;
        expect(diff, closeTo(180.0, 1e-3));
      }
    });

    test('5. Vimshottari Nested Sub and Sub-Sub Lord Proportions', () {
      // Test known boundary in Ashwini (Ketu star, 0° to 13°20')
      // Ketu sub: 0° to 0°46'40" = 0.777777°
      final ketuSub = KpAstrologyCalculator.getStarSubSubSubLords(0.5);
      expect(ketuSub['starLordEn'], 'Ketu');
      expect(ketuSub['subLordEn'], 'Ketu');

      // Venus sub in Ashwini: starts at 0°46'40", ends at 3°00'00" (span = 2.222222°)
      final venusSub = KpAstrologyCalculator.getStarSubSubSubLords(1.5);
      expect(venusSub['starLordEn'], 'Ketu');
      expect(venusSub['subLordEn'], 'Venus');

      // Sun sub in Ashwini: starts at 3°00'00", ends at 3°40'00" = 3.666666°
      final sunSub = KpAstrologyCalculator.getStarSubSubSubLords(3.2);
      expect(sunSub['starLordEn'], 'Ketu');
      expect(sunSub['subLordEn'], 'Sun');

      // Mercury sub in Revati (last sub of 27th nakshatra):
      final revatiLast = KpAstrologyCalculator.getStarSubSubSubLords(359.5);
      expect(revatiLast['starLordEn'], 'Mercury');
      expect(revatiLast['subLordEn'], 'Saturn'); // Saturn is 8th in Mercury's sequence
    });

    test('6. Continuous Vimshottari Dasha Hierarchy integrity', () {
      final chart = KPAstrologyEngine.calculateChart(testBirthData);
      final dashaHierarchy = chart.dashaHierarchy;
      expect(dashaHierarchy, isNotNull);

      expect(dashaHierarchy!.mahadashas.length, 9);
      expect(dashaHierarchy.birthBalanceYears, greaterThan(0.0));

      for (int m = 0; m < dashaHierarchy.mahadashas.length; m++) {
        final maha = dashaHierarchy.mahadashas[m];
        expect(maha.subPeriods.length, 9); // 9 Bhuktis

        if (m > 0) {
          final prevMaha = dashaHierarchy.mahadashas[m - 1];
          expect(maha.startDate, prevMaha.endDate); // Previous End == Next Start
        }

        for (int b = 0; b < maha.subPeriods.length; b++) {
          final bhukti = maha.subPeriods[b];
          expect(bhukti.subPeriods.length, 9); // 9 Antharas

          if (b > 0) {
            final prevBhukti = maha.subPeriods[b - 1];
            expect(bhukti.startDate, prevBhukti.endDate);
          }
        }
      }
    });

    test('7. Horary Number (1 to 249) Resolution', () {
      final h1 = KpAstrologyCalculator.getHoraryNumberAscendantLongitude(1);
      final h249 = KpAstrologyCalculator.getHoraryNumberAscendantLongitude(249);

      expect(h1, greaterThan(0.0));
      expect(h1, lessThan(2.0));
      expect(h249, greaterThan(350.0));
      expect(h249, lessThan(360.0));
    });
  });
}
