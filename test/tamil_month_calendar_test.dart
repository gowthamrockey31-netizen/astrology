import 'package:flutter_test/flutter_test.dart';
import 'package:astrocall/controllers/tamil_calendar_controller.dart';
import 'package:astrocall/models/tamil_calendar_models.dart';
import 'package:astrocall/services/panchanga_provider.dart';
import 'package:astrocall/services/astrology_calculator.dart';

void main() {
  group('Tamil Monthly Calendar Start Position & Day 1 Alignment Tests', () {
    const provider = AstronomicalPanchangaProvider();
    const location = PanchangaLocation(
      city: 'Chennai',
      latitude: 13.0827,
      longitude: 80.2707,
      timezone: 5.5,
    );

    test('1. Start Position: Tamil Monthly Calendar starts strictly from Tamil Month Day 1', () {
      // Test Aadi (Month Index 3, July-August 2026)
      final aadiController = TamilCalendarController(
        initialLocation: location,
        initialDate: DateTime(2026, 7, 20), // Aadi
      );

      expect(aadiController.focusedTamilMonthName, equals('ஆடி'));
      final aadiGrid = aadiController.getMonthGridDays();

      // July 17, 2026 is Friday (index 5 in Sunday-first ஞா..ச)
      // Cells 0..4 are empty (null) to maintain exact weekday alignment
      for (int i = 0; i < 5; i++) {
        expect(aadiGrid[i], isNull);
      }
      // Cell 5 is Aadi Day 1
      expect(aadiGrid[5], isNotNull);
      expect(aadiGrid[5]!.tamilDay, equals(1));
      expect(aadiGrid[5]!.tamilMonth, equals('ஆடி'));
      expect(aadiGrid[5]!.date, equals(DateTime(2026, 7, 17)));
      expect(aadiGrid[5]!.weekdayTa, equals('வெள்ளி'));

      // Test Aavani (Month Index 4, August-September 2026)
      final aavaniController = TamilCalendarController(
        initialLocation: location,
        initialDate: DateTime(2026, 8, 20), // Aavani
      );

      expect(aavaniController.focusedTamilMonthName, equals('ஆவணி'));
      final aavaniGrid = aavaniController.getMonthGridDays();

      // August 17, 2026 is Monday (index 1 in Sunday-first ஞா..ச)
      // Cell 0 is empty (null)
      expect(aavaniGrid[0], isNull);
      // Cell 1 is Aavani Day 1
      expect(aavaniGrid[1], isNotNull);
      expect(aavaniGrid[1]!.tamilDay, equals(1));
      expect(aavaniGrid[1]!.tamilMonth, equals('ஆவணி'));
      expect(aavaniGrid[1]!.date, equals(DateTime(2026, 8, 17)));
      expect(aavaniGrid[1]!.weekdayTa, equals('திங்கள்'));
    });

    test('2. Month Navigation: Next and Previous step through Tamil Months starting at Day 1', () {
      final controller = TamilCalendarController(
        initialLocation: location,
        initialDate: DateTime(2026, 7, 20), // Aadi
      );

      expect(controller.focusedTamilMonthName, equals('ஆடி'));

      // Next Month -> Aavani
      controller.nextMonth();
      expect(controller.focusedTamilMonthName, equals('ஆவணி'));
      final nextGrid = controller.getMonthGridDays();
      final aavaniDay1 = nextGrid.firstWhere((d) => d != null && d.tamilDay == 1);
      expect(aavaniDay1, isNotNull);
      expect(aavaniDay1!.tamilMonth, equals('ஆவணி'));
      expect(aavaniDay1.date, equals(DateTime(2026, 8, 17)));

      // Next Month -> Purattasi
      controller.nextMonth();
      expect(controller.focusedTamilMonthName, equals('புரட்டாசி'));
      final purattasiGrid = controller.getMonthGridDays();
      final purattasiDay1 = purattasiGrid.firstWhere((d) => d != null && d.tamilDay == 1);
      expect(purattasiDay1!.date, equals(DateTime(2026, 9, 18)));
      expect(purattasiDay1.tamilDay, equals(1));
      expect(purattasiDay1.weekdayTa, equals('வெள்ளி'));

      // Previous Month -> back to Aavani
      controller.previousMonth();
      expect(controller.focusedTamilMonthName, equals('ஆவணி'));

      // Previous Month -> back to Aadi
      controller.previousMonth();
      expect(controller.focusedTamilMonthName, equals('ஆடி'));

      // Today Button
      controller.goToToday();
      final todayTamil = provider.getTamilDate(DateTime.now(), location: location);
      expect(controller.focusedTamilMonthName, equals(todayTamil.tamilMonth));
    });

    test('3. Verification of all 12 Tamil Solar Month Start Dates and Day 1 Ingress', () {
      final ingressDates2026 = {
        'சித்திரை': DateTime(2026, 4, 14),
        'வைகாசி': DateTime(2026, 5, 15),
        'ஆனி': DateTime(2026, 6, 16),
        'ஆடி': DateTime(2026, 7, 17),
        'ஆவணி': DateTime(2026, 8, 17),
        'புரட்டாசி': DateTime(2026, 9, 18),
        'ஐப்பசி': DateTime(2026, 10, 18),
        'கார்த்திகை': DateTime(2026, 11, 17),
        'மார்கழி': DateTime(2026, 12, 16),
        'தை': DateTime(2026, 1, 15),
        'மாசி': DateTime(2026, 2, 13),
        'பங்குனி': DateTime(2026, 3, 15),
      };

      ingressDates2026.forEach((monthName, ingressDate) {
        final dayData = provider.calculateSync(date: ingressDate, location: location);
        expect(dayData.tamilMonth, equals(monthName));
        expect(dayData.tamilDay, equals(1));
        expect(dayData.isTamilMonthStart, isTrue);

        // Previous day was last day of prior month
        final prevDay = provider.calculateSync(
          date: ingressDate.subtract(const Duration(days: 1)),
          location: location,
        );
        expect(prevDay.tamilMonth, isNot(equals(monthName)));
        expect(prevDay.tamilDay, greaterThanOrEqualTo(29));
      });

      // Explicit verification:
      // September 17, 2026 = Aavani 32 (ஆவணி 32)
      final sep17 = provider.calculateSync(date: DateTime(2026, 9, 17), location: location);
      expect(sep17.tamilMonth, equals('ஆவணி'));
      expect(sep17.tamilDay, equals(32));
      expect(sep17.weekdayTa, equals('வியாழன்'));

      // September 18, 2026 = Purattasi 1 (புரட்டாசி 1)
      final sep18 = provider.calculateSync(date: DateTime(2026, 9, 18), location: location);
      expect(sep18.tamilMonth, equals('புரட்டாசி'));
      expect(sep18.tamilDay, equals(1));
      expect(sep18.weekdayTa, equals('வெள்ளி'));

      // September 19, 2026 = Purattasi 2 (புரட்டாசி 2 - User's exact issue fixed!)
      final sep19 = provider.calculateSync(date: DateTime(2026, 9, 19), location: location);
      expect(sep19.tamilMonth, equals('புரட்டாசி'));
      expect(sep19.tamilDay, equals(2));
      expect(sep19.weekdayTa, equals('சனி'));

      // September 20, 2026 = Purattasi 3 (புரட்டாசி 3)
      final sep20 = provider.calculateSync(date: DateTime(2026, 9, 20), location: location);
      expect(sep20.tamilMonth, equals('புரட்டாசி'));
      expect(sep20.tamilDay, equals(3));
      expect(sep20.weekdayTa, equals('ஞாயிறு'));
    });

    test('4. Existing Panchanga Details & Festivals remain intact', () {
      final aug15 = provider.calculateSync(date: DateTime(2026, 8, 15), location: location);
      expect(aug15.tamilMonth, equals('ஆடி'));
      expect(aug15.tamilDay, equals(30));
      expect(aug15.thithi.isNotEmpty, isTrue);
      expect(aug15.nakshatra.isNotEmpty, isTrue);
      expect(aug15.governmentHoliday, isNotNull);
      expect(aug15.governmentHoliday!.nameTa, contains('சுதந்திர தினம்'));
    });

    test('5. Gregorian Month Mode: Exactly aligns with 2026 Tamil Wall Calendar (Image 1)', () {
      final gregController = TamilCalendarController(
        initialLocation: location,
        initialDate: DateTime(2026, 8, 1), // August 2026
      );
      gregController.setDisplayMode(CalendarDisplayMode.gregorianMonth);

      expect(gregController.focusedGregorianMonthNameTa, equals('ஆகஸ்ட்'));
      expect(gregController.focusedGregorianYear, equals(2026));

      final augGrid = gregController.getMonthGridDays();

      // Aug 1, 2026 is Saturday (Index 6 in Sunday-first ஞா..ச)
      // Leading cells 0..5 are null
      for (int i = 0; i < 6; i++) {
        expect(augGrid[i], isNull);
      }
      // Cell 6 is Aug 1 (Aadi 16)
      expect(augGrid[6], isNotNull);
      expect(augGrid[6]!.date, equals(DateTime(2026, 8, 1)));
      expect(augGrid[6]!.tamilMonth, equals('ஆடி'));
      expect(augGrid[6]!.tamilDay, equals(16));

      // Aug 17 is Monday (Cell 6 + 16 = 22, column 1)
      final aug17 = augGrid.firstWhere((d) => d != null && d.date == DateTime(2026, 8, 17));
      expect(aug17, isNotNull);
      expect(aug17!.tamilMonth, equals('ஆவணி'));
      expect(aug17.tamilDay, equals(1));
      expect(aug17.weekdayTa, equals('திங்கள்'));

      // Test Jan 2026 (Thai Pongal on Jan 15)
      gregController.selectDate(DateTime(2026, 1, 1));
      final janGrid = gregController.getMonthGridDays();

      // Jan 1, 2026 is Thursday (Index 4 in Sunday-first ஞா..ச)
      for (int i = 0; i < 4; i++) {
        expect(janGrid[i], isNull);
      }
      expect(janGrid[4]!.date, equals(DateTime(2026, 1, 1)));
      expect(janGrid[4]!.tamilMonth, equals('மார்கழி'));
      expect(janGrid[4]!.tamilDay, equals(17));

      // Jan 15 is Thai 1 (Thursday, Pongal)
      final jan15 = janGrid.firstWhere((d) => d != null && d.date == DateTime(2026, 1, 15));
      expect(jan15!.tamilMonth, equals('தை'));
      expect(jan15.tamilDay, equals(1));
      expect(jan15.weekdayTa, equals('வியாழன்'));
    });
  });
}
