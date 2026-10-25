import 'package:flutter_test/flutter_test.dart';
import 'package:astrocall/services/daily_calendar_engine.dart';
import 'package:astrocall/models/daily_calendar_models.dart';

void main() {
  group('Nama Yogam (அமிர்தாதி யோகம்) 4-Category Traditional Mapping Tests', () {
    // 1. Prabala Arishta Yogam (கூடா நாள்) - All 7 weekdays
    test('Prabala Arishta Yogam maps correctly for all 7 weekdays', () {
      // Sunday (7): Bharani (1)
      expect(DailyCalendarEngine.calculateNamaYoga(7, 1), NamaYogaType.prabalaArishta);
      // Monday (1): Chitra (13)
      expect(DailyCalendarEngine.calculateNamaYoga(1, 13), NamaYogaType.prabalaArishta);
      // Tuesday (2): Uttara Ashadha (20)
      expect(DailyCalendarEngine.calculateNamaYoga(2, 20), NamaYogaType.prabalaArishta);
      // Wednesday (3): Dhanishta (22)
      expect(DailyCalendarEngine.calculateNamaYoga(3, 22), NamaYogaType.prabalaArishta);
      // Thursday (4): Jyeshtha (17)
      expect(DailyCalendarEngine.calculateNamaYoga(4, 17), NamaYogaType.prabalaArishta);
      // Friday (5): Purva Ashadha (19)
      expect(DailyCalendarEngine.calculateNamaYoga(5, 19), NamaYogaType.prabalaArishta);
      // Saturday (6): Revati (26)
      expect(DailyCalendarEngine.calculateNamaYoga(6, 26), NamaYogaType.prabalaArishta);
    });

    // 2. Marana Yogam - All 7 weekdays
    test('Marana Yogam maps correctly for all 7 weekdays', () {
      // Sunday (7): Krittika (2), Magha (9), Vishakha (15), Anuradha (16), Dhanishta (22)
      for (final n in [2, 9, 15, 16, 22]) {
        expect(DailyCalendarEngine.calculateNamaYoga(7, n), NamaYogaType.marana, reason: 'Sunday nakIdx $n');
      }

      // Monday (1): Ashwini (0), Krittika (2), Vishakha (15), Uttara Ashadha (20)
      for (final n in [0, 2, 15, 20]) {
        expect(DailyCalendarEngine.calculateNamaYoga(1, n), NamaYogaType.marana, reason: 'Monday nakIdx $n');
      }

      // Tuesday (2): Ardra (5), Vishakha (15), Purva Bhadrapada (24)
      for (final n in [5, 15, 24]) {
        expect(DailyCalendarEngine.calculateNamaYoga(2, n), NamaYogaType.marana, reason: 'Tuesday nakIdx $n');
      }

      // Wednesday (3): Ashwini (0), Hasta (12)
      for (final n in [0, 12]) {
        expect(DailyCalendarEngine.calculateNamaYoga(3, n), NamaYogaType.marana, reason: 'Wednesday nakIdx $n');
      }

      // Thursday (4): Krittika (2), Mrigashira (4), Ardra (5), Uttara Phalguni (11), Anuradha (16), Shatabhisha (23)
      for (final n in [2, 4, 5, 11, 16, 23]) {
        expect(DailyCalendarEngine.calculateNamaYoga(4, n), NamaYogaType.marana, reason: 'Thursday nakIdx $n');
      }

      // Friday (5): Rohini (3), Pushya (7), Ashlesha (8), Magha (9), Shravana (21)
      for (final n in [3, 7, 8, 9, 21]) {
        expect(DailyCalendarEngine.calculateNamaYoga(5, n), NamaYogaType.marana, reason: 'Friday nakIdx $n');
      }

      // Saturday (6): Ashlesha (8), Uttara Phalguni (11), Hasta (12), Chitra (13), Purva Bhadrapada (24)
      for (final n in [8, 11, 12, 13, 24]) {
        expect(DailyCalendarEngine.calculateNamaYoga(6, n), NamaYogaType.marana, reason: 'Saturday nakIdx $n');
      }
    });

    // 3. Amirtha Yogam - All 7 weekdays
    test('Amirtha Yogam maps correctly for all 7 weekdays', () {
      // Sunday (7): Uttara Phalguni (11), Hasta (12), Moola (18), Uttara Ashadha (20), Shravana (21), Uttara Bhadrapada (25), Revati (26)
      for (final n in [11, 12, 18, 20, 21, 25, 26]) {
        expect(DailyCalendarEngine.calculateNamaYoga(7, n), NamaYogaType.amirtha, reason: 'Sunday nakIdx $n');
      }

      // Monday (1): Rohini (3), Mrigashira (4), Punarvasu (6), Uttara Phalguni (11), Swati (14), Shravana (21)
      for (final n in [3, 4, 6, 11, 14, 21]) {
        expect(DailyCalendarEngine.calculateNamaYoga(1, n), NamaYogaType.amirtha, reason: 'Monday nakIdx $n');
      }

      // Tuesday (2): Ashwini (0), Rohini (3), Uttara Phalguni (11), Moola (18), Uttara Bhadrapada (25)
      for (final n in [0, 3, 11, 18, 25]) {
        expect(DailyCalendarEngine.calculateNamaYoga(2, n), NamaYogaType.amirtha, reason: 'Tuesday nakIdx $n');
      }

      // Wednesday (3): Krittika (2), Mrigashira (4), Purva Phalguni (10), Uttara Phalguni (11), Anuradha (16), Purva Ashadha (19), Uttara Ashadha (20), Purva Bhadrapada (24), Revati (26)
      for (final n in [2, 4, 10, 11, 16, 19, 20, 24, 26]) {
        expect(DailyCalendarEngine.calculateNamaYoga(3, n), NamaYogaType.amirtha, reason: 'Wednesday nakIdx $n');
      }

      // Thursday (4): Ashwini (0), Punarvasu (6), Pushya (7), Magha (9), Swati (14), Revati (26)
      for (final n in [0, 6, 7, 9, 14, 26]) {
        expect(DailyCalendarEngine.calculateNamaYoga(4, n), NamaYogaType.amirtha, reason: 'Thursday nakIdx $n');
      }

      // Friday (5): Ashwini (0), Hasta (12), Moola (18), Revati (26)
      for (final n in [0, 12, 18, 26]) {
        expect(DailyCalendarEngine.calculateNamaYoga(5, n), NamaYogaType.amirtha, reason: 'Friday nakIdx $n');
      }

      // Saturday (6): Krittika (2), Rohini (3), Magha (9), Swati (14), Shatabhisha (23), Uttara Bhadrapada (25)
      for (final n in [2, 3, 9, 14, 23, 25]) {
        expect(DailyCalendarEngine.calculateNamaYoga(6, n), NamaYogaType.amirtha, reason: 'Saturday nakIdx $n');
      }
    });

    // 4. Siddha Yogam - Sample check of other combinations across all 7 days
    test('Siddha Yogam returns for non-special combinations', () {
      expect(DailyCalendarEngine.calculateNamaYoga(7, 0), NamaYogaType.siddha); // Sunday + Ashwini
      expect(DailyCalendarEngine.calculateNamaYoga(1, 1), NamaYogaType.siddha); // Monday + Bharani
      expect(DailyCalendarEngine.calculateNamaYoga(2, 1), NamaYogaType.siddha); // Tuesday + Bharani
      expect(DailyCalendarEngine.calculateNamaYoga(3, 1), NamaYogaType.siddha); // Wednesday + Bharani
      expect(DailyCalendarEngine.calculateNamaYoga(4, 1), NamaYogaType.siddha); // Thursday + Bharani
      expect(DailyCalendarEngine.calculateNamaYoga(5, 1), NamaYogaType.siddha); // Friday + Bharani
      expect(DailyCalendarEngine.calculateNamaYoga(6, 0), NamaYogaType.siddha); // Saturday + Ashwini
    });

    // 5. Test Canonical Label Names
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

    // 6. Test Nakshatra Alias and Name Resolution
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

    // 7. Dynamic Transition Calculation for a Day
    test('calculateNamaYogaForDay handles transition during the day', () {
      final targetDate = DateTime(2026, 8, 22, 6, 0); // Saturday
      final nextDaySunrise = DateTime(2026, 8, 23, 6, 0);
      final nakEnd = DateTime(2026, 8, 22, 20, 49); // 08:49 PM

      // Saturday (6) + Shatabhisha (23) -> Amirtha Yogam
      // Next nak is Purva Bhadrapada (24) -> Marana Yogam on Saturday
      final result = DailyCalendarEngine.calculateNamaYogaForDay(
        weekdayIdx: 6,
        nakIdx: 23,
        targetDate: targetDate,
        nakEnd: nakEnd,
        nextDaySunrise: nextDaySunrise,
      );

      expect(result.primaryYoga, NamaYogaType.amirtha);
      expect(result.nextYoga, NamaYogaType.marana);
      expect(result.tamil, contains('அமிர்தயோகம்'));
      expect(result.tamil, contains('08:49 PM வரை'));
      expect(result.tamil, contains('பின் மரணயோகம்'));
      expect(result.english, contains('Amirtha Yogam (until today 08:49 PM), then Marana Yogam'));
    });

    // 8. Full day yoga when Nakshatra spans beyond next sunrise
    test('calculateNamaYogaForDay handles same Nakshatra spanning the full day', () {
      final targetDate = DateTime(2026, 8, 22, 6, 0);
      final nextDaySunrise = DateTime(2026, 8, 23, 6, 0);
      final nakEnd = DateTime(2026, 8, 23, 7, 30); // Nakshatra ends AFTER next sunrise

      final result = DailyCalendarEngine.calculateNamaYogaForDay(
        weekdayIdx: 6,
        nakIdx: 23,
        targetDate: targetDate,
        nakEnd: nakEnd,
        nextDaySunrise: nextDaySunrise,
      );

      expect(result.primaryYoga, NamaYogaType.amirtha);
      expect(result.nextYoga, isNull);
      expect(result.tamil, 'அமிர்தயோகம் (முழு நாளும்)');
      expect(result.english, 'Amirtha Yogam (Full Day)');
    });

    // 9. Integration with DailyCalendarEngine.calculate
    test('DailyCalendarEngine.calculate returns valid amirthathiYogaTa and amirthathiYogaEn', () {
      final dt = DateTime(2026, 8, 26, 12, 0);
      final data = DailyCalendarEngine.calculate(
        targetDate: dt,
        latitude: 13.0827,
        longitude: 80.2707,
        utcOffsetHours: 5.5,
      );

      expect(data.amirthathiYogaTa.isNotEmpty, true);
      expect(
        data.amirthathiYogaTa.contains('அமிர்தயோகம்') ||
        data.amirthathiYogaTa.contains('சித்தயோகம்') ||
        data.amirthathiYogaTa.contains('மரணயோகம்') ||
        data.amirthathiYogaTa.contains('பிரபலாரிஷ்ட யோகம்'),
        true,
        reason: 'Should contain one of the four Nama Yogam names in Tamil: ${data.amirthathiYogaTa}',
      );
      expect(data.amirthathiYogaEn != null && data.amirthathiYogaEn!.isNotEmpty, true);
    });
  });
}
