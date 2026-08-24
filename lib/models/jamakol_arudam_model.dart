/// Jamakol Arudam calculation models
class JamakolPlanet {
  final String nameTa;
  final String symbol;
  final int rasiIndex; // 0..11
  final String rasiNameTa;
  final bool isSpecialPoint; // Udhayam, Aarudam, Kavippu, Sooriyan

  const JamakolPlanet({
    required this.nameTa,
    required this.symbol,
    required this.rasiIndex,
    required this.rasiNameTa,
    this.isSpecialPoint = false,
  });
}

class JamakolArudamResult {
  final DateTime queryTime;
  final int jamamNumber; // 1..8
  final bool isDayJamam;
  final String jamamNameTa;
  final String jamamLordTa;
  
  // 4 Fundamental Jamakol Special Points
  final JamakolPlanet udhayam;   // உதயம்
  final JamakolPlanet aarudam;   // ஆருடம்
  final JamakolPlanet kavippu;   // கவிப்பு
  final JamakolPlanet sooriyan;  // சூரியன்

  // 8 Jamakkol External Planets (ஜாமக்கோள் வெளி கிரகங்கள்)
  final List<JamakolPlanet> jamaPlanets;
  
  // Sky Ephemeris Planets (உள் கிரகங்கள்)
  final List<JamakolPlanet> skyPlanets;

  // Analysis & Interpretation
  final String generalPredictionTa;
  final String questionSuccessAnalysisTa;
  final List<String> favorableSignsTa;
  final List<String> obstructiveSignsTa;

  const JamakolArudamResult({
    required this.queryTime,
    required this.jamamNumber,
    required this.isDayJamam,
    required this.jamamNameTa,
    required this.jamamLordTa,
    required this.udhayam,
    required this.aarudam,
    required this.kavippu,
    required this.sooriyan,
    required this.jamaPlanets,
    required this.skyPlanets,
    required this.generalPredictionTa,
    required this.questionSuccessAnalysisTa,
    required this.favorableSignsTa,
    required this.obstructiveSignsTa,
  });
}
