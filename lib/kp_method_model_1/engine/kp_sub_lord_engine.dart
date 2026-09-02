import 'kp_nakshatra_engine.dart';

class KPSubLordInfo {
  final String subLordEn;
  final String subLordTa;
  final double subStartDeg;
  final double subSpanDeg;
  final double offsetInSubDeg;

  const KPSubLordInfo({
    required this.subLordEn,
    required this.subLordTa,
    required this.subStartDeg,
    required this.subSpanDeg,
    required this.offsetInSubDeg,
  });
}

/// Engine for calculating proportional Vimshottari Sub-Lord divisions
class KPSubLordEngine {
  /// Calculate the Sub Lord for any sidereal longitude
  static KPSubLordInfo calculate(double siderealLongitude) {
    const double nakSpan = KPNakshatraEngine.nakshatraSpan; // 13.333333°
    final norm = siderealLongitude % 360.0;
    final int nakIdx = (norm / nakSpan).floor().clamp(0, 26);
    final double nakOffset = norm - (nakIdx * nakSpan);

    final int starLordIdx = nakIdx % 9;

    double accumulatedDeg = 0.0;
    int subLordIdx = starLordIdx;
    double chosenSpan = 0.0;
    double chosenStart = 0.0;

    for (int i = 0; i < 9; i++) {
      final int currentIdx = (starLordIdx + i) % 9;
      final String planet = KPNakshatraEngine.dashaLordSequenceEn[currentIdx];
      final double years = KPNakshatraEngine.vimshottariYears[planet]!;
      final double span = (years / 120.0) * nakSpan;

      if (i == 8 || (nakOffset >= accumulatedDeg && nakOffset < (accumulatedDeg + span - 1e-9))) {
        subLordIdx = currentIdx;
        chosenStart = accumulatedDeg;
        chosenSpan = span;
        break;
      }
      accumulatedDeg += span;
    }

    final subLordEn = KPNakshatraEngine.dashaLordSequenceEn[subLordIdx];
    final subLordTa = KPNakshatraEngine.dashaLordSequenceTa[subLordIdx];
    final offsetInSub = (nakOffset - chosenStart).clamp(0.0, chosenSpan);

    return KPSubLordInfo(
      subLordEn: subLordEn,
      subLordTa: subLordTa,
      subStartDeg: chosenStart,
      subSpanDeg: chosenSpan,
      offsetInSubDeg: offsetInSub,
    );
  }
}
