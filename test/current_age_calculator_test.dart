import 'package:flutter_test/flutter_test.dart';
import 'package:astrocall/modules/horoscope/current_age_calculator.dart';

void main() {
  group('CurrentAgeCalculator Unit Tests', () {
    test('1. Calculates exact age for user specification example (15-03-1990 to 04-09-2026)', () {
      final birth = DateTime(1990, 3, 15, 10, 30);
      final asOf = DateTime(2026, 9, 4, 12, 00);

      final result = CurrentAgeCalculator.calculate(
        birthDateTime: birth,
        asOfDateTime: asOf,
      );

      expect(result.years, 36);
      expect(result.months, 5);
      expect(result.days, 20);
      expect(result.tamilText, '36 வருடம் 5 மாதம் 20 நாள்');
      expect(result.englishText, '36 Years 5 Months 20 Days');
    });

    test('2. Accurately handles Birthday Today (time already passed)', () {
      final birth = DateTime(1995, 9, 4, 10, 00);
      final asOf = DateTime(2026, 9, 4, 15, 30); // 3:30 PM (after 10:00 AM)

      final result = CurrentAgeCalculator.calculate(
        birthDateTime: birth,
        asOfDateTime: asOf,
      );

      expect(result.years, 31);
      expect(result.months, 0);
      expect(result.days, 0);
      expect(result.tamilText, '31 வருடம் 0 மாதம் 0 நாள்');
    });

    test('3. Accurately handles Birthday Today (birth time later in the day)', () {
      final birth = DateTime(1995, 9, 4, 18, 00); // 6:00 PM
      final asOf = DateTime(2026, 9, 4, 10, 00); // 10:00 AM (has not reached 6:00 PM yet)

      final result = CurrentAgeCalculator.calculate(
        birthDateTime: birth,
        asOfDateTime: asOf,
      );

      expect(result.years, 30);
      expect(result.months, 11);
      expect(result.days, 30); // August has 31 days
    });

    test('4. Accurately handles leap year birth (Feb 29) on non-leap year Feb 28 vs March 1', () {
      final birth = DateTime(2004, 2, 29, 12, 0);

      // On Feb 28 of non-leap year 2025
      final asOfFeb28 = DateTime(2025, 2, 28, 12, 0);
      final resFeb28 = CurrentAgeCalculator.calculate(
        birthDateTime: birth,
        asOfDateTime: asOfFeb28,
      );
      expect(resFeb28.years, 20);
      expect(resFeb28.months, 11);
      expect(resFeb28.days, 30);

      // On March 1 of non-leap year 2025
      final asOfMar1 = DateTime(2025, 3, 1, 12, 0);
      final resMar1 = CurrentAgeCalculator.calculate(
        birthDateTime: birth,
        asOfDateTime: asOfMar1,
      );
      expect(resMar1.years, 21);
      expect(resMar1.months, 0);
      expect(resMar1.days, 0);
    });

    test('5. Accurately handles baby born within the past few months/days', () {
      final birth = DateTime(2026, 8, 20, 9, 0);
      final asOf = DateTime(2026, 9, 4, 10, 0);

      final result = CurrentAgeCalculator.calculate(
        birthDateTime: birth,
        asOfDateTime: asOf,
      );

      expect(result.years, 0);
      expect(result.months, 0);
      expect(result.days, 15);
      expect(result.tamilText, '0 வருடம் 0 மாதம் 15 நாள்');
      expect(result.englishText, '0 Years 0 Months 15 Days');
    });

    test('6. Throws ArgumentError if birthDateTime is in the future', () {
      final futureBirth = DateTime(2030, 1, 1);
      final asOf = DateTime(2026, 9, 4);

      expect(
        () => CurrentAgeCalculator.calculate(
          birthDateTime: futureBirth,
          asOfDateTime: asOf,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
