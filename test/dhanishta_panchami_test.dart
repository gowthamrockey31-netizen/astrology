import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:astrocall/modules/dhanishta_panchami/dhanishta_panchami.dart';

void main() {
  group('Dhanishta Panchami & Tithi Adaippu Rule Validation', () {
    test('1. Avittam (23) + Panchami (5) -> Dhanishta Panchami = TRUE', () {
      final rShukla = DhanishtaCalculator.calculateFromIndices(
        nakshatraNumber: 23, // Avittam
        tithiNumber: 5,      // Shukla Panchami
      );
      expect(rShukla.isDhanishtaPanchami, isTrue);
      expect(rShukla.nakshatraNumber, 23);
      expect(rShukla.nakshatraTamil, 'அவிட்டம்');
      expect(rShukla.tithiTamil, 'பஞ்சமி');

      final rKrishna = DhanishtaCalculator.calculateFromIndices(
        nakshatraNumber: 23, // Avittam
        tithiNumber: 20,     // Krishna Panchami (15 + 5)
      );
      expect(rKrishna.isDhanishtaPanchami, isTrue);
      expect(rKrishna.pakshaTamil, 'கிருஷ்ண பக்ஷம்');
      expect(rKrishna.tithiTamil, 'பஞ்சமி');
    });

    test('2. Avittam (23) + non-Panchami -> Dhanishta Panchami = FALSE', () {
      // Avittam + Chaturthi (4)
      final r4 = DhanishtaCalculator.calculateFromIndices(
        nakshatraNumber: 23,
        tithiNumber: 4,
      );
      expect(r4.isDhanishtaPanchami, isFalse);

      // Avittam + Sashti (6)
      final r6 = DhanishtaCalculator.calculateFromIndices(
        nakshatraNumber: 23,
        tithiNumber: 6,
      );
      expect(r6.isDhanishtaPanchami, isFalse);

      // Avittam + Purnima (15)
      final r15 = DhanishtaCalculator.calculateFromIndices(
        nakshatraNumber: 23,
        tithiNumber: 15,
      );
      expect(r15.isDhanishtaPanchami, isFalse);
    });

    test('3. Non-Avittam + Panchami (5) -> Dhanishta Panchami = FALSE', () {
      // Thiruvonam (22) + Panchami (5)
      final r22 = DhanishtaCalculator.calculateFromIndices(
        nakshatraNumber: 22,
        tithiNumber: 5,
      );
      expect(r22.isDhanishtaPanchami, isFalse);

      // Sathayam (24) + Panchami (5)
      final r24 = DhanishtaCalculator.calculateFromIndices(
        nakshatraNumber: 24,
        tithiNumber: 5,
      );
      expect(r24.isDhanishtaPanchami, isFalse);

      // Ashwini (1) + Panchami (5)
      final r1 = DhanishtaCalculator.calculateFromIndices(
        nakshatraNumber: 1,
        tithiNumber: 5,
      );
      expect(r1.isDhanishtaPanchami, isFalse);
    });

    test('4. Avittam (23) -> 6-month Adaippu', () {
      final r = DhanishtaCalculator.calculateFromIndices(
        nakshatraNumber: 23,
        tithiNumber: 1,
      );
      expect(r.isAdaippuNakshatra, isTrue);
      expect(r.adaippuMonths, 6);
      expect(r.adaippuType, 'ஆறு மாத அடைப்பு');
    });

    test('5. Sathayam (24) -> 6-month Adaippu', () {
      final r = DhanishtaCalculator.calculateFromIndices(
        nakshatraNumber: 24,
        tithiNumber: 1,
      );
      expect(r.isAdaippuNakshatra, isTrue);
      expect(r.adaippuMonths, 6);
      expect(r.adaippuType, 'ஆறு மாத அடைப்பு');
    });

    test('6. Poorattathi (25) -> 6-month Adaippu', () {
      final r = DhanishtaCalculator.calculateFromIndices(
        nakshatraNumber: 25,
        tithiNumber: 1,
      );
      expect(r.isAdaippuNakshatra, isTrue);
      expect(r.adaippuMonths, 6);
      expect(r.adaippuType, 'ஆறு மாத அடைப்பு');
    });

    test('7. Uthirattathi (26) -> 6-month Adaippu', () {
      final r = DhanishtaCalculator.calculateFromIndices(
        nakshatraNumber: 26,
        tithiNumber: 1,
      );
      expect(r.isAdaippuNakshatra, isTrue);
      expect(r.adaippuMonths, 6);
      expect(r.adaippuType, 'ஆறு மாத அடைப்பு');
    });

    test('8. Revathi (27) -> 6-month Adaippu', () {
      final r = DhanishtaCalculator.calculateFromIndices(
        nakshatraNumber: 27,
        tithiNumber: 1,
      );
      expect(r.isAdaippuNakshatra, isTrue);
      expect(r.adaippuMonths, 6);
      expect(r.adaippuType, 'ஆறு மாத அடைப்பு');
    });

    test('9. Rohini (4) -> 4-month Adaippu', () {
      final r = DhanishtaCalculator.calculateFromIndices(
        nakshatraNumber: 4,
        tithiNumber: 1,
      );
      expect(r.isAdaippuNakshatra, isTrue);
      expect(r.adaippuMonths, 4);
      expect(r.adaippuType, 'நான்கு மாத அடைப்பு');
    });

    test('10. Karthigai (3) & Uthiram (12) -> 3-month Adaippu', () {
      final r3 = DhanishtaCalculator.calculateFromIndices(
        nakshatraNumber: 3,
        tithiNumber: 1,
      );
      expect(r3.isAdaippuNakshatra, isTrue);
      expect(r3.adaippuMonths, 3);
      expect(r3.adaippuType, 'மூன்று மாத அடைப்பு');

      final r12 = DhanishtaCalculator.calculateFromIndices(
        nakshatraNumber: 12,
        tithiNumber: 1,
      );
      expect(r12.isAdaippuNakshatra, isTrue);
      expect(r12.adaippuMonths, 3);
      expect(r12.adaippuType, 'மூன்று மாத அடைப்பு');
    });

    test('11. Mrigashiram (5), Chithirai (14), Punarpoosam (7), Visakam (16), Uthiradam (21) -> 2-month Adaippu', () {
      final nakshatras2M = [5, 14, 7, 16, 21];
      for (final n in nakshatras2M) {
        final r = DhanishtaCalculator.calculateFromIndices(
          nakshatraNumber: n,
          tithiNumber: 1,
        );
        expect(r.isAdaippuNakshatra, isTrue, reason: 'Nakshatra $n should be Adaippu');
        expect(r.adaippuMonths, 2, reason: 'Nakshatra $n should have 2 months');
        expect(r.adaippuType, 'இரண்டு மாத அடைப்பு');
      }
    });

    test('12. Other Nakshatras -> No Adaippu', () {
      final nonAdaippu = [1, 2, 6, 8, 9, 10, 11, 13, 15, 17, 18, 19, 20, 22];
      for (final n in nonAdaippu) {
        final r = DhanishtaCalculator.calculateFromIndices(
          nakshatraNumber: n,
          tithiNumber: 1,
        );
        expect(r.isAdaippuNakshatra, isFalse, reason: 'Nakshatra $n should NOT be Adaippu');
        expect(r.adaippuMonths, 0);
        expect(r.adaippuType, 'அடைப்பு இல்லை');
      }
    });

    test('13. Angular elongation and Tithi calculation from Sun/Moon longitudes', () {
      // Sun = 0°, Moon = 50° -> Elongation = 50° -> (50/12).floor() + 1 = 5 (Panchami, Shukla)
      // Moon = 300° -> Nakshatra: (300 / 13.333333).floor() + 1 = 23 (Avittam)
      final rLong = DhanishtaCalculator.calculateFromLongitudes(
        sunLongitude: 250.0,
        moonLongitude: 300.0, // Elongation = 50° -> Tithi 5
      );
      expect(rLong.nakshatraNumber, 23);
      expect(rLong.nakshatraTamil, 'அவிட்டம்');
      expect(rLong.tithiNumber, 5);
      expect(rLong.tithiTamil, 'பஞ்சமி');
      expect(rLong.isDhanishtaPanchami, isTrue);
      expect(rLong.isAdaippuNakshatra, isTrue);
      expect(rLong.adaippuMonths, 6);
    });

    test('14. DateTime calculate execution runs cleanly', () {
      final rDate = DhanishtaCalculator.calculate(DateTime(2025, 5, 20, 10, 30));
      expect(rDate.nakshatraNumber, inInclusiveRange(1, 27));
      expect(rDate.tithiNumber, inInclusiveRange(1, 30));
      expect(rDate.nakshatraTamil, isNotEmpty);
      expect(rDate.tithiTamil, isNotEmpty);
      expect(rDate.explanation, isNotEmpty);
      expect(rDate.remedy, isNotEmpty);
    });

    group('Requirement Section 18 Test Cases', () {
      test('Test 1: Valid death date + time + location calculation verification', () {
        final deathDateTime = DateTime(2026, 9, 27, 13, 3);
        final r = DhanishtaPanchamiEngine.calculate(
          dateTime: deathDateTime,
          place: 'Chennai',
          latitude: 13.0827,
          longitude: 80.2707,
        );

        expect(r.sunLongitude, isNotNull);
        expect(r.moonLongitude, isNotNull);
        expect(r.nakshatra, isNotEmpty);
        expect(r.nakshatraNumber, inInclusiveRange(1, 27));
        expect(r.pada, inInclusiveRange(1, 4));
        expect(r.tithi, isNotEmpty);
        expect(r.tithiNumber, inInclusiveRange(1, 30));
        expect(r.isPanchaka, isA<bool>());
        expect(r.isAdaippu, isA<bool>());
        expect(r.closureMonths, inInclusiveRange(0, 6));
        if (r.closureMonths > 0) {
          expect(r.closureEndDate, isNotNull);
          expect(r.closureEndDate!.isAfter(deathDateTime), isTrue);
        }
      });

      test('Test 2: Each of the 13 configured Adaippu Nakshatras returns correct closure period', () {
        final expectedMonths = {
          23: 6, // Avittam
          24: 6, // Sathayam
          25: 6, // Poorattathi
          26: 6, // Uthirattathi
          27: 6, // Revathi
          4: 4,  // Rohini
          3: 3,  // Karthigai
          12: 3, // Uthiram
          5: 2,  // Mrigashiram
          7: 2,  // Punarpoosam
          14: 2, // Chithirai
          16: 2, // Visakam
          21: 2, // Uthiradam
        };

        expectedMonths.forEach((nakNum, expectedM) {
          final adaippu = DhanishtaPanchamiRules.getAdaippuData(nakNum);
          expect(adaippu.months, equals(expectedM), reason: 'Nakshatra $nakNum closure months mismatch');
          expect(adaippu.type, contains('மாத அடைப்பு'));

          final result = DhanishtaPanchamiEngine.calculateFromIndices(
            nakshatraNumber: nakNum,
            tithiNumber: 1,
          );
          expect(result.isAdaippu, isTrue);
          expect(result.closureMonths, equals(expectedM));
        });
      });

      test('Test 3: Nakshatras outside the 13 configured stars return அடைப்பு இல்லை', () {
        final nonAdaippuStars = [1, 2, 6, 8, 9, 10, 11, 13, 15, 17, 18, 19, 20, 22];
        for (final nakNum in nonAdaippuStars) {
          final adaippu = DhanishtaPanchamiRules.getAdaippuData(nakNum);
          expect(adaippu.months, equals(0));
          expect(adaippu.type, equals('அடைப்பு இல்லை'));

          final result = DhanishtaPanchamiEngine.calculateFromIndices(
            nakshatraNumber: nakNum,
            tithiNumber: 1,
          );
          expect(result.isAdaippu, isFalse);
          expect(result.closureMonths, equals(0));
          expect(result.closureEndDate, isNull);
          if (!result.isPanchaka) {
            expect(result.statusTamil, equals('அடைப்பு இல்லை'));
          }
        }
      });

      test('Test 4: Boundary testing before and after Nakshatra and Pada boundaries', () {
        // Ashwini ends at 13°20' = 13.3333333°
        // Just before boundary: 13.32° -> Ashwini Pada 4
        final beforeAshwiniEnd = DhanishtaPanchamiEngine.calculateFromLongitudes(
          sunLongitude: 0.0,
          moonLongitude: 13.32,
        );
        expect(beforeAshwiniEnd.nakshatraNumber, equals(1));
        expect(beforeAshwiniEnd.pada, equals(4));

        // Just after boundary: 13.35° -> Bharani Pada 1
        final afterAshwiniEnd = DhanishtaPanchamiEngine.calculateFromLongitudes(
          sunLongitude: 0.0,
          moonLongitude: 13.35,
        );
        expect(afterAshwiniEnd.nakshatraNumber, equals(2));
        expect(afterAshwiniEnd.pada, equals(1));

        // Avittam (23) starts at 293°20' = 293.333333°
        // Just before Avittam: 293.30° -> Thiruvonam (22) Pada 4
        final beforeAvittam = DhanishtaPanchamiEngine.calculateFromLongitudes(
          sunLongitude: 0.0,
          moonLongitude: 293.30,
        );
        expect(beforeAvittam.nakshatraNumber, equals(22));
        expect(beforeAvittam.isPanchaka, isFalse);
        expect(beforeAvittam.isAdaippu, isFalse);

        // Just after Avittam start: 293.35° -> Avittam (23) Pada 1
        final afterAvittamStart = DhanishtaPanchamiEngine.calculateFromLongitudes(
          sunLongitude: 0.0,
          moonLongitude: 293.35,
        );
        expect(afterAvittamStart.nakshatraNumber, equals(23));
        expect(afterAvittamStart.isPanchaka, isTrue);
        expect(afterAvittamStart.isAdaippu, isTrue);
        expect(afterAvittamStart.closureMonths, equals(6));
      });

      test('Test 5: Month-end dates arithmetic safety and valid calendar dates', () {
        // 1. 31 Jan 2026 + 1 month -> 28 Feb 2026 (non-leap)
        final jan31 = DateTime(2026, 1, 31, 12, 0);
        final end1 = DhanishtaPanchamiRules.calculateClosureEndDate(jan31, 1);
        expect(end1, equals(DateTime(2026, 2, 28, 12, 0)));

        // 2. 31 Jan 2024 + 1 month -> 29 Feb 2024 (leap year)
        final jan31Leap = DateTime(2024, 1, 31, 12, 0);
        final endLeap = DhanishtaPanchamiRules.calculateClosureEndDate(jan31Leap, 1);
        expect(endLeap, equals(DateTime(2024, 2, 29, 12, 0)));

        // 3. 31 March 2026 + 1 month -> 30 April 2026
        final mar31 = DateTime(2026, 3, 31, 12, 0);
        final end30Apr = DhanishtaPanchamiRules.calculateClosureEndDate(mar31, 1);
        expect(end30Apr, equals(DateTime(2026, 4, 30, 12, 0)));

        // 4. 31 May 2026 + 1 month -> 30 June 2026
        final may31 = DateTime(2026, 5, 31, 12, 0);
        final end30Jun = DhanishtaPanchamiRules.calculateClosureEndDate(may31, 1);
        expect(end30Jun, equals(DateTime(2026, 6, 30, 12, 0)));

        // 5. 15 Jan 2026 + 6 months -> 15 July 2026
        final jan15 = DateTime(2026, 1, 15, 12, 0);
        final end6M = DhanishtaPanchamiRules.calculateClosureEndDate(jan15, 6);
        expect(end6M, equals(DateTime(2026, 7, 15, 12, 0)));

        // 6. 27 Sept 2026 + 6 months -> 27 March 2027
        final sep27 = DateTime(2026, 9, 27, 13, 3);
        final endSep27 = DhanishtaPanchamiRules.calculateClosureEndDate(sep27, 6);
        expect(endSep27, equals(DateTime(2027, 3, 27, 13, 3)));
      });

      testWidgets('Widget Test: DhanishtaPanchamiTithiAdaippuModule renders and calculates successfully', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: DhanishtaPanchamiTithiAdaippuModule(),
          ),
        );
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.text('தனிஷ்டா பஞ்சமி / திதி அடைப்பு'), findsOneWidget);
        expect(find.text('தேதி & நேரம்'), findsOneWidget);
        expect(find.text('கணக்கிடுக'), findsOneWidget);
        expect(find.text('அடைப்பு / தனிஷ்டா பஞ்சமி நிலை'), findsOneWidget);
        expect(find.text('பஞ்சாங்க நிலை'), findsOneWidget);
        expect(find.text('தனிஷ்டா பஞ்சமி'), findsWidgets);
        expect(find.text('திதி அடைப்பு & முடிவு தேதி'), findsOneWidget);
        expect(find.text('பாரம்பரிய / சம்பிரதாய வழிமுறைகள்'), findsOneWidget);
        expect(find.textContaining('குடும்ப குலாசாரம்'), findsOneWidget);
      });
    });
  });
}
