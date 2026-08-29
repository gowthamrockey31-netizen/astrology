import 'package:flutter_test/flutter_test.dart';
import 'package:astrocall/services/numerology_calculator.dart';
import 'package:astrocall/models/numerology_model.dart';

void main() {
  group('Enhanced Numerology / எண்கணிதம் Comprehensive Unit Tests', () {
    test('TEST 1: Birth Number calculation for various days (1, 9, 10, 11, 19, 24, 29, 31)', () {
      // 1 -> 1
      final res1 = NumerologyCalculator.calculate(
        birthDate: DateTime(2000, 1, 1),
        name: 'TEST',
      );
      expect(res1.birthNumber, 1);
      expect(res1.birthCompoundNumber, 1);

      // 9 -> 9
      final res9 = NumerologyCalculator.calculate(
        birthDate: DateTime(2000, 1, 9),
        name: 'TEST',
      );
      expect(res9.birthNumber, 9);
      expect(res9.birthCompoundNumber, 9);

      // 10 -> 1+0 = 1
      final res10 = NumerologyCalculator.calculate(
        birthDate: DateTime(2000, 1, 10),
        name: 'TEST',
      );
      expect(res10.birthNumber, 1);
      expect(res10.birthCompoundNumber, 10);

      // 11 -> 1+1 = 2
      final res11 = NumerologyCalculator.calculate(
        birthDate: DateTime(2000, 1, 11),
        name: 'TEST',
      );
      expect(res11.birthNumber, 2);
      expect(res11.birthCompoundNumber, 11);

      // 19 -> 1+9 = 10 -> 1
      final res19 = NumerologyCalculator.calculate(
        birthDate: DateTime(2000, 1, 19),
        name: 'TEST',
      );
      expect(res19.birthNumber, 1);
      expect(res19.birthCompoundNumber, 19);

      // 24 -> 2+4 = 6
      final res24 = NumerologyCalculator.calculate(
        birthDate: DateTime(2000, 1, 24),
        name: 'TEST',
      );
      expect(res24.birthNumber, 6);
      expect(res24.birthCompoundNumber, 24);

      // 29 -> 2+9 = 11 -> 2
      final res29 = NumerologyCalculator.calculate(
        birthDate: DateTime(2000, 1, 29),
        name: 'TEST',
      );
      expect(res29.birthNumber, 2);
      expect(res29.birthCompoundNumber, 29);

      // 31 -> 3+1 = 4
      final res31 = NumerologyCalculator.calculate(
        birthDate: DateTime(2000, 1, 31),
        name: 'TEST',
      );
      expect(res31.birthNumber, 4);
      expect(res31.birthCompoundNumber, 31);
    });

    test('TEST 2: Life Path Number calculation & compound preservation', () {
      // 15-06-1996 -> 15+6+1996 = 2017 -> 2+0+1+7 = 10 -> 1+0 = 1
      final res = NumerologyCalculator.calculate(
        birthDate: DateTime(1996, 6, 15),
        name: 'GOWTHAM',
        system: NumerologySystem.chaldean,
      );
      expect(res.lifePathNumber, 1);
      expect(res.lifePathCompoundNumber, inInclusiveRange(10, 2017));
    });

    test('TEST 3: Attitude Number calculation (Day + Month)', () {
      // 15-06 -> 15 + 6 = 21 -> 2+1 = 3
      final res = NumerologyCalculator.calculate(
        birthDate: DateTime(1996, 6, 15),
        name: 'GOWTHAM',
      );
      expect(res.attitudeNumber, 3);
    });

    test('TEST 4: Name Number, Letter Breakdown & System Mapping', () {
      // GOWTHAM under Chaldean:
      // G=3, O=7, W=6, T=4, H=5, A=1, M=4 -> Total = 30 -> 3
      final chaldeanRes = NumerologyCalculator.calculate(
        birthDate: DateTime(1996, 6, 15),
        name: 'Gowtham',
        system: NumerologySystem.chaldean,
      );
      expect(chaldeanRes.letterBreakdown.length, 7);
      expect(chaldeanRes.nameCompoundNumber, 30);
      expect(chaldeanRes.nameNumber, 3);

      // GOWTHAM under Pythagorean:
      // G=7, O=6, W=5, T=2, H=8, A=1, M=4 -> Total = 33 -> 6 (or 33)
      final pythRes = NumerologyCalculator.calculate(
        birthDate: DateTime(1996, 6, 15),
        name: 'GOWTHAM',
        system: NumerologySystem.pythagorean,
      );
      expect(pythRes.nameCompoundNumber, 33);
      expect(pythRes.nameNumber, 6);
    });

    test('TEST 5: Personal Cycles (Year, Month, Day)', () {
      final cycles = NumerologyCalculator.calculatePersonalCycles(
        birthDate: DateTime(1996, 6, 15),
        targetYear: 2026,
        targetMonth: 8,
        targetDay: 27,
      );

      // Personal Year = 15 + 6 + 2026 = 2047 -> 2+0+4+7 = 13 -> 1+3 = 4
      expect(cycles.personalYear.reducedValue, 4);

      // Personal Month = 4 + 8 = 12 -> 1+2 = 3
      expect(cycles.personalMonth.reducedValue, 3);

      // Personal Day = 3 + 27 = 30 -> 3+0 = 3
      expect(cycles.personalDay.reducedValue, 3);

      expect(cycles.personalYearDescriptionTa.isNotEmpty, true);
      expect(cycles.personalMonthDescriptionTa.isNotEmpty, true);
      expect(cycles.personalDayDescriptionTa.isNotEmpty, true);
    });

    test('TEST 6: Centralized Number Reducer and Master Number support', () {
      final r1 = NumerologyCalculator.reduceNumber(24);
      expect(r1.compoundValue, 24);
      expect(r1.reducedValue, 6);
      expect(r1.isMasterNumber, false);

      final r2 = NumerologyCalculator.reduceNumber(11, preserveMasterNumbers: true);
      expect(r2.reducedValue, 11);
      expect(r2.isMasterNumber, true);

      final r3 = NumerologyCalculator.reduceNumber(11, preserveMasterNumbers: false);
      expect(r3.reducedValue, 2);
      expect(r3.isMasterNumber, false);
    });

    test('TEST 7: Compound Number Dictionary Details', () {
      final detail24 = NumerologyCalculator.getCompoundDetail(24, 6);
      expect(detail24.number, 24);
      expect(detail24.reducedNumber, 6);
      expect(detail24.titleTa.contains('அன்பும் செல்வமும்'), true);

      final detail19 = NumerologyCalculator.getCompoundDetail(19, 1);
      expect(detail19.titleTa.contains('இளவரசன்'), true);
    });

    test('TEST 8: Compatibility & Lucky Attributes', () {
      final res = NumerologyCalculator.calculate(
        birthDate: DateTime(1996, 6, 15), // Birth Number 6
        name: 'GOWTHAM',
      );

      expect(res.friendlyNumbers, contains(6));
      expect(res.enemyNumbers, contains(1));
      expect(res.luckyDates.isNotEmpty, true);
      expect(res.luckyColorsTa.isNotEmpty, true);
      expect(res.luckyGemsTa.isNotEmpty, true);
      expect(res.careerGuidanceTa.isNotEmpty, true);
    });
  });
}
