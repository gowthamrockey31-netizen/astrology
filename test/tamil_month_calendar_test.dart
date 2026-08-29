import 'package:flutter_test/flutter_test.dart';
import 'package:astrocall/controllers/tamil_calendar_controller.dart';
import 'package:astrocall/models/tamil_calendar_models.dart';
import 'package:astrocall/services/panchanga_provider.dart';

void main() {
  group('Tamil Monthly Calendar Calculation & Daily Detail Tests', () {
    const provider = AstronomicalPanchangaProvider();
    const location = PanchangaLocation(
      city: 'Chennai',
      latitude: 13.0827,
      longitude: 80.2707,
      timezone: 5.5,
    );

    test('1. August 2026 Monthly Grid: Correctly contains Aadi and Aavani with solar ingress at Aug 17', () {
      final controller = TamilCalendarController(
        initialLocation: location,
        initialDate: DateTime(2026, 8, 1),
      );

      expect(controller.focusedGregorianMonthYear, equals('August 2026'));
      expect(controller.focusedTamilMonthSummary, equals('ஆடி / ஆவணி'));
      expect(controller.focusedTamilYearName, equals('பராபவ'));

      final gridDays = controller.getMonthGridDays();
      expect([35, 42].contains(gridDays.length), isTrue);

      // Verify August 1, 2026 is Aadi 16
      final aug1 = controller.getDayData(DateTime(2026, 8, 1));
      expect(aug1.tamilMonth, equals('ஆடி'));
      expect(aug1.tamilDay, equals(16));
      expect(aug1.isTamilMonthStart, isFalse);

      // Verify August 16, 2026 is Aadi 31 (last day of Aadi)
      final aug16 = controller.getDayData(DateTime(2026, 8, 16));
      expect(aug16.tamilMonth, equals('ஆடி'));
      expect(aug16.tamilDay, equals(31));

      // Verify August 17, 2026 is Aavani 1 (Solar Ingress into Simha!)
      final aug17 = controller.getDayData(DateTime(2026, 8, 17));
      expect(aug17.tamilMonth, equals('ஆவணி'));
      expect(aug17.tamilDay, equals(1));
      expect(aug17.isTamilMonthStart, isTrue);

      // Verify August 31, 2026 is Aavani 15
      final aug31 = controller.getDayData(DateTime(2026, 8, 31));
      expect(aug31.tamilMonth, equals('ஆவணி'));
      expect(aug31.tamilDay, equals(15));
    });

    test('2. Month Navigation: Next, Previous, and Today recalculate exact Tamil dates', () {
      final controller = TamilCalendarController(
        initialLocation: location,
        initialDate: DateTime(2026, 8, 15),
      );

      // Navigate to Next Month (September 2026)
      controller.nextMonth();
      expect(controller.focusedGregorianMonthYear, equals('September 2026'));
      expect(controller.focusedTamilMonthSummary, equals('ஆவணி / புரட்டாசி'));

      // In September 2026, Sept 16 is Aavani 31, Sept 17 is Purattasi 1
      final sept16 = controller.getDayData(DateTime(2026, 9, 16));
      expect(sept16.tamilMonth, equals('ஆவணி'));
      final sept17 = controller.getDayData(DateTime(2026, 9, 17));
      expect(sept17.tamilMonth, equals('புரட்டாசி'));
      expect(sept17.tamilDay, equals(1));
      expect(sept17.isTamilMonthStart, isTrue);

      // Navigate back to Previous Month (August 2026)
      controller.previousMonth();
      expect(controller.focusedGregorianMonthYear, equals('August 2026'));

      // Test Today Button
      controller.goToToday();
      expect(controller.selectedDate.year, equals(DateTime.now().year));
      expect(controller.selectedDate.month, equals(DateTime.now().month));
    });

    test('3. Verification of all 12 Solar Month Ingress Boundaries (2026)', () {
      final ingressDates2026 = {
        'சித்திரை': DateTime(2026, 4, 14),
        'வைகாசி': DateTime(2026, 5, 15),
        'ஆனி': DateTime(2026, 6, 16),
        'ஆடி': DateTime(2026, 7, 17),
        'ஆவணி': DateTime(2026, 8, 17),
        'புரட்டாசி': DateTime(2026, 9, 17),
        'ஐப்பசி': DateTime(2026, 10, 18),
        'கார்த்திகை': DateTime(2026, 11, 17),
        'மார்கழி': DateTime(2026, 12, 16),
        'தை': DateTime(2026, 1, 15),
        'மாசி': DateTime(2026, 2, 13),
        'பங்குனி': DateTime(2026, 3, 15),
      };

      ingressDates2026.forEach((monthName, ingressDate) {
        final dayData = provider.calculateSync(date: ingressDate, location: location);
        expect(dayData.tamilMonth, equals(monthName), reason: 'Ingress month mismatch for $monthName at $ingressDate');
        expect(dayData.tamilDay, equals(1), reason: 'Day 1 expected at solar ingress for $monthName');
        expect(dayData.isTamilMonthStart, isTrue);

        // Previous calendar day must belong to previous month
        final prevDayData = provider.calculateSync(
          date: ingressDate.subtract(const Duration(days: 1)),
          location: location,
        );
        expect(prevDayData.tamilMonth, isNot(equals(monthName)), reason: 'Previous day should not be $monthName');
        expect(prevDayData.tamilDay, greaterThanOrEqualTo(29));
      });
    });

    test('4. Location and Timezone Awareness without Hardcoded Single City', () {
      const londonLocation = PanchangaLocation(
        city: 'London',
        latitude: 51.5074,
        longitude: -0.1278,
        timezone: 0.0, // UTC
      );

      final controller = TamilCalendarController(
        initialLocation: londonLocation,
        initialDate: DateTime(2026, 8, 17),
      );

      final dayData = controller.getDayData(DateTime(2026, 8, 17));
      expect(dayData.location.city, equals('London'));
      expect(dayData.sunrise.isNotEmpty, isTrue);
      expect(dayData.sunset.isNotEmpty, isTrue);
    });

    test('5. Daily Panchangam Details attached to every cell', () {
      final aug15 = provider.calculateSync(date: DateTime(2026, 8, 15), location: location);
      expect(aug15.tamilMonth, equals('ஆடி'));
      expect(aug15.tamilDay, equals(30));
      expect(aug15.thithi.isNotEmpty, isTrue);
      expect(aug15.nakshatra.isNotEmpty, isTrue);
      expect(aug15.governmentHoliday, isNotNull);
      expect(aug15.governmentHoliday!.nameTa, contains('சுதந்திர தினம்'));
    });
  });
}
