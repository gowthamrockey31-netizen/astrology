/// Comprehensive Yogi, Ava Yogi, and Anu Yogi calculation result
class YogiCalculationResult {
  final double sunLongitude;
  final double moonLongitude;
  final double pushyaOffset; // 93° 20' = 93.333333°
  final double yogiPointLongitude; // 0..360°
  
  // Yogi Details
  final String yogiRasiTa;
  final String yogiRasiEn;
  final int yogiRasiIndex;
  final String yogiDegreeFormatted;
  final String yogiNakshatraTa;
  final String yogiNakshatraEn;
  final int yogiPada;
  final String yogiPlanetTa;
  final String yogiPlanetEn;

  // Ava Yogi Details (6th Nakshatra Lord / Yogi + 186°40')
  final double avaYogiPointLongitude;
  final String avaYogiRasiTa;
  final String avaYogiNakshatraTa;
  final String avaYogiPlanetTa;
  final String avaYogiPlanetEn;

  // Anu Yogi Details (Duplicate Yogi helper)
  final String anuYogiNakshatraTa;
  final String anuYogiPlanetTa;

  // Explanation
  final String yogiDescription;
  final String avaYogiDescription;

  const YogiCalculationResult({
    required this.sunLongitude,
    required this.moonLongitude,
    required this.pushyaOffset,
    required this.yogiPointLongitude,
    required this.yogiRasiTa,
    required this.yogiRasiEn,
    required this.yogiRasiIndex,
    required this.yogiDegreeFormatted,
    required this.yogiNakshatraTa,
    required this.yogiNakshatraEn,
    required this.yogiPada,
    required this.yogiPlanetTa,
    required this.yogiPlanetEn,
    required this.avaYogiPointLongitude,
    required this.avaYogiRasiTa,
    required this.avaYogiNakshatraTa,
    required this.avaYogiPlanetTa,
    required this.avaYogiPlanetEn,
    required this.anuYogiNakshatraTa,
    required this.anuYogiPlanetTa,
    required this.yogiDescription,
    required this.avaYogiDescription,
  });
}
