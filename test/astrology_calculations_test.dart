import 'package:flutter_test/flutter_test.dart';
import 'package:astrocall/services/astrology_calculator.dart';
import 'package:astrocall/services/varga_calculator.dart';
import 'package:astrocall/services/yogi_calculator.dart';
import 'package:astrocall/services/planet_status_calculator.dart';
import 'package:astrocall/services/sevvai_dosham_calculator.dart';
import 'package:astrocall/services/rahu_ketu_dosham_calculator.dart';
import 'package:astrocall/services/aadhi_antha_nazhigai_calculator.dart';
import 'package:astrocall/services/dina_suddhi_calculator.dart';
import 'package:astrocall/services/kp_astrology_calculator.dart';
import 'package:astrocall/services/jamakol_arudam_calculator.dart';
import 'package:astrocall/services/bhrigu_nandi_nadi_calculator.dart';
import 'package:astrocall/services/numerology_calculator.dart';
import 'package:astrocall/models/varga_chart_model.dart';
import 'package:astrocall/models/numerology_model.dart';

void main() {
  group('1. Nakshatra & Pada Exact Calculation Tests', () {
    test('Ashwini Pada 1 to 4 boundary checks', () {
      final pada1 = AstrologyCalculator.calculateNakshatraPadaFromLongitude(1.0);
      expect(pada1['nakshatraIndex'], 0); // Ashwini
      expect(pada1['pada'], 1);

      final pada4 = AstrologyCalculator.calculateNakshatraPadaFromLongitude(12.5);
      expect(pada4['nakshatraIndex'], 0);
      expect(pada4['pada'], 4);
    });

    test('359.999° wrap around to Revati Pada 4 without index overflow', () {
      final revatiLast = AstrologyCalculator.calculateNakshatraPadaFromLongitude(359.999);
      expect(revatiLast['nakshatraIndex'], 26); // Revati
      expect(revatiLast['pada'], 4);
    });
  });

  group('2. Varga Divisional Charts (D1 to D60) Tests', () {
    test('D9 Navamsha and D10 Dasamsha calculations', () {
      final horoscope = AstrologyCalculator.calculateHoroscope(
        dateOfBirth: DateTime(1996, 6, 15, 8, 30),
        latitude: 13.0827,
        longitude: 80.2707,
        utcOffsetHours: 5.5,
      );

      final d9Result = VargaCalculator.calculateVarga(type: VargaType.d9, planets: horoscope.planets);
      expect(d9Result.planets.length, greaterThanOrEqualTo(9));
      expect(d9Result.type, VargaType.d9);

      final allVargas = VargaCalculator.calculateAllVargas(horoscope.planets);
      expect(allVargas.length, VargaType.values.length);
      expect(allVargas.containsKey(VargaType.d60), true);
    });
  });

  group('3. Yogi, Ava Yogi, and Anu Yogi Tests', () {
    test('Yogi point calculation and lordship', () {
      final yogi = YogiCalculator.calculateYogi(
        sunLongitude: 60.5,
        moonLongitude: 45.2,
      );

      expect(yogi.yogiPointLongitude, greaterThanOrEqualTo(0.0));
      expect(yogi.yogiPointLongitude, lessThan(360.0));
      expect(yogi.yogiPlanetTa.isNotEmpty, true);
      expect(yogi.avaYogiPlanetTa.isNotEmpty, true);
      expect(yogi.anuYogiPlanetTa.isNotEmpty, true);
    });
  });

  group('4. Planet Status (Combustion, Dignity, Debilitation)', () {
    test('Planet Status calculation', () {
      final horoscope = AstrologyCalculator.calculateHoroscope(
        dateOfBirth: DateTime(1996, 6, 15, 8, 30),
        latitude: 13.0827,
        longitude: 80.2707,
        utcOffsetHours: 5.5,
      );

      final statusReport = PlanetStatusCalculator.calculatePlanetStatuses(horoscope.planets);
      expect(statusReport.planetStatuses.isNotEmpty, true);
      expect(statusReport.planetStatuses.any((p) => p.nameTa == 'சூரியன்'), true);
    });
  });

  group('5. Sevvai & Rahu-Ketu Dosham Tests', () {
    test('Sevvai Dosham and Rahu-Ketu Dosham results', () {
      final horoscope = AstrologyCalculator.calculateHoroscope(
        dateOfBirth: DateTime(1996, 6, 15, 8, 30),
        latitude: 13.0827,
        longitude: 80.2707,
        utcOffsetHours: 5.5,
      );

      final sevvai = SevvaiDoshamCalculator.calculateSevvaiDosham(horoscope.planets);
      expect(sevvai.severityLevel.isNotEmpty, true);

      final rahuKetu = RahuKetuDoshamCalculator.calculateRahuKetuDosham(horoscope.planets);
      expect(rahuKetu.kalasarpaTypeTa.isNotEmpty, true);
    });
  });

  group('6. Aadhi, Andha, Parama Nazhigai & Dina Suddhi', () {
    test('Aadhi Antha Nazhigai progress and formatting', () {
      final res = AadhiAnthaNazhigaiCalculator.calculate(
        moonLongitude: 45.0,
        nakshatraNameTa: 'ரோகிணி',
      );
      expect(res.progressPercent, greaterThanOrEqualTo(0.0));
      expect(res.progressPercent, lessThanOrEqualTo(100.0));
      expect(res.paramaNazhigaiTotal, 60.0);
      expect(res.totalVinadi, 3600);
      expect(res.padaVinadi, 900.0);
    });

    test('Traditional Panchang Nakshatra duration conversion (Notebook example)', () {
      // Step-by-step mathematical validation from reference document:
      // Hours * 5 / 2 -> 25 * 5 / 2 = 125 / 2 = 62.5
      const int hours = 25;
      const double convertedHours = hours * 5 / 2;
      expect(convertedHours, 62.5);

      // Minutes * 5 / 2 -> 37 * 5 / 2 = 185 / 2 = 92.5
      const int minutes = 37;
      const double convertedMinutes = minutes * 5 / 2;
      expect(convertedMinutes, 92.5);

      // 25 hours 37 minutes -> 64 nazhigai 03 vinadi (3843 vinadi)
      final (nazhigai, vinadi, totalVinadi) = AadhiAnthaNazhigaiCalculator.convertDurationToNazhigai(
        hours: hours,
        minutes: minutes,
      );
      expect(nazhigai, 64);
      expect(vinadi, 3);
      // Smallest working unit: X * 60 + Y -> 64 * 60 + 03 = 3843
      expect(totalVinadi, 3843);

      // One-Pada duration: 3843 / 4 = 960.75
      final padaDuration = totalVinadi / 4.0;
      expect(padaDuration, 960.75);

      // Thiruvathirai 2nd pada calculation:
      // Elapsed 26 nazhigai 28 vinadi = 1588 vinadi
      final res = AadhiAnthaNazhigaiCalculator.calculateFromDuration(
        nakshatraNameTa: 'திருவாதிரை',
        durationHours: 25,
        durationMinutes: 37,
        elapsedNazhigai: 26,
        elapsedVinadi: 28,
        nakshatraStartTime: DateTime(2026, 1, 1, 22, 49),
        nakshatraEndTime: DateTime(2026, 1, 3, 0, 26),
      );
      expect(res.totalVinadi, 3843);
      expect(res.totalWorkingUnits, 3843);
      expect(res.padaVinadi, 3843 / 4.0); // 960.75
      expect(res.onePadaDuration, 960.75);
      expect(res.padaDurations.length, 4);
      expect(res.padaDurations, [960.75, 960.75, 960.75, 960.75]);
      expect(res.nazhigai, 64);
      expect(res.vinadi, 3);
      expect(res.originalDurationFormatted, '25 மணி 37 நிமிடம்');
      expect(res.convertedDurationFormatted, '64 நாழிகை 3 வினாடி');
      expect(res.aadhiVinadi, 1588);
      expect(res.andhaVinadi, 2255);
      expect(res.pada, 2); // 2nd pada (1588 > 960.75 and <= 1921.5)
      expect(res.paramaNazhigaiFormatted, '64 நாழிகை 3 வினாடி');
      expect(res.aadhiNazhigaiFormatted, '26 நாழிகை 28 வினாடி');
      expect(res.andhaNazhigaiFormatted, '37 நாழிகை 35 வினாடி');
    });

    test('Midnight crossing duration handling (Start: 10:49 PM, End: 12:26 AM next-next day)', () {
      final start = DateTime(2026, 6, 1, 22, 49); // 10:49 PM
      final end = DateTime(2026, 6, 3, 0, 26);   // 12:26 AM next-next day (25h 37m)

      final res = AadhiAnthaNazhigaiCalculator.calculate(
        moonLongitude: 67.5,
        nakshatraNameTa: 'திருவாதிரை',
        nakshatraStartTime: start,
        nakshatraEndTime: end,
      );

      expect(res.originalDuration, const Duration(hours: 25, minutes: 37));
      expect(res.nazhigai, 64);
      expect(res.vinadi, 3);
      expect(res.totalWorkingUnits, 3843);
      expect(res.onePadaDuration, 960.75);
      expect(res.paramaNazhigaiFormatted, '64 நாழிகை 3 வினாடி');
    });

    test('Dynamic Nakshatra timing and metrics calculation from birthDateTime', () {
      final birthDt = DateTime(1995, 8, 15, 8, 30);
      final res = AadhiAnthaNazhigaiCalculator.calculate(
        moonLongitude: 353.86,
        nakshatraNameTa: 'ரேவதி',
        birthDateTime: birthDt,
        utcOffsetHours: 5.5,
      );

      expect(res.nakshatraStartTime, isNotNull);
      expect(res.nakshatraEndTime, isNotNull);
      expect(res.originalDuration, isNotNull);
      expect(res.originalDuration!.inHours, greaterThanOrEqualTo(20));
      expect(res.originalDuration!.inHours, lessThanOrEqualTo(28));
      expect(res.nazhigai, greaterThan(50));
      expect(res.totalWorkingUnits, equals(res.nazhigai * 60 + res.vinadi));
      expect(res.onePadaDuration, equals(res.totalWorkingUnits / 4.0));
      expect(res.pada, 3); // Revati 3rd pada at 353.86°
      expect(res.progressPercent, greaterThan(0.0));
      expect(res.progressPercent, lessThan(100.0));
    });

    test('Dina Suddhi purity score calculation', () {
      final suddhi = DinaSuddhiCalculator.calculate(
        date: DateTime(2026, 8, 24, 10, 0),
        sunLongitude: 128.0,
        moonLongitude: 245.0,
        latitude: 13.0827,
        longitude: 80.2707,
        utcOffsetHours: 5.5,
      );
      expect(suddhi.weekdayTa.isNotEmpty, true);
      expect(suddhi.overallPurityScore.isNotEmpty, true);
    });
  });

  group('7. KP Astrology & KP Horary Sub-Lord Tests', () {
    test('KP Sub-Lord and Sub-Sub-Lord resolution', () {
      final lords = KpAstrologyCalculator.getStarSubSubSubLords(45.5);
      expect(lords['signLordTa']!.isNotEmpty, true);
      expect(lords['starLordTa']!.isNotEmpty, true);
      expect(lords['subLordTa']!.isNotEmpty, true);
      expect(lords['subSubLordTa']!.isNotEmpty, true);
    });

    test('KP 249 Horary Number mapping', () {
      final horaryAsc = KpAstrologyCalculator.getHoraryNumberAscendantLongitude(108);
      expect(horaryAsc, greaterThan(0.0));
      expect(horaryAsc, lessThan(360.0));
    });
  });

  group('8. Jamakol Arudam Prasannam Tests', () {
    test('Jamakol 4 pillars and outer planets placement', () {
      final jamakol = JamakolArudamCalculator.calculate(
        queryTime: DateTime(2026, 8, 24, 11, 30),
        customAarudamNumber: 5,
      );
      expect(jamakol.jamamNumber, inInclusiveRange(1, 8));
      expect(jamakol.udhayam.rasiNameTa.isNotEmpty, true);
      expect(jamakol.aarudam.rasiNameTa.isNotEmpty, true);
      expect(jamakol.kavippu.rasiNameTa.isNotEmpty, true);
      expect(jamakol.jamaPlanets.length, 8);
    });
  });

  group('9. Bhrigu Nandi Nadi & Numerology Tests', () {
    test('Bhrigu Nandi Nadi directional groupings and combinations', () {
      final horoscope = AstrologyCalculator.calculateHoroscope(
        dateOfBirth: DateTime(1996, 6, 15, 8, 30),
        latitude: 13.0827,
        longitude: 80.2707,
        utcOffsetHours: 5.5,
      );

      final nadi = BhriguNandiNadiCalculator.calculate(horoscope.planets);
      expect(nadi.directionalPlanetsTa.length, 4);
      expect(nadi.combinations.isNotEmpty, true);
    });

    test('Numerology Chaldean and Pythagorean calculations', () {
      final numRes = NumerologyCalculator.calculate(
        birthDate: DateTime(1996, 6, 15),
        name: 'GOWTHAM',
        system: NumerologySystem.chaldean,
      );

      expect(numRes.birthNumber, 6); // 15 -> 1+5 = 6
      expect(numRes.lifePathNumber, 1); // 15+6+1996 = 2017 -> 2+0+1+7 = 10 -> 1
      expect(numRes.nameNumber, inInclusiveRange(1, 9));
      expect(numRes.friendlyNumbers.isNotEmpty, true);
    });
  });
}
