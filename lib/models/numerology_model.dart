/// Numerology calculation system (Chaldean / Pythagorean)
enum NumerologySystem {
  chaldean('கீரோ / சால்தியன் முறை (Chaldean)', 'அதிர்வு & ஒலி அடிப்படையிலான பாரம்பரிய எண் கணிதம்'),
  pythagorean('பித்தகோரியன் முறை (Pythagorean)', '1 முதல் 9 வரிசை எண் கணித முறை');

  final String labelTa;
  final String descriptionTa;
  const NumerologySystem(this.labelTa, this.descriptionTa);
}

/// Result of a centralized number reduction
class NumberReductionResult {
  final int originalValue;
  final int compoundValue;
  final int reducedValue;
  final bool isMasterNumber;
  final List<int> stepSums;

  const NumberReductionResult({
    required this.originalValue,
    required this.compoundValue,
    required this.reducedValue,
    required this.isMasterNumber,
    required this.stepSums,
  });

  String get displayFormatted =>
      (compoundValue > 9 && compoundValue != reducedValue)
          ? '$compoundValue / $reducedValue'
          : '$reducedValue';
}

/// Name letter breakdown item
class NameLetterValue {
  final String letter;
  final int value;

  const NameLetterValue({required this.letter, required this.value});
}

/// Compound Number Detailed Interpretation
class CompoundNumberDetail {
  final int number;
  final int reducedNumber;
  final String lordTa;
  final String titleTa;
  final String descriptionTa;

  const CompoundNumberDetail({
    required this.number,
    required this.reducedNumber,
    required this.lordTa,
    required this.titleTa,
    required this.descriptionTa,
  });
}

/// Personal Cycle Results for Year, Month, Day
class PersonalCycleResult {
  final int targetYear;
  final int targetMonth;
  final int targetDay;

  final NumberReductionResult personalYear;
  final NumberReductionResult personalMonth;
  final NumberReductionResult personalDay;

  final String personalYearDescriptionTa;
  final String personalMonthDescriptionTa;
  final String personalDayDescriptionTa;

  const PersonalCycleResult({
    required this.targetYear,
    required this.targetMonth,
    required this.targetDay,
    required this.personalYear,
    required this.personalMonth,
    required this.personalDay,
    required this.personalYearDescriptionTa,
    required this.personalMonthDescriptionTa,
    required this.personalDayDescriptionTa,
  });
}

/// Enhanced Numerology Result
class NumerologyResult {
  final DateTime birthDate;
  final String personName;
  final NumerologySystem system;

  // 1. Birth Number (Janmank / Moolank)
  final int birthNumber; // 1..9
  final int birthCompoundNumber; // Raw day (e.g. 15, 24, 29)
  final NumberReductionResult birthReduction;
  final String birthNumberLordTa;
  final String birthNumberTraitTa;

  // 2. Life Path Number (Destiny / Bhagyank)
  final int lifePathNumber; // 1..9 or Master
  final int lifePathCompoundNumber; // Date sum (e.g. 37, 25)
  final NumberReductionResult lifePathReduction;
  final String lifePathLordTa;
  final String lifePathTraitTa;

  // 3. Attitude Number (Sun Number)
  final int attitudeNumber; // Day + Month
  final NumberReductionResult attitudeReduction;
  final String attitudeLordTa;
  final String attitudeTraitTa;

  // 4. Name Number (Namank)
  final int nameNumber; // Total compound reduced
  final int nameCompoundNumber; // Raw compound total (e.g. 37, 45, 51)
  final NumberReductionResult nameReduction;
  final List<NameLetterValue> letterBreakdown;
  final String nameNumberLordTa;
  final String nameNumberVibrationTa;

  // 5. Personal Cycles (Calculated for target date/year)
  final PersonalCycleResult personalCycles;

  // 6. Compound Details
  final CompoundNumberDetail? birthCompoundDetail;
  final CompoundNumberDetail? lifePathCompoundDetail;
  final CompoundNumberDetail? nameCompoundDetail;

  // 7. Compatibility & Guidance
  final List<int> friendlyNumbers;
  final List<int> enemyNumbers;
  final List<int> neutralNumbers;
  
  final List<String> luckyColorsTa;
  final List<String> luckyGemsTa;
  final List<String> luckyDaysTa;
  final List<int> luckyDates;
  final String careerGuidanceTa;

  const NumerologyResult({
    required this.birthDate,
    required this.personName,
    required this.system,
    required this.birthNumber,
    required this.birthCompoundNumber,
    required this.birthReduction,
    required this.birthNumberLordTa,
    required this.birthNumberTraitTa,
    required this.lifePathNumber,
    required this.lifePathCompoundNumber,
    required this.lifePathReduction,
    required this.lifePathLordTa,
    required this.lifePathTraitTa,
    required this.attitudeNumber,
    required this.attitudeReduction,
    required this.attitudeLordTa,
    required this.attitudeTraitTa,
    required this.nameNumber,
    required this.nameCompoundNumber,
    required this.nameReduction,
    required this.letterBreakdown,
    required this.nameNumberLordTa,
    required this.nameNumberVibrationTa,
    required this.personalCycles,
    this.birthCompoundDetail,
    this.lifePathCompoundDetail,
    this.nameCompoundDetail,
    required this.friendlyNumbers,
    required this.enemyNumbers,
    required this.neutralNumbers,
    required this.luckyColorsTa,
    required this.luckyGemsTa,
    required this.luckyDaysTa,
    required this.luckyDates,
    required this.careerGuidanceTa,
  });
}
