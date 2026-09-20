import 'dart:math' as math;
import 'astrology_calculator.dart';

/// Representation of an outer or inner Jamakkol planet/point
class JamakkolOuterPlanet {
  final String key;
  final String tamilName;
  final String shortSymbol;
  final double absoluteLongitude;
  final int rasiIndex;
  final double degreeInRasi;
  final String formattedDegree; // e.g. "344° 58'"
  final int borderSide; // 0: Top, 1: Right, 2: Bottom, 3: Left
  final int gridCol; // 0..3 for top/bottom or grid placement
  final int gridRow; // 0..3 for left/right

  const JamakkolOuterPlanet({
    required this.key,
    required this.tamilName,
    required this.shortSymbol,
    required this.absoluteLongitude,
    required this.rasiIndex,
    required this.degreeInRasi,
    required this.formattedDegree,
    required this.borderSide,
    required this.gridCol,
    required this.gridRow,
  });
}

/// Core Jamakkol Special Point (உதயம், ஆருடம், கவிப்பு, etc.)
class JamakkolPoint {
  final String name;
  final String tamilName;
  final String symbol;
  final double absoluteLongitude;
  final int rasiIndex;
  final double degreeInRasi;
  final int degree;
  final int minute;
  final String formattedDms; // e.g. "21° 56'"
  final String starName;
  final int pada;
  final String formattedStarPada; // e.g. "★ திருவோணம் - 4"
  final int houseFromUdhayam;

  const JamakkolPoint({
    required this.name,
    required this.tamilName,
    required this.symbol,
    required this.absoluteLongitude,
    required this.rasiIndex,
    required this.degreeInRasi,
    required this.degree,
    required this.minute,
    required this.formattedDms,
    required this.starName,
    required this.pada,
    required this.formattedStarPada,
    required this.houseFromUdhayam,
  });
}

/// Upagraha / Secondary prasannam point (எமகண்டம், மாந்தி, ராகு காலம், மிருத்யு)
class JamakkolUpagraha {
  final String key;
  final String tamilName;
  final String shortName; // "எம", "மாந்", "ரா.கா", "மிருத்யு", "லக்"
  final int rasiIndex;
  final int degree;
  final int minute;
  final String formattedDegree; // e.g. "25° 15'"
  final String colorCategory; // "red", "purple", "blue"

  const JamakkolUpagraha({
    required this.key,
    required this.tamilName,
    required this.shortName,
    required this.rasiIndex,
    required this.degree,
    required this.minute,
    required this.formattedDegree,
    required this.colorCategory,
  });
}

/// Gowri Panchangam Result
class GowriPanchangamResult {
  final String nameTa;
  final bool isGood;
  final String natureTa;

  const GowriPanchangamResult({
    required this.nameTa,
    required this.isGood,
    required this.natureTa,
  });
}

/// Full Calculated Dataset for Jamakkol Prasannam Rasi Chart
class JamakkolChartData {
  final DateTime queryDateTime;
  final String formattedDateTime;
  final String location;
  final int jamamNumber;
  final String jamamLord;
  final String weekdayNameEn;
  final String weekdayNameTa;
  final bool isDay;
  final JamakkolPoint udhayam;
  final JamakkolPoint aarudam;
  final JamakkolPoint kavippu;
  final List<JamakkolOuterPlanet> outerPlanets;
  final List<JamakkolUpagraha> upagrahas;
  final Map<int, List<JamakkolOuterPlanet>> outerPlanetsByRasi;
  final Map<int, List<JamakkolUpagraha>> upagrahasByRasi;
  final Map<int, List<JamakkolPoint>> specialPointsByRasi;
  final Map<String, PlanetDetail> skyPlanets;
  final Map<int, List<PlanetDetail>> skyPlanetsByRasi;

  const JamakkolChartData({
    required this.queryDateTime,
    required this.formattedDateTime,
    required this.location,
    required this.jamamNumber,
    required this.jamamLord,
    required this.weekdayNameEn,
    required this.weekdayNameTa,
    required this.isDay,
    required this.udhayam,
    required this.aarudam,
    required this.kavippu,
    required this.outerPlanets,
    required this.upagrahas,
    required this.outerPlanetsByRasi,
    required this.upagrahasByRasi,
    required this.specialPointsByRasi,
    required this.skyPlanets,
    required this.skyPlanetsByRasi,
  });
}

/// Engine that performs all mathematical Jamakkol Prasannam calculations
class JamakkolChartEngine {
  static const List<String> nakshatraNamesTa = [
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
    'அஸ்தம்',
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
    'உத்திரட்டாதி',
    'ரேவதி',
  ];

  static const List<String> weekdayNamesTa = [
    'ஞாயிறு',
    'திங்கள்',
    'செவ்வாய்',
    'புதன்',
    'வியாழன்',
    'வெள்ளி',
    'சனி',
  ];

  static const List<String> weekdayNamesEn = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
  ];

  /// Cycle of the 8 Jamakkol Outer Planets (spaced by exactly 45 degrees in counter-clockwise order)
  static const List<({String key, String tamil, String short})> outerPlanetCycle = [
    (key: 'Sun', tamil: 'சூரியன்', short: 'சூரி'),
    (key: 'Mars', tamil: 'செவ்வாய்', short: 'செவ்'),
    (key: 'Jupiter', tamil: 'குரு', short: 'குரு'),
    (key: 'Mercury', tamil: 'புதன்', short: 'புத'),
    (key: 'Venus', tamil: 'சுக்கிரன்', short: 'சுக்'),
    (key: 'Saturn', tamil: 'சனி', short: 'சனி'),
    (key: 'Moon', tamil: 'சந்திரன்', short: 'சந்'),
    (key: 'Rahu', tamil: 'பாம்பு', short: 'பாம்பு'),
  ];

  /// Index of each day lord in the outerPlanetCycle (Sun=0, Mars=1, Jupiter=2, Mercury=3, Venus=4, Saturn=5, Moon=6, Rahu=7)
  static const Map<String, int> planetCycleIndices = {
    'சூரியன்': 0,
    'செவ்வாய்': 1,
    'குரு': 2,
    'புதன்': 3,
    'சுக்கிரன்': 4,
    'சனி': 5,
    'சந்திரன்': 6,
    'பாம்பு': 7,
  };

  /// Order of Jamam lords for day jamams (Sun to Rahu)
  static const List<String> jamamLordsDay = [
    'சூரியன்',
    'செவ்வாய்',
    'குரு',
    'புதன்',
    'சுக்கிரன்',
    'சனி',
    'சந்திரன்',
    'பாம்பு',
  ];

  /// Normalizes angle strictly to [0.0, 360.0)
  static double normalizeDegrees(double deg) {
    double norm = deg % 360.0;
    if (norm < 0) norm += 360.0;
    return norm;
  }

  /// Calculates Star and Pada for any absolute longitude (0 to 360)
  static ({String star, int pada, String formatted}) getStarAndPada(double longitude) {
    final norm = normalizeDegrees(longitude);
    final totalMinutes = norm * 60.0;
    // 3° 20' = 200 minutes per pada
    final padaIndex = (totalMinutes / 200.0).floor().clamp(0, 107);
    final nakshatraIdx = (padaIndex ~/ 4).clamp(0, 26);
    final padaNum = (padaIndex % 4) + 1;
    final starName = nakshatraNamesTa[nakshatraIdx];
    return (
      star: starName,
      pada: padaNum,
      formatted: '★ $starName - $padaNum',
    );
  }

  /// Formats degree as DD° MM'
  static String formatDegreeMinute(double degreeVal) {
    final norm = normalizeDegrees(degreeVal);
    final d = norm.floor();
    final m = ((norm - d) * 60.0).round();
    if (m >= 60) {
      return "${d + 1}° 00'";
    }
    return "$d° ${m.toString().padLeft(2, '0')}'";
  }

  /// Maps Rasi index to its grid row, col and chart border placement
  /// South Indian 4x4 Grid:
  /// Row 0: Meenam (11), Mesham (0), Rishabam (1), Mithunam (2)  -> Top Border
  /// Row 1: Kumbam (10), Center,     Center,       Katakam (3)    -> Left/Right
  /// Row 2: Makaram (9), Center,     Center,       Simham (4)     -> Left/Right
  /// Row 3: Dhanusu (8), Viruchigam(7), Thulam (6), Kanni (5)     -> Bottom Border
  static ({int borderSide, int col, int row}) getRasiBorderInfo(int rasiIndex) {
    switch (rasiIndex) {
      case 11: // Meenam
        return (borderSide: 0, col: 0, row: 0); // Top left
      case 0: // Mesham
        return (borderSide: 0, col: 1, row: 0); // Top
      case 1: // Rishabam
        return (borderSide: 0, col: 2, row: 0); // Top
      case 2: // Mithunam
        return (borderSide: 0, col: 3, row: 0); // Top right
      case 3: // Katakam
        return (borderSide: 1, col: 3, row: 1); // Right
      case 4: // Simmam
        return (borderSide: 1, col: 3, row: 2); // Right
      case 5: // Kanni
        return (borderSide: 2, col: 3, row: 3); // Bottom right
      case 6: // Thulam
        return (borderSide: 2, col: 2, row: 3); // Bottom
      case 7: // Viruchigam
        return (borderSide: 2, col: 1, row: 3); // Bottom
      case 8: // Dhanusu
        return (borderSide: 2, col: 0, row: 3); // Bottom left
      case 9: // Makaram
        return (borderSide: 3, col: 0, row: 2); // Left
      case 10: // Kumbam
      default:
        return (borderSide: 3, col: 0, row: 1); // Left
    }
  }

  /// Calculates complete Jamakkol Prasannam data
  static JamakkolChartData calculate({
    required DateTime queryTime,
    required double latitude,
    required double longitude,
    double utcOffsetHours = 5.5,
    String locationName = 'Thiruvarur',
    int? customAarudamNumber,
  }) {
    // 1. Sunrise and Sunset
    final sunTimes = AstrologyCalculator.calculateSunriseSunset(
      queryTime,
      latitude,
      longitude,
      utcOffsetHours,
    );
    final sunrise = sunTimes['sunrise']!;
    final sunset = sunTimes['sunset']!;

    final bool isDay = !queryTime.isBefore(sunrise) && queryTime.isBefore(sunset);

    // 2. Daytime duration and elapsed minutes
    double totalDayMinutes;
    double elapsedMinutes;
    if (isDay) {
      totalDayMinutes = sunset.difference(sunrise).inMinutes.toDouble();
      elapsedMinutes = queryTime.difference(sunrise).inMinutes.toDouble().clamp(0.0, totalDayMinutes);
    } else {
      final nextSunrise = sunrise.add(const Duration(days: 1));
      totalDayMinutes = nextSunrise.difference(sunset).inMinutes.toDouble();
      elapsedMinutes = queryTime.isAfter(sunset)
          ? queryTime.difference(sunset).inMinutes.toDouble()
          : queryTime.difference(sunset.subtract(const Duration(days: 1))).inMinutes.toDouble();
    }

    final double jamamDuration = totalDayMinutes > 0 ? (totalDayMinutes / 8.0) : 90.0;
    final int jamamIdx = (elapsedMinutes / jamamDuration).floor().clamp(0, 7);
    final int jamamNumber = jamamIdx + 1;

    // Weekday (DateTime.monday = 1, sunday = 7)
    final int dtWeekday = queryTime.weekday; // 1: Mon .. 7: Sun
    final String weekdayTa = dtWeekday == 7
        ? 'ஞாயிறு'
        : (dtWeekday == 6 ? 'சனி' : weekdayNamesTa[dtWeekday]);
    final String weekdayEn = dtWeekday == 7
        ? 'Sunday'
        : (dtWeekday == 6 ? 'Saturday' : weekdayNamesEn[dtWeekday]);

    // Day Lord Index in outerPlanetCycle (Sun=0, Mars=1, Jupiter=2, Mercury=3, Venus=4, Saturn=5, Moon=6)
    final int dayLordCycleIdx = dtWeekday == 7
        ? 0 // Sun
        : (dtWeekday == 1
            ? 6 // Moon
            : (dtWeekday == 2
                ? 1 // Mars
                : (dtWeekday == 3
                    ? 3 // Mercury
                    : (dtWeekday == 4
                        ? 2 // Jupiter
                        : (dtWeekday == 5
                            ? 4 // Venus
                            : 5))))); // Saturday = Saturn

    final String dayLordName = outerPlanetCycle[dayLordCycleIdx].tamil;
    final String currentJamamLord = isDay
        ? jamamLordsDay[(jamamIdx + dayLordCycleIdx) % 8]
        : jamamLordsDay[(jamamIdx + 4) % 8];

    // 3. Astronomical Ephemeris for Ascendant & Sun
    final horoscope = AstrologyCalculator.calculateHoroscope(
      dateOfBirth: queryTime,
      latitude: latitude,
      longitude: longitude,
      utcOffsetHours: utcOffsetHours,
    );

    // Lagnam (லக்) = Exact Sidereal Ascendant
    final double lagnaLon = normalizeDegrees(horoscope.lagna.longitude);
    final int lagnaRasi = (lagnaLon / 30.0).floor() % 12;
    final double lagnaDegInRasi = lagnaLon % 30.0;
    final int lagnaD = lagnaDegInRasi.floor();
    final int lagnaM = ((lagnaDegInRasi - lagnaD) * 60.0).round();

    // 4. Udhayam (உதயம்) = Classical Jamakkol Udhayam
    // Starts from Sun's sign base at Sunrise and traverses 30° per hour (0.5° per minute) continuously
    final double sunLonAtSunrise = normalizeDegrees(horoscope.sun.longitude);
    final int sunRasiIndex = (sunLonAtSunrise / 30.0).floor() % 12;
    final double sunSignBaseLon = sunRasiIndex * 30.0;
    
    // Elapsed time from Sunrise
    final double curTimeMinutes = queryTime.hour * 60.0 + queryTime.minute + (queryTime.second / 60.0);
    final double sunriseMinutes = sunrise.hour * 60.0 + sunrise.minute + (sunrise.second / 60.0);
    double elapsedFromSunrise = curTimeMinutes - sunriseMinutes;
    if (elapsedFromSunrise < 0) elapsedFromSunrise += 1440.0;

    final double udhayamLon = normalizeDegrees(sunSignBaseLon + (elapsedFromSunrise * 0.5));
    final int udhayamRasi = (udhayamLon / 30.0).floor() % 12;
    final double udhayamDegInRasi = udhayamLon % 30.0;
    final int udhayamD = udhayamDegInRasi.floor();
    final int udhayamM = ((udhayamDegInRasi - udhayamD) * 60.0).round();
    final udhayamStarPada = getStarAndPada(udhayamLon);

    final udhayamPoint = JamakkolPoint(
      name: 'Udhayam',
      tamilName: 'உதயம்',
      symbol: 'உ',
      absoluteLongitude: udhayamLon,
      rasiIndex: udhayamRasi,
      degreeInRasi: udhayamDegInRasi,
      degree: udhayamD,
      minute: udhayamM,
      formattedDms: "$udhayamD° ${udhayamM.toString().padLeft(2, '0')}'",
      starName: udhayamStarPada.star,
      pada: udhayamStarPada.pada,
      formattedStarPada: udhayamStarPada.formatted,
      houseFromUdhayam: 1,
    );

    // 5. Aarudam (ஆருடம்)
    // Moving minute needle: 60 minutes = 360° (6° per minute)
    final double curMinuteWithSec = queryTime.minute + (queryTime.second / 60.0);
    double aarudamLon;
    if (customAarudamNumber != null && customAarudamNumber >= 1 && customAarudamNumber <= 12) {
      aarudamLon = normalizeDegrees((customAarudamNumber - 1) * 30.0 + udhayamDegInRasi);
    } else {
      aarudamLon = normalizeDegrees(curMinuteWithSec * 6.0);
    }
    final int aarudamRasi = (aarudamLon / 30.0).floor() % 12;
    final double aarudamDegInRasi = aarudamLon % 30.0;
    final int aarudamD = aarudamDegInRasi.floor();
    final int aarudamM = ((aarudamDegInRasi - aarudamD) * 60.0).round();
    final aarudamStarPada = getStarAndPada(aarudamLon);
    final int aarudamHouse = (((aarudamRasi - udhayamRasi) % 12 + 12) % 12) + 1;

    final aarudamPoint = JamakkolPoint(
      name: 'Aarudam',
      tamilName: 'ஆருடம்',
      symbol: 'ஆ',
      absoluteLongitude: aarudamLon,
      rasiIndex: aarudamRasi,
      degreeInRasi: aarudamDegInRasi,
      degree: aarudamD,
      minute: aarudamM,
      formattedDms: "$aarudamD° ${aarudamM.toString().padLeft(2, '0')}'",
      starName: aarudamStarPada.star,
      pada: aarudamStarPada.pada,
      formattedStarPada: aarudamStarPada.formatted,
      houseFromUdhayam: aarudamHouse,
    );

    // 6. Kavippu (கவிப்பு)
    // Anti-clockwise moving obstruction point based on Jamam, Weekday & Sun sign
    final int weekdayOffsetSigns = (dtWeekday == 6) ? 0 : ((dtWeekday == 7) ? 1 : (dtWeekday + 1) % 7);
    final double dayJamam1Base = normalizeDegrees((sunRasiIndex + 3 + weekdayOffsetSigns) * 30.0);
    final double nightJamam1Base = normalizeDegrees((sunRasiIndex + 2 + weekdayOffsetSigns) * 30.0);
    final double kavippuBase = isDay
        ? normalizeDegrees(dayJamam1Base + ((jamamIdx ~/ 2) * 60.0))
        : normalizeDegrees(nightJamam1Base + (jamamIdx * 60.0));
    final double kavippuLon = normalizeDegrees(kavippuBase - aarudamLon);
    final int kavippuRasi = (kavippuLon / 30.0).floor() % 12;
    final double kavippuDegInRasi = kavippuLon % 30.0;
    final int kavippuD = kavippuDegInRasi.floor();
    final int kavippuM = ((kavippuDegInRasi - kavippuD) * 60.0).round();
    final kavippuStarPada = getStarAndPada(kavippuLon);
    final int kavippuHouse = (((kavippuRasi - udhayamRasi) % 12 + 12) % 12) + 1;

    final kavippuPoint = JamakkolPoint(
      name: 'Kavippu',
      tamilName: 'கவிப்பு',
      symbol: 'கவி',
      absoluteLongitude: kavippuLon,
      rasiIndex: kavippuRasi,
      degreeInRasi: kavippuDegInRasi,
      degree: kavippuD,
      minute: kavippuM,
      formattedDms: "$kavippuD° ${kavippuM.toString().padLeft(2, '0')}'",
      starName: kavippuStarPada.star,
      pada: kavippuStarPada.pada,
      formattedStarPada: kavippuStarPada.formatted,
      houseFromUdhayam: kavippuHouse,
    );

    // 7. 8 Jamakkol Outer Planets (Outer 45° celestial ring)
    // Starts at 360° at 06:00:00 (Day) and 18:00:00 (Night) and rotates counter-clockwise at 0.5° per minute
    final double elapsedFromPeriodStart = isDay
        ? (curTimeMinutes - 360.0).clamp(0.0, 720.0)
        : (curTimeMinutes >= 1080.0 ? curTimeMinutes - 1080.0 : curTimeMinutes + 360.0).clamp(0.0, 720.0);
    final double currentDayLordLon = normalizeDegrees(360.0 - (elapsedFromPeriodStart * 0.5));

    final List<JamakkolOuterPlanet> outerPlanets = [];
    final Map<int, List<JamakkolOuterPlanet>> outerPlanetsByRasi = {};

    for (int i = 0; i < 8; i++) {
      final item = outerPlanetCycle[i];
      final double pLon = normalizeDegrees(currentDayLordLon + ((dayLordCycleIdx - i) * 45.0));
      final int rIdx = (pLon / 30.0).floor() % 12;
      final double degInRasi = pLon % 30.0;
      final borderInfo = getRasiBorderInfo(rIdx);

      final outerPlanet = JamakkolOuterPlanet(
        key: item.key,
        tamilName: item.tamil,
        shortSymbol: item.short,
        absoluteLongitude: pLon,
        rasiIndex: rIdx,
        degreeInRasi: degInRasi,
        formattedDegree: "${item.short} ${formatDegreeMinute(pLon)}",
        borderSide: borderInfo.borderSide,
        gridCol: borderInfo.col,
        gridRow: borderInfo.row,
      );

      outerPlanets.add(outerPlanet);
      outerPlanetsByRasi.putIfAbsent(rIdx, () => []).add(outerPlanet);
    }

    // 8. Upagrahas / Prasannam Points
    final double sunDegInRasi = horoscope.sun.degreeInRasi;
    final int sunD = sunDegInRasi.floor();
    final int sunM = ((sunDegInRasi - sunD) * 60.0).round();
    final String sunDegStr = "$sunD° ${sunM.toString().padLeft(2, '0')}'";

    // Yamakandam and Rahu Kaalam signs on Weekdays (1=Mon..7=Sun) for Day & Night
    const yamaDaySigns = {
      7: 5, // Sun -> Kanni (5)
      1: 2, // Mon -> Mithunam (2)
      2: 0, // Tue -> Mesham (0)
      3: 10, // Wed -> Kumbam (10)
      4: 8, // Thu -> Dhanusu (8)
      5: 6, // Fri -> Thulam (6)
      6: 3, // Sat -> Katakam (3)
    };
    const yamaNightSigns = {
      7: 3, // Sun -> Katakam (3)
      1: 6, // Mon -> Thulam (6)
      2: 8, // Tue -> Dhanusu (8)
      3: 10, // Wed -> Kumbam (10)
      4: 0, // Thu -> Mesham (0)
      5: 2, // Fri -> Mithunam (2)
      6: 3, // Sat -> Katakam (3)
    };

    const rahuDaySigns = {
      7: 0, // Sun -> Mesham (0)
      1: 1, // Mon -> Rishabam (1)
      2: 6, // Tue -> Thulam (6)
      3: 4, // Wed -> Simmam (4)
      4: 5, // Thu -> Kanni (5)
      5: 3, // Fri -> Katakam (3)
      6: 8, // Sat -> Dhanusu (8)
    };
    const rahuNightSigns = {
      7: 3, // Sun -> Katakam (3)
      1: 5, // Mon -> Kanni (5)
      2: 4, // Tue -> Simmam (4)
      3: 6, // Wed -> Thulam (6)
      4: 1, // Thu -> Rishabam (1)
      5: 7, // Fri -> Viruchigam (7)
      6: 8, // Sat -> Dhanusu (8)
    };

    const mrityuDaySigns = {
      7: 7, // Sun -> Viruchigam (7)
      1: 2, // Mon -> Mithunam (2)
      2: 3, // Tue -> Katakam (3)
      3: 4, // Wed -> Simmam (4)
      4: 5, // Thu -> Kanni (5)
      5: 6, // Fri -> Thulam (6)
      6: 7, // Sat -> Viruchigam (7)
    };
    const mrityuNightSigns = {
      7: 7, // Sun -> Viruchigam (7)
      1: 6, // Mon -> Thulam (6)
      2: 5, // Tue -> Kanni (5)
      3: 4, // Wed -> Simmam (4)
      4: 3, // Thu -> Katakam (3)
      5: 2, // Fri -> Mithunam (2)
      6: 4, // Sat -> Simmam (4)
    };

    const mrityuDayOffsets = {
      7: 0.0, // Sun -> Sun's degree (0° offset)
      1: 22.0,
      2: 18.0,
      3: 14.0,
      4: 10.0,
      5: 6.0,
      6: 24.0, // Sat -> +24°
    };
    const mrityuNightOffsets = {
      7: 26.0,
      1: 22.0,
      2: 18.0,
      3: 14.0,
      4: 10.0,
      5: 6.0,
      6: 6.0, // Sat -> +6°
    };

    const mandiDaySigns = {
      7: 10, // Sun -> Kumbam (10)
      1: 4,  // Mon -> Simmam (4)
      2: 2,  // Tue -> Mithunam (2)
      3: 0,  // Wed -> Mesham (0)
      4: 10, // Thu -> Kumbam (10)
      5: 6,  // Fri -> Thulam (6)
      6: 5,  // Sat -> Kanni (5)
    };
    const mandiNightSigns = {
      7: 5, // Sun -> Kanni (5)
      1: 6, // Mon -> Thulam (6)
      2: 10, // Tue -> Kumbam (10)
      3: 0, // Wed -> Mesham (0)
      4: 2, // Thu -> Mithunam (2)
      5: 4, // Fri -> Simmam (4)
      6: 1, // Sat -> Rishabam (1)
    };

    const mandiDayOffsets = {
      7: 6.0,  // Sun -> +6°
      1: 22.0,
      2: 18.0,
      3: 14.0,
      4: 10.0,
      5: 6.0,
      6: 12.0, // Sat -> +12°
    };
    const mandiNightOffsets = {
      7: 26.0,
      1: 22.0,
      2: 18.0,
      3: 14.0,
      4: 10.0,
      5: 6.0,
      6: 24.0, // Sat -> +24°
    };

    final int yamaRasi = isDay ? (yamaDaySigns[dtWeekday] ?? 3) : (yamaNightSigns[dtWeekday] ?? 3);
    final int rahuKaalamRasi = isDay ? (rahuDaySigns[dtWeekday] ?? 8) : (rahuNightSigns[dtWeekday] ?? 8);
    final int mrityuRasi = isDay ? (mrityuDaySigns[dtWeekday] ?? 7) : (mrityuNightSigns[dtWeekday] ?? 4);
    final double mrityuOffset = isDay ? (mrityuDayOffsets[dtWeekday] ?? 18.0) : (mrityuNightOffsets[dtWeekday] ?? 6.0);
    final int mandiRasi = isDay ? (mandiDaySigns[dtWeekday] ?? 5) : (mandiNightSigns[dtWeekday] ?? 1);
    final double mandiOffset = isDay ? (mandiDayOffsets[dtWeekday] ?? 12.0) : (mandiNightOffsets[dtWeekday] ?? 24.0);

    // Mrityu degree = (Sun's degree in rasi + offset) % 30
    final double mrityuDeg = (sunDegInRasi + mrityuOffset) % 30.0;
    final int mrityuD = mrityuDeg.floor();
    final int mrityuM = ((mrityuDeg - mrityuD) * 60.0).round();

    // Mandi degree = (Sun's degree in rasi + offset) % 30
    final double mandiDeg = (sunDegInRasi + mandiOffset) % 30.0;
    final int mandiD = mandiDeg.floor();
    final int mandiM = ((mandiDeg - mandiD) * 60.0).round();

    final List<JamakkolUpagraha> upagrahas = [
      JamakkolUpagraha(
        key: 'Yamakandam',
        tamilName: 'எமகண்டம்',
        shortName: 'எம',
        rasiIndex: yamaRasi,
        degree: sunD,
        minute: sunM,
        formattedDegree: "எம ($sunDegStr)",
        colorCategory: 'red',
      ),
      JamakkolUpagraha(
        key: 'RahuKaalam',
        tamilName: 'ராகு காலம்',
        shortName: 'ரா.கா',
        rasiIndex: rahuKaalamRasi,
        degree: sunD,
        minute: sunM,
        formattedDegree: "ரா.கா ($sunDegStr)",
        colorCategory: 'red',
      ),
      JamakkolUpagraha(
        key: 'Maandi',
        tamilName: 'மாந்தி',
        shortName: 'மாந்',
        rasiIndex: mandiRasi,
        degree: mandiD,
        minute: mandiM,
        formattedDegree: "மாந் ($mandiD° ${mandiM.toString().padLeft(2, '0')}')",
        colorCategory: 'red',
      ),
      JamakkolUpagraha(
        key: 'Mrityu',
        tamilName: 'மிருத்யு',
        shortName: 'மிருத்யு',
        rasiIndex: mrityuRasi,
        degree: mrityuD,
        minute: mrityuM,
        formattedDegree: "மிருத்யு ($mrityuD° ${mrityuM.toString().padLeft(2, '0')}')",
        colorCategory: 'purple',
      ),
      JamakkolUpagraha(
        key: 'Lagnam',
        tamilName: 'லக்னம்',
        shortName: 'லக்',
        rasiIndex: lagnaRasi,
        degree: lagnaD,
        minute: lagnaM,
        formattedDegree: "லக் ($lagnaD° ${lagnaM.toString().padLeft(2, '0')}')",
        colorCategory: 'blue',
      ),
    ];

    final Map<int, List<JamakkolUpagraha>> upagrahasByRasi = {};
    for (final u in upagrahas) {
      upagrahasByRasi.putIfAbsent(u.rasiIndex, () => []).add(u);
    }

    final Map<int, List<JamakkolPoint>> specialPointsByRasi = {};
    specialPointsByRasi.putIfAbsent(udhayamPoint.rasiIndex, () => []).add(udhayamPoint);
    specialPointsByRasi.putIfAbsent(aarudamPoint.rasiIndex, () => []).add(aarudamPoint);
    specialPointsByRasi.putIfAbsent(kavippuPoint.rasiIndex, () => []).add(kavippuPoint);

    // Sky / Transit Planets (Sun..Ketu, excluding Lagna and Mandi which are in upagrahas)
    final Map<int, List<PlanetDetail>> skyPlanetsByRasi = {};
    final Map<String, PlanetDetail> skyPlanets = {};
    for (final entry in horoscope.planets.entries) {
      if (entry.key != 'Lagna' && entry.key != 'Mandi') {
        skyPlanets[entry.key] = entry.value;
        skyPlanetsByRasi.putIfAbsent(entry.value.rasiIndex, () => []).add(entry.value);
      }
    }

    // Formatted query time (e.g. Sat Sep 12 2026 10:59:01 AM)
    const monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final mStr = monthNames[queryTime.month - 1];
    final hr12 = queryTime.hour == 0 ? 12 : (queryTime.hour > 12 ? queryTime.hour - 12 : queryTime.hour);
    final amPm = queryTime.hour >= 12 ? 'PM' : 'AM';
    final formattedTime =
        "${weekdayEn.substring(0, 3)} $mStr ${queryTime.day} ${queryTime.year} ${hr12.toString().padLeft(2, '0')}:${queryTime.minute.toString().padLeft(2, '0')}:${queryTime.second.toString().padLeft(2, '0')} $amPm";

    return JamakkolChartData(
      queryDateTime: queryTime,
      formattedDateTime: formattedTime,
      location: locationName,
      jamamNumber: jamamNumber,
      jamamLord: currentJamamLord,
      weekdayNameEn: weekdayEn,
      weekdayNameTa: weekdayTa,
      isDay: isDay,
      udhayam: udhayamPoint,
      aarudam: aarudamPoint,
      kavippu: kavippuPoint,
      outerPlanets: outerPlanets,
      upagrahas: upagrahas,
      outerPlanetsByRasi: outerPlanetsByRasi,
      upagrahasByRasi: upagrahasByRasi,
      specialPointsByRasi: specialPointsByRasi,
      skyPlanets: skyPlanets,
      skyPlanetsByRasi: skyPlanetsByRasi,
    );
  }

  /// Gowri order for Day by weekday (1=Mon ... 7=Sun)
  static const Map<int, List<String>> gowriDayOrder = {
    1: ['அமிர்தம்', 'ரோகம்', 'லாபம்', 'தனம்', 'விஷம்', 'சோரம்', 'சுபம்', 'உத்தி'],
    2: ['ரோகம்', 'லாபம்', 'தனம்', 'விஷம்', 'சோரம்', 'சுபம்', 'உத்தி', 'அமிர்தம்'],
    3: ['லாபம்', 'தனம்', 'விஷம்', 'சோரம்', 'சுபம்', 'உத்தி', 'அமிர்தம்', 'ரோகம்'],
    4: ['தனம்', 'விஷம்', 'சோரம்', 'சுபம்', 'உத்தி', 'அமிர்தம்', 'ரோகம்', 'லாபம்'],
    5: ['விஷம்', 'சோரம்', 'சுபம்', 'உத்தி', 'அமிர்தம்', 'ரோகம்', 'லாபம்', 'தனம்'],
    6: ['சோரம்', 'சுபம்', 'உத்தி', 'அமிர்தம்', 'ரோகம்', 'லாபம்', 'தனம்', 'விஷம்'],
    7: ['உத்தி', 'அமிர்தம்', 'ரோகம்', 'லாபம்', 'தனம்', 'விஷம்', 'சோரம்', 'சுபம்'],
  };

  /// Gowri order for Night by weekday (1=Mon ... 7=Sun) from Page 151
  static const Map<int, List<String>> gowriNightOrder = {
    1: ['சோரம்', 'உத்தி', 'விஷம்', 'ரோகம்', 'தனம்', 'சுபம்', 'லாபம்', 'அமிர்தம்'],
    2: ['சுபம்', 'லாபம்', 'அமிர்தம்', 'விஷம்', 'ரோகம்', 'சோரம்', 'உத்தி', 'தனம்'],
    3: ['விஷம்', 'ரோகம்', 'சோரம்', 'உத்தி', 'தனம்', 'சுபம்', 'லாபம்', 'அமிர்தம்'],
    4: ['லாபம்', 'அமிர்தம்', 'விஷம்', 'ரோகம்', 'சோரம்', 'உத்தி', 'தனம்', 'சுபம்'],
    5: ['ரோகம்', 'சோரம்', 'உத்தி', 'தனம்', 'சுபம்', 'லாபம்', 'அமிர்தம்', 'விஷம்'],
    6: ['அமிர்தம்', 'விஷம்', 'ரோகம்', 'சோரம்', 'உத்தி', 'தனம்', 'சுபம்', 'லாபம்'],
    7: ['தனம்', 'சுபம்', 'லாபம்', 'அமிர்தம்', 'விஷம்', 'ரோகம்', 'சோரம்', 'உத்தி'],
  };

  /// Calculates current Gowri Panchangam state based on authentic day and night cycles
  static GowriPanchangamResult calculateGowriPanchangam(DateTime queryTime, {double sunriseHour = 6.0}) {
    const goodNames = ['உத்தி', 'அமிர்தம்', 'அமுதம்', 'சுபம்', 'சுகம்', 'லாபம்', 'தனம்'];

    final double curHour = queryTime.hour + (queryTime.minute / 60.0) + (queryTime.second / 3600.0);
    final bool isDayTime = curHour >= sunriseHour && curHour < (sunriseHour + 12.0);

    int weekday;
    int slot;
    String name;

    if (isDayTime) {
      weekday = queryTime.weekday; // 1=Mon .. 7=Sun
      final double elapsedHours = (curHour - sunriseHour).clamp(0.0, 12.0);
      slot = (elapsedHours / 1.5).floor().clamp(0, 7);
      name = gowriDayOrder[weekday]![slot];
    } else {
      if (curHour < sunriseHour) {
        weekday = (queryTime.weekday - 2 + 7) % 7 + 1;
        final double elapsedHours = (curHour + (24.0 - (sunriseHour + 12.0))).clamp(0.0, 12.0);
        slot = (elapsedHours / 1.5).floor().clamp(0, 7);
      } else {
        weekday = queryTime.weekday;
        final double elapsedHours = (curHour - (sunriseHour + 12.0)).clamp(0.0, 12.0);
        slot = (elapsedHours / 1.5).floor().clamp(0, 7);
      }
      name = gowriNightOrder[weekday]![slot];
    }

    final bool isGood = goodNames.contains(name);
    return GowriPanchangamResult(
      nameTa: name,
      isGood: isGood,
      natureTa: isGood ? 'சுபம்' : 'அசுபம்',
    );
  }
}
