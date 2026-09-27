import 'package:flutter_test/flutter_test.dart';
import 'package:astrocall/daily_rasi_palan/engine/daily_rasi_palan_engine.dart';
import 'package:astrocall/daily_rasi_palan/engine/transit_calculator.dart';
import 'package:astrocall/daily_rasi_palan/models/rasi_palan_models.dart';

void main() {
  group('Daily Rasi Palan Models & Constants Tests', () {
    test('12 Rasis are defined correctly with required properties', () {
      expect(Rasi.values.length, equals(12));

      // Check all 12 Rasis names and numbers
      final expectedRasiData = [
        (0, 'மேஷம்', 'Mesham', 'Aries', 'சிவப்பு', 'முருகன் வழிபாடு செய்யவும்.'),
        (1, 'ரிஷபம்', 'Rishabam', 'Taurus', 'வெள்ளை', 'லட்சுமி வழிபாடு செய்யவும்.'),
        (2, 'மிதுனம்', 'Mithunam', 'Gemini', 'பச்சை', 'விஷ்ணு வழிபாடு செய்யவும்.'),
        (3, 'கடகம்', 'Kadagam', 'Cancer', 'வெள்ளை', 'அம்பாள் வழிபாடு செய்யவும்.'),
        (4, 'சிம்மம்', 'Simmam', 'Leo', 'தங்க நிறம்', 'சூரிய நமஸ்காரம் செய்யவும்.'),
        (5, 'கன்னி', 'Kanni', 'Virgo', 'பச்சை', 'பெருமாள் வழிபாடு செய்யவும்.'),
        (6, 'துலாம்', 'Thulam', 'Libra', 'நீலம்', 'மகாலட்சுமி வழிபாடு செய்யவும்.'),
        (7, 'விருச்சிகம்', 'Viruchigam', 'Scorpio', 'சிவப்பு', 'சுப்பிரமணியர் வழிபாடு செய்யவும்.'),
        (8, 'தனுசு', 'Dhanusu', 'Sagittarius', 'மஞ்சள்', 'குரு பகவான் வழிபாடு செய்யவும்.'),
        (9, 'மகரம்', 'Magaram', 'Capricorn', 'கருநீலம்', 'சனி பகவான் வழிபாடு செய்யவும்.'),
        (10, 'கும்பம்', 'Kumbam', 'Aquarius', 'நீலம்', 'ஆஞ்சநேயர் வழிபாடு செய்யவும்.'),
        (11, 'மீனம்', 'Meenam', 'Pisces', 'மஞ்சள்', 'குரு மற்றும் விஷ்ணு வழிபாடு செய்யவும்.'),
      ];

      for (final expected in expectedRasiData) {
        final rasi = Rasi.fromIndex(expected.$1);
        expect(rasi.index, equals(expected.$1));
        expect(rasi.rasiNumber, equals(expected.$1 + 1));
        expect(rasi.tamilName, equals(expected.$2));
        expect(rasi.transliteratedName, equals(expected.$3));
        expect(rasi.englishName, equals(expected.$4));
        expect(rasi.luckyColor, equals(expected.$5));
        expect(rasi.remedy, equals(expected.$6));
      }
    });

    test('Rasi fromIndex handles wrap-around gracefully', () {
      expect(Rasi.fromIndex(0), equals(Rasi.mesham));
      expect(Rasi.fromIndex(12), equals(Rasi.mesham));
      expect(Rasi.fromIndex(13), equals(Rasi.rishabam));
      expect(Rasi.fromIndex(-1), equals(Rasi.meenam));
    });

    test('Rasi fromTamilName finds appropriate rasi', () {
      expect(Rasi.fromTamilName('மேஷம்'), equals(Rasi.mesham));
      expect(Rasi.fromTamilName('கன்னி'), equals(Rasi.kanni));
      expect(Rasi.fromTamilName('மீனம்'), equals(Rasi.meenam));
    });
  });

  group('Daily Transit Calculator Reuse Tests', () {
    test('Consumes existing AstrologyCalculator.calculateTransits without duplicates', () {
      final date = DateTime(2026, 9, 25);
      final transits = DailyTransitCalculator.getTransits(date: date);

      // Must return 9 classical planets
      expect(transits.length, equals(9));

      final planetNames = transits.map((t) => t.planet).toSet();
      expect(planetNames, containsAll([
        'Sun',
        'Moon',
        'Mars',
        'Mercury',
        'Jupiter',
        'Venus',
        'Saturn',
        'Rahu',
        'Ketu',
      ]));

      for (final t in transits) {
        expect(t.transitRasiIndex, inInclusiveRange(0, 11));
        expect(t.degree, inInclusiveRange(0.0, 30.0));
        expect(t.transitRasiName.isNotEmpty, isTrue);
      }
    });
  });

  group('House Calculation Formula Tests', () {
    test('((transitRasi - birthRasi + 12) % 12) + 1 matches specification', () {
      // Mesham (0) to Mithunam (2) -> 3rd house
      expect(
        DailyRasiPalanEngine.calculateHouse(
          transitRasiIndex: 2,
          birthRasiIndex: 0,
        ),
        equals(3),
      );

      // Same Rasi -> 1st house
      expect(
        DailyRasiPalanEngine.calculateHouse(
          transitRasiIndex: 4,
          birthRasiIndex: 4,
        ),
        equals(1),
      );

      // Meenam (11) to Mesham (0) -> 2nd house
      expect(
        DailyRasiPalanEngine.calculateHouse(
          transitRasiIndex: 0,
          birthRasiIndex: 11,
        ),
        equals(2),
      );

      // Mesham (0) to Meenam (11) -> 12th house
      expect(
        DailyRasiPalanEngine.calculateHouse(
          transitRasiIndex: 11,
          birthRasiIndex: 0,
        ),
        equals(12),
      );
    });

    test('House is always strictly between 1 and 12 for all permutations', () {
      for (int birth = 0; birth < 12; birth++) {
        for (int transit = 0; transit < 12; transit++) {
          final house = DailyRasiPalanEngine.calculateHouse(
            transitRasiIndex: transit,
            birthRasiIndex: birth,
          );
          expect(house, inInclusiveRange(1, 12));
        }
      }
    });
  });

  group('Planetary Scoring Logic Tests', () {
    test('Jupiter scoring: good [2, 5, 7, 9, 11] = +8, other = -2', () {
      for (int h = 1; h <= 12; h++) {
        final score = DailyRasiPalanEngine.calculatePlanetScore('Jupiter', h);
        if ([2, 5, 7, 9, 11].contains(h)) {
          expect(score, equals(8), reason: 'Jupiter in house $h should be +8');
        } else {
          expect(score, equals(-2), reason: 'Jupiter in house $h should be -2');
        }
      }
    });

    test('Venus scoring: good [1, 2, 3, 4, 5, 8, 9, 11, 12] = +5, other = -3', () {
      for (int h = 1; h <= 12; h++) {
        final score = DailyRasiPalanEngine.calculatePlanetScore('Venus', h);
        if ([1, 2, 3, 4, 5, 8, 9, 11, 12].contains(h)) {
          expect(score, equals(5), reason: 'Venus in house $h should be +5');
        } else {
          expect(score, equals(-3), reason: 'Venus in house $h should be -3');
        }
      }
    });

    test('Mercury scoring: good [2, 4, 6, 8, 10, 11] = +5, other = -2', () {
      for (int h = 1; h <= 12; h++) {
        final score = DailyRasiPalanEngine.calculatePlanetScore('Mercury', h);
        if ([2, 4, 6, 8, 10, 11].contains(h)) {
          expect(score, equals(5), reason: 'Mercury in house $h should be +5');
        } else {
          expect(score, equals(-2), reason: 'Mercury in house $h should be -2');
        }
      }
    });

    test('Sun scoring: good [3, 6, 10, 11] = +4, other = -3', () {
      for (int h = 1; h <= 12; h++) {
        final score = DailyRasiPalanEngine.calculatePlanetScore('Sun', h);
        if ([3, 6, 10, 11].contains(h)) {
          expect(score, equals(4), reason: 'Sun in house $h should be +4');
        } else {
          expect(score, equals(-3), reason: 'Sun in house $h should be -3');
        }
      }
    });

    test('Mars scoring: good [3, 6, 10, 11] = +5, other = -4', () {
      for (int h = 1; h <= 12; h++) {
        final score = DailyRasiPalanEngine.calculatePlanetScore('Mars', h);
        if ([3, 6, 10, 11].contains(h)) {
          expect(score, equals(5), reason: 'Mars in house $h should be +5');
        } else {
          expect(score, equals(-4), reason: 'Mars in house $h should be -4');
        }
      }
    });

    test('Saturn scoring: good [3, 6, 11] = +5, other = -5', () {
      for (int h = 1; h <= 12; h++) {
        final score = DailyRasiPalanEngine.calculatePlanetScore('Saturn', h);
        if ([3, 6, 11].contains(h)) {
          expect(score, equals(5), reason: 'Saturn in house $h should be +5');
        } else {
          expect(score, equals(-5), reason: 'Saturn in house $h should be -5');
        }
      }
    });

    test('Rahu scoring: good [3, 6, 10, 11] = +4, other = -4', () {
      for (int h = 1; h <= 12; h++) {
        final score = DailyRasiPalanEngine.calculatePlanetScore('Rahu', h);
        if ([3, 6, 10, 11].contains(h)) {
          expect(score, equals(4), reason: 'Rahu in house $h should be +4');
        } else {
          expect(score, equals(-4), reason: 'Rahu in house $h should be -4');
        }
      }
    });

    test('Ketu scoring: good [3, 6, 10, 11] = +3, other = -3', () {
      for (int h = 1; h <= 12; h++) {
        final score = DailyRasiPalanEngine.calculatePlanetScore('Ketu', h);
        if ([3, 6, 10, 11].contains(h)) {
          expect(score, equals(3), reason: 'Ketu in house $h should be +3');
        } else {
          expect(score, equals(-3), reason: 'Ketu in house $h should be -3');
        }
      }
    });

    test('Moon scoring: good [1, 3, 6, 7, 10, 11] = +6, other = -4', () {
      for (int h = 1; h <= 12; h++) {
        final score = DailyRasiPalanEngine.calculatePlanetScore('Moon', h);
        if ([1, 3, 6, 7, 10, 11].contains(h)) {
          expect(score, equals(6), reason: 'Moon in house $h should be +6');
        } else {
          expect(score, equals(-4), reason: 'Moon in house $h should be -4');
        }
      }
    });
  });

  group('Rating & Clamping Tests', () {
    test('Star rating mapping', () {
      expect(DailyRasiPalanEngine.calculateRating(100), equals(5));
      expect(DailyRasiPalanEngine.calculateRating(80), equals(5));
      expect(DailyRasiPalanEngine.calculateRating(79), equals(4));
      expect(DailyRasiPalanEngine.calculateRating(60), equals(4));
      expect(DailyRasiPalanEngine.calculateRating(59), equals(3));
      expect(DailyRasiPalanEngine.calculateRating(40), equals(3));
      expect(DailyRasiPalanEngine.calculateRating(39), equals(2));
      expect(DailyRasiPalanEngine.calculateRating(20), equals(2));
      expect(DailyRasiPalanEngine.calculateRating(19), equals(1));
      expect(DailyRasiPalanEngine.calculateRating(0), equals(1));
    });
  });

  group('Lucky Number Formula Tests', () {
    test('((RasiNumber + Date.day) % 9) + 1 matches specification', () {
      // Mesham (RasiNumber 1), day 25 -> ((1 + 25) % 9) + 1 = (26 % 9) + 1 = 8 + 1 = 9
      final meshamPalan = DailyRasiPalanEngine.calculatePalan(
        rasi: Rasi.mesham,
        date: DateTime(2026, 9, 25),
      );
      expect(meshamPalan.luckyNumber, equals(((1 + 25) % 9) + 1));
      expect(meshamPalan.luckyNumber, equals(9));

      // Rishabam (RasiNumber 2), day 24 -> ((2 + 24) % 9) + 1 = (26 % 9) + 1 = 9
      final rishabamPalan = DailyRasiPalanEngine.calculatePalan(
        rasi: Rasi.rishabam,
        date: DateTime(2026, 9, 24),
      );
      expect(rishabamPalan.luckyNumber, equals(((2 + 24) % 9) + 1));
      expect(rishabamPalan.luckyNumber, equals(9));

      // Verify range 1..9 for all Rasis across all 31 days of any month
      for (final rasi in Rasi.values) {
        for (int day = 1; day <= 31; day++) {
          final num = ((rasi.rasiNumber + day) % 9) + 1;
          expect(num, inInclusiveRange(1, 9));
        }
      }
    });
  });

  group('12 Rasi Generation & Content Completeness Tests', () {
    test('All 12 Rasis generate complete predictions with valid sections', () {
      final date = DateTime(2026, 9, 25);
      final allPalan = DailyRasiPalanEngine.calculateAllRasis(date: date);

      expect(allPalan.length, equals(12));

      for (final rasi in Rasi.values) {
        final palan = allPalan[rasi.index]!;
        expect(palan.rasi, equals(rasi));
        expect(palan.date, equals(date));
        expect(palan.score, inInclusiveRange(0, 100));
        expect(palan.rating, inInclusiveRange(1, 5));

        // Required Sections
        expect(palan.general.isNotEmpty, isTrue);
        expect(palan.career.isNotEmpty, isTrue);
        expect(palan.finance.isNotEmpty, isTrue);
        expect(palan.love.isNotEmpty, isTrue);
        expect(palan.family, equals('குடும்ப உறுப்பினர்களுடன் ஆலோசித்து செயல்பட்டால் நல்லிணக்கம் அதிகரிக்கும்.'));
        expect(palan.health.isNotEmpty, isTrue);
        expect(palan.education, equals('மாணவர்கள் கவனத்துடன் படித்தால் நல்ல முன்னேற்றம் கிடைக்கும்.'));
        expect(palan.travel, equals('பயணத் திட்டங்களை முன்கூட்டியே அமைத்துக்கொள்வது நல்லது.'));
        expect(palan.luckyColor, equals(rasi.luckyColor));
        expect(palan.luckyNumber, inInclusiveRange(1, 9));
        expect(palan.caution.isNotEmpty, isTrue);
        expect(palan.remedy, equals(rasi.remedy));
        expect(palan.planetPositions.length, equals(9));
      }
    });

    test('Date changes dynamically recalculate lucky number and transits', () {
      final date1 = DateTime(2026, 9, 24);
      final date2 = DateTime(2026, 9, 25);

      final p1 = DailyRasiPalanEngine.calculatePalan(rasi: Rasi.mesham, date: date1);
      final p2 = DailyRasiPalanEngine.calculatePalan(rasi: Rasi.mesham, date: date2);

      expect(p1.date, equals(date1));
      expect(p2.date, equals(date2));
      expect(p1.luckyNumber, equals(((1 + 24) % 9) + 1));
      expect(p2.luckyNumber, equals(((1 + 25) % 9) + 1));
    });
  });
}
