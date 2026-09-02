import '../../services/astrology_calculator.dart';
import '../models/kp_birth_data.dart';
import '../models/kp_planet.dart';
import '../models/kp_planet_position.dart';
import '../models/kp_result.dart';
import 'kp_astronomy_engine.dart';
import 'kp_cusp_engine.dart';
import 'kp_dasha_engine.dart';
import 'kp_house_relation_engine.dart';
import 'kp_nakshatra_engine.dart';
import 'kp_ruling_planet_engine.dart';
import 'kp_significator_engine.dart';
import 'kp_sub_lord_engine.dart';
import 'kp_sub_sub_lord_engine.dart';

/// Central Orchestration Engine for KP Method Model 1
class KPCompleteEngine {
  /// Calculate complete KP Method Model 1 chart
  Future<KPMethodModel1Result> calculate({
    required KPBirthData birth,
  }) async {
    // 1. Validation
    if (birth.latitude < -90.0 || birth.latitude > 90.0) {
      return KPMethodModel1Result.unavailable(
        birthData: birth,
        message: 'Invalid latitude (${birth.latitude}). Must be between -90 and +90.',
      );
    }
    if (birth.longitude < -180.0 || birth.longitude > 180.0) {
      return KPMethodModel1Result.unavailable(
        birthData: birth,
        message: 'Invalid longitude (${birth.longitude}). Must be between -180 and +180.',
      );
    }
    if (birth.placeName.trim().isEmpty) {
      return KPMethodModel1Result.unavailable(
        birthData: birth,
        message: 'Missing birth location. Please provide a valid place name.',
      );
    }

    try {
      // 2. Real Astronomical calculations (Julian day, planetary positions, Placidus cusps)
      final astro = KPAstronomyEngine.calculate(birth);

      // 3. 12 Cusps
      final cusps = KPCuspEngine.calculateCusps(astro.cuspLongitudes);

      // Map which houses are owned by each planet based on cusp sign lordships
      final Map<String, List<int>> planetOwnedHouses = {};
      for (final cusp in cusps) {
        planetOwnedHouses.putIfAbsent(cusp.signLord, () => []).add(cusp.houseNumber);
      }

      // 4. 9 Planets Positions
      final List<KPPlanetPosition> planets = [];
      for (final p in KPPlanet.values) {
        final double pLong = astro.planetLongitudes[p] ?? 0.0;
        final double pSpeed = astro.planetSpeeds[p] ?? 1.0;
        final bool isRetro = (p != KPPlanet.sun && p != KPPlanet.moon) && (pSpeed < 0.0);

        final normLong = AstrologyCalculator.normalizeDegrees(pLong);
        final int rasiIdx = (normLong / 30.0).floor().clamp(0, 11);
        final double degInRasi = normLong - (rasiIdx * 30.0);
        final int degInt = degInRasi.floor();
        final double remMin = (degInRasi - degInt) * 60.0;
        final int minInt = remMin.floor();
        final double sec = (remMin - minInt) * 60.0;

        final nakInfo = KPNakshatraEngine.calculate(normLong);
        final subInfo = KPSubLordEngine.calculate(normLong);
        final subSubInfo = KPSubSubLordEngine.calculate(normLong);

        // Determine occupied house from Placidus cusps
        int occupiedHouse = 1;
        for (int i = 0; i < 12; i++) {
          final cur = cusps[i].longitude;
          final next = cusps[(i + 1) % 12].longitude;
          if (next > cur) {
            if (normLong >= cur && normLong < next) {
              occupiedHouse = i + 1;
              break;
            }
          } else {
            // Straddling 0° Aries
            if (normLong >= cur || normLong < next) {
              occupiedHouse = i + 1;
              break;
            }
          }
        }

        final owned = planetOwnedHouses[p.nameEn] ?? [];

        planets.add(KPPlanetPosition(
          planet: p,
          longitude: normLong,
          rasiIndex: rasiIdx,
          rasiNameEn: AstrologyCalculator.rasiNamesEn[rasiIdx],
          rasiNameTa: AstrologyCalculator.rasiNamesTa[rasiIdx],
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
          occupiedHouse: occupiedHouse,
          ownedHouses: owned,
          isRetrograde: isRetro,
          speed: pSpeed,
        ));
      }

      // 5. Ruling Planets
      final moonLong = astro.planetLongitudes[KPPlanet.moon] ?? 0.0;
      final rulingPlanets = KPRulingPlanetEngine.calculate(
        dateTime: birth.dateTime,
        moonLongitude: moonLong,
        ascendantLongitude: astro.ascendant,
      );

      // 6. Planet Significators (Model 1 Advantage Filter)
      final planetSignificators = KPSignificatorEngine.calculatePlanetSignificators(
        planets: planets,
        cusps: cusps,
      );

      // 7. House Significators (Model 1 Advantage Filter)
      final houseSignificators = KPHouseRelationEngine.calculateHouseSignificators(
        cusps: cusps,
        planets: planets,
      );

      // 8. Dasha Hierarchy & Birth Balance
      final dashaHierarchy = KPDashaEngine.calculate(
        moonLongitude: moonLong,
        birthDateTime: birth.dateTime,
        planets: planets,
      );

      return KPMethodModel1Result(
        birthData: birth,
        kpAyanamsa: astro.ayanamsa,
        planets: planets,
        cusps: cusps,
        rulingPlanets: rulingPlanets,
        planetSignificators: planetSignificators,
        houseSignificators: houseSignificators,
        dashaHierarchy: dashaHierarchy,
        isEngineAvailable: true,
      );
    } catch (e, stack) {
      return KPMethodModel1Result.unavailable(
        birthData: birth,
        message: 'Calculation Error: $e\n$stack',
      );
    }
  }
}
