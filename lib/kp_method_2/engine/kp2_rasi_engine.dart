import '../models/kp2_planet.dart';

/// Pure functional Rasi Engine for KP Method 2
class KP2RasiEngine {
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

  static const List<KP2Planet> rasiLords = [
    KP2Planet.mars,    // Mesham
    KP2Planet.venus,   // Rishabam
    KP2Planet.mercury, // Mithunam
    KP2Planet.moon,    // Kadagam
    KP2Planet.sun,     // Simmam
    KP2Planet.mercury, // Kanni
    KP2Planet.venus,   // Thulam
    KP2Planet.mars,    // Viruchigam
    KP2Planet.jupiter, // Dhanusu
    KP2Planet.saturn,  // Makaram
    KP2Planet.saturn,  // Kumbam
    KP2Planet.jupiter, // Meenam
  ];

  static int getRasiIndex(double longitude) {
    final norm = normalizeDegrees(longitude);
    return (norm / 30.0).floor() % 12;
  }

  static double getDegreeInRasi(double longitude) {
    final norm = normalizeDegrees(longitude);
    return norm % 30.0;
  }

  static String getRasiNameTa(int rasiIndex) {
    return rasiNamesTa[rasiIndex % 12];
  }

  static String getRasiNameEn(int rasiIndex) {
    return rasiNamesEn[rasiIndex % 12];
  }

  static KP2Planet getRasiLord(int rasiIndex) {
    return rasiLords[rasiIndex % 12];
  }

  static double normalizeDegrees(double deg) {
    double result = deg % 360.0;
    if (result < 0) result += 360.0;
    return result;
  }

  /// Format decimal degree into standard DD° MM' SS" format
  static String formatDms(double degWithinRasi) {
    double norm = degWithinRasi % 30.0;
    if (norm < 0) norm += 30.0;

    int d = norm.floor();
    double mf = (norm - d) * 60.0;
    int m = mf.floor();
    double sf = (mf - m) * 60.0;
    int s = sf.round();

    if (s >= 60) {
      s = 0;
      m++;
    }
    if (m >= 60) {
      m = 0;
      d++;
    }
    if (d >= 30) {
      d = 0;
    }

    final dStr = d.toString().padLeft(2, '0');
    final mStr = m.toString().padLeft(2, '0');
    final sStr = s.toString().padLeft(2, '0');
    return "$dStr° $mStr′ $sStr″";
  }
}
