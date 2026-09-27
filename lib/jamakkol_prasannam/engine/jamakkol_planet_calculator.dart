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

    // Elapsed minutes from period start (Day: from sunrise or 06:00; Night: from sunset or 18:00)
    final double periodBaseMinutes = isDay
        ? (schedule.sunrise.hour * 60.0 + schedule.sunrise.minute + (schedule.sunrise.second / 60.0))
        : (schedule.sunset.hour * 60.0 + schedule.sunset.minute + (schedule.sunset.second / 60.0));

    double elapsedFromPeriodStart = curMinutes - periodBaseMinutes;
    if (elapsedFromPeriodStart < 0) elapsedFromPeriodStart += 1440.0;
    if (elapsedFromPeriodStart > 720.0) elapsedFromPeriodStart = elapsedFromPeriodStart % 720.0;

    // Outer planets rotate counter-clockwise at 0.5 degrees per minute
    final double currentDayLordLon = normalize(360.0 - (elapsedFromPeriodStart * 0.5));
    final int dayLordCycleIdx = JamamCalculator.getWeekdayLordIndex(schedule.weekdayNumber);

    final List<JamakkolPlanet> result = [];
    final currentJamamLordPlanetKey = schedule.currentJamam.rulingPlanetEn;

    for (int i = 0; i < 8; i++) {
      final pInfo = JamamCalculator.planetCycle[i];
      final double pLon = normalize(currentDayLordLon + ((dayLordCycleIdx - i) * 45.0));
      final int rIdx = (pLon / 30.0).floor() % 12;
      final double degInRasi = pLon % 30.0;

      final totalMinutes = pLon * 60.0;
      final padaIndex = (totalMinutes / 200.0).floor().clamp(0, 107);
      final nakIdx = (padaIndex ~/ 4).clamp(0, 26);
      final pada = (padaIndex % 4) + 1;

      final borderInfo = getRasiBorderInfo(rIdx);
      final formattedDms = AstrologyCalculator.formatRasiDegree(degInRasi);

      result.add(JamakkolPlanet(
        key: pInfo.key,
        nameEn: pInfo.en,
        nameTa: pInfo.ta,
        shortTa: pInfo.shortTa,
        shortEn: pInfo.en.substring(0, math.min(3, pInfo.en.length)),
        absoluteLongitude: pLon,
        rasiIndex: rIdx,
        rasiNameTa: AstrologyCalculator.rasiNamesTa[rIdx],
        rasiNameEn: AstrologyCalculator.rasiNamesEn[rIdx],
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

  /// Calculates Upagrahas: Yamakandam, Rahu Kaalam, Mandi, Mrityu, and Lagna
  static List<JamakkolSpecialPoint> calculateUpagrahas({
    required DateTime queryDateTime,
    required JamakkolLocation location,
    required JamamDaySchedule schedule,
    required double sunLongitude,
    required int udayamRasiIndex,
  }) {
    final int dtWeekday = schedule.weekdayNumber; // 1=Mon .. 7=Sun
    final bool isDay = schedule.currentJamam.isDay;

    final double sunDegInRasi = normalize(sunLongitude) % 30.0;

    // Traditional sign assignments
    const yamaDaySigns = {7: 5, 1: 2, 2: 0, 3: 10, 4: 8, 5: 6, 6: 3};
    const yamaNightSigns = {7: 3, 1: 6, 2: 8, 3: 10, 4: 0, 5: 2, 6: 3};

    const rahuDaySigns = {7: 0, 1: 1, 2: 6, 3: 4, 4: 5, 5: 3, 6: 8};
    const rahuNightSigns = {7: 3, 1: 5, 2: 4, 3: 6, 4: 1, 5: 7, 6: 8};

    const mrityuDaySigns = {7: 7, 1: 2, 2: 3, 3: 4, 4: 5, 5: 6, 6: 7};
    const mrityuNightSigns = {7: 7, 1: 6, 2: 5, 3: 4, 4: 3, 5: 2, 6: 4};

    const mrityuDayOffsets = {7: 0.0, 1: 22.0, 2: 18.0, 3: 14.0, 4: 10.0, 5: 6.0, 6: 24.0};
    const mrityuNightOffsets = {7: 26.0, 1: 22.0, 2: 18.0, 3: 14.0, 4: 10.0, 5: 6.0, 6: 6.0};

    const mandiDaySigns = {7: 10, 1: 4, 2: 2, 3: 0, 4: 10, 5: 6, 6: 5};
    const mandiNightSigns = {7: 5, 1: 6, 2: 10, 3: 0, 4: 2, 5: 4, 6: 1};

    const mandiDayOffsets = {7: 6.0, 1: 22.0, 2: 18.0, 3: 14.0, 4: 10.0, 5: 6.0, 6: 12.0};
    const mandiNightOffsets = {7: 26.0, 1: 22.0, 2: 18.0, 3: 14.0, 4: 10.0, 5: 6.0, 6: 24.0};

    final int yamaRasi = isDay ? (yamaDaySigns[dtWeekday] ?? 3) : (yamaNightSigns[dtWeekday] ?? 3);
    final int rahuKaalamRasi = isDay ? (rahuDaySigns[dtWeekday] ?? 8) : (rahuNightSigns[dtWeekday] ?? 8);
    final int mrityuRasi = isDay ? (mrityuDaySigns[dtWeekday] ?? 7) : (mrityuNightSigns[dtWeekday] ?? 4);
    final double mrityuOffset = isDay ? (mrityuDayOffsets[dtWeekday] ?? 18.0) : (mrityuNightOffsets[dtWeekday] ?? 6.0);
    final int mandiRasi = isDay ? (mandiDaySigns[dtWeekday] ?? 5) : (mandiNightSigns[dtWeekday] ?? 1);
    final double mandiOffset = isDay ? (mandiDayOffsets[dtWeekday] ?? 12.0) : (mandiNightOffsets[dtWeekday] ?? 24.0);

    final double mrityuDeg = (sunDegInRasi + mrityuOffset) % 30.0;
    final double mandiDeg = (sunDegInRasi + mandiOffset) % 30.0;

    final List<JamakkolSpecialPoint> upagrahas = [];

    // 1. Yamakandam
    final double yamaLon = yamaRasi * 30.0 + sunDegInRasi;
    upagrahas.add(_createPoint(
      type: SpecialPointType.yamakandam,
      nameEn: 'Yamakandam',
      nameTa: 'எமகண்டம்',
      shortCode: 'எம',
      lon: yamaLon,
      udayamRasiIndex: udayamRasiIndex,
      descriptionTa: 'எமகண்ட காரக புள்ளி',
    ));

    // 2. Rahu Kaalam
    final double rahuKaalamLon = rahuKaalamRasi * 30.0 + sunDegInRasi;
    upagrahas.add(_createPoint(
      type: SpecialPointType.rahuKaalam,
      nameEn: 'Rahu Kaalam',
      nameTa: 'ராகு காலம்',
      shortCode: 'ரா.கா',
      lon: rahuKaalamLon,
      udayamRasiIndex: udayamRasiIndex,
      descriptionTa: 'ராகு கால காரக புள்ளி',
    ));

    // 3. Mandi (Gulikan)
    final double mandiLon = mandiRasi * 30.0 + mandiDeg;
    upagrahas.add(_createPoint(
      type: SpecialPointType.mandi,
      nameEn: 'Mandi',
      nameTa: 'மாந்தி',
      shortCode: 'மாந்',
      lon: mandiLon,
      udayamRasiIndex: udayamRasiIndex,
      descriptionTa: 'குளிகன் / மாந்தி புள்ளி',
    ));

    // 4. Mrityu
    final double mrityuLon = mrityuRasi * 30.0 + mrityuDeg;
    upagrahas.add(_createPoint(
      type: SpecialPointType.mrityu,
      nameEn: 'Mrityu',
      nameTa: 'மிருத்யு',
      shortCode: 'மிரு',
      lon: mrityuLon,
      udayamRasiIndex: udayamRasiIndex,
      descriptionTa: 'மிருத்யு காரக புள்ளி',
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
