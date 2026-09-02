import '../../services/astrology_calculator.dart';
import '../models/kp_birth_data.dart';
import '../models/kp_planet.dart';
import '../models/kp_planet_position.dart';
import 'kp_astronomy_engine.dart';
import 'kp_ayanamsa_engine.dart';
import 'kp_degree_formatter.dart';
import 'kp_nakshatra_engine.dart';
import 'kp_rasi_engine.dart';
import 'kp_sub_lord_engine.dart';
import 'kp_sub_sub_lord_engine.dart';

/// Calculation Engine for KP Planetary Positions
class KPPlanetPositionEngine {
  /// Calculate all 9 KP planets + Lagna based on birth data
  Future<List<KPPlanetPosition>> calculate(KPBirthData birthData) async {
    // 1. Calculate Astronomical Positions
    final astro = KPAstronomyEngine.calculate(birthData);
    final kpAyanamsa = KPAyanamsaEngine.calculateAyanamsa(
      birthData.dateTime,
      utcOffsetHours: birthData.utcOffsetHours,
    );

    final List<KPPlanetPosition> positions = [];

    // Calculate each of the 9 classical planets
    for (final p in KPPlanet.values) {
      final double siderealLong = astro.planetLongitudes[p] ?? 0.0;
      final double speed = astro.planetSpeeds[p] ?? 1.0;
      final bool isRetro = (p != KPPlanet.sun && p != KPPlanet.moon) && (speed < 0.0);

      final double normSidereal = AstrologyCalculator.normalizeDegrees(siderealLong);
      final double tropicalLong = AstrologyCalculator.normalizeDegrees(normSidereal + kpAyanamsa);

      final rasiInfo = KPRasiEngine.calculate(normSidereal);
      final nakInfo = KPNakshatraEngine.calculate(normSidereal);
      final subInfo = KPSubLordEngine.calculate(normSidereal);
      final subSubInfo = KPSubSubLordEngine.calculate(normSidereal);

      // Degree, minute, second inside rasi
      final double signDegree = normSidereal % 30.0;
      final int degInt = signDegree.floor();
      final double remMin = (signDegree - degInt) * 60.0;
      final int minInt = remMin.floor();
      final double sec = (remMin - minInt) * 60.0;

      positions.add(KPPlanetPosition(
        planet: p,
        longitude: normSidereal,
        tropicalLongitude: tropicalLong,
        siderealLongitude: normSidereal,
        rasiIndex: rasiInfo.index,
        rasiNameEn: rasiInfo.nameEn,
        rasiNameTa: rasiInfo.nameTa,
        degree: degInt,
        minute: minInt,
        second: sec,
        nakshatraIndex: nakInfo.index,
        nakshatraNameEn: nakInfo.nameEn,
        nakshatraNameTa: nakInfo.nameTa,
        pada: nakInfo.pada,
        starLord: nakInfo.lordEn,
        subLord: subInfo.subLordEn,
        subSubLord: subSubInfo.subSubLordEn,
        occupiedHouse: 1, // Will be bound to cusp houses
        ownedHouses: const [],
        isRetrograde: isRetro,
        speed: speed,
      ));
    }

    return positions;
  }
}
