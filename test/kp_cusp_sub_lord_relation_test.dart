import 'package:flutter_test/flutter_test.dart';
import 'package:astrocall/models/kp_astrology_model.dart';
import 'package:astrocall/services/kp_astrology_calculator.dart';
import 'package:astrocall/services/kp_cusp_sub_lord_relation_engine.dart';

void main() {
  group('KP Cusp Sub Lord House Relation Unit Tests', () {
    test('1. Normal Planet Sub Lord relation calculation with Star Lord', () {
      // Mock 12 KP Cusps (Mesham to Meenam sign lords)
      final List<KpCuspDetail> mockCusps = [
        const KpCuspDetail(
          cuspNumber: 1,
          cuspLongitude: 15.0,
          rasiIndex: 0,
          rasiNameTa: 'மேஷம்',
          rasiNameEn: 'Aries',
          degreeInRasi: 15.0,
          degreeFormatted: "15°00'00\"",
          signLordTa: 'செவ்வாய்', // Mars owns 1
          starLordTa: 'சுக்கிரன்',
          subLordTa: 'சுக்கிரன்',
          subSubLordTa: 'சுக்கிரன்',
        ),
        const KpCuspDetail(
          cuspNumber: 2,
          cuspLongitude: 45.0,
          rasiIndex: 1,
          rasiNameTa: 'ரிஷபம்',
          rasiNameEn: 'Taurus',
          degreeInRasi: 15.0,
          degreeFormatted: "15°00'00\"",
          signLordTa: 'சுக்கிரன்', // Venus owns 2
          starLordTa: 'சந்திரன்',
          subLordTa: 'குரு',
          subSubLordTa: 'குரு',
        ),
        const KpCuspDetail(
          cuspNumber: 3,
          cuspLongitude: 75.0,
          rasiIndex: 2,
          rasiNameTa: 'மிதுனம்',
          rasiNameEn: 'Gemini',
          degreeInRasi: 15.0,
          degreeFormatted: "15°00'00\"",
          signLordTa: 'புதன்',
          starLordTa: 'ராகு',
          subLordTa: 'சனி',
          subSubLordTa: 'சனி',
        ),
        const KpCuspDetail(
          cuspNumber: 4,
          cuspLongitude: 105.0,
          rasiIndex: 3,
          rasiNameTa: 'கடகம்',
          rasiNameEn: 'Cancer',
          degreeInRasi: 15.0,
          degreeFormatted: "15°00'00\"",
          signLordTa: 'சந்திரன்',
          starLordTa: 'சனி',
          subLordTa: 'புதன்',
          subSubLordTa: 'புதன்',
        ),
        const KpCuspDetail(
          cuspNumber: 5,
          cuspLongitude: 135.0,
          rasiIndex: 4,
          rasiNameTa: 'சிம்மம்',
          rasiNameEn: 'Leo',
          degreeInRasi: 15.0,
          degreeFormatted: "15°00'00\"",
          signLordTa: 'சூரியன்',
          starLordTa: 'கேது',
          subLordTa: 'சுக்கிரன்',
          subSubLordTa: 'சுக்கிரன்',
        ),
        const KpCuspDetail(
          cuspNumber: 6,
          cuspLongitude: 165.0,
          rasiIndex: 5,
          rasiNameTa: 'கன்னி',
          rasiNameEn: 'Virgo',
          degreeInRasi: 15.0,
          degreeFormatted: "15°00'00\"",
          signLordTa: 'புதன்',
          starLordTa: 'சந்திரன்',
          subLordTa: 'செவ்வாய்',
          subSubLordTa: 'செவ்வாய்',
        ),
        const KpCuspDetail(
          cuspNumber: 7,
          cuspLongitude: 195.0,
          rasiIndex: 6,
          rasiNameTa: 'துலாம்',
          rasiNameEn: 'Libra',
          degreeInRasi: 15.0,
          degreeFormatted: "15°00'00\"",
          signLordTa: 'சுக்கிரன்', // Venus owns 7
          starLordTa: 'செவ்வாய்',
          subLordTa: 'ராகு',
          subSubLordTa: 'ராகு',
        ),
        const KpCuspDetail(
          cuspNumber: 8,
          cuspLongitude: 225.0,
          rasiIndex: 7,
          rasiNameTa: 'விருச்சிகம்',
          rasiNameEn: 'Scorpio',
          degreeInRasi: 15.0,
          degreeFormatted: "15°00'00\"",
          signLordTa: 'செவ்வாய்',
          starLordTa: 'குரு',
          subLordTa: 'சனி',
          subSubLordTa: 'சனி',
        ),
        const KpCuspDetail(
          cuspNumber: 9,
          cuspLongitude: 255.0,
          rasiIndex: 8,
          rasiNameTa: 'தனுசு',
          rasiNameEn: 'Sagittarius',
          degreeInRasi: 15.0,
          degreeFormatted: "15°00'00\"",
          signLordTa: 'குரு', // Jupiter owns 9
          starLordTa: 'சுக்கிரன்',
          subLordTa: 'கேது',
          subSubLordTa: 'கேது',
        ),
        const KpCuspDetail(
          cuspNumber: 10,
          cuspLongitude: 285.0,
          rasiIndex: 9,
          rasiNameTa: 'மகரம்',
          rasiNameEn: 'Capricorn',
          degreeInRasi: 15.0,
          degreeFormatted: "15°00'00\"",
          signLordTa: 'சனி',
          starLordTa: 'சூரியன்',
          subLordTa: 'சந்திரன்',
          subSubLordTa: 'சந்திரன்',
        ),
        const KpCuspDetail(
          cuspNumber: 11,
          cuspLongitude: 315.0,
          rasiIndex: 10,
          rasiNameTa: 'கும்பம்',
          rasiNameEn: 'Aquarius',
          degreeInRasi: 15.0,
          degreeFormatted: "15°00'00\"",
          signLordTa: 'சனி',
          starLordTa: 'ராகு',
          subLordTa: 'சூரியன்',
          subSubLordTa: 'சூரியன்',
        ),
        const KpCuspDetail(
          cuspNumber: 12,
          cuspLongitude: 345.0,
          rasiIndex: 11,
          rasiNameTa: 'மீனம்',
          rasiNameEn: 'Pisces',
          degreeInRasi: 15.0,
          degreeFormatted: "15°00'00\"",
          signLordTa: 'குரு', // Jupiter owns 12
          starLordTa: 'சனி',
          subLordTa: 'புதன்',
          subSubLordTa: 'புதன்',
        ),
      ];

      // Mock planets:
      // Sub Lord = Venus (சுக்கிரன்):
      // - Occupied House: 7
      // - Owned Houses: 2, 7
      // - Star Lord: Jupiter (குரு)
      // Star Lord = Jupiter (குரு):
      // - Occupied House: 11
      // - Owned Houses: 9, 12
      final List<KpPlanetDetail> mockPlanets = [
        const KpPlanetDetail(
          planetNameEn: 'Venus',
          planetNameTa: 'சுக்கிரன்',
          symbol: '♀',
          longitude: 200.0,
          rasiIndex: 6,
          rasiNameTa: 'துலாம்',
          degreeInRasi: 20.0,
          degreeFormatted: "20°00'00\"",
          signLordTa: 'சுக்கிரன்',
          starLordTa: 'குரு',
          subLordTa: 'புதன்',
          subSubLordTa: 'புதன்',
          cuspOccupied: 7,
          isRetrograde: false,
        ),
        const KpPlanetDetail(
          planetNameEn: 'Jupiter',
          planetNameTa: 'குரு',
          symbol: '♃',
          longitude: 320.0,
          rasiIndex: 10,
          rasiNameTa: 'கும்பம்',
          degreeInRasi: 20.0,
          degreeFormatted: "20°00'00\"",
          signLordTa: 'சனி',
          starLordTa: 'ராகு',
          subLordTa: 'சுக்கிரன்',
          subSubLordTa: 'சுக்கிரன்',
          cuspOccupied: 11,
          isRetrograde: false,
        ),
      ];

      final results = KpCuspSubLordRelationEngine.calculateRelationTable(
        cusps: mockCusps,
        planets: mockPlanets,
      );

      expect(results.length, 12);

      // Cusp 1 has Sub Lord 'சுக்கிரன்' (Venus)
      final cusp1 = results.first;
      expect(cusp1.houseNumber, 1);
      expect(cusp1.cuspSubLordTa, 'சுக்கிரன்');
      expect(cusp1.subLordOccupiedHouses, [7]);
      expect(cusp1.subLordOwnedHouses, [2, 7]);
      expect(cusp1.subLordStarLordTa, 'குரு');
      expect(cusp1.starLordOccupiedHouses, [11]);
      expect(cusp1.starLordOwnedHouses, [9, 12]);

      // Combined raw: [7, 2, 7, 11, 9, 12] -> deduplicated and sorted: [2, 7, 9, 11, 12]
      expect(cusp1.finalRelatedHouses, [2, 7, 9, 11, 12]);
      expect(cusp1.finalRelatedHousesFormatted, '2, 7, 9, 11, 12');
    });

    test('2. Deduplication, ascending sorting, and boundary validation', () {
      final horoscope = KpAstrologyCalculator.calculateKpChart(
        dateTime: DateTime(1996, 6, 15, 8, 30),
        latitude: 13.0827,
        longitude: 80.2707,
        utcOffsetHours: 5.5,
      );

      final relations = horoscope.cuspHouseRelations;
      expect(relations.length, 12);

      for (int i = 0; i < 12; i++) {
        final rel = relations[i];
        expect(rel.houseNumber, i + 1);

        // Verify all house numbers are strictly within 1..12
        for (final h in rel.finalRelatedHouses) {
          expect(h, inInclusiveRange(1, 12));
        }

        // Verify uniqueness
        expect(rel.finalRelatedHouses.toSet().length, rel.finalRelatedHouses.length);

        // Verify ascending sort
        final sortedCopy = List<int>.from(rel.finalRelatedHouses)..sort();
        expect(rel.finalRelatedHouses, sortedCopy);

        // Verify Sub Lord is present
        expect(rel.cuspSubLordTa.isNotEmpty, true);
        expect(rel.cuspStarLordTa.isNotEmpty, true);
        expect(rel.nakshatraNameTa.isNotEmpty, true);
      }
    });

    test('3. Node Logic: Rahu and Ketu as Cusp Sub Lords', () {
      final isRahuNode = KpCuspSubLordRelationEngine.isNode('Rahu');
      final isKetuNode = KpCuspSubLordRelationEngine.isNode('கேது');
      final isSunNode = KpCuspSubLordRelationEngine.isNode('Sun');

      expect(isRahuNode, true);
      expect(isKetuNode, true);
      expect(isSunNode, false);

      // Verify node sign lord and conjunction properties in chart
      final horoscope = KpAstrologyCalculator.calculateKpChart(
        dateTime: DateTime(2024, 1, 15, 14, 0),
        latitude: 13.0827,
        longitude: 80.2707,
        utcOffsetHours: 5.5,
      );

      for (final rel in horoscope.cuspHouseRelations) {
        if (rel.isSubLordNode) {
          expect(rel.nodeSignLordTa != null, true);
          // If node has related houses, verify valid range
          for (final h in rel.nodeSignLordHouses) {
            expect(h, inInclusiveRange(1, 12));
          }
        }
      }
    });

    test('4. Dynamic Recalculation across different chart inputs', () {
      final chart1 = KpAstrologyCalculator.calculateKpChart(
        dateTime: DateTime(1990, 1, 1, 6, 0),
        latitude: 13.0827,
        longitude: 80.2707,
        utcOffsetHours: 5.5,
      );

      final chart2 = KpAstrologyCalculator.calculateKpChart(
        dateTime: DateTime(2005, 10, 25, 18, 30),
        latitude: 28.6139,
        longitude: 77.2090,
        utcOffsetHours: 5.5,
      );

      expect(chart1.cuspHouseRelations.length, 12);
      expect(chart2.cuspHouseRelations.length, 12);

      // Verify differences reflecting different chart inputs
      expect(
        chart1.cuspHouseRelations.first.cuspLongitude !=
            chart2.cuspHouseRelations.first.cuspLongitude,
        true,
      );
    });
  });
}
