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

  /// Determine Sun's Veedhi Rasi Index (1..3) from the actual Sun Rasi (1..12):
  /// Mesham = 1, Rishabam = 2, Mithunam = 3, Kadagam = 4, Simham = 5, Kanni = 6,
  /// Thulam = 7, Viruchigam = 8, Dhanusu = 9, Magaram = 10, Kumbam = 11, Meenam = 12.
  ///
  /// Mesha Veedhi (Index = 1): Rishabam (2), Mithunam (3), Kadagam (4), Simham (5)
  /// Rishabha Veedhi (Index = 2): Kanni (6), Thulam (7), Meenam (12), Mesham (1)
  /// Mithuna Veedhi (Index = 3): Viruchigam (8), Dhanusu (9), Magaram (10), Kumbam (11)
  static int getSunVeedhiIndex(int sunRasi1) {
    final int norm = ((sunRasi1 - 1) % 12 + 12) % 12 + 1;
    if (norm >= 2 && norm <= 5) {
      return 1; // Mesha Veedhi
    }
    if (norm == 6 || norm == 7 || norm == 12 || norm == 1) {
      return 2; // Rishabha Veedhi
    }
    if (norm >= 8 && norm <= 11) {
      return 3; // Mithuna Veedhi
    }
    return 1;
  }

  /// Sun Veedhi Rasi Name in English
  static String getSunVeedhiNameEn(int sunVeedhiIndex) {
    switch (sunVeedhiIndex) {
      case 1:
        return 'Mesham';
      case 2:
        return 'Rishabam';
      case 3:
        return 'Mithunam';
      default:
        return 'Mesham';
    }
  }

  /// Sun Veedhi Rasi Name in Tamil
  static String getSunVeedhiNameTa(int sunVeedhiIndex) {
    switch (sunVeedhiIndex) {
      case 1:
        return 'மேஷம்';
      case 2:
        return 'ரிஷபம்';
      case 3:
        return 'மிதுனம்';
      default:
        return 'மேஷம்';
    }
  }

  /// Calculates the clockwise distance from Aarudham (1..12) to Sun Veedhi Rasi (1..3).
  /// Formula: ((sunVeedhiIndex - aarudhamIndex) + 12) % 12
  static int calculateClockwiseDistance({
    required int aarudamRasi1,
    required int sunVeedhiIndex,
  }) {
    final int normAarudam = ((aarudamRasi1 - 1) % 12 + 12) % 12 + 1;
    final int normVeedhi = ((sunVeedhiIndex - 1) % 12 + 12) % 12 + 1;
    return ((normVeedhi - normAarudam) + 12) % 12;
  }

  /// Calculates Kavippu Rasi (1..12) from Udhayam (1..12) by moving clockwise
  /// by the calculated clockwise distance:
  /// Start = Udhayam Rasi, Count = calculated clockwise distance.
  /// Normalized strictly to 1..12 (1 = Mesham .. 12 = Meenam).
  static int calculateKavippuRasi1({
    required int udayamRasi1,
    required int clockwiseDistance,
  }) {
    final int normUdayam = ((udayamRasi1 - 1) % 12 + 12) % 12 + 1;
    return ((normUdayam - 1 + clockwiseDistance) % 12) + 1;
  }

  /// Determines KavippuBase longitude from Sun Rasi, Weekday, and Jamam (legacy helper)
  static double calculateKavippuBase({
    required int weekdayNumber, // 1=Mon .. 7=Sun
    required int jamamIndex,    // 0..7 (0-indexed)
    required bool isDay,
    required int sunRasiIndex,
  }) {
    const dayWeekdayOffsets = {
      7: 5, // Sun
      1: 6, // Mon
      2: 0, // Tue
      3: 1, // Wed
      4: 2, // Thu
      5: 4, // Fri -> Base = Makaram (270°) for Jamam 1
      6: 3, // Sat -> Base = Dhanusu (240°) for Jamam 1
    };

    const nightWeekdayOffsets = {
      7: 3, 1: 4, 2: 5, 3: 6, 4: 0, 5: 1, 6: 2,
    };

    final int offset = isDay
        ? (dayWeekdayOffsets[weekdayNumber] ?? 4)
        : (nightWeekdayOffsets[weekdayNumber] ?? 1);

    final double baseJamam1 = normalize((sunRasiIndex + offset) * 30.0);
    final double jamamProgression = isDay
        ? ((jamamIndex ~/ 2) * 60.0)
        : 60.0;

    return normalize(baseJamam1 + jamamProgression);
  }

  /// Calculates Kavippu using the authoritative Jamakkol dynamic formula:
  /// - Kavippu changes one rasi for every 5 minutes
  /// - Kavippu moves ANTI-CLOCKWISE through the rasi chart
  /// - Uses Sun Veedhi Rasi + clockwise distance from Arudham to Sun Veedhi from Udayam
  /// - Preserves dynamic degree precision in reverse direction
  static JamakkolSpecialPoint calculateKavippu({
    DateTime? queryDateTime,
    required int udayamRasiIndex, // 0..11
    double? udayamDegreeInRasi,
    int? arudamRasiIndex,         // 0..11
    double? arudamLongitude,
    double sunLongitude = 0.0,
    int weekdayNumber = 5,
    int jamamPeriodIndex = 3,
    bool isDay = true,
  }) {
    // 1. Obtain Sun Rasi (1..12) and Sun Veedhi Index (1..3)
    final int sunRasi1 = (normalize(sunLongitude) / 30.0).floor() % 12 + 1;
    final int sunVeedhiIndex = getSunVeedhiIndex(sunRasi1);

    // 2. Determine Arudam Rasi (1..12) and degree within 5-minute slot
    int aarudamRasi1;
    double degInSlot;

    if (queryDateTime != null) {
      final int minuteInSlot = queryDateTime.minute % 5;
      degInSlot = (minuteInSlot + (queryDateTime.second / 60.0) + (queryDateTime.millisecond / 60000.0)) * 6.0;
      if (arudamRasiIndex != null) {
        aarudamRasi1 = (arudamRasiIndex % 12) + 1;
      } else {
        aarudamRasi1 = (queryDateTime.minute ~/ 5) % 12 + 1;
      }
    } else if (arudamLongitude != null) {
      final norm = normalize(arudamLongitude);
      aarudamRasi1 = (norm / 30.0).floor() % 12 + 1;
      degInSlot = norm % 30.0;
    } else if (arudamRasiIndex != null) {
      aarudamRasi1 = (arudamRasiIndex % 12) + 1;
      degInSlot = udayamDegreeInRasi ?? 0.0;
    } else {
      aarudamRasi1 = 1;
      degInSlot = 0.0;
    }

    // 3. Clockwise distance from Aarudham (1..12) to Sun Veedhi Rasi (1..3)
    final int clockwiseDist = calculateClockwiseDistance(
      aarudamRasi1: aarudamRasi1,
      sunVeedhiIndex: sunVeedhiIndex,
    );

    // 4. Kavippu Rasi (1..12) from Udhayam (1..12)
    final int udayamRasi1 = (udayamRasiIndex % 12) + 1;
    final int kavippuRasi1 = calculateKavippuRasi1(
      udayamRasi1: udayamRasi1,
      clockwiseDistance: clockwiseDist,
    );
    final int rasiIdx = kavippuRasi1 - 1;

    // 5. 5-minute interval progression moving ANTI-CLOCKWISE
    double degInRasi = 30.0 - degInSlot;
    if (degInRasi >= 30.0) degInRasi = 29.9999;
    if (degInRasi < 0.0) degInRasi = 0.0;

    final double kavippuLon = normalize(rasiIdx * 30.0 + degInRasi);

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
