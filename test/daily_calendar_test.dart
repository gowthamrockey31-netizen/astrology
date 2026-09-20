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

    test('TEST 4: Planet Accuracy matches Authoritative Astrology Calculator at Sunrise', () {
      final dt = DateTime(2026, 8, 26, 12, 0);
      final res = DailyCalendarEngine.calculate(targetDate: dt, latitude: 13.0827, longitude: 80.2707, utcOffsetHours: 5.5);
      final astroData = AstrologyCalculator.calculateHoroscope(dateOfBirth: res.sunriseTime, latitude: 13.0827, longitude: 80.2707, utcOffsetHours: 5.5);

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

    test('TEST 7: Karana transition contains real Tamil names and dynamic timing without placeholder indices', () {
      final dt = DateTime(2026, 9, 5, 12, 30);
      final res = DailyCalendarEngine.calculate(targetDate: dt);

      // Must not contain hardcoded placeholder 'Index'
      expect(res.karanaTransition.previousName.contains('Index'), false);
      expect(res.karanaTransition.nextName.contains('Index'), false);

      // Must contain real Tamil names
      expect(res.karanaTransition.currentName.isNotEmpty, true);
      expect(res.karanaTransition.previousName.isNotEmpty, true);
      expect(res.karanaTransition.nextName.isNotEmpty, true);

      // Must contain dynamic timing (e.g. 'இன்று ... வரை')
      expect(res.karanaTransition.currentTiming.contains('வரை'), true);
      expect(res.karanaTransition.nextTiming.contains('முதல்'), true);
    });

    test('TEST 8: September 6, 2026 Dindigul Reference Panchangam Exact Match', () {
      final dt = DateTime(2026, 9, 6);
      final res = DailyCalendarEngine.calculate(
        targetDate: dt,
        latitude: 10.3626,
        longitude: 77.9920,
        utcOffsetHours: 5.5,
      );

      // Sunrise: 06:08 AM, Sunset: 06:24 PM or 06:25 PM
      expect(res.sunriseStr, '06:08 AM');
      expect(res.sunsetStr.contains('06:2'), true);

      // Tithi: Krishna Dashami until ~07:30 PM (ref: 7:29 PM)
      expect(res.tithiNameTa, 'தசமி');
      expect(res.tithiTransition.currentName, contains('தசமி'));
      expect(res.tithiTransition.currentTiming, contains('07:30 PM'));
      expect(res.tithiTransition.nextName, 'ஏகாதசி');

      // Nakshatra: Thiruvathirai until ~07:53 PM (ref: 7:52 PM), next Punarvasu
      expect(res.nakshatraNameTa, 'திருவாதிரை');
      expect(res.nakshatraTransition.currentTiming, contains('07:53 PM'));
      expect(res.nakshatraTransition.nextName, 'புனர்பூசம்');

      // Nama Yoga: Siddhi until ~09:45 AM (ref: 9:45 AM), next Vyatipata
      expect(res.yogaNameTa, 'சித்தி');
      expect(res.yogaTransition.currentTiming, contains('09:45 AM'));
      expect(res.yogaTransition.nextName, 'வியதீபாதம்');

      // Karana: Vanija until 08:42 AM (ref: 8:42 AM), next Bhadra until ~07:30 PM, next Bava
      expect(res.karanaNameTa, 'வனசை');
      expect(res.karanaTransition.currentTiming, contains('08:42 AM'));
      expect(res.karanaTransition.nextName, contains('பத்திரை'));
      expect(res.karanaTransition.nextName, contains('பவம்'));
    });

    test('TEST 9: September 7, 2026 (Tomorrow) Panchangam Exact Match', () {
      final dt = DateTime(2026, 9, 7);
      final res = DailyCalendarEngine.calculate(
        targetDate: dt,
        latitude: 10.3626,
        longitude: 77.9920,
        utcOffsetHours: 5.5,
      );

      // Sunrise: 06:08 AM
      expect(res.sunriseStr, '06:08 AM');

      // Tithi: Krishna Ekadashi until ~05:05 PM (ref: 5:04 PM), next Dvadashi
      expect(res.tithiNameTa, 'ஏகாதசி');
      expect(res.tithiTransition.currentTiming, contains('05:05 PM'));
      expect(res.tithiTransition.nextName, 'துவாதசி');

      // Nakshatra: Punarvasu until ~06:14 PM (ref: 6:14 PM), next Pushya
      expect(res.nakshatraNameTa, 'புனர்பூசம்');
      expect(res.nakshatraTransition.currentTiming, contains('06:14 PM'));
      expect(res.nakshatraTransition.nextName, 'பூசம்');

      // Nama Yoga: Vyatipata until ~06:41 AM (ref: 6:41 AM), next Variyan
      expect(res.yogaNameTa, 'வியதீபாதம்');
      expect(res.yogaTransition.currentTiming, contains('06:41 AM'));
      expect(res.yogaTransition.nextName, 'வரீயான்');

      // Karana: Bava until 06:17 AM (ref: 6:17 AM), next Balava until 05:05 PM, next Kaulava
      expect(res.karanaNameTa, 'பவம்');
      expect(res.karanaTransition.currentTiming, contains('06:17 AM'));
      expect(res.karanaTransition.nextName, contains('பாலவம்'));
    });

    test('TEST 10: Sunday Nalla Neram and Gowri order verification (Matching Page 151)', () {
      final sunday = DateTime(2026, 9, 6); // Sunday
      final res = DailyCalendarEngine.calculate(targetDate: sunday);

      // Sunday Evening Nalla Neram must be 04:30 PM - 05:30 PM (in Sukham), NOT 03:30 - 04:30 (in Choram)
      expect(res.eveningNallaNeram, 'மாலை 04:30 PM - 05:30 PM');

      // Sunday Day Gowri progression: உத்தி, அமிர்தம், ரோகம், லாபம், தனம், விஷம், சோரம், சுகம்
      final dayGowriNames = res.dayGowriPeriods.map((p) => p.nameTa).toList();
      expect(dayGowriNames, ['உத்தி', 'அமிர்தம்', 'ரோகம்', 'லாபம்', 'தனம்', 'விஷம்', 'சோரம்', 'சுகம்']);

      // 1st period must be உத்தி (சுபம்)
      expect(res.dayGowriPeriods[0].nameTa, 'உத்தி');
      expect(res.dayGowriPeriods[0].isGood, true);

      // 7th period (3:00 - 4:30 PM) must be சோரம் (அசுபம்)
      expect(res.dayGowriPeriods[6].nameTa, 'சோரம்');
      expect(res.dayGowriPeriods[6].isGood, false);

      // 8th period (4:30 - 6:00 PM) must be சுகம் (சுபம்)
      expect(res.dayGowriPeriods[7].nameTa, 'சுகம்');
      expect(res.dayGowriPeriods[7].isGood, true);

      // Sunday Night Gowri progression matching Page 151: தனம், சுகம், லாபம், அமிர்தம், விஷம், ரோகம், சோரம், உத்தி
      final nightGowriNames = res.nightGowriPeriods.map((p) => p.nameTa).toList();
      expect(nightGowriNames, ['தனம்', 'சுகம்', 'லாபம்', 'அமிர்தம்', 'விஷம்', 'ரோகம்', 'சோரம்', 'உத்தி']);
      expect(res.nightGowriPeriods[0].isGood, true); // தனம்
      expect(res.nightGowriPeriods[4].isGood, false); // விஷம்
      expect(res.nightGowriPeriods[7].isGood, true); // உத்தி

      // Saturday (Sep 12, 2026) Gowri verification matching Page 151
      final saturday = DateTime(2026, 9, 12);
      final satRes = DailyCalendarEngine.calculate(targetDate: saturday);
      expect(satRes.dayGowriPeriods.map((p) => p.nameTa).toList(),
          ['சோரம்', 'சுகம்', 'உத்தி', 'அமிர்தம்', 'ரோகம்', 'லாபம்', 'தனம்', 'விஷம்']);
      expect(satRes.nightGowriPeriods.map((p) => p.nameTa).toList(),
          ['அமிர்தம்', 'விஷம்', 'ரோகம்', 'சோரம்', 'உத்தி', 'தனம்', 'சுகம்', 'லாபம்']);
    });

    test('TEST 11: Authentic 27-count Nendhiram & Jeevan verification', () {
      // In early Avani, Sun is in Magha (index 9)
      // When Moon is in Swati (index 14): distance k = (14 - 9) + 1 = 6 -> Netram 1, Jeevan 1/2
      final dtAvani = DateTime(2026, 8, 18);
      final resAvani = DailyCalendarEngine.calculate(targetDate: dtAvani);
      expect(resAvani.nendhiramTa, contains('1 நேந்திரம்'));
      expect(resAvani.jeevanTa, contains('½ ஜீவன்'));

      // Reference test for Sep 7, 2026 (Panchangam book exact match: N=1, J=1/2)
      final dtSep7 = DateTime(2026, 9, 7);
      final resSep7 = DailyCalendarEngine.calculate(targetDate: dtSep7);
      expect(resSep7.nendhiramTa, contains('1 நேந்திரம்'));
      expect(resSep7.jeevanTa, contains('½ ஜீவன்'));

      // Reference test for Sep 8, 2026 (Panchangam book: Pushya, N=0, J=1/2)
      final dtSep8 = DateTime(2026, 9, 8);
      final resSep8 = DailyCalendarEngine.calculate(targetDate: dtSep8);
      expect(resSep8.nendhiramTa, contains('0 நேந்திரம்'));
      expect(resSep8.jeevanTa, contains('½ ஜீவன்'));

      // Reference test for Aug 24, 2026 (Panchangam book: Purvashada, N=2, J=1)
      final dtAug24 = DateTime(2026, 8, 24);
      final resAug24 = DailyCalendarEngine.calculate(targetDate: dtAug24);
      expect(resAug24.nendhiramTa, contains('2 நேந்திரம்'));
      expect(resAug24.jeevanTa, contains('1 ஜீவன்'));
    });

    test('TEST 12: Transit Lagna 2-hour progression starting from Sun Rasi', () {
      final dt = DateTime(2026, 8, 26);
      final res = DailyCalendarEngine.calculate(targetDate: dt);

      // 12 periods of 2 hours
      expect(res.transitLagnas.length, 12);
      expect(res.currentTransitLagna.isNotEmpty, true);

      // 1st period should be the Sun's Rasi
      final sunRasiIdx = res.rawPlanets['Sun']!.rasiIndex;
      expect(res.transitLagnas[0].rasiIndex, sunRasiIdx);

      // Subsequent periods advance 1 Rasi every 2 hours
      for (int i = 0; i < 12; i++) {
        expect(res.transitLagnas[i].rasiIndex, (sunRasiIdx + i) % 12);
      }
    });
  });
}
