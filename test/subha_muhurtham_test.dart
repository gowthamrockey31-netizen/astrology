import 'package:flutter_test/flutter_test.dart';
import 'package:astrocall/modules/professional_muhurtha/professional_muhurtha_models.dart';
import 'package:astrocall/modules/professional_muhurtha/professional_muhurtha_engine.dart';

void main() {
  late ProfessionalMuhurthaEngine engine;

  setUp(() {
    engine = ProfessionalMuhurthaEngine();
  });

  group('Panchanga Five Angas Rules', () {
    test('16 Classical Suitable Nakshatras rule', () {
      // Suitable Nakshatras (0-indexed):
      // Ashwini(0), Rohini(3), Mrigashirsha(4), Punarvasu(6), Pushya(7),
      // Uttara Phalguni(11), Hasta(12), Chitra(13), Swati(14), Anuradha(16),
      // Uttara Ashadha(20), Shravana(21), Dhanishta(22), Shatabhisha(23),
      // Uttara Bhadrapada(25), Revati(26).
      expect(ProfessionalMuhurthaEngine.suitableNakshatras.length, 16);
      expect(ProfessionalMuhurthaEngine.suitableNakshatras.contains(0), isTrue); // Ashwini
      expect(ProfessionalMuhurthaEngine.suitableNakshatras.contains(1), isFalse); // Bharani (avoided)
      expect(ProfessionalMuhurthaEngine.suitableNakshatras.contains(2), isFalse); // Krittika (avoided)
      expect(ProfessionalMuhurthaEngine.suitableNakshatras.contains(3), isTrue); // Rohini
      expect(ProfessionalMuhurthaEngine.suitableNakshatras.contains(7), isTrue); // Pushya
      expect(ProfessionalMuhurthaEngine.suitableNakshatras.contains(8), isFalse); // Ashlesha (avoided)
      expect(ProfessionalMuhurthaEngine.suitableNakshatras.contains(16), isTrue); // Anuradha
      expect(ProfessionalMuhurthaEngine.suitableNakshatras.contains(18), isFalse); // Mula (avoided)
      expect(ProfessionalMuhurthaEngine.suitableNakshatras.contains(26), isTrue); // Revati
    });

    test('Tithi evaluation preferred vs avoided', () {
      // Preferred: 2, 3, 5, 7, 10, 11, 12, 13
      // Avoided: 8, 9, 14, 15, 30
      // Date where Sun=0°, Moon=26° -> diff = 26° -> Tithi 3 (Tritiya)
      final angasTritiya = engine.evaluateFiveAngas(
        date: DateTime(2025, 4, 1),
        sunLong: 0.0,
        moonLong: 26.0, // (26 / 12) + 1 = 3 (Tritiya)
        category: MuhurthaCategory.generalSubha,
      );
      expect(angasTritiya.tithiNumber, 3);
      expect(angasTritiya.isTithiPreferred, isTrue);

      // Date where Sun=0°, Moon=88° -> diff = 88° -> Tithi 8 (Ashtami)
      final angasAshtami = engine.evaluateFiveAngas(
        date: DateTime(2025, 4, 1),
        sunLong: 0.0,
        moonLong: 88.0, // (88 / 12) + 1 = 8 (Ashtami)
        category: MuhurthaCategory.generalSubha,
      );
      expect(angasAshtami.tithiNumber, 8);
      expect(angasAshtami.isTithiPreferred, isFalse);

      // Amavasya (diff ~355°) -> Tithi 30
      final angasAmavasya = engine.evaluateFiveAngas(
        date: DateTime(2025, 4, 1),
        sunLong: 0.0,
        moonLong: 355.0, // (355 / 12) + 1 = 30 (Amavasya)
        category: MuhurthaCategory.generalSubha,
      );
      expect(angasAmavasya.tithiNumber, 30);
      expect(angasAmavasya.isTithiPreferred, isFalse);
    });

    test('Vara (Weekday) preferred vs avoided rules', () {
      // Monday = 1 (Preferred)
      final angasMon = engine.evaluateFiveAngas(
        date: DateTime(2025, 3, 24), // Monday
        sunLong: 340.0,
        moonLong: 280.0,
        category: MuhurthaCategory.generalSubha,
      );
      expect(angasMon.weekdayNumber, 1);
      expect(angasMon.isVaraPreferred, isTrue);

      // Tuesday = 2 (Avoided)
      final angasTue = engine.evaluateFiveAngas(
        date: DateTime(2025, 3, 25), // Tuesday
        sunLong: 341.0,
        moonLong: 295.0,
        category: MuhurthaCategory.generalSubha,
      );
      expect(angasTue.weekdayNumber, 2);
      expect(angasTue.isVaraPreferred, isFalse);

      // Wednesday = 3 (Preferred)
      final angasWed = engine.evaluateFiveAngas(
        date: DateTime(2025, 3, 26), // Wednesday
        sunLong: 342.0,
        moonLong: 310.0,
        category: MuhurthaCategory.generalSubha,
      );
      expect(angasWed.weekdayNumber, 3);
      expect(angasWed.isVaraPreferred, isTrue);

      // Saturday = 6 (Avoided)
      final angasSat = engine.evaluateFiveAngas(
        date: DateTime(2025, 3, 29), // Saturday
        sunLong: 345.0,
        moonLong: 350.0,
        category: MuhurthaCategory.generalSubha,
      );
      expect(angasSat.weekdayNumber, 6);
      expect(angasSat.isVaraPreferred, isFalse);
    });
  });

  group('Tara Bala Tests', () {
    test('Cyclical 1..9 calculation and correct accept/avoid status', () {
      // Birth Nakshatra: Ashwini (index 0)
      // Target: Ashwini (0) -> count = 1 -> Tara 1 (Janma) -> Avoid
      final t1 = engine.evaluateTaraBala(birthNakshatra: 0, targetNakshatra: 0);
      expect(t1.taraNumber, 1);
      expect(t1.taraName, 'ஜன்ம தாரை');
      expect(t1.isAccepted, isFalse);

      // Target: Bharani (1) -> count = 2 -> Tara 2 (Sampat) -> Accept
      final t2 = engine.evaluateTaraBala(birthNakshatra: 0, targetNakshatra: 1);
      expect(t2.taraNumber, 2);
      expect(t2.taraName, 'சம்பத் தாரை');
      expect(t2.isAccepted, isTrue);

      // Target: Krittika (2) -> count = 3 -> Tara 3 (Vipat) -> Avoid
      final t3 = engine.evaluateTaraBala(birthNakshatra: 0, targetNakshatra: 2);
      expect(t3.taraNumber, 3);
      expect(t3.taraName, 'விபத் தாரை');
      expect(t3.isAccepted, isFalse);

      // Target: Rohini (3) -> count = 4 -> Tara 4 (Kshema) -> Accept
      final t4 = engine.evaluateTaraBala(birthNakshatra: 0, targetNakshatra: 3);
      expect(t4.taraNumber, 4);
      expect(t4.taraName, 'க்ஷேம தாரை');
      expect(t4.isAccepted, isTrue);

      // Target: Mrigashirsha (4) -> count = 5 -> Tara 5 (Pratyak) -> Avoid
      final t5 = engine.evaluateTaraBala(birthNakshatra: 0, targetNakshatra: 4);
      expect(t5.taraNumber, 5);
      expect(t5.isAccepted, isFalse);

      // Target: Punarvasu (6) -> count = 7 -> Tara 7 (Vadha) -> Avoid
      final t7 = engine.evaluateTaraBala(birthNakshatra: 0, targetNakshatra: 6);
      expect(t7.taraNumber, 7);
      expect(t7.isAccepted, isFalse);

      // Target: Pushya (7) -> count = 8 -> Tara 8 (Mitra) -> Accept
      final t8 = engine.evaluateTaraBala(birthNakshatra: 0, targetNakshatra: 7);
      expect(t8.taraNumber, 8);
      expect(t8.taraName, 'மித்ர தாரை');
      expect(t8.isAccepted, isTrue);

      // Target: Ashlesha (8) -> count = 9 -> Tara 9 (Param Mitra) -> Accept
      final t9 = engine.evaluateTaraBala(birthNakshatra: 0, targetNakshatra: 8);
      expect(t9.taraNumber, 9);
      expect(t9.taraName, 'பரம மித்ர தாரை');
      expect(t9.isAccepted, isTrue);

      // Wrap around test:
      // Birth: Revati (26), Target: Ashwini (0) -> count = 2 -> Tara 2 (Sampat)
      final tWrap = engine.evaluateTaraBala(birthNakshatra: 26, targetNakshatra: 0);
      expect(tWrap.taraNumber, 2);
      expect(tWrap.isAccepted, isTrue);
    });
  });

  group('Chandra Bala & Chandrashtama Tests', () {
    test('Actual Moon Rasi relative house calculation', () {
      // Birth Rasi: Mesham (0)
      // Moon in Rishabam (long 45°) -> Rasi 1 -> relative house = 2 -> Preferred
      final cb2 = engine.evaluateChandraBala(birthRasi: 0, moonLong: 45.0);
      expect(cb2.relativeHouse, 2);
      expect(cb2.isPreferred, isTrue);
      expect(cb2.isChandrashtama, isFalse);

      // Moon in Simmam (long 130°) -> Rasi 4 -> relative house = 5 -> Preferred
      final cb5 = engine.evaluateChandraBala(birthRasi: 0, moonLong: 130.0);
      expect(cb5.relativeHouse, 5);
      expect(cb5.isPreferred, isTrue);
      expect(cb5.isChandrashtama, isFalse);

      // Moon in Viruchigam (long 220°) -> Rasi 7 -> relative house = 8 -> Chandrashtama!
      final cb8 = engine.evaluateChandraBala(birthRasi: 0, moonLong: 220.0);
      expect(cb8.relativeHouse, 8);
      expect(cb8.isChandrashtama, isTrue);
      expect(cb8.isPreferred, isFalse);
    });
  });

  group('Lagna Shuddhi & Ashtama Lagna Tests', () {
    test('Ashtama Lagna rejection from Birth Rasi', () {
      // Birth Rasi: Mesham (0). Candidate Lagna: Viruchigam (7) -> 8th house -> Ashtama Lagna!
      final lAshtama = engine.evaluateLagnaShuddhi(
        ascLong: 225.0, // Viruchigam (7)
        planets: {},
        birthProfile: BirthProfile(
          name: 'Test',
          birthDate: DateTime(1995, 1, 1),
          birthNakshatra: 0,
          birthRasi: 0, // Mesham
        ),
      );
      expect(lAshtama.isAshtamaLagna, isTrue);
      expect(lAshtama.isClean, isFalse);
    });

    test('Lagna Shuddhi malefic detection in 7th, 8th, 12th houses', () {
      // Candidate Lagna: Mesham (0°)
      // Malefic Saturn in Thulam (195° -> house 7)
      final planetsWithSaturnIn7th = {
        'Saturn': (longitude: 195.0, isRetrograde: false),
      };

      final lSaturn7 = engine.evaluateLagnaShuddhi(
        ascLong: 10.0, // Mesham
        planets: planetsWithSaturnIn7th,
        birthProfile: null,
      );
      expect(lSaturn7.isClean, isFalse);
      expect(lSaturn7.maleficPlanetsIn7812.any((s) => s.contains('7-ம்') && s.contains('சனி')), isTrue);
    });
  });

  group('Panchaka Dosha Tests', () {
    test('evaluatePanchaka % 9 rule evaluation', () {
      // weekdayNum: Monday=1 (dayVal = 1%7 + 1 = 2)
      // tithiNum: 3 (tithiVal = 3)
      // nakIdx: 3 (nakVal = 4)
      // lagnaRasi: 1 (lagnaVal = 2)
      // total = 2 + 3 + 4 + 2 = 11 % 9 = 2 -> Agni Panchaka (Bad)
      final p2 = engine.evaluatePanchaka(
        weekdayNum: 1, // Mon
        tithiNum: 3,
        nakIdx: 3,
        lagnaRasi: 1,
      );
      expect(p2.remainder, 2);
      expect(p2.typeName, 'அக்னி பஞ்சகம்');
      expect(p2.isGood, isFalse);

      // Subha Panchaka remainder 3
      // weekdayNum: 2 (Tue -> dayVal 3), tithiNum: 3, nakIdx: 3, lagnaRasi: 1 -> total 3+3+4+2 = 12 % 9 = 3
      final p3 = engine.evaluatePanchaka(
        weekdayNum: 2, // Tue
        tithiNum: 3,
        nakIdx: 3,
        lagnaRasi: 1,
      );
      expect(p3.remainder, 3);
      expect(p3.typeName, 'சுப பஞ்சகம்');
      expect(p3.isGood, isTrue);

      // Mrityu Panchaka remainder 1
      // weekdayNum: 7 (Sun -> dayVal 1), tithiNum: 3, nakIdx: 3, lagnaRasi: 1 -> total 1+3+4+2 = 10 % 9 = 1
      final p1 = engine.evaluatePanchaka(
        weekdayNum: 7, // Sun
        tithiNum: 3,
        nakIdx: 3,
        lagnaRasi: 1,
      );
      expect(p1.remainder, 1);
      expect(p1.typeName, 'மிருத்யு பஞ்சகம்');
      expect(p1.isGood, isFalse);
    });
  });

  group('Inauspicious Periods Calculation Tests', () {
    test('Rahu Kalam, Yamagandam, Gulikai, Visha Kadigai generation', () {
      final sunrise = DateTime(2025, 4, 1, 6, 0);
      final sunset = DateTime(2025, 4, 1, 18, 0);
      final periods = engine.calculateInauspiciousPeriods(
        sunrise: sunrise,
        sunset: sunset,
        weekday: 1, // Monday
        moonLong: 10.0, // Ashwini
      );

      final names = periods.map((p) => p.name).toList();
      expect(names.any((n) => n.contains('ராகுகாலம்')), isTrue);
      expect(names.any((n) => n.contains('எமகண்டம்')), isTrue);
      expect(names.any((n) => n.contains('குளிகை')), isTrue);
      expect(names.any((n) => n.contains('விஷ கடிகை')), isTrue);
      expect(names.any((n) => n.contains('சந்தியா')), isTrue);
    });
  });

  group('Month Restrictions & Masa Sunyam Tests', () {
    test('Month preferences: Aadi, Margazhi, Purattasi, Masi avoided', () {
      // 0: Chithirai -> preferred
      expect(ProfessionalMuhurthaEngine.tamilMonths[0], 'சித்திரை');
      // 3: Aadi -> avoided
      expect(ProfessionalMuhurthaEngine.tamilMonths[3], 'ஆடி');
      // 5: Purattasi -> avoided
      expect(ProfessionalMuhurthaEngine.tamilMonths[5], 'புரட்டாசி');
      // 8: Margazhi -> avoided
      expect(ProfessionalMuhurthaEngine.tamilMonths[8], 'மார்கழி');
      // 10: Masi -> avoided
      expect(ProfessionalMuhurthaEngine.tamilMonths[10], 'மாசி');
    });

    test('Month Sunya Rasis mapping', () {
      // Chithirai (0): Makaram (9)
      expect(ProfessionalMuhurthaEngine.monthSunyaRasiMap[0], [9]);
      // Vaikasi (1): Dhanusu (8), Meenam (11)
      expect(ProfessionalMuhurthaEngine.monthSunyaRasiMap[1], [8, 11]);
    });
  });

  group('Guru Bala & Surya Bala Tests', () {
    test('Guru Bala for Marriage (2, 5, 7, 9, 11)', () {
      // Birth Rasi: Mesham (0)
      // Jupiter in Rishabam (long 40°) -> 2nd house -> Auspicious
      final gb2 = engine.evaluateGuruBala(birthRasi: 0, jupiterLong: 40.0);
      expect(gb2.relativeHouse, 2);
      expect(gb2.isAuspicious, isTrue);

      // Jupiter in Simmam (long 130°) -> 5th house -> Auspicious
      final gb5 = engine.evaluateGuruBala(birthRasi: 0, jupiterLong: 130.0);
      expect(gb5.relativeHouse, 5);
      expect(gb5.isAuspicious, isTrue);

      // Jupiter in Mithunam (long 70°) -> 3rd house -> Inauspicious
      final gb3 = engine.evaluateGuruBala(birthRasi: 0, jupiterLong: 70.0);
      expect(gb3.relativeHouse, 3);
      expect(gb3.isAuspicious, isFalse);
    });

    test('Surya Bala (3, 6, 10, 11)', () {
      // Birth Rasi: Mesham (0)
      // Sun in Mithunam (long 70°) -> 3rd house -> Auspicious
      final sb3 = engine.evaluateSuryaBala(birthRasi: 0, sunLong: 70.0);
      expect(sb3.relativeHouse, 3);
      expect(sb3.isAuspicious, isTrue);

      // Sun in Kanni (long 160°) -> 6th house -> Auspicious
      final sb6 = engine.evaluateSuryaBala(birthRasi: 0, sunLong: 160.0);
      expect(sb6.relativeHouse, 6);
      expect(sb6.isAuspicious, isTrue);

      // Sun in Rishabam (long 40°) -> 2nd house -> Inauspicious
      final sb2 = engine.evaluateSuryaBala(birthRasi: 0, sunLong: 40.0);
      expect(sb2.relativeHouse, 2);
      expect(sb2.isAuspicious, isFalse);
    });
  });

  group('Full Engine Date-wise Calculation Test', () {
    test('calculate returns complete MuhurthaResult without errors', () {
      final res = engine.calculate(
        date: DateTime(2025, 5, 15),
        location: const GeoLocation(
          name: 'Chennai',
          latitude: 13.0827,
          longitude: 80.2707,
          timeZone: 5.5,
        ),
        category: MuhurthaCategory.marriage,
        birthProfile: BirthProfile(
          name: 'Ram',
          birthDate: DateTime(1995, 1, 1),
          birthNakshatra: 3, // Rohini
          birthRasi: 1, // Rishabam
        ),
      );

      expect(res.angas.tithiName, isNotEmpty);
      expect(res.angas.nakshatraName, isNotEmpty);
      expect(res.angas.yogaName, isNotEmpty);
      expect(res.angas.karanaName, isNotEmpty);
      expect(res.inauspiciousPeriods.length, greaterThanOrEqualTo(5));
      expect(res.abhijitMuhurtham, isNotNull);
      expect(res.taraBala, isNotNull);
      expect(res.chandraBala, isNotNull);
      expect(res.guruBala, isNotNull);
      expect(res.suryaBala, isNotNull);
      expect(res.summaryVerdict, isNotEmpty);
    });
  });
}
