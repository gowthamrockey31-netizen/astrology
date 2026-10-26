import 'package:intl/intl.dart';
import '../models/daily_calendar_models.dart';
import '../models/tamil_calendar_models.dart';
import 'astrology_calculator.dart';
import 'gowri_panchangam_engine.dart';
import 'jaathaga_kurippugal_calculator.dart';
import 'panchanga_provider.dart';
import 'swiss_ephemeris_calculator.dart';
import 'tithi_calculator.dart';

/// Comprehensive Calculation Engine for Daily Calendar (தினசரி நாள்காட்டி)
class DailyCalendarEngine {
  /// Weekday names in Tamil
  static const List<String> weekdaysTa = [
    'திங்கள்', 'செவ்வாய்', 'புதன்', 'வியாழன்', 'வெள்ளி', 'சனி', 'ஞாயிறு'
  ];

  /// Soolam directions and Pariharam by weekday (1=Mon ... 7=Sun)
  static const Map<int, Map<String, String>> soolamByWeekday = {
    1: {'direction': 'கிழக்கு (East)', 'pariharam': 'தயிர் (Curd)'},
    2: {'direction': 'வடக்கு (North)', 'pariharam': 'பால் (Milk)'},
    3: {'direction': 'வடக்கு (North)', 'pariharam': 'பால் (Milk)'},
    4: {'direction': 'தெற்கு (South)', 'pariharam': 'தைலம் / நெய் (Ghee)'},
    5: {'direction': 'மேற்கு (West)', 'pariharam': 'வெல்லம் (Jaggery)'},
    6: {'direction': 'கிழக்கு (East)', 'pariharam': 'தயிர் (Curd)'},
    7: {'direction': 'மேற்கு (West)', 'pariharam': 'வெல்லம் (Jaggery)'},
  };

  /// Note explaining sunrise-based approximation
  static const String nallaNeramNoteTa =
      'குறிப்பு: மேற்கண்ட நேரம் தோராயமானது. அதனால் அன்றைய தின சூரிய உதயத்திற்கு ஏற்ப மதிப்பீடு செய்து நல்ல நேரம் காண்க...';

  /// Wednesday marriage warning (புதன்கிழமை அன்று திருமணத்தை தவிர்க்க)
  static const String wednesdayMarriageWarning = 'புதன்கிழமை அன்று திருமணத்தை தவிர்க்க';

  /// Morning & Evening Nalla Neram windows by weekday (1=Mon ... 7=Sun)
  static const Map<int, Map<String, String>> nallaNeramByWeekday = {
    1: {
      'morning': 'காலை 06:00 AM - 07:00 AM',
      'evening': 'பகல் 12:00 PM - 01:30 PM',
    },
    2: {
      'morning': 'காலை 10:30 AM - 11:00 AM',
      'evening': 'மாலை 05:30 PM - 06:00 PM',
    },
    3: {
      'morning': 'காலை 09:00 AM - 10:00 AM',
      'evening': 'பகல் 01:30 PM - 03:00 PM, மாலை 04:30 PM - 06:00 PM',
    },
    4: {
      'morning': 'காலை 09:00 AM - 10:30 AM',
      'evening': 'பகல் 01:00 PM - 01:30 PM, மாலை 04:30 PM - 06:00 PM',
    },
    5: {
      'morning': 'காலை 06:00 AM - 07:30 AM',
      'evening': 'பகல் 01:00 PM - 01:30 PM, மாலை 05:00 PM - 06:00 PM',
    },
    6: {
      'morning': 'காலை 10:30 AM - 12:00 PM',
      'evening': 'மாலை 05:00 PM - 06:00 PM',
    },
    7: {
      'morning': 'காலை 07:30 AM - 09:00 AM',
      'evening': 'மாலை 02:00 PM - 03:00 PM',
    },
  };

  /// Authoritative Gowri order for Day by weekday (1=Mon ... 7=Sun) from GowriPanchangamEngine
  static Map<int, List<String>> get gowriDayOrder => {
    for (int d = 1; d <= 7; d++)
      d: (GowriPanchangamEngine.dayGowri[d % 7]!).map((t) => t.tamilName).toList(),
  };

  /// Authoritative Gowri order for Night by weekday (1=Mon ... 7=Sun) from GowriPanchangamEngine
  static Map<int, List<String>> get gowriNightOrder => {
    for (int d = 1; d <= 7; d++)
      d: (GowriPanchangamEngine.nightGowri[d % 7]!).map((t) => t.tamilName).toList(),
  };

  /// Authoritative Tamil date calculation shared by Daily Calendar and Birth Chart
  static ({String month, int day, String formatted}) calculateTamilDate(
    DateTime date, {
    double latitude = 13.0827,
    double longitude = 80.2707,
    double utcOffsetHours = 5.5,
  }) {
    final loc = PanchangaLocation(
      city: 'DailyCalendarLocation',
      latitude: latitude,
      longitude: longitude,
      timezone: utcOffsetHours,
    );
    final tamilDateObj = const AstronomicalPanchangaProvider().getTamilDate(date, location: loc);
    return (
      month: tamilDateObj.tamilMonth,
      day: tamilDateObj.tamilDay,
      formatted: '${tamilDateObj.tamilMonth} - ${tamilDateObj.tamilDay}',
    );
  }

  /// Calculate all Daily Calendar details for a given date and location
  static DailyCalendarData calculate({
    required DateTime targetDate,
    double latitude = 13.0827,
    double longitude = 80.2707,
    double utcOffsetHours = 5.5,
  }) {
    // 1. Calculate authoritative ephemeris and sunrise/sunset (NOAA EoT + 50' refraction)
    final sunTimes = AstrologyCalculator.calculateSunriseSunset(targetDate, latitude, longitude, utcOffsetHours);
    final sunrise = sunTimes['sunrise']!;
    final sunset = sunTimes['sunset']!;

    // In Vedic Panchangam, the day's prevailing elements are evaluated at Sunrise
    final smSunrise = SwissEphemerisCalculator.calculateSunMoonSidereal(
      sunrise,
      utcOffsetHours: utcOffsetHours,
    );
    final sunLongSunrise = smSunrise.sun;
    final moonLongSunrise = smSunrise.moon;

    final astroData = AstrologyCalculator.calculateHoroscope(
      dateOfBirth: sunrise,
      latitude: latitude,
      longitude: longitude,
      utcOffsetHours: utcOffsetHours,
    );

    final weekdayIdx = targetDate.weekday; // 1=Mon .. 7=Sun
    final weekdayTa = weekdaysTa[weekdayIdx - 1];
    final weekdayEn = DateFormat('EEEE').format(targetDate);
    final englishDateStr = DateFormat('dd / MM / yyyy').format(targetDate);

    // 2. Tamil Date & Month (Calculated from authoritative Tamil solar calendar)
    final tamilDateObj = calculateTamilDate(
      targetDate,
      latitude: latitude,
      longitude: longitude,
      utcOffsetHours: utcOffsetHours,
    );
    final tamilMonth = tamilDateObj.month;
    final tamilDay = tamilDateObj.day;
    final tamilDateFormatted = tamilDateObj.formatted;

    // 3. Tithi & Paksha at Sunrise
    final elongSunrise = (moonLongSunrise - sunLongSunrise + 360.0) % 360.0;
    final tithiIdx = (elongSunrise / 12.0).floor() % 30;
    final tithiName = TithiCalculator.tithiNamesTa[tithiIdx];
    final isShukla = tithiIdx < 15;
    final pakshaTa = isShukla ? 'வளர்பிறை (சுக்ல பக்ஷம்)' : 'தேய்பிறை (கிருஷ்ண பக்ஷம்)';
    final tithiFullName = (tithiIdx == 14 || tithiIdx == 29)
        ? tithiName
        : '${isShukla ? "சுக்ல பக்ஷம்" : "கிருஷ்ண பக்ஷம்"} $tithiName';

    // 4. Nakshatra, Pada, Star Lord at Sunrise
    const double nakSpan = 360.0 / 27.0;
    const double padaSpan = nakSpan / 4.0;
    final int nakIdx = (moonLongSunrise / nakSpan).floor() % 27;
    final double nakOffset = (moonLongSunrise - (nakIdx * nakSpan) + 360.0) % 360.0;
    final int pada = ((nakOffset / padaSpan).floor()).clamp(0, 3) + 1;
    final String nakTa = AstrologyCalculator.nakshatrasTa[nakIdx];
    final String starLordTa = AstrologyCalculator.planetLordsTa[nakIdx % 9];

    // 5. Nama Yoga at Sunrise
    final double yogaSumSunrise = (sunLongSunrise + moonLongSunrise) % 360.0;
    final int yogaIdx = (yogaSumSunrise / nakSpan).floor() % 27;
    final String yogaNameTa = AstrologyCalculator.yogaNamesTa[yogaIdx];

    // 6. Karana at Sunrise
    final int karanaNum = (elongSunrise / 6.0).floor() % 60;
    final String karanaNameTa = _getKaranaNameTa(karanaNum);

    // 7. Nokku Naal
    final nokkuNaalTa = _calculateNokkuNaal(nakIdx);

    // 8. Good Times & Gowri Periods
    final nallaNeram = nallaNeramByWeekday[weekdayIdx] ?? {'morning': 'காலை 07:30 AM - 09:00 AM', 'evening': 'மாலை 02:00 PM - 03:00 PM'};
    // Wednesday marriage warning removed as per user requirement
    const String? marriageWarning = null;
    final nextDaySunTimes = AstrologyCalculator.calculateSunriseSunset(
      targetDate.add(const Duration(days: 1)),
      latitude,
      longitude,
      utcOffsetHours,
    );
    final nextDaySunrise = nextDaySunTimes['sunrise'] ?? sunrise.add(const Duration(days: 1));
    final prevDaySunTimes = AstrologyCalculator.calculateSunriseSunset(
      targetDate.subtract(const Duration(days: 1)),
      latitude,
      longitude,
      utcOffsetHours,
    );
    final prevDaySunset = prevDaySunTimes['sunset'] ?? sunset.subtract(const Duration(days: 1));
    final gowriWeekdayIdx = weekdayIdx % 7; // Sunday=0, Monday=1 ... Saturday=6
    final dayGowri = GowriPanchangamEngine.calculateDayGowriPeriods(
      sunrise: sunrise,
      sunset: sunset,
      weekdayIndex: gowriWeekdayIdx,
    );
    final nightGowri = GowriPanchangamEngine.calculateNightGowriPeriods(
      sunset: sunset,
      nextSunrise: nextDaySunrise,
      weekdayIndex: gowriWeekdayIdx,
    );

    // 10. Dynamic Daytime Inauspicious & Muhurtha Windows
    final dayMinutes = sunset.difference(sunrise).inMinutes;
    final partMinutes = dayMinutes / 8.0;

    final rahuKalam = _formatDynamicWindow(sunrise, partMinutes, _getRahuPartIndex(weekdayIdx));
    final yamaGandam = _formatDynamicWindow(sunrise, partMinutes, _getYamaPartIndex(weekdayIdx));
    final gulikaiKalam = _formatDynamicWindow(sunrise, partMinutes, _getGulikaiPartIndex(weekdayIdx));

    // Abhijit Muhurtham (8th of 15 muhurthams = center of daytime)
    final muhurthaLenMins = dayMinutes / 15.0;
    final abhijitStart = sunrise.add(Duration(minutes: (7 * muhurthaLenMins).round()));
    final abhijitEnd = abhijitStart.add(Duration(minutes: muhurthaLenMins.round()));
    final abhijitMuhurtham = '${DateFormat('hh:mm a').format(abhijitStart)} - ${DateFormat('hh:mm a').format(abhijitEnd)}';

    // 11. Chandrashtama (Evaluated at midday to match astronomical panchangam & prevailing daytime moon)
    final middayTime = DateTime(targetDate.year, targetDate.month, targetDate.day, 12, 0);
    final smMidday = SwissEphemerisCalculator.calculateSunMoonSidereal(
      middayTime,
      utcOffsetHours: utcOffsetHours,
    );
    final moonRasiIdx = (smMidday.moon / 30.0).floor() % 12;
    final chandraRasiIdx = (moonRasiIdx - 7 + 12) % 12; // Sign experiencing Chandrashtama
    final chandrashtamaRasiTa = '${AstrologyCalculator.rasiNamesTa[chandraRasiIdx]} (${AstrologyCalculator.rasiNamesEn[chandraRasiIdx]})';
    final chandrashtamaNaks = _getNakshatrasForRasi(chandraRasiIdx);

    // 12. Nendhiram & Jeevan (Authentic Sun Nakshatra -> Moon Nakshatra count)
    final int sunNakIdx = (sunLongSunrise / nakSpan).floor() % 27;
    final nendhiramJeevan = _calculateNendhiramJeevan(sunNakIdx, nakIdx);

    // 13. Soolam & Pariharam
    final soolamInfo = soolamByWeekday[weekdayIdx] ?? {'direction': 'வடக்கு', 'pariharam': 'பால்'};

    // 14. Exact boundary bisection transitions for Tithi, Nakshatra, Yoga, Karana
    final tithiEnd = _findNextBoundaryCrossing(
      startTime: sunrise,
      getAngle: (t) {
        final sm = SwissEphemerisCalculator.calculateSunMoonSidereal(t, utcOffsetHours: utcOffsetHours);
        return (sm.moon - sm.sun + 360.0) % 360.0;
      },
      currentIdx: tithiIdx,
      span: 12.0,
      utcOffsetHours: utcOffsetHours,
    );
    final prevTithi = TithiCalculator.tithiNamesTa[(tithiIdx - 1 + 30) % 30];
    final nextTithi = TithiCalculator.tithiNamesTa[(tithiIdx + 1) % 30];
    final tithiTrans = PanchangamTransition(
      currentName: tithiFullName,
      currentTiming: _formatTransitionTime(targetDate, tithiEnd),
      previousName: prevTithi,
      previousTiming: 'முந்தைய திதி',
      nextName: nextTithi,
      nextTiming: _formatTransitionStart(targetDate, tithiEnd),
    );

    final nakEnd = _findNextBoundaryCrossing(
      startTime: sunrise,
      getAngle: (t) => SwissEphemerisCalculator.calculateSunMoonSidereal(t, utcOffsetHours: utcOffsetHours).moon,
      currentIdx: nakIdx,
      span: nakSpan,
      utcOffsetHours: utcOffsetHours,
    );
    final prevNak = AstrologyCalculator.nakshatrasTa[(nakIdx - 1 + 27) % 27];
    final nextNak = AstrologyCalculator.nakshatrasTa[(nakIdx + 1) % 27];
    final nakTrans = PanchangamTransition(
      currentName: nakTa,
      currentTiming: _formatTransitionTime(targetDate, nakEnd),
      previousName: prevNak,
      previousTiming: 'முந்தைய நட்சத்திரம்',
      nextName: nextNak,
      nextTiming: _formatTransitionStart(targetDate, nakEnd),
    );

    // 8. Nama Yogam / Amirthathi Yoga (Linked to General Yoga)
    final String amirthathiYogaTa = JaathagaKurippugalCalculator.calculateAmirthathiYoga(weekdayIdx, nakIdx);
    final namaYogaInfo = calculateNamaYogaForDay(
      weekdayIdx: weekdayIdx,
      nakIdx: nakIdx,
      targetDate: targetDate,
      nakEnd: nakEnd,
      nextDaySunrise: nextDaySunrise,
    );
    final String amirthathiYogaEn = namaYogaInfo.english;

    final yogaEnd = _findNextBoundaryCrossing(
      startTime: sunrise,
      getAngle: (t) {
        final sm = SwissEphemerisCalculator.calculateSunMoonSidereal(t, utcOffsetHours: utcOffsetHours);
        return (sm.sun + sm.moon) % 360.0;
      },
      currentIdx: yogaIdx,
      span: nakSpan,
      utcOffsetHours: utcOffsetHours,
    );
    final prevYoga = AstrologyCalculator.yogaNamesTa[(yogaIdx - 1 + 27) % 27];
    final nextYoga = AstrologyCalculator.yogaNamesTa[(yogaIdx + 1) % 27];
    final yogaTrans = PanchangamTransition(
      currentName: yogaNameTa,
      currentTiming: _formatTransitionTime(targetDate, yogaEnd),
      previousName: prevYoga,
      previousTiming: 'முந்தைய யோகம்',
      nextName: nextYoga,
      nextTiming: _formatTransitionStart(targetDate, yogaEnd),
    );

    final karanaEnd1 = _findNextBoundaryCrossing(
      startTime: sunrise,
      getAngle: (t) {
        final sm = SwissEphemerisCalculator.calculateSunMoonSidereal(t, utcOffsetHours: utcOffsetHours);
        return (sm.moon - sm.sun + 360.0) % 360.0;
      },
      currentIdx: karanaNum,
      span: 6.0,
      utcOffsetHours: utcOffsetHours,
    );
    final prevKarana = _getKaranaNameTa((karanaNum - 1 + 60) % 60);

    // Look ahead to the subsequent karana (since karanas span 6° / ~12 hours)
    final nextKaranaNum = (karanaNum + 1) % 60;
    final nextKaranaName = _getKaranaNameTa(nextKaranaNum);
    final karanaEnd2 = _findNextBoundaryCrossing(
      startTime: karanaEnd1.add(const Duration(minutes: 2)),
      getAngle: (t) {
        final sm = SwissEphemerisCalculator.calculateSunMoonSidereal(t, utcOffsetHours: utcOffsetHours);
        return (sm.moon - sm.sun + 360.0) % 360.0;
      },
      currentIdx: nextKaranaNum,
      span: 6.0,
      utcOffsetHours: utcOffsetHours,
    );

    String nextKaranaDisplay;
    if (karanaEnd2.isBefore(nextDaySunrise)) {
      final thirdKaranaName = _getKaranaNameTa((karanaNum + 2) % 60);
      nextKaranaDisplay = '$nextKaranaName (${_formatShortTime(karanaEnd2)} வரை), மறு $thirdKaranaName';
    } else {
      nextKaranaDisplay = nextKaranaName;
    }

    final karanaTrans = PanchangamTransition(
      currentName: karanaNameTa,
      currentTiming: _formatTransitionTime(targetDate, karanaEnd1),
      previousName: prevKarana,
      previousTiming: 'முந்தைய கரணம்',
      nextName: nextKaranaDisplay,
      nextTiming: _formatTransitionStart(targetDate, karanaEnd1),
    );

    // 15. Transits for 9 planets
    final transits = _buildPlanetaryTransits(astroData.planets);

    // 16. Pada Saram Notes & Special Events
    final padaSaramNotes = _generatePadaSaramNotes(transits);
    final specialEvents = _detectSpecialEvents(tithiIdx + 1, nakIdx, tamilDay, tamilMonth);

    final timeFormatter = DateFormat('hh:mm a');

    // 15. Transit Lagna (கோச்சார லக்னம் - சூரியன் இருக்கும் ராசியிலிருந்து 2 மணி நேரத்திற்கு ஒரு ராசி மாற்றம்)
    final int sunRasiIdx = (sunLongSunrise / 30.0).floor() % 12;
    final nowTime = DateTime.now();
    final bool isToday = (nowTime.year == targetDate.year && nowTime.month == targetDate.month && nowTime.day == targetDate.day);
    final DateTime evalTime = isToday ? nowTime : sunrise;

    final List<DailyLagnaPeriod> transitLagnaList = [];
    int activeLagnaRasi = sunRasiIdx;
    String activeLagnaStr = '${AstrologyCalculator.rasiNamesTa[sunRasiIdx]} (${AstrologyCalculator.rasiNamesEn[sunRasiIdx]})';

    for (int i = 0; i < 12; i++) {
      final pStart = sunrise.add(Duration(minutes: i * 120));
      final pEnd = sunrise.add(Duration(minutes: (i + 1) * 120));
      final rIdx = (sunRasiIdx + i) % 12;
      final isCurr = !evalTime.isBefore(pStart) && evalTime.isBefore(pEnd);
      if (isCurr) {
        activeLagnaRasi = rIdx;
        activeLagnaStr = '${AstrologyCalculator.rasiNamesTa[rIdx]} (${AstrologyCalculator.rasiNamesEn[rIdx]})';
      }

      transitLagnaList.add(DailyLagnaPeriod(
        rasiIndex: rIdx,
        rasiNameTa: AstrologyCalculator.rasiNamesTa[rIdx],
        rasiNameEn: AstrologyCalculator.rasiNamesEn[rIdx],
        timeRange: '${timeFormatter.format(pStart)} - ${timeFormatter.format(pEnd)}',
        startTime: pStart,
        endTime: pEnd,
        isCurrent: isCurr,
      ));
    }

    // Update rawPlanets with the active Transit Lagna point for the chart display
    final updatedPlanets = Map<String, PlanetDetail>.from(astroData.planets);
    final lagnaLong = (activeLagnaRasi * 30.0 + 15.0);
    updatedPlanets['Lagna'] = PlanetDetail(
      name: 'Lagna',
      tamilName: 'லக்னம்',
      symbol: 'Asc',
      longitude: lagnaLong,
      rasiIndex: activeLagnaRasi,
      rasiNameEn: AstrologyCalculator.rasiNamesEn[activeLagnaRasi],
      rasiNameTa: AstrologyCalculator.rasiNamesTa[activeLagnaRasi],
      degreeInRasi: 15.0,
      nakshatraIndex: (lagnaLong / nakSpan).floor() % 27,
      nakshatraNameEn: AstrologyCalculator.nakshatrasEn[(lagnaLong / nakSpan).floor() % 27],
      nakshatraNameTa: AstrologyCalculator.nakshatrasTa[(lagnaLong / nakSpan).floor() % 27],
      pada: 2,
      starLord: AstrologyCalculator.planetLords[((lagnaLong / nakSpan).floor() % 27) % 9],
      subLord: '',
      tamilStarLord: AstrologyCalculator.planetLordsTa[((lagnaLong / nakSpan).floor() % 27) % 9],
      tamilSubLord: '',
      navamsaPart: 4,
      navamsaIndex: activeLagnaRasi,
      navamsaRasiTa: AstrologyCalculator.rasiNamesTa[activeLagnaRasi],
      navamsaRasiEn: AstrologyCalculator.rasiNamesEn[activeLagnaRasi],
      isRetrograde: false,
    );

    return DailyCalendarData(
      date: targetDate,
      englishDate: englishDateStr,
      weekdayTa: weekdayTa,
      weekdayEn: weekdayEn,
      tamilMonth: tamilMonth,
      tamilDay: tamilDay,
      tamilDateFormatted: tamilDateFormatted,
      pakshaTa: pakshaTa,
      nokkuNaalTa: nokkuNaalTa,
      naalVisheshamTa: specialEvents.isNotEmpty ? specialEvents.first : 'இயல்பான நன்னாள்',
      sunriseStr: timeFormatter.format(sunrise),
      sunsetStr: timeFormatter.format(sunset),
      sunriseTime: sunrise,
      sunsetTime: sunset,
      nextSunriseTime: nextDaySunrise,
      prevSunsetTime: prevDaySunset,
      morningNallaNeram: nallaNeram['morning']!,
      eveningNallaNeram: nallaNeram['evening']!,
      nallaNeramNote: nallaNeramNoteTa,
      marriageWarning: marriageWarning,
      dayGowriPeriods: dayGowri,
      nightGowriPeriods: nightGowri,
      tithiNameTa: tithiName,
      tithiPakshaTa: pakshaTa,
      tithiNumber: tithiIdx + 1,
      tithiTransition: tithiTrans,
      nakshatraNameTa: nakTa,
      nakshatraPada: pada,
      nakshatraLordTa: starLordTa,
      nakshatraTransition: nakTrans,
      yogaNameTa: yogaNameTa,
      yogaTransition: yogaTrans,
      amirthathiYogaTa: amirthathiYogaTa,
      amirthathiYogaEn: amirthathiYogaEn,
      karanaNameTa: karanaNameTa,
      karanaTransition: karanaTrans,
      chandrashtamaRasiTa: chandrashtamaRasiTa,
      chandrashtamaNakshatrasTa: chandrashtamaNaks,
      nendhiramTa: nendhiramJeevan['nendhiram']!,
      jeevanTa: nendhiramJeevan['jeevan']!,
      rahuKalam: rahuKalam,
      gulikaiKalam: gulikaiKalam,
      yamaGandam: yamaGandam,
      abhijitMuhurtham: abhijitMuhurtham,
      soolamDirectionTa: soolamInfo['direction']!,
      pariharamTa: soolamInfo['pariharam']!,
      udayathiNazhigai: astroData.udayathiNazhiStr,
      nakshatraNazhigai: astroData.nakshatraNazhiStr,
      rawPlanets: updatedPlanets,
      transits: transits,
      padaSaramNotes: padaSaramNotes,
      specialEvents: specialEvents,
      currentTransitLagna: activeLagnaStr,
      transitLagnas: transitLagnaList,
    );
  }

  static String _calculateNokkuNaal(int nakIdx) {
    // 0: Ashwini, 1: Bharani, 2: Krittika, 3: Rohini, 4: Mrigashira, 5: Ardra
    // 6: Punarvasu, 7: Pushya, 8: Ashlesha, 9: Magha, 10: Pooram, 11: Uthiram
    // 12: Hastham, 13: Chitra, 14: Swati, 15: Visakam, 16: Anusham, 17: Kettai
    // 18: Moolam, 19: Pooradam, 20: Uthiradam, 21: Thiruvonam, 22: Avittam
    // 23: Sathayam, 24: Poorattathi, 25: Uthirattathi, 26: Revati
    const melNokku = [3, 5, 7, 11, 20, 21, 22, 23, 25];
    const keezhNokku = [1, 2, 8, 9, 10, 15, 18, 19, 24];

    if (melNokku.contains(nakIdx)) {
      return 'மேல் நோக்கு நாள் (கட்டிடம், பயிர் நடவு, உயர்வு காரியங்களுக்கு உகந்தது)';
    } else if (keezhNokku.contains(nakIdx)) {
      return 'கீழ் நோக்கு நாள் (கிணறு வெட்ட, சுரங்கம், அஸ்திவாரம் தோண்ட உகந்தது)';
    } else {
      return 'சம நோக்கு நாள் (சாலை, வாகனம், வியாபாரம், பொது சுப காரியங்களுக்கு உகந்தது)';
    }
  }


  static int _getRahuPartIndex(int weekday) {
    // 1: Mon (1), 2: Tue (6), 3: Wed (4), 4: Thu (5), 5: Fri (3), 6: Sat (2), 7: Sun (7)
    switch (weekday) {
      case 1: return 1;
      case 2: return 6;
      case 3: return 4;
      case 4: return 5;
      case 5: return 3;
      case 6: return 2;
      case 7: return 7;
      default: return 1;
    }
  }

  static int _getYamaPartIndex(int weekday) {
    return AstronomicalPanchangaProvider.yamaParts[weekday] ?? 3;
  }

  static int _getGulikaiPartIndex(int weekday) {
    // 1: Mon (5), 2: Tue (4), 3: Wed (3), 4: Thu (2), 5: Fri (1), 6: Sat (0), 7: Sun (6)
    switch (weekday) {
      case 1: return 5;
      case 2: return 4;
      case 3: return 3;
      case 4: return 2;
      case 5: return 1;
      case 6: return 0;
      case 7: return 6;
      default: return 5;
    }
  }

  static String _formatDynamicWindow(DateTime start, double partMinutes, int partIndex) {
    final pStart = start.add(Duration(minutes: (partIndex * partMinutes).round()));
    final pEnd = start.add(Duration(minutes: ((partIndex + 1) * partMinutes).round()));
    final fmt = DateFormat('hh:mm a');
    return '${fmt.format(pStart)} - ${fmt.format(pEnd)}';
  }

  static String _getNakshatrasForRasi(int rasiIdx) {
    // Each Rasi has 2 1/4 nakshatras (9 padas)
    final startNak = (rasiIdx * 2.25).floor();
    final endNak = ((rasiIdx + 1) * 2.25).ceil().clamp(0, 27);
    final naks = <String>[];
    for (int i = startNak; i < endNak && i < 27; i++) {
      naks.add(AstrologyCalculator.nakshatrasTa[i]);
    }
    return naks.join(', ');
  }

  static Map<String, String> _calculateNendhiramJeevan(int sunNakIdx, int moonNakIdx) {
    // Count k = 1..27 from Sun Nakshatra to Moon Nakshatra
    final k = ((moonNakIdx - sunNakIdx) % 27 + 27) % 27 + 1;
    int nVal;
    double jVal;
    String nDesc;
    String jDesc;

    if (k == 1 || k == 2 || k == 3 || k == 27) {
      nVal = 0; jVal = 0.0;
      nDesc = "சுபம் இல்லை (குருட்டு நாள்)";
      jDesc = "ஜீவன் அற்ற நாள்";
    } else if (k == 4 || k == 25 || k == 26) {
      nVal = 0; jVal = 0.5;
      nDesc = "சுபம் இல்லை (குருட்டு நாள்)";
      jDesc = "அரை ஜீவன் (மத்திமம்)";
    } else if ((k >= 5 && k <= 8) || (k >= 21 && k <= 24)) {
      nVal = 1; jVal = 0.5;
      nDesc = "மத்திமம்";
      jDesc = "அரை ஜீவன் (மத்திமம்)";
    } else if (k == 9) {
      nVal = 2; jVal = 0.5;
      nDesc = "முழு சுபம்";
      jDesc = "அரை ஜீவன் (மத்திமம்)";
    } else if (k == 10) {
      nVal = 2; jVal = 0.0;
      nDesc = "முழு சுபம்";
      jDesc = "ஜீவன் அற்ற நாள்";
    } else if (k >= 11 && k <= 19) {
      nVal = 2; jVal = 1.0;
      nDesc = "முழு சுபம்";
      jDesc = "சுப பலன்";
    } else if (k == 20) {
      nVal = 2; jVal = 0.5;
      nDesc = "முழு சுபம்";
      jDesc = "அரை ஜீவன் (மத்திமம்)";
    } else {
      nVal = 1; jVal = 0.5;
      nDesc = "மத்திமம்";
      jDesc = "அரை ஜீவன் (மத்திமம்)";
    }

    final jStr = jVal == 0.0 ? "0" : (jVal == 0.5 ? "½" : "1");
    return {
      'nendhiram': '$nVal நேந்திரம் ($nDesc)',
      'jeevan': '$jStr ஜீவன் ($jDesc)',
    };
  }

  static String _getKaranaNameTa(int idx) {
    final norm = (idx % 60 + 60) % 60;
    if (norm == 0) return 'கிம்ஸ்துக்னம்';
    if (norm == 57) return 'சகுனி';
    if (norm == 58) return 'சதுஷ்பாதம்';
    if (norm == 59) return 'நாகவம்';
    final mobileIdx = (norm - 1) % 7;
    const names = ['பவம்', 'பாலவம்', 'கௌலவம்', 'தைதுலை', 'கரசை', 'வனசை', 'பத்திரை'];
    return names[mobileIdx];
  }

  static String _formatTransitionTime(DateTime targetCalendarDate, DateTime endDt) {
    final hour = endDt.hour;
    String period;
    if (hour >= 3 && hour < 6) {
      period = 'அதிகாலை';
    } else if (hour >= 6 && hour < 12) {
      period = (hour >= 9) ? 'பகல்' : 'காலை';
    } else if (hour >= 12 && hour < 16) {
      period = 'மதியம்';
    } else if (hour >= 16 && hour < 20) {
      period = 'மாலை';
    } else {
      period = 'இரவு';
    }

    final timeStr = DateFormat('hh:mm a').format(endDt);

    final isSameDay = targetCalendarDate.year == endDt.year &&
        targetCalendarDate.month == endDt.month &&
        targetCalendarDate.day == endDt.day;

    final nextDay = targetCalendarDate.add(const Duration(days: 1));
    final isNextDay = nextDay.year == endDt.year &&
        nextDay.month == endDt.month &&
        nextDay.day == endDt.day;

    if (isSameDay) {
      return 'இன்று $period $timeStr வரை';
    } else if (isNextDay) {
      return 'நாளை $period $timeStr வரை';
    } else {
      return '$period $timeStr வரை';
    }
  }

  static String _formatShortTime(DateTime dt) {
    final hour = dt.hour;
    String period;
    if (hour >= 3 && hour < 6) {
      period = 'அதிகாலை';
    } else if (hour >= 6 && hour < 12) {
      period = (hour >= 9) ? 'பகல்' : 'காலை';
    } else if (hour >= 12 && hour < 16) {
      period = 'மதியம்';
    } else if (hour >= 16 && hour < 20) {
      period = 'மாலை';
    } else {
      period = 'இரவு';
    }
    final timeStr = DateFormat('hh:mm a').format(dt);
    return '$period $timeStr';
  }

  static String _formatTransitionStart(DateTime targetCalendarDate, DateTime startDt) {
    final hour = startDt.hour;
    String period;
    if (hour >= 3 && hour < 6) {
      period = 'அதிகாலை';
    } else if (hour >= 6 && hour < 12) {
      period = (hour >= 9) ? 'பகல்' : 'காலை';
    } else if (hour >= 12 && hour < 16) {
      period = 'மதியம்';
    } else if (hour >= 16 && hour < 20) {
      period = 'மாலை';
    } else {
      period = 'இரவு';
    }

    final timeStr = DateFormat('hh:mm a').format(startDt);

    final isSameDay = targetCalendarDate.year == startDt.year &&
        targetCalendarDate.month == startDt.month &&
        targetCalendarDate.day == startDt.day;

    final nextDay = targetCalendarDate.add(const Duration(days: 1));
    final isNextDay = nextDay.year == startDt.year &&
        nextDay.month == startDt.month &&
        nextDay.day == startDt.day;

    if (isSameDay) {
      return 'இன்று $period $timeStr முதல்';
    } else if (isNextDay) {
      return 'நாளை $period $timeStr முதல்';
    } else {
      return '$period $timeStr முதல்';
    }
  }

  static DateTime _findNextBoundaryCrossing({
    required DateTime startTime,
    required double Function(DateTime) getAngle,
    required int currentIdx,
    required double span,
    required double utcOffsetHours,
  }) {
    final targetBoundary = ((currentIdx + 1) * span) % 360.0;
    final effectiveTarget = (targetBoundary == 0.0) ? 360.0 : targetBoundary;

    bool isPast(double angle) {
      if (effectiveTarget == 360.0) {
        return angle < (currentIdx * span) || angle >= 360.0;
      }
      return angle >= effectiveTarget;
    }

    DateTime lower = startTime;
    DateTime upper = startTime.add(const Duration(hours: 36));

    // Coarse scan: 10-minute intervals
    DateTime t = lower;
    while (t.isBefore(upper)) {
      final nextT = t.add(const Duration(minutes: 10));
      final a1 = getAngle(t);
      final a2 = getAngle(nextT);
      if (!isPast(a1) && isPast(a2)) {
        lower = t;
        upper = nextT;
        break;
      }
      t = nextT;
    }

    // Binary search (bisection) down to 1 second precision
    while (upper.difference(lower).inSeconds > 1) {
      final mid = lower.add(Duration(milliseconds: upper.difference(lower).inMilliseconds ~/ 2));
      final aMid = getAngle(mid);
      if (isPast(aMid)) {
        upper = mid;
      } else {
        lower = mid;
      }
    }

    final exact = lower.add(Duration(seconds: upper.difference(lower).inSeconds ~/ 2));
    final roundedMinute = (exact.second >= 30) ? exact.minute + 1 : exact.minute;
    return DateTime(exact.year, exact.month, exact.day, exact.hour, roundedMinute);
  }

  static List<DailyPlanetTransit> _buildPlanetaryTransits(Map<String, PlanetDetail> planets) {
    final List<DailyPlanetTransit> list = [];
    final targetKeys = ['Sun', 'Moon', 'Mars', 'Mercury', 'Jupiter', 'Venus', 'Saturn', 'Rahu', 'Ketu'];

    for (final key in targetKeys) {
      final p = planets[key];
      if (p == null) continue;

      String summary;
      if (p.isRetrograde) {
        summary = '${p.tamilName} ${p.rasiNameTa} ராசியில் வக்ர கதியில் சஞ்சரிக்கிறார்.';
      } else {
        summary = '${p.tamilName} ${p.rasiNameTa} ராசியில் ${p.nakshatraNameTa} நட்சத்திரத்தில் நேர்கதியில் சஞ்சரிக்கிறார்.';
      }

      list.add(DailyPlanetTransit(
        planetKey: p.name,
        nameTa: p.tamilName,
        nameEn: p.name,
        rasiNameTa: p.rasiNameTa,
        rasiNameEn: p.rasiNameEn,
        rasiIndex: p.rasiIndex,
        degreeInRasi: p.degreeInRasi,
        formattedDegree: '${p.degreeInRasi.toStringAsFixed(2)}°',
        formattedDMS: p.degreeFormatted,
        nakshatraNameTa: p.nakshatraNameTa,
        pada: p.pada,
        isRetrograde: p.isRetrograde,
        transitSummaryTa: summary,
      ));
    }

    return list;
  }

  static List<String> _generatePadaSaramNotes(List<DailyPlanetTransit> transits) {
    final List<String> notes = [];
    for (final t in transits) {
      notes.add('${t.nameTa} : ${t.rasiNameTa} – ${t.formattedDMS} (${t.nakshatraNameTa} ${t.pada}-ஆம் பாதம்)${t.isRetrograde ? " [வக்ரம்]" : ""}');
    }
    return notes;
  }

  static List<String> _detectSpecialEvents(int tithiNum, int nakIdx, int tamilDay, String tamilMonth) {
    final List<String> events = [];

    if (tamilDay == 1) {
      events.add('$tamilMonth மாதப் பிறப்பு (சங்கிராந்தி புண்ணிய காலம்)');
    }
    if (tithiNum == 11 || tithiNum == 26) {
      events.add('ஏகாதசி விரதம் (மகா விஷ்ணு வழிபாடு)');
    }
    if (tithiNum == 13 || tithiNum == 28) {
      events.add('பிரதோஷ விரதம் (சிவபெருமான் விசேஷ வழிபாடு)');
    }
    if (tithiNum == 15) {
      events.add('பௌர்ணமி விரதம் (சத்யநாராயண பூஜை & கிரிவலம்)');
    }
    if (tithiNum == 30) {
      events.add('அமாவாசை புண்ணிய காலம் (பித்ரு தர்ப்பணம்)');
    }
    if (tithiNum == 4 || tithiNum == 19) {
      events.add('சதுர்த்தி விரதம் (விநாயகர் சதுர்த்தி / சங்கடஹர சதுர்த்தி)');
    }
    if (tithiNum == 6 || tithiNum == 21) {
      events.add('சஷ்டி விரதம் (முருகப் பெருமான் வழிபாடு)');
    }
    if (tithiNum == 29) {
      events.add('மாத சிவராத்திரி விரதம்');
    }
    if (nakIdx == 2) {
      events.add('கார்த்திகை விரதம் (கிருத்திகை நட்சத்திர வழிபாடு)');
    }
    if (nakIdx == 21) {
      events.add('திருவோண விரதம் (பெருமாள் விசேஷ ஆராதனை)');
    }

    return events;
  }

  /// Canonical Nama Yogam (அமிர்தாதி யோகம்) evaluation linked to General Yoga
  static NamaYogaType calculateNamaYoga(int weekdayIdx, int nakIdx) {
    final rem = (weekdayIdx + nakIdx) % 3;
    if (rem == 0) return NamaYogaType.amirtha;
    if (rem == 1) return NamaYogaType.siddha;
    return NamaYogaType.marana;
  }

  /// Resolve canonical Nakshatra index from name string (supporting alternate spellings)
  static int resolveNakshatraIndex(String nakshatraName) {
    final clean = nakshatraName.trim().toLowerCase();
    const aliasMap = {
      'அசுவினி': 0, 'அஸ்வினி': 0, 'ashwini': 0, 'aswini': 0,
      'பரணி': 1, 'bharani': 1,
      'கார்த்திகை': 2, 'கிருத்திகை': 2, 'krittika': 2, 'krithika': 2,
      'ரோகிணி': 3, 'ரோஹிணி': 3, 'rohini': 3,
      'மிருகசீரிஷம்': 4, 'மிருகசீரிடம்': 4, 'mrigashira': 4, 'mrigasira': 4,
      'திருவாதிரை': 5, 'ஆருத்ரா': 5, 'ardra': 5, 'arudra': 5,
      'புனர்பூசம்': 6, 'punarvasu': 6,
      'பூசம்': 7, 'புஷ்யம்': 7, 'pushya': 7, 'pushyam': 7,
      'ஆயில்யம்': 8, 'ஆயிலியம்': 8, 'ashlesha': 8, 'aslesha': 8,
      'மகம்': 9, 'magha': 9, 'makam': 9,
      'பூரம்': 10, 'purva phalguni': 10, 'pooram': 10,
      'உத்திரம்': 11, 'uttara phalguni': 11, 'uthiram': 11,
      'அஸ்தம்': 12, 'ஹஸ்தம்': 12, 'hasta': 12, 'hastham': 12,
      'சித்திரை': 13, 'chitra': 13, 'chithirai': 13,
      'சுவாதி': 14, 'ஸ்வாதி': 14, 'swati': 14, 'swathi': 14,
      'விசாகம்': 15, 'vishakha': 15, 'visakam': 15,
      'அனுஷம்': 16, 'அனுசம்': 16, 'anuradha': 16, 'anusham': 16,
      'கேட்டை': 17, 'jyeshtha': 17, 'kettai': 17,
      'மூலம்': 18, 'mula': 18, 'moolam': 18,
      'பூராடம்': 19, 'purva ashadha': 19, 'pooradam': 19,
      'உத்திராடம்': 20, 'uttara ashadha': 20, 'uthiradam': 20,
      'திருவோணம்': 21, 'shravana': 21, 'thiruvonam': 21,
      'அவிட்டம்': 22, 'dhanishta': 22, 'avittam': 22,
      'சதயம்': 23, 'சதாபிஷேக்': 23, 'shatabhisha': 23, 'sadayam': 23,
      'பூரட்டாதி': 24, 'purva bhadrapada': 24, 'poorattathi': 24,
      'உத்திரட்டாதி': 25, 'உத்தரட்டாதி': 25, 'uttara bhadrapada': 25, 'uthirattathi': 25,
      'ரேவதி': 26, 'revati': 26, 'revathi': 26,
    };
    if (aliasMap.containsKey(clean)) {
      return aliasMap[clean]!;
    }
    final taIdx = AstrologyCalculator.nakshatrasTa.indexOf(nakshatraName.trim());
    if (taIdx != -1) return taIdx;
    final enIdx = AstrologyCalculator.nakshatrasEn.indexWhere((n) => n.toLowerCase() == clean);
    if (enIdx != -1) return enIdx;
    return 0;
  }

  /// Calculates dynamic Nama Yogam for a calendar day, incorporating Nakshatra transition times
  static ({String tamil, String english, NamaYogaType primaryYoga, NamaYogaType? nextYoga}) calculateNamaYogaForDay({
    required int weekdayIdx,
    required int nakIdx,
    required DateTime targetDate,
    required DateTime nakEnd,
    required DateTime nextDaySunrise,
  }) {
    final yoga1 = calculateNamaYoga(weekdayIdx, nakIdx);
    final nextNakIdx = (nakIdx + 1) % 27;
    final yoga2 = calculateNamaYoga(weekdayIdx, nextNakIdx);
    final generalTa1 = JaathagaKurippugalCalculator.calculateAmirthathiYoga(weekdayIdx, nakIdx);
    final generalTa2 = JaathagaKurippugalCalculator.calculateAmirthathiYoga(weekdayIdx, nextNakIdx);

    // If Nakshatra transition occurs during this calendar/astrological day (before next sunrise)
    if (nakEnd.isBefore(nextDaySunrise)) {
      if (yoga1 == yoga2) {
        return (
          tamil: generalTa1,
          english: yoga1.englishName,
          primaryYoga: yoga1,
          nextYoga: null,
        );
      } else {
        final timingStr = _formatTransitionTime(targetDate, nakEnd);
        final timingStrEn = _formatTransitionTimeEn(targetDate, nakEnd);
        return (
          tamil: '$generalTa1 ($timingStr), பின் $generalTa2',
          english: '${yoga1.englishName} ($timingStrEn), then ${yoga2.englishName}',
          primaryYoga: yoga1,
          nextYoga: yoga2,
        );
      }
    } else {
      return (
        tamil: generalTa1,
        english: '${yoga1.englishName} (Full Day)',
        primaryYoga: yoga1,
        nextYoga: null,
      );
    }
  }

  static String _formatTransitionTimeEn(DateTime targetCalendarDate, DateTime endDt) {
    final timeStr = DateFormat('hh:mm a').format(endDt);
    final isSameDay = targetCalendarDate.year == endDt.year &&
        targetCalendarDate.month == endDt.month &&
        targetCalendarDate.day == endDt.day;
    if (isSameDay) {
      return 'until today $timeStr';
    } else {
      return 'until tomorrow $timeStr';
    }
  }
}
