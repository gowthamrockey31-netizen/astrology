import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:astrocall/modules/jamakol_arudam_model_2/jamakol_arudam_model_2.dart';
import 'package:astrocall/screens/dashboard/dashboard_screen.dart';

void main() {
  group('ஜாமகோள் ஆருடம் Model 2 — Mathematical & Calculation Engine Tests', () {
    test('1. normalize() correctly clamps longitudes strictly to 0 <= deg < 360', () {
      expect(JamakkolCalculator.normalize(0.0), 0.0);
      expect(JamakkolCalculator.normalize(360.0), 0.0);
      expect(JamakkolCalculator.normalize(720.0), 0.0);
      expect(JamakkolCalculator.normalize(375.5), closeTo(15.5, 0.0001));
      expect(JamakkolCalculator.normalize(-30.0), closeTo(330.0, 0.0001));
      expect(JamakkolCalculator.normalize(-390.0), closeTo(330.0, 0.0001));
    });

    test('2. rasiFromLongitude() maps longitudes to 12 zodiac rasis accurately', () {
      // 0..30 Mesham (0)
      expect(JamakkolCalculator.rasiFromLongitude(0.0), 0);
      expect(JamakkolCalculator.rasiFromLongitude(15.0), 0);
      expect(JamakkolCalculator.rasiFromLongitude(29.99), 0);
      // 30..60 Rishabam (1)
      expect(JamakkolCalculator.rasiFromLongitude(30.0), 1);
      expect(JamakkolCalculator.rasiFromLongitude(45.5), 1);
      // 330..360 Meenam (11)
      expect(JamakkolCalculator.rasiFromLongitude(330.0), 11);
      expect(JamakkolCalculator.rasiFromLongitude(359.99), 11);
      // Overflow handling
      expect(JamakkolCalculator.rasiFromLongitude(365.0), 0);
    });

    test('3. houseFromLongitudes() calculates 1-based house from reference', () {
      // Same rasi = 1st house
      expect(JamakkolCalculator.houseFromLongitudes(10.0, 20.0), 1);
      // Next rasi = 2nd house
      expect(JamakkolCalculator.houseFromLongitudes(10.0, 40.0), 2);
      // 7th house (opposite sign)
      expect(JamakkolCalculator.houseFromLongitudes(10.0, 190.0), 7);
      // 12th house (previous sign)
      expect(JamakkolCalculator.houseFromLongitudes(40.0, 10.0), 12);
      expect(JamakkolCalculator.houseFromLongitudes(10.0, 340.0), 12);
    });

    test('4. formatDegree() returns formatted DD° MM′ strings', () {
      expect(JamakkolCalculator.formatDegree(0.0), '00° 00′');
      expect(JamakkolCalculator.formatDegree(15.5), '15° 30′');
      expect(JamakkolCalculator.formatDegree(45.75), '15° 45′'); // 45.75 % 30 = 15.75
    });

    test('5. makeMark() builds MarkPosition with proper house and coordinates', () {
      final mark = JamakkolCalculator.makeMark(
        'Udhayam',
        'உதயம்',
        142.5, // Simmam (4) ~ 22.5°
        const Color(0xFF00E676),
        'உ',
        refUdhayamLon: 142.5,
      );

      expect(mark.name, 'Udhayam');
      expect(mark.tamilName, 'உதயம்');
      expect(mark.rasiIndex, 4);
      expect(mark.rasiName, 'சிம்மம்');
      expect(mark.house, 1);
      expect(mark.symbol, 'உ');
      expect(mark.degreeInRasi, closeTo(22.5, 0.001));
      expect(mark.formattedDegree, '22° 30′');
    });

    test('6. demoJamakkol() produces valid demonstration snapshot', () {
      final demo = JamakkolCalculator.demoJamakkol();
      expect(demo.location, contains('Chennai'));
      expect(demo.udhayamLongitude, 142.5);
      expect(demo.arudhamLongitude, 38.0);
      expect(demo.kavippuLongitude, 218.0);
      expect(demo.outerPlanetsLongitudes.isNotEmpty, true);
      expect(demo.transitPlanetsLongitudes.isNotEmpty, true);
    });

    test('7. JamakkolCalculator.calculate() runs end-to-end on snapshot', () {
      final demo = JamakkolCalculator.demoJamakkol();
      final result = JamakkolCalculator.calculate(demo);

      expect(result.udhayam.name, 'Udhayam');
      expect(result.arudham.name, 'Arudham');
      expect(result.kavippu.name, 'Kavippu');
      expect(result.outerPlanets.length, demo.outerPlanetsLongitudes.length);
      expect(result.transitPlanets.length, demo.transitPlanetsLongitudes.length);
      expect(result.predictions.isNotEmpty, true);
    });

    test('8. JamakkolRuleEngine.predict() generates comprehensive Tamil predictions', () {
      final demo = JamakkolCalculator.demoJamakkol();
      final result = JamakkolCalculator.calculate(demo);

      expect(result.predictions.any((p) => p.contains('உதயம்')), true);
      expect(result.predictions.any((p) => p.contains('ஆருடம்')), true);
      expect(result.predictions.any((p) => p.contains('கவிப்பு')), true);
      expect(result.predictions.any((p) => p.contains('சாம')), true);
    });
  });

  group('ஜாமகோள் ஆருடம் Model 2 — UI Rendering Tests', () {
    testWidgets('JamakkolPrasannamPage renders Header, Marks, Legend, and Tables', (tester) async {
      tester.view.physicalSize = const Size(600, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: JamakkolPrasannamPage(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify Header
      expect(find.text('ஜாமகோள் பிரசன்னம்'), findsAtLeastNWidgets(1));
      expect(find.text('ஜாமகோள் ஆருடம் — Model 2'), findsOneWidget);

      // Verify Core Marks
      expect(find.text('உதயம்'), findsAtLeastNWidgets(1));
      expect(find.text('ஆருடம்'), findsAtLeastNWidgets(1));
      expect(find.text('கவிப்பு'), findsAtLeastNWidgets(1));

      // Verify Legend
      expect(find.text('வெளிவட்டம்'), findsAtLeastNWidgets(1));
      expect(find.text('கோச்சாரம்'), findsAtLeastNWidgets(1));

      // Verify Table Sections
      expect(find.text('வெளிவட்ட கிரகநிலைகள்'), findsOneWidget);
      expect(find.text('கோச்சார கிரகநிலைகள்'), findsOneWidget);

      // Verify Predictions Section
      expect(find.text('கிரகநிலைகளின் அடிப்படையிலான பலன்கள்'), findsOneWidget);
    });

    testWidgets('Navigation to /jamakol_arudam_model2 opens JamakkolPrasannamPage', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          initialRoute: '/',
          routes: {
            '/': (context) => Scaffold(
                  body: Center(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pushNamed(context, '/jamakol_arudam_model2'),
                      child: const Text('Open Model 2'),
                    ),
                  ),
                ),
            '/jamakol_arudam_model2': (context) => const JamakkolPrasannamPage(),
          },
        ),
      );

      await tester.pump();
      expect(find.text('Open Model 2'), findsOneWidget);

      await tester.tap(find.text('Open Model 2'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('ஜாமகோள் பிரசன்னம்'), findsAtLeastNWidgets(1));
      expect(find.text('ஜாமகோள் ஆருடம் — Model 2'), findsOneWidget);
    });

    testWidgets('DashboardScreen displays card with title ஜாமகோள் ஆருடம் and subtitle Model 2', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: const DashboardScreen(),
          routes: {
            '/jamakol_arudam_model2': (context) => const JamakkolPrasannamPage(),
          },
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      final finder = find.text('Model 2');
      for (int i = 0; i < 5; i++) {
        if (finder.evaluate().isNotEmpty) break;
        await tester.drag(find.byType(Scrollable).first, const Offset(0, -400));
        await tester.pump(const Duration(milliseconds: 200));
      }

      expect(finder, findsAtLeastNWidgets(1));
    });
  });
}
