import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:astrocall/jamakkol_prasannam/engine/jamakkol_engine.dart';
import 'package:astrocall/jamakkol_prasannam/engine/jamakkol_planet_calculator.dart';
import 'package:astrocall/jamakkol_prasannam/models/jamakkol_models.dart';
import 'package:astrocall/jamakkol_prasannam/models/jamakkol_planet_models.dart';
import 'package:astrocall/jamakkol_prasannam/widgets/jamakkol_chart.dart';

void main() {
  group('Jamakkol Prasannam - Mrityu and Mandi Placement Regression Tests', () {
    test('1. Reference screenshot verification: Monday Oct 26, 2026 05:07 PM Chennai', () {
      final query = DateTime(2026, 10, 26, 17, 7, 0);
      final chart = JamakkolEngine.calculateChart(
        queryDateTime: query,
        location: JamakkolLocation.defaultChennai,
      );

      // Verify Sunrise remains 5:58 AM
      expect(chart.sunrise.hour, equals(5));
      expect(chart.sunrise.minute, equals(58));

      // Mandi verification:
      // Reference shows Mandi in Kumbam (10) at 20° 50'
      final mandi = chart.upagrahas.firstWhere((p) => p.type == SpecialPointType.mandi);
      expect(mandi.rasiIndex, equals(10), reason: 'Mandi must be in Kumbam (10)');
      expect(mandi.rasiNameTa, equals('கும்பம்'));
      expect(mandi.degreeInRasi, closeTo(20.84, 0.1), reason: 'Mandi degree ~20° 50\'');
      expect(chart.mandiRasi, equals(10));
      expect(chart.specialPointsByRasi[10]!.any((p) => p.type == SpecialPointType.mandi), isTrue);

      // Mrityu verification:
      // Reference shows Mrityu in Vrichikam (7) at 14° 50'
      final mrityu = chart.upagrahas.firstWhere((p) => p.type == SpecialPointType.mrityu);
      expect(mrityu.rasiIndex, equals(7), reason: 'Mrityu must be in Vrichikam (7)');
      expect(mrityu.rasiNameTa, equals('விருச்சிகம்'));
      expect(mrityu.degreeInRasi, closeTo(14.84, 0.1), reason: 'Mrityu degree ~14° 50\'');
      expect(chart.mridyuRasi, equals(7));
      expect(chart.specialPointsByRasi[7]!.any((p) => p.type == SpecialPointType.mrityu), isTrue);

      // Verify all other special points and core pillars remain unchanged
      expect(chart.udayam.rasiIndex, equals(5)); // Kanni
      expect(chart.arudam.rasiIndex, equals(1)); // Rishabam
      expect(chart.kavippu.rasiIndex, equals(5)); // Kanni
      expect(chart.rahuKalamRasi, equals(9)); // Makaram
      expect(chart.emakandamRasi, equals(6)); // Thulam
    });

    test('2. Changing query date/time dynamically updates both points across all 7 weekdays', () {
      // Sunday Oct 25, 2026 12:00 PM
      final chartSun = JamakkolEngine.calculateChart(
        queryDateTime: DateTime(2026, 10, 25, 12, 0, 0),
        location: JamakkolLocation.defaultChennai,
      );
      expect(chartSun.mandiRasi, equals(11)); // Meenam 13° 37'
      expect(chartSun.mridyuRasi, equals(8)); // Dhanusu 7° 37'

      // Tuesday Oct 27, 2026 12:00 PM
      final chartTue = JamakkolEngine.calculateChart(
        queryDateTime: DateTime(2026, 10, 27, 12, 0, 0),
        location: JamakkolLocation.defaultChennai,
      );
      expect(chartTue.mandiRasi, equals(9)); // Makaram 27° 37'
      expect(chartTue.mridyuRasi, equals(6)); // Thulam 21° 37'

      // Wednesday Oct 28, 2026 12:00 PM
      final chartWed = JamakkolEngine.calculateChart(
        queryDateTime: DateTime(2026, 10, 28, 12, 0, 0),
        location: JamakkolLocation.defaultChennai,
      );
      expect(chartWed.mandiRasi, equals(9)); // Makaram 4° 37'
      expect(chartWed.mridyuRasi, equals(11)); // Meenam 16° 37'

      // Thursday Oct 29, 2026 12:00 PM
      final chartThu = JamakkolEngine.calculateChart(
        queryDateTime: DateTime(2026, 10, 29, 12, 0, 0),
        location: JamakkolLocation.defaultChennai,
      );
      expect(chartThu.mandiRasi, equals(8)); // Dhanusu 11° 36'
      expect(chartThu.mridyuRasi, equals(10)); // Kumbam 23° 36'

      // Friday Oct 30, 2026 12:00 PM
      final chartFri = JamakkolEngine.calculateChart(
        queryDateTime: DateTime(2026, 10, 30, 12, 0, 0),
        location: JamakkolLocation.defaultChennai,
      );
      expect(chartFri.mandiRasi, equals(7)); // Vrichikam 18° 36'
      expect(chartFri.mridyuRasi, equals(10)); // Kumbam 0° 36'

      // Saturday Oct 31, 2026 12:00 PM
      final chartSat = JamakkolEngine.calculateChart(
        queryDateTime: DateTime(2026, 10, 31, 12, 0, 0),
        location: JamakkolLocation.defaultChennai,
      );
      expect(chartSat.mandiRasi, equals(6)); // Thulam 25° 36'
      expect(chartSat.mridyuRasi, equals(9)); // Makaram 7° 36'
    });

    test('3. Nighttime calculations for Mandi and Mrityu match reference values', () {
      // Monday Oct 26, 2026 21:00:00 (Night Jamam)
      final chartMonNight = JamakkolEngine.calculateChart(
        queryDateTime: DateTime(2026, 10, 26, 21, 0, 0),
        location: JamakkolLocation.defaultChennai,
      );
      // Mandi in Rishabam (1) 14° 59'
      expect(chartMonNight.mandiRasi, equals(1));
      final mandi = chartMonNight.upagrahas.firstWhere((p) => p.type == SpecialPointType.mandi);
      expect(mandi.degreeInRasi, closeTo(14.99, 0.1));

      // Mrityu in Kadagam (3) 26° 59'
      expect(chartMonNight.mridyuRasi, equals(3));
      final mrityu = chartMonNight.upagrahas.firstWhere((p) => p.type == SpecialPointType.mrityu);
      expect(mrityu.degreeInRasi, closeTo(26.99, 0.1));
    });

    test('4. Boundary transitions: Positions smoothly transition across Rasi boundaries', () {
      // Simulate Sun moving from 29.9° to 0.1° across boundary
      final lonBefore = JamakkolPlanetCalculator.calculateMandiLongitude(
        weekdayNumber: 1,
        sunLongitude: 29.9,
        isDay: true,
      );
      final lonAfter = JamakkolPlanetCalculator.calculateMandiLongitude(
        weekdayNumber: 1,
        sunLongitude: 30.1,
        isDay: true,
      );

      expect((lonAfter - lonBefore).abs(), closeTo(0.2, 0.001));
    });

    testWidgets('5. Full UI Chart Widget renders Mandi in Kumbam and Mrityu in Vrichikam matching reference', (tester) async {
      final query = DateTime(2026, 10, 26, 17, 7, 0);
      final chart = JamakkolEngine.calculateChart(
        queryDateTime: query,
        location: JamakkolLocation.defaultChennai,
        isLive: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: JamakkolChartWidget(state: chart, isTamil: true),
            ),
          ),
        ),
      );
      await tester.pump();

      // Mandi badge (மாந் 20° 50') must be rendered in the chart
      expect(find.text('மாந் 20° 50\''), findsOneWidget);

      // Mrityu badge (மிரு 14° 50') must be rendered in the chart
      expect(find.text('மிரு 14° 50\''), findsOneWidget);

      // Verify Center Dashboard contains Mrityu in Vrichikam
      expect(find.text('விருச்சிகம்'), findsWidgets);

      // Verify Sunrise is 5:58 AM
      expect(find.textContaining('5:58 AM'), findsWidgets);
    });
  });
}
