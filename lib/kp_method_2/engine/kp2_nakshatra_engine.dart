import '../models/kp2_planet.dart';

/// Pure functional Nakshatra Engine for KP Method 2
class KP2NakshatraEngine {
  static const List<String> nakshatrasTa = [
    'அஸ்வினி',
    'பரணி',
    'கார்த்திகை',
    'ரோகிணி',
    'மிருகசீரிஷம்',
    'திருவாதிரை',
    'புனர்பூசம்',
    'பூசம்',
    'ஆயில்யம்',
    'மகம்',
    'பூரம்',
    'உத்திரம்',
    'ஹஸ்தம்',
    'சித்திரை',
    'சுவாதி',
    'விசாகம்',
    'அனுஷம்',
    'கேட்டை',
    'மூலம்',
    'பூராடம்',
    'உத்திராடம்',
    'திருவோணம்',
    'அவிட்டம்',
    'சதயம்',
    'பூரட்டாதி',
    'உத்தரட்டாதி',
    'ரேவதி',
  ];

  static const List<KP2Planet> vimshottariLords = [
    KP2Planet.ketu,
    KP2Planet.venus,
    KP2Planet.sun,
    KP2Planet.moon,
    KP2Planet.mars,
    KP2Planet.rahu,
    KP2Planet.jupiter,
    KP2Planet.saturn,
    KP2Planet.mercury,
  ];

  static const double nakshatraSpanDegrees = 360.0 / 27.0; // 13° 20' = 13.33333333°
  static const double padaSpanDegrees = nakshatraSpanDegrees / 4.0; // 3° 20' = 3.33333333°

  static int getNakshatraIndex(double longitude) {
    double norm = longitude % 360.0;
    if (norm < 0) norm += 360.0;
    return (norm / nakshatraSpanDegrees).floor().clamp(0, 26);
  }

  static String getNakshatraNameTa(int index) {
    return nakshatrasTa[index.clamp(0, 26)];
  }

  static int getPada(double longitude) {
    double norm = longitude % 360.0;
    if (norm < 0) norm += 360.0;
    final nakOffset = norm % nakshatraSpanDegrees;
    return (nakOffset / padaSpanDegrees).floor().clamp(0, 3) + 1;
  }

  static KP2Planet getStarLord(int nakshatraIndex) {
    return vimshottariLords[nakshatraIndex % 9];
  }
}
