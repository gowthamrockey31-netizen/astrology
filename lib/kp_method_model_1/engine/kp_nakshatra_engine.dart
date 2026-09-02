import '../../services/astrology_calculator.dart';

class KPNakshatraInfo {
  final int index;
  final String nameEn;
  final String nameTa;
  final String lordEn;
  final String lordTa;
  final int pada;
  final double degreeInNakshatra;
  final double elapsedMinutes;
  final double remainingMinutes;

  const KPNakshatraInfo({
    required this.index,
    required this.nameEn,
    required this.nameTa,
    required this.lordEn,
    required this.lordTa,
    required this.pada,
    required this.degreeInNakshatra,
    required this.elapsedMinutes,
    required this.remainingMinutes,
  });
}

/// Standard 27 Nakshatra division engine
class KPNakshatraEngine {
  static const double nakshatraSpan = 360.0 / 27.0; // 13.333333° = 13° 20' = 800 minutes
  static const double padaSpan = nakshatraSpan / 4.0; // 3.333333° = 3° 20' = 200 minutes

  static const List<String> dashaLordSequenceEn = [
    'Ketu', 'Venus', 'Sun', 'Moon', 'Mars', 'Rahu', 'Jupiter', 'Saturn', 'Mercury'
  ];

  static const List<String> dashaLordSequenceTa = [
    'கேது', 'சுக்கிரன்', 'சூரியன்', 'சந்திரன்', 'செவ்வாய்', 'ராகு', 'குரு', 'சனி', 'புதன்'
  ];

  static const List<String> signLordsEn = [
    'Mars', 'Venus', 'Mercury', 'Moon', 'Sun', 'Mercury',
    'Venus', 'Mars', 'Jupiter', 'Saturn', 'Saturn', 'Jupiter'
  ];

  static const List<String> signLordsTa = [
    'செவ்வாய்', 'சுக்கிரன்', 'புதன்', 'சந்திரன்', 'சூரியன்', 'புதன்',
    'சுக்கிரன்', 'செவ்வாய்', 'குரு', 'சனி', 'சனி', 'குரு'
  ];

  static const Map<String, double> vimshottariYears = {
    'Ketu': 7.0,
    'Venus': 20.0,
    'Sun': 6.0,
    'Moon': 10.0,
    'Mars': 7.0,
    'Rahu': 18.0,
    'Jupiter': 16.0,
    'Saturn': 19.0,
    'Mercury': 17.0,
  };

  /// Compute nakshatra details from sidereal longitude (0..360)
  static KPNakshatraInfo calculate(double siderealLongitude) {
    final norm = AstrologyCalculator.normalizeDegrees(siderealLongitude);
    final int nakIdx = (norm / nakshatraSpan).floor().clamp(0, 26);
    final double offsetDeg = norm - (nakIdx * nakshatraSpan);
    final int pada = (offsetDeg / padaSpan).floor().clamp(0, 3) + 1;

    final int lordIdx = nakIdx % 9;
    final lordEn = dashaLordSequenceEn[lordIdx];
    final lordTa = dashaLordSequenceTa[lordIdx];

    final elapsedMin = offsetDeg * 60.0;
    final remainingMin = 800.0 - elapsedMin;

    return KPNakshatraInfo(
      index: nakIdx,
      nameEn: AstrologyCalculator.nakshatrasEn[nakIdx],
      nameTa: AstrologyCalculator.nakshatrasTa[nakIdx],
      lordEn: lordEn,
      lordTa: lordTa,
      pada: pada,
      degreeInNakshatra: offsetDeg,
      elapsedMinutes: elapsedMin,
      remainingMinutes: remainingMin,
    );
  }
}
