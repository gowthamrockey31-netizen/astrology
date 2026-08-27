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
  });
}
