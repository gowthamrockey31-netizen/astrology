import 'nakshatra_prasannam_data.dart';

/// User input model for Nakshatra Prasannam
class PrasannaInput {
  final DateTime questionDateTime;
  final DateTime sunriseDateTime;
  final String place;
  final double latitude;
  final double longitude;
  final double moonSunriseLongitude;
  final double? moonQuestionLongitude;
  final Map<Planet, double> planetLongitudes;
  final double? ascendantLongitude;

  const PrasannaInput({
    required this.questionDateTime,
    required this.sunriseDateTime,
    required this.place,
    required this.latitude,
    required this.longitude,
    required this.moonSunriseLongitude,
    this.moonQuestionLongitude,
    required this.planetLongitudes,
    this.ascendantLongitude,
  });

  PrasannaInput copyWith({
    DateTime? questionDateTime,
    DateTime? sunriseDateTime,
    String? place,
    double? latitude,
    double? longitude,
    double? moonSunriseLongitude,
    double? moonQuestionLongitude,
    Map<Planet, double>? planetLongitudes,
    double? ascendantLongitude,
  }) {
    return PrasannaInput(
      questionDateTime: questionDateTime ?? this.questionDateTime,
      sunriseDateTime: sunriseDateTime ?? this.sunriseDateTime,
      place: place ?? this.place,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      moonSunriseLongitude: moonSunriseLongitude ?? this.moonSunriseLongitude,
      moonQuestionLongitude: moonQuestionLongitude ?? this.moonQuestionLongitude,
      planetLongitudes: planetLongitudes ?? this.planetLongitudes,
      ascendantLongitude: ascendantLongitude ?? this.ascendantLongitude,
    );
  }
}

/// Represents Nakshatra position details (DRM, etc.)
class NakshatraPosition {
  final int nakshatraIndex; // 0 to 26
  final String nakshatraNameTamil;
  final String nakshatraNameEnglish;
  final Planet lord;
  final int pada; // 1 to 4
  final double traversedDegrees; // சென்ற பாகை (0.0 to 13.333)
  final double remainingDegrees; // மீதமுள்ள பாகை (0.0 to 13.333)
  final double totalStarDegrees; // 13.333333333333334
  final double longitude; // normalized 0 to 360

  const NakshatraPosition({
    required this.nakshatraIndex,
    required this.nakshatraNameTamil,
    required this.nakshatraNameEnglish,
    required this.lord,
    required this.pada,
    required this.traversedDegrees,
    required this.remainingDegrees,
    this.totalStarDegrees = 13.333333333333334,
    required this.longitude,
  });

  String get lordTamil => kPlanetTamilNames[lord] ?? '';
  String get lordEnglish => kPlanetEnglishNames[lord] ?? '';
}

/// Helper model for formatted duration / time
class DashaTime {
  final int hours;
  final int minutes;
  final int seconds;
  final double totalMinutes;

  const DashaTime({
    required this.hours,
    required this.minutes,
    required this.seconds,
    required this.totalMinutes,
  });

  factory DashaTime.fromMinutes(double mins) {
    if (mins.isNaN || mins.isInfinite || mins < 0) {
      mins = 0;
    }
    final totalSec = (mins * 60.0).round();
    final h = totalSec ~/ 3600;
    final m = (totalSec % 3600) ~/ 60;
    final s = totalSec % 60;
    return DashaTime(hours: h, minutes: m, seconds: s, totalMinutes: mins);
  }

  String toTamilDurationString() {
    if (hours > 0) {
      return '$hours மணி $minutes நிமிடம்';
    } else {
      return '$minutes நிமிடம் $seconds வினாடி';
    }
  }

  String toFormattedTime() {
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

/// A segment in the sequential Nakshatra Dasha timeline from Sunrise
class DashaSegment {
  final Planet planet;
  final DateTime startTime;
  final DateTime endTime;
  final double durationMinutes;
  final bool isCurrentSegment;

  const DashaSegment({
    required this.planet,
    required this.startTime,
    required this.endTime,
    required this.durationMinutes,
    this.isCurrentSegment = false,
  });

  String get planetTamil => kPlanetTamilNames[planet] ?? '';
  String get planetEnglish => kPlanetEnglishNames[planet] ?? '';
}

/// Results of HRM (Hora Rising Moon / Nakshatra Prasanna Moon) calculation
class HrmResult {
  final Planet hrmPlanet;
  final DateTime startTime;
  final DateTime endTime;
  final double totalDurationMinutes;
  final double elapsedMinutes;
  final double remainingMinutes;
  final List<DashaSegment> timeline;

  const HrmResult({
    required this.hrmPlanet,
    required this.startTime,
    required this.endTime,
    required this.totalDurationMinutes,
    required this.elapsedMinutes,
    required this.remainingMinutes,
    required this.timeline,
  });

  String get planetTamil => kPlanetTamilNames[hrmPlanet] ?? '';
  String get planetEnglish => kPlanetEnglishNames[hrmPlanet] ?? '';
}

/// Results of NPL (Nakshatra Prasanna Lagna) calculation
class NplResult {
  final Planet hrmPlanet;
  final int rasiIndex; // 0 to 11
  final String rasiTamil;
  final String rasiEnglish;
  final int bhava; // 1 to 12
  final double planetLongitude;

  const NplResult({
    required this.hrmPlanet,
    required this.rasiIndex,
    required this.rasiTamil,
    required this.rasiEnglish,
    required this.bhava,
    required this.planetLongitude,
  });

  String get hrmPlanetTamil => kPlanetTamilNames[hrmPlanet] ?? '';
}

/// Results of Jeeva & Sareera calculation and relationship
class JeevaSareeraResult {
  final Planet sourcePlanet;
  final Planet jeevaPlanet;
  final Planet sareeraPlanet;
  final PlanetaryRelationship relation;
  final String relationTamil;
  final String relationDescription;

  const JeevaSareeraResult({
    required this.sourcePlanet,
    required this.jeevaPlanet,
    required this.sareeraPlanet,
    required this.relation,
    required this.relationTamil,
    required this.relationDescription,
  });

  String get sourcePlanetTamil => kPlanetTamilNames[sourcePlanet] ?? '';
  String get jeevaPlanetTamil => kPlanetTamilNames[jeevaPlanet] ?? '';
  String get sareeraPlanetTamil => kPlanetTamilNames[sareeraPlanet] ?? '';
}

/// Results of Uttama Drekkana analysis
class UttamaResult {
  final bool isVargottama;
  final String vargottamaDescription;
  final bool isParivarthana;
  final String parivarthanaDescription;
  final String summary;

  const UttamaResult({
    required this.isVargottama,
    required this.vargottamaDescription,
    required this.isParivarthana,
    required this.parivarthanaDescription,
    required this.summary,
  });
}

/// Relationship between DRM and HRM
class MoonRelationship {
  final Planet drmLord;
  final Planet hrmLord;
  final PlanetaryRelationship relation;
  final String relationTamil;
  final String explanation;

  const MoonRelationship({
    required this.drmLord,
    required this.hrmLord,
    required this.relation,
    required this.relationTamil,
    required this.explanation,
  });

  String get drmLordTamil => kPlanetTamilNames[drmLord] ?? '';
  String get hrmLordTamil => kPlanetTamilNames[hrmLord] ?? '';
}

/// Supported Answer Timing Periods
enum AnswerPeriod {
  sameDay, // ஒரே நாள்
  withinOneMonth, // ஒரு மாதத்திற்குள்
  oneToTwoMonths, // ஒன்று அல்லது இரண்டு மாதங்கள்
  delayed, // தாமதம்
}

/// Complete Nakshatra Prasanna Calculation Result
class NakshatraPrasannaResult {
  final PrasannaInput input;
  final DateTime lockTime;
  final NakshatraPosition drm;
  final double drmRemainingMinutes;
  final HrmResult hrm;
  final NplResult? npl;
  final JeevaSareeraResult? jeevaSareera;
  final MoonRelationship drmHrmRelation;
  final String guna;
  final UttamaResult uttama;
  final AnswerPeriod answerPeriod;
  final String timingDescription;
  final DateTime calculationTimestamp;

  const NakshatraPrasannaResult({
    required this.input,
    required this.lockTime,
    required this.drm,
    required this.drmRemainingMinutes,
    required this.hrm,
    this.npl,
    this.jeevaSareera,
    required this.drmHrmRelation,
    required this.guna,
    required this.uttama,
    required this.answerPeriod,
    required this.timingDescription,
    required this.calculationTimestamp,
  });
}
