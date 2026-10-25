import 'package:flutter_test/flutter_test.dart';
import 'package:astrocall/jamakkol_prasannam/engine/jamakkol_engine.dart';
import 'package:astrocall/jamakkol_prasannam/models/jamakkol_models.dart';
import 'package:astrocall/jamakkol_prasannam/models/jamakkol_planet_models.dart';

void main() {
  group('Jamakkol Prasannam - Exact Reference Agreement Tests (Oct 18, 2026)', () {
    const location = JamakkolLocation(
      name: 'Chennai',
      latitude: 13.08784,
      longitude: 80.27847,
      timezone: 5.5,
    );

    test('Case 1: Daytime Sunday 11:19:27 AM (Jamam #4 [புதன்])', () {
      final dt = DateTime(2026, 10, 18, 11, 19, 27);
      final state = JamakkolEngine.calculateChart(queryDateTime: dt, location: location);

      // 1. Core Pillars
      expect(state.udayam.rasiIndex, equals(11)); // Meenam
      expect(state.udayam.nakshatraTa, equals('உத்தரட்டாதி'));
      expect(state.udayam.pada, equals(3));

      expect(state.arudam.rasiIndex, equals(3)); // Kadagam
      expect(state.kavippu.rasiIndex, equals(9)); // Makaram

      // 2. Upagrahas (Special Points)
      final mandi = state.upagrahas.firstWhere((u) => u.type == SpecialPointType.mandi);
      expect(mandi.rasiIndex, equals(11), reason: 'Mandi must be in Meenam (11) on Sunday day');
      expect(mandi.degreeInRasi, closeTo(6.64, 0.1));

      final mrityu = state.upagrahas.firstWhere((u) => u.type == SpecialPointType.mrityu);
      expect(mrityu.rasiIndex, equals(8), reason: 'Mrityu must be in Dhanusu (8) on Sunday day');
      expect(mrityu.degreeInRasi, closeTo(0.64, 0.1));

      final raKa = state.upagrahas.firstWhere((u) => u.type == SpecialPointType.rahuKaalam);
      expect(raKa.rasiIndex, equals(0), reason: 'Ra.Ka must be in Mesham (0) on Sunday day');

      final yama = state.upagrahas.firstWhere((u) => u.type == SpecialPointType.yamakandam);
      expect(yama.rasiIndex, equals(5), reason: 'Emakandam must be in Kanni (5) on Sunday day');

      final lagna = state.upagrahas.firstWhere((u) => u.type == SpecialPointType.lagna);
      expect(lagna.rasiIndex, equals(8), reason: 'Lagna must be in Dhanusu (8)');

      // 3. Outer Planets mapping to allowed Ubhaya signs
      final sun = state.jamakkolPlanets.firstWhere((p) => p.nameEn == 'Sun');
      expect(sun.rasiIndex, equals(6)); // Thulam
      expect(sun.absoluteLongitude, closeTo(200.27, 0.1));

      final saturn = state.jamakkolPlanets.firstWhere((p) => p.nameEn == 'Saturn');
      expect(saturn.rasiIndex, equals(11)); // Meenam
      expect(saturn.absoluteLongitude, closeTo(335.27, 0.1));
    });

    test('Case 2: Nighttime Sunday 06:43:26 PM (Jamam #1 [சுக்கிரன்])', () {
      final dt = DateTime(2026, 10, 18, 18, 43, 26);
      final state = JamakkolEngine.calculateChart(queryDateTime: dt, location: location);

      // 1. Core Pillars
      expect(state.udayam.rasiIndex, equals(6)); // Thulam
      expect(state.udayam.nakshatraTa, equals('விசாகம்'));
      expect(state.udayam.pada, equals(3));

      expect(state.arudam.rasiIndex, equals(8)); // Dhanusu
      expect(state.arudam.nakshatraTa, equals('பூராடம்'));
      expect(state.arudam.pada, equals(3));

      expect(state.kavippu.rasiIndex, equals(11)); // Meenam
      expect(state.kavippu.nakshatraTa, equals('உத்தரட்டாதி'));
      expect(state.kavippu.pada, equals(2));

      // 2. Upagrahas
      final mandi = state.upagrahas.firstWhere((u) => u.type == SpecialPointType.mandi);
      expect(mandi.rasiIndex, equals(2), reason: 'Mandi must be in Mithunam (2) on Sunday night');
      expect(mandi.degreeInRasi, closeTo(0.95, 0.1));

      final mrityu = state.upagrahas.firstWhere((u) => u.type == SpecialPointType.mrityu);
      expect(mrityu.rasiIndex, equals(4), reason: 'Mrityu must be in Simmam (4) on Sunday night');
      expect(mrityu.degreeInRasi, closeTo(12.95, 0.1));

      final raKa = state.upagrahas.firstWhere((u) => u.type == SpecialPointType.rahuKaalam);
      expect(raKa.rasiIndex, equals(0), reason: 'Ra.Ka must be in Mesham (0) on Sunday night');

      final yama = state.upagrahas.firstWhere((u) => u.type == SpecialPointType.yamakandam);
      expect(yama.rasiIndex, equals(5), reason: 'Emakandam must be in Kanni (5) on Sunday night');

      final lagna = state.upagrahas.firstWhere((u) => u.type == SpecialPointType.lagna);
      expect(lagna.rasiIndex, equals(0), reason: 'Lagna must be in Mesham (0)');
    });

    test('Case 3: Nighttime Sunday 07:07:20 PM (Jamam #1 [சுக்கிரன்])', () {
      final dt = DateTime(2026, 10, 18, 19, 7, 20);
      final state = JamakkolEngine.calculateChart(queryDateTime: dt, location: location);

      // 1. Core Pillars
      expect(state.udayam.rasiIndex, equals(7)); // Viruchigam
      expect(state.udayam.nakshatraTa, equals('அனுஷம்'));
      expect(state.udayam.pada, anyOf(equals(2), equals(3)));

      expect(state.arudam.rasiIndex, equals(1)); // Rishabam
      expect(state.arudam.nakshatraTa, equals('ரோகிணி'));
      expect(state.arudam.pada, equals(2));

      expect(state.kavippu.rasiIndex, equals(7)); // Viruchigam
      expect(state.kavippu.nakshatraTa, equals('அனுஷம்'));
      expect(state.kavippu.pada, equals(4));

      // 2. Upagrahas
      final mandi = state.upagrahas.firstWhere((u) => u.type == SpecialPointType.mandi);
      expect(mandi.rasiIndex, equals(2), reason: 'Mandi must be in Mithunam (2)');
      expect(mandi.degreeInRasi, closeTo(0.96, 0.1));

      final mrityu = state.upagrahas.firstWhere((u) => u.type == SpecialPointType.mrityu);
      expect(mrityu.rasiIndex, equals(4), reason: 'Mrityu must be in Simmam (4)');
      expect(mrityu.degreeInRasi, closeTo(12.96, 0.1));

      final raKa = state.upagrahas.firstWhere((u) => u.type == SpecialPointType.rahuKaalam);
      expect(raKa.rasiIndex, equals(0), reason: 'Ra.Ka must be in Mesham (0)');

      final yama = state.upagrahas.firstWhere((u) => u.type == SpecialPointType.yamakandam);
      expect(yama.rasiIndex, equals(5), reason: 'Emakandam must be in Kanni (5)');

      final lagna = state.upagrahas.firstWhere((u) => u.type == SpecialPointType.lagna);
      expect(lagna.rasiIndex, equals(0), reason: 'Lagna must be in Mesham (0)');
    });

    test('Case 4: Daytime Monday 07:22:00 AM (Jamam #1 [சந்திரன்])', () {
      final dt = DateTime(2026, 10, 12, 7, 22, 0);
      final state = JamakkolEngine.calculateChart(queryDateTime: dt, location: location);

      // 1. Core Pillars
      expect(state.udayam.rasiIndex, equals(7)); // Viruchigam
      expect(state.udayam.nakshatraTa, equals('அனுஷம்'));
      expect(state.udayam.pada, equals(1)); // Anusham-1

      expect(state.arudam.rasiIndex, equals(4)); // Simmam
      expect(state.arudam.nakshatraTa, equals('மகம்'));
      expect(state.arudam.pada, equals(4)); // Magam-4
      expect(state.arudam.degreeInRasi, closeTo(12.0, 0.05));

      expect(state.kavippu.rasiIndex, equals(4)); // Simmam
      expect(state.kavippu.nakshatraTa, equals('பூரம்'));
      expect(state.kavippu.pada, equals(2)); // Pooram-2
      expect(state.kavippu.degreeInRasi, closeTo(18.0, 0.05));

      // 2. Upagrahas
      final raKa = state.upagrahas.firstWhere((u) => u.type == SpecialPointType.rahuKaalam);
      expect(raKa.rasiIndex, equals(9), reason: 'Ra.Ka must be in Makaram (9) on Monday');
      expect(raKa.degreeInRasi, closeTo(24.53, 0.1));

      final yama = state.upagrahas.firstWhere((u) => u.type == SpecialPointType.yamakandam);
      expect(yama.rasiIndex, equals(6), reason: 'Emakandam must be in Thulam (6) on Monday');
      expect(yama.degreeInRasi, closeTo(24.53, 0.1));

      final mandi = state.upagrahas.firstWhere((u) => u.type == SpecialPointType.mandi);
      expect(mandi.rasiIndex, equals(10), reason: 'Mandi must be in Kumbam (10) on Monday');
      expect(mandi.degreeInRasi, closeTo(6.53, 0.1));

      final mrityu = state.upagrahas.firstWhere((u) => u.type == SpecialPointType.mrityu);
      expect(mrityu.rasiIndex, equals(7), reason: 'Mrityu must be in Viruchigam (7) on Monday');
      expect(mrityu.degreeInRasi, closeTo(0.53, 0.1));

      final lagna = state.upagrahas.firstWhere((u) => u.type == SpecialPointType.lagna);
      expect(lagna.rasiIndex, equals(6), reason: 'Lagna must be in Thulam (6)');

      // 3. Outer Planets Spacing
      final saturn = state.jamakkolPlanets.firstWhere((p) => p.nameEn == 'Saturn');
      expect(saturn.absoluteLongitude, closeTo(4.0, 0.1));

      final venus = state.jamakkolPlanets.firstWhere((p) => p.nameEn == 'Venus');
      expect(venus.absoluteLongitude, closeTo(49.0, 0.1));

      final mercury = state.jamakkolPlanets.firstWhere((p) => p.nameEn == 'Mercury');
      expect(mercury.absoluteLongitude, closeTo(94.0, 0.1));

      final jupiter = state.jamakkolPlanets.firstWhere((p) => p.nameEn == 'Jupiter');
      expect(jupiter.absoluteLongitude, closeTo(139.0, 0.1));

      final mars = state.jamakkolPlanets.firstWhere((p) => p.nameEn == 'Mars');
      expect(mars.absoluteLongitude, closeTo(184.0, 0.1));

      final sun = state.jamakkolPlanets.firstWhere((p) => p.nameEn == 'Sun');
      expect(sun.absoluteLongitude, closeTo(229.0, 0.1));

      final rahu = state.jamakkolPlanets.firstWhere((p) => p.nameEn == 'Rahu');
      expect(rahu.absoluteLongitude, closeTo(274.0, 0.1));

      final moon = state.jamakkolPlanets.firstWhere((p) => p.nameEn == 'Moon');
      expect(moon.absoluteLongitude, closeTo(319.0, 0.1));
    });

    test('Case 5: Tuesday Oct 20 2026 11:13:47 AM (Screenshot Verification)', () {
      final dt = DateTime(2026, 10, 20, 11, 13, 47);
      final state = JamakkolEngine.calculateChart(queryDateTime: dt, location: location);

      // 1. Core Pillars
      // In reference screenshot: Udayam in Meenam, Arudam in Mithunam, Kavippu in Kumbam
      expect(state.udayam.rasiIndex, equals(11)); // Meenam
      expect(state.arudam.rasiIndex, equals(2)); // Mithunam
      expect(state.kavippu.rasiIndex, equals(10)); // Kumbam

      // 2. Upagrahas (Special Points)
      // Mandi must be in Makaram (9) at 20° 37'
      final mandi = state.upagrahas.firstWhere((u) => u.type == SpecialPointType.mandi);
      expect(mandi.rasiIndex, equals(9), reason: 'Mandi must be in Makaram (9) on Tuesday daytime');
      expect(mandi.degreeInRasi, closeTo(20.62, 0.1));

      // Mrityu must be in Thulam (6) at 14° 37'
      final mrityu = state.upagrahas.firstWhere((u) => u.type == SpecialPointType.mrityu);
      expect(mrityu.rasiIndex, equals(6), reason: 'Mrityu must be in Thulam (6) on Tuesday daytime');
      expect(mrityu.degreeInRasi, closeTo(14.62, 0.1));

      // Ra.Ka in Mithunam (2) at 2° 37'
      final raKa = state.upagrahas.firstWhere((u) => u.type == SpecialPointType.rahuKaalam);
      expect(raKa.rasiIndex, equals(2), reason: 'Ra.Ka must be in Mithunam (2) on Tuesday daytime');
      expect(raKa.degreeInRasi, closeTo(2.62, 0.1));

      // Emakandam in Dhanusu (8) at 2° 37'
      final yama = state.upagrahas.firstWhere((u) => u.type == SpecialPointType.yamakandam);
      expect(yama.rasiIndex, equals(8), reason: 'Emakandam must be in Dhanusu (8) on Tuesday daytime');
      expect(yama.degreeInRasi, closeTo(2.62, 0.1));

      // 3. Tamil Month (Matham)
      expect(state.tamilMonth, equals('ஐப்பசி'));

      // 4. Outer Ring Planets (8 planets spaced at 45°)
      // Reference: சந் 337° 31', சனி 22° 31', சுக் 67° 31', புத 112° 31', குரு 157° 31', செவ் 202° 31', சூரி 247° 31', பாம்பு 292° 31'
      final moon = state.jamakkolPlanets.firstWhere((p) => p.nameEn == 'Moon');
      expect(moon.absoluteLongitude, closeTo(338.0, 1.0));
      expect(moon.rasiIndex, equals(11)); // Meenam

      final saturn = state.jamakkolPlanets.firstWhere((p) => p.nameEn == 'Saturn');
      expect(saturn.absoluteLongitude, closeTo(23.0, 1.0));
      expect(saturn.rasiIndex, equals(0)); // Mesham

      final venus = state.jamakkolPlanets.firstWhere((p) => p.nameEn == 'Venus');
      expect(venus.absoluteLongitude, closeTo(68.0, 1.0));
      expect(venus.rasiIndex, equals(2)); // Mithunam

      final mercury = state.jamakkolPlanets.firstWhere((p) => p.nameEn == 'Mercury');
      expect(mercury.absoluteLongitude, closeTo(113.0, 1.0));
      expect(mercury.rasiIndex, equals(3)); // Kadagam
    });

    test('Case 6: Tuesday Oct 20 2026 12:05:01 PM (User Request Verification)', () {
      final dt = DateTime(2026, 10, 20, 12, 5, 1);
      final state = JamakkolEngine.calculateChart(queryDateTime: dt, location: location);

      // At 12:05:01 PM (~51 min after 11:13:47 AM), Udayam progresses into Mesham (0)
      expect(state.udayam.rasiIndex, equals(0)); // Mesham
      expect(state.udayam.rasiNameTa, equals('மேஷம்'));

      // Mandi in Makaram (9)
      final mandi = state.upagrahas.firstWhere((u) => u.type == SpecialPointType.mandi);
      expect(mandi.rasiIndex, equals(9));
      expect(mandi.rasiNameTa, equals('மகரம்'));

      // Mrityu in Thulam (6)
      final mrityu = state.upagrahas.firstWhere((u) => u.type == SpecialPointType.mrityu);
      expect(mrityu.rasiIndex, equals(6));
      expect(mrityu.rasiNameTa, equals('துலாம்'));

      // Tamil Month
      expect(state.tamilMonth, equals('ஐப்பசி'));
    });

    test('Case 7: Saturday Oct 24 2026 08:04:22 PM (Screenshot Reference Agreement)', () {
      final dt = DateTime(2026, 10, 24, 20, 4, 22);
      final state = JamakkolEngine.calculateChart(queryDateTime: dt, location: location);

      // 1. Core Pillars
      expect(state.udayam.rasiIndex, equals(8)); // Dhanusu
      expect(state.udayam.rasiNameTa, equals('தனுசு'));
      expect(state.udayam.nakshatraTa, equals('பூராடம்'));
      expect(state.udayam.pada, equals(1));

      expect(state.arudam.rasiIndex, equals(0)); // Mesham
      expect(state.arudam.rasiNameTa, equals('மேஷம்'));
      expect(state.arudam.nakshatraTa, equals('பரணி'));
      expect(state.arudam.pada, equals(4));

      expect(state.kavippu.rasiIndex, equals(9)); // Makaram
      expect(state.kavippu.rasiNameTa, equals('மகரம்'));
      expect(state.kavippu.nakshatraTa, equals('உத்திராடம்'));
      expect(state.kavippu.pada, equals(3));

      // 2. Upagrahas (Special Points)
      final mandi = state.upagrahas.firstWhere((u) => u.type == SpecialPointType.mandi);
      expect(mandi.rasiIndex, equals(3), reason: 'Mandi must be in Kadagam (3) on Saturday night');
      expect(mandi.rasiNameTa, equals('கடகம்'));
      expect(mandi.degreeInRasi, closeTo(0.95, 0.05));

      final mrityu = state.upagrahas.firstWhere((u) => u.type == SpecialPointType.mrityu);
      expect(mrityu.rasiIndex, equals(5), reason: 'Mrityu must be in Kanni (5) on Saturday night');
      expect(mrityu.rasiNameTa, equals('கன்னி'));
      expect(mrityu.degreeInRasi, closeTo(12.95, 0.05));

      final raKa = state.upagrahas.firstWhere((u) => u.type == SpecialPointType.rahuKaalam);
      expect(raKa.rasiIndex, equals(8), reason: 'Ra.Ka must be in Dhanusu (8)');
      expect(raKa.rasiNameTa, equals('தனுசு'));
      expect(raKa.degreeInRasi, closeTo(6.95, 0.05));

      final yama = state.upagrahas.firstWhere((u) => u.type == SpecialPointType.yamakandam);
      expect(yama.rasiIndex, equals(3), reason: 'Emakandam must be in Kadagam (3)');
      expect(yama.rasiNameTa, equals('கடகம்'));
      expect(yama.degreeInRasi, closeTo(6.95, 0.05));

      // 3. Rasi-level placement check (Cell 7 empty, Cell 8 has Mandi + Yama + Mars + Jupiter, Cell 9 has Ketu, Cell 10 has Mrityu)
      final cellMithunamSpecial = state.specialPointsByRasi[2] ?? [];
      final cellMithunamTransits = state.transitPlanetsByRasi[2] ?? [];
      expect(cellMithunamSpecial.isEmpty, isTrue, reason: 'Mithunam must have no special points');
      expect(cellMithunamTransits.isEmpty, isTrue, reason: 'Mithunam must have no transit planets');

      final cellKadagamSpecial = state.specialPointsByRasi[3] ?? [];
      final cellKadagamTransits = state.transitPlanetsByRasi[3] ?? [];
      expect(cellKadagamSpecial.any((p) => p.type == SpecialPointType.mandi), isTrue, reason: 'Kadagam must have Mandi');
      expect(cellKadagamSpecial.any((p) => p.type == SpecialPointType.yamakandam), isTrue, reason: 'Kadagam must have Emakandam');
      expect(cellKadagamTransits.any((p) => p.nameEn == 'Mars'), isTrue, reason: 'Kadagam must have Mars');
      expect(cellKadagamTransits.any((p) => p.nameEn == 'Jupiter'), isTrue, reason: 'Kadagam must have Jupiter');

      final cellSimhamSpecial = state.specialPointsByRasi[4] ?? [];
      final cellSimhamTransits = state.transitPlanetsByRasi[4] ?? [];
      expect(cellSimhamSpecial.isEmpty, isTrue, reason: 'Simham must have no special points (Mrityu moved to Kanni)');
      expect(cellSimhamTransits.map((p) => p.nameEn), contains('Ketu'));

      final cellKanniSpecial = state.specialPointsByRasi[5] ?? [];
      expect(cellKanniSpecial.any((p) => p.type == SpecialPointType.mrityu), isTrue, reason: 'Kanni must have Mrityu');

      // 4. Tamil Month & Sunrise
      expect(state.tamilMonth, equals('ஐப்பசி'));
      expect(state.sunrise.hour, equals(5));
      expect(state.sunrise.minute, equals(58));
    });
  });
}
