import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:astrocall/controllers/tamil_calendar_controller.dart';
import 'package:astrocall/models/tamil_calendar_models.dart';
import 'package:astrocall/services/panchanga_provider.dart';
import 'package:astrocall/widgets/calendar/tamil_month_calendar_view.dart';
import 'package:astrocall/widgets/calendar/tamil_day_detail_sheet.dart';

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

    test('3. Verification of all 12 Tamil Solar Month Start Dates, Day Counts and Ingresses', () {
      final expectedMonthData = [
        {'name': 'சித்திரை', 'days': 31, 'start': DateTime(2026, 4, 14), 'end': DateTime(2026, 5, 14)},
        {'name': 'வைகாசி', 'days': 31, 'start': DateTime(2026, 5, 15), 'end': DateTime(2026, 6, 14)},
        {'name': 'ஆனி', 'days': 32, 'start': DateTime(2026, 6, 15), 'end': DateTime(2026, 7, 16)},
        {'name': 'ஆடி', 'days': 31, 'start': DateTime(2026, 7, 17), 'end': DateTime(2026, 8, 16)},
        {'name': 'ஆவணி', 'days': 32, 'start': DateTime(2026, 8, 17), 'end': DateTime(2026, 9, 17)},
        {'name': 'புரட்டாசி', 'days': 30, 'start': DateTime(2026, 9, 18), 'end': DateTime(2026, 10, 17)},
        {'name': 'ஐப்பசி', 'days': 30, 'start': DateTime(2026, 10, 18), 'end': DateTime(2026, 11, 16)},
        {'name': 'கார்த்திகை', 'days': 29, 'start': DateTime(2026, 11, 17), 'end': DateTime(2026, 12, 15)},
        {'name': 'மார்கழி', 'days': 30, 'start': DateTime(2026, 12, 16), 'end': DateTime(2027, 1, 14)},
        {'name': 'தை', 'days': 29, 'start': DateTime(2027, 1, 15), 'end': DateTime(2027, 2, 12)},
        {'name': 'மாசி', 'days': 30, 'start': DateTime(2027, 2, 13), 'end': DateTime(2027, 3, 14)},
        {'name': 'பங்குனி', 'days': 30, 'start': DateTime(2027, 3, 15), 'end': DateTime(2027, 4, 13)},
      ];

      for (int i = 0; i < 12; i++) {
        final expected = expectedMonthData[i];
        final monthData = provider.getTamilMonthData(
          tamilYear: 2026,
          tamilMonthIndex: i,
          location: location,
        );

        expect(monthData.tamilMonth, equals(expected['name']));
        expect(monthData.startDate, equals(expected['start']));
        expect(monthData.endDate, equals(expected['end']));
        expect(monthData.days.length, equals(expected['days']),
            reason: 'Month ${expected['name']} must have exactly ${expected['days']} days');

        // Check start day
        final firstDay = monthData.days.first;
        expect(firstDay.tamilDay, equals(1));
        expect(firstDay.date, equals(expected['start']));
        expect(firstDay.tamilMonth, equals(expected['name']));

        // Check end day
        final lastDay = monthData.days.last;
        expect(lastDay.tamilDay, equals(expected['days']));
        expect(lastDay.date, equals(expected['end']));
        expect(lastDay.tamilMonth, equals(expected['name']));
      }

      // Explicit verification of transitions:
      // 1. Panguni -> Chithirai
      final panguniLast = provider.calculateSync(date: DateTime(2026, 4, 13), location: location);
      expect(panguniLast.tamilMonth, equals('பங்குனி'));
      expect(panguniLast.tamilDay, equals(30));
      final chithiraiFirst = provider.calculateSync(date: DateTime(2026, 4, 14), location: location);
      expect(chithiraiFirst.tamilMonth, equals('சித்திரை'));
      expect(chithiraiFirst.tamilDay, equals(1));

      // 2. Chithirai -> Vaikasi
      final chithiraiLast = provider.calculateSync(date: DateTime(2026, 5, 14), location: location);
      expect(chithiraiLast.tamilMonth, equals('சித்திரை'));
      expect(chithiraiLast.tamilDay, equals(31));
      final vaikasiFirst = provider.calculateSync(date: DateTime(2026, 5, 15), location: location);
      expect(vaikasiFirst.tamilMonth, equals('வைகாசி'));
      expect(vaikasiFirst.tamilDay, equals(1));

      // 3. Aani -> Aadi
      final aaniLast = provider.calculateSync(date: DateTime(2026, 7, 16), location: location);
      expect(aaniLast.tamilMonth, equals('ஆனி'));
      expect(aaniLast.tamilDay, equals(32));
      final aadiFirst = provider.calculateSync(date: DateTime(2026, 7, 17), location: location);
      expect(aadiFirst.tamilMonth, equals('ஆடி'));
      expect(aadiFirst.tamilDay, equals(1));

      // 4. Margazhi -> Thai
      final margazhiLast = provider.calculateSync(date: DateTime(2027, 1, 14), location: location);
      expect(margazhiLast.tamilMonth, equals('மார்கழி'));
      expect(margazhiLast.tamilDay, equals(30));
      final thaiFirst = provider.calculateSync(date: DateTime(2027, 1, 15), location: location);
      expect(thaiFirst.tamilMonth, equals('தை'));
      expect(thaiFirst.tamilDay, equals(1));

      // Purattasi specific days verification:
      final sep16 = provider.calculateSync(date: DateTime(2026, 9, 16), location: location);
      expect(sep16.tamilMonth, equals('ஆவணி'));
      expect(sep16.tamilDay, equals(31));

      final sep17 = provider.calculateSync(date: DateTime(2026, 9, 17), location: location);
      expect(sep17.tamilMonth, equals('ஆவணி'));
      expect(sep17.tamilDay, equals(32));
      expect(sep17.weekdayTa, equals('வியாழன்'));

      final sep18 = provider.calculateSync(date: DateTime(2026, 9, 18), location: location);
      expect(sep18.tamilMonth, equals('புரட்டாசி'));
      expect(sep18.tamilDay, equals(1));
      expect(sep18.weekdayTa, equals('வெள்ளி'));
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

      // Test Jan 2026 (Thai Pongal on Jan 14)
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

    testWidgets('6. Responsive Layout: Calendar adapts dynamically to various screen heights without overflow', (tester) async {
      final controller = TamilCalendarController(
        initialLocation: location,
        initialDate: DateTime(2026, 9, 20), // Purattasi
      );

      // Test across multiple device screen dimensions
      final testSizes = [
        const Size(360, 640),  // Compact Android
        const Size(392, 872),  // Modern Tall Android (as in screenshot)
        const Size(412, 915),  // Large Android flagship
        const Size(800, 1280), // Tablet
        const Size(844, 390),  // Landscape
      ];

      for (final size in testSizes) {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SafeArea(
                child: SingleChildScrollView(
                  child: TamilMonthCalendarView(controller: controller),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(TamilMonthCalendarView), findsOneWidget);
        expect(tester.takeException(), isNull);
      }

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    });

    testWidgets('7. Monthly Calendar: Durmuhurtham, Varjyam, and Amrita Kalam are completely absent from display', (tester) async {
      final dayData = provider.calculateSync(
        date: DateTime(2026, 9, 20),
        location: location,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TamilDayDetailSheet(dayData: dayData),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify that all 3 requested items are completely absent
      expect(find.text('துர்முஹூர்த்தம்'), findsNothing, reason: 'Durmuhurtham must not be displayed in Monthly Calendar');
      expect(find.text('வர்ஜ்யம்'), findsNothing, reason: 'Varjyam must not be displayed in Monthly Calendar');
      expect(find.text('அமிர்த காலம்'), findsNothing, reason: 'Amrita Kalam must not be displayed in Monthly Calendar');
    });

    testWidgets('8. Monthly Calendar: Emakandam, Rahu Kalam, Kuligai, Sunrise, Sunset, and other timings remain fully preserved', (tester) async {
      final dayData = provider.calculateSync(
        date: DateTime(2026, 9, 20),
        location: location,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TamilDayDetailSheet(dayData: dayData),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify essential preserved timings
      expect(find.text('சூரிய உதயம்'), findsOneWidget);
      expect(find.text('சூரிய அஸ்தமனம்'), findsOneWidget);
      expect(find.text('ராகு காலம்'), findsOneWidget);
      expect(find.text('குளிகை காலம்'), findsOneWidget);
      expect(find.text('எமகண்டம்'), findsOneWidget);
      expect(find.text('அபிஜித் முகூர்த்தம்'), findsOneWidget);

      // Verify core Panchanga details remain visible
      expect(find.text('நோக்கு நாள் & பிற விவரங்கள்'), findsOneWidget);
      expect(find.text('சந்திராஷ்டம ராசி'), findsOneWidget);
      expect(find.text('சூலம் திசை'), findsOneWidget);
      expect(find.text('பரிகாரம்'), findsOneWidget);
    });
  });
}
