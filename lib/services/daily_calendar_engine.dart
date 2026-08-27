import 'package:intl/intl.dart';
import '../models/daily_calendar_models.dart';
import 'astrology_calculator.dart';
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

  /// Morning & Evening Nalla Neram windows by weekday (1=Mon ... 7=Sun)
  static const Map<int, Map<String, String>> nallaNeramByWeekday = {
    1: {'morning': 'காலை 06:30 AM - 07:30 AM', 'evening': 'மாலை 04:30 PM - 05:30 PM'},
    2: {'morning': 'காலை 07:30 AM - 08:30 AM', 'evening': 'மாலை 04:30 PM - 05:30 PM'},
    3: {'morning': 'காலை 09:30 AM - 10:30 AM', 'evening': 'மாலை 04:30 PM - 05:30 PM'},
    4: {'morning': 'காலை 09:30 AM - 10:30 AM', 'evening': 'மாலை 06:30 PM - 07:30 PM'},
    5: {'morning': 'காலை 09:30 AM - 10:30 AM', 'evening': 'மாலை 04:30 PM - 05:30 PM'},
    6: {'morning': 'காலை 07:30 AM - 08:30 AM', 'evening': 'மாலை 05:00 PM - 06:00 PM'},
    7: {'morning': 'காலை 07:30 AM - 08:30 AM', 'evening': 'மாலை 03:30 PM - 04:30 PM'},
  };

  /// Gowri order for Day by weekday (1=Mon ... 7=Sun)
  static const Map<int, List<String>> gowriDayOrder = {
    1: ['அமிர்தம்', 'ரோகம்', 'லாபம்', 'தனம்', 'விஷம்', 'சுகம்', 'சோரம்', 'உத்தி'],
    2: ['ரோகம்', 'லாபம்', 'தனம்', 'விஷம்', 'சுகம்', 'சோரம்', 'உத்தி', 'அமிர்தம்'],
    3: ['லாபம்', 'தனம்', 'விஷம்', 'சுகம்', 'சோரம்', 'உத்தி', 'அமிர்தம்', 'ரோகம்'],
    4: ['தனம்', 'விஷம்', 'சுகம்', 'சோரம்', 'உத்தி', 'அமிர்தம்', 'ரோகம்', 'லாபம்'],
    5: ['விஷம்', 'சுகம்', 'சோரம்', 'உத்தி', 'அமிர்தம்', 'ரோகம்', 'லாபம்', 'தனம்'],
    6: ['சுகம்', 'சோரம்', 'உத்தி', 'அமிர்தம்', 'ரோகம்', 'லாபம்', 'தனம்', 'விஷம்'],
    7: ['உத்தி', 'அமிர்தம்', 'ரோகம்', 'லாபம்', 'தனம்', 'விஷம்', 'சுகம்', 'சோரம்'],
  };

  /// Gowri order for Night by weekday (1=Mon ... 7=Sun)
  static const Map<int, List<String>> gowriNightOrder = {
    1: ['சுகம்', 'சோரம்', 'உத்தி', 'அமிர்தம்', 'ரோகம்', 'லாபம்', 'தனம்', 'விஷம்'],
    2: ['உத்தி', 'அமிர்தம்', 'ரோகம்', 'லாபம்', 'தனம்', 'விஷம்', 'சுகம்', 'சோரம்'],
    3: ['அமிர்தம்', 'ரோகம்', 'லாபம்', 'தனம்', 'விஷம்', 'சுகம்', 'சோரம்', 'உத்தி'],
    4: ['ரோகம்', 'லாபம்', 'தனம்', 'விஷம்', 'சுகம்', 'சோரம்', 'உத்தி', 'அமிர்தம்'],
    5: ['லாபம்', 'தனம்', 'விஷம்', 'சுகம்', 'சோரம்', 'உத்தி', 'அமிர்தம்', 'ரோகம்'],
    6: ['தனம்', 'விஷம்', 'சுகம்', 'சோரம்', 'உத்தி', 'அமிர்தம்', 'ரோகம்', 'லாபம்'],
    7: ['விஷம்', 'சுகம்', 'சோரம்', 'உத்தி', 'அமிர்தம்', 'ரோகம்', 'லாபம்', 'தனம்'],
  };

  /// Calculate all Daily Calendar details for a given date and location
  static DailyCalendarData calculate({
    required DateTime targetDate,
    double latitude = 13.0827,
    double longitude = 80.2707,
    double utcOffsetHours = 5.5,
  }) {
    // 1. Calculate authoritative ephemeris and sunrise/sunset
    final sunTimes = AstrologyCalculator.calculateSunriseSunset(targetDate, latitude, longitude, utcOffsetHours);
    final sunrise = sunTimes['sunrise']!;
    final sunset = sunTimes['sunset']!;

    // Use midday for stable day-level transit evaluation
    final targetMidday = DateTime(targetDate.year, targetDate.month, targetDate.day, 12, 0);

    final astroData = AstrologyCalculator.calculateHoroscope(
      dateOfBirth: targetMidday,
      latitude: latitude,
      longitude: longitude,
      utcOffsetHours: utcOffsetHours,
    );

    final sun = astroData.sun;
    final moon = astroData.moon;
    final weekdayIdx = targetDate.weekday; // 1=Mon .. 7=Sun
    final weekdayTa = weekdaysTa[weekdayIdx - 1];
    final weekdayEn = DateFormat('EEEE').format(targetDate);
    final englishDateStr = DateFormat('dd / MM / yyyy').format(targetDate);

    // 2. Tamil Date & Month
    final tamilMonth = astroData.tamilMonthTa;
    final tamilDay = astroData.tamilDay;
    final tamilDateFormatted = astroData.tamilDateFormatted;

    // 3. Tithi & Paksha
    final tithi = astroData.tithi;
    final pakshaTa = tithi.isShuklaPaksha ? 'வளர்பிறை (சுக்ல பக்ஷம்)' : 'தேய்பிறை (கிருஷ்ண பக்ஷம்)';

    // 4. Nakshatra, Pada, Star Lord
    const double nakSpan = 360.0 / 27.0;
    const double padaSpan = nakSpan / 4.0;
    final int nakIdx = (moon.longitude / nakSpan).floor() % 27;
    final double nakOffset = moon.longitude - (nakIdx * nakSpan);
    final int pada = ((nakOffset / padaSpan).floor()).clamp(0, 3) + 1;
    final String nakTa = AstrologyCalculator.nakshatrasTa[nakIdx];
    final String starLordTa = moon.tamilStarLord;

    // 5. Nokku Naal
    final nokkuNaalTa = _calculateNokkuNaal(nakIdx);

    // 6. Amirthathi Yoga
    final rem = (weekdayIdx + nakIdx) % 3;
    String amirthathiYogaTa;
    if (rem == 0) amirthathiYogaTa = "அமிர்த யோகம் (மிக சுபம்)";
    else if (rem == 1) amirthathiYogaTa = "சித்த யோகம் (சுபம்)";
    else amirthathiYogaTa = "மரண யோகம் (கவனம் தேவை)";

    // 7. Good Times & Gowri Periods
    final nallaNeram = nallaNeramByWeekday[weekdayIdx] ?? {'morning': '07:30 AM - 08:30 AM', 'evening': '04:30 PM - 05:30 PM'};
    final dayGowri = _calculateGowriPeriods(sunrise, sunset, gowriDayOrder[weekdayIdx]!);
    final nextDaySunrise = sunrise.add(const Duration(days: 1));
    final nightGowri = _calculateGowriPeriods(sunset, nextDaySunrise, gowriNightOrder[weekdayIdx]!);

    // 8. Dynamic Daytime Inauspicious & Muhurtha Windows
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

    // 9. Chandrashtama
    final moonRasiIdx = moon.rasiIndex; // 0..11
    final chandraRasiIdx = (moonRasiIdx - 7 + 12) % 12; // Sign experiencing Chandrashtama
    final chandrashtamaRasiTa = '${AstrologyCalculator.rasiNamesTa[chandraRasiIdx]} (${AstrologyCalculator.rasiNamesEn[chandraRasiIdx]})';
    final chandrashtamaNaks = _getNakshatrasForRasi(chandraRasiIdx);

    // 10. Nendhiram & Jeevan
    final nendhiramJeevan = _calculateNendhiramJeevan(nakIdx);

    // 11. Soolam & Pariharam
    final soolamInfo = soolamByWeekday[weekdayIdx] ?? {'direction': 'வடக்கு', 'pariharam': 'பால்'};

    // 12. Transitions for Tithi, Nakshatra, Yoga, Karana across the day
    final tithiTrans = _calculateTithiTransition(targetDate, sun.longitude, moon.longitude);
    final nakTrans = _calculateNakshatraTransition(targetDate, moon.longitude);
    final yogaTrans = _calculateYogaTransition(targetDate, sun.longitude, moon.longitude);
    final karanaTrans = _calculateKaranaTransition(targetDate, sun.longitude, moon.longitude);

    // 13. Transits for 9 planets
    final transits = _buildPlanetaryTransits(astroData.planets);

    // 14. Pada Saram Notes & Special Events
    final padaSaramNotes = _generatePadaSaramNotes(transits);
    final specialEvents = _detectSpecialEvents(tithi.tithiNumber, nakIdx, tamilDay, tamilMonth);

    final timeFormatter = DateFormat('hh:mm a');

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
      morningNallaNeram: nallaNeram['morning']!,
      eveningNallaNeram: nallaNeram['evening']!,
      dayGowriPeriods: dayGowri,
      nightGowriPeriods: nightGowri,
      tithiNameTa: tithi.tithiNameTa,
      tithiPakshaTa: tithi.pakshaTa,
      tithiNumber: tithi.tithiNumber,
      tithiTransition: tithiTrans,
      nakshatraNameTa: nakTa,
      nakshatraPada: pada,
      nakshatraLordTa: starLordTa,
      nakshatraTransition: nakTrans,
      yogaNameTa: astroData.yogaNameTa,
      yogaTransition: yogaTrans,
      amirthathiYogaTa: amirthathiYogaTa,
      karanaNameTa: astroData.karanaNameTa,
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
      rawPlanets: astroData.planets,
      transits: transits,
      padaSaramNotes: padaSaramNotes,
      specialEvents: specialEvents,
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

  static List<GowriPeriod> _calculateGowriPeriods(DateTime start, DateTime end, List<String> gowriNames) {
    final totalMins = end.difference(start).inMinutes;
    final sliceMins = totalMins / 8.0;
    final formatter = DateFormat('hh:mm a');
    final List<GowriPeriod> list = [];

    const goodNames = ['அமிர்தம்', 'சுகம்', 'லாபம்', 'தனம்'];

    for (int i = 0; i < 8; i++) {
      final pStart = start.add(Duration(minutes: (i * sliceMins).round()));
      final pEnd = start.add(Duration(minutes: ((i + 1) * sliceMins).round()));
      final name = gowriNames[i];
      final isGood = goodNames.contains(name);

      list.add(GowriPeriod(
        nameTa: name,
        timeRange: '${formatter.format(pStart)} - ${formatter.format(pEnd)}',
        isGood: isGood,
        natureTa: isGood ? 'சுபம் (நன்மை)' : 'அசுபம் (தவிர்க்கவும்)',
      ));
    }

    return list;
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
    // 1: Mon (3), 2: Tue (2), 3: Wed (1), 4: Thu (0), 5: Fri (4), 6: Sat (5), 7: Sun (6)
    switch (weekday) {
      case 1: return 3;
      case 2: return 2;
      case 3: return 1;
      case 4: return 0;
      case 5: return 4;
      case 6: return 5;
      case 7: return 6;
      default: return 3;
    }
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

  static Map<String, String> _calculateNendhiramJeevan(int nakIdx) {
    // Traditional table: Odd nakshatras have 2 Nendhiram, 1 Jeevan; others standard
    final int nVal = (nakIdx % 2 == 0) ? 2 : 1;
    final int jVal = (nakIdx % 3 == 0) ? 1 : 2;
    return {
      'nendhiram': '$nVal நேந்திரம் (${nVal >= 2 ? "முழு சுபம்" : "மத்திமம்"})',
      'jeevan': '$jVal ஜீவன் (${jVal >= 1 ? "சுப பலன்" : "அற்ப பலன்"})',
    };
  }

  static PanchangamTransition _calculateTithiTransition(DateTime dt, double sunLong, double moonLong) {
    final curTithi = TithiCalculator.calculateTithi(sunLongitude: sunLong, moonLongitude: moonLong);
    final prevTithi = TithiCalculator.getTithiByNumber(curTithi.tithiNumber == 1 ? 30 : curTithi.tithiNumber - 1);
    final nextTithi = TithiCalculator.getTithiByNumber(curTithi.tithiNumber == 30 ? 1 : curTithi.tithiNumber + 1);

    double diff = moonLong - sunLong;
    if (diff < 0) diff += 360.0;
    double degInTithi = diff % 12.0;
    double remainingDeg = 12.0 - degInTithi;
    double hrsRemaining = (remainingDeg / 12.0) * 24.0; // ~24h avg tithi duration

    final endDt = dt.add(Duration(minutes: (hrsRemaining * 60).round()));
    final timeStr = DateFormat('hh:mm a').format(endDt);

    return PanchangamTransition(
      currentName: '${curTithi.pakshaTa} ${curTithi.tithiNameTa}',
      currentTiming: 'இன்று மாலை $timeStr வரை',
      previousName: '${prevTithi.pakshaTa} ${prevTithi.tithiNameTa}',
      previousTiming: 'நேற்று முடிந்தது',
      nextName: '${nextTithi.pakshaTa} ${nextTithi.tithiNameTa}',
      nextTiming: 'இன்று மாலை $timeStr முதல்',
    );
  }

  static PanchangamTransition _calculateNakshatraTransition(DateTime dt, double moonLong) {
    const double span = 360.0 / 27.0;
    final int curIdx = (moonLong / span).floor() % 27;
    final int prevIdx = (curIdx - 1 + 27) % 27;
    final int nextIdx = (curIdx + 1) % 27;

    final double degInNak = moonLong % span;
    final double remainingDeg = span - degInNak;
    final double hrsRemaining = (remainingDeg / span) * 24.0;

    final endDt = dt.add(Duration(minutes: (hrsRemaining * 60).round()));
    final timeStr = DateFormat('hh:mm a').format(endDt);

    return PanchangamTransition(
      currentName: AstrologyCalculator.nakshatrasTa[curIdx],
      currentTiming: 'இன்று $timeStr வரை',
      previousName: AstrologyCalculator.nakshatrasTa[prevIdx],
      previousTiming: 'நேற்று நிறைவடைந்தது',
      nextName: AstrologyCalculator.nakshatrasTa[nextIdx],
      nextTiming: 'இன்று $timeStr முதல்',
    );
  }

  static PanchangamTransition _calculateYogaTransition(DateTime dt, double sunLong, double moonLong) {
    const double span = 360.0 / 27.0;
    final double sum = (sunLong + moonLong) % 360.0;
    final int curIdx = (sum / span).floor() % 27;
    final int prevIdx = (curIdx - 1 + 27) % 27;
    final int nextIdx = (curIdx + 1) % 27;

    return PanchangamTransition(
      currentName: AstrologyCalculator.yogaNamesTa[curIdx],
      currentTiming: 'முழு பகல் நேரம்',
      previousName: AstrologyCalculator.yogaNamesTa[prevIdx],
      previousTiming: 'முந்தைய யோகம்',
      nextName: AstrologyCalculator.yogaNamesTa[nextIdx],
      nextTiming: 'அடுத்த யோகம்',
    );
  }

  static PanchangamTransition _calculateKaranaTransition(DateTime dt, double sunLong, double moonLong) {
    final cur = AstrologyCalculator.calculateKarana(sunLong, moonLong);
    final curIdx = cur['index'] as int;
    final nextIdx = (curIdx + 1) % 60;
    final prevIdx = (curIdx - 1 + 60) % 60;

    return PanchangamTransition(
      currentName: cur['nameTa'] as String,
      currentTiming: 'அரை திதி காலம்',
      previousName: 'முந்தைய கரணம் (Index $prevIdx)',
      previousTiming: 'நிறைவுற்றது',
      nextName: 'அடுத்த கரணம் (Index $nextIdx)',
      nextTiming: 'தொடங்கும் நேரம்',
    );
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
}
