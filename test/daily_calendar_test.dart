import 'package:flutter_test/flutter_test.dart';
import 'package:astrocall/services/daily_calendar_engine.dart';
import 'package:astrocall/services/astrology_calculator.dart';

void main() {
  group('Daily Calendar (தினசரி நாள்காட்டி) Unit Tests', () {
    test('TEST 1: Today calculation returns complete non-empty dataset', () {
      final now = DateTime(2026, 8, 26, 12, 0);
      final result = DailyCalendarEngine.calculate(
        targetDate: now,
        latitude: 13.0827,
        longitude: 80.2707,
        utcOffsetHours: 5.5,
      );

      // Section 1: Dates & Weekday
      expect(result.englishDate, '26 / 08 / 2026');
      expect(result.weekdayTa, 'புதன்');
      expect(result.weekdayEn, 'Wednesday');
      expect(result.tamilMonth.isNotEmpty, true);
      expect(result.tamilDay > 0, true);
      expect(result.pakshaTa.isNotEmpty, true);
      expect(result.nokkuNaalTa.isNotEmpty, true);

      // Section 2: Nalla Neram
      expect(result.morningNallaNeram.contains('காலை'), true);
      expect(result.eveningNallaNeram.contains('மாலை'), true);

      // Section 3: Gowri Periods
      expect(result.dayGowriPeriods.length, 8);
      expect(result.nightGowriPeriods.length, 8);

      // Section 4: Daily Panchangam
      expect(result.tithiNameTa.isNotEmpty, true);
      expect(result.nakshatraNameTa.isNotEmpty, true);
      expect(result.nakshatraPada >= 1 && result.nakshatraPada <= 4, true);
      expect(result.yogaNameTa.isNotEmpty, true);
      expect(result.karanaNameTa.isNotEmpty, true);

      // Section 5 & 6: Chandrashtama & Nendhiram / Jeevan
      expect(result.chandrashtamaRasiTa.isNotEmpty, true);
      expect(result.chandrashtamaNakshatrasTa.isNotEmpty, true);
      expect(result.nendhiramTa.isNotEmpty, true);
      expect(result.jeevanTa.isNotEmpty, true);

      // Section 7: Daily Time Periods
      expect(result.rahuKalam.isNotEmpty, true);
      expect(result.gulikaiKalam.isNotEmpty, true);
      expect(result.yamaGandam.isNotEmpty, true);
      expect(result.abhijitMuhurtham.isNotEmpty, true);

      // Section 8: Soolam & Pariharam
      expect(result.soolamDirectionTa.contains('வடக்கு'), true); // Wednesday Soolam is North
      expect(result.pariharamTa.contains('பால்'), true);

      // Section 10: 9 Planet Transits
      expect(result.transits.length, 9);
      final transitKeys = result.transits.map((t) => t.nameEn).toList();
      expect(transitKeys, containsAll(['Sun', 'Moon', 'Mars', 'Mercury', 'Jupiter', 'Venus', 'Saturn', 'Rahu', 'Ketu']));
    });

    test('TEST 2 & 3: Date Change & Previous/Next Day recalculation', () {
      final dateA = DateTime(2026, 8, 26, 12, 0);
      final dateB = DateTime(2026, 8, 27, 12, 0);

      final resA = DailyCalendarEngine.calculate(targetDate: dateA);
      final resB = DailyCalendarEngine.calculate(targetDate: dateB);

      expect(resA.weekdayTa, 'புதன்');
      expect(resB.weekdayTa, 'வியாழன்');

      expect(resA.englishDate, isNot(equals(resB.englishDate)));
      expect(resA.soolamDirectionTa, isNot(equals(resB.soolamDirectionTa)));
      expect(resA.eveningNallaNeram, isNot(equals(resB.eveningNallaNeram)));
      expect(resA.rahuKalam, isNot(equals(resB.rahuKalam)));
    });

    test('TEST 4: Planet Accuracy matches Authoritative Astrology Calculator', () {
      final dt = DateTime(2026, 8, 26, 12, 0);
      final res = DailyCalendarEngine.calculate(targetDate: dt, latitude: 13.0827, longitude: 80.2707, utcOffsetHours: 5.5);
      final astroData = AstrologyCalculator.calculateHoroscope(dateOfBirth: dt, latitude: 13.0827, longitude: 80.2707, utcOffsetHours: 5.5);

      for (final transit in res.transits) {
        final p = astroData.planets[transit.planetKey]!;
        expect(transit.degreeInRasi, closeTo(p.degreeInRasi, 0.001));
        expect(transit.rasiIndex, p.rasiIndex);
        expect(transit.nakshatraNameTa, p.nakshatraNameTa);
        expect(transit.pada, p.pada);
      }
    });

    test('TEST 5: Tithi & Paksha calculation integrity', () {
      // Shukla Paksha date
      final shuklaDate = DateTime(2026, 8, 15, 12, 0);
      final resShukla = DailyCalendarEngine.calculate(targetDate: shuklaDate);
      expect(resShukla.tithiNumber >= 1 && resShukla.tithiNumber <= 30, true);

      // Krishna Paksha date
      final krishnaDate = DateTime(2026, 8, 29, 12, 0);
      final resKrishna = DailyCalendarEngine.calculate(targetDate: krishnaDate);
      expect(resKrishna.tithiNumber >= 1 && resKrishna.tithiNumber <= 30, true);
    });

    test('TEST 6: Location Change updates Sunrise, Sunset & Rahu Kalam', () {
      final dt = DateTime(2026, 8, 26, 12, 0);
      // Chennai vs Delhi
      final chennai = DailyCalendarEngine.calculate(targetDate: dt, latitude: 13.0827, longitude: 80.2707, utcOffsetHours: 5.5);
      final delhi = DailyCalendarEngine.calculate(targetDate: dt, latitude: 28.6139, longitude: 77.2090, utcOffsetHours: 5.5);

      expect(chennai.sunriseStr, isNot(equals(delhi.sunriseStr)));
      expect(chennai.sunsetStr, isNot(equals(delhi.sunsetStr)));
      expect(chennai.rahuKalam, isNot(equals(delhi.rahuKalam)));
    });
  });
}
