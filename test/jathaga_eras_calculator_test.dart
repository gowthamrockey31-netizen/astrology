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
      expect(res['hijri_year'], 1362);         // (2026 - 622) * 32/33 = 1361.45 -> 1361 + 1 (month > 7)
      expect(res['formatted_date'], '21-08-2026');
      expect(res['formatted_time'], '13:05');
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

    test('Test 4: Hijri transition (Month 7 vs Month 8)', () {
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

      expect(m7['hijri_year'], 1361);
      expect(m8['hijri_year'], 1362);
    });
  });
}
