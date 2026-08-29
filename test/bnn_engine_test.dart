import 'package:flutter_test/flutter_test.dart';
import 'package:astrocall/models/bnn_models.dart';
import 'package:astrocall/services/astrology_calculator.dart';
import 'package:astrocall/services/bnn_engine.dart';

void main() {
  group('Bhrigu Nandi Nadi (BNN) Engine Unit Tests', () {
    test('Test 1: Normalization & Degree conversion', () {
      final pos0 = BnnPlanetPosition.fromAbsoluteLongitude(
        planetKey: 'Sun',
        tamilName: 'சூரியன்',
        englishName: 'Sun',
        absoluteLongitude: 0.0,
      );
      expect(pos0.signNumber, 1);
      expect(pos0.degreeInSign, 0.0);
      expect(pos0.signNameTa, 'மேஷம்');

      final pos29 = BnnPlanetPosition.fromAbsoluteLongitude(
        planetKey: 'Moon',
        tamilName: 'சந்திரன்',
        englishName: 'Moon',
        absoluteLongitude: 29.999,
      );
      expect(pos29.signNumber, 1);
      expect(pos29.degreeInSign, closeTo(29.999, 0.001));

      final pos30 = BnnPlanetPosition.fromAbsoluteLongitude(
        planetKey: 'Mars',
        tamilName: 'செவ்வாய்',
        englishName: 'Mars',
        absoluteLongitude: 30.0,
      );
      expect(pos30.signNumber, 2);
      expect(pos30.degreeInSign, 0.0);
      expect(pos30.signNameTa, 'ரிஷபம்');

      final pos359 = BnnPlanetPosition.fromAbsoluteLongitude(
        planetKey: 'Saturn',
        tamilName: 'சனி',
        englishName: 'Saturn',
        absoluteLongitude: 359.999,
      );
      expect(pos359.signNumber, 12);
      expect(pos359.degreeInSign, closeTo(29.999, 0.001));
      expect(pos359.signNameTa, 'மீனம்');
    });

    test('Test 2: Aries (Sign 1) Relationship Groups', () {
      final baseSign = 1;

      final trine159 = BnnEngine.getRelatedSigns(baseSign, BnnRelationType.trine159);
      expect(trine159, [1, 5, 9]);

      final upachaya311 = BnnEngine.getRelatedSigns(baseSign, BnnRelationType.upachaya311);
      expect(upachaya311, [3, 11]);

      final seventh7 = BnnEngine.getRelatedSigns(baseSign, BnnRelationType.seventh7);
      expect(seventh7, [7]);

      final secondTwelfth212 = BnnEngine.getRelatedSigns(baseSign, BnnRelationType.secondTwelfth212);
      expect(secondTwelfth212, [2, 12]);
    });

    test('Test 3: Circular Zodiac Wraparound for signs 10, 11, 12', () {
      // Sign 10 (Capricorn / Makaram)
      expect(BnnEngine.getRelatedSigns(10, BnnRelationType.trine159), [10, 2, 6]);
      expect(BnnEngine.getRelatedSigns(10, BnnRelationType.upachaya311), [12, 8]);
      expect(BnnEngine.getRelatedSigns(10, BnnRelationType.seventh7), [4]);
      expect(BnnEngine.getRelatedSigns(10, BnnRelationType.secondTwelfth212), [11, 9]);

      // Sign 11 (Aquarius / Kumbam)
      expect(BnnEngine.getRelatedSigns(11, BnnRelationType.trine159), [11, 3, 7]);
      expect(BnnEngine.getRelatedSigns(11, BnnRelationType.upachaya311), [1, 9]);
      expect(BnnEngine.getRelatedSigns(11, BnnRelationType.seventh7), [5]);
      expect(BnnEngine.getRelatedSigns(11, BnnRelationType.secondTwelfth212), [12, 10]);

      // Sign 12 (Pisces / Meenam)
      expect(BnnEngine.getRelatedSigns(12, BnnRelationType.trine159), [12, 4, 8]);
      expect(BnnEngine.getRelatedSigns(12, BnnRelationType.upachaya311), [2, 10]);
      expect(BnnEngine.getRelatedSigns(12, BnnRelationType.seventh7), [6]);
      expect(BnnEngine.getRelatedSigns(12, BnnRelationType.secondTwelfth212), [1, 11]);
    });

    test('Test 4: Degree Sorting within Signs and Sign Sequence Preservation', () {
      final source = BnnPlanetPosition.fromAbsoluteLongitude(
        planetKey: 'Jupiter',
        tamilName: 'குரு',
        englishName: 'Jupiter',
        absoluteLongitude: 12.0, // Sign 1, 12.0°
      );

      final p1 = BnnPlanetPosition.fromAbsoluteLongitude(
        planetKey: 'Saturn',
        tamilName: 'சனி',
        englishName: 'Saturn',
        absoluteLongitude: 24.10, // Sign 1, 24.10°
      );

      final p2 = BnnPlanetPosition.fromAbsoluteLongitude(
        planetKey: 'Venus',
        tamilName: 'சுக்கிரன்',
        englishName: 'Venus',
        absoluteLongitude: 5.20, // Sign 1, 5.20°
      );

      final p3 = BnnPlanetPosition.fromAbsoluteLongitude(
        planetKey: 'Mars',
        tamilName: 'செவ்வாய்',
        englishName: 'Mars',
        absoluteLongitude: 120.0 + 15.0, // Sign 5 (Simham), 15.0°
      );

      final p4 = BnnPlanetPosition.fromAbsoluteLongitude(
        planetKey: 'Moon',
        tamilName: 'சந்திரன்',
        englishName: 'Moon',
        absoluteLongitude: 120.0 + 8.0, // Sign 5 (Simham), 8.0°
      );

      final allPlanets = [source, p1, p2, p3, p4];

      final related = BnnEngine.getRelatedPlanets(
        sourcePlanet: source,
        relatedSignsInOrder: [1, 5, 9],
        allPlanets: allPlanets,
      );

      // Sign 1: Venus (5.20°) then Saturn (24.10°) [source Jupiter excluded]
      // Sign 5: Moon (8.0°) then Mars (15.0°)
      expect(related.length, 4);
      expect(related[0].planetKey, 'Venus');
      expect(related[1].planetKey, 'Saturn');
      expect(related[2].planetKey, 'Moon');
      expect(related[3].planetKey, 'Mars');
    });

    test('Test 5: Empty Relationship group detection', () {
      final source = BnnPlanetPosition.fromAbsoluteLongitude(
        planetKey: 'Sun',
        tamilName: 'சூரியன்',
        englishName: 'Sun',
        absoluteLongitude: 10.0, // Sign 1
      );

      final other = BnnPlanetPosition.fromAbsoluteLongitude(
        planetKey: 'Moon',
        tamilName: 'சந்திரன்',
        englishName: 'Moon',
        absoluteLongitude: 10.0, // Sign 1
      );

      final analysis = BnnEngine.analyzePlanet(
        sourcePlanet: source,
        allPlanets: [source, other],
      );

      // (7) Opposite should be empty (Sign 7)
      expect(analysis.seventh7.hasRelatedPlanets, false);
      expect(analysis.seventh7.relatedPlanets.isEmpty, true);
      expect(analysis.seventh7.interpretationTa.contains('இந்த தொடர்பில் நேரடி கிரகங்கள் இல்லை'), true);

      // (1,5,9) Trine should have Moon
      expect(analysis.trine159.hasRelatedPlanets, true);
      expect(analysis.trine159.relatedPlanets.first.planetKey, 'Moon');
    });

    test('Test 6: Real Horoscope Data & All 9 Planets with Rahu & Ketu', () {
      final dt = DateTime(1996, 6, 15, 8, 30);
      final astroData = AstrologyCalculator.calculateHoroscope(
        dateOfBirth: dt,
        latitude: 13.0827,
        longitude: 80.2707,
        utcOffsetHours: 5.5,
      );

      final bnnPlanets = BnnEngine.normalizePlanets(astroData.planets);
      expect(bnnPlanets.length, 9);

      final keys = bnnPlanets.map((p) => p.planetKey).toList();
      expect(keys, containsAll(['Sun', 'Moon', 'Mars', 'Mercury', 'Jupiter', 'Venus', 'Saturn', 'Rahu', 'Ketu']));

      final allAnalysis = BnnEngine.analyzeAllPlanets(bnnPlanets);
      expect(allAnalysis.length, 9);

      for (final key in keys) {
        final analysis = allAnalysis[key]!;
        expect(analysis.relationResults.length, 4);
        expect(analysis.trine159.relatedSigns.length, 3);
        expect(analysis.upachaya311.relatedSigns.length, 2);
        expect(analysis.seventh7.relatedSigns.length, 1);
        expect(analysis.secondTwelfth212.relatedSigns.length, 2);
      }
    });

    test('Test 7: BNN Directional Priority (1,5,9 -> 3,11 -> 7 -> 2 -> 12) & Absolute Longitude Ascending Sort', () {
      final source = BnnPlanetPosition.fromAbsoluteLongitude(
        planetKey: 'Jupiter',
        tamilName: 'குரு',
        englishName: 'Jupiter',
        absoluteLongitude: 10.0, // Sign 1 (Aries), 10°
      );

      // Sign 12 (12th): Rahu at 335°
      final p12 = BnnPlanetPosition.fromAbsoluteLongitude(
        planetKey: 'Rahu',
        tamilName: 'ராகு',
        englishName: 'Rahu',
        absoluteLongitude: 335.0,
      );

      // Sign 2 (2nd): Venus at 45°
      final p2 = BnnPlanetPosition.fromAbsoluteLongitude(
        planetKey: 'Venus',
        tamilName: 'சுக்கிரன்',
        englishName: 'Venus',
        absoluteLongitude: 45.0,
      );

      // Sign 7 (7th): Saturn at 190°
      final p7 = BnnPlanetPosition.fromAbsoluteLongitude(
        planetKey: 'Saturn',
        tamilName: 'சனி',
        englishName: 'Saturn',
        absoluteLongitude: 190.0,
      );

      // Sign 3 (3rd - Upachaya): Mercury at 75°
      final p3 = BnnPlanetPosition.fromAbsoluteLongitude(
        planetKey: 'Mercury',
        tamilName: 'புதன்',
        englishName: 'Mercury',
        absoluteLongitude: 75.0,
      );

      // Sign 5 (5th - Trine): Mars at 135°
      final p5 = BnnPlanetPosition.fromAbsoluteLongitude(
        planetKey: 'Mars',
        tamilName: 'செவ்வாய்',
        englishName: 'Mars',
        absoluteLongitude: 135.0,
      );

      // Sign 9 (9th - Trine): Sun at 245°
      final p9 = BnnPlanetPosition.fromAbsoluteLongitude(
        planetKey: 'Sun',
        tamilName: 'சூரியன்',
        englishName: 'Sun',
        absoluteLongitude: 245.0,
      );

      final allPlanets = [source, p12, p2, p7, p3, p5, p9];
      final connections = BnnEngine.getSortedBnnConnections(
        sourcePlanet: source,
        allPlanets: allPlanets,
      );

      // Expected order:
      // 1. Trines (1,5,9) sorted by absolute longitude: Mars (135°) -> Sun (245°)
      // 2. Upachaya (3,11): Mercury (75°)
      // 3. Seventh (7): Saturn (190°)
      // 4. Second (2): Venus (45°)
      // 5. Twelfth (12): Rahu (335°)
      expect(connections.length, 6);
      expect(connections[0].targetPlanet.planetKey, 'Mars');
      expect(connections[0].directionPriority, 1);
      expect(connections[1].targetPlanet.planetKey, 'Sun');
      expect(connections[1].directionPriority, 1);
      expect(connections[2].targetPlanet.planetKey, 'Mercury');
      expect(connections[2].directionPriority, 2);
      expect(connections[3].targetPlanet.planetKey, 'Saturn');
      expect(connections[3].directionPriority, 3);
      expect(connections[4].targetPlanet.planetKey, 'Venus');
      expect(connections[4].directionPriority, 4);
      expect(connections[5].targetPlanet.planetKey, 'Rahu');
      expect(connections[5].directionPriority, 5);
    });

    test('Test 8: Planetary Relationships & Karakatwas (Max 10)', () {
      // Source Jupiter -> Target Sun (Friend), Venus (Enemy), Saturn (Neutral)
      expect(BnnEngine.getRelationship('Jupiter', 'Sun'), BnnPlanetRelationship.friend);
      expect(BnnEngine.getRelationship('Jupiter', 'Venus'), BnnPlanetRelationship.enemy);
      expect(BnnEngine.getRelationship('Jupiter', 'Saturn'), BnnPlanetRelationship.neutral);

      // Karakatwa count check: all planets have <= 10
      for (final key in BnnEngine.standardPlanetKeys) {
        final karakatwas = BnnKarakatwa.getKarakatwasForPlanet(key);
        expect(karakatwas.length, lessThanOrEqualTo(10));
        expect(karakatwas.isNotEmpty, true);
      }
    });

    test('Test 9: Real Vimshottari Dasha Calculation from Moon position with continuous periods', () {
      final birthDt = DateTime(1996, 6, 15, 8, 30);
      // Moon at 45.0° (Rohini Nakshatra, Moon Lord, total 10 years)
      final dasha = BnnEngine.calculateVimshottariDasha(
        moonLongitude: 45.0,
        birthDateTime: birthDt,
      );

      expect(dasha.startingPlanetEn, 'Moon');
      expect(dasha.startingPlanetTa, 'சந்திரன்');
      expect(dasha.balanceYears, greaterThan(0.0));
      expect(dasha.balanceYears, lessThanOrEqualTo(10.0));
      expect(dasha.mahadashas.length, 9);

      // Verify period continuity: previous end == next start, final subperiod end equals parent end
      for (int m = 0; m < dasha.mahadashas.length; m++) {
        final maha = dasha.mahadashas[m];
        if (m > 0) {
          expect(maha.startDate, dasha.mahadashas[m - 1].endDate);
        }

        for (int b = 0; b < maha.subPeriods.length; b++) {
          final bhukti = maha.subPeriods[b];
          if (b > 0) {
            expect(bhukti.startDate, maha.subPeriods[b - 1].endDate);
          }
          if (b == 8) {
            expect(bhukti.endDate, maha.endDate);
          }

          for (int a = 0; a < bhukti.subPeriods.length; a++) {
            final antara = bhukti.subPeriods[a];
            if (a > 0) {
              expect(antara.startDate, bhukti.subPeriods[a - 1].endDate);
            }
            if (a == 8) {
              expect(antara.endDate, bhukti.endDate);
            }
          }
        }
      }
    });

    test('Test 10: BnnChartProvider rejects 0,0 coordinates & calculates real chart', () {
      final birthDt = DateTime(1996, 6, 15, 8, 30);

      // Coordinate validation: 0,0 must throw ArgumentError
      expect(
        () => BnnChartProvider.calculateBnnChart(
          birthDateTime: birthDt,
          latitude: 0.0,
          longitude: 0.0,
        ),
        throwsA(isA<ArgumentError>()),
      );

      // Valid coordinates produce complete BnnChartData
      final chart = BnnChartProvider.calculateBnnChart(
        birthDateTime: birthDt,
        latitude: 13.0827,
        longitude: 80.2707,
        placeName: 'Chennai',
      );

      expect(chart.planets.length, 9);
      expect(chart.lagna.planetKey, 'Lagna');
      expect(chart.analyses.length, 9);
      expect(chart.dashaResult.mahadashas.length, 9);
    });
  });
}

