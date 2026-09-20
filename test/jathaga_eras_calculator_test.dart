import 'package:flutter_test/flutter_test.dart';
import 'package:astrocall/services/jathaga_eras_calculator.dart';

void main() {
  group('JathagaErasCalculator Tests', () {
    test('Test 3: Standard Date calculation (21-08-2026 13:05)', () {
      final res = JathagaErasCalculator.calculateAllEras(
        day: 21,
        month: 8,
        year: 2026,
        hour: 13,
        minute: 5,
      );

      expect(res['gregorian_year'], 2026);
      expect(res['thiruvalluvar_year'], 2057); // 2026 + 31
      expect(res['salivahana_year'], 1948);    // 2026 - 78
      expect(res['kaliyugadhi_year'], 5127);   // 2026 + 3101
      expect(res['kollam_year'], 1202);        // 2026 - 824
      expect(res['fasli_year'], 1436);         // 2026 - 590 (Aug >= July 1)
      expect(res['hijri_year'], 1448);         // Astronomical Islamic lunar year for Aug 2026
      expect(res['formatted_date'], '21-08-2026');
      expect(res['formatted_time'], '13:05');
    });

    test('Test August 1995 (User verified case: Hijri 1416, Fasli 1405)', () {
      final res = JathagaErasCalculator.calculateAllEras(
        day: 10,
        month: 8,
        year: 1995,
        hour: 9,
        minute: 15,
      );

      expect(res['gregorian_year'], 1995);
      expect(res['thiruvalluvar_year'], 2026); // 1995 + 31
      expect(res['salivahana_year'], 1917);    // 1995 - 78
      expect(res['kaliyugadhi_year'], 5096);   // 1995 + 3101
      expect(res['kollam_year'], 1170);        // 1995 - 824 - 1 (Aug 10 < Aug 16)
      expect(res['fasli_year'], 1405);         // 1995 - 590
      expect(res['hijri_year'], 1416);         // Accurate Islamic lunar year 1416 AH
    });

    test('Test Boundary Date - Fasli Year (June 30 vs July 1)', () {
      final before = JathagaErasCalculator.calculateAllEras(
        day: 30,
        month: 6,
        year: 2026,
        hour: 10,
        minute: 0,
      );
      final after = JathagaErasCalculator.calculateAllEras(
        day: 1,
        month: 7,
        year: 2026,
        hour: 10,
        minute: 0,
      );

      expect(before['fasli_year'], 1435); // 2026 - 591
      expect(after['fasli_year'], 1436);  // 2026 - 590
    });

    test('Test 4: Boundary Date - Thiruvalluvar Year (Jan 13 vs Jan 14)', () {
      final before = JathagaErasCalculator.calculateAllEras(
        day: 13,
        month: 1,
        year: 2026,
        hour: 10,
        minute: 0,
      );
      final after = JathagaErasCalculator.calculateAllEras(
        day: 14,
        month: 1,
        year: 2026,
        hour: 10,
        minute: 0,
      );

      expect(before['thiruvalluvar_year'], 2056); // 2026 + 31 - 1
      expect(after['thiruvalluvar_year'], 2057);  // 2026 + 31
    });

    test('Test 4: Boundary Date - Salivahana & Kali Yugadhi (Apr 13 vs Apr 14)', () {
      final before = JathagaErasCalculator.calculateAllEras(
        day: 13,
        month: 4,
        year: 2026,
        hour: 10,
        minute: 0,
      );
      final after = JathagaErasCalculator.calculateAllEras(
        day: 14,
        month: 4,
        year: 2026,
        hour: 10,
        minute: 0,
      );

      expect(before['salivahana_year'], 1947);  // 2026 - 78 - 1
      expect(after['salivahana_year'], 1948);   // 2026 - 78

      expect(before['kaliyugadhi_year'], 5126); // 2026 + 3101 - 1
      expect(after['kaliyugadhi_year'], 5127);  // 2026 + 3101
    });

    test('Test 4: Boundary Date - Kollam Year (Aug 15 vs Aug 16)', () {
      final before = JathagaErasCalculator.calculateAllEras(
        day: 15,
        month: 8,
        year: 2026,
        hour: 10,
        minute: 0,
      );
      final after = JathagaErasCalculator.calculateAllEras(
        day: 16,
        month: 8,
        year: 2026,
        hour: 10,
        minute: 0,
      );

      expect(before['kollam_year'], 1201); // 2026 - 824 - 1
      expect(after['kollam_year'], 1202);  // 2026 - 824
    });

    test('Test 4: Hijri calculation (July 2026 vs August 2026)', () {
      final m7 = JathagaErasCalculator.calculateAllEras(
        day: 15,
        month: 7,
        year: 2026,
        hour: 10,
        minute: 0,
      );
      final m8 = JathagaErasCalculator.calculateAllEras(
        day: 15,
        month: 8,
        year: 2026,
        hour: 10,
        minute: 0,
      );

      // July 15, 2026 is Muharram 1448 AH; August 15, 2026 is Safar 1448 AH
      expect(m7['hijri_year'], 1448);
      expect(m8['hijri_year'], 1448);
    });
  });
}
