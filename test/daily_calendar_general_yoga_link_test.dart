import 'package:flutter_test/flutter_test.dart';
import 'package:astrocall/services/daily_calendar_engine.dart';
import 'package:astrocall/models/user_model.dart';
import 'package:astrocall/services/jaathaga_kurippugal_calculator.dart';
import 'package:astrocall/models/daily_calendar_models.dart';

void main() {
  group('Daily Calendar Yoga linked to General Yoga Tests', () {
    test('Image 2 (2026-10-26): Daily Calendar Yoga exactly matches General Panchangam Yoga', () {
      final user20261026 = UserModel(
        id: 'usr_test_1',
        name: 'Divine Seeker',
        mobile: '+919876543210',
        gender: 'Male',
        dob: '2026-10-26',
        timeOfBirth: '08:30 AM',
        placeOfBirth: 'Chennai, TN',
        city: 'Chennai',
        state: 'Tamil Nadu',
        country: 'India',
        zodiac: '',
        nakshatra: '',
        lagna: '',
        walletBalance: 0,
        profilePhoto: '',
        latitude: 13.0827,
        longitude: 80.2707,
        timezone: 5.5,
      );

      final generalNotes = JaathagaKurippugalCalculator.calculateNotes(
        user: user20261026,
        birthDateTime: DateTime(2026, 10, 26, 8, 30),
      );

      final dailyData = DailyCalendarEngine.calculate(
        targetDate: DateTime(2026, 10, 26),
        latitude: 13.0827,
        longitude: 80.2707,
        utcOffsetHours: 5.5,
      );

      // Verify Nithya Yoga consistency
      expect(dailyData.yogaNameTa, 'வஜ்ரம்');
      expect(generalNotes.yoga, 'வஜ்ரம்');
      expect(dailyData.yogaNameTa, generalNotes.yoga);

      // Verify Amirthathi Yoga consistency (circled in Image 2)
      expect(generalNotes.amirthathiYoga, 'சித்த யோகம் (நன்மை)');
      expect(dailyData.amirthathiYogaTa, 'சித்த யோகம் (நன்மை)');
      expect(dailyData.amirthathiYogaTa, generalNotes.amirthathiYoga);
    });

    test('Image 1 (2026-10-11): Daily Calendar Yoga exactly matches General Panchangam Yoga', () {
      final user20261011 = UserModel(
        id: 'usr_test_2',
        name: 'Divine Seeker',
        mobile: '+919876543210',
        gender: 'Male',
        dob: '2026-10-11',
        timeOfBirth: '08:30 AM',
        placeOfBirth: 'Chennai',
        city: 'Chennai',
        state: 'Tamil Nadu',
        country: 'India',
        zodiac: '',
        nakshatra: '',
        lagna: '',
        walletBalance: 0,
        profilePhoto: '',
        latitude: 13.0827,
        longitude: 80.2707,
        timezone: 5.5,
      );

      final generalNotes = JaathagaKurippugalCalculator.calculateNotes(
        user: user20261011,
        birthDateTime: DateTime(2026, 10, 11, 8, 30),
      );

      final dailyData = DailyCalendarEngine.calculate(
        targetDate: DateTime(2026, 10, 11),
        latitude: 13.0827,
        longitude: 80.2707,
        utcOffsetHours: 5.5,
      );

      // Verify Nithya Yoga consistency
      expect(dailyData.yogaNameTa, 'வைதிருதி');
      expect(generalNotes.yoga, 'வைதிருதி');
      expect(dailyData.yogaNameTa, generalNotes.yoga);

      // Verify Amirthathi Yoga consistency (Image 1)
      expect(generalNotes.amirthathiYoga, 'மரண யோகம் (கவனம் தேவை)');
      expect(dailyData.amirthathiYogaTa, 'மரண யோகம் (கவனம் தேவை)');
      expect(dailyData.amirthathiYogaTa, generalNotes.amirthathiYoga);
    });

    test('Authoritative calculation rules are consistent across all 7 weekdays and 27 nakshatras', () {
      for (int weekday = 1; weekday <= 7; weekday++) {
        for (int nakIdx = 0; nakIdx < 27; nakIdx++) {
          final generalYogaStr = JaathagaKurippugalCalculator.calculateAmirthathiYoga(weekday, nakIdx);
          final dailyYogaType = DailyCalendarEngine.calculateNamaYoga(weekday, nakIdx);

          final rem = (weekday + nakIdx) % 3;
          if (rem == 0) {
            expect(generalYogaStr, 'அமிர்த யோகம் (சுபம்)');
            expect(dailyYogaType, NamaYogaType.amirtha);
          } else if (rem == 1) {
            expect(generalYogaStr, 'சித்த யோகம் (நன்மை)');
            expect(dailyYogaType, NamaYogaType.siddha);
          } else {
            expect(generalYogaStr, 'மரண யோகம் (கவனம் தேவை)');
            expect(dailyYogaType, NamaYogaType.marana);
          }
        }
      }
    });
  });
}
