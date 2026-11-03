import 'package:flutter_test/flutter_test.dart';
import 'package:astrocall/models/tamil_calendar_models.dart';
import 'package:astrocall/services/panchanga_provider.dart';

void main() {
  group('Tamil Monthly Calendar Amirthathi Yogam Tests', () {
    const provider = AstronomicalPanchangaProvider();
    const location = PanchangaLocation(
      city: 'Chennai',
      latitude: 13.0827,
      longitude: 80.2707,
      timezone: 5.5,
    );

    test('1. Verify User Screenshot Date: 03 November 2026 (Tuesday)', () {
      final date = DateTime(2026, 11, 3);
      final dayData = provider.calculateSync(date: date, location: location);

      // Verify that the erroneous legacy "மரண யோகம்" is replaced with correct Siddha Yogam segments
      expect(dayData.weekdayTa, equals('செவ்வாய்'));
      expect(dayData.weekdayNumber, equals(2));
      expect(dayData.nakshatra, equals('மகம்'));

      // In the legacy code, (2 + 9) % 3 == 2 gave "மரண யோகம்".
      // Under canonical rules, Tuesday + Magha = Siddha Yogam!
      expect(dayData.amirthathiYoga, isNot(equals('மரண யோகம்')));
      expect(dayData.amirthathiYoga, contains('சித்தயோகம் – மகம்'));
      expect(dayData.amirthathiYoga, contains('சித்தயோகம் – பூரம்'));

      // Check the segments
      expect(dayData.amirthathiYogaSegments.length, equals(2));

      final seg1 = dayData.amirthathiYogaSegments[0];
      expect(seg1.yogaName, equals('சித்தயோகம்'));
      expect(seg1.nakshatraName, equals('மகம்'));
      expect(seg1.formattedDuration, equals('21 மணி 24 நிமிடம்'));
      expect(seg1.formattedNazhigai, equals('53 நாழிகை 30 வினாடி'));

      final seg2 = dayData.amirthathiYogaSegments[1];
      expect(seg2.yogaName, equals('சித்தயோகம்'));
      expect(seg2.nakshatraName, equals('பூரம்'));
      expect(seg2.formattedDuration, equals('2 மணி 36 நிமிடம்'));
      expect(seg2.formattedNazhigai, equals('6 நாழிகை 30 வினாடி'));

      // Total duration must equal complete 24-hour Panchangam day
      final totalMins = seg1.duration.inMinutes + seg2.duration.inMinutes;
      expect(totalMins, equals(1440));
    });

    test('2. Verify All Days in Tamil Month Receive Valid Amirthathi Yogam', () {
      // Generate Aippasi month (Month Index 6 of 2026)
      final monthData = provider.getTamilMonthData(
        tamilYear: 2026,
        tamilMonthIndex: 6, // ஐப்பசி
        location: location,
      );

      expect(monthData.days.isNotEmpty, isTrue);

      for (final day in monthData.days) {
        expect(day.amirthathiYoga, isNotEmpty);
        expect(day.amirthathiYogaSegments, isNotEmpty);

        // Verify that durations sum up to the full sunrise-to-next-sunrise day
        final totalSegMinutes = day.amirthathiYogaSegments.fold<int>(
          0,
          (sum, s) => sum + s.duration.inMinutes,
        );
        final fullDayMinutes = day.amirthathiYogaSegments.last.endTime
            .difference(day.amirthathiYogaSegments.first.startTime)
            .inMinutes;

        expect(totalSegMinutes, equals(fullDayMinutes),
            reason: 'Duration mismatch on ${day.date}');

        // Verify continuity between consecutive segments
        for (int i = 0; i < day.amirthathiYogaSegments.length - 1; i++) {
          expect(
            day.amirthathiYogaSegments[i].endTime,
            equals(day.amirthathiYogaSegments[i + 1].startTime),
            reason: 'Discontinuity on ${day.date}',
          );
        }

        // Verify that Yogam names are one of the 4 canonical types
        for (final seg in day.amirthathiYogaSegments) {
          expect(
            [
              'அமிர்தயோகம்',
              'சித்தயோகம்',
              'மரணயோகம்',
              'பிரபலாரிஷ்ட யோகம்',
            ].contains(seg.yogaName),
            isTrue,
            reason: 'Invalid yoga name ${seg.yogaName} on ${day.date}',
          );
        }
      }
    });

    test('3. Verify Multi-segment Formatting in Panchangam Details', () {
      final date = DateTime(2026, 11, 3);
      final dayData = provider.calculateSync(date: date, location: location);

      // Formatted text must display each segment with timings and duration
      final lines = dayData.amirthathiYoga.split('\n\n');
      expect(lines.length, equals(2));
      expect(lines[0], contains('சித்தயோகம் – மகம்'));
      expect(lines[0], contains('காலை 06:03 – மறுநாள் இரவு 03:27'));
      expect(lines[1], contains('சித்தயோகம் – பூரம்'));
      expect(lines[1], contains('மறுநாள் இரவு 03:27 – மறுநாள் காலை 06:03'));
    });
  });
}

