import '../../services/astrology_calculator.dart';
import '../models/jamakkol_planet_models.dart';

/// Calculation engine for Arudam (ஆருடம்)
/// In Jamakkol Prasannam, Arudam represents the matter inquired / object of the query / outcome.
class ArudamCalculator {
  /// Normalize degrees strictly to [0.0, 360.0)
  static double normalize(double deg) {
    double n = deg % 360.0;
    if (n < 0) n += 360.0;
    return n;
  }

  /// Calculates Arudam for a given query time, with optional custom Arudam number (1..12)
  static JamakkolSpecialPoint calculateArudam({
    required DateTime queryDateTime,
    required int udayamRasiIndex,
    double? udayamDegreeInRasi,
    int? customArudamNumber,
  }) {
    double arudamLon;

    if (customArudamNumber != null && customArudamNumber >= 1 && customArudamNumber <= 12) {
      // User specified manual Arudam number 1..12
      final deg = udayamDegreeInRasi ?? 15.0;
      arudamLon = normalize((customArudamNumber - 1) * 30.0 + deg);
    } else {
      // Traditional time-based Arudam:
      // The 60-minute clock hour is mapped onto the 12 signs (360°):
      // Each 5 minutes = 1 Rasi (30°), which gives 6° per minute (or 0.1° per second).
      final double curMinuteWithSec = queryDateTime.minute + (queryDateTime.second / 60.0);
      arudamLon = normalize(curMinuteWithSec * 6.0);
    }

    final int rasiIdx = (arudamLon / 30.0).floor() % 12;
    final double degInRasi = arudamLon % 30.0;

    // Derived Star & Pada
    final totalMinutes = arudamLon * 60.0;
    final padaIndex = (totalMinutes / 200.0).floor().clamp(0, 107);
    final nakIdx = (padaIndex ~/ 4).clamp(0, 26);
    final pada = (padaIndex % 4) + 1;

    final formattedDms = AstrologyCalculator.formatRasiDegree(degInRasi);
    final int houseFromUdayam = (((rasiIdx - udayamRasiIndex) % 12 + 12) % 12) + 1;

    return JamakkolSpecialPoint(
      type: SpecialPointType.arudam,
      nameEn: 'Arudam',
      nameTa: 'ஆருடம்',
      shortCode: 'ஆ',
      absoluteLongitude: arudamLon,
      rasiIndex: rasiIdx,
      rasiNameTa: AstrologyCalculator.rasiNamesTa[rasiIdx],
      rasiNameEn: AstrologyCalculator.rasiNamesEn[rasiIdx],
      degreeInRasi: degInRasi,
      formattedDms: formattedDms,
      nakshatraTa: AstrologyCalculator.nakshatrasTa[nakIdx],
      nakshatraEn: AstrologyCalculator.nakshatrasEn[nakIdx],
      nakshatraIndex: nakIdx,
      pada: pada,
      houseFromUdayam: houseFromUdayam,
      descriptionTa: 'கேட்கப்படும் காரியம் / பலன் அமையும் நிலையைக் குறிக்கும் புள்ளி',
    );
  }
}
