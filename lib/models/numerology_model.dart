/// Numerology calculation system (Chaldean / Pythagorean)
enum NumerologySystem {
  chaldean('கீரோ / சால்தியன் முறை (Chaldean)', 'அதிர்வு & ஒலி அடிப்படையிலான பாரம்பரிய எண் கணிதம்'),
  pythagorean('பித்தகோரியன் முறை (Pythagorean)', '1 முதல் 9 வரிசை எண் கணித முறை');

  final String labelTa;
  final String descriptionTa;
  const NumerologySystem(this.labelTa, this.descriptionTa);
}

/// Numerology Result
class NumerologyResult {
  final DateTime birthDate;
  final String personName;
  final NumerologySystem system;

  // Numbers
  final int birthNumber; // 1..9 (Moolank / Janmank)
  final String birthNumberLordTa;
  final String birthNumberTraitTa;

  final int lifePathNumber; // 1..9 (Destiny / Bhagyank / Master 11, 22, 33)
  final String lifePathLordTa;
  final String lifePathTraitTa;

  final int nameNumber; // Total compound reduced
  final int nameCompoundNumber; // Raw compound total (e.g. 37, 45, 51)
  final String nameNumberLordTa;
  final String nameNumberVibrationTa;

  // Compatibility & Guidance
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
    required this.birthNumberLordTa,
    required this.birthNumberTraitTa,
    required this.lifePathNumber,
    required this.lifePathLordTa,
    required this.lifePathTraitTa,
    required this.nameNumber,
    required this.nameCompoundNumber,
    required this.nameNumberLordTa,
    required this.nameNumberVibrationTa,
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
