import 'package:flutter_test/flutter_test.dart';
import 'package:astrocall/modules/professional_muhurtha/professional_muhurtha.dart';

void main() {
  group('ProfessionalMuhurthaEngine Tests', () {
    final engine = ProfessionalMuhurthaEngine();
    const location = GeoLocation(
      name: 'Coimbatore',
      latitude: 11.0168,
      longitude: 76.9558,
      timeZone: 5.5,
    );

    test('calculates general Muhurtha correctly', () {
      final result = engine.calculate(
        date: DateTime(2026, 9, 15),
        location: location,
        activity: MuhurthaActivity.business,
        mode: MuhurthaMode.general,
      );

      expect(result.sunrise, isNotNull);
      expect(result.sunset, isNotNull);
      expect(result.rahuKalam, isNotNull);
      expect(result.yamagandam, isNotNull);
      expect(result.gulikai, isNotNull);
      expect(result.highestScore, greaterThanOrEqualTo(0));
      expect(result.highestScore, lessThanOrEqualTo(100));
      expect(result.finalRecommendation, isNotEmpty);
    });

    test('calculates personal Muhurtha with birth profile correctly', () {
      final birth = BirthProfile(
        birthDate: DateTime(1995, 5, 10, 10, 30),
        birthNakshatra: 3,
        birthRasi: 1,
      );

      final result = engine.calculate(
        date: DateTime(2026, 9, 15),
        location: location,
        activity: MuhurthaActivity.marriage,
        mode: MuhurthaMode.personal,
        birth: birth,
      );

      expect(result.sunrise, isNotNull);
      expect(result.sunset, isNotNull);
      expect(result.highestScore, greaterThanOrEqualTo(0));
      expect(result.highestScore, lessThanOrEqualTo(100));
    });
  });
}
