import 'package:flutter_test/flutter_test.dart';
import 'package:astrocall/modules/ayana_kala/ayana_kala_module.dart';

void main() {
  group('Ayana Kala Module (உத்தராயணம் / தட்சிணாயணம்) Tests', () {
    test('Uttarayana calculation for January birth (Surya in Makara)', () {
      final res = AyanaCalculator.calculate(
        birthDateTime: DateTime(2026, 1, 20, 10, 0),
        latitude: 11.0168,
        longitude: 76.9558,
      );

      expect(res.ayana, 'Uttarayana');
      expect(res.ayanaTamil, 'உத்தராயணம்');
      expect(res.rasi.contains('மகரம்') || res.rasi.contains('Makara') || res.solarLongitude >= 270.0 || res.solarLongitude < 90.0, true);
      expect(res.description.contains('உத்தராயணம்'), true);
    });

    test('Dakshinayana calculation for August birth (Surya in Simha/Karka)', () {
      final res = AyanaCalculator.calculate(
        birthDateTime: DateTime(2026, 8, 20, 10, 0),
        latitude: 11.0168,
        longitude: 76.9558,
      );

      expect(res.ayana, 'Dakshinayana');
      expect(res.ayanaTamil, 'தட்சிணாயணம்');
      expect(res.solarLongitude, inInclusiveRange(90.0, 269.999));
      expect(res.description.contains('தட்சிணாயணம்'), true);
    });

    test('Ayana start and next ayana timestamps are valid', () {
      final res = AyanaCalculator.calculate(
        birthDateTime: DateTime(2026, 4, 14, 6, 0),
      );

      expect(res.ayanaStart.isBefore(res.nextAyana), true);
    });
  });
}
