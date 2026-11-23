import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:astrocall/kp_method_2/kp_method_2.dart';

void main() {
  group('KP2 Ruling Planets Reference Image Verification (14-11-2026)', () {
    test('Calculates and verifies ruling planets for Chennai, Kundrathur test case', () {
      final kundrathur = KP2BirthData(
        date: DateTime(2026, 11, 14),
        time: '08:49:22 AM',
        place: 'Chennai, Kundrathur',
        latitude: 12.9977,
        longitude: 80.0972,
        timezone: 5.5,
      );

      final res = KP2CompleteEngine.calculate(kundrathur);
      final rp = res.rulingPlanets;

      print('=== Verification for Kundrathur (12.9977, 80.0972) ===');
      print('Day Lord: ${rp.dayLord.nameEn} (${rp.dayLord.nameTa})');
      print('Lagna: ${rp.ascSignLord.shortNameTa}, ${rp.ascStarLord.shortNameTa}, ${rp.ascSubLord.shortNameTa}, ${rp.ascSubSubLord.shortNameTa}, ${rp.ascSubSubSubLord.shortNameTa}');
      print('Moon: ${rp.moonSignLord.shortNameTa}, ${rp.moonStarLord.shortNameTa}, ${rp.moonSubLord.shortNameTa}, ${rp.moonSubSubLord.shortNameTa}, ${rp.moonSubSubSubLord.shortNameTa}');

      // 1. Day Lord verification: 14-11-2026 is Saturday -> Saturn (சனி)
      expect(kundrathur.localDateTime.weekday, equals(DateTime.saturday));
      expect(rp.dayLord, equals(KP2Planet.saturn));
      expect(rp.dayLord.shortNameTa, equals('சனி'));

      // 2. Transit Ascendant (லக்னம்) — Five Ruling Planets
      expect(rp.ascSignLord, equals(KP2Planet.jupiter)); // குரு
      expect(rp.ascStarLord, equals(KP2Planet.ketu));    // கேது
      expect(rp.ascSubLord, equals(KP2Planet.sun));      // சூரி / சூரியன்
      expect(rp.ascSubSubLord, equals(KP2Planet.mercury)); // புத / புதன்
      expect(rp.ascSubSubSubLord, isNotNull);

      // 3. Transit Moon (சந்திரன்) — Five Ruling Planets
      expect(rp.moonSignLord, equals(KP2Planet.jupiter)); // குரு
      expect(rp.moonStarLord, equals(KP2Planet.venus));   // சுக் / சுக்கிரன்
      expect(rp.moonSubLord, equals(KP2Planet.jupiter));  // குரு
      expect(rp.moonSubSubLord, isNotNull);
      expect(rp.moonSubSubSubLord, isNotNull);

      // 4. Ten Ruling Planets collection
      expect(rp.ascendantRulingPlanets.length, equals(5));
      expect(rp.moonRulingPlanets.length, equals(5));
      expect(rp.tenRulingPlanets.length, equals(10));

      // 5. Preserves duplicate planets across positions
      for (final planet in rp.tenRulingPlanets) {
        expect(planet, isNotNull);
      }
      expect(rp.tenRulingPlanets.contains(KP2Planet.jupiter), isTrue);
      // Jupiter appears multiple times (Lagna sign lord, Moon sign lord, Moon sub lord)
      final jupiterCount = rp.tenRulingPlanets.where((p) => p == KP2Planet.jupiter).length;
      expect(jupiterCount, greaterThanOrEqualTo(2));
    });

    testWidgets('KP2RulingPlanetsWidget renders reference table layout cleanly', (tester) async {
      final kundrathur = KP2BirthData(
        date: DateTime(2026, 11, 14),
        time: '08:49:22 AM',
        place: 'Chennai, Kundrathur',
        latitude: 12.9977,
        longitude: 80.0972,
        timezone: 5.5,
      );

      final res = KP2CompleteEngine.calculate(kundrathur);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: KP2RulingPlanetsWidget(
                rulingPlanets: res.rulingPlanets,
                birthData: res.birthData,
              ),
            ),
          ),
        ),
      );

      // Verify table text elements appear
      expect(find.text('ஆளும் கிரகங்கள்'), findsOneWidget);
      expect(find.textContaining('14-11-2026'), findsOneWidget);
      expect(find.textContaining('Chennai, Kundrathur'), findsOneWidget);
      expect(find.textContaining('நாள் அதிபதி: சனி'), findsOneWidget);
      expect(find.text('கிரகம்'), findsOneWidget);
      expect(find.text('ரா.அ'), findsOneWidget);
      expect(find.text('ந.அ'), findsOneWidget);
      expect(find.text('உ.அ'), findsOneWidget);
      expect(find.text('உ.உ'), findsOneWidget);
      expect(find.text('உ.உ.உ'), findsOneWidget);
      expect(find.text('லக்னம்'), findsOneWidget);
      expect(find.text('சந்திரன்'), findsOneWidget);
      expect(find.byType(Table), findsOneWidget);
    });
  });
}
