import '../models/kp2_planet.dart';
import 'kp2_nakshatra_engine.dart';

/// Pure functional KP Sub Lord Engine for KP Method 2
class KP2SubLordEngine {
  static const List<KP2Planet> sequence = KP2NakshatraEngine.vimshottariLords;

  /// Calculate KP Sub Lord for any given sidereal longitude
  static KP2Planet calculateSubLord(double longitude) {
    double norm = longitude % 360.0;
    if (norm < 0) norm += 360.0;

    final int nakIdx = (norm / KP2NakshatraEngine.nakshatraSpanDegrees).floor().clamp(0, 26);
    final double elapsedInNakDegrees = norm % KP2NakshatraEngine.nakshatraSpanDegrees;
    final double elapsedInNakMinutes = elapsedInNakDegrees * 60.0;

    final int startLordIdx = nakIdx % 9;
    double accumulatedMinutes = 0.0;

    for (int i = 0; i < 9; i++) {
      final currentLordIdx = (startLordIdx + i) % 9;
      final planet = sequence[currentLordIdx];
      final double subSpanMinutes = (planet.dashaYears / 120.0) * 800.0;

      accumulatedMinutes += subSpanMinutes;
      if (elapsedInNakMinutes < accumulatedMinutes || i == 8) {
        return planet;
      }
    }

    return sequence[startLordIdx];
  }

  /// Get start and end span in arcminutes within nakshatra for the sub lord
  static Map<String, dynamic> getSubLordSpan(double longitude) {
    double norm = longitude % 360.0;
    if (norm < 0) norm += 360.0;

    final int nakIdx = (norm / KP2NakshatraEngine.nakshatraSpanDegrees).floor().clamp(0, 26);
    final double elapsedInNakMinutes = (norm % KP2NakshatraEngine.nakshatraSpanDegrees) * 60.0;

    final int startLordIdx = nakIdx % 9;
    double startMin = 0.0;

    for (int i = 0; i < 9; i++) {
      final currentLordIdx = (startLordIdx + i) % 9;
      final planet = sequence[currentLordIdx];
      final double spanMin = (planet.dashaYears / 120.0) * 800.0;

      if (elapsedInNakMinutes < startMin + spanMin || i == 8) {
        return {
          'subLord': planet,
          'startMinutes': startMin,
          'endMinutes': startMin + spanMin,
          'spanMinutes': spanMin,
          'elapsedInSubMinutes': elapsedInNakMinutes - startMin,
        };
      }
      startMin += spanMin;
    }

    return {
      'subLord': sequence[startLordIdx],
      'startMinutes': 0.0,
      'endMinutes': 800.0,
      'spanMinutes': 800.0,
      'elapsedInSubMinutes': 0.0,
    };
  }
}
