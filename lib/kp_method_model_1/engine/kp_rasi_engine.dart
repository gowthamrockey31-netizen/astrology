import 'kp_degree_formatter.dart';

/// Representation of a Zodiac Rasi calculation result
class KPRasiInfo {
  final int index; // 0..11
  final String nameEn;
  final String nameTa;
  final double degreeInsideSign; // 0.0 .. <30.0
  final String degreeFormatted; // DD°MM'SS"

  const KPRasiInfo({
    required this.index,
    required this.nameEn,
    required this.nameTa,
    required this.degreeInsideSign,
    required this.degreeFormatted,
  });
}

/// KP Rasi Calculation Engine
class KPRasiEngine {
  /// 12 Zodiac signs in traditional Indian order (Index 0..11)
  static const List<String> rasiNamesTa = [
    'மேஷம்',
    'ரிஷபம்',
    'மிதுனம்',
    'கடகம்',
    'சிம்மம்',
    'கன்னி',
    'துலாம்',
    'விருச்சிகம்',
    'தனுசு',
    'மகரம்',
    'கும்பம்',
    'மீனம்',
  ];

  static const List<String> rasiNamesEn = [
    'Aries',
    'Taurus',
    'Gemini',
    'Cancer',
    'Leo',
    'Virgo',
    'Libra',
    'Scorpio',
    'Sagittarius',
    'Capricorn',
    'Aquarius',
    'Pisces',
  ];

  /// Calculate Rasi details from sidereal longitude (0°..360°)
  static KPRasiInfo calculate(double siderealLongitude) {
    // 1. Normalize
    double norm = siderealLongitude % 360.0;
    if (norm < 0) norm += 360.0;

    // 2. Index (0..11)
    int signIndex = (norm / 30.0).floor().clamp(0, 11);

    // 3. Degree inside sign (0..30°)
    double degreeInside = norm % 30.0;

    // 4. Exact DD°MM'SS" string
    final dms = KPDegreeFormatter.formatRasiDegree(norm);

    return KPRasiInfo(
      index: signIndex,
      nameEn: rasiNamesEn[signIndex],
      nameTa: rasiNamesTa[signIndex],
      degreeInsideSign: degreeInside,
      degreeFormatted: dms,
    );
  }
}
