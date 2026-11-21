import 'package:flutter_test/flutter_test.dart';
import 'package:astrocall/modules/professional_muhurtha/professional_muhurtha.dart';

void main() {
  group('Subha Muhurtham - Panchangam, Lagna Shuddhi & Dosha Rules Tests', () {
    final engine = ProfessionalMuhurthaEngine();
    const location = GeoLocation(
      name: 'Chennai',
      latitude: 13.0827,
      longitude: 80.2707,
      timeZone: 5.5,
    );

    // ===============================================================
    // 1. PANCHAKA DOSHAM CALCULATION & CLASSIFICATION
    // Formula: (Day + Tithi + Nakshatra + Lagna) mod 9
    // Remainder:
    // 1: Mrityu Panchaka (avoid)
    // 2: Agni Panchaka (avoid)
    // 4: Raja Panchaka (avoid)
    // 6: Chora Panchaka (avoid)
    // 8: Roga Panchaka (avoid)
    // 0, 3, 5, 7: Subha Panchaka (auspicious)
    // ===============================================================
    test('Panchaka Remainder (Day + Tithi + Nakshatra + Lagna) % 9 classifies correctly', () {
      // Day values: Sun=1, Mon=2, Tue=3, Wed=4, Thu=5, Fri=6, Sat=7
      // Remainder 1: Mrityu
      // E.g. Sun(1) + Pratipada(1) + Ashwini(1) + Mesham(7) = 10 % 9 = 1
      var p = engine.evaluatePanchaka(weekdayNum: 7, tithiNum: 1, nakIdx: 0, lagnaRasi: 6);
      expect(p.remainder, 1);
      expect(p.typeName, 'மிருத்யு பஞ்சகம்');
      expect(p.isGood, isFalse);

      // Remainder 2: Agni
      // E.g. Sun(1) + Pratipada(1) + Ashwini(1) + Mesham(8) = 11 % 9 = 2
      p = engine.evaluatePanchaka(weekdayNum: 7, tithiNum: 1, nakIdx: 0, lagnaRasi: 7);
      expect(p.remainder, 2);
      expect(p.typeName, 'அக்னி பஞ்சகம்');
      expect(p.isGood, isFalse);

      // Remainder 3: Subha
      p = engine.evaluatePanchaka(weekdayNum: 7, tithiNum: 1, nakIdx: 0, lagnaRasi: 8);
      expect(p.remainder, 3);
      expect(p.typeName, 'சுப பஞ்சகம்');
      expect(p.isGood, isTrue);

      // Remainder 4: Raja
      p = engine.evaluatePanchaka(weekdayNum: 7, tithiNum: 1, nakIdx: 0, lagnaRasi: 9);
      expect(p.remainder, 4);
      expect(p.typeName, 'ராஜ பஞ்சகம்');
      expect(p.isGood, isFalse);

      // Remainder 5: Subha
      p = engine.evaluatePanchaka(weekdayNum: 7, tithiNum: 1, nakIdx: 0, lagnaRasi: 10);
      expect(p.remainder, 5);
      expect(p.typeName, 'சுப பஞ்சகம்');
      expect(p.isGood, isTrue);

      // Remainder 6: Chora
      p = engine.evaluatePanchaka(weekdayNum: 7, tithiNum: 1, nakIdx: 0, lagnaRasi: 11);
      expect(p.remainder, 6);
      expect(p.typeName, 'சோர பஞ்சகம்');
      expect(p.isGood, isFalse);

      // Remainder 7: Subha
      p = engine.evaluatePanchaka(weekdayNum: 7, tithiNum: 1, nakIdx: 0, lagnaRasi: 3);
      expect(p.remainder, 7);
      expect(p.typeName, 'சுப பஞ்சகம்');
      expect(p.isGood, isTrue);

      // Remainder 8: Roga
      p = engine.evaluatePanchaka(weekdayNum: 7, tithiNum: 1, nakIdx: 0, lagnaRasi: 4);
      expect(p.remainder, 8);
      expect(p.typeName, 'ரோக பஞ்சகம்');
      expect(p.isGood, isFalse);

      // Remainder 0: Subha
      p = engine.evaluatePanchaka(weekdayNum: 7, tithiNum: 1, nakIdx: 0, lagnaRasi: 5);
      expect(p.remainder, 0);
      expect(p.typeName, 'சுப பஞ்சகம்');
      expect(p.isGood, isTrue);
    });

    // ===============================================================
    // 2. LAGNA SHUDDHI: 7TH, 8TH, 12TH HOUSES & ASHTAMA LAGNA
    // Malefics: Sun, Mars, Saturn, Rahu, Ketu
    // ===============================================================
    test('Lagna Shuddhi checks 7th, 8th, and 12th houses for malefics (Sun, Mars, Saturn, Rahu, Ketu)', () {
      // Lagna at 15° Mesha (0)
      const ascMesha = 15.0; // Mesha = 0

      // Case A: Malefic in 7th house (Thula = 6) -> Jamitra Dosham
      final planetsHouse7Afflicted = {
        'Sun': (longitude: 195.0, isRetrograde: false), // 195° = Thulam (7th from Mesha)
        'Mars': (longitude: 60.0, isRetrograde: false),  // Mithuna (3rd)
        'Saturn': (longitude: 90.0, isRetrograde: false),// Kadaga (4th)
        'Rahu': (longitude: 300.0, isRetrograde: false), // Kumbha (11th)
        'Ketu': (longitude: 120.0, isRetrograde: false), // Simha (5th)
      };
      final eval7 = engine.evaluateMuhurthaLagna(
        ascLong: ascMesha,
        planets: planetsHouse7Afflicted,
      );
      expect(eval7.house7Checked, isFalse);
      expect(eval7.isClean, isFalse);
      expect(eval7.papaGrahaViolations.any((v) => v.contains('7-ம் இடத்தில்')), isTrue);

      // Case B: Malefic in 8th house (Viruchigam = 7) -> Ashtama Dosham
      final planetsHouse8Afflicted = {
        'Sun': (longitude: 45.0, isRetrograde: false),   // Rishaba (2nd)
        'Mars': (longitude: 225.0, isRetrograde: false), // 225° = Viruchigam (8th from Mesha)
        'Saturn': (longitude: 90.0, isRetrograde: false),
        'Rahu': (longitude: 300.0, isRetrograde: false),
        'Ketu': (longitude: 120.0, isRetrograde: false),
      };
      final eval8 = engine.evaluateMuhurthaLagna(
        ascLong: ascMesha,
        planets: planetsHouse8Afflicted,
      );
      expect(eval8.house8Checked, isFalse);
      expect(eval8.isClean, isFalse);
      expect(eval8.papaGrahaViolations.any((v) => v.contains('8-ம் இடத்தில்')), isTrue);

      // Case C: Malefic in 12th house (Meenam = 11) -> Vyaya Dosham
      final planetsHouse12Afflicted = {
        'Sun': (longitude: 45.0, isRetrograde: false),
        'Mars': (longitude: 60.0, isRetrograde: false),
        'Saturn': (longitude: 345.0, isRetrograde: false), // 345° = Meenam (12th from Mesha)
        'Rahu': (longitude: 300.0, isRetrograde: false),
        'Ketu': (longitude: 120.0, isRetrograde: false),
      };
      final eval12 = engine.evaluateMuhurthaLagna(
        ascLong: ascMesha,
        planets: planetsHouse12Afflicted,
      );
      expect(eval12.house12Checked, isFalse);
      expect(eval12.isClean, isFalse);
      expect(eval12.papaGrahaViolations.any((v) => v.contains('12-ம் இடத்தில்')), isTrue);

      // Case D: Clean houses 7, 8, 12 -> Lagna Shuddhi passed
      final planetsClean = {
        'Sun': (longitude: 45.0, isRetrograde: false),   // 2nd
        'Mars': (longitude: 75.0, isRetrograde: false),  // 3rd
        'Saturn': (longitude: 105.0, isRetrograde: false), // 4th
        'Rahu': (longitude: 135.0, isRetrograde: false), // 5th
        'Ketu': (longitude: 315.0, isRetrograde: false), // 11th
      };
      final evalClean = engine.evaluateMuhurthaLagna(
        ascLong: ascMesha,
        planets: planetsClean,
      );
      expect(evalClean.house7Checked, isTrue);
      expect(evalClean.house8Checked, isTrue);
      expect(evalClean.house12Checked, isTrue);
      expect(evalClean.isClean, isTrue);

      // Case E: Ashtama Lagna from Birth Rasi
      // Native's birth Rasi: Kanni (5). 8th from Kanni = Mesham (0).
      final birthProfileKanni = BirthProfile(
        name: 'Seeker',
        birthDate: DateTime(1995, 1, 1),
        birthNakshatra: 12, // Hasta (Kanni)
        birthRasi: 5,       // Kanni
      );
      final evalAshtamaLagna = engine.evaluateMuhurthaLagna(
        ascLong: ascMesha, // Mesham (0), which is 8th from Kanni (5)
        planets: planetsClean,
        birthProfile: birthProfileKanni,
      );
      expect(evalAshtamaLagna.isClean, isFalse);
      expect(evalAshtamaLagna.papaGrahaViolations.any((v) => v.contains('அஷ்டம லக்னம்')), isTrue);
    });

    // ===============================================================
    // 3. TARA BALAM: INCLUSIVE COUNT MODULO 9
    // Unfavorable: 1 (Janma), 3 (Vipath), 5 (Pratyak), 7 (Vadha)
    // Favorable: 2 (Sampat), 4 (Kshema), 6 (Sadhaka), 8 (Mitra), 9 (Parama Mitra)
    // ===============================================================
    test('Tara Balam modulo 9 calculation correctly accepts and rejects', () {
      const birthNak = 0; // Ashwini

      // 1: Janma Tara (Ashwini -> Ashwini: dist 1 -> tara 1)
      var t = engine.evaluateTaraBala(birthNakshatra: birthNak, targetNakshatra: 0);
      expect(t.taraNumber, 1);
      expect(t.isAccepted, isFalse);

      // 2: Sampat Tara (Ashwini -> Bharani: dist 2 -> tara 2)
      t = engine.evaluateTaraBala(birthNakshatra: birthNak, targetNakshatra: 1);
      expect(t.taraNumber, 2);
      expect(t.isAccepted, isTrue);

      // 3: Vipath Tara (Ashwini -> Krittika: dist 3 -> tara 3)
      t = engine.evaluateTaraBala(birthNakshatra: birthNak, targetNakshatra: 2);
      expect(t.taraNumber, 3);
      expect(t.isAccepted, isFalse);

      // 4: Kshema Tara (Ashwini -> Rohini: dist 4 -> tara 4)
      t = engine.evaluateTaraBala(birthNakshatra: birthNak, targetNakshatra: 3);
      expect(t.taraNumber, 4);
      expect(t.isAccepted, isTrue);

      // 5: Pratyak Tara (Ashwini -> Mrigashira: dist 5 -> tara 5)
      t = engine.evaluateTaraBala(birthNakshatra: birthNak, targetNakshatra: 4);
      expect(t.taraNumber, 5);
      expect(t.isAccepted, isFalse);

      // 6: Sadhaka Tara (Ashwini -> Ardra: dist 6 -> tara 6)
      t = engine.evaluateTaraBala(birthNakshatra: birthNak, targetNakshatra: 5);
      expect(t.taraNumber, 6);
      expect(t.isAccepted, isTrue);

      // 7: Vadha Tara (Ashwini -> Punarvasu: dist 7 -> tara 7)
      t = engine.evaluateTaraBala(birthNakshatra: birthNak, targetNakshatra: 6);
      expect(t.taraNumber, 7);
      expect(t.isAccepted, isFalse);

      // 8: Mitra Tara (Ashwini -> Pushya: dist 8 -> tara 8)
      t = engine.evaluateTaraBala(birthNakshatra: birthNak, targetNakshatra: 7);
      expect(t.taraNumber, 8);
      expect(t.isAccepted, isTrue);

      // 9: Parama Mitra Tara (Ashwini -> Ashlesha: dist 9 -> tara 9)
      t = engine.evaluateTaraBala(birthNakshatra: birthNak, targetNakshatra: 8);
      expect(t.taraNumber, 9);
      expect(t.isAccepted, isTrue);
    });

    // ===============================================================
    // 4. CHANDRA BALAM: 2, 5, 9, 11 FAVORABLE & 8 CHANDRASHTAMA
    // ===============================================================
    test('Chandra Balam correctly identifies favorable positions and Chandrashtama', () {
      const birthRasi = 0; // Mesham

      // 2nd house (Rishaba: 45°) -> Favorable
      var cb = engine.evaluateChandraBala(birthRasi: birthRasi, moonLong: 45.0);
      expect(cb.relativeHouse, 2);
      expect(cb.isPreferred, isTrue);
      expect(cb.isChandrashtama, isFalse);

      // 5th house (Simha: 135°) -> Favorable
      cb = engine.evaluateChandraBala(birthRasi: birthRasi, moonLong: 135.0);
      expect(cb.relativeHouse, 5);
      expect(cb.isPreferred, isTrue);
      expect(cb.isChandrashtama, isFalse);

      // 8th house (Viruchigam: 225°) -> Chandrashtama!
      cb = engine.evaluateChandraBala(birthRasi: birthRasi, moonLong: 225.0);
      expect(cb.relativeHouse, 8);
      expect(cb.isChandrashtama, isTrue);
      expect(cb.isPreferred, isFalse);

      // 9th house (Dhanusu: 255°) -> Favorable
      cb = engine.evaluateChandraBala(birthRasi: birthRasi, moonLong: 255.0);
      expect(cb.relativeHouse, 9);
      expect(cb.isPreferred, isTrue);
      expect(cb.isChandrashtama, isFalse);

      // 11th house (Kumbha: 315°) -> Favorable
      cb = engine.evaluateChandraBala(birthRasi: birthRasi, moonLong: 315.0);
      expect(cb.relativeHouse, 11);
      expect(cb.isPreferred, isTrue);
      expect(cb.isChandrashtama, isFalse);
    });

    // ===============================================================
    // 5. GURU BALAM & SURYA BALAM
    // ===============================================================
    test('Guru Balam for women and Surya Balam for men evaluate relative to birth Rasi', () {
      const birthRasi = 0; // Mesham

      // Guru Balam: 2, 5, 7, 9, 11 are auspicious
      var gb = engine.evaluateGuruBala(birthRasi: birthRasi, jupiterLong: 135.0); // 5th (Simha)
      expect(gb.relativeHouse, 5);
      expect(gb.isAuspicious, isTrue);

      gb = engine.evaluateGuruBala(birthRasi: birthRasi, jupiterLong: 225.0); // 8th (Viruchigam)
      expect(gb.relativeHouse, 8);
      expect(gb.isAuspicious, isFalse);

      // Surya Balam: 3, 6, 10, 11 (Upachaya) are auspicious
      var sb = engine.evaluateSuryaBala(birthRasi: birthRasi, sunLong: 75.0); // 3rd (Mithuna)
      expect(sb.relativeHouse, 3);
      expect(sb.isAuspicious, isTrue);

      sb = engine.evaluateSuryaBala(birthRasi: birthRasi, sunLong: 45.0); // 2nd (Rishaba)
      expect(sb.relativeHouse, 2);
      expect(sb.isAuspicious, isFalse);
    });

    // ===============================================================
    // 6. TAMIL MONTH RESTRICTIONS
    // Generally avoided: Aadi (3), Purattasi (5), Margazhi (8), Maasi (10)
    // Generally favorable: Chithirai (0), Vaikasi (1), Avani (4), Aippasi (6), Karthigai (7), Thai (9), Panguni (11)
    // ===============================================================
    test('Tamil Month Restrictions include Aadi, Margazhi, Purattasi, and Maasi', () {
      final rules = SubhaMuhurthamRules.standard();

      // Avoided: Aadi(3), Purattasi(5), Margazhi(8), Maasi(10)
      expect(rules.avoidedTamilMonths.contains(3), isTrue);
      expect(rules.avoidedTamilMonths.contains(5), isTrue);
      expect(rules.avoidedTamilMonths.contains(8), isTrue);
      expect(rules.avoidedTamilMonths.contains(10), isTrue);

      // Favorable: Chithirai(0), Vaikasi(1), Avani(4), Aippasi(6), Karthigai(7), Thai(9), Panguni(11)
      expect(rules.avoidedTamilMonths.contains(0), isFalse);
      expect(rules.avoidedTamilMonths.contains(1), isFalse);
      expect(rules.avoidedTamilMonths.contains(4), isFalse);
      expect(rules.avoidedTamilMonths.contains(6), isFalse);
      expect(rules.avoidedTamilMonths.contains(7), isFalse);
      expect(rules.avoidedTamilMonths.contains(9), isFalse);
      expect(rules.avoidedTamilMonths.contains(11), isFalse);
    });

    // ===============================================================
    // 7. AMIRTHATHI YOGA: SUNRISE-TO-SUNRISE & MULTI-SEGMENT TESTS
    // Cases:
    // - One Nakshatra remains active throughout sunrise to next sunrise.
    // - One Nakshatra ends after sunrise and another begins during same Panchangam day.
    // - Two Nakshatra transitions occur within one sunrise-to-sunrise period.
    // - A Nakshatra transition occurs exactly at sunrise.
    // - A Nakshatra transition occurs exactly at next sunrise.
    // - The Yoga changes correctly according to weekday–Nakshatra mapping.
    // - The Yoga remains unchanged when weekday–Nakshatra mapping produces same classification.
    // ===============================================================
    test('Sunrise-to-sunrise Amirthathi Yoga calculation across transitions', () {
      final sunrise = DateTime(2026, 10, 24, 6, 0);
      final nextSunrise = DateTime(2026, 10, 25, 6, 0);

      // Calculate periods across the 24-hr window
      final periods = ProfessionalMuhurthaEngine.calculateSunriseToSunriseYogaPeriods(
        targetDate: DateTime(2026, 10, 24),
        sunrise: sunrise,
        nextSunrise: nextSunrise,
        panchangamWeekday: 6, // Saturday (சனி)
        utcOffsetHours: 5.5,
      );

      expect(periods.isNotEmpty, isTrue);
      // All periods must connect continuously from sunrise to nextSunrise
      expect(periods.first.startTime, equals(sunrise));
      expect(periods.last.endTime, equals(nextSunrise));

      for (int i = 0; i < periods.length - 1; i++) {
        expect(periods[i].endTime, equals(periods[i + 1].startTime));
      }
    });

    test('Amirthathi Yoga remains unchanged when Nakshatra transition produces same classification', () {
      // Saturday (6):
      // Nakshatra 0 (Ashwini) -> Siddha Yogam
      // Nakshatra 1 (Bharani) -> Siddha Yogam
      final yoga0 = ProfessionalMuhurthaEngine.calculateNamaYoga(6, 0);
      final yoga1 = ProfessionalMuhurthaEngine.calculateNamaYoga(6, 1);
      expect(yoga0, SubhaNamaYogaType.siddha);
      expect(yoga1, SubhaNamaYogaType.siddha);

      // When evaluateLevel1Day evaluates a day where both segments are Siddha Yogam,
      // the displayed yoga remains 'சித்தயோகம்' without spurious transition labels
      final l1 = engine.evaluateLevel1Day(
        date: DateTime(2026, 10, 24),
        sunLong: 210.0,
        moonLong: 5.0, // Ashwini
        category: MuhurthaCategory.generalSubha,
        rules: SubhaMuhurthamRules.standard(),
      );
      expect(l1.yoga.amirthathiYoga, equals('சித்தயோகம்'));
      expect(l1.yoga.nextYoga, isNull);
    });

    test('Amirthathi Yoga does not use or combine Sun-Moon yoga', () {
      final res = engine.calculate(
        date: DateTime(2026, 11, 4),
        location: location,
        category: MuhurthaCategory.generalSubha,
      );

      // Angas yogaName must equal Amirthathi Yoga, never Sun-Moon yoga
      expect(res.angas.yogaName, equals(res.angas.amirthathiYoga));
      expect(res.level1Day.yoga.yogaName, equals(res.level1Day.yoga.amirthathiYoga));

      // 4 classifications only
      final validLabels = [
        SubhaNamaYogaType.amirtha.tamilLabel,
        SubhaNamaYogaType.siddha.tamilLabel,
        SubhaNamaYogaType.marana.tamilLabel,
        SubhaNamaYogaType.prabalaArishta.tamilLabel,
      ];
      final matchesAny = validLabels.any((l) => res.angas.amirthathiYoga.contains(l));
      expect(matchesAny, isTrue);
    });

    // ===============================================================
    // 8. ABHIJIT MUHURTHAM DYNAMIC SOLAR-NOON CALCULATION
    // ===============================================================
    test('Abhijit Muhurtham is dynamically centered around local solar noon', () {
      final res = engine.calculate(
        date: DateTime(2026, 11, 4),
        location: location,
        category: MuhurthaCategory.generalSubha,
      );

      expect(res.abhijitMuhurtham, isNotNull);
      final abhijit = res.abhijitMuhurtham!;
      expect(abhijit.start.isBefore(res.solarNoon), isTrue);
      expect(abhijit.end.isAfter(res.solarNoon), isTrue);

      // Midpoint of Abhijit must coincide with solar noon within 1 minute
      final midMs = (abhijit.start.millisecondsSinceEpoch + abhijit.end.millisecondsSinceEpoch) ~/ 2;
      final mid = DateTime.fromMillisecondsSinceEpoch(midMs);
      expect(mid.difference(res.solarNoon).inMinutes.abs(), lessThanOrEqualTo(1));
    });

    // ===============================================================
    // 9. DATE RANGE SEARCH RUNS DYNAMICALLY WITHOUT SIDE EFFECTS
    // ===============================================================
    test('Date range search calculates independently for each date', () {
      final results = engine.searchDateRange(
        startDate: DateTime(2026, 11, 1),
        endDate: DateTime(2026, 11, 5),
        location: location,
        category: MuhurthaCategory.generalSubha,
      );

      expect(results.length, equals(5));
      for (final r in results) {
        expect(r.angas.amirthathiYoga, isNotEmpty);
        expect(r.level1Day.vaaram.weekdayName, isNotEmpty);
      }
    });

    // ===============================================================
    // 10. MORNING EVALUATION WINDOW & REGRESSION TEST: 11 NOVEMBER 2026
    // ===============================================================
    test('11 November 2026 evaluates Anusham at sunrise and detects transition to Kettai at 11:38 AM', () {
      final res = engine.calculate(
        date: DateTime(2026, 11, 11),
        location: location,
        category: MuhurthaCategory.generalSubha,
      );

      // Sunrise must be dynamically calculated (around 06:06 AM)
      expect(res.sunrise.hour, equals(6));
      expect(res.sunrise.minute, equals(6));

      // Prevailing Nakshatra at sunrise must be Anusham (index 16)
      expect(res.angas.nakshatraIndex, equals(16));
      expect(res.angas.nakshatraName, contains('அனுஷம்'));
      expect(res.angas.isNakshatraSuitable, isTrue);

      // Nakshatra transition must be detected before 12:00 PM (around 11:38 AM to Kettai)
      expect(res.angas.nakshatraTransitionTime, isNotNull);
      final transTime = res.angas.nakshatraTransitionTime!;
      expect(transTime.hour, equals(11));
      expect(transTime.minute, equals(38));
      expect(res.angas.nakshatraName, contains('பின் கேட்டை'));

      // Tithi at sunrise is Thuvithiyai (2), Karana is Kaulava, Yoga is Siddha Yoga
      expect(res.angas.tithiNumber, equals(2));
      expect(res.angas.isTithiPreferred, isTrue);
      expect(res.angas.isKaranaAuspicious, isTrue);
      expect(res.angas.isYogaAuspicious, isTrue);

      // Level 1 must pass based on morning sunrise priority
      expect(res.level1Day.isLevel1Passed, isTrue);
      expect(res.isGeneralDaySuitable, isTrue);

      // In searchDateRange, 11 Nov 2026 must be included as eligible
      final range = engine.searchDateRange(
        startDate: DateTime(2026, 11, 10),
        endDate: DateTime(2026, 11, 12),
        location: location,
        category: MuhurthaCategory.generalSubha,
      );
      final nov11 = range.firstWhere((r) => r.date.day == 11);
      expect(nov11.isGeneralDaySuitable, isTrue);
      expect(nov11.level1Day.isLevel1Passed, isTrue);
    });
  });
}
