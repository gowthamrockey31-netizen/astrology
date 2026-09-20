import 'package:flutter_test/flutter_test.dart';
import 'package:astrocall/kp_method_model_3/kp_method_model_3.dart';

void main() {
  group('KP Method — Model 3 Tests', () {
    late BirthData testBirth;

    setUp(() {
      testBirth = BirthData(
        dateTime: DateTime(1990, 8, 15, 14, 30),
        time: '02:30 PM',
        place: 'Chennai',
        latitude: 13.0827,
        longitude: 80.2707,
        timezone: 5.5,
      );
    });

    test('Helper formatters: kpDegree & kpDate', () {
      final degStr = kpDegree(24.2097);
      expect(degStr, contains('24°'));
      expect(degStr, contains("'"));

      final dateStr = kpDate(DateTime(2026, 9, 6));
      expect(dateStr, equals('06-09-2026'));
    });

    test('KPAstronomy calculations', () {
      final jd = KPAstronomy.getJulianDay(testBirth);
      expect(jd, greaterThan(2440000.0));

      final ayanamsa = KPAstronomy.getKPAyanamsa(jd);
      expect(ayanamsa, greaterThan(23.0));
      expect(ayanamsa, lessThan(25.0));

      final cusps = KPAstronomy.calculatePlacidusCusps(
        jd: jd,
        latitude: testBirth.latitude,
        longitude: testBirth.longitude,
        ayanamsa: ayanamsa,
      );
      expect(cusps.length, equals(12));
      for (final c in cusps) {
        expect(c, greaterThanOrEqualTo(0.0));
        expect(c, lessThan(360.0));
      }
    });

    test('KPNakshatraEngine: 4 tiers (Star, Sub, Sub-Sub, Sub-Sub-Sub)', () {
      // 0.0 degrees is Ashwini (Ketu star)
      expect(KPNakshatraEngine.getNakshatraIndex(0.0), equals(0));
      expect(KPNakshatraEngine.getStarLord(0.0), equals('Ketu'));

      final sub = KPNakshatraEngine.getSubLord(0.0);
      expect(KPConstants.planetsEn.contains(sub), isTrue);

      final subSub = KPNakshatraEngine.getSubSubLord(0.0);
      expect(KPConstants.planetsEn.contains(subSub), isTrue);

      final subSubSub = KPNakshatraEngine.getSubSubSubLord(0.0);
      expect(KPConstants.planetsEn.contains(subSubSub), isTrue);
    });

    test('CompleteKPModule execution & KPResult structure', () {
      final module = CompleteKPModule();
      final result = module.calculate(testBirth);

      expect(result.ascendantDegree, greaterThanOrEqualTo(0.0));
      expect(result.ascendantDegree, lessThan(360.0));
      expect(result.ascendantDegreeStr.isNotEmpty, isTrue);

      // 9 Planets
      expect(result.planetPositions.length, equals(9));
      for (final p in result.planetPositions) {
        expect(p.house, inInclusiveRange(1, 12));
        expect(p.starLord.isNotEmpty, isTrue);
        expect(p.subLord.isNotEmpty, isTrue);
        expect(p.subSubLord.isNotEmpty, isTrue);
        expect(p.subSubSubLord.isNotEmpty, isTrue);
      }

      // 12 Cusps
      expect(result.cusps.length, equals(12));
      for (final c in result.cusps) {
        expect(c.subSubSubLord.isNotEmpty, isTrue);
      }

      // Ruling Planets (5 tiers: ரா.அ, ந.அ, உ.அ, உ.உ, உ.உ.உ)
      expect(result.rulingPlanets.isNotEmpty, isTrue);
      final categories = result.rulingPlanets.map((r) => r.category).toSet();
      expect(categories.contains('ரா.அ'), isTrue);
      expect(categories.contains('ந.அ'), isTrue);
      expect(categories.contains('உ.அ'), isTrue);
      expect(categories.contains('உ.உ'), isTrue);
      expect(categories.contains('உ.உ.உ'), isTrue);

      // 12 Cusp Relations with Red/Blue houses
      expect(result.cuspRelations.length, equals(12));
      for (final cr in result.cuspRelations) {
        expect(cr.cuspNumber, inInclusiveRange(1, 12));
        expect(cr.starLord.isNotEmpty, isTrue);
        expect(cr.subLord.isNotEmpty, isTrue);
        // Lists should be initialized
        expect(cr.finalHouses, isA<List<int>>());
        expect(cr.redHouses, isA<List<int>>());
        expect(cr.blueHouses, isA<List<int>>());
      }

      // Dasha timeline
      expect(result.dashaPeriods.length, equals(9));
      expect(result.dashaPeriods.first.startDateFormatted.isNotEmpty, isTrue);
      expect(result.dashaPeriods.first.endDateFormatted.isNotEmpty, isTrue);
    });

    test('Birth Time Rectification tool', () {
      final rectResult = CompleteKPModule.rectifyBirthTime(testBirth);
      expect(rectResult.congruenceScore, greaterThan(0.0));
      expect(rectResult.rectifiedLagnaDegreeStr.isNotEmpty, isTrue);
      expect(rectResult.rectifiedSubLord.isNotEmpty, isTrue);
      expect(rectResult.explanationTa.isNotEmpty, isTrue);
      expect(rectResult.explanationEn.isNotEmpty, isTrue);
    });
  });
}
