import 'package:flutter_test/flutter_test.dart';
import 'package:astrocall/services/porutham_calculator.dart';
import 'package:astrocall/models/porutham_model.dart';

void main() {
  group('AstroDashaCare – Marriage Matching: Eight Porutham Corrections Tests', () {

    // =========================================================================
    // 1. DINA PORUTHAM
    // =========================================================================
    group('1. Dina Porutham', () {
      test('17th position returns NOT MATCHED', () {
        // Female Ashwini (0), Male Jyeshtha (16) -> count = 17
        final res = PoruthamCalculator.calculateDinaPorutham(0, 16);
        expect(res.status, equals(PoruthamStatus.notMatched));
        expect(res.isMatched, isFalse);
        expect(res.metricInfoTa, contains('17'));
      });

      test('22nd position returns NOT MATCHED', () {
        // Female Ashwini (0), Male Shravana (21) -> count = 22
        final res = PoruthamCalculator.calculateDinaPorutham(0, 21);
        expect(res.status, equals(PoruthamStatus.notMatched));
        expect(res.isMatched, isFalse);
        expect(res.metricInfoTa, contains('22'));
      });

      test('Favorable positions outside 17 and 22 return MATCHED', () {
        // Count 2: Ashwini (0) -> Bharani (1)
        expect(PoruthamCalculator.calculateDinaPorutham(0, 1).isMatched, isTrue);
        // Count 4: Ashwini (0) -> Rohini (3)
        expect(PoruthamCalculator.calculateDinaPorutham(0, 3).isMatched, isTrue);
        // Count 6: Ashwini (0) -> Ardra (5)
        expect(PoruthamCalculator.calculateDinaPorutham(0, 5).isMatched, isTrue);
        // Count 8: Ashwini (0) -> Pushya (7)
        expect(PoruthamCalculator.calculateDinaPorutham(0, 7).isMatched, isTrue);
        // Count 9: Ashwini (0) -> Ashlesha (8)
        expect(PoruthamCalculator.calculateDinaPorutham(0, 8).isMatched, isTrue);
      });

      test('Unfavorable positions return NOT MATCHED', () {
        // Count 1 (Janma): Ashwini (0) -> Ashwini (0)
        expect(PoruthamCalculator.calculateDinaPorutham(0, 0).isMatched, isFalse);
        // Count 3 (Vipat): Ashwini (0) -> Krittika (2)
        expect(PoruthamCalculator.calculateDinaPorutham(0, 2).isMatched, isFalse);
        // Count 5 (Pratyak): Ashwini (0) -> Mrigashira (4)
        expect(PoruthamCalculator.calculateDinaPorutham(0, 4).isMatched, isFalse);
        // Count 7 (Naidhana): Ashwini (0) -> Punarvasu (6)
        expect(PoruthamCalculator.calculateDinaPorutham(0, 6).isMatched, isFalse);
      });
    });

    // =========================================================================
    // 2. GANA PORUTHAM
    // =========================================================================
    group('2. Gana Porutham', () {
      test('Positions 14 through 27 return MATCHED under special exception', () {
        // Test all positions 14..27 starting from Ashwini (0, Deva) and Magha (9, Rakshasa)
        for (int count = 14; count <= 27; count++) {
          final maleStar = (9 + count - 1) % 27;
          final res = PoruthamCalculator.calculateGanaPorutham(9, maleStar);
          expect(res.status, equals(PoruthamStatus.matched),
              reason: 'Position $count should match under exception');
          expect(res.descriptionTa, contains('சிறப்பு விதிவிலக்கு'));
        }
      });

      test('Positions below 14 preserve existing Gana Porutham rules', () {
        // Female Deva (Ashwini 0) + Male Deva (Mrigashira 4, count 5) -> MATCHED
        expect(PoruthamCalculator.calculateGanaPorutham(0, 4).isMatched, isTrue);

        // Female Rakshasa (Ashlesha 8) + Male Deva (Ashwini 0, count 19) -> MATCHED via exception (> 14)
        expect(PoruthamCalculator.calculateGanaPorutham(8, 0).isMatched, isTrue);

        // Female Rakshasa (Magha 9) + Male Deva (Hasta 12, count 4 < 14) -> NOT MATCHED
        expect(PoruthamCalculator.calculateGanaPorutham(9, 12).isMatched, isFalse);
      });
    });

    // =========================================================================
    // 3. MAHENDRA PORUTHAM
    // =========================================================================
    group('3. Mahendra Porutham', () {
      test('Position 1 returns MATCHED under new condition', () {
        // Ashwini (0) to Ashwini (0) -> count = 1
        final res = PoruthamCalculator.calculateMahendraPorutham(0, 0);
        expect(res.status, equals(PoruthamStatus.matched));
        expect(res.isMatched, isTrue);
      });

      test('All matched positions (1, 4, 7, 10, 13, 16, 19, 22, 25) return MATCHED', () {
        const matchedCounts = {1, 4, 7, 10, 13, 16, 19, 22, 25};
        for (int count = 1; count <= 27; count++) {
          final maleStar = (count - 1) % 27;
          final res = PoruthamCalculator.calculateMahendraPorutham(0, maleStar);
          if (matchedCounts.contains(count)) {
            expect(res.isMatched, isTrue, reason: 'Count $count should match Mahendra');
          } else {
            expect(res.isMatched, isFalse, reason: 'Count $count should NOT match Mahendra');
          }
        }
      });
    });

    // =========================================================================
    // 4. STHREE DEERGAM
    // =========================================================================
    group('4. Sthree Deergham', () {
      test('Positions 8 through 27 (count > 7) return MATCHED', () {
        for (int count = 8; count <= 27; count++) {
          final maleStar = (count - 1) % 27;
          final res = PoruthamCalculator.calculateSthreeDeerghaPorutham(0, maleStar);
          expect(res.status, equals(PoruthamStatus.matched),
              reason: 'Count $count must match Sthree Deergham');
        }
      });

      test('Positions 1 through 7 (count <= 7) return NOT MATCHED', () {
        for (int count = 1; count <= 7; count++) {
          final maleStar = (count - 1) % 27;
          final res = PoruthamCalculator.calculateSthreeDeerghaPorutham(0, maleStar);
          expect(res.status, equals(PoruthamStatus.notMatched),
              reason: 'Count $count must NOT match Sthree Deergham');
        }
      });
    });

    // =========================================================================
    // 5. YONI PORUTHAM
    // =========================================================================
    group('5. Yoni Porutham', () {
      test('All five specified combinations return NOT MATCHED in both orders', () {
        // 1. Uthiradam (20) x Visakam (15)
        expect(PoruthamCalculator.calculateYoniPorutham(20, 15).isMatched, isFalse);
        expect(PoruthamCalculator.calculateYoniPorutham(15, 20).isMatched, isFalse);

        // 2. Rohini (3) x Magam (9)
        expect(PoruthamCalculator.calculateYoniPorutham(3, 9).isMatched, isFalse);
        expect(PoruthamCalculator.calculateYoniPorutham(9, 3).isMatched, isFalse);

        // 3. Rohini (3) x Pooram (10)
        expect(PoruthamCalculator.calculateYoniPorutham(3, 10).isMatched, isFalse);
        expect(PoruthamCalculator.calculateYoniPorutham(10, 3).isMatched, isFalse);

        // 4. Mirugaseerisham (4) x Magam (9)
        expect(PoruthamCalculator.calculateYoniPorutham(4, 9).isMatched, isFalse);
        expect(PoruthamCalculator.calculateYoniPorutham(9, 4).isMatched, isFalse);

        // 5. Mirugaseerisham (4) x Pooram (10)
        expect(PoruthamCalculator.calculateYoniPorutham(4, 10).isMatched, isFalse);
        expect(PoruthamCalculator.calculateYoniPorutham(10, 4).isMatched, isFalse);
      });

      test('Other non-enemy Yoni combinations return MATCHED', () {
        // Same Yoni: Ashwini (0) x Shatabhisha (23) -> Horse x Horse
        expect(PoruthamCalculator.calculateYoniPorutham(0, 23).isMatched, isTrue);

        // Friendly Yoni: Ashwini (0) x Krittika (2) -> Horse x Goat
        expect(PoruthamCalculator.calculateYoniPorutham(0, 2).isMatched, isTrue);
      });

      test('Classical enemy Yoni combinations return NOT MATCHED', () {
        // Horse (0) x Buffalo (12 Hasta)
        expect(PoruthamCalculator.calculateYoniPorutham(0, 12).isMatched, isFalse);
      });
    });

    // =========================================================================
    // 6. RASI PORUTHAM
    // =========================================================================
    group('6. Rasi Porutham', () {
      test('NOT MATCHED positions: 2, 3, 4, 5, 6, 8', () {
        const rejectedCounts = {2, 3, 4, 5, 6, 8};
        for (final count in rejectedCounts) {
          final maleRasi = (0 + count - 1) % 12; // Female = Mesham (0)
          final res = PoruthamCalculator.calculateRasiPorutham(0, maleRasi);
          expect(res.status, equals(PoruthamStatus.notMatched),
              reason: 'Position $count must be rejected');
        }
      });

      test('MATCHED positions: 1, 7, 9, 10, 11, 12', () {
        const matchedCounts = {1, 7, 9, 10, 11, 12};
        for (final count in matchedCounts) {
          final maleRasi = (0 + count - 1) % 12; // Female = Mesham (0)
          final res = PoruthamCalculator.calculateRasiPorutham(0, maleRasi);
          expect(res.status, equals(PoruthamStatus.matched),
              reason: 'Position $count must match');
        }
      });
    });

    // =========================================================================
    // 7. RASI ATHIPATHI PORUTHAM
    // =========================================================================
    group('7. Rasi Athipathi Porutham', () {
      test('All 25 specified combinations return NOT MATCHED', () {
        final rejections = [
          (0, 2, 'Mesham x Mithunam'),
          (0, 5, 'Mesham x Kanni'),
          (1, 3, 'Rishabam x Kadagam'),
          (1, 4, 'Rishabam x Simham'),
          (2, 3, 'Mithunam x Kadagam'),
          (4, 6, 'Simham x Thulam'),
          (4, 1, 'Simham x Rishabam'),
          (4, 9, 'Simham x Makaram'),
          (4, 10, 'Simham x Kumbam'),
          (8, 1, 'Dhanusu x Rishabam'),
          (8, 2, 'Dhanusu x Mithunam'),
          (8, 5, 'Dhanusu x Kanni'),
          (8, 6, 'Dhanusu x Thulam'),
          (11, 1, 'Meenam x Rishabam'),
          (11, 2, 'Meenam x Mithunam'),
          (11, 5, 'Meenam x Kanni'),
          (11, 6, 'Meenam x Thulam'),
          (9, 0, 'Makaram x Mesham'),
          (9, 3, 'Makaram x Kadagam'),
          (9, 4, 'Makaram x Simham'),
          (10, 0, 'Kumbam x Mesham'),
          (10, 3, 'Kumbam x Kadagam'),
          (10, 4, 'Kumbam x Simham'),
        ];

        for (final item in rejections) {
          final res = PoruthamCalculator.calculateRasiAthipathiPorutham(item.$1, item.$2);
          expect(res.status, equals(PoruthamStatus.notMatched),
              reason: '${item.$3} must be rejected');
        }

        // Test the two flagged combinations with Visakam (Nakshatra 15):
        // 21. Makaram (9) x Visakam
        final resMakaramVisakam = PoruthamCalculator.calculateRasiAthipathiPorutham(9, 6, maleStar: 15);
        expect(resMakaramVisakam.status, equals(PoruthamStatus.notMatched),
            reason: 'Makaram x Visakam must be rejected');

        // 25. Kumbam (10) x Visakam
        final resKumbamVisakam = PoruthamCalculator.calculateRasiAthipathiPorutham(10, 6, maleStar: 15);
        expect(resKumbamVisakam.status, equals(PoruthamStatus.notMatched),
            reason: 'Kumbam x Visakam must be rejected');

        // Test helper function with name string
        expect(PoruthamCalculator.isRasiAthipathiCombinationRejected(femaleRasi: 9, maleTarget: 'Visakam'), isTrue);
        expect(PoruthamCalculator.isRasiAthipathiCombinationRejected(femaleRasi: 10, maleTarget: 'Visakam'), isTrue);
      });

      test('Non-rejected combinations return MATCHED', () {
        // Mesham (0) x Simham (4)
        expect(PoruthamCalculator.calculateRasiAthipathiPorutham(0, 4).isMatched, isTrue);
        // Kadagam (3) x Meenam (11)
        expect(PoruthamCalculator.calculateRasiAthipathiPorutham(3, 11).isMatched, isTrue);
      });
    });

    // =========================================================================
    // 8. VASYA PORUTHAM
    // =========================================================================
    group('8. Vasya Porutham', () {
      test('All 15 specified directional combinations return MATCHED', () {
        final matchedPairs = [
          (0, 4, 'Mesham -> Simham'),
          (1, 3, 'Rishabam -> Kadagam'),
          (2, 5, 'Mithunam -> Kanni'),
          (3, 7, 'Kadagam -> Viruchigam'),
          (4, 6, 'Simham -> Thulam'),
          (5, 1, 'Kanni -> Rishabam'),
          (5, 11, 'Kanni -> Meenam'),
          (6, 9, 'Thulam -> Makaram'),
          (7, 3, 'Viruchigam -> Kadagam'),
          (7, 5, 'Viruchigam -> Kanni'),
          (8, 11, 'Dhanusu -> Meenam'),
          (9, 0, 'Makaram -> Mesham'),
          (9, 10, 'Makaram -> Kumbam'),
          (10, 11, 'Kumbam -> Meenam'),
          (11, 9, 'Meenam -> Makaram'),
        ];

        for (final item in matchedPairs) {
          final res = PoruthamCalculator.calculateVasyaPorutham(item.$1, item.$2);
          expect(res.status, equals(PoruthamStatus.matched),
              reason: '${item.$3} must be matched');
        }
      });

      test('Non-symmetric check: reverse directional pairs without Vasya return NOT MATCHED', () {
        // Mesham (0) -> Simham (4) is matched, but Simham (4) -> Mesham (0) is NOT Vasya
        expect(PoruthamCalculator.calculateVasyaPorutham(0, 4).isMatched, isTrue);
        expect(PoruthamCalculator.calculateVasyaPorutham(4, 0).isMatched, isFalse);

        // Mithunam (2) -> Kanni (5) is matched, but Kanni (5) -> Mithunam (2) is NOT in list
        expect(PoruthamCalculator.calculateVasyaPorutham(2, 5).isMatched, isTrue);
        expect(PoruthamCalculator.calculateVasyaPorutham(5, 2).isMatched, isFalse);
      });
    });

    // =========================================================================
    // 9. OVERALL CALCULATION INTEGRATION
    // =========================================================================
    test('calculatePorutham integrates all eight updated rules', () {
      final result = PoruthamCalculator.calculatePorutham(
        maleStarIndex: 0, // Ashwini
        malePada: 1,
        maleRasiIndex: 4, // Simham
        femaleStarIndex: 0, // Ashwini
        femalePada: 1,
        femaleRasiIndex: 0, // Mesham
      );

      expect(result.items.length, equals(11));
      // Mahendra: count = 1 -> MATCHED
      expect(result.items.firstWhere((i) => i.id == 'mahendra').isMatched, isTrue);
      // Sthree Deergham: count = 1 <= 7 -> NOT MATCHED
      expect(result.items.firstWhere((i) => i.id == 'sthree_deergha').isMatched, isFalse);
      // Vasya: Mesham (0) -> Simham (4) -> MATCHED
      expect(result.items.firstWhere((i) => i.id == 'vasya').isMatched, isTrue);

      // Verify each item has non-empty structured metadata tags
      for (final item in result.items) {
        expect(item.nameTa, isNotEmpty);
        expect(item.statusTextTa, isNotEmpty);
        expect(item.descriptionTa, isNotEmpty);
        expect(item.femaleInfoTa, isNotNull);
        expect(item.maleInfoTa, isNotNull);
      }
    });
  });
}
