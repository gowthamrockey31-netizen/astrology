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

  /// Calculates Arudam Rasi Index directly from the minute component:
  /// Every 5 minutes represents one Rasi starting at Mesham (0):
  /// 00-04 = Mesham (0), 05-09 = Rishabam (1), ..., 55-59 = Meenam (11)
  /// Formula: floor(minute / 5) % 12
  static int calculateArudamRasiIndex(int minute) {
    return (minute ~/ 5) % 12;
  }

  /// Calculates Arudam for a given query time, with optional custom Arudam number (1..12)
  static JamakkolSpecialPoint calculateArudam({
    required DateTime queryDateTime,
    required int udayamRasiIndex,
    double? udayamDegreeInRasi,
    int? customArudamNumber,
  }) {
    int rasiIdx;
    double degInRasi;
    double arudamLon;

    if (customArudamNumber != null && customArudamNumber >= 1 && customArudamNumber <= 12) {
      // User specified manual Arudam number 1..12
      rasiIdx = (customArudamNumber - 1) % 12;
      degInRasi = udayamDegreeInRasi ?? 15.0;
      arudamLon = normalize(rasiIdx * 30.0 + degInRasi);
    } else {
      // Traditional minute-based Arudam:
      // Every 5 minutes represents one Rasi (0..11) starting at Mesham (0).
      // Formula: rasiIndex = floor(minute / 5)
      rasiIdx = calculateArudamRasiIndex(queryDateTime.minute);
      final int minuteInSlot = queryDateTime.minute % 5;
      degInRasi = (minuteInSlot + (queryDateTime.second / 60.0)) * 6.0;
      arudamLon = normalize(rasiIdx * 30.0 + degInRasi);
    }

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
