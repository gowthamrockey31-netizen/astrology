import '../models/kp2_birth_data.dart';
import '../models/kp2_planet.dart';
import '../models/kp2_result.dart';
import 'kp2_astronomy_engine.dart';
import 'kp2_cusp_engine.dart';
import 'kp2_ruling_planet_engine.dart';
import 'kp2_significator_engine.dart';
import 'kp2_dasha_engine.dart';

/// Top-Level Complete Calculation Engine for KP Method 2
class KP2CompleteEngine {
  /// Calculate all KP Method 2 results for a given birth profile
  static KP2Result calculate(KP2BirthData data) {
    // 1. Compute Julian Day & Lahiri Ayanamsa
    final jd = KP2AstronomyEngine.getJulianDay(data);
    final ayanamsa = KP2AstronomyEngine.getLahiriAyanamsa(jd);
    final ayanamsaDms = KP2AstronomyEngine.formatAyanamsa(ayanamsa);

    // 2. Compute 12 Placidus Cusps (converted to sidereal with Lahiri Ayanamsa)
    final cusps = KP2CuspEngine.calculateCusps(
      birthData: data,
      jd: jd,
      ayanamsa: ayanamsa,
    );

    // 3. Compute 9 Planetary Positions with Star, Sub, Sub-Sub, & Occupied House
    final planetPositions = KP2AstronomyEngine.calculatePlanets(
      birthData: data,
      jd: jd,
      ayanamsa: ayanamsa,
      cusps: cusps,
    );

    // 4. Compute Ruling Planets
    final moonPos = planetPositions.firstWhere((p) => p.planet == KP2Planet.moon);
    final ascCusp = cusps.firstWhere((c) => c.house == 1);
    final rulingPlanets = KP2RulingPlanetEngine.calculate(
      localDateTime: data.localDateTime,
      moonPosition: moonPos,
      ascendantCusp: ascCusp,
    );

    // 5. Compute Planet & House Significators with Advantage Filter
    final (planetSigs, houseSigs) = KP2SignificatorEngine.calculate(
      positions: planetPositions,
      cusps: cusps,
    );

    // 6. Compute Vimshottari Dasha Balance and 4-Level Timeline
    final (dashaBalance, dashaTimeline) = KP2DashaEngine.calculate(
      moonLongitude: moonPos.siderealLongitude,
      birthDateTime: data.localDateTime,
    );

    return KP2Result(
      birthData: data,
      julianDay: jd,
      ayanamsa: ayanamsa,
      ayanamsaDms: ayanamsaDms,
      planetPositions: planetPositions,
      cusps: cusps,
      rulingPlanets: rulingPlanets,
      planetSignificators: planetSigs,
      houseSignificators: houseSigs,
      dashaBalance: dashaBalance,
      dashaTimeline: dashaTimeline,
    );
  }
}
