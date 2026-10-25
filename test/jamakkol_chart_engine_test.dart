import 'package:flutter_test/flutter_test.dart';
import 'package:astrocall/services/jamakkol_chart_engine.dart';
import 'package:astrocall/jamakkol_prasannam/engine/kavippu_calculator.dart';

void main() {
  group('JamakkolChartEngine Tests', () {
    test('Star and Pada calculation matches reference', () {
      // 1. Makaram 21° 56' (291° 56') -> திருவோணம் - 4
      final uRes = JamakkolChartEngine.getStarAndPada(291.933333);
      expect(uRes.star, equals('திருவோணம்'));
      expect(uRes.pada, equals(4));
      expect(uRes.formatted, equals('★ திருவோணம் - 4'));

      // 2. Mesham 0° 18' (0° 18') -> அஸ்வினி - 1
      final aRes = JamakkolChartEngine.getStarAndPada(0.3);
      expect(aRes.star, equals('அஸ்வினி'));
      expect(aRes.pada, equals(1));
      expect(aRes.formatted, equals('★ அஸ்வினி - 1'));

      // 3. Makaram 29° 41' (299° 41') -> அவிட்டம் - 2
      final kRes = JamakkolChartEngine.getStarAndPada(299.683333);
      expect(kRes.star, equals('அவிட்டம்'));
      expect(kRes.pada, equals(2));
      expect(kRes.formatted, equals('★ அவிட்டம் - 2'));
    });

    test('Live Reference Match: Sep 20, 2026 10:34:00 AM Chennai (User Screenshot)', () {
      final query = DateTime(2026, 9, 20, 10, 34, 0);
      final data = JamakkolChartEngine.calculate(
        queryTime: query,
        latitude: 13.08784,
        longitude: 80.27847,
        locationName: 'Chennai',
      );

      // Verify Jamam # 4 on Sunday
      expect(data.jamamNumber, equals(4));
      expect(data.weekdayNameEn, equals('Sunday'));
      expect(data.weekdayNameTa, equals('ஞாயிறு'));
      expect(data.isDay, isTrue);

      // Verify Udhayam (Makaram - திருவோணம் 3)
      expect(data.udhayam.rasiIndex, equals(9)); // Makaram
      expect(data.udhayam.starName, equals('திருவோணம்'));

      // Verify Aarudam (Thulam - விசாகம் 2)
      expect(data.aarudam.rasiIndex, equals(6)); // Thulam
      expect(data.aarudam.starName, equals('விசாகம்'));
      expect(data.aarudam.pada, equals(2));

      // Verify Kavippu (Simmam - மகம் 2)
      expect(data.kavippu.rasiIndex, equals(4)); // Simmam
      expect(data.kavippu.starName, equals('மகம்'));
      expect(data.kavippu.pada, equals(2));

      // Verify Outer Planets (approx 45° counter-clockwise ring, mapped to Ubhaya signs)
      final saturn = data.outerPlanets.firstWhere((p) => p.key == 'Saturn');
      expect(saturn.formattedDegree, equals("சனி 358° 00'"));

      final venus = data.outerPlanets.firstWhere((p) => p.key == 'Venus');
      expect(venus.formattedDegree, equals("சுக் 73° 00'")); // Rishabam 13° -> Mithunam 13° (73°)

      final mercury = data.outerPlanets.firstWhere((p) => p.key == 'Mercury');
      expect(mercury.formattedDegree, equals("புத 88° 00'"));

      final jupiter = data.outerPlanets.firstWhere((p) => p.key == 'Jupiter');
      expect(jupiter.formattedDegree, equals("குரு 163° 00'")); // Simham 13° -> Kanni 13° (163°)

      final mars = data.outerPlanets.firstWhere((p) => p.key == 'Mars');
      expect(mars.formattedDegree, equals("செவ் 178° 00'"));

      final sun = data.outerPlanets.firstWhere((p) => p.key == 'Sun');
      expect(sun.formattedDegree, equals("சூரி 253° 00'")); // Viruchigam 13° -> Dhanusu 13° (253°)

      final rahu = data.outerPlanets.firstWhere((p) => p.key == 'Rahu');
      expect(rahu.formattedDegree, equals("பாம்பு 268° 00'"));

      final moon = data.outerPlanets.firstWhere((p) => p.key == 'Moon');
      expect(moon.formattedDegree, equals("சந் 343° 00'")); // Kumbam 13° -> Meenam 13° (343°)

      // Verify Upagrahas on Sunday Day:
      final yama = data.upagrahas.firstWhere((u) => u.shortName == 'எம');
      expect(yama.rasiIndex, equals(8)); // Dhanusu

      final rahuKalam = data.upagrahas.firstWhere((u) => u.shortName == 'ரா.கா');
      expect(rahuKalam.rasiIndex, equals(0)); // Mesham

      final mandi = data.upagrahas.firstWhere((u) => u.shortName == 'மாந்');
      expect(mandi.rasiIndex, equals(10)); // Kumbam

      final mrityu = data.upagrahas.firstWhere((u) => u.shortName == 'மிருத்யு');
      expect(mrityu.rasiIndex, equals(4)); // Simmam

      final lagna = data.upagrahas.firstWhere((u) => u.shortName == 'லக்');
      expect(lagna.rasiIndex, equals(7)); // Viruchigam
    });

    test('Live Reference Match: Sep 19, 2026 04:45:32 PM Thiruvarur (jamakkolprasannam.com)', () {
      final query = DateTime(2026, 9, 19, 16, 45, 32);
      final data = JamakkolChartEngine.calculate(
        queryTime: query,
        latitude: 10.7661,
        longitude: 79.6384,
        locationName: 'Thiruvarur',
      );

      // Verify Jamam # 8 on Saturday
      expect(data.jamamNumber, equals(8));
      expect(data.weekdayNameEn, equals('Saturday'));
      expect(data.weekdayNameTa, equals('சனி'));

      // Verify Udhayam (Katakam - Ayilyam)
      expect(data.udhayam.rasiIndex, equals(3)); // Katakam
      expect(data.udhayam.starName, equals('ஆயில்யம்'));

      // Verify Aarudam (Makaram - Uthiradam)
      expect(data.aarudam.rasiIndex, equals(9)); // Makaram
      expect(data.aarudam.starName, equals('உத்திராடம்'));

      // Verify Kavippu (Viruchigam 26° 48', கேட்டை - 4)
      expect(data.kavippu.rasiIndex, equals(7)); // Viruchigam
      expect(data.kavippu.starName, equals('கேட்டை'));
      expect(data.kavippu.pada, equals(4));

      // Verify Outer Planets degrees match within 1.0° (mapped to Ubhaya signs)
      final saturn = data.outerPlanets.firstWhere((p) => p.key == 'Saturn');
      expect(saturn.absoluteLongitude, closeTo(67.23, 1.0)); // Rishabam 7° 14' -> Mithunam 7° 14' (67.23)

      final venus = data.outerPlanets.firstWhere((p) => p.key == 'Venus');
      expect(venus.absoluteLongitude, closeTo(82.23, 1.0)); // Mithunam 22° 14'

      final mercury = data.outerPlanets.firstWhere((p) => p.key == 'Mercury');
      expect(mercury.absoluteLongitude, closeTo(157.23, 1.0)); // Simham 7° 14' -> Kanni 7° 14' (157.23)

      final jupiter = data.outerPlanets.firstWhere((p) => p.key == 'Jupiter');
      expect(jupiter.absoluteLongitude, closeTo(172.23, 1.0)); // Kanni 22° 14'

      final mars = data.outerPlanets.firstWhere((p) => p.key == 'Mars');
      expect(mars.absoluteLongitude, closeTo(247.23, 1.0)); // Viruchigam 7° 14' -> Dhanusu 7° 14' (247.23)

      final sun = data.outerPlanets.firstWhere((p) => p.key == 'Sun');
      expect(sun.absoluteLongitude, closeTo(262.23, 1.0)); // Dhanusu 22° 14'

      final rahu = data.outerPlanets.firstWhere((p) => p.key == 'Rahu');
      expect(rahu.absoluteLongitude, closeTo(337.23, 1.0)); // Kumbam 7° 14' -> Meenam 7° 14' (337.23)

      final moon = data.outerPlanets.firstWhere((p) => p.key == 'Moon');
      expect(moon.absoluteLongitude, closeTo(352.23, 1.0)); // Meenam 22° 14'

      // Verify Upagrahas exist (Yamakandam, Rahu Kaalam, Maandi, Mrityu, Lagnam)
      expect(data.upagrahas.length, equals(5));
      expect(data.upagrahas.any((u) => u.shortName == 'எம'), isTrue);
      expect(data.upagrahas.any((u) => u.shortName == 'ரா.கா'), isTrue);
      expect(data.upagrahas.any((u) => u.shortName == 'மாந்'), isTrue);
      expect(data.upagrahas.any((u) => u.shortName == 'மிருத்யு'), isTrue);
      expect(data.upagrahas.any((u) => u.shortName == 'லக்'), isTrue);
    });

    test('Live Reference Match: Sep 19, 2026 07:39:41 PM Thiruvarur Night Jamam #2', () {
      final query = DateTime(2026, 9, 19, 19, 39, 41);
      final data = JamakkolChartEngine.calculate(
        queryTime: query,
        latitude: 10.7661,
        longitude: 79.6384,
        locationName: 'Thiruvarur',
      );

      // Verify Jamam # 2 on Saturday Night
      expect(data.jamamNumber, equals(2));
      expect(data.weekdayNameEn, equals('Saturday'));
      expect(data.weekdayNameTa, equals('சனி'));
      expect(data.isDay, isFalse);

      // Verify Udhayam (Thulam, சுவாதி)
      expect(data.udhayam.rasiIndex, equals(6)); // Thulam
      expect(data.udhayam.starName, equals('சுவாதி'));

      // Verify Aarudam (Viruchigam 28° 06', கேட்டை - 4)
      expect(data.aarudam.rasiIndex, equals(7)); // Viruchigam
      expect(data.aarudam.starName, equals('கேட்டை'));
      expect(data.aarudam.pada, equals(4));

      // Verify Kavippu (Mesham, அஸ்வினி - 1)
      expect(data.kavippu.rasiIndex, equals(0)); // Mesham
      expect(data.kavippu.starName, equals('அஸ்வினி'));
      expect(data.kavippu.pada, equals(1));

      // Verify 8 Outer Planets (mapped to Ubhaya signs)
      final saturn = data.outerPlanets.firstWhere((p) => p.key == 'Saturn');
      expect(saturn.rasiIndex, equals(11)); // Kumbam -> Meenam (330°-360°)
      expect(saturn.formattedDegree, equals("சனி 340° 09'"));

      final moon = data.outerPlanets.firstWhere((p) => p.key == 'Moon');
      expect(moon.rasiIndex, equals(8)); // Dhanusu (240°-270°)
      expect(moon.formattedDegree, equals("சந் 265° 09'"));

      final rahu = data.outerPlanets.firstWhere((p) => p.key == 'Rahu');
      expect(rahu.rasiIndex, equals(8)); // Viruchigam -> Dhanusu (240°-270°)
      expect(rahu.formattedDegree, equals("பாம்பு 250° 09'"));

      final sun = data.outerPlanets.firstWhere((p) => p.key == 'Sun');
      expect(sun.rasiIndex, equals(5)); // Kanni (150°-180°)
      expect(sun.formattedDegree, equals("சூரி 175° 09'"));

      final mars = data.outerPlanets.firstWhere((p) => p.key == 'Mars');
      expect(mars.rasiIndex, equals(5)); // Simmam -> Kanni (150°-180°)
      expect(mars.formattedDegree, equals("செவ் 160° 09'"));

      final jupiter = data.outerPlanets.firstWhere((p) => p.key == 'Jupiter');
      expect(jupiter.rasiIndex, equals(2)); // Mithunam (60°-90°)
      expect(jupiter.formattedDegree, equals("குரு 85° 09'"));

      final mercury = data.outerPlanets.firstWhere((p) => p.key == 'Mercury');
      expect(mercury.rasiIndex, equals(2)); // Rishabam -> Mithunam (60°-90°)
      expect(mercury.formattedDegree, equals("புத 70° 09'"));

      final venus = data.outerPlanets.firstWhere((p) => p.key == 'Venus');
      expect(venus.rasiIndex, equals(11)); // Meenam (330°-360°)
      expect(venus.formattedDegree, equals("சுக் 355° 09'"));

      // Verify Upagrahas on Saturday Night:
      final yama = data.upagrahas.firstWhere((u) => u.shortName == 'எம');
      expect(yama.rasiIndex, equals(3)); // Katakam

      final rahuKalam = data.upagrahas.firstWhere((u) => u.shortName == 'ரா.கா');
      expect(rahuKalam.rasiIndex, equals(8)); // Dhanusu

      final mandi = data.upagrahas.firstWhere((u) => u.shortName == 'மாந்');
      expect(mandi.rasiIndex, equals(1)); // Rishabam
      expect(mandi.degree, equals(26)); // 26° 25'

      final mrityu = data.upagrahas.firstWhere((u) => u.shortName == 'மிருத்யு');
      expect(mrityu.rasiIndex, equals(10)); // Kumbam
      expect(mrityu.degree, equals(8)); // 8° 25'
    });

    test('Live Reference Match: Sep 19, 2026 08:28:04 PM Chennai (Exact User Screenshot)', () {
      final query = DateTime(2026, 9, 19, 20, 28, 4);
      final data = JamakkolChartEngine.calculate(
        queryTime: query,
        latitude: 13.0827,
        longitude: 80.2707,
        locationName: 'Chennai',
      );

      // Verify Jamam # 2 on Saturday Night
      expect(data.jamamNumber, equals(2));
      expect(data.weekdayNameEn, equals('Saturday'));
      expect(data.weekdayNameTa, equals('சனி'));
      expect(data.isDay, isFalse);

      // Verify Udhayam (Viruchigam, அனுஷம் - 4)
      expect(data.udhayam.rasiIndex, equals(7)); // Viruchigam
      expect(data.udhayam.starName, equals('அனுஷம்'));

      // Verify Aarudam (Kanni 18° 23', அஸ்தம் - 3)
      expect(data.aarudam.rasiIndex, equals(5)); // Kanni
      expect(data.aarudam.starName, equals('அஸ்தம்'));
      expect(data.aarudam.pada, equals(3));
      expect(data.aarudam.degree, equals(18));

      // Verify Kavippu (Katakam 11° 36', பூசம் - 3)
      expect(data.kavippu.rasiIndex, equals(3)); // Katakam
      expect(data.kavippu.starName, equals('பூசம்'));
      expect(data.kavippu.pada, equals(3));
      expect(data.kavippu.degree, equals(11));

      // Verify 8 Outer Planets
      final saturn = data.outerPlanets.firstWhere((p) => p.key == 'Saturn');
      expect(saturn.absoluteLongitude, closeTo(285.98, 0.1));

      final moon = data.outerPlanets.firstWhere((p) => p.key == 'Moon');
      expect(moon.absoluteLongitude, closeTo(240.98, 0.1));

      final rahu = data.outerPlanets.firstWhere((p) => p.key == 'Rahu');
      expect(rahu.absoluteLongitude, closeTo(195.98, 0.1));

      final sun = data.outerPlanets.firstWhere((p) => p.key == 'Sun');
      expect(sun.absoluteLongitude, closeTo(150.98, 0.1));

      final mars = data.outerPlanets.firstWhere((p) => p.key == 'Mars');
      expect(mars.absoluteLongitude, closeTo(105.98, 0.1));

      final jupiter = data.outerPlanets.firstWhere((p) => p.key == 'Jupiter');
      expect(jupiter.absoluteLongitude, closeTo(60.98, 0.1));

      final mercury = data.outerPlanets.firstWhere((p) => p.key == 'Mercury');
      expect(mercury.absoluteLongitude, closeTo(15.98, 0.1));

      final venus = data.outerPlanets.firstWhere((p) => p.key == 'Venus');
      expect(venus.absoluteLongitude, closeTo(330.98, 0.1));
    });

    test('Validation scenario: Oct 02, 2026 09:30:29 AM Chennai', () {
      final query = DateTime(2026, 10, 2, 9, 30, 29);
      final data = JamakkolChartEngine.calculate(
        queryTime: query,
        latitude: 13.0827,
        longitude: 80.2707,
        locationName: 'Chennai',
      );

      expect(data.jamamNumber, equals(3));
      expect(data.weekdayNameEn, equals('Friday'));
      expect(data.aarudam.rasiIndex, equals(6)); // Thulam
    });

    group('Corrected Kavippu Calculation & Sun Veedhi Validation', () {
      test('Test Group 1: Sun Rasi in Mesha Veedhi group (e.g. Rishabam -> Mesham 1)', () {
        // Rishabam = 2, Mithunam = 3, Kadagam = 4, Simham = 5
        expect(KavippuCalculator.getSunVeedhiIndex(2), equals(1)); // Rishabam -> Mesham
        expect(KavippuCalculator.getSunVeedhiIndex(3), equals(1)); // Mithunam -> Mesham
        expect(KavippuCalculator.getSunVeedhiIndex(4), equals(1)); // Kadagam -> Mesham
        expect(KavippuCalculator.getSunVeedhiIndex(5), equals(1)); // Simham -> Mesham
        expect(KavippuCalculator.getSunVeedhiNameEn(1), equals('Mesham'));
      });

      test('Test Group 2: Sun Rasi in Rishabha Veedhi group (e.g. Kanni -> Rishabam 2)', () {
        // Kanni = 6, Thulam = 7, Meenam = 12, Mesham = 1
        expect(KavippuCalculator.getSunVeedhiIndex(6), equals(2)); // Kanni -> Rishabam
        expect(KavippuCalculator.getSunVeedhiIndex(7), equals(2)); // Thulam -> Rishabam
        expect(KavippuCalculator.getSunVeedhiIndex(12), equals(2)); // Meenam -> Rishabam
        expect(KavippuCalculator.getSunVeedhiIndex(1), equals(2)); // Mesham -> Rishabam
        expect(KavippuCalculator.getSunVeedhiNameEn(2), equals('Rishabam'));
      });

      test('Test Group 3: Sun Rasi in Mithuna Veedhi group (e.g. Dhanusu -> Mithunam 3)', () {
        // Viruchigam = 8, Dhanusu = 9, Magaram = 10, Kumbam = 11
        expect(KavippuCalculator.getSunVeedhiIndex(8), equals(3)); // Viruchigam -> Mithunam
        expect(KavippuCalculator.getSunVeedhiIndex(9), equals(3)); // Dhanusu -> Mithunam
        expect(KavippuCalculator.getSunVeedhiIndex(10), equals(3)); // Magaram -> Mithunam
        expect(KavippuCalculator.getSunVeedhiIndex(11), equals(3)); // Kumbam -> Mithunam
        expect(KavippuCalculator.getSunVeedhiNameEn(3), equals('Mithunam'));
      });

      test('All 12 Sun Rasis are covered exactly once with correct Veedhi mappings', () {
        final expectedVeedhis = {
          1: 2, // Mesham -> Rishabha Veedhi
          2: 1, // Rishabam -> Mesha Veedhi
          3: 1, // Mithunam -> Mesha Veedhi
          4: 1, // Kadagam -> Mesha Veedhi
          5: 1, // Simham -> Mesha Veedhi
          6: 2, // Kanni -> Rishabha Veedhi
          7: 2, // Thulam -> Rishabha Veedhi
          8: 3, // Viruchigam -> Mithuna Veedhi
          9: 3, // Dhanusu -> Mithuna Veedhi
          10: 3, // Magaram -> Mithuna Veedhi
          11: 3, // Kumbam -> Mithuna Veedhi
          12: 2, // Meenam -> Rishabha Veedhi
        };

        for (int rasi = 1; rasi <= 12; rasi++) {
          expect(KavippuCalculator.getSunVeedhiIndex(rasi), equals(expectedVeedhis[rasi]));
        }
      });

      test('Circular case: Aarudham near Meenam (12) to Sun Veedhi Mesham (1) crosses Meenam -> Mesham', () {
        // Clockwise distance from 12 to 1 = ((1 - 12) + 12) % 12 = 1
        final dist = KavippuCalculator.calculateClockwiseDistance(
          aarudamRasi1: 12,
          sunVeedhiIndex: 1,
        );
        expect(dist, equals(1));

        // When Udhayam = Meenam (12), moving 1 step yields Mesham (1)
        final kavippuRasi1 = KavippuCalculator.calculateKavippuRasi1(
          udayamRasi1: 12,
          clockwiseDistance: dist,
        );
        expect(kavippuRasi1, equals(1)); // Mesham
      });

      test('Circular case: Mesham (1) to Meenam (12) boundary without off-by-one or negative index', () {
        // Clockwise distance from 1 to 12 = ((12 - 1) + 12) % 12 = 11
        final dist = KavippuCalculator.calculateClockwiseDistance(
          aarudamRasi1: 1,
          sunVeedhiIndex: 12,
        );
        expect(dist, equals(11));

        // When Udhayam = Mesham (1), moving 11 steps yields Meenam (12)
        final kavippuRasi1 = KavippuCalculator.calculateKavippuRasi1(
          udayamRasi1: 1,
          clockwiseDistance: dist,
        );
        expect(kavippuRasi1, equals(12)); // Meenam
      });

      test('Kavippu result is strictly normalized to 1..12 and 0-based rasiIndex in 0..11', () {
        for (int sun = 1; sun <= 12; sun++) {
          final veedhi = KavippuCalculator.getSunVeedhiIndex(sun);
          for (int aru = 1; aru <= 12; aru++) {
            final dist = KavippuCalculator.calculateClockwiseDistance(aarudamRasi1: aru, sunVeedhiIndex: veedhi);
            expect(dist, inInclusiveRange(0, 11));
            for (int udh = 1; udh <= 12; udh++) {
              final k1 = KavippuCalculator.calculateKavippuRasi1(udayamRasi1: udh, clockwiseDistance: dist);
              expect(k1, inInclusiveRange(1, 12));
              final k0 = k1 - 1;
              expect(k0, inInclusiveRange(0, 11));
            }
          }
        }
      });
    });
  });
}
