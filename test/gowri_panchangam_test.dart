import 'package:flutter_test/flutter_test.dart';
import 'package:astrocall/services/gowri_panchangam_engine.dart';
import 'package:astrocall/services/daily_calendar_engine.dart';
import 'package:astrocall/services/astrology_calculator.dart';

void main() {
  group('Authoritative Gowri Panchangam (கௌரி பஞ்சாங்கம்) Tests', () {
    // -------------------------------------------------------------
    // Reference Table Verification as supplied in User Specification
    // -------------------------------------------------------------
    final expectedDayGowri = {
      // 0: Sunday
      0: ['உத்தி', 'அமிர்தம்', 'ரோகம்', 'லாபம்', 'தனம்', 'சுகம்', 'சோரம்', 'விஷம்'],
      // 1: Monday
      1: ['அமிர்தம்', 'விஷம்', 'ரோகம்', 'லாபம்', 'தனம்', 'சுகம்', 'சோரம்', 'விஷம்'],
      // 2: Tuesday
      2: ['ரோகம்', 'லாபம்', 'தனம்', 'சுகம்', 'விஷம்', 'உத்தி', 'சோரம்', 'அமிர்தம்'],
      // 3: Wednesday
      3: ['லாபம்', 'தனம்', 'சுகம்', 'விஷம்', 'சோரம்', 'அமிர்தம்', 'உத்தி', 'ரோகம்'],
      // 4: Thursday
      4: ['தனம்', 'சுகம்', 'சோரம்', 'அமிர்தம்', 'உத்தி', 'விஷம்', 'ரோகம்', 'லாபம்'],
      // 5: Friday
      5: ['சுகம்', 'சோரம்', 'உத்தி', 'விஷம்', 'அமிர்தம்', 'தனம்', 'லாபம்', 'தனம்'],
      // 6: Saturday
      6: ['சோரம்', 'உத்தி', 'விஷம்', 'அமிர்தம்', 'ரோகம்', 'லாபம்', 'சுகம்', 'உத்தி'],
    };

    final expectedNightGowri = {
      // 0: Sunday
      0: ['தனம்', 'சுகம்', 'சோரம்', 'விஷம்', 'உத்தி', 'அமிர்தம்', 'ரோகம்', 'லாபம்'],
      // 1: Monday
      1: ['சுகம்', 'சோரம்', 'உத்தி', 'அமிர்தம்', 'ரோகம்', 'விஷம்', 'தனம்', 'அமிர்தம்'],
      // 2: Tuesday
      2: ['சோரம்', 'உத்தி', 'சோரம்', 'அமிர்தம்', 'சோரம்', 'லாபம்', 'சுகம்', 'விஷம்'],
      // 3: Wednesday
      3: ['உத்தி', 'அமிர்தம்', 'ரோகம்', 'லாபம்', 'சுகம்', 'தனம்', 'விஷம்', 'ரோகம்'],
      // 4: Thursday
      4: ['அமிர்தம்', 'ரோகம்', 'விஷம்', 'தனம்', 'லாபம்', 'சுகம்', 'சோரம்', 'உத்தி'],
      // 5: Friday
      5: ['ரோகம்', 'லாபம்', 'தனம்', 'சுகம்', 'சோரம்', 'உத்தி', 'விஷம்', 'அமிர்தம்'],
      // 6: Saturday
      6: ['லாபம்', 'தனம்', 'சுகம்', 'விஷம்', 'உத்தி', 'சோரம்', 'அமிர்தம்', 'ரோகம்'],
    };

    test('1. Verify Weekday Index Mapping (Sunday=0 to Saturday=6)', () {
      // In Dart: Monday=1 ... Sunday=7
      // dt.weekday % 7: Sunday(7 % 7)=0, Monday(1 % 7)=1 ... Saturday(6 % 7)=6
      expect(GowriPanchangamEngine.toGowriWeekdayIndex(7), 0); // Sunday
      expect(GowriPanchangamEngine.toGowriWeekdayIndex(1), 1); // Monday
      expect(GowriPanchangamEngine.toGowriWeekdayIndex(2), 2); // Tuesday
      expect(GowriPanchangamEngine.toGowriWeekdayIndex(3), 3); // Wednesday
      expect(GowriPanchangamEngine.toGowriWeekdayIndex(4), 4); // Thursday
      expect(GowriPanchangamEngine.toGowriWeekdayIndex(5), 5); // Friday
      expect(GowriPanchangamEngine.toGowriWeekdayIndex(6), 6); // Saturday
    });

    test('2. Verify All 7 Weekdays Day Gowri against Reference Table', () {
      for (int w = 0; w < 7; w++) {
        final list = GowriPanchangamEngine.dayGowri[w]!.map((t) => t.tamilName).toList();
        expect(list, expectedDayGowri[w], reason: 'Day Gowri mismatch on weekday index $w');
        expect(list.length, 8);
      }
    });

    test('3. Verify All 7 Weekdays Night Gowri against Reference Table', () {
      for (int w = 0; w < 7; w++) {
        final list = GowriPanchangamEngine.nightGowri[w]!.map((t) => t.tamilName).toList();
        expect(list, expectedNightGowri[w], reason: 'Night Gowri mismatch on weekday index $w');
        expect(list.length, 8);
      }
    });

    test('4. Dynamic Day Gowri Interval Duration (Sunset - Sunrise / 8)', () {
      // Test non-standard sunrise 05:48 AM and sunset 06:12 PM (total 744 minutes, 93 mins per slot)
      final sunrise = DateTime(2026, 9, 6, 5, 48);
      final sunset = DateTime(2026, 9, 6, 18, 12);
      final periods = GowriPanchangamEngine.calculateDayGowriPeriods(
        sunrise: sunrise,
        sunset: sunset,
        weekdayIndex: 0, // Sunday
      );

      expect(periods.length, 8);
      // Sunday Slot 1: உத்தி, starts at sunrise 05:48 AM
      expect(periods[0].nameTa, 'உத்தி');
      expect(periods[0].isGood, true);
      expect(periods[0].startTime, sunrise);
      expect(periods[0].endTime, sunrise.add(const Duration(minutes: 93)));

      // Sunday Slot 8 ends at sunset 18:12
      expect(periods[7].nameTa, 'விஷம்');
      expect(periods[7].isGood, false);
      expect(periods[7].endTime, sunset);
    });

    test('5. Dynamic Night Gowri Interval Duration (Next Sunrise - Sunset / 8)', () {
      // Sunday sunset 18:12 to Monday sunrise 05:52 (total 696 mins = 11.6 hrs, 87 mins per slot)
      final sunset = DateTime(2026, 9, 6, 18, 12);
      final nextSunrise = DateTime(2026, 9, 7, 5, 52);
      final periods = GowriPanchangamEngine.calculateNightGowriPeriods(
        sunset: sunset,
        nextSunrise: nextSunrise,
        weekdayIndex: 0, // Sunday Night belongs to Sunday
      );

      expect(periods.length, 8);
      // Sunday Night Slot 1: தனம்
      expect(periods[0].nameTa, 'தனம்');
      expect(periods[0].isGood, true);
      expect(periods[0].startTime, sunset);
      // Total 700 minutes / 8 = 87.5 mins -> rounds to 88 mins
      expect(periods[0].endTime, sunset.add(Duration(minutes: (700 / 8.0).round())));

      // Sunday Night Slot 8: லாபம், ends at next sunrise
      expect(periods[7].nameTa, 'லாபம்');
      expect(periods[7].isGood, true);
      expect(periods[7].endTime, nextSunrise);
    });

    test('6. Active Gowri Period Detection during Day', () {
      final sunrise = DateTime(2026, 9, 6, 6, 0);
      final sunset = DateTime(2026, 9, 6, 18, 0);
      final dayPeriods = GowriPanchangamEngine.calculateDayGowriPeriods(
        sunrise: sunrise,
        sunset: sunset,
        weekdayIndex: 0, // Sunday
      );
      final nightPeriods = GowriPanchangamEngine.calculateNightGowriPeriods(
        sunset: sunset,
        nextSunrise: DateTime(2026, 9, 7, 6, 0),
        weekdayIndex: 0,
      );

      // Query at 10:45 AM (Slot 4: 10:30 AM - 12:00 PM -> Sunday Slot 4 is லாபம்)
      final queryTime = DateTime(2026, 9, 6, 10, 45);
      final result = GowriPanchangamEngine.getCurrentGowriPeriod(
        dayPeriods: dayPeriods,
        nightPeriods: nightPeriods,
        currentTime: queryTime,
      );

      expect(result, isNotNull);
      expect(result!.isDay, true);
      expect(result.period.nameTa, 'லாபம்');
      expect(result.period.isGood, true);
    });

    test('7. Active Gowri Period Detection during Night', () {
      final sunrise = DateTime(2026, 9, 6, 6, 0);
      final sunset = DateTime(2026, 9, 6, 18, 0);
      final dayPeriods = GowriPanchangamEngine.calculateDayGowriPeriods(
        sunrise: sunrise,
        sunset: sunset,
        weekdayIndex: 0, // Sunday
      );
      final nightPeriods = GowriPanchangamEngine.calculateNightGowriPeriods(
        sunset: sunset,
        nextSunrise: DateTime(2026, 9, 7, 6, 0),
        weekdayIndex: 0,
      );

      // Query at 11:15 PM (Slot 4: 10:30 PM - 12:00 AM -> Sunday Night Slot 4 is விஷம்)
      final queryTime = DateTime(2026, 9, 6, 23, 15);
      final result = GowriPanchangamEngine.getCurrentGowriPeriod(
        dayPeriods: dayPeriods,
        nightPeriods: nightPeriods,
        currentTime: queryTime,
      );

      expect(result, isNotNull);
      expect(result!.isDay, false);
      expect(result.period.nameTa, 'விஷம்');
      expect(result.period.isGood, false);
    });

    test('8. Date Change & Selected Date determining Weekday Column', () {
      // Changing date to Tuesday (Sep 8, 2026)
      final tuesday = DateTime(2026, 9, 8);
      final calDataTue = DailyCalendarEngine.calculate(targetDate: tuesday);

      expect(calDataTue.dayGowriPeriods.map((p) => p.nameTa).toList(),
          expectedDayGowri[2]); // Tuesday Day
      expect(calDataTue.nightGowriPeriods.map((p) => p.nameTa).toList(),
          expectedNightGowri[2]); // Tuesday Night

      // Changing date to Wednesday (Sep 9, 2026)
      final wednesday = DateTime(2026, 9, 9);
      final calDataWed = DailyCalendarEngine.calculate(targetDate: wednesday);

      expect(calDataWed.dayGowriPeriods.map((p) => p.nameTa).toList(),
          expectedDayGowri[3]); // Wednesday Day
      expect(calDataWed.nightGowriPeriods.map((p) => p.nameTa).toList(),
          expectedNightGowri[3]); // Wednesday Night
    });
  });
}
