import '../../services/astrology_calculator.dart';
import '../models/jamakkol_planet_models.dart';

/// Calculation engine for Kavippu (கவிப்பு)
/// In Jamakkol Prasannam, Kavippu is the obstruction / shadow point that indicates hindrances,
/// delays, losses, or negative interference in the query.
class KavippuCalculator {
  /// Normalize degrees strictly to [0.0, 360.0)
  static double normalize(double deg) {
    double n = deg % 360.0;
    if (n < 0) n += 360.0;
    return n;
  }

  /// Calculates Kavippu based on Sun sign, Weekday, Jamam, and Arudam
  static JamakkolSpecialPoint calculateKavippu({
    required double sunLongitude,
    required int weekdayNumber, // 1=Mon .. 7=Sun
    required int jamamPeriodIndex, // 1 to 8 within Day or Night
    required bool isDay,
    required double arudamLongitude,
    required int udayamRasiIndex,
  }) {
    final int sunRasiIndex = (normalize(sunLongitude) / 30.0).floor() % 12;

    // Traditional Jamakkol weekday offset signs
    final int weekdayOffsetSigns = (weekdayNumber == 6)
        ? 0
        : ((weekdayNumber == 7) ? 1 : (weekdayNumber + 1) % 7);

    // Day & Night base signs from Sun's position
    final double dayJamam1Base = normalize((sunRasiIndex + 3 + weekdayOffsetSigns) * 30.0);
    final double nightJamam1Base = normalize((sunRasiIndex + 2 + weekdayOffsetSigns) * 30.0);

    final int jamamIdxZeroBased = (jamamPeriodIndex - 1).clamp(0, 7);
    final double kavippuBase = isDay
        ? normalize(dayJamam1Base + ((jamamIdxZeroBased ~/ 2) * 60.0))
        : normalize(nightJamam1Base + (jamamIdxZeroBased * 60.0));

    // Kavippu moves counter-clockwise (anti-zodiac) by the value of Arudam
    final double kavippuLon = normalize(kavippuBase - arudamLongitude);
    final int rasiIdx = (kavippuLon / 30.0).floor() % 12;
    final double degInRasi = kavippuLon % 30.0;

    // Derived Star & Pada
    final totalMinutes = kavippuLon * 60.0;
    final padaIndex = (totalMinutes / 200.0).floor().clamp(0, 107);
    final nakIdx = (padaIndex ~/ 4).clamp(0, 26);
    final pada = (padaIndex % 4) + 1;

    final formattedDms = AstrologyCalculator.formatRasiDegree(degInRasi);
    final int houseFromUdayam = (((rasiIdx - udayamRasiIndex) % 12 + 12) % 12) + 1;

    return JamakkolSpecialPoint(
      type: SpecialPointType.kavippu,
      nameEn: 'Kavippu',
      nameTa: 'கவிப்பு',
      shortCode: 'கவி',
      absoluteLongitude: kavippuLon,
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
      descriptionTa: 'தடை, தாமதம், இழப்பு, மறைமுக எதிர்ப்புகளைக் குறிக்கும் கவிப்பு புள்ளி',
    );
  }
}
