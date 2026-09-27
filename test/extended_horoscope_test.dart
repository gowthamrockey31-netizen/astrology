import 'package:flutter_test/flutter_test.dart';
import 'package:astrocall/daily_rasi_palan/engine/daily_rasi_palan_engine.dart';
import 'package:astrocall/daily_rasi_palan/engine/extended_horoscope_engine.dart';
import 'package:astrocall/daily_rasi_palan/models/extended_horoscope_models.dart';
import 'package:astrocall/daily_rasi_palan/models/rasi_palan_models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Extended Horoscope (Weekly, Monthly, Yearly) Tests', () {
    // -------------------------------------------------------------
    // 1. REGRESSION CHECK: DAILY RASI PALAN
    // -------------------------------------------------------------
    test('1. Daily Rasi Palan calculation produces consistent and valid output', () {
      final testDate = DateTime(2026, 9, 27);
      final rasi = Rasi.mesham;

      final daily = DailyRasiPalanEngine.calculatePalan(rasi: rasi, date: testDate);
      expect(daily.rasi, equals(Rasi.mesham));
      expect(daily.date, equals(testDate));
      expect(daily.score, inInclusiveRange(0, 100));
      expect(daily.rating, inInclusiveRange(1, 5));
      expect(daily.general, isNotEmpty);
      expect(daily.career, isNotEmpty);
      expect(daily.finance, isNotEmpty);
      expect(daily.love, isNotEmpty);
      expect(daily.family, isNotEmpty);
      expect(daily.health, isNotEmpty);
      expect(daily.education, isNotEmpty);
      expect(daily.travel, isNotEmpty);
      expect(daily.luckyColor, isNotEmpty);
      expect(daily.luckyNumber, inInclusiveRange(1, 9));
      expect(daily.remedy, isNotEmpty);
      expect(daily.caution, isNotEmpty);
    });

    // -------------------------------------------------------------
    // 2. WEEKLY HOROSCOPE
    // -------------------------------------------------------------
    group('2. Weekly Horoscope Calculations', () {
      test('2.1 Normal Week calculation (7 days Monday to Sunday)', () {
        // Sep 27, 2026 is Sunday (weekday 7)
        final anchor = DateTime(2026, 9, 27);
        final weekRange = ExtendedHoroscopeEngine.getWeekRange(anchor);

        expect(weekRange['start'], equals(DateTime(2026, 9, 21))); // Monday
        expect(weekRange['end'], equals(DateTime(2026, 9, 27))); // Sunday
        expect(weekRange['end']!.difference(weekRange['start']!).inDays, equals(6));

        final weekly = ExtendedHoroscopeEngine.calculateWeeklyPalan(
          rasi: Rasi.mesham,
          anchorDate: anchor,
        );

        expect(weekly.rasi, equals(Rasi.mesham));
        expect(weekly.startDate, equals(DateTime(2026, 9, 21)));
        expect(weekly.endDate, equals(DateTime(2026, 9, 27)));
        expect(weekly.score, inInclusiveRange(0, 100));
        expect(weekly.rating, inInclusiveRange(1, 5));
        expect(weekly.periodHighlights.length, equals(3)); // Start, Mid, Weekend
        expect(weekly.dailyScores.length, equals(7)); // 7 daily transit scores

        // Verify categories
        expect(weekly.general, isNotEmpty);
        expect(weekly.career, isNotEmpty);
        expect(weekly.finance, isNotEmpty);
        expect(weekly.love, isNotEmpty);
        expect(weekly.family, isNotEmpty);
        expect(weekly.health, isNotEmpty);
        expect(weekly.education, isNotEmpty);
        expect(weekly.business, isNotEmpty);
        expect(weekly.travel, isNotEmpty);
        expect(weekly.luckyDays, isNotEmpty);
        expect(weekly.cautionDays, isNotEmpty);
        expect(weekly.luckyColor, isNotEmpty);
        expect(weekly.luckyNumber, inInclusiveRange(1, 9));
        expect(weekly.remedy, isNotEmpty);
        expect(weekly.caution, isNotEmpty);
      });

      test('2.2 Week crossing Month Boundary (Sep 28 to Oct 4, 2026)', () {
        final anchor = DateTime(2026, 9, 30); // Wednesday
        final weekRange = ExtendedHoroscopeEngine.getWeekRange(anchor);

        expect(weekRange['start'], equals(DateTime(2026, 9, 28))); // Monday in Sep
        expect(weekRange['end'], equals(DateTime(2026, 10, 4))); // Sunday in Oct

        final weekly = ExtendedHoroscopeEngine.calculateWeeklyPalan(
          rasi: Rasi.simmam,
          anchorDate: anchor,
        );

        expect(weekly.startDate.month, equals(9));
        expect(weekly.endDate.month, equals(10));
        expect(weekly.score, inInclusiveRange(0, 100));
        expect(weekly.dailyScores.length, equals(7));
      });

      test('2.3 Week crossing Year Boundary (Dec 28, 2026 to Jan 3, 2027)', () {
        final anchor = DateTime(2026, 12, 31); // Thursday
        final weekRange = ExtendedHoroscopeEngine.getWeekRange(anchor);

        expect(weekRange['start'], equals(DateTime(2026, 12, 28))); // Monday in 2026
        expect(weekRange['end'], equals(DateTime(2027, 1, 3))); // Sunday in 2027

        final weekly = ExtendedHoroscopeEngine.calculateWeeklyPalan(
          rasi: Rasi.magaram,
          anchorDate: anchor,
        );

        expect(weekly.startDate.year, equals(2026));
        expect(weekly.endDate.year, equals(2027));
        expect(weekly.score, inInclusiveRange(0, 100));
        expect(weekly.dailyScores.length, equals(7));
      });
    });

    // -------------------------------------------------------------
    // 3. MONTHLY HOROSCOPE
    // -------------------------------------------------------------
    group('3. Monthly Horoscope Calculations', () {
      test('3.1 28-day February in non-leap year (Feb 2026)', () {
        final anchor = DateTime(2026, 2, 10);
        final range = ExtendedHoroscopeEngine.getMonthRange(anchor);

        expect(range['start'], equals(DateTime(2026, 2, 1)));
        expect(range['end'], equals(DateTime(2026, 2, 28)));
        expect(range['end']!.day, equals(28));

        final monthly = ExtendedHoroscopeEngine.calculateMonthlyPalan(
          rasi: Rasi.viruchigam,
          anchorDate: anchor,
        );

        expect(monthly.month, equals(2));
        expect(monthly.year, equals(2026));
        expect(monthly.startDate.day, equals(1));
        expect(monthly.endDate.day, equals(28));
        expect(monthly.periodBreakdowns.length, equals(3));
        expect(monthly.score, inInclusiveRange(0, 100));
        expect(monthly.rating, inInclusiveRange(1, 5));
        expect(monthly.general, isNotEmpty);
        expect(monthly.career, isNotEmpty);
        expect(monthly.finance, isNotEmpty);
        expect(monthly.love, isNotEmpty);
        expect(monthly.family, isNotEmpty);
        expect(monthly.health, isNotEmpty);
        expect(monthly.education, isNotEmpty);
        expect(monthly.business, isNotEmpty);
        expect(monthly.travel, isNotEmpty);
        expect(monthly.auspiciousPeriod, isNotEmpty);
        expect(monthly.cautionPeriod, isNotEmpty);
      });

      test('3.2 29-day February in leap year (Feb 2028)', () {
        final anchor = DateTime(2028, 2, 15);
        final range = ExtendedHoroscopeEngine.getMonthRange(anchor);

        expect(range['start'], equals(DateTime(2028, 2, 1)));
        expect(range['end'], equals(DateTime(2028, 2, 29)));
        expect(range['end']!.day, equals(29));

        final monthly = ExtendedHoroscopeEngine.calculateMonthlyPalan(
          rasi: Rasi.meenam,
          anchorDate: anchor,
        );

        expect(monthly.endDate.day, equals(29));
        expect(monthly.score, inInclusiveRange(0, 100));
      });

      test('3.3 30-day Month (September 2026)', () {
        final anchor = DateTime(2026, 9, 27);
        final range = ExtendedHoroscopeEngine.getMonthRange(anchor);

        expect(range['start'], equals(DateTime(2026, 9, 1)));
        expect(range['end'], equals(DateTime(2026, 9, 30)));
        expect(range['end']!.day, equals(30));

        final monthly = ExtendedHoroscopeEngine.calculateMonthlyPalan(
          rasi: Rasi.kanni,
          anchorDate: anchor,
        );

        expect(monthly.endDate.day, equals(30));
        expect(monthly.score, inInclusiveRange(0, 100));
      });

      test('3.4 31-day Month (October 2026)', () {
        final anchor = DateTime(2026, 10, 15);
        final range = ExtendedHoroscopeEngine.getMonthRange(anchor);

        expect(range['start'], equals(DateTime(2026, 10, 1)));
        expect(range['end'], equals(DateTime(2026, 10, 31)));
        expect(range['end']!.day, equals(31));

        final monthly = ExtendedHoroscopeEngine.calculateMonthlyPalan(
          rasi: Rasi.thulam,
          anchorDate: anchor,
        );

        expect(monthly.endDate.day, equals(31));
        expect(monthly.score, inInclusiveRange(0, 100));
      });
    });

    // -------------------------------------------------------------
    // 4. YEARLY HOROSCOPE
    // -------------------------------------------------------------
    group('4. Yearly Horoscope Calculations', () {
      test('4.1 Normal Year (2026: Jan 1 to Dec 31, 12 month summaries)', () {
        final range = ExtendedHoroscopeEngine.getYearRange(2026);
        expect(range['start'], equals(DateTime(2026, 1, 1)));
        expect(range['end'], equals(DateTime(2026, 12, 31)));

        final yearly = ExtendedHoroscopeEngine.calculateYearlyPalan(
          rasi: Rasi.mesham,
          year: 2026,
        );

        expect(yearly.year, equals(2026));
        expect(yearly.monthSummaries.length, equals(12));
        for (int m = 1; m <= 12; m++) {
          final item = yearly.monthSummaries[m - 1];
          expect(item.month, equals(m));
          expect(item.monthNameTa, isNotEmpty);
          expect(item.monthNameEn, isNotEmpty);
          expect(item.score, inInclusiveRange(0, 100));
          expect(item.rating, inInclusiveRange(1, 5));
          expect(item.summary, isNotEmpty);
          expect(item.planetaryAspect, isNotEmpty);
        }

        expect(yearly.score, inInclusiveRange(0, 100));
        expect(yearly.rating, inInclusiveRange(1, 5));
        expect(yearly.majorTransitInfluences, isNotEmpty);
        expect(yearly.majorTransitInfluences, contains('குரு'));
        expect(yearly.majorTransitInfluences, contains('சனி'));
        expect(yearly.favorableMonths, isNotEmpty);
        expect(yearly.cautionMonths, isNotEmpty);
        expect(yearly.general, isNotEmpty);
        expect(yearly.career, isNotEmpty);
        expect(yearly.finance, isNotEmpty);
        expect(yearly.love, isNotEmpty);
        expect(yearly.family, isNotEmpty);
        expect(yearly.health, isNotEmpty);
        expect(yearly.education, isNotEmpty);
        expect(yearly.business, isNotEmpty);
        expect(yearly.travel, isNotEmpty);
        expect(yearly.remedy, isNotEmpty);
        expect(yearly.caution, isNotEmpty);
      });

      test('4.2 Leap Year (2028: Jan 1 to Dec 31)', () {
        final yearly = ExtendedHoroscopeEngine.calculateYearlyPalan(
          rasi: Rasi.kadagam,
          year: 2028,
        );

        expect(yearly.year, equals(2028));
        expect(yearly.monthSummaries.length, equals(12));
        expect(yearly.score, inInclusiveRange(0, 100));
      });
    });

    // -------------------------------------------------------------
    // 5. ALL 12 RASIS VERIFICATION
    // -------------------------------------------------------------
    test('5. All 12 Rasis calculate successfully across Weekly, Monthly, and Yearly', () {
      final anchor = DateTime(2026, 9, 27);

      for (final rasi in Rasi.values) {
        // Weekly
        final weekly = ExtendedHoroscopeEngine.calculateWeeklyPalan(
          rasi: rasi,
          anchorDate: anchor,
        );
        expect(weekly.rasi, equals(rasi));
        expect(weekly.score, inInclusiveRange(0, 100));
        expect(weekly.general, isNotEmpty);

        // Monthly
        final monthly = ExtendedHoroscopeEngine.calculateMonthlyPalan(
          rasi: rasi,
          anchorDate: anchor,
        );
        expect(monthly.rasi, equals(rasi));
        expect(monthly.score, inInclusiveRange(0, 100));
        expect(monthly.general, isNotEmpty);

        // Yearly
        final yearly = ExtendedHoroscopeEngine.calculateYearlyPalan(
          rasi: rasi,
          year: anchor.year,
        );
        expect(yearly.rasi, equals(rasi));
        expect(yearly.score, inInclusiveRange(0, 100));
        expect(yearly.general, isNotEmpty);
        expect(yearly.monthSummaries.length, equals(12));
      }
    });
  });
}
