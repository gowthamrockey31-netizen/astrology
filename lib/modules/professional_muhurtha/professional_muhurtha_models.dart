// ===============================================================
// PROFESSIONAL SUBHA MUHURTHAM - DATA MODELS
// ===============================================================

import 'subha_muhurtham_rules.dart';

/// Categories of Muhurtham
enum MuhurthaCategory {
  generalSubha,
  marriage,
  houseEntry,
  bhoomiPooja,
  earPiercing,
  newBusiness;

  String get tamilTitle {
    switch (this) {
      case MuhurthaCategory.generalSubha:
        return 'பொது சுப காரியம்';
      case MuhurthaCategory.marriage:
        return 'திருமணம் (Wedding)';
      case MuhurthaCategory.houseEntry:
        return 'கிரகப்பிரவேசம் (House Warming)';
      case MuhurthaCategory.bhoomiPooja:
        return 'பூமி பூஜை (Ground Breaking)';
      case MuhurthaCategory.earPiercing:
        return 'காதணி விழா (Ear Piercing)';
      case MuhurthaCategory.newBusiness:
        return 'தொழில் தொடக்கம் (New Business)';
    }
  }

  String get englishTitle {
    switch (this) {
      case MuhurthaCategory.generalSubha:
        return 'General Auspicious';
      case MuhurthaCategory.marriage:
        return 'Marriage';
      case MuhurthaCategory.houseEntry:
        return 'Gruha Pravesham';
      case MuhurthaCategory.bhoomiPooja:
        return 'Bhoomi Pooja';
      case MuhurthaCategory.earPiercing:
        return 'Ear Piercing';
      case MuhurthaCategory.newBusiness:
        return 'New Business';
    }
  }
}

class GeoLocation {
  final String name;
  final double latitude;
  final double longitude;
  final double timeZone;

  const GeoLocation({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.timeZone,
  });
}

class BirthProfile {
  final String name;
  final DateTime birthDate;
  final int birthNakshatra; // 0..26
  final int birthRasi; // 0..11

  const BirthProfile({
    required this.name,
    required this.birthDate,
    required this.birthNakshatra,
    required this.birthRasi,
  });
}

// ===============================================================
// LEVEL 1: GENERAL DAY SUITABILITY MODELS
// ===============================================================

class VaaramEvaluation {
  final int weekdayNumber; // 1=Mon..7=Sun
  final String weekdayName;
  final bool isSuitable;
  final bool isValarpiraiSunday;
  final String reason;

  const VaaramEvaluation({
    required this.weekdayNumber,
    required this.weekdayName,
    required this.isSuitable,
    required this.isValarpiraiSunday,
    required this.reason,
  });
}

class TithiEvaluation {
  final int tithiNumber; // 1..30
  final int singleTithiNumber; // 1..15
  final String tithiName;
  final String paksha;
  final bool isSuitable;
  final String? conflictNote;
  final String reason;

  const TithiEvaluation({
    required this.tithiNumber,
    required this.singleTithiNumber,
    required this.tithiName,
    required this.paksha,
    required this.isSuitable,
    this.conflictNote,
    required this.reason,
  });
}

class NakshatraEvaluation {
  final int nakshatraIndex; // 0..26
  final String nakshatraName;
  final bool isSuitable;
  final String? conflictNote;
  final String reason;

  const NakshatraEvaluation({
    required this.nakshatraIndex,
    required this.nakshatraName,
    required this.isSuitable,
    this.conflictNote,
    required this.reason,
  });
}

/// Four Classical Nama Yogam Types for Subha Muhurtham
enum SubhaNamaYogaType {
  amirtha(
    tamilLabel: 'அமிர்தயோகம்',
    englishLabel: 'Amirtha Yogam',
    isAuspicious: true,
    description: 'சகல சுப காரியங்களுக்கும் மிக உன்னதமானது',
  ),
  siddha(
    tamilLabel: 'சித்தயோகம்',
    englishLabel: 'Siddha Yogam',
    isAuspicious: true,
    description: 'காரிய வெற்றி தரக்கூடிய உகந்த யோகம்',
  ),
  marana(
    tamilLabel: 'மரணயோகம்',
    englishLabel: 'Marana Yogam',
    isAuspicious: false,
    description: 'சுப காரியங்களை முற்றிலும் தவிர்க்கவும்',
  ),
  prabalaArishta(
    tamilLabel: 'பிரபலாரிஷ்ட யோகம்',
    englishLabel: 'Prabala Arishta Yogam',
    isAuspicious: false,
    description: 'சுப காரியங்களுக்கு முற்றிலும் விலக்கப்பட வேண்டிய தோஷ யோகம்',
  );

  final String tamilLabel;
  final String englishLabel;
  final bool isAuspicious;
  final String description;

  const SubhaNamaYogaType({
    required this.tamilLabel,
    required this.englishLabel,
    required this.isAuspicious,
    required this.description,
  });
}

class YogaEvaluation {
  final String yogaName;
  final String amirthathiYoga;
  final bool isSuitable;
  final String reason;
  final SubhaNamaYogaType? primaryYoga;
  final SubhaNamaYogaType? nextYoga;
  final DateTime? transitionTime;

  const YogaEvaluation({
    required this.yogaName,
    required this.amirthathiYoga,
    required this.isSuitable,
    required this.reason,
    this.primaryYoga,
    this.nextYoga,
    this.transitionTime,
  });
}

class KaranaEvaluation {
  final String karanaName;
  final bool isSuitable;
  final String reason;

  const KaranaEvaluation({
    required this.karanaName,
    required this.isSuitable,
    required this.reason,
  });
}

/// Level 1: Aggregated General Day Suitability
class DaySuitabilityLevel1 {
  final VaaramEvaluation vaaram;
  final TithiEvaluation tithi;
  final NakshatraEvaluation nakshatra;
  final YogaEvaluation yoga;
  final KaranaEvaluation karana;
  final bool isLevel1Passed;
  final String summary;

  const DaySuitabilityLevel1({
    required this.vaaram,
    required this.tithi,
    required this.nakshatra,
    required this.yoga,
    required this.karana,
    required this.isLevel1Passed,
    required this.summary,
  });
}

// ===============================================================
// LEVEL 2: AVOIDANCE RULES MODELS
// ===============================================================

class MonthAvoidanceEvaluation {
  final String tamilMonth;
  final int tamilMonthIndex;
  final bool isMonthAvoided;
  final bool isSuitable;
  final String reason;

  const MonthAvoidanceEvaluation({
    required this.tamilMonth,
    required this.tamilMonthIndex,
    required this.isMonthAvoided,
    required this.isSuitable,
    required this.reason,
  });
}

class KariDayEvaluation {
  final int tamilDay;
  final bool isKariDay;
  final List<int> kariDaysInMonth;
  final bool isSuitable;
  final String reason;

  const KariDayEvaluation({
    required this.tamilDay,
    required this.isKariDay,
    required this.kariDaysInMonth,
    required this.isSuitable,
    required this.reason,
  });
}

class AvoidanceCheckItem {
  final String name;
  final String timingFormatted;
  final bool isAvoided;
  final String description;

  const AvoidanceCheckItem({
    required this.name,
    required this.timingFormatted,
    required this.isAvoided,
    required this.description,
  });
}

/// Level 2: Aggregated Avoidance Rules Result
class AvoidanceLevel2 {
  final MonthAvoidanceEvaluation monthCheck;
  final KariDayEvaluation kariDayCheck;
  final AvoidanceCheckItem rahuKalam;
  final AvoidanceCheckItem yamagandam;
  final AvoidanceCheckItem kuligai;
  final List<InauspiciousPeriod> allInauspiciousPeriods;
  final bool isLevel2Passed;
  final String summary;

  const AvoidanceLevel2({
    required this.monthCheck,
    required this.kariDayCheck,
    required this.rahuKalam,
    required this.yamagandam,
    required this.kuligai,
    required this.allInauspiciousPeriods,
    required this.isLevel2Passed,
    required this.summary,
  });
}

// ===============================================================
// LEVEL 3: PERSON-SPECIFIC JATHAGA CHECK MODELS
// ===============================================================

/// Level 3: Aggregated Person-Specific Result
class JathagaLevel3 {
  final bool hasBirthProfile;
  final ChandraBalaResult chandrashtama;
  final TaraBalaResult tarabalam;
  final GuruBalaResult? guruBalam;
  final SuryaBalaResult? suryaBalam;
  final bool isLevel3Passed;
  final String summary;

  const JathagaLevel3({
    required this.hasBirthProfile,
    required this.chandrashtama,
    required this.tarabalam,
    this.guruBalam,
    this.suryaBalam,
    required this.isLevel3Passed,
    required this.summary,
  });
}

// ===============================================================
// LEVEL 4: MUHURTHAM LAGNA CHECK MODELS
// ===============================================================

class MuhurthaLagnaEvaluation {
  final String lagnaRasi;
  final int lagnaIndex;
  final String lagnaDegreeStr;
  final bool isLagnaSuitable;

  final String lagnaLord;
  final String lagnaLordStrength; // 'வலுவானது (Strong)' / 'பலவீனமானது (Weak)'
  final String lagnaLordReason;

  final bool house7Checked;
  final String house7Reason;

  final bool house8Checked;
  final String house8Reason;

  final String marsCheck;
  final String saturnCheck;
  final String rahuCheck;
  final String ketuCheck;

  final bool isClean;
  final List<String> papaGrahaViolations;
  final String status;
  final String reason;

  const MuhurthaLagnaEvaluation({
    required this.lagnaRasi,
    required this.lagnaIndex,
    required this.lagnaDegreeStr,
    required this.isLagnaSuitable,
    required this.lagnaLord,
    required this.lagnaLordStrength,
    required this.lagnaLordReason,
    required this.house7Checked,
    required this.house7Reason,
    required this.house8Checked,
    required this.house8Reason,
    required this.marsCheck,
    required this.saturnCheck,
    required this.rahuCheck,
    required this.ketuCheck,
    required this.isClean,
    required this.papaGrahaViolations,
    required this.status,
    required this.reason,
  });
}

// ===============================================================
// EXISTING / COMPATIBILITY MODELS
// ===============================================================

/// Panchanga Five Angas evaluation result
class PanchangaAngasResult {
  final String tithiName;
  final int tithiNumber;
  final String paksha;
  final bool isTithiPreferred;
  final String tithiReason;

  final String weekdayName;
  final int weekdayNumber; // 1=Mon..7=Sun
  final bool isVaraPreferred;
  final String varaReason;

  final String nakshatraName;
  final int nakshatraIndex; // 0..26
  final bool isNakshatraSuitable;
  final String nakshatraReason;

  final String yogaName;
  final String amirthathiYoga;
  final bool isYogaAuspicious;
  final String yogaReason;

  final String karanaName;
  final bool isKaranaAuspicious;
  final String karanaReason;

  final SubhaNamaYogaType? primaryNamaYoga;
  final SubhaNamaYogaType? nextNamaYoga;
  final DateTime? yogaTransitionTime;

  const PanchangaAngasResult({
    required this.tithiName,
    required this.tithiNumber,
    required this.paksha,
    required this.isTithiPreferred,
    required this.tithiReason,
    required this.weekdayName,
    required this.weekdayNumber,
    required this.isVaraPreferred,
    required this.varaReason,
    required this.nakshatraName,
    required this.nakshatraIndex,
    required this.isNakshatraSuitable,
    required this.nakshatraReason,
    required this.yogaName,
    required this.amirthathiYoga,
    required this.isYogaAuspicious,
    required this.yogaReason,
    required this.karanaName,
    required this.isKaranaAuspicious,
    required this.karanaReason,
    this.primaryNamaYoga,
    this.nextNamaYoga,
    this.yogaTransitionTime,
  });
}

/// Tara Bala evaluation result (1..9 cyclical)
class TaraBalaResult {
  final int taraNumber; // 1..9
  final String taraName;
  final bool isAccepted;
  final String status;
  final String reason;

  const TaraBalaResult({
    required this.taraNumber,
    required this.taraName,
    required this.isAccepted,
    required this.status,
    required this.reason,
  });
}

/// Chandra Bala evaluation result
class ChandraBalaResult {
  final String birthRasi;
  final String moonRasi;
  final int relativeHouse; // 1..12
  final bool isPreferred;
  final bool isChandrashtama;
  final String status;
  final String reason;

  const ChandraBalaResult({
    required this.birthRasi,
    required this.moonRasi,
    required this.relativeHouse,
    required this.isPreferred,
    required this.isChandrashtama,
    required this.status,
    required this.reason,
  });
}

/// Guru Bala evaluation result (for Marriage)
class GuruBalaResult {
  final String birthRasi;
  final String jupiterRasi;
  final int relativeHouse; // 1..12
  final bool isAuspicious;
  final String status;
  final String reason;

  const GuruBalaResult({
    required this.birthRasi,
    required this.jupiterRasi,
    required this.relativeHouse,
    required this.isAuspicious,
    required this.status,
    required this.reason,
  });
}

/// Surya Bala evaluation result
class SuryaBalaResult {
  final String birthRasi;
  final String sunRasi;
  final int relativeHouse; // 1..12
  final bool isAuspicious;
  final String status;
  final String reason;

  const SuryaBalaResult({
    required this.birthRasi,
    required this.sunRasi,
    required this.relativeHouse,
    required this.isAuspicious,
    required this.status,
    required this.reason,
  });
}

/// Lagna Shuddhi evaluation for a specific candidate time
class LagnaShuddhiResult {
  final String lagnaRasi;
  final String lagnaDegreeStr;
  final bool isAshtamaLagna;
  final bool isClean;
  final List<String> maleficPlanetsIn7812;
  final String status;
  final String reason;

  const LagnaShuddhiResult({
    required this.lagnaRasi,
    required this.lagnaDegreeStr,
    required this.isAshtamaLagna,
    required this.isClean,
    required this.maleficPlanetsIn7812,
    required this.status,
    required this.reason,
  });
}

/// Panchaka Dosha evaluation: (Day + Tithi + Nakshatra + Lagna) % 9
class PanchakaResult {
  final int dayVal;
  final int tithiVal;
  final int nakshatraVal;
  final int lagnaVal;
  final int total;
  final int remainder;
  final String typeName;
  final bool isGood;
  final String reason;

  const PanchakaResult({
    required this.dayVal,
    required this.tithiVal,
    required this.nakshatraVal,
    required this.lagnaVal,
    required this.total,
    required this.remainder,
    required this.typeName,
    required this.isGood,
    required this.reason,
  });
}

/// Inauspicious time window (Rahu Kalam, Yamagandam, Gulikai, Visha Kadigai, Sandhya)
class InauspiciousPeriod {
  final String name;
  final DateTime start;
  final DateTime end;
  final String timingFormatted;
  final String description;

  const InauspiciousPeriod({
    required this.name,
    required this.start,
    required this.end,
    required this.timingFormatted,
    required this.description,
  });
}

/// Continuous Auspicious Muhurtham Window
class SubhaTimeWindow {
  final DateTime start;
  final DateTime end;
  final String timingFormatted;
  final String durationFormatted;
  final String lagnaName;
  final String panchakaName;
  final double suitabilityScore; // 0..100
  final List<String> reasons;
  final MuhurthaLagnaEvaluation? lagnaEvaluation;

  const SubhaTimeWindow({
    required this.start,
    required this.end,
    required this.timingFormatted,
    required this.durationFormatted,
    required this.lagnaName,
    required this.panchakaName,
    required this.suitabilityScore,
    required this.reasons,
    this.lagnaEvaluation,
  });
}

/// Complete Muhurtham Calculation Result for a selected Date & Location
class MuhurthaResult {
  final DateTime date;
  final GeoLocation location;
  final MuhurthaCategory category;
  final BirthProfile? birthProfile;

  final String tamilMonth;
  final int tamilDay;
  final String tamilYearName;
  final bool isMonthPreferred;
  final String monthRestrictionReason;
  final List<String> monthSunyamRasis;
  final bool isKathiriAgniActive;
  final String kathiriReason;

  final DateTime sunrise;
  final DateTime sunset;
  final DateTime solarNoon;

  final PanchangaAngasResult angas;
  final TaraBalaResult? taraBala;
  final ChandraBalaResult? chandraBala;
  final GuruBalaResult? guruBala;
  final SuryaBalaResult? suryaBala;

  final SubhaTimeWindow? abhijitMuhurtham;
  final List<InauspiciousPeriod> inauspiciousPeriods;
  final List<SubhaTimeWindow> validWindows;
  final String summaryVerdict;

  // Transparent 4-Level Evaluation Hierarchy
  final DaySuitabilityLevel1 level1Day;
  final AvoidanceLevel2 level2Avoidance;
  final JathagaLevel3? level3Jathaga;
  final SubhaMuhurthamRules rules;
  final MuhurthamRulePreset rulePreset;
  final String? conflictNote;

  const MuhurthaResult({
    required this.date,
    required this.location,
    required this.category,
    this.birthProfile,
    required this.tamilMonth,
    required this.tamilDay,
    required this.tamilYearName,
    required this.isMonthPreferred,
    required this.monthRestrictionReason,
    required this.monthSunyamRasis,
    required this.isKathiriAgniActive,
    required this.kathiriReason,
    required this.sunrise,
    required this.sunset,
    required this.solarNoon,
    required this.angas,
    this.taraBala,
    this.chandraBala,
    this.guruBala,
    this.suryaBala,
    this.abhijitMuhurtham,
    required this.inauspiciousPeriods,
    required this.validWindows,
    required this.summaryVerdict,
    required this.level1Day,
    required this.level2Avoidance,
    this.level3Jathaga,
    required this.rules,
    required this.rulePreset,
    this.conflictNote,
  });

  /// Convenience getters distinguishing the evaluation layers
  bool get isGeneralDaySuitable => level1Day.isLevel1Passed && level2Avoidance.isLevel2Passed;
  bool get isPersonSuitable => level3Jathaga == null || level3Jathaga!.isLevel3Passed;
  bool get hasMuhurthaTimeWindows => validWindows.isNotEmpty;
  bool get isOverallSubhaMuhurthamDay => isGeneralDaySuitable && isPersonSuitable && hasMuhurthaTimeWindows;
}
