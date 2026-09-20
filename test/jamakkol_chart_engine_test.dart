import 'package:flutter_test/flutter_test.dart';
import 'package:astrocall/services/jamakkol_chart_engine.dart';

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

      // Verify Outer Planets (approx 45° counter-clockwise ring)
      final saturn = data.outerPlanets.firstWhere((p) => p.key == 'Saturn');
      expect(saturn.formattedDegree, equals("சனி 358° 00'"));

      final venus = data.outerPlanets.firstWhere((p) => p.key == 'Venus');
      expect(venus.formattedDegree, equals("சுக் 43° 00'"));

      final mercury = data.outerPlanets.firstWhere((p) => p.key == 'Mercury');
      expect(mercury.formattedDegree, equals("புத 88° 00'"));

      final jupiter = data.outerPlanets.firstWhere((p) => p.key == 'Jupiter');
      expect(jupiter.formattedDegree, equals("குரு 133° 00'"));

      final mars = data.outerPlanets.firstWhere((p) => p.key == 'Mars');
      expect(mars.formattedDegree, equals("செவ் 178° 00'"));

      final sun = data.outerPlanets.firstWhere((p) => p.key == 'Sun');
      expect(sun.formattedDegree, equals("சூரி 223° 00'"));

      final rahu = data.outerPlanets.firstWhere((p) => p.key == 'Rahu');
      expect(rahu.formattedDegree, equals("பாம்பு 268° 00'"));

      final moon = data.outerPlanets.firstWhere((p) => p.key == 'Moon');
      expect(moon.formattedDegree, equals("சந் 313° 00'"));

      // Verify Upagrahas on Sunday Day:
      final yama = data.upagrahas.firstWhere((u) => u.shortName == 'எம');
      expect(yama.rasiIndex, equals(5)); // Kanni

      final rahuKalam = data.upagrahas.firstWhere((u) => u.shortName == 'ரா.கா');
      expect(rahuKalam.rasiIndex, equals(0)); // Mesham

      final mandi = data.upagrahas.firstWhere((u) => u.shortName == 'மாந்');
      expect(mandi.rasiIndex, equals(10)); // Kumbam

      final mrityu = data.upagrahas.firstWhere((u) => u.shortName == 'மிருத்யு');
      expect(mrityu.rasiIndex, equals(7)); // Viruchigam

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

      // Verify Kavippu (Simmam 26° 48', உத்திரம் - 1)
      expect(data.kavippu.rasiIndex, equals(4)); // Simmam
      expect(data.kavippu.pada, equals(1));

      // Verify Outer Planets degrees match within 1.0°
      final saturn = data.outerPlanets.firstWhere((p) => p.key == 'Saturn');
      expect(saturn.absoluteLongitude, closeTo(37.23, 1.0)); // Mesham 7° 14'

      final venus = data.outerPlanets.firstWhere((p) => p.key == 'Venus');
      expect(venus.absoluteLongitude, closeTo(82.23, 1.0)); // Mithunam 22° 14'

      final mercury = data.outerPlanets.firstWhere((p) => p.key == 'Mercury');
      expect(mercury.absoluteLongitude, closeTo(127.23, 1.0)); // Katakam 7° 14'

      final jupiter = data.outerPlanets.firstWhere((p) => p.key == 'Jupiter');
      expect(jupiter.absoluteLongitude, closeTo(172.23, 1.0)); // Kanni 22° 14'

      final mars = data.outerPlanets.firstWhere((p) => p.key == 'Mars');
      expect(mars.absoluteLongitude, closeTo(217.23, 1.0)); // Thulam 7° 14'

      final sun = data.outerPlanets.firstWhere((p) => p.key == 'Sun');
      expect(sun.absoluteLongitude, closeTo(262.23, 1.0)); // Dhanusu 22° 14'

      final rahu = data.outerPlanets.firstWhere((p) => p.key == 'Rahu');
      expect(rahu.absoluteLongitude, closeTo(307.23, 1.0)); // Makaram 7° 14'

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

      // Verify Kavippu (Rishabam, கார்த்திகை)
      expect(data.kavippu.rasiIndex, equals(1)); // Rishabam
      expect(data.kavippu.starName, equals('கார்த்திகை'));

      // Verify 8 Outer Planets
      final saturn = data.outerPlanets.firstWhere((p) => p.key == 'Saturn');
      expect(saturn.rasiIndex, equals(10)); // Kumbam (300°-330°)
      expect(saturn.formattedDegree, equals("சனி 310° 09'"));

      final moon = data.outerPlanets.firstWhere((p) => p.key == 'Moon');
      expect(moon.rasiIndex, equals(8)); // Dhanusu (240°-270°)
      expect(moon.formattedDegree, equals("சந் 265° 09'"));

      final rahu = data.outerPlanets.firstWhere((p) => p.key == 'Rahu');
      expect(rahu.rasiIndex, equals(7)); // Viruchigam (210°-240°)
      expect(rahu.formattedDegree, equals("பாம்பு 220° 09'"));

      final sun = data.outerPlanets.firstWhere((p) => p.key == 'Sun');
      expect(sun.rasiIndex, equals(5)); // Kanni (150°-180°)
      expect(sun.formattedDegree, equals("சூரி 175° 09'"));

      final mars = data.outerPlanets.firstWhere((p) => p.key == 'Mars');
      expect(mars.rasiIndex, equals(4)); // Simmam (120°-150°)
      expect(mars.formattedDegree, equals("செவ் 130° 09'"));

      final jupiter = data.outerPlanets.firstWhere((p) => p.key == 'Jupiter');
      expect(jupiter.rasiIndex, equals(2)); // Mithunam (60°-90°)
      expect(jupiter.formattedDegree, equals("குரு 85° 09'"));

      final mercury = data.outerPlanets.firstWhere((p) => p.key == 'Mercury');
      expect(mercury.rasiIndex, equals(1)); // Rishabam (30°-60°)
      expect(mercury.formattedDegree, equals("புத 40° 09'"));

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
      expect(mrityu.rasiIndex, equals(4)); // Simmam
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
  });
}
