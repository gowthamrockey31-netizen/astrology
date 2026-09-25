import 'nakshatra_prasannam_calculator.dart';
import 'nakshatra_prasannam_data.dart';
import 'nakshatra_prasannam_models.dart';

/// Engine orchestrating input validation and calculation flow for Nakshatra Prasannam.
class NakshatraPrasannaEngine {
  /// Validate input parameters and return list of Tamil error messages
  static List<String> validateInput(PrasannaInput input) {
    final errors = <String>[];

    // 1. Question time must not be before sunrise
    if (input.questionDateTime.isBefore(input.sunriseDateTime)) {
      errors.add('கேள்வி நேரம் சூரிய உதய நேரத்திற்கு முன் இருக்கக்கூடாது.');
    }

    // 2. Moon longitude at sunrise must be between 0 and 360
    if (input.moonSunriseLongitude < 0.0 || input.moonSunriseLongitude >= 360.0) {
      errors.add('சூரிய உதய சந்திரனின் பாகை 0° முதல் 360° வரை இருக்க வேண்டும்.');
    }

    // 3. Moon question longitude check if provided
    if (input.moonQuestionLongitude != null) {
      if (input.moonQuestionLongitude! < 0.0 || input.moonQuestionLongitude! >= 360.0) {
        errors.add('கேள்வி நேர சந்திரனின் பாகை 0° முதல் 360° வரை இருக்க வேண்டும்.');
      }
    }

    // 4. Planet longitudes validity
    for (final entry in input.planetLongitudes.entries) {
      if (entry.value.isNaN || entry.value.isInfinite || entry.value < 0.0 || entry.value >= 360.0) {
        errors.add('${kPlanetTamilNames[entry.key]} கிரக பாகை தவறாக உள்ளது (${entry.value}°). 0° முதல் 360° வரை இருத்தல் வேண்டும்.');
      }
    }

    // 5. Ascendant check
    if (input.ascendantLongitude != null) {
      if (input.ascendantLongitude! < 0.0 || input.ascendantLongitude! >= 360.0) {
        errors.add('லக்ன பாகை 0° முதல் 360° வரை இருக்க வேண்டும்.');
      }
    }

    return errors;
  }

  /// Execute the complete Nakshatra Prasannam calculation flow:
  /// Question Date & Time
  ///         ↓
  ///      Sunrise
  ///         ↓
  /// Moon Longitude at Sunrise
  ///         ↓
  ///        DRM
  ///         ↓
  /// Remaining Nakshatra Time
  ///         ↓
  /// Sequential Nakshatra Dasha Periods
  ///         ↓
  /// Question / Lock Time
  ///         ↓
  ///        HRM
  ///         ↓
  ///     HRM Planet
  ///         ↓
  ///        NPL
  ///         ↓
  ///       Jeeva
  ///         ↓
  ///      Sareera
  ///         ↓
  ///   DRM–HRM Relation
  ///         ↓
  ///  Jeeva–Sareera Relation
  ///         ↓
  /// Final Result
  static NakshatraPrasannaResult calculate(PrasannaInput input) {
    // 1. Calculate DRM (Daily Sunrise Moon)
    final drm = NakshatraPrasannaCalculator.getNakshatraPosition(input.moonSunriseLongitude);
    final drmRemainingMin = NakshatraPrasannaCalculator.remainingStarTime(drm.remainingDegrees, drm.lord);

    // 2. Sequential Nakshatra Dasha Periods & HRM calculation
    final hrm = NakshatraPrasannaCalculator.calculateHRM(
      sunrise: input.sunriseDateTime,
      questionTime: input.questionDateTime,
      drm: drm,
    );

    // 3. HRM Planet longitude lookup
    final hrmPlanetLon = input.planetLongitudes[hrm.hrmPlanet] ??
        (hrm.hrmPlanet == Planet.moon ? (input.moonQuestionLongitude ?? input.moonSunriseLongitude) : null);

    // 4. Calculate NPL (Nakshatra Prasanna Lagna)
    final npl = NakshatraPrasannaCalculator.calculateNPL(
      hrmPlanet: hrm.hrmPlanet,
      hrmPlanetLongitude: hrmPlanetLon,
      ascendantLongitude: input.ascendantLongitude,
    );

    // 5. Calculate Jeeva & Sareera
    final Map<Planet, double> fullPlanetLons = Map.from(input.planetLongitudes);
    if (!fullPlanetLons.containsKey(Planet.moon)) {
      fullPlanetLons[Planet.moon] = input.moonQuestionLongitude ?? input.moonSunriseLongitude;
    }

    final jeevaSareera = NakshatraPrasannaCalculator.calculateJeevaSareera(
      sourcePlanet: hrm.hrmPlanet,
      planetLongitudes: fullPlanetLons,
    );

    // 6. DRM–HRM Relationship
    final drmHrmRelation = NakshatraPrasannaCalculator.evaluateDrmHrm(drm.lord, hrm.hrmPlanet);

    // 7. Guna calculation
    final guna = NakshatraPrasannaCalculator.gunaOfPlanetAtStar(hrm.hrmPlanet, drm.nakshatraIndex);

    // 8. Uttama Drekkana calculation
    final uttama = NakshatraPrasannaCalculator.calculateUttama(
      planetLongitude: hrmPlanetLon ?? input.moonSunriseLongitude,
      planetLongitudes: fullPlanetLons,
    );

    // 9. Event Timing (Answer Period)
    final answerPeriod = NakshatraPrasannaCalculator.determineAnswerPeriod(
      drmHrm: drmHrmRelation,
      jeevaSareera: jeevaSareera,
      guna: guna,
      bhava: npl?.bhava,
    );
    final timingDesc = NakshatraPrasannaCalculator.timingInterpretation(answerPeriod);

    return NakshatraPrasannaResult(
      input: input,
      lockTime: input.questionDateTime,
      drm: drm,
      drmRemainingMinutes: drmRemainingMin,
      hrm: hrm,
      npl: npl,
      jeevaSareera: jeevaSareera,
      drmHrmRelation: drmHrmRelation,
      guna: guna,
      uttama: uttama,
      answerPeriod: answerPeriod,
      timingDescription: timingDesc,
      calculationTimestamp: DateTime.now(),
    );
  }
}
