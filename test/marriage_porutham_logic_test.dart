import 'package:flutter_test/flutter_test.dart';
import 'package:astrocall/models/porutham_model.dart';
import 'package:astrocall/services/astrology_calculator.dart';
import 'package:astrocall/services/porutham_calculator.dart';

void main() {
  group('Marriage Matching Logic Update Tests', () {
    // -------------------------------------------------------------------------
    // PART 1: RASI PORUTHAM (Updated with 8-Rule Corrections)
    // -------------------------------------------------------------------------
    group('Part 1: Rasi Porutham', () {
      const rejectedPositions = {2, 3, 4, 5, 6, 8};
      const matchedPositions = {1, 7, 9, 10, 11, 12};

      test('Rejection positions 2, 3, 4, 5, 6, 8 return NOT MATCHED', () {
        for (final pos in rejectedPositions) {
          final maleRasi = (0 + pos - 1) % 12;
          final res = PoruthamCalculator.calculateRasiPorutham(0, maleRasi);
          expect(res.status, equals(PoruthamStatus.notMatched),
              reason: 'Position $pos should be NOT MATCHED');
        }
      });

      test('Favorable positions 1, 7, 9, 10, 11, 12 return MATCHED', () {
        for (final pos in matchedPositions) {
          final maleRasi = (0 + pos - 1) % 12;
          final res = PoruthamCalculator.calculateRasiPorutham(0, maleRasi);
          expect(res.status, equals(PoruthamStatus.matched),
              reason: 'Position $pos should be MATCHED');
        }
      });

      test('Complete 144 pairs distribution: exactly 72 matched, 72 not matched', () {
        int totalMatched = 0;
        int totalNotMatched = 0;
        for (int f = 0; f < 12; f++) {
          for (int m = 0; m < 12; m++) {
            final item = PoruthamCalculator.calculateRasiPorutham(f, m);
            if (item.status == PoruthamStatus.matched) {
              totalMatched++;
            } else {
              totalNotMatched++;
            }
          }
        }
        expect(totalMatched, equals(72));
        expect(totalNotMatched, equals(72));
        expect(totalMatched + totalNotMatched, equals(144));
      });
    });

    // -------------------------------------------------------------------------
    // PART 2: RASI ATHIPATHI PORUTHAM (Updated with 8-Rule Corrections)
    // -------------------------------------------------------------------------
    group('Part 2: Rasi Athipathi Porutham', () {
      test('Specified 23 Rasi-to-Rasi rejection combinations return NOT MATCHED', () {
        final rejections = [
          [0, 2], [0, 5],
          [1, 3], [1, 4],
          [2, 3],
          [4, 6], [4, 1], [4, 9], [4, 10],
          [8, 1], [8, 2], [8, 5], [8, 6],
          [11, 1], [11, 2], [11, 5], [11, 6],
          [9, 0], [9, 3], [9, 4],
          [10, 0], [10, 3], [10, 4],
        ];

        for (final pair in rejections) {
          final res = PoruthamCalculator.calculateRasiAthipathiPorutham(pair[0], pair[1]);
          expect(res.status, equals(PoruthamStatus.notMatched),
              reason: 'Pair Female ${pair[0]} x Male ${pair[1]} must be NOT MATCHED');
        }
      });

      test('Visakam rejection for Makaram (9) and Kumbam (10) returns NOT MATCHED', () {
        // Makaram (9) x Visakam (maleStar: 15)
        final resMakaram = PoruthamCalculator.calculateRasiAthipathiPorutham(9, 6, maleStar: 15);
        expect(resMakaram.status, equals(PoruthamStatus.notMatched));

        // Kumbam (10) x Visakam (maleStar: 15)
        final resKumbam = PoruthamCalculator.calculateRasiAthipathiPorutham(10, 6, maleStar: 15);
        expect(resKumbam.status, equals(PoruthamStatus.notMatched));
      });

      test('Non-rejected combinations return MATCHED (121 matched out of 144 Rasi pairs)', () {
        int totalMatched = 0;
        int totalNotMatched = 0;
        for (int f = 0; f < 12; f++) {
          for (int m = 0; m < 12; m++) {
            final item = PoruthamCalculator.calculateRasiAthipathiPorutham(f, m);
            if (item.status == PoruthamStatus.matched) {
              totalMatched++;
            } else {
              totalNotMatched++;
            }
          }
        }
        expect(totalNotMatched, equals(23));
        expect(totalMatched, equals(121));
        expect(totalMatched + totalNotMatched, equals(144));
      });
    });

    // -------------------------------------------------------------------------
    // PART 3: BHAVA SAMYAM DHOSHAM (PAGE 69 BENCHMARK & CALCULATION)
    // -------------------------------------------------------------------------
    group('Part 3: Bhava Samyam Dhosham', () {
      test('Page 69 Benchmark Example: Male Total = 4.5 (4 1/2), Female Total = 2.75 (2 3/4)', () {
        // Construct the exact Page 69 astrological configurations:
        // Male:
        // Lagna in Mesham (0): Sun in 1 (house 2), Rahu in 3 (house 4) -> 2 malefics * 1.0 = 2.0
        // Moon in Makaram (9): Ketu in 9 (h 1), Mars in 10 (h 2), Rahu in 3 (h 7), Saturn in 4 (h 8) -> 4 * 0.5 = 2.0
        // Venus in Mesham (0): Sun in 1 (h 2), Rahu in 3 (h 4) -> 2 * 0.25 = 0.5 (1/2)
        // Male Total = 4.5 (4 1/2)
        final maleMalefics = {
          'Sun': 1,
          'Mars': 10,
          'Saturn': 4,
          'Rahu': 3,
          'Ketu': 9,
        };

        // Female:
        // Lagna in Mesham (0): Mars in 1 (h 2), Saturn in 7 (h 8) -> 2 malefics * 1.0 = 2.0
        // Moon in Kumbam (10): Mars in 1 (h 4) -> 1 malefic * 0.5 = 0.5 (1/2)
        // Venus in Kumbam (10): Mars in 1 (h 4) -> 1 malefic * 0.25 = 0.25 (1/4)
        // Sun, Rahu, Ketu in houses outside 1, 2, 4, 7, 8, 12:
        // e.g. Sun in 2 (h 3/5), Rahu in 4 (h 5/7? no: h 5), Ketu in 10 (h 11/1)
        final femaleMalefics = {
          'Mars': 1,
          'Saturn': 7,
          'Sun': 2,
          'Rahu': 8,
          'Ketu': 2,
        };

        final samyam = BhavaSamyamCalculator.calculateFromRasiPositions(
          maleLagnaRasi: 0,
          maleMoonRasi: 9,
          maleVenusRasi: 0,
          maleMaleficRasis: maleMalefics,
          femaleLagnaRasi: 0,
          femaleMoonRasi: 10,
          femaleVenusRasi: 10,
          femaleMaleficRasis: femaleMalefics,
        );

        expect(samyam.hasDetailedData, isTrue);
        expect(samyam.maleChart, isNotNull);
        expect(samyam.femaleChart, isNotNull);

        // Verify Male Rows
        final mRows = samyam.maleChart!.rows;
        expect(mRows[0].refNameTa, equals('லக்னம்'));
        expect(mRows[0].rowAmount, equals(2.0));
        expect(mRows[0].rowAmountStr, equals('2'));
        expect(mRows[0].getOccupantsString(2), equals('சூ'));
        expect(mRows[0].getOccupantsString(4), equals('ரா'));

        expect(mRows[1].refNameTa, equals('சந்திரன்'));
        expect(mRows[1].rowAmount, equals(2.0));
        expect(mRows[1].rowAmountStr, equals('2'));
        expect(mRows[1].getOccupantsString(1), equals('கே'));
        expect(mRows[1].getOccupantsString(2), equals('செ'));
        expect(mRows[1].getOccupantsString(7), equals('ரா'));
        expect(mRows[1].getOccupantsString(8), equals('சனி'));

        expect(mRows[2].refNameTa, equals('சுக்கிரன்'));
        expect(mRows[2].rowAmount, equals(0.5));
        expect(mRows[2].rowAmountStr, equals('1/2'));

        // Verify Male Total
        expect(samyam.maleChart!.totalAmount, equals(4.5));
        expect(samyam.maleChart!.totalAmountStr, equals('4 1/2'));

        // Verify Female Rows
        final fRows = samyam.femaleChart!.rows;
        expect(fRows[0].refNameTa, equals('லக்னம்'));
        expect(fRows[0].rowAmount, equals(2.0));
        expect(fRows[0].rowAmountStr, equals('2'));
        expect(fRows[0].getOccupantsString(2), equals('செ'));
        expect(fRows[0].getOccupantsString(8), equals('சனி'));

        expect(fRows[1].refNameTa, equals('சந்திரன்'));
        expect(fRows[1].rowAmount, equals(0.5));
        expect(fRows[1].rowAmountStr, equals('1/2'));
        expect(fRows[1].getOccupantsString(4), equals('செ'));

        expect(fRows[2].refNameTa, equals('சுக்கிரன்'));
        expect(fRows[2].rowAmount, equals(0.25));
        expect(fRows[2].rowAmountStr, equals('1/4'));
        expect(fRows[2].getOccupantsString(4), equals('செ'));

        // Verify Female Total
        expect(samyam.femaleChart!.totalAmount, equals(2.75));
        expect(samyam.femaleChart!.totalAmountStr, equals('2 3/4'));

        // Verify Difference & Comparison
        expect(samyam.difference, equals(1.75));
        expect(samyam.differenceStr, equals('1 3/4'));
        expect(samyam.status, equals(PoruthamStatus.matched));
        expect(samyam.isMatched, isTrue);
        expect(samyam.comparisonConclusionTa, contains('ஆணுக்கு பெண்ணைவிட பாவதோச அளவு அதிகமாக உள்ளதால் ஜாதகங்கள் பொருந்தும்'));
      });

      test('Dynamic Calculation with Real Horoscopes updates when horoscope changes', () {
        final maleData1 = AstrologyCalculator.calculateHoroscope(
          dateOfBirth: DateTime(1996, 6, 15, 8, 30),
          latitude: 13.0827,
          longitude: 80.2707,
          utcOffsetHours: 5.5,
        );

        final femaleData1 = AstrologyCalculator.calculateHoroscope(
          dateOfBirth: DateTime(1998, 11, 20, 14, 15),
          latitude: 9.9252,
          longitude: 78.1198,
          utcOffsetHours: 5.5,
        );

        final samyam1 = BhavaSamyamCalculator.calculate(
          maleAstroData: maleData1,
          femaleAstroData: femaleData1,
        );

        expect(samyam1.hasDetailedData, isTrue);
        expect(samyam1.maleChart, isNotNull);
        expect(samyam1.femaleChart, isNotNull);
        expect(samyam1.maleChart!.rows.length, equals(3));
        expect(samyam1.femaleChart!.rows.length, equals(3));
        expect(samyam1.maleChart!.totalAmount, greaterThanOrEqualTo(0.0));
        expect(samyam1.femaleChart!.totalAmount, greaterThanOrEqualTo(0.0));

        // Change female to a completely different birth date & time
        final femaleData2 = AstrologyCalculator.calculateHoroscope(
          dateOfBirth: DateTime(1992, 3, 5, 22, 10),
          latitude: 11.0168,
          longitude: 76.9558,
          utcOffsetHours: 5.5,
        );

        final samyam2 = BhavaSamyamCalculator.calculate(
          maleAstroData: maleData1,
          femaleAstroData: femaleData2,
        );

        expect(samyam2.femaleChart!.totalAmount, isNot(equals(samyam1.femaleChart!.totalAmount)));
      });

      test('Bhava Samyam does NOT alter 11 Poruthams score or total count', () {
        final maleData = AstrologyCalculator.calculateHoroscope(
          dateOfBirth: DateTime(1996, 6, 15, 8, 30),
          latitude: 13.0827,
          longitude: 80.2707,
          utcOffsetHours: 5.5,
        );

        final femaleData = AstrologyCalculator.calculateHoroscope(
          dateOfBirth: DateTime(1998, 11, 20, 14, 15),
          latitude: 9.9252,
          longitude: 78.1198,
          utcOffsetHours: 5.5,
        );

        final result = PoruthamCalculator.calculatePorutham(
          maleStarIndex: maleData.moon.nakshatraIndex,
          malePada: maleData.moon.pada,
          maleRasiIndex: maleData.moon.rasiIndex,
          femaleStarIndex: femaleData.moon.nakshatraIndex,
          femalePada: femaleData.moon.pada,
          femaleRasiIndex: femaleData.moon.rasiIndex,
          maleAstroData: maleData,
          femaleAstroData: femaleData,
        );

        expect(result.totalCount, equals(11));
        expect(result.items.length, equals(11));
        expect(result.scoreText, equals('${result.matchedCount} / 11'));
        expect(result.bhavaSamyam.hasDetailedData, isTrue);
      });
    });

    // -------------------------------------------------------------------------
    // ALL 11 PORUTHAMS INTACT
    // -------------------------------------------------------------------------
    group('Overall 11 Poruthams System Integrity', () {
      test('All 11 Porutham IDs are present and intact', () {
        final result = PoruthamCalculator.calculatePorutham(
          maleStarIndex: 0,
          malePada: 1,
          maleRasiIndex: 0,
          femaleStarIndex: 0,
          femalePada: 1,
          femaleRasiIndex: 0,
        );

        final ids = result.items.map((i) => i.id).toList();
        expect(ids, equals([
          'dina',
          'gana',
          'mahendra',
          'sthree_deergha',
          'yoni',
          'rasi',
          'rasi_athipathi',
          'vasya',
          'rajju',
          'vedha',
          'nadi',
        ]));
      });
    });
  });
}
