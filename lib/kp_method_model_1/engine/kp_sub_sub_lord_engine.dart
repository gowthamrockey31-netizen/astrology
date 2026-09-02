import 'kp_nakshatra_engine.dart';
import 'kp_sub_lord_engine.dart';

class KPSubSubLordInfo {
  final String subSubLordEn;
  final String subSubLordTa;
  final double subSubSpanDeg;

  const KPSubSubLordInfo({
    required this.subSubLordEn,
    required this.subSubLordTa,
    required this.subSubSpanDeg,
  });
}

/// Engine for calculating proportional Vimshottari Sub-Sub-Lord divisions
class KPSubSubLordEngine {
  /// Calculate the Sub-Sub Lord for any sidereal longitude
  static KPSubSubLordInfo calculate(double siderealLongitude) {
    final subInfo = KPSubLordEngine.calculate(siderealLongitude);

    final int subLordIdx = KPNakshatraEngine.dashaLordSequenceEn.indexOf(subInfo.subLordEn);
    final double subSpan = subInfo.subSpanDeg;
    final double offsetInSub = subInfo.offsetInSubDeg;

    double accumulatedSubSub = 0.0;
    int subSubLordIdx = subLordIdx;
    double chosenSubSubSpan = 0.0;

    for (int j = 0; j < 9; j++) {
      final int currentIdx = (subLordIdx + j) % 9;
      final String planet = KPNakshatraEngine.dashaLordSequenceEn[currentIdx];
      final double years = KPNakshatraEngine.vimshottariYears[planet]!;
      final double span = (years / 120.0) * subSpan;

      if (j == 8 || (offsetInSub >= accumulatedSubSub && offsetInSub < (accumulatedSubSub + span - 1e-9))) {
        subSubLordIdx = currentIdx;
        chosenSubSubSpan = span;
        break;
      }
      accumulatedSubSub += span;
    }

    return KPSubSubLordInfo(
      subSubLordEn: KPNakshatraEngine.dashaLordSequenceEn[subSubLordIdx],
      subSubLordTa: KPNakshatraEngine.dashaLordSequenceTa[subSubLordIdx],
      subSubSpanDeg: chosenSubSubSpan,
    );
  }
}
