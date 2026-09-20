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

    test('Mukkuna Velai dynamically calculates by weekday and 90-min cycle (Jathaka Alankaram)', () {
      final sunrise = DateTime(2026, 8, 15, 6, 0); // Reference 06:00 AM sunrise

      // Monday (சாத்வீக நாள்):
      final mon1 = DateTime(2026, 8, 17, 6, 45); // Mon 06:45 AM -> Period 0 (0-90m) -> சாத்வீகம்
      final mon2 = DateTime(2026, 8, 17, 8, 0);  // Mon 08:00 AM -> Period 1 (90-180m) -> ராஜசம்
      final mon3 = DateTime(2026, 8, 17, 9, 45); // Mon 09:45 AM -> Period 2 (180-270m) -> தாமசம்
      expect(JaathagaKurippugalCalculator.calculateMukkunaVelai(birthDateTime: mon1, sunrise: sunrise), equals('சாத்வீகம்'));
      expect(JaathagaKurippugalCalculator.calculateMukkunaVelai(birthDateTime: mon2, sunrise: sunrise), equals('ராஜசம்'));
      expect(JaathagaKurippugalCalculator.calculateMukkunaVelai(birthDateTime: mon3, sunrise: sunrise), equals('தாமசம்'));

      // Saturday (1987-08-15) at 08:30 AM (Period 1 -> தாமசம் -> சாத்வீகம்):
      final satUser = UserModel(
        id: 'u87',
        name: 'Divine Seeker',
        mobile: '123',
        gender: 'Male',
        dob: '1987-08-15',
        timeOfBirth: '08:30 AM',
        placeOfBirth: 'Chennai',
        city: 'Chennai',
        state: 'Tamil Nadu',
        country: 'India',
        zodiac: 'Aries',
        nakshatra: 'Bharani',
        lagna: 'Virgo',
        walletBalance: 0,
        profilePhoto: '',
      );
      final res87 = JaathagaKurippugalCalculator.calculateNotes(user: satUser);
      expect(res87.mukkunaVelai, equals('சாத்வீகம்'));

      // Tuesday (1995-08-15) at 08:30 AM (Period 1 -> ராஜசம் -> தாமசம்):
      final tueUser = UserModel(
        id: 'u95',
        name: 'Divine Seeker',
        mobile: '123',
        gender: 'Male',
        dob: '1995-08-15',
        timeOfBirth: '08:30 AM',
        placeOfBirth: 'Chennai',
        city: 'Chennai',
        state: 'Tamil Nadu',
        country: 'India',
        zodiac: 'Pisces',
        nakshatra: 'Revati',
        lagna: 'Virgo',
        walletBalance: 0,
        profilePhoto: '',
      );
      final res95 = JaathagaKurippugalCalculator.calculateNotes(user: tueUser);
      // Tuesday 08:30 AM must NOT be identical to Saturday 08:30 AM!
      expect(res95.mukkunaVelai, equals('தாமசம்'));
      expect(res95.mukkunaVelai, isNot(equals(res87.mukkunaVelai)));
    });
  });
}
