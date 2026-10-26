import 'package:flutter_test/flutter_test.dart';
import 'package:astrocall/services/daily_calendar_engine.dart';
import 'package:astrocall/models/daily_calendar_models.dart';

void main() {
  group('Daily Calendar Nama Yogam (அமிர்தாதி யோகம்) Linked to General Yoga Tests', () {
    test('calculateNamaYoga correctly maps (weekday + nakIdx) % 3 for all 7 weekdays and 27 nakshatras', () {
      for (int w = 1; w <= 7; w++) {
        for (int n = 0; n < 27; n++) {
          final yoga = DailyCalendarEngine.calculateNamaYoga(w, n);
          final rem = (w + n) % 3;
          if (rem == 0) {
            expect(yoga, NamaYogaType.amirtha, reason: 'w=$w, n=$n');
          } else if (rem == 1) {
            expect(yoga, NamaYogaType.siddha, reason: 'w=$w, n=$n');
          } else {
            expect(yoga, NamaYogaType.marana, reason: 'w=$w, n=$n');
          }
        }
      }
    });

    test('NamaYogaType labels match required Tamil and English naming', () {
      expect(NamaYogaType.amirtha.tamilName, 'அமிர்தயோகம்');
      expect(NamaYogaType.amirtha.englishName, 'Amirtha Yogam');

      expect(NamaYogaType.siddha.tamilName, 'சித்தயோகம்');
      expect(NamaYogaType.siddha.englishName, 'Siddha Yogam');

      expect(NamaYogaType.marana.tamilName, 'மரணயோகம்');
      expect(NamaYogaType.marana.englishName, 'Marana Yogam');

      expect(NamaYogaType.prabalaArishta.tamilName, 'பிரபலாரிஷ்ட யோகம்');
      expect(NamaYogaType.prabalaArishta.englishName, 'Prabala Arishta Yogam');
    });

    test('resolveNakshatraIndex resolves Tamil & English spellings', () {
      expect(DailyCalendarEngine.resolveNakshatraIndex('அசுவினி'), 0);
      expect(DailyCalendarEngine.resolveNakshatraIndex('அஸ்வினி'), 0);
      expect(DailyCalendarEngine.resolveNakshatraIndex('Ashwini'), 0);
      expect(DailyCalendarEngine.resolveNakshatraIndex('கார்த்திகை'), 2);
      expect(DailyCalendarEngine.resolveNakshatraIndex('கிருத்திகை'), 2);
      expect(DailyCalendarEngine.resolveNakshatraIndex('சதயம்'), 23);
      expect(DailyCalendarEngine.resolveNakshatraIndex('சதாபிஷேக்'), 23);
      expect(DailyCalendarEngine.resolveNakshatraIndex('Shatabhisha'), 23);
      expect(DailyCalendarEngine.resolveNakshatraIndex('ரேவதி'), 26);
    });

    test('calculateNamaYogaForDay handles transition during the day', () {
      final targetDate = DateTime(2026, 8, 22, 6, 0); // Saturday (6)
      final nextDaySunrise = DateTime(2026, 8, 23, 6, 0);
      final nakEnd = DateTime(2026, 8, 22, 20, 49); // 08:49 PM

      // Saturday (6) + Shatabhisha (23) -> (6 + 23) % 3 = 29 % 3 = 2 -> Marana Yogam
      // Next nak is Purva Bhadrapada (24) -> (6 + 24) % 3 = 0 -> Amirtha Yogam
      final result = DailyCalendarEngine.calculateNamaYogaForDay(
        weekdayIdx: 6,
        nakIdx: 23,
        targetDate: targetDate,
        nakEnd: nakEnd,
        nextDaySunrise: nextDaySunrise,
      );

      expect(result.primaryYoga, NamaYogaType.marana);
      expect(result.nextYoga, NamaYogaType.amirtha);
      expect(result.tamil, contains('மரண யோகம் (கவனம் தேவை)'));
      expect(result.tamil, contains('08:49 PM வரை'));
      expect(result.tamil, contains('பின் அமிர்த யோகம் (சுபம்)'));
      expect(result.english, contains('Marana Yogam (until today 08:49 PM), then Amirtha Yogam'));
    });

    test('calculateNamaYogaForDay handles same Nakshatra spanning the full day', () {
      final targetDate = DateTime(2026, 8, 22, 6, 0);
      final nextDaySunrise = DateTime(2026, 8, 23, 6, 0);
      final nakEnd = DateTime(2026, 8, 23, 7, 30); // Nakshatra ends AFTER next sunrise

      // Saturday (6) + Shatabhisha (23) -> Marana Yogam
      final result = DailyCalendarEngine.calculateNamaYogaForDay(
        weekdayIdx: 6,
        nakIdx: 23,
        targetDate: targetDate,
        nakEnd: nakEnd,
        nextDaySunrise: nextDaySunrise,
      );

      expect(result.primaryYoga, NamaYogaType.marana);
      expect(result.nextYoga, isNull);
      expect(result.tamil, 'மரண யோகம் (கவனம் தேவை)');
      expect(result.english, 'Marana Yogam (Full Day)');
    });

    test('DailyCalendarEngine.calculate returns valid amirthathiYogaTa and amirthathiYogaEn consistent with General Yoga', () {
      final dt = DateTime(2026, 8, 26, 12, 0);
      final data = DailyCalendarEngine.calculate(
        targetDate: dt,
        latitude: 13.0827,
        longitude: 80.2707,
        utcOffsetHours: 5.5,
      );

      expect(data.amirthathiYogaTa.isNotEmpty, true);
      expect(
        data.amirthathiYogaTa.contains('அமிர்த யோகம்') ||
        data.amirthathiYogaTa.contains('சித்த யோகம்') ||
        data.amirthathiYogaTa.contains('மரண யோகம்'),
        true,
        reason: 'Should contain one of the General Yoga names in Tamil: ${data.amirthathiYogaTa}',
      );
      expect(data.amirthathiYogaEn != null && data.amirthathiYogaEn!.isNotEmpty, true);
    });
  });
}
