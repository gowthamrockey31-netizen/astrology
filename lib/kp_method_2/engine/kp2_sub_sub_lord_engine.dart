import '../models/kp2_planet.dart';
import 'kp2_nakshatra_engine.dart';
import 'kp2_sub_lord_engine.dart';

/// Pure functional KP Sub-Sub Lord and Sub-Sub-Sub Lord Engine for KP Method 2
class KP2SubSubLordEngine {
  static const List<KP2Planet> sequence = KP2NakshatraEngine.vimshottariLords;

  /// Get start and end span in arcminutes within sub lord for the sub-sub lord
  static Map<String, dynamic> getSubSubLordSpan(double longitude) {
    final subSpan = KP2SubLordEngine.getSubLordSpan(longitude);
    final KP2Planet subLord = subSpan['subLord'] as KP2Planet;
    final double totalSubSpanMinutes = subSpan['spanMinutes'] as double;
    final double elapsedInSubMinutes = subSpan['elapsedInSubMinutes'] as double;

    final int startLordIdx = sequence.indexOf(subLord);
    double startMin = 0.0;

    for (int i = 0; i < 9; i++) {
      final currentLordIdx = (startLordIdx + i) % 9;
      final planet = sequence[currentLordIdx];
      final double spanMin = (planet.dashaYears / 120.0) * totalSubSpanMinutes;

      if (elapsedInSubMinutes < startMin + spanMin || i == 8) {
        return {
          'subSubLord': planet,
          'startMinutes': startMin,
          'endMinutes': startMin + spanMin,
          'spanMinutes': spanMin,
          'elapsedInSubSubMinutes': elapsedInSubMinutes - startMin,
        };
      }
      startMin += spanMin;
    }

    return {
      'subSubLord': subLord,
      'startMinutes': 0.0,
      'endMinutes': totalSubSpanMinutes,
      'spanMinutes': totalSubSpanMinutes,
      'elapsedInSubSubMinutes': 0.0,
    };
  }

  /// Calculate KP Sub-Sub Lord for any given sidereal longitude
  static KP2Planet calculateSubSubLord(double longitude) {
    return getSubSubLordSpan(longitude)['subSubLord'] as KP2Planet;
  }

  /// Calculate KP Sub-Sub-Sub Lord for any given sidereal longitude (5th level)
  static KP2Planet calculateSubSubSubLord(double longitude) {
    final subSubSpan = getSubSubLordSpan(longitude);
    final KP2Planet subSubLord = subSubSpan['subSubLord'] as KP2Planet;
    final double totalSubSubSpanMinutes = subSubSpan['spanMinutes'] as double;
    final double elapsedInSubSubMinutes = subSubSpan['elapsedInSubSubMinutes'] as double;

    final int startLordIdx = sequence.indexOf(subSubLord);
    double accumulatedMinutes = 0.0;

    for (int i = 0; i < 9; i++) {
      final currentLordIdx = (startLordIdx + i) % 9;
      final planet = sequence[currentLordIdx];
      final double subSubSubSpanMinutes = (planet.dashaYears / 120.0) * totalSubSubSpanMinutes;

      accumulatedMinutes += subSubSubSpanMinutes;
      if (elapsedInSubSubMinutes < accumulatedMinutes || i == 8) {
        return planet;
      }
    }

    return subSubLord;
  }
}
