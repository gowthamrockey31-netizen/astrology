import '../models/kp2_planet.dart';
import 'kp2_nakshatra_engine.dart';
import 'kp2_sub_lord_engine.dart';

/// Pure functional KP Sub-Sub Lord Engine for KP Method 2
class KP2SubSubLordEngine {
  static const List<KP2Planet> sequence = KP2NakshatraEngine.vimshottariLords;

  /// Calculate KP Sub-Sub Lord for any given sidereal longitude
  static KP2Planet calculateSubSubLord(double longitude) {
    final subSpan = KP2SubLordEngine.getSubLordSpan(longitude);
    final KP2Planet subLord = subSpan['subLord'] as KP2Planet;
    final double totalSubSpanMinutes = subSpan['spanMinutes'] as double;
    final double elapsedInSubMinutes = subSpan['elapsedInSubMinutes'] as double;

    final int startLordIdx = sequence.indexOf(subLord);
    double accumulatedMinutes = 0.0;

    for (int i = 0; i < 9; i++) {
      final currentLordIdx = (startLordIdx + i) % 9;
      final planet = sequence[currentLordIdx];
      final double subSubSpanMinutes = (planet.dashaYears / 120.0) * totalSubSpanMinutes;

      accumulatedMinutes += subSubSpanMinutes;
      if (elapsedInSubMinutes < accumulatedMinutes || i == 8) {
        return planet;
      }
    }

    return subLord;
  }
}
