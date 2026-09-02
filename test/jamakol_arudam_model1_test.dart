import 'package:flutter_test/flutter_test.dart';
import 'package:astrocall/engine/jamakol_arudam_model1_engine.dart';
import 'package:astrocall/models/jamakol_arudam_model1.dart';
import 'package:astrocall/services/astrology_calculator.dart';

void main() {
  group('Jamakol Arudam Model 1 Unit Tests', () {
    // 1. Longitude Normalization
    test('1. Longitude Normalization strictly wraps into 0° <= longitude < 360°', () {
      expect(JamakolArudamModel1Engine.normalizeLongitude(0.0), 0.0);
      expect(JamakolArudamModel1Engine.normalizeLongitude(359.999), closeTo(359.999, 0.001));
      expect(JamakolArudamModel1Engine.normalizeLongitude(360.0), 0.0);
      expect(JamakolArudamModel1Engine.normalizeLongitude(720.0), 0.0);
      expect(JamakolArudamModel1Engine.normalizeLongitude(-30.0), closeTo(330.0, 0.001));
      expect(JamakolArudamModel1Engine.normalizeLongitude(-180.0), closeTo(180.0, 0.001));
    });

    // 2. Degree / Minute / Second Conversion
    test('2. Degree / Minute / Second conversion preserves exact decimal precision', () {
      // 12.582777° -> 12° 34' 58"
      const deg = 12.582777;
      final dms = JamakolArudamModel1Engine.toDMS(deg);
      expect(dms.$1, 12);
      expect(dms.$2, 34);
      expect(dms.$3, closeTo(58.0, 0.5));

      // 0.0°
      final dmsZero = JamakolArudamModel1Engine.toDMS(0.0);
      expect(dmsZero.$1, 0);
      expect(dmsZero.$2, 0);
      expect(dmsZero.$3, closeTo(0.0, 0.001));

      // 29.999°
      final dmsMax = JamakolArudamModel1Engine.toDMS(29.999);
      expect(dmsMax.$1, 29);
      expect(dmsMax.$2, 59);
    });

    // 3. Rasi Index & Name Calculation
    test('3. Rasi index & names match project centralized definitions (0..11)', () {
      expect(JamakolArudamModel1Engine.getRasiIndex(0.0), 0); // Mesham
      expect(JamakolArudamModel1Engine.getRasiName(0), 'மேஷம்');

      expect(JamakolArudamModel1Engine.getRasiIndex(30.0), 1); // Rishabam
      expect(JamakolArudamModel1Engine.getRasiName(1), 'ரிஷபம்');

      expect(JamakolArudamModel1Engine.getRasiIndex(120.0), 4); // Simmam
      expect(JamakolArudamModel1Engine.getRasiName(4), 'சிம்மம்');

      expect(JamakolArudamModel1Engine.getRasiIndex(330.0), 11); // Meenam
      expect(JamakolArudamModel1Engine.getRasiName(11), 'மீனம்');

      // Verify all 12 Rasis
      expect(AstrologyCalculator.rasiNamesTa.length, 12);
      expect(AstrologyCalculator.rasiNamesTa.first, 'மேஷம்');
      expect(AstrologyCalculator.rasiNamesTa.last, 'மீனம்');
    });

    // 4. Core Point Model (உதயம், ஆருடம், கவிப்பு)
    test('4. Core Point model formats DMS and degrees correctly', () {
      const point = JamakolArudamCorePoint(
        nameTa: 'உதயம்',
        nameEn: 'Udhayam',
        symbol: 'உ',
        absoluteLongitude: 12.582777,
        rasi: 'மேஷம்',
        rasiIndex: 0,
        degreeWithinRasi: 12.582777,
        degree: 12,
        minute: 34,
        second: 58.0,
      );

      expect(point.nameTa, 'உதயம்');
      expect(point.rasi, 'மேஷம்');
      expect(point.formattedDMS, '12° 34′ 58″');
      expect(point.formattedDegree, '12.58°');
    });

    // 5. Planetary Model
    test('5. Planetary model supports all fields, house from Udhayam, and DMS', () {
      const planet = JamakolArudamPlanet(
        nameTa: 'சூரியன்',
        englishName: 'Sun',
        planetKey: 'Sun',
        longitude: 132.5,
        rasi: 'சிம்மம்',
        rasiIndex: 4,
        degreeWithinRasi: 12.5,
        degree: 12,
        minute: 30,
        second: 0.0,
        house: 5,
        nakshatra: 'மகம்',
        pada: 3,
        isRetrograde: false,
      );

      expect(planet.nameTa, 'சூரியன்');
      expect(planet.house, 5);
      expect(planet.formattedDMS, '12° 30′ 00″');
    });

    // 6. Invalid Coordinates & Longitude Handling
    test('6. Input validation rejects 0,0 and invalid bounds', () {
      final validTime = DateTime(2026, 9, 2, 10, 0);

      // Rejects 0,0 coordinates
      expect(
        () => JamakolArudamModel1Engine.validateInputs(
          queryTime: validTime,
          latitude: 0.0,
          longitude: 0.0,
        ),
        throwsA(isA<ArgumentError>()),
      );

      // Rejects latitude > 90
      expect(
        () => JamakolArudamModel1Engine.validateInputs(
          queryTime: validTime,
          latitude: 95.0,
          longitude: 80.0,
        ),
        throwsA(isA<ArgumentError>()),
      );

      // Rejects longitude > 180
      expect(
        () => JamakolArudamModel1Engine.validateInputs(
          queryTime: validTime,
          latitude: 13.0,
          longitude: 195.0,
        ),
        throwsA(isA<ArgumentError>()),
      );

      // Rejects NaN longitude
      expect(
        () => JamakolArudamModel1Engine.normalizeLongitude(double.nan),
        throwsA(isA<ArgumentError>()),
      );
    });

    // 7. Full Engine Calculation with Real Astronomical Ephemeris
    test('7. Jamakol Arudam Model 1 Engine calculates core points, Navagrahas, and predictions', () {
      final queryTime = DateTime(2026, 9, 2, 10, 30);
      final result = JamakolArudamModel1Engine.calculate(
        queryTime: queryTime,
        customAarudamNumber: 5, // Simmam
        latitude: 13.0827,
        longitude: 80.2707,
        utcOffsetHours: 5.5,
        placeName: 'Chennai',
      );

      // 1. Verify Core Points
      expect(result.udhayam.nameTa, 'உதயம்');
      expect(result.aarudam.nameTa, 'ஆருடம்');
      expect(result.kavippu.nameTa, 'கவிப்பு');

      // Aarudam was chosen as 5 -> Simmam (index 4)
      expect(result.aarudam.rasiIndex, 4);
      expect(result.aarudam.rasi, 'சிம்மம்');

      // Kavippu is 7th from Aarudam (index 4 + 6 = 10 -> Kumbam)
      expect(result.kavippu.rasiIndex, 10);
      expect(result.kavippu.rasi, 'கும்பம்');

      // Kavippu longitude is exactly 180° opposite Aarudam
      final expectedKavippuLong = (result.aarudam.absoluteLongitude + 180.0) % 360.0;
      expect(result.kavippu.absoluteLongitude, closeTo(expectedKavippuLong, 0.001));

      // 2. Verify 9 Navagrahas from Ephemeris
      expect(result.planets.length, 9);
      final planetNames = result.planets.map((p) => p.planetKey).toList();
      expect(planetNames, [
        'Sun',
        'Moon',
        'Mars',
        'Mercury',
        'Jupiter',
        'Venus',
        'Saturn',
        'Rahu',
        'Ketu',
      ]);

      // All planets have valid longitudes, houses, and DMS
      for (final p in result.planets) {
        expect(p.longitude, inInclusiveRange(0.0, 360.0));
        expect(p.rasiIndex, inInclusiveRange(0, 11));
        expect(p.house, inInclusiveRange(1, 12));
        expect(p.formattedDMS.contains('°'), isTrue);
      }

      // 3. Verify Jamam status
      expect(result.jamamNumber, inInclusiveRange(1, 8));
      expect(result.jamamLordTa.isNotEmpty, isTrue);

      // 4. Verify Predictions & Signs
      expect(result.predictions.isNotEmpty, isTrue);
      expect(result.favorableSignsTa.isNotEmpty, isTrue);
      expect(result.obstructiveSignsTa.isNotEmpty, isTrue);
      expect(result.generalSummaryTa.isNotEmpty, isTrue);
    });
  });
}
