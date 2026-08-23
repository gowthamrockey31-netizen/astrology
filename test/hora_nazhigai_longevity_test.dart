import 'package:flutter_test/flutter_test.dart';
import 'package:astrocall/services/astrology_calculator.dart';
import 'package:astrocall/services/hora_calculator.dart';
import 'package:astrocall/services/nazhigai_calculator.dart';
import 'package:astrocall/services/longevity_calculator.dart';
import 'package:astrocall/models/longevity_result.dart';

void main() {
  group('HoraCalculator Unit Tests', () {
    test('Sunday sunrise starts with Sun Hora', () {
      // 2026-08-23 is Sunday. Sunrise at Chennai is ~06:05 AM IST.
      // Target time 06:15 AM IST (10 mins after sunrise)
      final sundaySunrise = DateTime(2026, 8, 23, 6, 15);
      final res = HoraCalculator.calculateHora(
        targetTime: sundaySunrise,
        latitude: 13.0827,
        longitude: 80.2707,
        utcOffsetHours: 5.5,
      );

      expect(res.currentHoraNameEn, equals('Sun'));
      expect(res.isDaytime, isTrue);
      expect(res.horaNumber, equals(1));
    });

    test('Monday sunrise starts with Moon Hora', () {
      // 2026-08-24 is Monday. Target time 06:15 AM IST (10 mins after sunrise)
      final mondaySunrise = DateTime(2026, 8, 24, 6, 15);
      final res = HoraCalculator.calculateHora(
        targetTime: mondaySunrise,
        latitude: 13.0827,
        longitude: 80.2707,
        utcOffsetHours: 5.5,
      );

      expect(res.currentHoraNameEn, equals('Moon'));
      expect(res.isDaytime, isTrue);
      expect(res.horaNumber, equals(1));
    });

    test('Midnight after sunset belongs to previous astrological day', () {
      // Tuesday 02:00 AM (before Tuesday sunrise 06:05 AM)
      // Belongs to Monday's cycle!
      final tuesdayEarlyAm = DateTime(2026, 8, 25, 2, 0);
      final res = HoraCalculator.calculateHora(
        targetTime: tuesdayEarlyAm,
        latitude: 13.0827,
        longitude: 80.2707,
        utcOffsetHours: 5.5,
      );

      expect(res.isDaytime, isFalse); // Nighttime Hora
      expect(res.dayRulerEn, equals('Moon')); // Monday ruler is Moon
    });
  });

  group('NazhigaiCalculator Unit Tests', () {
    final sunrise = DateTime(2026, 8, 20, 6, 0, 0);

    test('Event at exact sunrise returns 0 Nazhigai 0 Vinazhigai', () {
      final res = NazhigaiCalculator.calculateNazhigai(
        eventTime: sunrise,
        sunriseTime: sunrise,
      );

      expect(res.nazhigai, equals(0));
      expect(res.vinazhigai, equals(0));
    });

    test('Event at sunrise + 24 minutes returns 1 Nazhigai 0 Vinazhigai', () {
      final event = sunrise.add(const Duration(minutes: 24));
      final res = NazhigaiCalculator.calculateNazhigai(
        eventTime: event,
        sunriseTime: sunrise,
      );

      expect(res.nazhigai, equals(1));
      expect(res.vinazhigai, equals(0));
    });

    test('Event at sunrise + 48 minutes returns 2 Nazhigai 0 Vinazhigai', () {
      final event = sunrise.add(const Duration(minutes: 48));
      final res = NazhigaiCalculator.calculateNazhigai(
        eventTime: event,
        sunriseTime: sunrise,
      );

      expect(res.nazhigai, equals(2));
      expect(res.vinazhigai, equals(0));
    });

    test('Event at 14:30 (8h 30m elapsed = 510m) returns 21 Nazhigai 15 Vinazhigai', () {
      final event = DateTime(2026, 8, 20, 14, 30, 0);
      final res = NazhigaiCalculator.calculateNazhigai(
        eventTime: event,
        sunriseTime: sunrise,
      );

      expect(res.nazhigai, equals(21));
      expect(res.vinazhigai, equals(15));
      expect(res.formattedValueTa, equals('21 நாழிகை 15 விநாழிகை'));
    });
  });

  group('LongevityCalculator (Pindayu) Unit Tests', () {
    test('Calculates valid Pindayu longevity for benchmark horoscope', () {
      final benchmarkDt = DateTime(1987, 3, 11, 9, 50);
      final astroData = AstrologyCalculator.calculateHoroscope(
        dateOfBirth: benchmarkDt,
        latitude: 10.2785,
        longitude: 77.9244,
        utcOffsetHours: 5.5,
      );

      final longevity = LongevityCalculator.calculatePindayuLongevity(
        planets: astroData.planets,
        lagna: astroData.lagna,
      );

      expect(longevity.planetaryBreakdown.length, equals(7)); // 7 classical planets
      expect(longevity.totalBasicYears, greaterThan(50.0));
      expect(longevity.finalYears, greaterThan(0.0));
      expect(longevity.category, isNotNull);
    });

    test('Classifies Longevity categories correctly', () {
      final benchmarkDt = DateTime(1987, 3, 11, 9, 50);
      final astroData = AstrologyCalculator.calculateHoroscope(
        dateOfBirth: benchmarkDt,
        latitude: 10.2785,
        longitude: 77.9244,
        utcOffsetHours: 5.5,
      );

      final result = LongevityCalculator.calculatePindayuLongevity(
        planets: astroData.planets,
        lagna: astroData.lagna,
      );

      if (result.finalYears > 70) {
        expect(result.category, equals(LongevityCategory.deerghayu));
      } else if (result.finalYears >= 32) {
        expect(result.category, equals(LongevityCategory.madhyayu));
      } else {
        expect(result.category, equals(LongevityCategory.alpayu));
      }
    });
  });
}
