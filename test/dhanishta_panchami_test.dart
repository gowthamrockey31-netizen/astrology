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
  });
}
