import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:astrocall/models/user_model.dart';
import 'package:astrocall/models/mundane_models.dart';
import 'package:astrocall/services/auth_service.dart';
import 'package:astrocall/services/mundane_calculator.dart';
import 'package:astrocall/screens/mundane_astrology/mundane_astrology_screen.dart';

void main() {
  group('Mundane Astrology (உலகியல் ஜோதிடம்) Complete Module & Access Tests', () {
    final userModel = UserModel(
      id: 'usr_normal',
      name: 'Normal User',
      mobile: '+919876543210',
      gender: 'Male',
      dob: '1995-05-10',
      timeOfBirth: '08:30 AM',
      placeOfBirth: 'Chennai',
      city: 'Chennai',
      state: 'Tamil Nadu',
      country: 'India',
      zodiac: 'Taurus',
      nakshatra: 'Rohini',
      lagna: 'Taurus',
      walletBalance: 500.0,
      role: 'User',
      profilePhoto: '',
    );

    final adminModel = UserModel(
      id: 'usr_admin',
      name: 'Admin User',
      mobile: '+919999999999',
      gender: 'Male',
      dob: '1990-01-01',
      timeOfBirth: '10:00 AM',
      placeOfBirth: 'Chennai',
      city: 'Chennai',
      state: 'Tamil Nadu',
      country: 'India',
      zodiac: 'Capricorn',
      nakshatra: 'Uttara Ashadha',
      lagna: 'Aries',
      walletBalance: 99999.0,
      role: 'Admin',
      profilePhoto: '',
    );

    test('1. Role check: User and Astrologer are not Admin, Admin is verified', () {
      // Normal User
      AuthService.updateCurrentUser(userModel);
      AuthService.setActiveRole('User');
      expect(AuthService.isAdmin, false);
      expect(userModel.isAdmin, false);

      // Astrologer
      AuthService.setActiveRole('Astrologer');
      expect(AuthService.isAdmin, false);

      // Admin
      AuthService.updateCurrentUser(adminModel);
      AuthService.setActiveRole('Admin');
      expect(AuthService.isAdmin, true);
      expect(adminModel.isAdmin, true);
    });

    test('2. 9 Planets: DMS, House, Nakshatra, Pada and Ascending Longitude Sorting', () {
      final now = DateTime(2026, 8, 28, 12, 0);
      final chart = MundaneCalculator.calculateMundaneChart(dateTime: now);

      expect(chart.planetPositions.length, 9);

      // Verify Ascending Absolute Longitude Sorting (0° -> 360°)
      for (int i = 0; i < chart.planetPositions.length - 1; i++) {
        expect(chart.planetPositions[i].longitude, lessThanOrEqualTo(chart.planetPositions[i + 1].longitude));
      }

      for (final p in chart.planetPositions) {
        expect(p.formattedDMS.contains('°'), true);
        expect(p.formattedDMS.contains("'"), true);
        expect(p.house, inInclusiveRange(1, 12));
        expect(p.pada, inInclusiveRange(1, 4));
        expect(p.nakshatraNameTa.isNotEmpty, true);
      }
    });

    test('3. Aspect Calculator: Conjunction, Sextile, Square, Trine, Opposition', () {
      final p1 = PlanetPosition.fromAbsoluteLongitude(name: 'Sun', tamilName: 'சூரியன்', absoluteLongitude: 10.0);
      final p2 = PlanetPosition.fromAbsoluteLongitude(name: 'Moon', tamilName: 'சந்திரன்', absoluteLongitude: 12.0); // Conjunction (2° diff)
      final p3 = PlanetPosition.fromAbsoluteLongitude(name: 'Mars', tamilName: 'செவ்வாய்', absoluteLongitude: 70.0); // Sextile (60° diff)
      final p4 = PlanetPosition.fromAbsoluteLongitude(name: 'Jupiter', tamilName: 'குரு', absoluteLongitude: 100.0); // Square (90° diff)
      final p5 = PlanetPosition.fromAbsoluteLongitude(name: 'Saturn', tamilName: 'சனி', absoluteLongitude: 130.0); // Trine (120° diff)
      final p6 = PlanetPosition.fromAbsoluteLongitude(name: 'Rahu', tamilName: 'ராகு', absoluteLongitude: 190.0); // Opposition (180° diff)

      final aspects = AspectCalculator.calculateAspects([p1, p2, p3, p4, p5, p6]);
      expect(aspects.any((a) => a.aspectType == 'Conjunction'), true);
      expect(aspects.any((a) => a.aspectType == 'Sextile'), true);
      expect(aspects.any((a) => a.aspectType == 'Square'), true);
      expect(aspects.any((a) => a.aspectType == 'Trine'), true);
      expect(aspects.any((a) => a.aspectType == 'Opposition'), true);
    });

    test('4. House Cluster Detection: identifies >= 3 planets in same house', () {
      final p1 = PlanetPosition.fromAbsoluteLongitude(name: 'Sun', tamilName: 'சூரியன்', absoluteLongitude: 10.0, house: 10);
      final p2 = PlanetPosition.fromAbsoluteLongitude(name: 'Mercury', tamilName: 'புதன்', absoluteLongitude: 15.0, house: 10);
      final p3 = PlanetPosition.fromAbsoluteLongitude(name: 'Venus', tamilName: 'சுக்கிரன்', absoluteLongitude: 20.0, house: 10);
      final p4 = PlanetPosition.fromAbsoluteLongitude(name: 'Mars', tamilName: 'செவ்வாய்', absoluteLongitude: 50.0, house: 11);

      final clusters = HouseClusterDetector.detectClusters([p1, p2, p3, p4]);
      expect(clusters.length, 1);
      expect(clusters.first.houseNumber, 10);
      expect(clusters.first.planetCount, 3);
      expect(clusters.first.predictionStrength, greaterThanOrEqualTo(70));
    });

    test('5. Mundane Prediction Engine: Sorted descending by strength (0 to 100)', () {
      final now = DateTime(2026, 8, 28, 12, 0);
      final chart = MundaneCalculator.calculateMundaneChart(dateTime: now);

      expect(chart.predictions.isNotEmpty, true);

      // Verify descending sort by strength
      for (int i = 0; i < chart.predictions.length - 1; i++) {
        expect(chart.predictions[i].strength, greaterThanOrEqualTo(chart.predictions[i + 1].strength));
      }

      for (final pred in chart.predictions) {
        expect(pred.strength, inInclusiveRange(0, 100));
        expect(pred.categoryTa.isNotEmpty, true);
        expect(pred.descriptionTa.isNotEmpty, true);
      }
    });

    test('6. Transit Comparison Engine & Demo India Independence Chart 1947', () {
      final demo = MundaneExample.indiaIndependenceChart;
      expect(demo.country, 'India');
      expect(demo.chartDateTime.year, 1947);
      expect(demo.clusters.isNotEmpty, true);
      expect(demo.predictions.isNotEmpty, true);

      final current = MundaneCalculator.calculateMundaneChart(dateTime: DateTime(2026, 8, 28));
      final transitComp = MundaneTransitEngine.compareTransits(
        eventPlanets: demo.planetPositions,
        transitPlanets: current.planetPositions,
      );
      expect(transitComp, isA<List<MundaneTransitComparison>>());
    });

    test('7. 12 Mundane Houses & 9 Planetary Significations Data Check', () {
      expect(MundaneData.houseMeaningsTa.length, 12);
      expect(MundaneData.houseMeaningsTa[1]!.contains('மக்கள்'), true);
      expect(MundaneData.houseMeaningsTa[10]!.contains('அரசு'), true);

      expect(MundaneData.planetarySignificationsTa.length, 9);
      expect(MundaneData.planetarySignificationsTa['Sun']!.contains('அரசு'), true);
    });

    testWidgets('8. Non-admin user accessing MundaneAstrologyScreen sees Access Denied and no data exposed', (WidgetTester tester) async {
      AuthService.updateCurrentUser(userModel);
      AuthService.setActiveRole('User');

      await tester.pumpWidget(
        MaterialApp(
          routes: {
            '/user_dashboard': (context) => const Scaffold(body: Text('User Dashboard Screen')),
          },
          home: const MundaneAstrologyScreen(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      // Access Denied screen must be displayed
      expect(find.textContaining('Access Denied'), findsOneWidget);
      // Ensure Mundane predictions are NOT exposed
      expect(find.text('தேசிய & உலகளாவிய பலன்கள் (Mundane Predictions)'), findsNothing);
    });

    testWidgets('9. Admin user accessing MundaneAstrologyScreen views complete module and sections', (WidgetTester tester) async {
      AuthService.updateCurrentUser(adminModel);
      AuthService.setActiveRole('Admin');

      final chart = MundaneCalculator.calculateMundaneChart(dateTime: DateTime(2026, 8, 28, 12, 0));

      await tester.pumpWidget(
        MaterialApp(
          home: MundaneAstrologyScreen(chart: chart),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      // Verify Admin views Mundane Astrology module
      expect(find.text('உலகியல் ஜோதிடம்'), findsOneWidget);
      expect(find.text('Admin Only'), findsOneWidget);
      expect(find.text('நிகழ்வு & பிராந்திய விவரங்கள் (Location & Event Details)'), findsOneWidget);
      expect(find.text('9 கிரக நிலைகள் (Planetary Longitudes - 0° to 360° Ascending)'), findsOneWidget);
      expect(find.text('தேசிய & உலகளாவிய பலன்கள் (Mundane Predictions)'), findsOneWidget);
    });
  });
}
