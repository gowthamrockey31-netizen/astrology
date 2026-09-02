import 'package:flutter_test/flutter_test.dart';
import 'package:astrocall/models/bnn_method1_model.dart';
import 'package:astrocall/engine/bnn_method1_engine.dart';
import 'package:astrocall/engine/bnn_method1_relation_engine.dart';
import 'package:astrocall/data/bnn_method1_karakatwa.dart';
import 'package:astrocall/providers/bnn_method1_chart_provider.dart';

void main() {
  group('BNN Method 1 Unit Tests', () {
    // 1. Longitude Normalization
    test('1. Longitude Normalization strictly wraps 0° <= long < 360°', () {
      expect(BnnMethod1Engine.normalizeLongitude(0.0), 0.0);
      expect(BnnMethod1Engine.normalizeLongitude(359.99), closeTo(359.99, 0.001));
      expect(BnnMethod1Engine.normalizeLongitude(360.0), 0.0);
      expect(BnnMethod1Engine.normalizeLongitude(720.5), closeTo(0.5, 0.001));
      expect(BnnMethod1Engine.normalizeLongitude(-30.0), closeTo(330.0, 0.001));
      expect(BnnMethod1Engine.normalizeLongitude(-370.0), closeTo(350.0, 0.001));
    });

    // 2. Degree / Minute / Second Conversion
    test('2. Degree / Minute / Second Conversion maintains precision', () {
      // 15° 30' 45"
      final deg = 15.0 + (30.0 / 60.0) + (45.0 / 3600.0);
      final dms = BnnMethod1Engine.toDMS(deg);
      expect(dms.$1, 15);
      expect(dms.$2, 30);
      expect(dms.$3, closeTo(45.0, 0.01));

      // 0° 0' 0"
      final dmsZero = BnnMethod1Engine.toDMS(0.0);
      expect(dmsZero.$1, 0);
      expect(dmsZero.$2, 0);
      expect(dmsZero.$3, closeTo(0.0, 0.001));

      // 29° 59' 59"
      final degEnd = 29.0 + (59.0 / 60.0) + (59.0 / 3600.0);
      final dmsEnd = BnnMethod1Engine.toDMS(degEnd);
      expect(dmsEnd.$1, 29);
      expect(dmsEnd.$2, 59);
      expect(dmsEnd.$3, closeTo(59.0, 0.01));
    });

    // 3. Sign Calculation (1 to 12)
    test('3. Sign Calculation floor(long / 30) + 1 produces 1 to 12', () {
      expect(BnnMethod1Engine.getSign(0.0), 1); // Mesham
      expect(BnnMethod1Engine.getSign(29.999), 1); // Mesham
      expect(BnnMethod1Engine.getSign(30.0), 2); // Rishabam
      expect(BnnMethod1Engine.getSign(89.999), 3); // Mithunam
      expect(BnnMethod1Engine.getSign(90.0), 4); // Kadagam
      expect(BnnMethod1Engine.getSign(330.0), 12); // Meenam
      expect(BnnMethod1Engine.getSign(359.999), 12); // Meenam
    });

    // 4. Relative House Calculation ((target - source + 12) % 12) + 1
    test('4. Relative House Calculation is always 1 to 12', () {
      // Same sign (1)
      expect(BnnMethod1Engine.calculateRelativeHouse(1, 1), 1);
      expect(BnnMethod1Engine.calculateRelativeHouse(5, 5), 1);

      // Sign 1 to Sign 5 (5th house)
      expect(BnnMethod1Engine.calculateRelativeHouse(1, 5), 5);

      // Sign 1 to Sign 9 (9th house)
      expect(BnnMethod1Engine.calculateRelativeHouse(1, 9), 9);

      // Sign 1 to Sign 3 (3rd house)
      expect(BnnMethod1Engine.calculateRelativeHouse(1, 3), 3);

      // Sign 1 to Sign 11 (11th house)
      expect(BnnMethod1Engine.calculateRelativeHouse(1, 11), 11);

      // Sign 1 to Sign 7 (7th house)
      expect(BnnMethod1Engine.calculateRelativeHouse(1, 7), 7);

      // Sign 1 to Sign 2 (2nd house)
      expect(BnnMethod1Engine.calculateRelativeHouse(1, 2), 2);

      // Sign 1 to Sign 12 (12th house)
      expect(BnnMethod1Engine.calculateRelativeHouse(1, 12), 12);

      // Circular wrap: Sign 12 to Sign 1 (2nd house)
      expect(BnnMethod1Engine.calculateRelativeHouse(12, 1), 2);

      // Circular wrap: Sign 12 to Sign 11 (12th house)
      expect(BnnMethod1Engine.calculateRelativeHouse(12, 11), 12);
    });

    // 5. Direction Priority Sequence
    test('5. Direction Group Mapping adheres to strict Method 1 Priority', () {
      // Priority 1: 1, 5, 9
      expect(BnnMethod1DirectionGroup.fromRelativeHouse(1)?.priority, 1);
      expect(BnnMethod1DirectionGroup.fromRelativeHouse(5)?.priority, 1);
      expect(BnnMethod1DirectionGroup.fromRelativeHouse(9)?.priority, 1);

      // Priority 2: 3, 11
      expect(BnnMethod1DirectionGroup.fromRelativeHouse(3)?.priority, 2);
      expect(BnnMethod1DirectionGroup.fromRelativeHouse(11)?.priority, 2);

      // Priority 3: 7
      expect(BnnMethod1DirectionGroup.fromRelativeHouse(7)?.priority, 3);

      // Priority 4: 2
      expect(BnnMethod1DirectionGroup.fromRelativeHouse(2)?.priority, 4);

      // Priority 5: 12
      expect(BnnMethod1DirectionGroup.fromRelativeHouse(12)?.priority, 5);

      // Non-Method 1 relative houses (4, 6, 8, 10) return null
      expect(BnnMethod1DirectionGroup.fromRelativeHouse(4), isNull);
      expect(BnnMethod1DirectionGroup.fromRelativeHouse(6), isNull);
      expect(BnnMethod1DirectionGroup.fromRelativeHouse(8), isNull);
      expect(BnnMethod1DirectionGroup.fromRelativeHouse(10), isNull);
    });

    // 6. Connection Sorting (Priority Ascending, Secondary Longitude Ascending)
    test('6. Connection Sorting: Priority 1..5 then Longitude ascending', () {
      final source = const BnnMethod1Planet(
        planetKey: 'Jupiter',
        planetName: 'குரு',
        englishName: 'Jupiter',
        longitude: 10.0, // Sign 1 (Mesham)
        sign: 1,
        signNameTa: 'மேஷம்',
        signNameEn: 'Aries',
        degreeWithinSign: 10.0,
        degree: 10,
        minute: 0,
        second: 0.0,
        house: 1,
        nakshatra: 'அஸ்வினி',
        nakshatraIndex: 0,
        nakshatraPada: 3,
        degreeOrder: 1,
      );

      // Target in 12th house (relativeHouse = 12, Priority 5)
      final pIn12 = const BnnMethod1Planet(
        planetKey: 'Saturn',
        planetName: 'சனி',
        englishName: 'Saturn',
        longitude: 340.0, // Sign 12 (Meenam)
        sign: 12,
        signNameTa: 'மீனம்',
        signNameEn: 'Pisces',
        degreeWithinSign: 10.0,
        degree: 10,
        minute: 0,
        second: 0.0,
        house: 12,
        nakshatra: 'உத்தரட்டாதி',
        nakshatraIndex: 25,
        nakshatraPada: 3,
        degreeOrder: 9,
      );

      // Target in 5th house (relativeHouse = 5, Priority 1)
      final pIn5 = const BnnMethod1Planet(
        planetKey: 'Sun',
        planetName: 'சூரியன்',
        englishName: 'Sun',
        longitude: 130.0, // Sign 5 (Simmam)
        sign: 5,
        signNameTa: 'சிம்மம்',
        signNameEn: 'Leo',
        degreeWithinSign: 10.0,
        degree: 10,
        minute: 0,
        second: 0.0,
        house: 5,
        nakshatra: 'மகம்',
        nakshatraIndex: 9,
        nakshatraPada: 3,
        degreeOrder: 4,
      );

      // Target in 9th house (relativeHouse = 9, Priority 1, higher longitude)
      final pIn9 = const BnnMethod1Planet(
        planetKey: 'Mars',
        planetName: 'செவ்வாய்',
        englishName: 'Mars',
        longitude: 250.0, // Sign 9 (Dhanusu)
        sign: 9,
        signNameTa: 'தனுசு',
        signNameEn: 'Sagittarius',
        degreeWithinSign: 10.0,
        degree: 10,
        minute: 0,
        second: 0.0,
        house: 9,
        nakshatra: 'மூலம்',
        nakshatraIndex: 18,
        nakshatraPada: 3,
        degreeOrder: 7,
      );

      // Target in 7th house (relativeHouse = 7, Priority 3)
      final pIn7 = const BnnMethod1Planet(
        planetKey: 'Venus',
        planetName: 'சுக்கிரன்',
        englishName: 'Venus',
        longitude: 195.0, // Sign 7 (Thulam)
        sign: 7,
        signNameTa: 'துலாம்',
        signNameEn: 'Libra',
        degreeWithinSign: 15.0,
        degree: 15,
        minute: 0,
        second: 0.0,
        house: 7,
        nakshatra: 'சுவாதி',
        nakshatraIndex: 14,
        nakshatraPada: 3,
        degreeOrder: 6,
      );

      final conns = BnnMethod1Engine.calculatePlanetConnections(
        sourcePlanet: source,
        allPlanets: [source, pIn12, pIn5, pIn9, pIn7],
      );

      // Expected order: Priority 1 (Sun, Mars), then Priority 3 (Venus), then Priority 5 (Saturn)
      expect(conns.length, 4);
      expect(conns[0].targetPlanet.planetKey, 'Sun'); // Priority 1, long 130
      expect(conns[1].targetPlanet.planetKey, 'Mars'); // Priority 1, long 250
      expect(conns[2].targetPlanet.planetKey, 'Venus'); // Priority 3, long 195
      expect(conns[3].targetPlanet.planetKey, 'Saturn'); // Priority 5, long 340
    });

    // 7. Planetary Relation Retrieval
    test('7. Planetary Relationship Engine returns exact classical values', () {
      expect(BnnMethod1PlanetRelationEngine.getRelation('Sun', 'Moon'), BnnMethod1Relation.friend);
      expect(BnnMethod1PlanetRelationEngine.getRelation('Sun', 'Mars'), BnnMethod1Relation.friend);
      expect(BnnMethod1PlanetRelationEngine.getRelation('Sun', 'Jupiter'), BnnMethod1Relation.friend);
      expect(BnnMethod1PlanetRelationEngine.getRelation('Sun', 'Mercury'), BnnMethod1Relation.neutral);
      expect(BnnMethod1PlanetRelationEngine.getRelation('Sun', 'Venus'), BnnMethod1Relation.enemy);
      expect(BnnMethod1PlanetRelationEngine.getRelation('Sun', 'Saturn'), BnnMethod1Relation.enemy);

      // Self relationship defaults to friend
      expect(BnnMethod1PlanetRelationEngine.getRelation('Jupiter', 'Jupiter'), BnnMethod1Relation.friend);

      // Unknown planet defaults to neutral
      expect(BnnMethod1PlanetRelationEngine.getRelation('Unknown', 'Jupiter'), BnnMethod1Relation.neutral);
      expect(BnnMethod1PlanetRelationEngine.getRelation('Jupiter', 'Unknown'), BnnMethod1Relation.neutral);
    });

    // 8. Karakatwa Retrieval
    test('8. Karakatwa repository returns at most 10 karakatwas per planet', () {
      for (final key in BnnMethod1Engine.standardPlanetKeys) {
        final karakatwas = BnnMethod1KarakatwaRepository.getKarakatwas(key);
        expect(karakatwas.isNotEmpty, isTrue);
        expect(karakatwas.length, lessThanOrEqualTo(10));
        expect(karakatwas.first.isNotEmpty, isTrue);
      }
    });

    // 9. Duplicate Connection Prevention (source != target)
    test('9. Prevents self-connection in calculatePlanetConnections', () {
      final p1 = const BnnMethod1Planet(
        planetKey: 'Sun',
        planetName: 'சூரியன்',
        englishName: 'Sun',
        longitude: 45.0,
        sign: 2,
        signNameTa: 'ரிஷபம்',
        signNameEn: 'Taurus',
        degreeWithinSign: 15.0,
        degree: 15,
        minute: 0,
        second: 0.0,
        house: 1,
        nakshatra: 'ரோகிணி',
        nakshatraIndex: 3,
        nakshatraPada: 2,
      );

      final conns = BnnMethod1Engine.calculatePlanetConnections(
        sourcePlanet: p1,
        allPlanets: [p1],
      );

      expect(conns, isEmpty);
    });

    // 10. Invalid Coordinates Validation
    test('10. Invalid coordinates throw clear ArgumentError', () {
      // 0,0 rejection
      expect(
        () => DefaultBnnMethod1ChartProvider.validateInputs(
          birthDateTime: DateTime(1996, 6, 15, 8, 30),
          latitude: 0.0,
          longitude: 0.0,
        ),
        throwsA(isA<ArgumentError>()),
      );

      // Latitude > 90
      expect(
        () => DefaultBnnMethod1ChartProvider.validateInputs(
          birthDateTime: DateTime(1996, 6, 15, 8, 30),
          latitude: 95.0,
          longitude: 80.0,
        ),
        throwsA(isA<ArgumentError>()),
      );

      // Longitude > 180
      expect(
        () => DefaultBnnMethod1ChartProvider.validateInputs(
          birthDateTime: DateTime(1996, 6, 15, 8, 30),
          latitude: 13.0,
          longitude: 195.0,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    // 11. Invalid Longitude Handling
    test('11. Invalid longitude (NaN or Infinite) throws ArgumentError', () {
      expect(
        () => BnnMethod1Engine.normalizeLongitude(double.nan),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => BnnMethod1Engine.normalizeLongitude(double.infinity),
        throwsA(isA<ArgumentError>()),
      );
    });

    // 12. Full Integration with Real Astronomical Calculations
    test('12. Full BNN Method 1 Calculation produces all 9 planets & predictions', () {
      final result = DefaultBnnMethod1ChartProvider.calculateSync(
        birthDateTime: DateTime(1996, 6, 15, 8, 30),
        latitude: 13.0827,
        longitude: 80.2707,
        utcOffsetHours: 5.5,
        placeName: 'Chennai',
      );

      expect(result.calculationStatus, 'Success');
      expect(result.planetaryPositions.length, 9);
      expect(result.degreeOrder.length, 9);
      expect(result.allConnections.isNotEmpty, isTrue);
      expect(result.predictions.isNotEmpty, isTrue);

      // Degree order strictly from 1 to 9
      final orderValues = result.degreeOrder.map((p) => p.degreeOrder).toList();
      expect(orderValues, [1, 2, 3, 4, 5, 6, 7, 8, 9]);

      // All connections have valid relative houses and direction priorities
      for (final c in result.allConnections) {
        expect(c.relativeHouse, inInclusiveRange(1, 12));
        expect(c.directionPriority, inInclusiveRange(1, 5));
        expect(c.karakatwas.length, lessThanOrEqualTo(10));
      }

      // Real Dasha result attached
      expect(result.dashaResult, isNotNull);
      expect(result.dashaResult!.balanceFormatted.contains('மகா தசை'), isTrue);
    });
  });
}
