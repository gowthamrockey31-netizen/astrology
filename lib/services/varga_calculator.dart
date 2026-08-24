import '../models/varga_chart_model.dart';
import 'astrology_calculator.dart';

/// Calculation Service for all 16 Classical Vedic Divisional Charts (Varga Chakras)
class VargaCalculator {
  /// Calculate a specific Varga Chart for a map of planets
  static VargaChartResult calculateVarga({
    required VargaType type,
    required Map<String, PlanetDetail> planets,
  }) {
    final Map<String, VargaPlanetPosition> calculatedPositions = {};
    final Map<int, List<VargaPlanetPosition>> rasiPlanets = {};

    for (final entry in planets.entries) {
      final key = entry.key;
      final p = entry.value;
      final int vargaRasiIdx = _calculateVargaSignIndex(type, p.rasiIndex, p.degreeInRasi);
      final double degreeInVarga = (p.degreeInRasi * type.division) % 30.0;

      final pos = VargaPlanetPosition(
        planetKey: key,
        tamilName: p.tamilName,
        symbol: p.symbol,
        rasiIndex: vargaRasiIdx,
        rasiNameTa: AstrologyCalculator.rasiNamesTa[vargaRasiIdx],
        rasiNameEn: AstrologyCalculator.rasiNamesEn[vargaRasiIdx],
        degreeInVarga: degreeInVarga,
      );

      calculatedPositions[key] = pos;
      rasiPlanets.putIfAbsent(vargaRasiIdx, () => []).add(pos);
    }

    return VargaChartResult(
      type: type,
      planets: calculatedPositions,
      rasiPlanets: rasiPlanets,
    );
  }

  /// Calculates all 16 Varga Charts
  static Map<VargaType, VargaChartResult> calculateAllVargas(Map<String, PlanetDetail> planets) {
    final Map<VargaType, VargaChartResult> allVargas = {};
    for (final type in VargaType.values) {
      allVargas[type] = calculateVarga(type: type, planets: planets);
    }
    return allVargas;
  }

  /// Internal sign transformation based on Classical Parashara Varga algorithms
  static int _calculateVargaSignIndex(VargaType type, int rasiIdx, double degreeInRasi) {
    final bool isOddSign = (rasiIdx % 2 == 0); // 0=Aries (Odd), 1=Taurus (Even)...

    switch (type) {
      case VargaType.d1:
        return rasiIdx;

      case VargaType.d2: // Hora (2 divisions of 15°)
        // In odd signs: 0-15° is Sun (Leo=4), 15-30° is Moon (Cancer=3)
        // In even signs: 0-15° is Moon (Cancer=3), 15-30° is Sun (Leo=4)
        final isFirstHalf = degreeInRasi < 15.0;
        if (isOddSign) {
          return isFirstHalf ? 4 : 3;
        } else {
          return isFirstHalf ? 3 : 4;
        }

      case VargaType.d3: // Drekkana (3 divisions of 10°)
        // 1st part: Same sign, 2nd part: 5th sign, 3rd part: 9th sign
        final part = (degreeInRasi / 10.0).floor().clamp(0, 2);
        if (part == 0) return rasiIdx;
        if (part == 1) return (rasiIdx + 4) % 12;
        return (rasiIdx + 8) % 12;

      case VargaType.d4: // Chaturthamsha (4 divisions of 7°30')
        // Starts from same sign, successive parts go to 1st, 4th, 7th, 10th
        final part = (degreeInRasi / 7.5).floor().clamp(0, 3);
        return (rasiIdx + part * 3) % 12;

      case VargaType.d7: // Saptamsha (7 divisions of 4°17'8.57")
        // Odd signs: starts from same sign. Even signs: starts from 7th sign.
        final part = (degreeInRasi / (30.0 / 7.0)).floor().clamp(0, 6);
        final startRasi = isOddSign ? rasiIdx : (rasiIdx + 6) % 12;
        return (startRasi + part) % 12;

      case VargaType.d9: // Navamsha (9 divisions of 3°20')
        // Movable (0,3,6,9) -> starts same sign
        // Fixed (1,4,7,10) -> starts 9th from it
        // Dual (2,5,8,11) -> starts 5th from it
        final part = (degreeInRasi / (30.0 / 9.0)).floor().clamp(0, 8);
        int startRasi = 0;
        if (rasiIdx % 4 == 0) {
          startRasi = 0; // Aries, Leo, Sagittarius starts at Aries
        } else if (rasiIdx % 4 == 1) {
          startRasi = 9; // Taurus, Virgo, Capricorn starts at Capricorn
        } else if (rasiIdx % 4 == 2) {
          startRasi = 6; // Gemini, Libra, Aquarius starts at Libra
        } else {
          startRasi = 3; // Cancer, Scorpio, Pisces starts at Cancer
        }
        return (startRasi + part) % 12;

      case VargaType.d10: // Dasamsha (10 divisions of 3°)
        // Odd signs: starts from same sign. Even signs: starts from 9th sign.
        final part = (degreeInRasi / 3.0).floor().clamp(0, 9);
        final startRasi = isOddSign ? rasiIdx : (rasiIdx + 8) % 12;
        return (startRasi + part) % 12;

      case VargaType.d12: // Dwadasamsha (12 divisions of 2°30')
        // Starts from the sign itself and proceeds in order
        final part = (degreeInRasi / 2.5).floor().clamp(0, 11);
        return (rasiIdx + part) % 12;

      case VargaType.d16: // Shodashamsha (16 divisions of 1°52'30")
        // Movable (Aries) starts Aries, Fixed starts Leo, Dual starts Sagittarius
        final part = (degreeInRasi / (30.0 / 16.0)).floor().clamp(0, 15);
        int startRasi = (rasiIdx % 3 == 0) ? 0 : ((rasiIdx % 3 == 1) ? 4 : 8);
        return (startRasi + part) % 12;

      case VargaType.d20: // Vimshamsha (20 divisions of 1°30')
        // Movable starts Aries, Fixed starts Sagittarius, Dual starts Leo
        final part = (degreeInRasi / 1.5).floor().clamp(0, 19);
        int startRasi = (rasiIdx % 3 == 0) ? 0 : ((rasiIdx % 3 == 1) ? 8 : 4);
        return (startRasi + part) % 12;

      case VargaType.d24: // Chaturvimshamsha (24 divisions of 1°15')
        // Odd signs start from Leo, Even signs start from Cancer
        final part = (degreeInRasi / 1.25).floor().clamp(0, 23);
        final startRasi = isOddSign ? 4 : 3;
        return (startRasi + part) % 12;

      case VargaType.d27: // Bhamsa / Saptavimshamsha (27 divisions of 1°06'40")
        // Fire signs start Aries, Earth start Cancer, Air start Libra, Water start Capricorn
        final part = (degreeInRasi / (30.0 / 27.0)).floor().clamp(0, 26);
        final startRasi = (rasiIdx % 4) * 3;
        return (startRasi + part) % 12;

      case VargaType.d30: // Trimsamsha (30 divisions, degrees assigned by 5 elements)
        // Odd signs: Mars (0-5°=Aries), Saturn (5-10°=Aquarius), Jupiter (10-18°=Sagittarius), Mercury (18-25°=Gemini), Venus (25-30°=Libra)
        // Even signs: Venus (0-5°=Taurus), Mercury (5-12°=Virgo), Jupiter (12-20°=Pisces), Saturn (20-25°=Capricorn), Mars (25-30°=Scorpio)
        if (isOddSign) {
          if (degreeInRasi < 5.0) return 0; // Aries
          if (degreeInRasi < 10.0) return 10; // Aquarius
          if (degreeInRasi < 18.0) return 8; // Sagittarius
          if (degreeInRasi < 25.0) return 2; // Gemini
          return 6; // Libra
        } else {
          if (degreeInRasi < 5.0) return 1; // Taurus
          if (degreeInRasi < 12.0) return 5; // Virgo
          if (degreeInRasi < 20.0) return 11; // Pisces
          if (degreeInRasi < 25.0) return 9; // Capricorn
          return 7; // Scorpio
        }

      case VargaType.d40: // Khavedamsha (40 divisions of 45')
        // Odd signs start Aries, Even signs start Libra
        final part = (degreeInRasi / 0.75).floor().clamp(0, 39);
        final startRasi = isOddSign ? 0 : 6;
        return (startRasi + part) % 12;

      case VargaType.d45: // Akshavedamsha (45 divisions of 40')
        // Movable start Aries, Fixed start Leo, Dual start Sagittarius
        final part = (degreeInRasi / (30.0 / 45.0)).floor().clamp(0, 44);
        int startRasi = (rasiIdx % 3 == 0) ? 0 : ((rasiIdx % 3 == 1) ? 4 : 8);
        return (startRasi + part) % 12;

      case VargaType.d60: // Shastiamsha (60 divisions of 30')
        // Starts from the sign itself and proceeds in regular zodiac order
        final part = (degreeInRasi / 0.5).floor().clamp(0, 59);
        return (rasiIdx + part) % 12;
    }
  }
}
