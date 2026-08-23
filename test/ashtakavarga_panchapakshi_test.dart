import 'package:flutter_test/flutter_test.dart';
import 'package:astrocall/services/astrology_calculator.dart';
import 'package:astrocall/services/ashtakavarga_calculator.dart';
import 'package:astrocall/services/panchapakshi_calculator.dart';

void main() {
  group('Ashtakavarga & Panchapakshi Unit Tests', () {
    final birthDt = DateTime(1987, 3, 11, 9, 50);
    final astroData = AstrologyCalculator.calculateHoroscope(
      dateOfBirth: birthDt,
      latitude: 10.2785,
      longitude: 77.9244,
      utcOffsetHours: 5.5,
    );

    test('Ashtakavarga totals 337 total SAV points across 12 Rasis', () {
      final res = AshtakavargaCalculator.calculateAshtakavarga(astroData.planets);

      expect(res.totalSavPoints, equals(337));
      expect(res.sarvashtakavarga.length, equals(12));
      expect(res.bhinnashtakavarga.keys.length, equals(7));
    });

    test('Panchapakshi determines valid birth bird for Shukla/Krishna Paksha', () {
      final bird = PanchapakshiCalculator.getBirthBird(
        nakshatraIndex: astroData.moon.nakshatraIndex,
        isShuklaPaksha: astroData.tithi.isShuklaPaksha,
      );

      expect(bird.nameTa, isNotEmpty);
      expect(bird.nameEn, isNotEmpty);
      expect(bird.symbol, isNotEmpty);
    });

    test('Panchapakshi computes live current activity with valid power percentage', () {
      final act = PanchapakshiCalculator.calculateCurrentActivity(
        nakshatraIndex: astroData.moon.nakshatraIndex,
        isShuklaPaksha: astroData.tithi.isShuklaPaksha,
      );

      expect(act.powerPercentage, greaterThanOrEqualTo(0));
      expect(act.powerPercentage, lessThanOrEqualTo(100));
      expect(act.currentYamamIndex, greaterThanOrEqualTo(1));
      expect(act.currentYamamIndex, lessThanOrEqualTo(5));
    });
  });
}
