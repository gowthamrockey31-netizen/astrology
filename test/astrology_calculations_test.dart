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
      expect(allVargas.length, 16);
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
