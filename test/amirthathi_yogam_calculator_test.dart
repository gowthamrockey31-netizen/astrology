import 'package:flutter_test/flutter_test.dart';
import 'package:astrocall/services/jaathaga_kurippugal_calculator.dart';
import 'package:astrocall/services/daily_calendar_engine.dart';
import 'package:astrocall/models/daily_calendar_models.dart';
import 'package:astrocall/models/user_model.dart';

void main() {
  group('Amirthathi Yogam (அமிர்தாதி யோகம்) Calculation Tests', () {
    const double chennaiLat = 13.0827;
    const double chennaiLon = 80.2707;
    const double chennaiTz = 5.5;

    test('1. Verify Canonical Weekday + Nakshatra Rules for all 4 Yogams', () {
      // 1. Prabala Arishta Yogam
      expect(DailyCalendarEngine.calculateNamaYoga(7, 1), NamaYogaType.prabalaArishta); // Sun + Bharani
      expect(DailyCalendarEngine.calculateNamaYoga(1, 13), NamaYogaType.prabalaArishta); // Mon + Chitra
      expect(DailyCalendarEngine.calculateNamaYoga(2, 20), NamaYogaType.prabalaArishta); // Tue + U.Ashadha
      expect(DailyCalendarEngine.calculateNamaYoga(3, 22), NamaYogaType.prabalaArishta); // Wed + Dhanishta
      expect(DailyCalendarEngine.calculateNamaYoga(4, 17), NamaYogaType.prabalaArishta); // Thu + Jyeshtha
      expect(DailyCalendarEngine.calculateNamaYoga(5, 19), NamaYogaType.prabalaArishta); // Fri + P.Ashadha
      expect(DailyCalendarEngine.calculateNamaYoga(6, 26), NamaYogaType.prabalaArishta); // Sat + Revati

      // 2. Marana Yogam
      expect(DailyCalendarEngine.calculateNamaYoga(7, 2), NamaYogaType.marana); // Sun + Krittika
      expect(DailyCalendarEngine.calculateNamaYoga(1, 0), NamaYogaType.marana); // Mon + Ashwini
      expect(DailyCalendarEngine.calculateNamaYoga(2, 5), NamaYogaType.marana); // Tue + Ardra
      expect(DailyCalendarEngine.calculateNamaYoga(3, 0), NamaYogaType.marana); // Wed + Ashwini
      expect(DailyCalendarEngine.calculateNamaYoga(4, 2), NamaYogaType.marana); // Thu + Krittika
      expect(DailyCalendarEngine.calculateNamaYoga(5, 3), NamaYogaType.marana); // Fri + Rohini
      expect(DailyCalendarEngine.calculateNamaYoga(6, 8), NamaYogaType.marana); // Sat + Pushya

      // 3. Amirtha Yogam
      expect(DailyCalendarEngine.calculateNamaYoga(7, 11), NamaYogaType.amirtha); // Sun + U.Phalguni
      expect(DailyCalendarEngine.calculateNamaYoga(1, 3), NamaYogaType.amirtha); // Mon + Rohini
      expect(DailyCalendarEngine.calculateNamaYoga(2, 0), NamaYogaType.amirtha); // Tue + Ashwini
      expect(DailyCalendarEngine.calculateNamaYoga(3, 2), NamaYogaType.amirtha); // Wed + Krittika
      expect(DailyCalendarEngine.calculateNamaYoga(4, 0), NamaYogaType.amirtha); // Thu + Ashwini
      expect(DailyCalendarEngine.calculateNamaYoga(5, 0), NamaYogaType.amirtha); // Fri + Ashwini
      expect(DailyCalendarEngine.calculateNamaYoga(6, 3), NamaYogaType.amirtha); // Sat + Rohini

      // 4. Siddha Yogam (default for non-special combinations)
      expect(DailyCalendarEngine.calculateNamaYoga(7, 0), NamaYogaType.siddha); // Sun + Ashwini
      expect(DailyCalendarEngine.calculateNamaYoga(6, 4), NamaYogaType.siddha); // Sat + Mrigashirsham
    });

    test('2. Verify User Screenshot Profile (1995-08-15 Chennai)', () {
      final segments = JaathagaKurippugalCalculator.calculateAmirthathiYogamSegments(
        birthDateTime: DateTime(1995, 8, 15, 8, 30),
        latitude: chennaiLat,
        longitude: chennaiLon,
        utcOffsetHours: chennaiTz,
      );

      expect(segments.length, equals(2));

      // Segment 1: Siddha Yogam – Revati (from Sunrise ~05:57 to ~20:04)
      final seg1 = segments[0];
      expect(seg1.yogaName, equals('சித்தயோகம்'));
      expect(seg1.nakshatraName, equals('ரேவதி'));
      expect(seg1.nakshatraIndex, equals(26));
      expect(seg1.startTime.hour, equals(5));
      expect(seg1.startTime.minute, equals(57));
      expect(seg1.endTime.hour, equals(20));
      expect(seg1.endTime.minute, equals(4));
      expect(seg1.duration.inMinutes, equals(847)); // 14 hours 7 mins
      expect(seg1.formattedDuration, equals('14 மணி 7 நிமிடம்'));
      expect(seg1.formattedNazhigai, equals('35 நாழிகை 18 வினாடி'));

      // Segment 2: Amirtha Yogam – Ashwini (from ~20:04 to Next Sunrise ~05:57)
      final seg2 = segments[1];
      expect(seg2.yogaName, equals('அமிர்தயோகம்'));
      expect(seg2.nakshatraName, equals('அஸ்வினி'));
      expect(seg2.nakshatraIndex, equals(0));
      expect(seg2.startTime, equals(seg1.endTime)); // Exactly continuous!
      expect(seg2.duration.inMinutes, equals(593)); // 9 hours 53 mins
      expect(seg2.formattedDuration, equals('9 மணி 53 நிமிடம்'));
      expect(seg2.formattedNazhigai, equals('24 நாழிகை 43 வினாடி'));

      // Sum of segment durations must equal complete Panchangam day
      final totalMinutes = seg1.duration.inMinutes + seg2.duration.inMinutes;
      expect(totalMinutes, equals(1440));
    });

    test('3. Verify Pre-Sunrise Birth Handled by Previous Panchangam Day', () {
      // 2024-01-01 at 04:30 AM is before sunrise (~06:30 AM).
      // It must belong to Sunday Dec 31, 2023 panchangam day.
      final segments = JaathagaKurippugalCalculator.calculateAmirthathiYogamSegments(
        birthDateTime: DateTime(2024, 1, 1, 4, 30),
        latitude: chennaiLat,
        longitude: chennaiLon,
        utcOffsetHours: chennaiTz,
      );

      expect(segments.isNotEmpty, isTrue);
      // Panchangam day start must be Dec 31 sunrise
      expect(segments.first.startTime.day, equals(31));
      expect(segments.first.startTime.month, equals(12));
      expect(segments.first.startTime.year, equals(2023));

      // End must be Jan 1 sunrise
      expect(segments.last.endTime.day, equals(1));
      expect(segments.last.endTime.month, equals(1));
      expect(segments.last.endTime.year, equals(2024));
    });

    test('4. Verify Duration and Nazhigai Conversion Accuracy', () {
      // 1 Nazhigai = 24 mins = 1440 seconds
      // 5h 30m = 330 mins = 13.75 Nazhigai = 13 Nazhigai 45 Vinadi
      final n1 = JaathagaKurippugalCalculator.calculateNazhigaiAndVinadi(
        const Duration(hours: 5, minutes: 30),
      );
      expect(n1.nazhigai, equals(13));
      expect(n1.vinadi, equals(45));
      expect(n1.formatted, equals('13 நாழிகை 45 வினாடி'));

      // 24 hours = 60 Nazhigai 0 Vinadi
      final n2 = JaathagaKurippugalCalculator.calculateNazhigaiAndVinadi(
        const Duration(hours: 24),
      );
      expect(n2.nazhigai, equals(60));
      expect(n2.vinadi, equals(0));
      expect(n2.formatted, equals('60 நாழிகை 0 வினாடி'));
    });

    test('5. Verify Complete Panchangam Day Sum Equals Segment Sum', () {
      final testDates = [
        DateTime(2024, 3, 20, 10, 0),
        DateTime(2024, 6, 21, 15, 0),
        DateTime(2024, 9, 22, 18, 0),
        DateTime(2024, 12, 21, 23, 0),
      ];

      for (final dt in testDates) {
        final segments = JaathagaKurippugalCalculator.calculateAmirthathiYogamSegments(
          birthDateTime: dt,
          latitude: chennaiLat,
          longitude: chennaiLon,
          utcOffsetHours: chennaiTz,
        );

        final totalSegMinutes = segments.fold<int>(0, (sum, s) => sum + s.duration.inMinutes);
        final fullDayMinutes = segments.last.endTime.difference(segments.first.startTime).inMinutes;

        expect(totalSegMinutes, equals(fullDayMinutes), reason: 'Failed for $dt');

        // Check continuity: segment[i].endTime == segment[i+1].startTime
        for (int i = 0; i < segments.length - 1; i++) {
          expect(segments[i].endTime, equals(segments[i + 1].startTime),
              reason: 'Discontinuity between segment $i and ${i + 1} for $dt');
        }
      }
    });

    test('6. Verify calculateNotes Integration and String Formatting', () {
      final user = UserModel(
        id: 'user_1',
        name: 'Divine Seeker',
        gender: 'Male',
        dob: '1995-08-15',
        timeOfBirth: '08:30 AM',
        placeOfBirth: 'Chennai, TN',
        city: 'Chennai',
        state: 'Tamil Nadu',
        country: 'India',
        zodiac: 'Pisces',
        nakshatra: 'Revati',
        lagna: 'Virgo',
        walletBalance: 0,
        profilePhoto: '',
        latitude: chennaiLat,
        longitude: chennaiLon,
        timezone: chennaiTz,
        mobile: '9876543210',
      );

      final result = JaathagaKurippugalCalculator.calculateNotes(user: user);

      // Verify that amirthathiYoga is populated with both segments
      expect(result.amirthathiYoga, contains('சித்தயோகம் – ரேவதி'));
      expect(result.amirthathiYoga, contains('அமிர்தயோகம் – அஸ்வினி'));
      expect(result.amirthathiYoga, contains('14 மணி 7 நிமிடம் / 35 நாழிகை 18 வினாடி'));
      expect(result.amirthathiYoga, contains('9 மணி 53 நிமிடம் / 24 நாழிகை 43 வினாடி'));
      expect(result.amirthathiYogaSegments.length, equals(2));
    });
  });
}

