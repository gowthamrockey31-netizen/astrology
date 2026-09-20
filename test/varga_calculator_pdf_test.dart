import 'package:flutter_test/flutter_test.dart';
import 'package:astrocall/models/varga_chart_model.dart';
import 'package:astrocall/services/varga_calculator.dart';
import 'package:astrocall/services/astrology_calculator.dart';

void main() {
  group('Divisional Charts (Vargas) PDF Pages 13-22 Verification', () {
    late Map<String, PlanetDetail> planets;

    setUp(() {
      // Sankara Narayanan A - 09-10-1999 @ 9:20 AM Dindigul (PDF Page 12)
      final horoscope = AstrologyCalculator.calculateHoroscope(
        dateOfBirth: DateTime(1999, 10, 9, 9, 20, 0),
        latitude: 10.3673,
        longitude: 77.9803,
        utcOffsetHours: 5.5,
      );
      planets = horoscope.planets;
    });

    test('All 19 Varga types are defined and calculable', () {
      final allVargas = VargaCalculator.calculateAllVargas(planets);
      expect(allVargas.length, equals(19));
      expect(VargaType.values.length, equals(19));
      expect(allVargas.containsKey(VargaType.d1), isTrue);
      expect(allVargas.containsKey(VargaType.d2), isTrue);
      expect(allVargas.containsKey(VargaType.d3), isTrue);
      expect(allVargas.containsKey(VargaType.d4), isTrue);
      expect(allVargas.containsKey(VargaType.d5), isTrue);
      expect(allVargas.containsKey(VargaType.d6), isTrue);
      expect(allVargas.containsKey(VargaType.d7), isTrue);
      expect(allVargas.containsKey(VargaType.d8), isTrue);
      expect(allVargas.containsKey(VargaType.d9), isTrue);
      expect(allVargas.containsKey(VargaType.d10), isTrue);
      expect(allVargas.containsKey(VargaType.d12), isTrue);
      expect(allVargas.containsKey(VargaType.d16), isTrue);
      expect(allVargas.containsKey(VargaType.d20), isTrue);
      expect(allVargas.containsKey(VargaType.d24), isTrue);
      expect(allVargas.containsKey(VargaType.d27), isTrue);
      expect(allVargas.containsKey(VargaType.d30), isTrue);
      expect(allVargas.containsKey(VargaType.d40), isTrue);
      expect(allVargas.containsKey(VargaType.d45), isTrue);
      expect(allVargas.containsKey(VargaType.d60), isTrue);
    });

    test('D1 (Rasi - Page 13) placements match PDF', () {
      final d1 = VargaCalculator.calculateVarga(type: VargaType.d1, planets: planets);
      expect(d1.planets['Lagna']!.rasiIndex, equals(7)); // Viruchigam
      expect(d1.planets['Sun']!.rasiIndex, equals(5)); // Kanni
      expect(d1.planets['Moon']!.rasiIndex, equals(5)); // Kanni
      expect(d1.planets['Mars']!.rasiIndex, equals(8)); // Dhanusu
      expect(d1.planets['Mercury']!.rasiIndex, equals(6)); // Thulam
      expect(d1.planets['Jupiter']!.rasiIndex, equals(0)); // Mesham
      expect(d1.planets['Venus']!.rasiIndex, equals(4)); // Simmam
      expect(d1.planets['Saturn']!.rasiIndex, equals(0)); // Mesham
      expect(d1.planets['Rahu']!.rasiIndex, equals(3)); // Kadagam
      expect(d1.planets['Ketu']!.rasiIndex, equals(9)); // Makaram
      expect(d1.planets['Mandi']!.rasiIndex, equals(6)); // Thulam
    });

    test('D2 (Hora - Page 13) placements match PDF', () {
      final d2 = VargaCalculator.calculateVarga(type: VargaType.d2, planets: planets);
      expect(d2.planets['Lagna']!.rasiIndex, equals(3)); // Kadagam
      expect(d2.planets['Saturn']!.rasiIndex, equals(3)); // Kadagam
      expect(d2.planets['Sun']!.rasiIndex, equals(4)); // Simmam
      expect(d2.planets['Moon']!.rasiIndex, equals(4)); // Simmam
      expect(d2.planets['Mars']!.rasiIndex, equals(4)); // Simmam
    });

    test('D4 (Chaturthamsha - Page 14) placements match PDF', () {
      final d4 = VargaCalculator.calculateVarga(type: VargaType.d4, planets: planets);
      expect(d4.planets['Lagna']!.rasiIndex, equals(7)); // Viruchigam
      expect(d4.planets['Sun']!.rasiIndex, equals(11)); // Meenam
      expect(d4.planets['Moon']!.rasiIndex, equals(11)); // Meenam
      expect(d4.planets['Mars']!.rasiIndex, equals(8)); // Dhanusu
      expect(d4.planets['Jupiter']!.rasiIndex, equals(3)); // Kadagam
      expect(d4.planets['Venus']!.rasiIndex, equals(4)); // Simmam
      expect(d4.planets['Saturn']!.rasiIndex, equals(6)); // Thulam
      expect(d4.planets['Mandi']!.rasiIndex, equals(6)); // Thulam
    });

    test('D5 (Panchamsha - Page 15) placements match PDF', () {
      final d5 = VargaCalculator.calculateVarga(type: VargaType.d5, planets: planets);
      expect(d5.planets['Lagna']!.rasiIndex, equals(5)); // Kanni (Virgo)
      expect(d5.planets['Sun']!.rasiIndex, equals(9)); // Makaram (Capricorn)
      expect(d5.planets['Moon']!.rasiIndex, equals(11)); // Meenam (Pisces)
      expect(d5.planets['Mars']!.rasiIndex, equals(0)); // Mesham (Aries)
      expect(d5.planets['Mercury']!.rasiIndex, equals(10)); // Kumbam (Aquarius)
      expect(d5.planets['Jupiter']!.rasiIndex, equals(10)); // Kumbam (Aquarius)
      expect(d5.planets['Venus']!.rasiIndex, equals(10)); // Kumbam (Aquarius)
      expect(d5.planets['Saturn']!.rasiIndex, equals(2)); // Mithunam (Gemini)
      expect(d5.planets['Rahu']!.rasiIndex, equals(11)); // Meenam (Pisces)
      expect(d5.planets['Ketu']!.rasiIndex, equals(11)); // Meenam (Pisces)
      expect(d5.planets['Mandi']!.rasiIndex, equals(0)); // Mesham (Aries)
    });

    test('D6 (Shashtamsha - Page 15) placements match PDF', () {
      final d6 = VargaCalculator.calculateVarga(type: VargaType.d6, planets: planets);
      expect(d6.planets['Lagna']!.rasiIndex, equals(2)); // Mithunam
      expect(d6.planets['Sun']!.rasiIndex, equals(3)); // Kadagam
      expect(d6.planets['Moon']!.rasiIndex, equals(2)); // Mithunam
      expect(d6.planets['Jupiter']!.rasiIndex, equals(1)); // Rishabam
      expect(d6.planets['Venus']!.rasiIndex, equals(5)); // Kanya
      expect(d6.planets['Saturn']!.rasiIndex, equals(4)); // Simha
      expect(d6.planets['Rahu']!.rasiIndex, equals(0)); // Mesham
      expect(d6.planets['Ketu']!.rasiIndex, equals(6)); // Thulam
      expect(d6.planets['Mandi']!.rasiIndex, equals(6)); // Thulam
    });

    test('D8 (Ashtamsha - Page 16) placements match PDF', () {
      final d8 = VargaCalculator.calculateVarga(type: VargaType.d8, planets: planets);
      expect(d8.planets['Lagna']!.rasiIndex, equals(9)); // Makaram
      expect(d8.planets['Sun']!.rasiIndex, equals(9)); // Makaram
      expect(d8.planets['Moon']!.rasiIndex, equals(8)); // Dhanusu
      expect(d8.planets['Mars']!.rasiIndex, equals(4)); // Simmam
      expect(d8.planets['Mercury']!.rasiIndex, equals(3)); // Kadagam
      expect(d8.planets['Jupiter']!.rasiIndex, equals(2)); // Mithunam
      expect(d8.planets['Venus']!.rasiIndex, equals(9)); // Makaram
      expect(d8.planets['Saturn']!.rasiIndex, equals(5)); // Kanni
      expect(d8.planets['Rahu']!.rasiIndex, equals(4)); // Simmam
      expect(d8.planets['Ketu']!.rasiIndex, equals(4)); // Simmam
      expect(d8.planets['Mandi']!.rasiIndex, equals(0)); // Mesham
    });

    test('D9 (Navamsha - Page 10 & 17) placements match PDF', () {
      final d9 = VargaCalculator.calculateVarga(type: VargaType.d9, planets: planets);
      expect(d9.planets['Mars']!.rasiIndex, equals(0)); // Mesham
      expect(d9.planets['Ketu']!.rasiIndex, equals(1)); // Rishabam
      expect(d9.planets['Moon']!.rasiIndex, equals(2)); // Mithunam
      expect(d9.planets['Jupiter']!.rasiIndex, equals(2)); // Mithunam
      expect(d9.planets['Venus']!.rasiIndex, equals(2)); // Mithunam
      expect(d9.planets['Sun']!.rasiIndex, equals(3)); // Kadagam
      expect(d9.planets['Lagna']!.rasiIndex, equals(5)); // Kanni
      expect(d9.planets['Saturn']!.rasiIndex, equals(6)); // Thulam
      expect(d9.planets['Mandi']!.rasiIndex, equals(6)); // Thulam
      expect(d9.planets['Rahu']!.rasiIndex, equals(7)); // Viruchigam
      expect(d9.planets['Mercury']!.rasiIndex, equals(9)); // Makaram
    });

    test('D10 (Dasamsha - Page 17) placements match PDF', () {
      final d10 = VargaCalculator.calculateVarga(type: VargaType.d10, planets: planets);
      expect(d10.planets['Jupiter']!.rasiIndex, equals(2)); // Mithunam
      expect(d10.planets['Lagna']!.rasiIndex, equals(5)); // Kanni
      expect(d10.planets['Moon']!.rasiIndex, equals(6)); // Thulam
      expect(d10.planets['Venus']!.rasiIndex, equals(6)); // Thulam
      expect(d10.planets['Mandi']!.rasiIndex, equals(6)); // Thulam
      expect(d10.planets['Saturn']!.rasiIndex, equals(7)); // Viruchigam
      expect(d10.planets['Sun']!.rasiIndex, equals(8)); // Dhanusu
      expect(d10.planets['Mars']!.rasiIndex, equals(8)); // Dhanusu
      expect(d10.planets['Mercury']!.rasiIndex, equals(9)); // Makaram
      expect(d10.planets['Ketu']!.rasiIndex, equals(10)); // Kumbam
    });

    test('D12 (Dwadasamsha - Page 18) placements match PDF', () {
      final d12 = VargaCalculator.calculateVarga(type: VargaType.d12, planets: planets);
      expect(d12.planets['Mars']!.rasiIndex, equals(0)); // Mesham
      expect(d12.planets['Mandi']!.rasiIndex, equals(0)); // Mesham
      expect(d12.planets['Venus']!.rasiIndex, equals(2)); // Mithunam
      expect(d12.planets['Lagna']!.rasiIndex, equals(2)); // Mithunam
      expect(d12.planets['Jupiter']!.rasiIndex, equals(3)); // Kadagam
      expect(d12.planets['Mercury']!.rasiIndex, equals(4)); // Simmam
      expect(d12.planets['Rahu']!.rasiIndex, equals(6)); // Thulam
      expect(d12.planets['Ketu']!.rasiIndex, equals(6)); // Thulam
      expect(d12.planets['Moon']!.rasiIndex, equals(7)); // Viruchigam
      expect(d12.planets['Sun']!.rasiIndex, equals(8)); // Dhanusu
      expect(d12.planets['Saturn']!.rasiIndex, equals(8)); // Dhanusu
    });

    test('Divisional Charts dynamically recalculate and change when user details change', () {
      // User 1: 1999-10-09 @ 09:20 AM (Sankara Narayanan)
      final user1Horoscope = AstrologyCalculator.calculateHoroscope(
        dateOfBirth: DateTime(1999, 10, 9, 9, 20, 0),
        latitude: 10.3673,
        longitude: 77.9803,
        utcOffsetHours: 5.5,
      );
      final user1D9 = VargaCalculator.calculateVarga(type: VargaType.d9, planets: user1Horoscope.planets);

      // User 2: 1995-08-15 @ 08:30 AM (Divine Seeker)
      final user2Horoscope = AstrologyCalculator.calculateHoroscope(
        dateOfBirth: DateTime(1995, 8, 15, 8, 30, 0),
        latitude: 13.0827,
        longitude: 80.2707,
        utcOffsetHours: 5.5,
      );
      final user2D9 = VargaCalculator.calculateVarga(type: VargaType.d9, planets: user2Horoscope.planets);

      // Verify that user 1 and user 2 produce completely different, dynamic Navamsha charts!
      expect(user1D9.planets['Lagna']!.rasiIndex, equals(5)); // Kanni
      expect(user2D9.planets['Lagna']!.rasiIndex, isNot(equals(5))); // NOT Kanni
      expect(user1D9.planets['Sun']!.rasiIndex, equals(3)); // Kadagam
      expect(user2D9.planets['Sun']!.rasiIndex, isNot(equals(3))); // NOT Kadagam
      expect(user1D9.planets['Mars']!.rasiIndex, isNot(equals(user2D9.planets['Mars']!.rasiIndex)));
    });
  });
}
