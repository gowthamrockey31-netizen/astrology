import 'package:flutter/foundation.dart';
import 'jamam_models.dart';
import 'jamakkol_planet_models.dart';

/// Geographic place details for Jamakkol calculation
@immutable
class JamakkolLocation {
  final String name;
  final double latitude;
  final double longitude;
  final double timezone;

  const JamakkolLocation({
    required this.name,
    required this.latitude,
    required this.longitude,
    this.timezone = 5.5,
  });

  static const defaultChennai = JamakkolLocation(
    name: 'Chennai',
    latitude: 13.0827,
    longitude: 80.2707,
    timezone: 5.5,
  );

  static const defaultCoimbatore = JamakkolLocation(
    name: 'Coimbatore',
    latitude: 11.0168,
    longitude: 76.9558,
    timezone: 5.5,
  );

  static const defaultMadurai = JamakkolLocation(
    name: 'Madurai',
    latitude: 9.9252,
    longitude: 78.1198,
    timezone: 5.5,
  );

  static const defaultThiruvarur = JamakkolLocation(
    name: 'Thiruvarur',
    latitude: 10.7725,
    longitude: 79.6365,
    timezone: 5.5,
  );
}

/// Planetary aspect relationship in Jamakkol
@immutable
class JamakkolAspect {
  final String sourceNameEn;
  final String sourceNameTa;
  final String targetNameEn;
  final String targetNameTa;
  final int houseDistance; // 1 to 12
  final String aspectTypeEn; // e.g. "Opposition (7th)", "Trine (5th/9th)", "Conjunction (1st)"
  final String aspectTypeTa; // e.g. "சமசப்தம பார்வை (7)", "திரிகோண பார்வை (5/9)", "இணைவு (1)"
  final bool isBenefic;
  final String descriptionTa;
  final String descriptionEn;

  const JamakkolAspect({
    required this.sourceNameEn,
    required this.sourceNameTa,
    required this.targetNameEn,
    required this.targetNameTa,
    required this.houseDistance,
    required this.aspectTypeEn,
    required this.aspectTypeTa,
    required this.isBenefic,
    required this.descriptionTa,
    required this.descriptionEn,
  });
}

/// Astrological combination / Yoga in Jamakkol Prasannam
@immutable
class JamakkolCombination {
  final String titleTa;
  final String titleEn;
  final String descriptionTa;
  final String descriptionEn;
  final bool isFavorable;
  final String category; // 'Udayam', 'Arudam', 'Kavippu', 'General'

  const JamakkolCombination({
    required this.titleTa,
    required this.titleEn,
    required this.descriptionTa,
    required this.descriptionEn,
    required this.isFavorable,
    required this.category,
  });
}

/// 5-minute interval for the Next 1-Hour Analysis
@immutable
class JamakkolNextHourSlot {
  final DateTime startTime;
  final DateTime endTime;
  final int arudamRasiIndex;
  final String arudamRasiTa;
  final String arudamRasiEn;
  final String arudamLordTa;
  final String arudamLordEn;
  final bool isFavorable;
  final bool negotiationFavorable; // பேச்சுவார்த்தை
  final bool muhurthamFavorable; // சுப காரியம்
  final bool moneyFavorable; // பண வரவு
  final String statusSummaryTa;
  final String statusSummaryEn;
  final List<String> favorableFactorsTa;
  final List<String> unfavorableFactorsTa;

  const JamakkolNextHourSlot({
    required this.startTime,
    required this.endTime,
    required this.arudamRasiIndex,
    required this.arudamRasiTa,
    required this.arudamRasiEn,
    required this.arudamLordTa,
    required this.arudamLordEn,
    required this.isFavorable,
    required this.negotiationFavorable,
    required this.muhurthamFavorable,
    required this.moneyFavorable,
    required this.statusSummaryTa,
    required this.statusSummaryEn,
    required this.favorableFactorsTa,
    required this.unfavorableFactorsTa,
  });
}

/// Question categories supported by the interpretation engine
enum JamakkolQuestionCategory {
  job, // உத்தியோகம் / தொழில்
  business, // வியாபாரம்
  marriage, // திருமணம்
  money, // தனம் / வருமானம்
  loan, // கடன் / மீட்பு
  property, // சொத்து / மனை / வாகனம்
  travel, // பயணம் / வெளிநாடு
  legal, // வழக்கு / தகராறு
  lostItem, // காணாமல் போன பொருள்
  relationship, // உறவு / குடும்ப ஒற்றுமை
  health, // ஆரோக்கியம் / நலம்
  competition, // தேர்வு / போட்டி வெற்றி
  general, // பொது பிரசன்னம்
}

/// Structured interpretation findings for the query
@immutable
class JamakkolInterpretation {
  final String verdictTitleTa;
  final String verdictTitleEn;
  final String verdictSummaryTa;
  final String verdictSummaryEn;
  final bool isOverallFavorable;
  final int confidenceScore; // 0 to 100

  // Key pillar analyses
  final String udayamAnalysisTa;
  final String udayamAnalysisEn;
  final String arudamAnalysisTa;
  final String arudamAnalysisEn;
  final String kavippuAnalysisTa;
  final String kavippuAnalysisEn;

  // House relationships
  final int udayamToArudamHouse; // 1 to 12
  final String udayamToArudamTextTa;
  final String udayamToArudamTextEn;

  final int arudamToUdayamHouse; // 1 to 12
  final int udayamToKavippuHouse; // 1 to 12
  final int arudamToKavippuHouse; // 1 to 12

  // Question specific breakdown
  final JamakkolQuestionCategory questionCategory;
  final String questionCategoryLabelTa;
  final String questionCategoryLabelEn;
  final String questionAnalysisTa;
  final String questionAnalysisEn;

  // Guidance / Remedies
  final List<String> positiveIndicatorsTa;
  final List<String> warningIndicatorsTa;
  final String practicalRemedyTa;
  final String practicalRemedyEn;

  const JamakkolInterpretation({
    required this.verdictTitleTa,
    required this.verdictTitleEn,
    required this.verdictSummaryTa,
    required this.verdictSummaryEn,
    required this.isOverallFavorable,
    required this.confidenceScore,
    required this.udayamAnalysisTa,
    required this.udayamAnalysisEn,
    required this.arudamAnalysisTa,
    required this.arudamAnalysisEn,
    required this.kavippuAnalysisTa,
    required this.kavippuAnalysisEn,
    required this.udayamToArudamHouse,
    required this.udayamToArudamTextTa,
    required this.udayamToArudamTextEn,
    required this.arudamToUdayamHouse,
    required this.udayamToKavippuHouse,
    required this.arudamToKavippuHouse,
    required this.questionCategory,
    required this.questionCategoryLabelTa,
    required this.questionCategoryLabelEn,
    required this.questionAnalysisTa,
    required this.questionAnalysisEn,
    required this.positiveIndicatorsTa,
    required this.warningIndicatorsTa,
    required this.practicalRemedyTa,
    required this.practicalRemedyEn,
  });
}

/// The entire state and calculated result of a Jamakkol Prasannam session
@immutable
class JamakkolChartState {
  final JamakkolLocation location;
  final DateTime queryDateTime;
  final bool isLive;
  final String question;
  final JamakkolQuestionCategory questionCategory;
  final int? customArudamNumber;

  // Core astronomical / jamam facts
  final DateTime sunrise;
  final DateTime sunset;
  final JamamDaySchedule jamamSchedule;
  final JamamInfo currentJamam;

  // Key pillars
  final JamakkolSpecialPoint udayam;
  final JamakkolSpecialPoint arudam;
  final JamakkolSpecialPoint kavippu;

  // Upagrahas / secondary points
  final List<JamakkolSpecialPoint> upagrahas;

  // Planetary bodies
  final List<JamakkolPlanet> jamakkolPlanets;
  final List<TransitPlanet> transitPlanets;

  // Rasi indexed lookup maps for chart painting
  final Map<int, List<JamakkolPlanet>> jamakkolPlanetsByRasi;
  final Map<int, List<TransitPlanet>> transitPlanetsByRasi;
  final Map<int, List<JamakkolSpecialPoint>> specialPointsByRasi;

  // Analytical relationships
  final List<JamakkolAspect> aspects;
  final List<JamakkolCombination> combinations;
  final List<JamakkolNextHourSlot> nextHourSlots;
  final JamakkolInterpretation interpretation;

  const JamakkolChartState({
    required this.location,
    required this.queryDateTime,
    required this.isLive,
    required this.question,
    required this.questionCategory,
    this.customArudamNumber,
    required this.sunrise,
    required this.sunset,
    required this.jamamSchedule,
    required this.currentJamam,
    required this.udayam,
    required this.arudam,
    required this.kavippu,
    required this.upagrahas,
    required this.jamakkolPlanets,
    required this.transitPlanets,
    required this.jamakkolPlanetsByRasi,
    required this.transitPlanetsByRasi,
    required this.specialPointsByRasi,
    required this.aspects,
    required this.combinations,
    required this.nextHourSlots,
    required this.interpretation,
  });
}
