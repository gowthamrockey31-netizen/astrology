import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:astrocall/services/astrology_calculator.dart';
import 'package:astrocall/widgets/south_indian_jathagam_widget.dart';
import 'package:astrocall/models/user_model.dart';

void main() {
  group('Gocharam Transit Planetary Calculation Tests', () {
    test('calculateTransits contains all 9 planets including Mercury and Venus', () {
      final transits = AstrologyCalculator.calculateTransits();

      expect(transits.length, equals(9));
      expect(transits.containsKey('Mercury'), isTrue);
      expect(transits.containsKey('Venus'), isTrue);
      expect(transits.containsKey('Sun'), isTrue);
      expect(transits.containsKey('Moon'), isTrue);
      expect(transits.containsKey('Mars'), isTrue);
      expect(transits.containsKey('Jupiter'), isTrue);
      expect(transits.containsKey('Saturn'), isTrue);
      expect(transits.containsKey('Rahu'), isTrue);
      expect(transits.containsKey('Ketu'), isTrue);

      final merc = transits['Mercury']!;
      expect(merc.tamilName, equals('புதன்'));
      expect(merc.symbol, equals('பு'));
      expect(merc.longitude, greaterThanOrEqualTo(0.0));
      expect(merc.longitude, lessThan(360.0));

      final ven = transits['Venus']!;
      expect(ven.tamilName, equals('சுக்கிரன்'));
      expect(ven.symbol, equals('சுக்'));
      expect(ven.longitude, greaterThanOrEqualTo(0.0));
      expect(ven.longitude, lessThan(360.0));
    });
  });

  group('SouthIndianJathagamWidget Rasi Box Touch Tests', () {
    testWidgets('Tapping a Rasi box renders elevated details card and triggers interaction', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final user = UserModel(
        id: 'test_123',
        name: 'Test Seeker',
        mobile: '+919876543210',
        gender: 'Male',
        dob: '1995-08-15',
        timeOfBirth: '01:25 PM',
        placeOfBirth: 'Erode',
        city: 'Erode',
        state: 'Tamil Nadu',
        country: 'India',
        zodiac: 'Simha',
        nakshatra: 'Magha',
        lagna: 'Vrischika',
        walletBalance: 100.0,
        profilePhoto: '',
        latitude: 11.3410,
        longitude: 77.7172,
        timezone: 5.5,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SouthIndianJathagamWidget(user: user),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify the widget rendered
      expect(find.text('ராசி (Rasi Chart D1)'), findsOneWidget);
      expect(find.text('Outer Orbit: Gocharam'), findsOneWidget);

      // Tap on Simmam Rasi box (rasiIdx = 4)
      final simmamBoxFinder = find.byKey(const Key('rasi_box_4'));
      expect(simmamBoxFinder, findsOneWidget);

      await tester.tap(simmamBoxFinder);
      await tester.pumpAndSettle();

      // The details card or modal with close button should appear
      expect(find.byIcon(Icons.close), findsWidgets);
    });
  });
}
