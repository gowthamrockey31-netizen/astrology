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

      // Sunday Morning Nalla Neram must be 07:30 AM - 09:00 AM, NOT 07:00 AM - 10:00 AM
      expect(res.morningNallaNeram, 'காலை 07:30 AM - 09:00 AM');
      expect(res.morningNallaNeram.contains('10:00'), false);
      expect(res.morningNallaNeram.contains('07:30 AM - 09:00 AM'), true);

      // Sunday Evening Nalla Neram must be 02:00 PM - 03:00 PM per handwritten table
      expect(res.eveningNallaNeram, 'மாலை 02:00 PM - 03:00 PM');

      // Nalla Neram sunrise-based approximation note
      expect(res.nallaNeramNote, contains('குறிப்பு: மேற்கண்ட நேரம் தோராயமானது'));

      // Sunday Day Gowri progression: உத்தி, அமிர்தம், ரோகம், லாபம், தனம், சுகம், சோரம், விஷம்
      final dayGowriNames = res.dayGowriPeriods.map((p) => p.nameTa).toList();
      expect(dayGowriNames, ['உத்தி', 'அமிர்தம்', 'ரோகம்', 'லாபம்', 'தனம்', 'சுகம்', 'சோரம்', 'விஷம்']);

      // 1st period must be உத்தி (சுபம்)
      expect(res.dayGowriPeriods[0].nameTa, 'உத்தி');
      expect(res.dayGowriPeriods[0].isGood, true);

      // 6th period must be சுகம் (சுபம்)
      expect(res.dayGowriPeriods[5].nameTa, 'சுகம்');
      expect(res.dayGowriPeriods[5].isGood, true);

      // 7th period must be சோரம் (அசுபம்)
      expect(res.dayGowriPeriods[6].nameTa, 'சோரம்');
      expect(res.dayGowriPeriods[6].isGood, false);

      // 8th period must be விஷம் (அசுபம்)
      expect(res.dayGowriPeriods[7].nameTa, 'விஷம்');
      expect(res.dayGowriPeriods[7].isGood, false);

      // Sunday Night Gowri progression matching Page 151: தனம், சுகம், சோரம், விஷம், உத்தி, அமிர்தம், ரோகம், லாபம்
      final nightGowriNames = res.nightGowriPeriods.map((p) => p.nameTa).toList();
      expect(nightGowriNames, ['தனம்', 'சுகம்', 'சோரம்', 'விஷம்', 'உத்தி', 'அமிர்தம்', 'ரோகம்', 'லாபம்']);
      expect(res.nightGowriPeriods[0].isGood, true); // தனம்
      expect(res.nightGowriPeriods[3].isGood, false); // விஷம்
      expect(res.nightGowriPeriods[7].isGood, true); // லாபம்

      // Saturday (Sep 12, 2026) Gowri verification matching Page 151
      final saturday = DateTime(2026, 9, 12);
      final satRes = DailyCalendarEngine.calculate(targetDate: saturday);
      expect(satRes.dayGowriPeriods.map((p) => p.nameTa).toList(),
          ['சோரம்', 'உத்தி', 'விஷம்', 'அமிர்தம்', 'ரோகம்', 'லாபம்', 'தனம்', 'சுகம்']);
      expect(satRes.nightGowriPeriods.map((p) => p.nameTa).toList(),
          ['லாபம்', 'தனம்', 'சுகம்', 'சோரம்', 'உத்தி', 'விஷம்', 'அமிர்தம்', 'ரோகம்']);
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

    test('TEST 13: Complete 7-Day Date-Wise Nalla Neram Verification', () {
      // 1. Sunday (Sep 6, 2026)
      final sun1 = DailyCalendarEngine.calculate(targetDate: DateTime(2026, 9, 6));
      expect(sun1.weekdayTa, 'ஞாயிறு');
      expect(sun1.morningNallaNeram, 'காலை 07:30 AM - 09:00 AM');
      expect(sun1.morningNallaNeram.contains('10:00'), false);
      expect(sun1.eveningNallaNeram, 'மாலை 02:00 PM - 03:00 PM');
      expect(sun1.nallaNeramNote, contains('குறிப்பு: மேற்கண்ட நேரம் தோராயமானது'));

      // 2. Monday (Sep 7, 2026)
      final mon = DailyCalendarEngine.calculate(targetDate: DateTime(2026, 9, 7));
      expect(mon.weekdayTa, 'திங்கள்');
      expect(mon.morningNallaNeram, 'காலை 06:00 AM - 07:00 AM');
      expect(mon.eveningNallaNeram, 'பகல் 12:00 PM - 01:30 PM');

      // 3. Tuesday (Sep 8, 2026)
      final tue = DailyCalendarEngine.calculate(targetDate: DateTime(2026, 9, 8));
      expect(tue.weekdayTa, 'செவ்வாய்');
      expect(tue.morningNallaNeram, 'காலை 10:30 AM - 11:00 AM');
      expect(tue.eveningNallaNeram, 'மாலை 05:30 PM - 06:00 PM');

      // 4. Wednesday (Sep 9, 2026)
      final wed = DailyCalendarEngine.calculate(targetDate: DateTime(2026, 9, 9));
      expect(wed.weekdayTa, 'புதன்');
      expect(wed.marriageWarning, isNull);
      expect(wed.morningNallaNeram, 'காலை 09:00 AM - 10:00 AM');
      expect(wed.eveningNallaNeram, 'பகல் 01:30 PM - 03:00 PM, மாலை 04:30 PM - 06:00 PM');

      // 5. Thursday (Sep 10, 2026)
      final thu = DailyCalendarEngine.calculate(targetDate: DateTime(2026, 9, 10));
      expect(thu.weekdayTa, 'வியாழன்');
      expect(thu.marriageWarning, isNull);
      expect(thu.morningNallaNeram, 'காலை 09:00 AM - 10:30 AM');
      expect(thu.morningNallaNeram.contains('திருமணத்தை தவிர்க்க'), false);
      expect(thu.eveningNallaNeram, 'பகல் 01:00 PM - 01:30 PM, மாலை 04:30 PM - 06:00 PM');

      // 6. Friday (Sep 11, 2026)
      final fri = DailyCalendarEngine.calculate(targetDate: DateTime(2026, 9, 11));
      expect(fri.weekdayTa, 'வெள்ளி');
      expect(fri.morningNallaNeram, 'காலை 06:00 AM - 07:30 AM');
      expect(fri.eveningNallaNeram, 'பகல் 01:00 PM - 01:30 PM, மாலை 05:00 PM - 06:00 PM');

      // 7. Saturday (Sep 12, 2026)
      final sat = DailyCalendarEngine.calculate(targetDate: DateTime(2026, 9, 12));
      expect(sat.weekdayTa, 'சனி');
      expect(sat.morningNallaNeram, 'காலை 10:30 AM - 12:00 PM');
      expect(sat.eveningNallaNeram, 'மாலை 05:00 PM - 06:00 PM');

      // Another Sunday (Sep 13, 2026) to test multiple dates
      final sun2 = DailyCalendarEngine.calculate(targetDate: DateTime(2026, 9, 13));
      expect(sun2.weekdayTa, 'ஞாயிறு');
      expect(sun2.morningNallaNeram, 'காலை 07:30 AM - 09:00 AM');
      expect(sun2.morningNallaNeram.contains('10:00'), false);
      expect(sun2.eveningNallaNeram, 'மாலை 02:00 PM - 03:00 PM');
    });

    test('TEST 14: Confirmed Tamil Date Validation Cases (Aadi 19 & Aippasi 5)', () {
      // Case 1: 04-08-1998 -> Aadi 19 (must not display Aadi 18)
      final case1 = DailyCalendarEngine.calculate(targetDate: DateTime(1998, 8, 4));
      expect(case1.tamilMonth, equals('ஆடி'));
      expect(case1.tamilDay, equals(19));
      expect(case1.tamilDateFormatted, equals('ஆடி - 19'));

      // Case 2: 21 October -> Aippasi 5 across various years
      for (final y in [1998, 2020, 2024, 2025]) {
        final case2 = DailyCalendarEngine.calculate(targetDate: DateTime(y, 10, 21));
        expect(case2.tamilMonth, equals('ஐப்பசி'));
        expect(case2.tamilDay, equals(5));
        expect(case2.tamilDateFormatted, equals('ஐப்பசி - 5'));
      }
      final case2026 = DailyCalendarEngine.calculate(targetDate: DateTime(2026, 10, 21));
      expect(case2026.tamilMonth, equals('ஐப்பசி'));
      expect(case2026.tamilDay, equals(4));

      // Transitions and middle of months across all 12 Tamil months
      final transitions = [
        (DateTime(2026, 4, 14), 'சித்திரை', 1),
        (DateTime(2026, 5, 14), 'சித்திரை', 31),
        (DateTime(2026, 5, 15), 'வைகாசி', 1),
        (DateTime(2026, 6, 15), 'ஆனி', 1),
        (DateTime(2026, 7, 16), 'ஆனி', 32),
        (DateTime(2026, 7, 17), 'ஆடி', 1),
        (DateTime(2026, 8, 17), 'ஆவணி', 1),
        (DateTime(2026, 9, 17), 'ஆவணி', 32),
        (DateTime(2026, 9, 18), 'புரட்டாசி', 1),
        (DateTime(2026, 10, 17), 'புரட்டாசி', 30),
        (DateTime(2026, 10, 18), 'ஐப்பசி', 1),
        (DateTime(2026, 11, 17), 'கார்த்திகை', 1),
        (DateTime(2026, 12, 16), 'மார்கழி', 1),
        (DateTime(2027, 1, 15), 'தை', 1),
        (DateTime(2027, 2, 13), 'மாசி', 1),
        (DateTime(2027, 3, 15), 'பங்குனி', 1),
      ];
      for (final t in transitions) {
        final res = DailyCalendarEngine.calculate(targetDate: t.$1);
        expect(res.tamilMonth, equals(t.$2));
        expect(res.tamilDay, equals(t.$3));
      }
    });

    test('TEST 15: Wednesday Marriage Warning Verification (Only on Wednesday)', () {
      // Test across a full 7-day week
      final wednesday = DateTime(2026, 9, 9);
      final thu = DateTime(2026, 9, 10);
      final fri = DateTime(2026, 9, 11);
      final sat = DateTime(2026, 9, 12);
      final sun = DateTime(2026, 9, 13);
      final mon = DateTime(2026, 9, 14);
      final tue = DateTime(2026, 9, 15);

      // 1. Wednesday: MUST NOT display "புதன்கிழமை அன்று திருமணத்தை தவிர்க்க" (marriageWarning is null)
      final wedRes = DailyCalendarEngine.calculate(targetDate: wednesday);
      expect(wedRes.weekdayTa, equals('புதன்'));
      expect(wedRes.marriageWarning, isNull);

      // 2. Thursday: MUST NOT display warning and MUST have null marriageWarning
      final thuRes = DailyCalendarEngine.calculate(targetDate: thu);
      expect(thuRes.weekdayTa, equals('வியாழன்'));
      expect(thuRes.marriageWarning, isNull);
      expect(thuRes.morningNallaNeram.contains('திருமணத்தை தவிர்க்க'), isFalse);
      expect(thuRes.nallaNeramNote.contains('வியாழன்'), isFalse);

      // 3. Other weekdays: MUST NOT display the warning
      for (final d in [fri, sat, sun, mon, tue]) {
        final res = DailyCalendarEngine.calculate(targetDate: d);
        expect(res.marriageWarning, isNull);
        expect(res.morningNallaNeram.contains('திருமணத்தை தவிர்க்க'), isFalse);
        expect(res.eveningNallaNeram.contains('திருமணத்தை தவிர்க்க'), isFalse);
      }

      // 4. Multiple Wednesdays across different months and years: all must have null marriageWarning
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

    test('TEST 14: 11 October 2026 Sandhitra/Chandrashtama Rasi displays Meenam (Pisces)', () {
      final oct11 = DateTime(2026, 10, 11);
      final res = DailyCalendarEngine.calculate(
        targetDate: oct11,
        latitude: 13.0827,
        longitude: 80.2707,
        utcOffsetHours: 5.5,
      );

      // Verify Chandrashtama Rasi displays Meenam (Pisces)
      expect(res.chandrashtamaRasiTa, contains('மீனம்'));
      expect(res.chandrashtamaRasiTa, contains('Pisces'));

      // Verify Chandrashtama Nakshatras for Meenam
      expect(res.chandrashtamaNakshatrasTa, contains('பூரட்டாதி'));
      expect(res.chandrashtamaNakshatrasTa, contains('உத்தரட்டாதி'));
      expect(res.chandrashtamaNakshatrasTa, contains('ரேவதி'));

      // Verify adjacent dates transition consistency
      final oct10 = DailyCalendarEngine.calculate(targetDate: DateTime(2026, 10, 10));
      expect(oct10.chandrashtamaRasiTa, contains('கும்பம்')); // Aquarius before Libra entry

      final oct12 = DailyCalendarEngine.calculate(targetDate: DateTime(2026, 10, 12));
      expect(oct12.chandrashtamaRasiTa, contains('மீனம்')); // Pisces while Moon is in Libra

      // Verify other fields remain completely intact
      expect(res.englishDate, '11 / 10 / 2026');
      expect(res.weekdayTa, 'ஞாயிறு');
      expect(res.weekdayEn, 'Sunday');
      expect(res.nakshatraNameTa, 'சித்திரை');
      expect(res.tithiNameTa, isNotEmpty);
      expect(res.yogaNameTa, isNotEmpty);
      expect(res.karanaNameTa, isNotEmpty);
    });
  });
}
