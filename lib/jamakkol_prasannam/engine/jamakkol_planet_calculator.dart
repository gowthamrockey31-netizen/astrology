import 'dart:math' as math;
import '../../services/astrology_calculator.dart';
import '../models/jamakkol_models.dart';
import '../models/jamakkol_planet_models.dart';
import '../models/jamam_models.dart';
import 'jamam_calculator.dart';

/// Calculator for Jamakkol Outer Planets, Transit Planets, and Upagrahas
class JamakkolPlanetCalculator {
  /// Normalize degrees strictly to [0.0, 360.0)
  static double normalize(double deg) {
    double n = deg % 360.0;
    if (n < 0) n += 360.0;
    return n;
  }

  /// South Indian chart 4x4 border placement information:
  /// Row 0: Meenam(11), Mesham(0), Rishabam(1), Mithunam(2) -> Top Border (borderSide 0)
  /// Row 1: Kumbam(10), center,    center,      Katakam(3)  -> Left(3) / Right(1)
  /// Row 2: Makaram(9), center,    center,      Simham(4)   -> Left(3) / Right(1)
  /// Row 3: Dhanusu(8), Viruch(7), Thulam(6),   Kanni(5)    -> Bottom Border (borderSide 2)
  static ({int borderSide, int col, int row}) getRasiBorderInfo(int rasiIndex) {
    switch (rasiIndex) {
      case 11: // Meenam
        return (borderSide: 0, col: 0, row: 0);
      case 0: // Mesham
        return (borderSide: 0, col: 1, row: 0);
      case 1: // Rishabam
        return (borderSide: 0, col: 2, row: 0);
      case 2: // Mithunam
        return (borderSide: 0, col: 3, row: 0);
      case 3: // Katakam
        return (borderSide: 1, col: 3, row: 1);
      case 4: // Simham
        return (borderSide: 1, col: 3, row: 2);
      case 5: // Kanni
        return (borderSide: 2, col: 3, row: 3);
      case 6: // Thulam
        return (borderSide: 2, col: 2, row: 3);
      case 7: // Viruchigam
        return (borderSide: 2, col: 1, row: 3);
      case 8: // Dhanusu
        return (borderSide: 2, col: 0, row: 3);
      case 9: // Makaram
        return (borderSide: 3, col: 0, row: 2);
      case 10: // Kumbam
      default:
        return (borderSide: 3, col: 0, row: 1);
    }
  }

  /// Calculates the 8 Traditional Jamakkol Outer Planets
  /// Spaced at 45° intervals in counter-clockwise order, rotating continuously
  static List<JamakkolPlanet> calculateJamakkolPlanets({
    required DateTime queryDateTime,
    required JamamDaySchedule schedule,
  }) {
    final curMinutes = queryDateTime.hour * 60.0 + queryDateTime.minute + (queryDateTime.second / 60.0);
    final isDay = schedule.currentJamam.isDay;

    // Reference time: 06:00:00 AM for Day (360 min) and 18:00:00 PM for Night (1080 min)
    // Movement: 0.5° per minute continuous counter-clockwise
    final double elapsedFromPeriodStart = isDay
        ? (curMinutes - 360.0).clamp(0.0, 720.0)
        : (curMinutes >= 1080.0 ? curMinutes - 1080.0 : curMinutes + 360.0).clamp(0.0, 720.0);

    final double currentDayLordLon = normalize(360.0 - (elapsedFromPeriodStart * 0.5));
    final int dayLordCycleIdx = JamamCalculator.getWeekdayLordIndex(schedule.weekdayNumber);

    final List<JamakkolPlanet> result = [];
    final currentJamamLordPlanetKey = schedule.currentJamam.rulingPlanetEn;

    for (int i = 0; i < 8; i++) {
      final pInfo = JamamCalculator.planetCycle[i];
      final double pLon = normalize(currentDayLordLon + ((dayLordCycleIdx - i) * 45.0));
      final int rawRIdx = (pLon / 30.0).floor() % 12;
      final double degInRasi = pLon % 30.0;

      // Classical Jamakkol outer-ring planet path:
      // Outer planets must not enter Fixed signs (ரிஷபம், சிம்மம், விருச்சிகம், கும்பம்).
      // They are placed into the corresponding Ubhaya (dual) signs with degree retained:
      // Rishabam (1) -> Mithunam (2)
      // Simham (4) -> Kanni (5)
      // Viruchigam (7) -> Dhanusu (8)
      // Kumbam (10) -> Meenam (11)
      int displayRasiIdx = rawRIdx;
      switch (rawRIdx) {
        case 1:
          displayRasiIdx = 2; // Rishabam -> Mithunam
          break;
        case 4:
          displayRasiIdx = 5; // Simham -> Kanni
          break;
        case 7:
          displayRasiIdx = 8; // Viruchigam -> Dhanusu
          break;
        case 10:
          displayRasiIdx = 11; // Kumbam -> Meenam
          break;
        default:
          displayRasiIdx = rawRIdx;
          break;
      }

      final double mappedLon = normalize(displayRasiIdx * 30.0 + degInRasi);
      final totalMinutes = mappedLon * 60.0;
      final padaIndex = (totalMinutes / 200.0).floor().clamp(0, 107);
      final nakIdx = (padaIndex ~/ 4).clamp(0, 26);
      final pada = (padaIndex % 4) + 1;

      final borderInfo = getRasiBorderInfo(displayRasiIdx);
      final formattedDms = AstrologyCalculator.formatRasiDegree(degInRasi);

      result.add(JamakkolPlanet(
        key: pInfo.key,
        nameEn: pInfo.en,
        nameTa: pInfo.ta,
        shortTa: pInfo.shortTa,
        shortEn: pInfo.en.substring(0, math.min(3, pInfo.en.length)),
        absoluteLongitude: pLon,
        rasiIndex: displayRasiIdx,
        rasiNameTa: AstrologyCalculator.rasiNamesTa[displayRasiIdx],
        rasiNameEn: AstrologyCalculator.rasiNamesEn[displayRasiIdx],
        degreeInRasi: degInRasi,
        formattedDms: formattedDms,
        nakshatraTa: AstrologyCalculator.nakshatrasTa[nakIdx],
        nakshatraEn: AstrologyCalculator.nakshatrasEn[nakIdx],
        nakshatraIndex: nakIdx,
        pada: pada,
        borderSide: borderInfo.borderSide,
        gridCol: borderInfo.col,
        gridRow: borderInfo.row,
        isCurrentJamamLord: pInfo.en.toLowerCase() == currentJamamLordPlanetKey.toLowerCase(),
      ));
    }

    return result;
  }

  /// Calculates astronomical Gocharam (Transit) planets using Swiss Ephemeris / AstrologyCalculator
  static List<TransitPlanet> calculateTransitPlanets({
    required DateTime queryDateTime,
    required JamakkolLocation location,
  }) {
    final horoscope = AstrologyCalculator.calculateHoroscope(
      dateOfBirth: queryDateTime,
      latitude: location.latitude,
      longitude: location.longitude,
      utcOffsetHours: location.timezone,
    );

    final List<TransitPlanet> list = [];
    final sunDetail = horoscope.planets['Sun'];
    final double sunLon = sunDetail != null ? normalize(sunDetail.longitude) : 0.0;

    for (final entry in horoscope.planets.entries) {
      if (entry.key == 'Lagna' || entry.key == 'Mandi') continue;

      final p = entry.value;
      final double lon = normalize(p.longitude);
      final int rasiIdx = p.rasiIndex;
      final double degInRasi = p.degreeInRasi;

      final totalMinutes = lon * 60.0;
      final padaIndex = (totalMinutes / 200.0).floor().clamp(0, 107);
      final nakIdx = (padaIndex ~/ 4).clamp(0, 26);
      final pada = (padaIndex % 4) + 1;

      // Determine combustion with Sun (except Rahu/Ketu)
      bool isCombust = false;
      if (entry.key != 'Sun' && entry.key != 'Rahu' && entry.key != 'Ketu') {
        double dist = (lon - sunLon).abs();
        if (dist > 180.0) dist = 360.0 - dist;
        if (entry.key == 'Moon' && dist <= 12.0) isCombust = true;
        if (entry.key == 'Mars' && dist <= 17.0) isCombust = true;
        if (entry.key == 'Mercury' && dist <= 14.0) isCombust = true;
        if (entry.key == 'Jupiter' && dist <= 11.0) isCombust = true;
        if (entry.key == 'Venus' && dist <= 10.0) isCombust = true;
        if (entry.key == 'Saturn' && dist <= 15.0) isCombust = true;
      }

      final dignityInfo = _determineDignity(entry.key, rasiIdx, degInRasi, isCombust);

      list.add(TransitPlanet(
        nameEn: p.name,
        nameTa: p.tamilName,
        symbol: p.symbol,
        absoluteLongitude: lon,
        rasiIndex: rasiIdx,
        rasiNameTa: AstrologyCalculator.rasiNamesTa[rasiIdx],
        rasiNameEn: AstrologyCalculator.rasiNamesEn[rasiIdx],
        degreeInRasi: degInRasi,
        formattedDms: AstrologyCalculator.formatRasiDegree(degInRasi),
        nakshatraTa: AstrologyCalculator.nakshatrasTa[nakIdx],
        nakshatraEn: AstrologyCalculator.nakshatrasEn[nakIdx],
        nakshatraIndex: nakIdx,
        pada: pada,
        isRetrograde: p.isRetrograde,
        isCombust: isCombust,
        dignity: dignityInfo.dignity,
        dignityLabelTa: dignityInfo.labelTa,
        dignityLabelEn: dignityInfo.labelEn,
      ));
    }

    return list;
  }

  /// Calculates Dignity for a planet based on sign and degree
  static ({PlanetaryDignity dignity, String labelTa, String labelEn}) _determineDignity(
    String planetKey,
    int rasiIndex,
    double degInRasi,
    bool isCombust,
  ) {
    if (isCombust) {
      return (dignity: PlanetaryDignity.combust, labelTa: 'அஸ்தங்கம்', labelEn: 'Combust');
    }

    switch (planetKey) {
      case 'Sun':
        if (rasiIndex == 0) return (dignity: PlanetaryDignity.exalted, labelTa: 'உச்சம்', labelEn: 'Exalted');
        if (rasiIndex == 6) return (dignity: PlanetaryDignity.debilitated, labelTa: 'நீசம்', labelEn: 'Debilitated');
        if (rasiIndex == 4) return (dignity: PlanetaryDignity.ownSign, labelTa: 'ஆட்சி', labelEn: 'Own Sign');
        break;
      case 'Moon':
        if (rasiIndex == 1) return (dignity: PlanetaryDignity.exalted, labelTa: 'உச்சம்', labelEn: 'Exalted');
        if (rasiIndex == 7) return (dignity: PlanetaryDignity.debilitated, labelTa: 'நீசம்', labelEn: 'Debilitated');
        if (rasiIndex == 3) return (dignity: PlanetaryDignity.ownSign, labelTa: 'ஆட்சி', labelEn: 'Own Sign');
        break;
      case 'Mars':
        if (rasiIndex == 9) return (dignity: PlanetaryDignity.exalted, labelTa: 'உச்சம்', labelEn: 'Exalted');
        if (rasiIndex == 3) return (dignity: PlanetaryDignity.debilitated, labelTa: 'நீசம்', labelEn: 'Debilitated');
        if (rasiIndex == 0 || rasiIndex == 7) return (dignity: PlanetaryDignity.ownSign, labelTa: 'ஆட்சி', labelEn: 'Own Sign');
        break;
      case 'Mercury':
        if (rasiIndex == 5) return (dignity: PlanetaryDignity.exalted, labelTa: 'உச்சம்', labelEn: 'Exalted');
        if (rasiIndex == 11) return (dignity: PlanetaryDignity.debilitated, labelTa: 'நீசம்', labelEn: 'Debilitated');
        if (rasiIndex == 2) return (dignity: PlanetaryDignity.ownSign, labelTa: 'ஆட்சி', labelEn: 'Own Sign');
        break;
      case 'Jupiter':
        if (rasiIndex == 3) return (dignity: PlanetaryDignity.exalted, labelTa: 'உச்சம்', labelEn: 'Exalted');
        if (rasiIndex == 9) return (dignity: PlanetaryDignity.debilitated, labelTa: 'நீசம்', labelEn: 'Debilitated');
        if (rasiIndex == 8 || rasiIndex == 11) return (dignity: PlanetaryDignity.ownSign, labelTa: 'ஆட்சி', labelEn: 'Own Sign');
        break;
      case 'Venus':
        if (rasiIndex == 11) return (dignity: PlanetaryDignity.exalted, labelTa: 'உச்சம்', labelEn: 'Exalted');
        if (rasiIndex == 5) return (dignity: PlanetaryDignity.debilitated, labelTa: 'நீசம்', labelEn: 'Debilitated');
        if (rasiIndex == 1 || rasiIndex == 6) return (dignity: PlanetaryDignity.ownSign, labelTa: 'ஆட்சி', labelEn: 'Own Sign');
        break;
      case 'Saturn':
        if (rasiIndex == 6) return (dignity: PlanetaryDignity.exalted, labelTa: 'உச்சம்', labelEn: 'Exalted');
        if (rasiIndex == 0) return (dignity: PlanetaryDignity.debilitated, labelTa: 'நீசம்', labelEn: 'Debilitated');
        if (rasiIndex == 9 || rasiIndex == 10) return (dignity: PlanetaryDignity.ownSign, labelTa: 'ஆட்சி', labelEn: 'Own Sign');
        break;
      case 'Rahu':
        if (rasiIndex == 1 || rasiIndex == 2) return (dignity: PlanetaryDignity.exalted, labelTa: 'உச்சம்', labelEn: 'Exalted');
        if (rasiIndex == 7 || rasiIndex == 8) return (dignity: PlanetaryDignity.debilitated, labelTa: 'நீசம்', labelEn: 'Debilitated');
        if (rasiIndex == 10) return (dignity: PlanetaryDignity.ownSign, labelTa: 'ஆட்சி', labelEn: 'Own Sign');
        break;
      case 'Ketu':
        if (rasiIndex == 7 || rasiIndex == 8) return (dignity: PlanetaryDignity.exalted, labelTa: 'உச்சம்', labelEn: 'Exalted');
        if (rasiIndex == 1 || rasiIndex == 2) return (dignity: PlanetaryDignity.debilitated, labelTa: 'நீசம்', labelEn: 'Debilitated');
        if (rasiIndex == 7) return (dignity: PlanetaryDignity.ownSign, labelTa: 'ஆட்சி', labelEn: 'Own Sign');
        break;
    }

    return (dignity: PlanetaryDignity.neutral, labelTa: 'சமம்', labelEn: 'Neutral');
  }

  /// Calculates Jamakkol Rahu Kalam (Ra.Ka) Rasi point:
  /// Fixed by weekday for both Day and Night:
  /// Sunday(7)=Mesham (0), Monday(1)=Makaram (9), Tuesday(2)=Mithunam (2),
  /// Wednesday(3)=Kanni (5), Thursday(4)=Kadagam (3), Friday(5)=Thulam (6), Saturday(6)=Dhanusu (8)
  static int calculateRahuKalamRasi(int weekdayNumber, {bool isDay = true}) {
    switch (weekdayNumber) {
      case 7: return 0; // Sunday -> Mesham (0)
      case 1: return 9; // Monday -> Makaram (9)
      case 2: return 2; // Tuesday -> Mithunam (2)
      case 3: return 5; // Wednesday -> Kanni (5)
      case 4: return 3; // Thursday -> Kadagam (3)
      case 5: return 6; // Friday -> Thulam (6)
      case 6: return 8; // Saturday -> Dhanusu (8)
      default: return 0;
    }
  }

  /// Calculates Jamakkol Emakandam Rasi point:
  /// Fixed by weekday for both Day and Night:
  /// Sunday(7)=Kanni (5), Monday(1)=Thulam (6), Tuesday(2)=Dhanusu (8),
  /// Wednesday(3)=Makaram (9), Thursday(4)=Meenam (11), Friday(5)=Mithunam (2), Saturday(6)=Kadagam (3)
  static int calculateEmakandamRasi(int weekdayNumber, {bool isDay = true}) {
    switch (weekdayNumber) {
      case 7: return 5; // Sunday -> Kanni (5)
      case 1: return 6; // Monday -> Thulam (6)
      case 2: return 8; // Tuesday -> Dhanusu (8)
      case 3: return 9; // Wednesday -> Makaram (9)
      case 4: return 11; // Thursday -> Meenam (11)
      case 5: return 2; // Friday -> Mithunam (2)
      case 6: return 3; // Saturday -> Kadagam (3)
      default: return 5;
    }
  }

  /// Calculates Jamakkol Mandi Longitude dynamically:
  /// Classical Jamakkol rule: Mandi = Sun Longitude + Mandi Offset
  /// Day offsets from Sun: Sun=156°, Mon=132°, Tue=108°, Wed=84°, Thu=60°, Fri=36°, Sat=12°
  /// Night offsets from Sun: Sun=240°, Mon=216°, Tue=192°, Wed=336°, Thu=312°, Fri=288°, Sat=264°
  static double calculateMandiLongitude({
    required int weekdayNumber,
    double? sunLongitude,
    double? sunDegInRasi,
    required bool isDay,
  }) {
    const mandiDayOffsets = {7: 156.0, 1: 132.0, 2: 108.0, 3: 84.0, 4: 60.0, 5: 36.0, 6: 12.0};
    const mandiNightOffsets = {7: 240.0, 1: 216.0, 2: 192.0, 3: 336.0, 4: 312.0, 5: 288.0, 6: 264.0};

    final double offset = isDay ? (mandiDayOffsets[weekdayNumber] ?? 156.0) : (mandiNightOffsets[weekdayNumber] ?? 240.0);
    final double baseSun = sunLongitude ?? (150.0 + (sunDegInRasi ?? 0.0));
    return normalize(baseSun + offset);
  }

  /// Calculates Jamakkol Mandi Rasi point
  static int calculateMandiRasi({
    required int weekdayNumber,
    double? sunLongitude,
    double? sunDegInRasi,
    required bool isDay,
  }) {
    final lon = calculateMandiLongitude(
      weekdayNumber: weekdayNumber,
      sunLongitude: sunLongitude,
      sunDegInRasi: sunDegInRasi,
      isDay: isDay,
    );
    return (lon / 30.0).floor() % 12;
  }

  /// Calculates Jamakkol Mridyu Longitude dynamically:
  /// Classical Jamakkol rule: Mrityu = Sun Longitude + Mrityu Offset
  /// Day offsets from Sun: Sun=60°, Mon=36°, Tue=12°, Wed=156°, Thu=132°, Fri=108°, Sat=84°
  /// Night offsets from Sun: Sun=312°, Mon=288°, Tue=264°, Wed=240°, Thu=216°, Fri=192°, Sat=336°
  static double calculateMridyuLongitude({
    required int weekdayNumber,
    double? sunLongitude,
    double? sunDegInRasi,
    required bool isDay,
  }) {
    const mrityuDayOffsets = {7: 60.0, 1: 36.0, 2: 12.0, 3: 156.0, 4: 132.0, 5: 108.0, 6: 84.0};
    const mrityuNightOffsets = {7: 312.0, 1: 288.0, 2: 264.0, 3: 240.0, 4: 216.0, 5: 192.0, 6: 336.0};

    final double offset = isDay ? (mrityuDayOffsets[weekdayNumber] ?? 60.0) : (mrityuNightOffsets[weekdayNumber] ?? 312.0);
    final double baseSun = sunLongitude ?? (150.0 + (sunDegInRasi ?? 0.0));
    return normalize(baseSun + offset);
  }

  /// Calculates Jamakkol Mridyu Rasi point
  static int calculateMridyuRasi({
    required int weekdayNumber,
    double? sunLongitude,
    double? sunDegInRasi,
    required bool isDay,
  }) {
    final lon = calculateMridyuLongitude(
      weekdayNumber: weekdayNumber,
      sunLongitude: sunLongitude,
      sunDegInRasi: sunDegInRasi,
      isDay: isDay,
    );
    return (lon / 30.0).floor() % 12;
  }

  /// Calculates Upagrahas: Yamakandam (Emakandam), Rahu Kaalam (Ra.Ka), Mandi, Mrityu (Mridyu), and Lagna
  static List<JamakkolSpecialPoint> calculateUpagrahas({
    required DateTime queryDateTime,
    required JamakkolLocation location,
    required JamamDaySchedule schedule,
    required double sunLongitude,
    required int udayamRasiIndex,
    bool useSecondaryMridyu = false,
  }) {
    final int dtWeekday = schedule.weekdayNumber; // 1=Mon .. 7=Sun
    final bool isDay = schedule.currentJamam.isDay;

    final double sunDegInRasi = normalize(sunLongitude) % 30.0;

    // Mandi calculation
    final double mandiLon = calculateMandiLongitude(
      weekdayNumber: dtWeekday,
      sunLongitude: sunLongitude,
      sunDegInRasi: sunDegInRasi,
      isDay: isDay,
    );

    // 1. Jamakkol Rahu Kalam Rasi Point (Ra.Ka)
    final int rahuKaalamRasi = calculateRahuKalamRasi(dtWeekday, isDay: isDay);
    final double rahuKaalamLon = normalize(rahuKaalamRasi * 30.0 + sunDegInRasi);

    // 2. Jamakkol Emakandam Rasi Point (Emakandam)
    final int emakandamRasi = calculateEmakandamRasi(dtWeekday, isDay: isDay);
    final double yamaLon = normalize(emakandamRasi * 30.0 + sunDegInRasi);

    // 3. Jamakkol Mridyu Rasi Point (Mridyu)
    final double mrityuLon = calculateMridyuLongitude(
      weekdayNumber: dtWeekday,
      sunLongitude: sunLongitude,
      sunDegInRasi: sunDegInRasi,
      isDay: isDay,
    );

    final List<JamakkolSpecialPoint> upagrahas = [];

    // 1. Emakandam
    upagrahas.add(_createPoint(
      type: SpecialPointType.yamakandam,
      nameEn: 'Emakandam',
      nameTa: 'எமகண்டம்',
      shortCode: 'எம',
      lon: yamaLon,
      udayamRasiIndex: udayamRasiIndex,
      descriptionTa: 'ஜாமக்கோள் எமகண்ட புள்ளி (Emakandam)',
    ));

    // 2. Rahu Kaalam (Ra.Ka)
    upagrahas.add(_createPoint(
      type: SpecialPointType.rahuKaalam,
      nameEn: 'Ra.Ka',
      nameTa: 'ரா.கா',
      shortCode: 'ரா.கா',
      lon: rahuKaalamLon,
      udayamRasiIndex: udayamRasiIndex,
      descriptionTa: 'ஜாமக்கோள் ராகு கால காரக புள்ளி (Ra.Ka)',
    ));

    // 3. Mandi (Gulikan)
    upagrahas.add(_createPoint(
      type: SpecialPointType.mandi,
      nameEn: 'Mandi',
      nameTa: 'மாந்தி',
      shortCode: 'மாந்',
      lon: mandiLon,
      udayamRasiIndex: udayamRasiIndex,
      descriptionTa: 'குளிகன் / மாந்தி புள்ளி',
    ));

    // 4. Mridyu
    upagrahas.add(_createPoint(
      type: SpecialPointType.mrityu,
      nameEn: 'Mridyu',
      nameTa: 'மிருத்யு',
      shortCode: 'மிரு',
      lon: mrityuLon,
      udayamRasiIndex: udayamRasiIndex,
      descriptionTa: 'ஜாமக்கோள் மிருத்யு புள்ளி (Mridyu)',
    ));

    return upagrahas;
  }

  static JamakkolSpecialPoint _createPoint({
    required SpecialPointType type,
    required String nameEn,
    required String nameTa,
    required String shortCode,
    required double lon,
    required int udayamRasiIndex,
    String? descriptionTa,
  }) {
    final double norm = normalize(lon);
    final int rIdx = (norm / 30.0).floor() % 12;
    final double degInRasi = norm % 30.0;

    final totalMinutes = norm * 60.0;
    final padaIndex = (totalMinutes / 200.0).floor().clamp(0, 107);
    final nakIdx = (padaIndex ~/ 4).clamp(0, 26);
    final pada = (padaIndex % 4) + 1;

    final int houseFromUdayam = (((rIdx - udayamRasiIndex) % 12 + 12) % 12) + 1;

    return JamakkolSpecialPoint(
      type: type,
      nameEn: nameEn,
      nameTa: nameTa,
      shortCode: shortCode,
      absoluteLongitude: norm,
      rasiIndex: rIdx,
      rasiNameTa: AstrologyCalculator.rasiNamesTa[rIdx],
      rasiNameEn: AstrologyCalculator.rasiNamesEn[rIdx],
      degreeInRasi: degInRasi,
      formattedDms: AstrologyCalculator.formatRasiDegree(degInRasi),
      nakshatraTa: AstrologyCalculator.nakshatrasTa[nakIdx],
      nakshatraEn: AstrologyCalculator.nakshatrasEn[nakIdx],
      nakshatraIndex: nakIdx,
      pada: pada,
      houseFromUdayam: houseFromUdayam,
      descriptionTa: descriptionTa,
    );
  }
}
