import 'package:flutter_test/flutter_test.dart';
import 'package:astrocall/models/user_model.dart';
import 'package:astrocall/services/jaathaga_kurippugal_calculator.dart';
import 'package:astrocall/models/jaathaga_kurippugal_model.dart';

void main() {
  group('JaathagaKurippugalCalculator Unit Tests', () {
    final testUser = UserModel(
      id: 'test_1',
      name: 'சுரேஷ்',
      mobile: '+919876543210',
      gender: 'Male',
      dob: '1996-06-15',
      timeOfBirth: '08:30 AM',
      placeOfBirth: 'Chennai',
      city: 'Chennai',
      state: 'Tamil Nadu',
      country: 'India',
      zodiac: 'Gemini',
      nakshatra: 'Rohini',
      lagna: 'Mesha',
      walletBalance: 500.0,
      profilePhoto: '',
      latitude: 13.0827,
      longitude: 80.2707,
      timezone: 5.5,
    );

    test('calculateNotes populates person name, age, and English date', () {
      final JaathagaKurippugalResult res = JaathagaKurippugalCalculator.calculateNotes(user: testUser);

      expect(res.personName, equals('சுரேஷ்'));
      expect(res.gender, equals('Male'));
      expect(res.englishDate, equals('15-06-1996'));
    });

    test('calculateNotes computes correct Nazhigai format', () {
      final duration = const Duration(hours: 2, minutes: 24); // 144 mins = 6 Nazhigai
      final str = JaathagaKurippugalCalculator.formatNazhigai(duration);

      expect(str, contains('6 நாழிகை'));
    });

    test('Master Nakshatra attributes contain valid Gana and Yoni for Ashwini', () {
      final ashwini = JaathagaKurippugalCalculator.nakshatraMasterData[0];

      expect(ashwini.name, equals('அஸ்வினி'));
      expect(ashwini.gana, equals('தேவ கணம்'));
      expect(ashwini.yoni, equals('குதிரை'));
      expect(ashwini.rajju, equals('பாத ரஜ்ஜு'));
      expect(ashwini.bird, equals('காட்டு கோழி'));
      expect(ashwini.tree, equals('எட்டி'));
    });

    test('Master Nakshatra attributes array has 27 items', () {
      expect(JaathagaKurippugalCalculator.nakshatraMasterData.length, equals(27));
    });
  });
}
