import 'package:flutter_test/flutter_test.dart';
import 'package:astrocall/controllers/tamil_calendar_controller.dart';
import 'package:astrocall/models/tamil_calendar_models.dart';
import 'package:astrocall/services/panchanga_provider.dart';

void main() {
  group('Tamil Month & Panchanga Provider True Tamil Calendar Tests', () {
    const provider = AstronomicalPanchangaProvider();
    const location = PanchangaLocation(
      city: 'Chennai',
      latitude: 13.0827,
      longitude: 80.2707,
      timezone: 5.5,
    );

    test('1. ஆடி (Aadi) Month: Starts on actual Aadi 1, maps to correct Gregorian date and weekday', () {
      final aadiData = provider.getTamilMonthData(
        tamilYear: 2026,
        tamilMonthIndex: 3, // Aadi
        location: location,
      );

      expect(aadiData.tamilMonth, equals('ஆடி'));
      expect(aadiData.days.first.tamilDay, equals(1));
      // In 2026, Aadi 1 is July 17
      expect(aadiData.startDate.year, equals(2026));
      expect(aadiData.startDate.month, equals(7));
      expect(aadiData.startDate.day, equals(17));
      expect(aadiData.days.first.weekdayTa, equals('வெள்ளி')); // Friday

      // Last day of Aadi 2026 is August 16
      expect(aadiData.endDate.month, equals(8));
      expect(aadiData.endDate.day, equals(16));
      expect(aadiData.days.last.tamilDay, equals(31));

      // Sequential progression check
      for (int i = 0; i < aadiData.days.length; i++) {
        expect(aadiData.days[i].tamilDay, equals(i + 1));
        expect(aadiData.days[i].tamilMonth, equals('ஆடி'));
        expect(aadiData.days[i].date, equals(aadiData.startDate.add(Duration(days: i))));
      }
    });

    test('2. ஆவணி (Aavani) Month: Starts on actual Aavani 1, immediately follows Aadi', () {
      final aavaniData = provider.getTamilMonthData(
        tamilYear: 2026,
        tamilMonthIndex: 4, // Aavani
        location: location,
      );

      expect(aavaniData.tamilMonth, equals('ஆவணி'));
      expect(aavaniData.days.first.tamilDay, equals(1));
      // In 2026, Aavani 1 is August 17
      expect(aavaniData.startDate.year, equals(2026));
      expect(aavaniData.startDate.month, equals(8));
      expect(aavaniData.startDate.day, equals(17));
      expect(aavaniData.days.first.weekdayTa, equals('திங்கள்')); // Monday

      // Last day of Aavani 2026 is September 16
      expect(aavaniData.endDate.month, equals(9));
      expect(aavaniData.endDate.day, equals(16));
    });

    test('3. ஆனி (Aani) Month: Starts on actual Aani 1, precedes Aadi', () {
      final aaniData = provider.getTamilMonthData(
        tamilYear: 2026,
        tamilMonthIndex: 2, // Aani
        location: location,
      );

      expect(aaniData.tamilMonth, equals('ஆனி'));
      expect(aaniData.days.first.tamilDay, equals(1));
      // In 2026, Aani 1 is June 16
      expect(aaniData.startDate.year, equals(2026));
      expect(aaniData.startDate.month, equals(6));
      expect(aaniData.startDate.day, equals(16));
      expect(aaniData.days.first.weekdayTa, equals('செவ்வாய்')); // Tuesday
    });

    test('4. தை (Thai) Month: Starts on Thai 1 (Pongal / Makara Sankranti)', () {
      final thaiData = provider.getTamilMonthData(
        tamilYear: 2026,
        tamilMonthIndex: 9, // Thai
        location: location,
      );

      expect(thaiData.tamilMonth, equals('தை'));
      expect(thaiData.days.first.tamilDay, equals(1));
      // Thai 1 of 2026 is January 15, 2027 (in Tamil Year 2026 Jovian cycle)
      expect(thaiData.startDate.month, equals(1));
      expect(thaiData.startDate.day, equals(15));
    });

    test('5. சித்திரை (Chithirai) Month: Starts on Tamil New Year', () {
      final chithiraiData = provider.getTamilMonthData(
        tamilYear: 2026,
        tamilMonthIndex: 0, // Chithirai
        location: location,
      );

      expect(chithiraiData.tamilMonth, equals('சித்திரை'));
      expect(chithiraiData.days.first.tamilDay, equals(1));
      // Chithirai 1 in 2026 is April 14, 2026
      expect(chithiraiData.startDate.month, equals(4));
      expect(chithiraiData.startDate.day, equals(14));
      expect(chithiraiData.days.first.weekdayTa, equals('செவ்வாய்')); // Tuesday
    });

    test('6. Reversible Conversion API: getTamilDate <-> getGregorianDate', () {
      final aadi1Greg = provider.getGregorianDate(
        tamilYear: 2026,
        tamilMonth: 'ஆடி',
        tamilDay: 1,
        location: location,
      );
      expect(aadi1Greg, equals(DateTime(2026, 7, 17)));

      final aadi1Tamil = provider.getTamilDate(aadi1Greg, location: location);
      expect(aadi1Tamil.tamilMonth, equals('ஆடி'));
      expect(aadi1Tamil.tamilDay, equals(1));
      expect(aadi1Tamil.tamilYear, equals(2026));

      // Test mid-month day
      final aadi15Greg = provider.getGregorianDate(
        tamilYear: 2026,
        tamilMonth: 'ஆடி',
        tamilDay: 15,
        location: location,
      );
      expect(aadi15Greg, equals(DateTime(2026, 7, 31)));
      final aadi15Tamil = provider.getTamilDate(aadi15Greg, location: location);
      expect(aadi15Tamil.tamilMonth, equals('ஆடி'));
      expect(aadi15Tamil.tamilDay, equals(15));
    });

    test('7. Multi-Year Boundary Verification (2025, 2026, 2027)', () {
      for (final y in [2025, 2026, 2027]) {
        final chithirai = provider.getTamilMonthData(tamilYear: y, tamilMonthIndex: 0, location: location);
        expect(chithirai.startDate.month, equals(4));
        expect([13, 14, 15].contains(chithirai.startDate.day), isTrue);

        final aadi = provider.getTamilMonthData(tamilYear: y, tamilMonthIndex: 3, location: location);
        expect(aadi.startDate.month, equals(7));
        expect([16, 17, 18].contains(aadi.startDate.day), isTrue);
      }
    });

    test('8. TamilCalendarController Grid Alignment & Navigation', () {
      final controller = TamilCalendarController(
        initialLocation: location,
        initialDate: DateTime(2026, 7, 20), // Aadi 4, 2026
      );

      expect(controller.focusedTamilMonthName, equals('ஆடி'));
      expect(controller.focusedTamilMonthIndex, equals(3));

      final grid = controller.getMonthGridDays();
      expect([35, 42].contains(grid.length), isTrue);

      // July 17, 2026 was Friday.
      // Sunday-first header: ஞா(0), தி(1), செ(2), பு(3), வி(4), வெ(5), ச(6)
      // Cells 0..4 must be null (empty padding cells)
      for (int i = 0; i < 5; i++) {
        expect(grid[i], isNull);
      }
      // Cell 5 is Tamil Day 1 (Aadi 1)
      expect(grid[5], isNotNull);
      expect(grid[5]!.tamilDay, equals(1));
      expect(grid[5]!.date, equals(DateTime(2026, 7, 17)));

      // Test navigation to Next Month (Aavani)
      controller.nextMonth();
      expect(controller.focusedTamilMonthName, equals('ஆவணி'));
      expect(controller.focusedTamilMonthIndex, equals(4));
      final aavaniGrid = controller.getMonthGridDays();
      // August 17, 2026 was Monday (index 1 in Sunday-first).
      expect(aavaniGrid[0], isNull); // ஞா is null
      expect(aavaniGrid[1], isNotNull); // தி is Aavani 1
      expect(aavaniGrid[1]!.tamilDay, equals(1));

      // Test navigation to Previous Month (back to Aadi)
      controller.previousMonth();
      expect(controller.focusedTamilMonthName, equals('ஆடி'));

      // Test Today Button
      controller.goToToday();
      final nowTamil = provider.getTamilDate(DateTime.now(), location: location);
      expect(controller.focusedTamilMonthName, equals(nowTamil.tamilMonth));
    });

    test('9. Festivals and Government Holidays remain attached to exact Gregorian dates', () {
      final aadiData = provider.getTamilMonthData(
        tamilYear: 2026,
        tamilMonthIndex: 3, // Aadi 2026
        location: location,
      );

      // Aug 15, 2026 is Independence Day (in Aadi)
      final indepDay = aadiData.days.firstWhere((d) => d.date == DateTime(2026, 8, 15));
      expect(indepDay.governmentHoliday, isNotNull);
      expect(indepDay.governmentHoliday!.nameTa, contains('சுதந்திர தினம்'));
      expect(indepDay.festivals.any((f) => f.nameTa.contains('சுதந்திர தினம்')), isTrue);

      // April 14, 2026 is Tamil New Year (Chithirai 1)
      final chithiraiData = provider.getTamilMonthData(
        tamilYear: 2026,
        tamilMonthIndex: 0,
        location: location,
      );
      final newYearDay = chithiraiData.days.firstWhere((d) => d.date == DateTime(2026, 4, 14));
      expect(newYearDay.governmentHoliday, isNotNull);
      expect(newYearDay.governmentHoliday!.nameTa, contains('புத்தாண்டு'));
      expect(newYearDay.festivals.any((f) => f.nameTa.contains('புத்தாண்டு')), isTrue);
    });
  });
}
