import '../models/jamakkol_models.dart';
import '../models/jamakkol_planet_models.dart';
import 'arudam_calculator.dart';
import 'jamakkol_aspect_calculator.dart';
import 'jamakkol_interpretation_engine.dart';
import 'jamakkol_planet_calculator.dart';
import 'jamam_calculator.dart';
import 'kavippu_calculator.dart';
import 'udayam_calculator.dart';

/// Master Engine that orchestrates all Jamakkol Prasannam calculations
class JamakkolEngine {
  /// Calculates complete immutable JamakkolChartState
  static JamakkolChartState calculateChart({
    required DateTime queryDateTime,
    required JamakkolLocation location,
    bool isLive = true,
    String question = '',
    JamakkolQuestionCategory questionCategory = JamakkolQuestionCategory.general,
    int? customArudamNumber,
  }) {
    // 1. Calculate Jamam Schedule (16 Jamams, Sunrise, Sunset, Weekday Lord, Current Jamam)
    final jamamSchedule = JamamCalculator.calculateSchedule(
      queryDateTime: queryDateTime,
      location: location,
    );
    final currentJamam = jamamSchedule.currentJamam;

    // 2. Transit / Gocharam Planets (via local Swiss Ephemeris / AstrologyCalculator)
    final transitPlanets = JamakkolPlanetCalculator.calculateTransitPlanets(
      queryDateTime: queryDateTime,
      location: location,
    );

    // Find Sun's longitude for key point calculations
    double sunLongitude = 0.0;
    for (final tp in transitPlanets) {
      if (tp.nameEn == 'Sun' || tp.nameTa == 'சூரியன்') {
        sunLongitude = tp.absoluteLongitude;
        break;
      }
    }

    // 3. Udayam (உதயம்)
    final udayam = UdayamCalculator.calculateUdayam(
      queryDateTime: queryDateTime,
      location: location,
      effectiveSunrise: jamamSchedule.sunrise,
      effectiveSunset: jamamSchedule.sunset,
      sunLongitude: sunLongitude,
    );

    // 4. Arudam (ஆருடம்)
    final arudam = ArudamCalculator.calculateArudam(
      queryDateTime: queryDateTime,
      udayamRasiIndex: udayam.rasiIndex,
      udayamDegreeInRasi: udayam.degreeInRasi,
      customArudamNumber: customArudamNumber,
    );

    // 5. Kavippu (கவிப்பு)
    final kavippu = KavippuCalculator.calculateKavippu(
      queryDateTime: queryDateTime,
      udayamRasiIndex: udayam.rasiIndex,
      arudamRasiIndex: arudam.rasiIndex,
      udayamDegreeInRasi: udayam.degreeInRasi,
      arudamLongitude: arudam.absoluteLongitude,
      sunLongitude: sunLongitude,
      weekdayNumber: jamamSchedule.weekdayNumber,
      jamamPeriodIndex: currentJamam.periodIndex,
      isDay: currentJamam.isDay,
    );

    // 6. Upagrahas (Yamakandam, Rahu Kaalam, Mandi, Mrityu, Lagna)
    final upagrahas = JamakkolPlanetCalculator.calculateUpagrahas(
      queryDateTime: queryDateTime,
      location: location,
      schedule: jamamSchedule,
      sunLongitude: sunLongitude,
      udayamRasiIndex: udayam.rasiIndex,
    );

    // Also add Sidereal Lagna to upagrahas list for astronomical reference
    final siderealLagna = UdayamCalculator.calculateSiderealLagna(
      queryDateTime: queryDateTime,
      location: location,
      udayamRasiIndex: udayam.rasiIndex,
    );
    upagrahas.add(siderealLagna);

    // 7. 8 Traditional Jamakkol Outer Planets
    final jamakkolPlanets = JamakkolPlanetCalculator.calculateJamakkolPlanets(
      queryDateTime: queryDateTime,
      schedule: jamamSchedule,
    );

    // 8. Rasi Indexed Maps for chart rendering
    final Map<int, List<JamakkolPlanet>> jamakkolPlanetsByRasi = {};
    for (final jp in jamakkolPlanets) {
      jamakkolPlanetsByRasi.putIfAbsent(jp.rasiIndex, () => []).add(jp);
    }

    final Map<int, List<TransitPlanet>> transitPlanetsByRasi = {};
    for (final tp in transitPlanets) {
      transitPlanetsByRasi.putIfAbsent(tp.rasiIndex, () => []).add(tp);
    }

    final Map<int, List<JamakkolSpecialPoint>> specialPointsByRasi = {};
    specialPointsByRasi.putIfAbsent(udayam.rasiIndex, () => []).add(udayam);
    specialPointsByRasi.putIfAbsent(arudam.rasiIndex, () => []).add(arudam);
    specialPointsByRasi.putIfAbsent(kavippu.rasiIndex, () => []).add(kavippu);
    for (final u in upagrahas) {
      specialPointsByRasi.putIfAbsent(u.rasiIndex, () => []).add(u);
    }

    // 9. Aspects & Astrological Combinations
    final aspects = JamakkolAspectCalculator.calculateAspects(
      udayam: udayam,
      arudam: arudam,
      kavippu: kavippu,
      jamakkolPlanets: jamakkolPlanets,
      transitPlanets: transitPlanets,
    );

    final combinations = JamakkolAspectCalculator.calculateCombinations(
      udayam: udayam,
      arudam: arudam,
      kavippu: kavippu,
      jamakkolPlanets: jamakkolPlanets,
      transitPlanets: transitPlanets,
    );

    // 10. Next 1-Hour Analysis
    final nextHourSlots = JamakkolInterpretationEngine.calculateNextHourSlots(
      queryDateTime: queryDateTime,
      udayam: udayam,
      kavippu: kavippu,
      jamakkolPlanets: jamakkolPlanets,
    );

    // 11. Comprehensive Interpretation
    final interpretation = JamakkolInterpretationEngine.generateInterpretation(
      question: question,
      category: questionCategory,
      udayam: udayam,
      arudam: arudam,
      kavippu: kavippu,
      jamakkolPlanets: jamakkolPlanets,
      transitPlanets: transitPlanets,
      combinations: combinations,
      aspects: aspects,
    );

    return JamakkolChartState(
      location: location,
      queryDateTime: queryDateTime,
      isLive: isLive,
      question: question,
      questionCategory: questionCategory,
      customArudamNumber: customArudamNumber,
      sunrise: jamamSchedule.sunrise,
      sunset: jamamSchedule.sunset,
      jamamSchedule: jamamSchedule,
      currentJamam: currentJamam,
      udayam: udayam,
      arudam: arudam,
      kavippu: kavippu,
      upagrahas: upagrahas,
      jamakkolPlanets: jamakkolPlanets,
      transitPlanets: transitPlanets,
      jamakkolPlanetsByRasi: jamakkolPlanetsByRasi,
      transitPlanetsByRasi: transitPlanetsByRasi,
      specialPointsByRasi: specialPointsByRasi,
      aspects: aspects,
      combinations: combinations,
      nextHourSlots: nextHourSlots,
      interpretation: interpretation,
    );
  }
}
