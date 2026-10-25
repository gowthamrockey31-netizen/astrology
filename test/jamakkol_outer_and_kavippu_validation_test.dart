import 'package:flutter_test/flutter_test.dart';
import 'package:astrocall/services/jamakkol_chart_engine.dart';
import 'package:astrocall/jamakkol_prasannam/engine/kavippu_calculator.dart';
import 'package:astrocall/jamakkol_prasannam/models/jamakkol_models.dart';

void main() {
  group('Jamakkol Outer-Ring Planet Path Validation', () {
    const fixedSigns = [1, 4, 7, 10]; // Rishabam, Simham, Viruchigam, Kumbam

    test('Outer-ring planets NEVER land in Fixed signs across 24 hours', () {
      final baseDate = DateTime(2026, 10, 12);
      for (int hour = 0; hour < 24; hour++) {
        for (int min in [0, 5, 12, 27, 35, 48, 59]) {
          final queryTime = DateTime(baseDate.year, baseDate.month, baseDate.day, hour, min, 30);
          final chartData = JamakkolChartEngine.calculate(
            queryTime: queryTime,
            latitude: 13.0827,
            longitude: 80.2707,
            locationName: 'Chennai',
          );

          expect(chartData.outerPlanets.length, equals(8));
          for (final planet in chartData.outerPlanets) {
            // Regression check: Fixed signs are strictly forbidden
            expect(fixedSigns.contains(planet.rasiIndex), isFalse,
                reason: '${planet.key} at $hour:$min was placed in fixed sign ${planet.rasiIndex}');
            // Allowed signs are Chara (0, 3, 6, 9) and Ubhaya (2, 5, 8, 11)
            expect([0, 2, 3, 5, 6, 8, 9, 11].contains(planet.rasiIndex), isTrue);
            // Degree in rasi is preserved within [0.0, 30.0)
            expect(planet.degreeInRasi, inInclusiveRange(0.0, 30.0));
          }
        }
      }
    });

    test('Outer-ring fixed signs correctly map to corresponding Ubhaya signs', () {
      // Test explicit cases where raw position hits Fixed signs
      // Raw 1 (Rishabam) -> Mapped 2 (Mithunam)
      // Raw 4 (Simham) -> Mapped 5 (Kanni)
      // Raw 7 (Viruchigam) -> Mapped 8 (Dhanusu)
      // Raw 10 (Kumbam) -> Mapped 11 (Meenam)
      final query = DateTime(2026, 9, 20, 10, 34, 0);
      final chartData = JamakkolChartEngine.calculate(
        queryTime: query,
        latitude: 13.0827,
        longitude: 80.2707,
        locationName: 'Chennai',
      );

      final venus = chartData.outerPlanets.firstWhere((p) => p.key == 'Venus');
      final jupiter = chartData.outerPlanets.firstWhere((p) => p.key == 'Jupiter');
      final sun = chartData.outerPlanets.firstWhere((p) => p.key == 'Sun');
      final moon = chartData.outerPlanets.firstWhere((p) => p.key == 'Moon');

      // Raw Venus was 43° (Rishabam 13°) -> maps to Mithunam (2) 13° (73°)
      expect(venus.rasiIndex, equals(2)); // Mithunam
      expect(venus.degreeInRasi, closeTo(13.0, 0.01));
      expect(venus.formattedDegree, equals("சுக் 73° 00'"));

      // Raw Jupiter was 133° (Simham 13°) -> maps to Kanni (5) 13° (163°)
      expect(jupiter.rasiIndex, equals(5)); // Kanni
      expect(jupiter.degreeInRasi, closeTo(13.0, 0.01));
      expect(jupiter.formattedDegree, equals("குரு 163° 00'"));

      // Raw Sun was 223° (Viruchigam 13°) -> maps to Dhanusu (8) 13° (253°)
      expect(sun.rasiIndex, equals(8)); // Dhanusu
      expect(sun.degreeInRasi, closeTo(13.0, 0.01));
      expect(sun.formattedDegree, equals("சூரி 253° 00'"));

      // Raw Moon was 313° (Kumbam 13°) -> maps to Meenam (11) 13° (343°)
      expect(moon.rasiIndex, equals(11)); // Meenam
      expect(moon.degreeInRasi, closeTo(13.0, 0.01));
      expect(moon.formattedDegree, equals("சந் 343° 00'"));
    });
  });

  group('Kavippu 5-Minute Anti-Clockwise Progression Validation', () {
    test('Kavippu changes one rasi every 5 minutes in ANTI-CLOCKWISE direction', () {
      final baseDate = DateTime(2026, 10, 12, 10, 0, 0);

      int? previousRasi;
      for (int minute = 0; minute < 60; minute += 5) {
        final queryTime = baseDate.add(Duration(minutes: minute));
        final chartData = JamakkolChartEngine.calculate(
          queryTime: queryTime,
          latitude: 13.0827,
          longitude: 80.2707,
          locationName: 'Chennai',
        );

        final currentRasi = chartData.kavippu.rasiIndex;

        if (previousRasi != null) {
          // Anti-clockwise progression: next rasi is (prev - 1) mod 12
          final expectedRasi = (previousRasi - 1 + 12) % 12;
          expect(currentRasi, equals(expectedRasi),
              reason: 'At minute $minute, Kavippu moved from $previousRasi to $currentRasi instead of $expectedRasi');
        }
        previousRasi = currentRasi;
      }
    });

    test('Kavippu validated at all 12 five-minute boundaries (00, 05, 10, ... 55)', () {
      final testDate = DateTime(2026, 9, 20, 14, 0, 0);
      final rasisAtSlots = <int, int>{};

      for (int slot = 0; slot < 12; slot++) {
        final min = slot * 5;
        final time = testDate.add(Duration(minutes: min));
        final data = JamakkolChartEngine.calculate(
          queryTime: time,
          latitude: 13.0827,
          longitude: 80.2707,
          locationName: 'Chennai',
        );
        rasisAtSlots[min] = data.kavippu.rasiIndex;
      }

      // Ensure all 12 rasis are covered across 60 minutes
      final uniqueRasis = rasisAtSlots.values.toSet();
      expect(uniqueRasis.length, equals(12), reason: 'All 12 rasis must be visited in 60 minutes');

      // Verify each consecutive 5-minute jump steps exactly 1 rasi anti-clockwise
      final minutesList = [0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55];
      for (int i = 0; i < minutesList.length; i++) {
        final m1 = minutesList[i];
        final m2 = minutesList[(i + 1) % minutesList.length];
        final r1 = rasisAtSlots[m1]!;
        final r2 = rasisAtSlots[m2]!;
        expect((r1 - r2 + 12) % 12, equals(1),
            reason: 'Step from minute $m1 to $m2 did not move 1 rasi anti-clockwise ($r1 -> $r2)');
      }
    });

    test('Boundary crossing: immediately before, at, and immediately after 5-minute boundary', () {
      // Slot 1: 10:00:00 to 10:04:59
      // Slot 2: 10:05:00 to 10:09:59
      final tBefore = DateTime(2026, 10, 12, 10, 4, 59); // 4m 59s
      final tAt = DateTime(2026, 10, 12, 10, 5, 0);      // 5m 00s
      final tAfter = DateTime(2026, 10, 12, 10, 5, 1);   // 5m 01s

      final dBefore = JamakkolChartEngine.calculate(queryTime: tBefore, latitude: 13.0827, longitude: 80.2707, locationName: 'Chennai');
      final dAt = JamakkolChartEngine.calculate(queryTime: tAt, latitude: 13.0827, longitude: 80.2707, locationName: 'Chennai');
      final dAfter = JamakkolChartEngine.calculate(queryTime: tAfter, latitude: 13.0827, longitude: 80.2707, locationName: 'Chennai');

      // At 10:04:59, Kavippu is at the very tail of its first sign (close to 0°)
      expect(dBefore.kavippu.degreeInRasi, closeTo(0.1, 0.15));

      // At 10:05:00, Kavippu enters the NEXT anti-clockwise sign at 30°
      expect(dAt.kavippu.rasiIndex, equals((dBefore.kavippu.rasiIndex - 1 + 12) % 12));
      expect(dAt.kavippu.degreeInRasi, closeTo(30.0, 0.01));
      expect(dAt.kavippu.formattedDms, equals("30° 00'"));

      // At 10:05:01, Kavippu continues progressing downwards inside the new sign
      expect(dAfter.kavippu.rasiIndex, equals(dAt.kavippu.rasiIndex));
      expect(dAfter.kavippu.degreeInRasi, lessThan(30.0));
      expect(dAfter.kavippu.degreeInRasi, closeTo(29.9, 0.1));
    });

    test('Midnight 23:55 -> 00:00 day transition is smooth and anti-clockwise', () {
      final tNight = DateTime(2026, 11, 10, 23, 55, 0);
      final tMidnight = DateTime(2026, 11, 11, 0, 0, 0);

      final dNight = JamakkolChartEngine.calculate(queryTime: tNight, latitude: 13.0827, longitude: 80.2707, locationName: 'Chennai');
      final dMidnight = JamakkolChartEngine.calculate(queryTime: tMidnight, latitude: 13.0827, longitude: 80.2707, locationName: 'Chennai');

      // Both stay in Udayam Rishabam (1) across this 5-minute boundary
      expect(dNight.udhayam.rasiIndex, equals(dMidnight.udhayam.rasiIndex));

      // Kavippu steps exactly 1 rasi anti-clockwise: (dNight - dMidnight) mod 12 == 1
      final diff = (dNight.kavippu.rasiIndex - dMidnight.kavippu.rasiIndex + 12) % 12;
      expect(diff, equals(1),
          reason: '23:55 (${dNight.kavippu.rasiIndex}) to 00:00 (${dMidnight.kavippu.rasiIndex}) transition was not 1 rasi anti-clockwise');
    });

    test('Consistency: KavippuCalculator and JamakkolChartEngine produce matching Kavippu given same Udayam', () {
      final testDate = DateTime(2026, 10, 12, 11, 23, 45);
      final location = JamakkolLocation.defaultChennai;

      final chartEngineData = JamakkolChartEngine.calculate(
        queryTime: testDate,
        latitude: location.latitude,
        longitude: location.longitude,
        locationName: location.name,
      );

      final kavippuFromCalc = KavippuCalculator.calculateKavippu(
        queryDateTime: testDate,
        udayamRasiIndex: chartEngineData.udhayam.rasiIndex,
        sunLongitude: chartEngineData.skyPlanets['Sun']!.longitude,
      );

      // Kavippu must match identically
      expect(kavippuFromCalc.rasiIndex, equals(chartEngineData.kavippu.rasiIndex));
      expect(kavippuFromCalc.degreeInRasi, closeTo(chartEngineData.kavippu.degreeInRasi, 0.01));
    });

    test('Multiple locations offline: Kavippu and outer planets calculate robustly', () {
      final locations = [
        {'name': 'Chennai', 'lat': 13.0827, 'lon': 80.2707},
        {'name': 'Madurai', 'lat': 9.9252, 'lon': 78.1198},
        {'name': 'Thiruvarur', 'lat': 10.7661, 'lon': 79.6384},
        {'name': 'Coimbatore', 'lat': 11.0168, 'lon': 76.9558},
        {'name': 'Delhi', 'lat': 28.6139, 'lon': 77.2090},
      ];

      for (final loc in locations) {
        final queryTime = DateTime(2026, 10, 12, 16, 20, 15);
        final data = JamakkolChartEngine.calculate(
          queryTime: queryTime,
          latitude: loc['lat'] as double,
          longitude: loc['lon'] as double,
          locationName: loc['name'] as String,
        );

        expect(data.kavippu.rasiIndex, inInclusiveRange(0, 11));
        expect(data.kavippu.degreeInRasi, inInclusiveRange(0.0, 30.0));
        expect(data.outerPlanets.length, equals(8));
      }
    });
  });
}
