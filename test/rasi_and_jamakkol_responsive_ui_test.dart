import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:astrocall/models/user_model.dart';
import 'package:astrocall/services/astrology_calculator.dart';
import 'package:astrocall/widgets/south_indian_rasi_chart.dart';
import 'package:astrocall/widgets/south_indian_jathagam_widget.dart';
import 'package:astrocall/jamakkol_prasannam/models/jamakkol_models.dart';
import 'package:astrocall/jamakkol_prasannam/screens/jamakkol_home_screen.dart';
import 'package:astrocall/jamakkol_prasannam/screens/jamakkol_result_screen.dart';
import 'package:astrocall/jamakkol_prasannam/widgets/jamakkol_chart.dart';
import 'package:astrocall/jamakkol_prasannam/engine/jamakkol_engine.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final testUser = UserModel(
    id: 'user_1',
    name: 'Seeker',
    mobile: '+919876543210',
    gender: 'Male',
    dob: '1995-05-15',
    timeOfBirth: '10:30 AM',
    placeOfBirth: 'Chennai',
    city: 'Chennai',
    state: 'Tamil Nadu',
    country: 'India',
    zodiac: 'Mesham',
    nakshatra: 'Ashwini',
    lagna: 'Rishabam',
    walletBalance: 100.0,
    profilePhoto: '',
    latitude: 13.0827,
    longitude: 80.2707,
    timezone: 5.5,
  );

  final testState = JamakkolEngine.calculateChart(
    queryDateTime: DateTime(2026, 9, 29, 10, 30),
    location: JamakkolLocation.defaultChennai,
    question: 'தொழில் வெற்றி பெறுமா?',
    questionCategory: JamakkolQuestionCategory.job,
  );

  group('Rasi Chart UI Layout & Responsiveness', () {
    testWidgets('SouthIndianRasiChart renders without overflow on mobile portrait (360x640)', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final transits = AstrologyCalculator.calculateTransits();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SouthIndianRasiChart(
                title: 'ராசி மண்டலம்',
                planets: transits,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('ராசி மண்டலம்'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('SouthIndianRasiChart renders on Desktop (1440x900)', (tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final transits = AstrologyCalculator.calculateTransits();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SouthIndianRasiChart(
                title: 'ராசி மண்டலம்',
                planets: transits,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('ராசி மண்டலம்'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('SouthIndianJathagamWidget renders with stretched downward Rasi chart', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SouthIndianJathagamWidget(user: testUser),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('ஜாதக கட்டங்கள் (ராசி & நவாம்சம்)'), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Verify all 12 rasi cells are present
      for (int i = 0; i < 12; i++) {
        expect(find.byKey(Key('rasi_box_$i')), findsOneWidget);
      }

      // Verify the 4 rows expand across the container:
      // Row 0 cell (Mesham: rasi_box_0) and Row 3 cell (Kanni: rasi_box_5)
      final meshamBox = tester.getRect(find.byKey(const Key('rasi_box_0')));
      final kanniBox = tester.getRect(find.byKey(const Key('rasi_box_5')));
      // Row 3 should be positioned significantly below Row 0, with equal row heights
      expect(kanniBox.top, greaterThan(meshamBox.bottom));
      expect(kanniBox.height, greaterThan(50.0));
      expect((kanniBox.height - meshamBox.height).abs(), lessThan(2.0)); // Equal height across rows

      // Verify outer orbit cells exist
      expect(find.byKey(const Key('outer_orbit_rasi_8')), findsOneWidget);
      expect(find.byKey(const Key('outer_orbit_rasi_6')), findsOneWidget);
      expect(find.byKey(const Key('outer_orbit_rasi_5')), findsOneWidget);
    });
  });

  group('Jamakkol Prasannam Mobile Layout & Text Visibility', () {
    testWidgets('JamakkolChartWidget displays all cells without clipping on mobile portrait (360x640)', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: JamakkolChartWidget(
                state: testState,
                isTamil: true,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('ஜாமக்கோள் பிரசன்னம்'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('JamakkolLiveScreen renders lower text & remedy section without overflow on mobile', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: JamakkolHomeScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify header and core widgets
      expect(find.text('ஜாமக்கோள் பிரசன்னம்'), findsAtLeastNWidgets(1));

      // Scroll to bottom to verify lower content is fully visible
      final scrollable = find.byType(Scrollable).first;
      await tester.scrollUntilVisible(
        find.text('வழிகாட்டல் & ஜோதிடப் பரிகாரம்'),
        300,
        scrollable: scrollable,
      );
      await tester.pumpAndSettle();

      expect(find.text('வழிகாட்டல் & ஜோதிடப் பரிகாரம்'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('JamakkolResultScreen renders full consultation report with remedies on mobile', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: JamakkolResultScreen(
            state: testState,
            isTamil: true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('பிரசன்ன ஆய்வு அறிக்கை'), findsOneWidget);

      final scrollable = find.byType(Scrollable).first;
      await tester.scrollUntilVisible(
        find.text('ஜோதிடப் பரிகாரம் & வழிகாட்டல்'),
        300,
        scrollable: scrollable,
      );
      await tester.pumpAndSettle();

      expect(find.text('ஜோதிடப் பரிகாரம் & வழிகாட்டல்'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
