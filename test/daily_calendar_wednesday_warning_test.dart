import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:astrocall/screens/daily_calendar/daily_calendar_screen.dart';
import 'package:astrocall/services/daily_calendar_engine.dart';

void main() {
  group('Daily Calendar Wednesday Marriage Warning Removed Tests', () {
    test('1. Wednesday has null marriageWarning (marriage avoidance text removed)', () {
      final wed = DateTime(2026, 9, 9); // Wednesday
      final res = DailyCalendarEngine.calculate(targetDate: wed);

      expect(res.weekdayTa, equals('புதன்'));
      expect(res.marriageWarning, isNull);
    });

    test('2. Thursday has null marriageWarning and no marriage warning', () {
      final thu = DateTime(2026, 9, 10); // Thursday
      final res = DailyCalendarEngine.calculate(targetDate: thu);

      expect(res.weekdayTa, equals('வியாழன்'));
      expect(res.marriageWarning, isNull);
      expect(res.morningNallaNeram.contains('திருமணத்தை தவிர்க்க'), isFalse);
      expect(res.eveningNallaNeram.contains('திருமணத்தை தவிர்க்க'), isFalse);
      expect(res.nallaNeramNote.contains('வியாழன்'), isFalse);
    });

    test('3. Other weekdays do not display marriage warning', () {
      final days = [
        DateTime(2026, 9, 6),  // Sunday
        DateTime(2026, 9, 7),  // Monday
        DateTime(2026, 9, 8),  // Tuesday
        DateTime(2026, 9, 9),  // Wednesday
        DateTime(2026, 9, 10), // Thursday
        DateTime(2026, 9, 11), // Friday
        DateTime(2026, 9, 12), // Saturday
      ];

      for (final d in days) {
        final res = DailyCalendarEngine.calculate(targetDate: d);
        expect(res.marriageWarning, isNull, reason: 'Failed for ${res.weekdayTa} ($d)');
      }
    });

    test('4. Multiple Wednesdays across months all have null marriageWarning', () {
      final otherWednesdays = [
        DateTime(2024, 1, 3),
        DateTime(2025, 6, 18),
        DateTime(2026, 10, 7),
        DateTime(2026, 10, 14),
        DateTime(2026, 10, 21),
      ];
      for (final w in otherWednesdays) {
        final res = DailyCalendarEngine.calculate(targetDate: w);
        expect(res.weekdayTa, equals('புதன்'));
        expect(res.marriageWarning, isNull);
      }
    });

    testWidgets('5. DailyCalendarScreen UI never displays Wednesday marriage avoidance text', (tester) async {
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        if (details.exceptionAsString().contains('RenderFlex overflowed')) return;
        originalOnError?.call(details);
      };
      addTearDown(() => FlutterError.onError = originalOnError);

      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      // Start on Wednesday, Sep 9, 2026
      await tester.pumpWidget(
        MaterialApp(
          home: DailyCalendarScreen(
            initialDate: DateTime(2026, 9, 9),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Wednesday warning MUST NOT be displayed
      expect(find.text('புதன்கிழமை அன்று திருமணத்தை தவிர்க்க'), findsNothing);
      expect(find.textContaining('திருமணத்தை தவிர்க்க'), findsNothing);

      // Tap Next Day button (moves to Thursday, Sep 10, 2026)
      final nextDayButton = find.byIcon(Icons.chevron_right_rounded);
      expect(nextDayButton, findsOneWidget);
      await tester.tap(nextDayButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // On Thursday: warning MUST NOT be displayed
      expect(find.text('புதன்கிழமை அன்று திருமணத்தை தவிர்க்க'), findsNothing);
      expect(find.textContaining('திருமணத்தை தவிர்க்க'), findsNothing);

      // Tap Previous Day button (moves back to Wednesday, Sep 9, 2026)
      final prevDayButton = find.byIcon(Icons.chevron_left_rounded);
      expect(prevDayButton, findsOneWidget);
      await tester.tap(prevDayButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Wednesday warning still MUST NOT be displayed
      expect(find.text('புதன்கிழமை அன்று திருமணத்தை தவிர்க்க'), findsNothing);
      expect(find.textContaining('திருமணத்தை தவிர்க்க'), findsNothing);
    });
  });
}
