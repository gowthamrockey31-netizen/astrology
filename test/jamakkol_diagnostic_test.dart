import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:astrocall/jamakkol_prasannam/engine/jamakkol_engine.dart';
import 'package:astrocall/jamakkol_prasannam/models/jamakkol_models.dart';
import 'package:astrocall/jamakkol_prasannam/models/jamakkol_planet_models.dart';

void main() {
  group('Jamakkol Prasannam Diagnostic & Regression Tests', () {
    const loc = JamakkolLocation.defaultChennai;

    test('Sunrise strictly displays 5:58 AM and downstream Jamam schedule matches', () {
      final dt = DateTime(2026, 10, 23, 22, 11, 0);
      final state = JamakkolEngine.calculateChart(queryDateTime: dt, location: loc);

      final sunriseFormatted = DateFormat('h:mm a').format(state.sunrise);
      expect(sunriseFormatted, equals('5:58 AM'));
      expect(state.sunrise.hour, equals(5));
      expect(state.sunrise.minute, equals(58));
      expect(state.sunrise.second, equals(0));
    });

    test('Diagnostic trace and verification for 23 October 2026 10:11 PM and multiple test cases', () {
      final testCases = [
        ('Case 1: 23 Oct 2026 10:11 PM (Friday Night)', DateTime(2026, 10, 23, 22, 11, 0)),
        ('Case 1b: 23 Oct 2026 7:52:40 PM (Screenshot)', DateTime(2026, 10, 23, 19, 52, 40)),
        ('Case 2: 23 Oct 2026 11:00 AM (Friday Day)', DateTime(2026, 10, 23, 11, 0, 0)),
        ('Case 3: 24 Oct 2026 11:00 AM (Saturday Day)', DateTime(2026, 10, 24, 11, 0, 0)),
        ('Case 4: 20 Oct 2026 11:13:47 AM (Tuesday Day)', DateTime(2026, 10, 20, 11, 13, 47)),
        ('Case 5: 20 Nov 2026 11:00 AM (Next Month)', DateTime(2026, 11, 20, 11, 0, 0)),
      ];

      for (final tc in testCases) {
        final dt = tc.$2;
        final state = JamakkolEngine.calculateChart(queryDateTime: dt, location: loc);

        final mandi = state.upagrahas.firstWhere((u) => u.type == SpecialPointType.mandi);
        final rahuTransit = state.transitPlanets.firstWhere((p) => p.nameEn == 'Rahu');
        final ketuTransit = state.transitPlanets.firstWhere((p) => p.nameEn == 'Ketu');
        final sunTransit = state.transitPlanets.firstWhere((p) => p.nameEn == 'Sun');
        final raKa = state.upagrahas.firstWhere((u) => u.type == SpecialPointType.rahuKaalam);

        // Verify sunrise is always 5:58 AM
        expect(state.sunrise.hour, equals(5));
        expect(state.sunrise.minute, equals(58));
        expect(DateFormat('h:mm a').format(state.sunrise), equals('5:58 AM'));

        expect(mandi.absoluteLongitude > 0, isTrue);
        expect(rahuTransit.absoluteLongitude > 0, isTrue);
        expect(ketuTransit.absoluteLongitude > 0, isTrue);
        expect(sunTransit.absoluteLongitude > 0, isTrue);
        expect(raKa.absoluteLongitude > 0, isTrue);
      }

      // Assert Case 1: 23 Oct 2026 10:11 PM
      final state1 = JamakkolEngine.calculateChart(queryDateTime: DateTime(2026, 10, 23, 22, 11, 0), location: loc);
      expect(state1.tamilMonth, equals('ஐப்பசி'));
      expect(state1.tamilDateFormatted, equals('ஐப்பசி - 6'));
      expect(DateFormat('h:mm a').format(state1.sunrise), equals('5:58 AM'));
      final mandi1 = state1.upagrahas.firstWhere((u) => u.type == SpecialPointType.mandi);
      expect(mandi1.rasiNameTa, equals('மிதுனம்')); // Gemini
      expect(mandi1.degreeInRasi, closeTo(24.06, 0.1));
      final rahu1 = state1.transitPlanets.firstWhere((p) => p.nameEn == 'Rahu');
      expect(rahu1.rasiNameTa, equals('கும்பம்')); // Aquarius
      expect(rahu1.degreeInRasi, closeTo(2.28, 0.1));
      final ketu1 = state1.transitPlanets.firstWhere((p) => p.nameEn == 'Ketu');
      expect(ketu1.rasiNameTa, equals('சிம்மம்')); // Leo
      expect(ketu1.degreeInRasi, closeTo(2.28, 0.1));
      expect(state1.udayam.rasiNameTa, equals('கும்பம்'));
      expect(state1.arudam.rasiNameTa, equals('மிதுனம்'));
      expect(state1.kavippu.rasiNameTa, equals('மகரம்'));

      // Assert Case 1b: 23 Oct 2026 7:52:40 PM (Screenshot input)
      final state1b = JamakkolEngine.calculateChart(queryDateTime: DateTime(2026, 10, 23, 19, 52, 40), location: loc);
      expect(state1b.udayam.rasiNameTa, equals('தனுசு'));
      expect(state1b.udayam.nakshatraTa, equals('மூலம்'));
      expect(state1b.udayam.pada, equals(3));
      expect(state1b.arudam.rasiNameTa, equals('கும்பம்'));
      expect(state1b.arudam.nakshatraTa, equals('சதயம்'));
      expect(state1b.arudam.pada, equals(3));
      expect(state1b.kavippu.rasiNameTa, equals('மீனம்'));
      expect(state1b.kavippu.nakshatraTa, equals('உத்தரட்டாதி'));
      expect(state1b.kavippu.pada, equals(4));

      // Assert Case 2: 23 Oct 2026 11:00 AM (Friday daytime)
      final state2 = JamakkolEngine.calculateChart(queryDateTime: DateTime(2026, 10, 23, 11, 0, 0), location: loc);
      expect(state2.tamilMonth, equals('ஐப்பசி'));
      final mandi2 = state2.upagrahas.firstWhere((u) => u.type == SpecialPointType.mandi);
      expect(mandi2.rasiNameTa, equals('துலாம்')); // Libra
      expect(mandi2.degreeInRasi, closeTo(11.60, 0.1));
      expect(mandi2.absoluteLongitude != mandi1.absoluteLongitude, isTrue);

      // Assert Case 3: 24 Oct 2026 11:00 AM (Saturday daytime)
      final state3 = JamakkolEngine.calculateChart(queryDateTime: DateTime(2026, 10, 24, 11, 0, 0), location: loc);
      final mandi3 = state3.upagrahas.firstWhere((u) => u.type == SpecialPointType.mandi);
      expect(mandi3.rasiNameTa, equals('கன்னி')); // Virgo
      expect(mandi3.degreeInRasi, closeTo(18.59, 0.1));

      // Assert Case 3b: 24 Oct 2026 8:04:22 PM (Saturday nighttime)
      final state3b = JamakkolEngine.calculateChart(queryDateTime: DateTime(2026, 10, 24, 20, 4, 22), location: loc);
      final mandi3b = state3b.upagrahas.firstWhere((u) => u.type == SpecialPointType.mandi);
      expect(mandi3b.rasiNameTa, equals('கடகம்')); // Cancer (0° 57')
      expect(mandi3b.degreeInRasi, closeTo(0.95, 0.1));
      final mrityu3b = state3b.upagrahas.firstWhere((u) => u.type == SpecialPointType.mrityu);
      expect(mrityu3b.rasiNameTa, equals('கன்னி')); // Virgo (12° 57')
      expect(mrityu3b.degreeInRasi, closeTo(12.95, 0.1));

      // Assert Case 4: 20 Oct 2026 11:13:47 AM (Tuesday daytime)
      final state4 = JamakkolEngine.calculateChart(queryDateTime: DateTime(2026, 10, 20, 11, 13, 47), location: loc);
      final mandi4 = state4.upagrahas.firstWhere((u) => u.type == SpecialPointType.mandi);
      expect(mandi4.rasiNameTa, equals('மகரம்')); // Capricorn
      expect(mandi4.degreeInRasi, closeTo(20.62, 0.1));

      // Assert Case 5: 20 Nov 2026 11:00 AM (Month transition)
      final state5 = JamakkolEngine.calculateChart(queryDateTime: DateTime(2026, 11, 20, 11, 0, 0), location: loc);
      expect(state5.tamilMonth, equals('கார்த்திகை'));
      expect(state5.tamilDateFormatted, equals('கார்த்திகை - 4'));

      // Assert repeatability: Re-running 23 Oct 2026 10:11 PM produces identical outputs
      final stateRepeat = JamakkolEngine.calculateChart(queryDateTime: DateTime(2026, 10, 23, 22, 11, 0), location: loc);
      final mandiRepeat = stateRepeat.upagrahas.firstWhere((u) => u.type == SpecialPointType.mandi);
      expect(mandiRepeat.absoluteLongitude, equals(mandi1.absoluteLongitude));
      expect(stateRepeat.tamilMonth, equals(state1.tamilMonth));
      expect(stateRepeat.udayam.absoluteLongitude, equals(state1.udayam.absoluteLongitude));
      expect(stateRepeat.arudam.absoluteLongitude, equals(state1.arudam.absoluteLongitude));
      expect(stateRepeat.kavippu.absoluteLongitude, equals(state1.kavippu.absoluteLongitude));
    });
  });
}
