import 'package:flutter_test/flutter_test.dart';
import 'package:astrocall/modules/professional_muhurtha/professional_muhurtha.dart';

void main() {
  group('Subha Muhurtham Day Selection & Engine Tests', () {
    final engine = ProfessionalMuhurthaEngine();
    const location = GeoLocation(
      name: 'Chennai',
      latitude: 13.0827,
      longitude: 80.2707,
      timeZone: 5.5,
    );

    // ===============================================================
    // 1. WEEKDAY TESTS
    // ===============================================================
    group('1. Weekday Rules', () {
      final rules = SubhaMuhurthamRules.standard();

      test('Allowed weekdays (Sun, Mon, Wed, Thu, Fri) are suitable', () {
        // Monday (1)
        expect(rules.allowedWeekdays.contains(1), isTrue);
        // Wednesday (3)
        expect(rules.allowedWeekdays.contains(3), isTrue);
        // Thursday (4)
        expect(rules.allowedWeekdays.contains(4), isTrue);
        // Friday (5)
        expect(rules.allowedWeekdays.contains(5), isTrue);
        // Sunday (7)
        expect(rules.allowedWeekdays.contains(7), isTrue);
      });

      test('Avoided weekdays (Tuesday, Saturday) are rejected', () {
        // Tuesday (2)
        expect(rules.allowedWeekdays.contains(2), isFalse);
        // Saturday (6)
        expect(rules.allowedWeekdays.contains(6), isFalse);
      });

      test('Valarpirai Sunday is identified as specially favourable', () {
        // 2026-05-17 is a Sunday with Shukla Paksha / Valarpirai
        final res = engine.calculate(
          date: DateTime(2026, 5, 17),
          location: location,
          category: MuhurthaCategory.generalSubha,
          rules: rules,
        );

        expect(res.level1Day.vaaram.weekdayNumber, equals(7));
        expect(res.level1Day.vaaram.isSuitable, isTrue);
        if (res.level1Day.tithi.paksha.contains('வளர்பிறை')) {
          expect(res.level1Day.vaaram.isValarpiraiSunday, isTrue);
          expect(res.level1Day.vaaram.reason, contains('வளர்பிறை ஞாயிற்றுக்கிழமை'));
        }
      });
    });

    // ===============================================================
    // 2. PANCHANGA COMBINATIONS & CONFLICT TESTS
    // ===============================================================
    group('2. Panchanga Combinations & Conflicts', () {
      test('Standard vs Extended preset handling for Tithi Conflict (Chaturthi, Shashti, Chaturdashi)', () {
        final stdRules = SubhaMuhurthamRules.standard();
        final extRules = SubhaMuhurthamRules.extended();

        // Chaturthi (4)
        expect(stdRules.allowedTithis.contains(4), isFalse);
        expect(stdRules.avoidedTithis.contains(4), isTrue);
        expect(extRules.allowedTithis.contains(4), isTrue);

        // Conflict note verification
        final conflictNote4 = SubhaMuhurthamRules.getTithiConflictNote(4);
        expect(conflictNote4, isNotNull);
        expect(conflictNote4, contains('சதுர்த்தி'));
        expect(conflictNote4, contains('Chaturthi'));

        // Shashti (6)
        expect(stdRules.allowedTithis.contains(6), isFalse);
        expect(extRules.allowedTithis.contains(6), isTrue);
        final conflictNote6 = SubhaMuhurthamRules.getTithiConflictNote(6);
        expect(conflictNote6, isNotNull);
        expect(conflictNote6, contains('சஷ்டி'));

        // Chaturdashi (14)
        expect(stdRules.allowedTithis.contains(14), isFalse);
        expect(extRules.allowedTithis.contains(14), isTrue);

        // Classical Favourable Tithis present in both (2, 3, 5, 7, 10, 11, 12, 13)
        for (final t in [2, 3, 5, 7, 10, 11, 12, 13]) {
          expect(stdRules.allowedTithis.contains(t), isTrue);
          expect(extRules.allowedTithis.contains(t), isTrue);
        }

        // Always avoided in both: Ashtami (8), Navami (9), Amavasya (30)
        for (final t in [8, 9, 30]) {
          expect(stdRules.avoidedTithis.contains(t), isTrue);
          expect(extRules.avoidedTithis.contains(t), isTrue);
        }
      });

      test('Standard vs Extended preset handling for Nakshatra Conflict (Chitra, Swati, Mula)', () {
        final stdRules = SubhaMuhurthamRules.standard();
        final extRules = SubhaMuhurthamRules.extended();

        // Chitra (13) and Swati (14)
        expect(stdRules.allowedNakshatras.contains(13), isTrue);
        expect(stdRules.allowedNakshatras.contains(14), isTrue);
        expect(extRules.allowedNakshatras.contains(13), isFalse);
        expect(extRules.allowedNakshatras.contains(14), isFalse);

        // Mula (18)
        expect(stdRules.allowedNakshatras.contains(18), isFalse);
        expect(extRules.allowedNakshatras.contains(18), isTrue);

        // Conflict note verification
        final conflictChitra = SubhaMuhurthamRules.getNakshatraConflictNote(13);
        expect(conflictChitra, contains('சித்திரை'));
        final conflictSwati = SubhaMuhurthamRules.getNakshatraConflictNote(14);
        expect(conflictSwati, contains('சுவாதி'));
        final conflictMula = SubhaMuhurthamRules.getNakshatraConflictNote(18);
        expect(conflictMula, contains('மூலம்'));

        // Common classical nakshatras in both (Rohini=3, Mrigashira=4, Pushya=7, Revati=26)
        for (final nak in [0, 3, 4, 6, 7, 11, 12, 16, 20, 21, 22, 23, 25, 26]) {
          expect(stdRules.allowedNakshatras.contains(nak), isTrue);
          expect(extRules.allowedNakshatras.contains(nak), isTrue);
        }
      });

      test('Yoga rule verification: Siddha & Amrita suitable, Marana avoided', () {
        final rules = SubhaMuhurthamRules.standard();

        expect(rules.allowedAmirthathiYogas.contains('சித்த யோகம்'), isTrue);
        expect(rules.allowedAmirthathiYogas.contains('அமிர்த யோகம்'), isTrue);
        expect(rules.avoidedAmirthathiYogas.contains('மரண யோகம்'), isTrue);
      });

      test('Karana rule verification: Bava, Balava, Kaulava, Taitula, Garaja, Vanija suitable, Vishti avoided', () {
        final rules = SubhaMuhurthamRules.standard();

        for (final k in ['பவ', 'பாலவ', 'கௌலவ', 'தைதுலை', 'கரசை', 'வணிசை']) {
          expect(rules.allowedKaranas.contains(k), isTrue);
        }
        for (final bad in ['பத்திரை', 'விஷ்டி', 'சகுனி', 'சதுஷ்பாதம்', 'நாகவம்', 'கிமிஸ்துக்னம்']) {
          expect(rules.avoidedKaranas.contains(bad), isTrue);
        }
      });
    });

    // ===============================================================
    // 3. AVOIDANCE RULES TESTS
    // ===============================================================
    group('3. Avoidance Rules', () {
      final rules = SubhaMuhurthamRules.standard();

      test('Month avoidance: Aadi (3), Purattasi (5), Margazhi (8)', () {
        expect(rules.avoidedTamilMonths.contains(3), isTrue); // Aadi
        expect(rules.avoidedTamilMonths.contains(5), isTrue); // Purattasi
        expect(rules.avoidedTamilMonths.contains(8), isTrue); // Margazhi

        expect(rules.avoidedTamilMonths.contains(1), isFalse); // Vaikasi is preferred
        expect(rules.avoidedTamilMonths.contains(9), isFalse); // Thai is preferred
      });

      test('Kari Naal check matches classical Tamil astrological dates', () {
        // Chithirai (0): 6, 15
        expect(rules.isKariDay(0, 6), isTrue);
        expect(rules.isKariDay(0, 15), isTrue);
        expect(rules.isKariDay(0, 7), isFalse);

        // Vaikasi (1): 7, 16, 17
        expect(rules.isKariDay(1, 7), isTrue);
        expect(rules.isKariDay(1, 16), isTrue);
        expect(rules.isKariDay(1, 17), isTrue);
        expect(rules.isKariDay(1, 4), isFalse);

        // Aadi (3): 2, 10, 20
        expect(rules.isKariDay(3, 2), isTrue);
        expect(rules.isKariDay(3, 10), isTrue);
        expect(rules.isKariDay(3, 20), isTrue);
        expect(rules.isKariDay(3, 5), isFalse);
      });

      test('Inauspicious periods (Rahu, Yama, Gulikai) are correctly calculated', () {
        final res = engine.calculate(
          date: DateTime(2026, 5, 20),
          location: location,
          category: MuhurthaCategory.generalSubha,
        );

        final periodNames = res.inauspiciousPeriods.map((p) => p.name).toList();
        expect(periodNames.any((n) => n.contains('ராகு')), isTrue);
        expect(periodNames.any((n) => n.contains('எமகண்டம்')), isTrue);
        expect(periodNames.any((n) => n.contains('குளிகை')), isTrue);

        expect(res.level2Avoidance.rahuKalam.timingFormatted, isNotEmpty);
        expect(res.level2Avoidance.yamagandam.timingFormatted, isNotEmpty);
        expect(res.level2Avoidance.kuligai.timingFormatted, isNotEmpty);
      });
    });

    // ===============================================================
    // 4. PERSON-SPECIFIC JATHAGA TESTS
    // ===============================================================
    group('4. Person-Specific Jathaga Rules', () {
      test('Chandrashtama: Moon in 8th house from Janma Rasi marks day unsuitable', () {
        // Janma Rasi = Mesham (0). Moon in 8th house = Viruchigam (7).
        final chandraMatch = engine.evaluateChandraBala(
          birthRasi: 0,
          moonLong: 220.0, // Viruchigam (7 * 30 = 210°..240°)
        );

        expect(chandraMatch.relativeHouse, equals(8));
        expect(chandraMatch.isChandrashtama, isTrue);
        expect(chandraMatch.reason, contains('சந்திராஷ்டம தோஷம்'));

        // Normal Moon Rasi: Moon in 5th house = Simmam (4)
        final chandraGood = engine.evaluateChandraBala(
          birthRasi: 0,
          moonLong: 130.0, // Simmam (120°..150°)
        );
        expect(chandraGood.relativeHouse, equals(5));
        expect(chandraGood.isChandrashtama, isFalse);
        expect(chandraGood.isPreferred, isTrue);
      });

      test('Tarabalam: Cyclical calculation 1..9 from Janma Nakshatra', () {
        // Janma = Ashwini (0). Target = Rohini (3).
        // Distance = (3 - 0) + 1 = 4 -> Kshema Tara (4) -> Suitable!
        final tara4 = engine.evaluateTaraBala(
          birthNakshatra: 0,
          targetNakshatra: 3,
        );
        expect(tara4.taraNumber, equals(4));
        expect(tara4.taraName, equals('க்ஷேம தாரை'));
        expect(tara4.isAccepted, isTrue);

        // Janma = Ashwini (0). Target = Bharani (1).
        // Distance = (1 - 0) + 1 = 2 -> Sampat Tara (2) -> Suitable!
        final tara2 = engine.evaluateTaraBala(
          birthNakshatra: 0,
          targetNakshatra: 1,
        );
        expect(tara2.taraNumber, equals(2));
        expect(tara2.taraName, equals('சம்பத் தாரை'));
        expect(tara2.isAccepted, isTrue);

        // Janma = Ashwini (0). Target = Krittika (2).
        // Distance = (2 - 0) + 1 = 3 -> Vipat Tara (3) -> Avoid!
        final tara3 = engine.evaluateTaraBala(
          birthNakshatra: 0,
          targetNakshatra: 2,
        );
        expect(tara3.taraNumber, equals(3));
        expect(tara3.taraName, equals('விபத் தாரை'));
        expect(tara3.isAccepted, isFalse);
      });

      test('Guru Balam & Surya Balam evaluations', () {
        // Janma = Mesham (0). Guru in Dhanusu (8 * 30 = 240°..270°) -> 9th house (Bhagya) -> Auspicious!
        final guru = engine.evaluateGuruBala(birthRasi: 0, jupiterLong: 250.0);
        expect(guru.relativeHouse, equals(9));
        expect(guru.isAuspicious, isTrue);

        // Janma = Mesham (0). Guru in Kanni (5 * 30 = 150°..180°) -> 6th house -> Weak
        final guruWeak = engine.evaluateGuruBala(birthRasi: 0, jupiterLong: 160.0);
        expect(guruWeak.relativeHouse, equals(6));
        expect(guruWeak.isAuspicious, isFalse);

        // Surya Balam: Janma = Mesham (0). Sun in Makaram (9 * 30 = 270°..300°) -> 10th house (Upachaya) -> Auspicious!
        final surya = engine.evaluateSuryaBala(birthRasi: 0, sunLong: 280.0);
        expect(surya.relativeHouse, equals(10));
        expect(surya.isAuspicious, isTrue);
      });
    });

    // ===============================================================
    // 5. LEVEL 4: MUHURTHAM LAGNA & PAPA GRAHA TESTS
    // ===============================================================
    group('5. Muhurtham Lagna & Papa Grahas', () {
      test('Lagna Lord strength and 7th/8th house shuddhi inspection', () {
        // Lagna in Mesham (0). Lagna Lord is Mars.
        // Planets: Mars in 10th (Capricorn), Sun in 11th, Moon in 2nd, Jupiter in 9th,
        // Saturn in 11th, Rahu in 3rd, Ketu in 9th (Houses 7 and 8 are completely pure!)
        final planets = <String, ({double longitude, bool isRetrograde})>{
          'Sun': (longitude: 315.0, isRetrograde: false),
          'Moon': (longitude: 45.0, isRetrograde: false),
          'Mars': (longitude: 280.0, isRetrograde: false),    // 10th house (Exalted / Kendra)
          'Mercury': (longitude: 320.0, isRetrograde: false),
          'Jupiter': (longitude: 250.0, isRetrograde: false),
          'Venus': (longitude: 340.0, isRetrograde: false),
          'Saturn': (longitude: 310.0, isRetrograde: false),  // 11th house
          'Rahu': (longitude: 70.0, isRetrograde: false),     // 3rd house
          'Ketu': (longitude: 250.0, isRetrograde: false),    // 9th house
        };

        final eval = engine.evaluateMuhurthaLagna(
          ascLong: 15.0, // Mesham (0)
          planets: planets,
        );

        expect(eval.lagnaIndex, equals(0));
        expect(eval.lagnaLord, contains('Mars'));
        expect(eval.lagnaLordStrength, contains('Strong'));
        expect(eval.house7Checked, isTrue);
        expect(eval.house8Checked, isTrue);
        expect(eval.isClean, isTrue);
        expect(eval.marsCheck, contains('சுத்தி'));
        expect(eval.saturnCheck, contains('சுத்தி'));
      });

      test('Papa Graha in 7th or 8th house is flagged as dosha', () {
        // Lagna in Mesham (0). Mars placed in 7th house (Thulam: 180°..210°) -> Jamitra Dosha!
        final planetsAfflicted = <String, ({double longitude, bool isRetrograde})>{
          'Sun': (longitude: 0.0, isRetrograde: false),
          'Moon': (longitude: 45.0, isRetrograde: false),
          'Mars': (longitude: 195.0, isRetrograde: false), // In 7th house!
          'Mercury': (longitude: 0.0, isRetrograde: false),
          'Jupiter': (longitude: 0.0, isRetrograde: false),
          'Venus': (longitude: 0.0, isRetrograde: false),
          'Saturn': (longitude: 0.0, isRetrograde: false),
          'Rahu': (longitude: 0.0, isRetrograde: false),
          'Ketu': (longitude: 0.0, isRetrograde: false),
        };

        final eval = engine.evaluateMuhurthaLagna(
          ascLong: 15.0, // Mesham (0)
          planets: planetsAfflicted,
        );

        expect(eval.house7Checked, isFalse);
        expect(eval.isClean, isFalse);
        expect(eval.marsCheck, contains('தோஷம்'));
        expect(eval.house7Reason, contains('செவ்வாய்'));
      });
    });

    // ===============================================================
    // 6. DATE RANGE SEARCH TESTS (INDEPENDENT DAYS)
    // ===============================================================
    group('6. Date Range Search', () {
      test('processes each date independently across the range', () {
        final start = DateTime(2026, 5, 1);
        final end = DateTime(2026, 5, 7);

        final results = engine.searchDateRange(
          startDate: start,
          endDate: end,
          location: location,
          category: MuhurthaCategory.generalSubha,
          onlySuitable: false,
        );

        expect(results.length, equals(7));

        // Verify each date has its own independent calculations
        for (int i = 0; i < results.length; i++) {
          final expectedDate = DateTime(2026, 5, 1 + i, 12, 0);
          expect(results[i].date, equals(expectedDate));
          expect(results[i].level1Day, isNotNull);
          expect(results[i].level2Avoidance, isNotNull);
          expect(results[i].rules, isNotNull);
        }

        // Tithi or Moon Longitude changes day by day (never copies previous day)
        expect(results[0].angas.nakshatraIndex != results[4].angas.nakshatraIndex, isTrue);
      });
    });
  });
}
