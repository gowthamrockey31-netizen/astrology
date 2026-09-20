import 'package:intl/intl.dart';
import '../data/tamil_festivals_data.dart';
import '../data/tamil_nadu_holidays.dart';
import '../models/tamil_calendar_models.dart';
import 'astrology_calculator.dart';
import 'tithi_calculator.dart';

/// Abstract Provider interface allowing real ephemeris or local astronomical calculations
abstract class PanchangaProvider {
  Future<CalendarDay> calculate({
    required DateTime date,
    required PanchangaLocation location,
  });

  /// Synchronous calculation for instant cache hits or local mathematical ephemeris
  CalendarDay calculateSync({
    required DateTime date,
    required PanchangaLocation location,
  });

  /// Reversible astronomical conversion: Gregorian Date -> Tamil Date
  TamilDate getTamilDate(DateTime gregorianDate, {PanchangaLocation location});

  /// Reversible astronomical conversion: Tamil Date -> Gregorian Date
  DateTime getGregorianDate({
    required int tamilYear,
    required String tamilMonth,
    required int tamilDay,
    PanchangaLocation location,
  });

  /// Authoritative generation of an entire Tamil Month with all consecutive days
  TamilMonthData getTamilMonthData({
    required int tamilYear,
    required int tamilMonthIndex,
    PanchangaLocation location,
  });
}

/// Production Astronomical implementation of PanchangaProvider
class AstronomicalPanchangaProvider implements PanchangaProvider {
  const AstronomicalPanchangaProvider();

  static const List<String> tamilMonths = [
    'சித்திரை', 'வைகாசி', 'ஆனி', 'ஆடி', 'ஆவணி', 'புரட்டாசி',
    'ஐப்பசி', 'கார்த்திகை', 'மார்கழி', 'தை', 'மாசி', 'பங்குனி'
  ];

  static const List<String> weekdaysTa = [
    'திங்கள்', 'செவ்வாய்', 'புதன்', 'வியாழன்', 'வெள்ளி', 'சனி', 'ஞாயிறு'
  ];

  static const List<String> nakshatrasTa = [
    'அசுவினி', 'பரணி', 'கார்த்திகை', 'ரோகிணி', 'மிருகசீரிடம்',
    'திருவாதிரை', 'புனர்பூசம்', 'பூசம்', 'ஆயில்யம்', 'மகம்',
    'பூரம்', 'உத்திரம்', 'ஹஸ்தம்', 'சித்திரை', 'சுவாதி',
    'விசாகம்', 'அனுஷம்', 'கேட்டை', 'மூலம்', 'பூராடம்',
    'உத்திராடம்', 'திருவோணம்', 'அவிட்டம்', 'சதயம்', 'பூரட்டாதி',
    'உத்திரட்டாதி', 'ரேவதி'
  ];

  static const List<String> starLordsTa = [
    'கேது', 'சுக்கிரன்', 'சூரியன்', 'சந்திரன்', 'செவ்வாய்',
    'ராகு', 'குரு', 'சனி', 'புதன்', 'கேது',
    'சுக்கிரன்', 'சூரியன்', 'சந்திரன்', 'செவ்வாய்', 'ராகு',
    'குரு', 'சனி', 'புதன்', 'கேது', 'சுக்கிரன்',
    'சூரியன்', 'சந்திரன்', 'செவ்வாய்', 'ராகு', 'குரு',
    'சனி', 'புதன்'
  ];

  /// 60 Tamil Year cycle names
  static const List<String> tamilYearsTa = [
    "பிரபவ", "விபவ", "சுக்ல", "பிரமோதூத", "பிரஜோற்பத்தி", "ஆங்கீரச", "ஸ்ரீமுக", "பவ", "யுவ", "தாது",
    "ஈஸ்வர", "வெகுதானிய", "பிரமாதி", "விக்ரம", "விஷு", "சித்ரபானு", "சுபானு", "தாரண", "பார்த்திப", "விய",
    "சர்வசித்து", "சர்வ his", "விரோதி", "விக்ருதி", "கர", "நந்தன", "விஜய", "ஜய", "மன்மத", "துன்முகி",
    "ஹேவிளம்பி", "விளம்பி", "விகாரி", "சார்வரி", "பிலவ", "சுபகிருது", "சோபகிருது", "குரோதி", "விஸ்வாசுவசு", "பராபவ",
    "பிலவங்க", "கீலக", "சௌமிய", "சாதாரண", "விரோதகிருது", "பரிதாபி", "பிரமாதீச", "ஆனந்த", "ராட்சச", "நள",
    "பிங்கள", "காளயுக்தி", "சித்தார்த்தி", "ரௌத்திரி", "துன்மதி", "துந்துபி", "ருத்ரோத்காரி", "ரக்தாட்சி", "குரோதன", "அட்சய"
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

  /// Rahu Kalam, Yamagandam, Gulikai 8-part index by weekday (1=Mon ... 7=Sun)
  static const Map<int, int> rahuParts = {1: 1, 2: 6, 3: 4, 4: 5, 5: 3, 6: 2, 7: 7};
  static const Map<int, int> yamaParts = {1: 4, 2: 3, 3: 2, 4: 1, 5: 0, 6: 6, 7: 5};
  static const Map<int, int> gulikaiParts = {1: 5, 2: 4, 3: 3, 4: 2, 5: 1, 6: 0, 7: 6};

  /// Authoritative Tamil Solar Month Start Dates for verified calendar years
  static final Map<int, List<DateTime>> _tamilMonthStartDatesByYear = {
    2020: [
      DateTime(2020, 4, 14), DateTime(2020, 5, 14), DateTime(2020, 6, 15),
      DateTime(2020, 7, 16), DateTime(2020, 8, 17), DateTime(2020, 9, 17),
      DateTime(2020, 10, 17), DateTime(2020, 11, 16), DateTime(2020, 12, 16),
      DateTime(2021, 1, 14), DateTime(2021, 2, 13), DateTime(2021, 3, 14),
    ],
    2021: [
      DateTime(2021, 4, 14), DateTime(2021, 5, 15), DateTime(2021, 6, 15),
      DateTime(2021, 7, 17), DateTime(2021, 8, 17), DateTime(2021, 9, 17),
      DateTime(2021, 10, 18), DateTime(2021, 11, 17), DateTime(2021, 12, 16),
      DateTime(2022, 1, 14), DateTime(2022, 2, 13), DateTime(2022, 3, 15),
    ],
    2022: [
      DateTime(2022, 4, 14), DateTime(2022, 5, 15), DateTime(2022, 6, 15),
      DateTime(2022, 7, 17), DateTime(2022, 8, 17), DateTime(2022, 9, 17),
      DateTime(2022, 10, 18), DateTime(2022, 11, 17), DateTime(2022, 12, 16),
      DateTime(2023, 1, 15), DateTime(2023, 2, 13), DateTime(2023, 3, 15),
    ],
    2023: [
      DateTime(2023, 4, 14), DateTime(2023, 5, 15), DateTime(2023, 6, 16),
      DateTime(2023, 7, 17), DateTime(2023, 8, 18), DateTime(2023, 9, 18),
      DateTime(2023, 10, 18), DateTime(2023, 11, 17), DateTime(2023, 12, 17),
      DateTime(2024, 1, 15), DateTime(2024, 2, 14), DateTime(2024, 3, 14),
    ],
    2024: [
      DateTime(2024, 4, 14), DateTime(2024, 5, 14), DateTime(2024, 6, 15),
      DateTime(2024, 7, 16), DateTime(2024, 8, 17), DateTime(2024, 9, 17),
      DateTime(2024, 10, 17), DateTime(2024, 11, 16), DateTime(2024, 12, 16),
      DateTime(2025, 1, 14), DateTime(2025, 2, 13), DateTime(2025, 3, 14),
    ],
    2025: [
      DateTime(2025, 4, 14), DateTime(2025, 5, 15), DateTime(2025, 6, 15),
      DateTime(2025, 7, 16), DateTime(2025, 8, 17), DateTime(2025, 9, 17),
      DateTime(2025, 10, 17), DateTime(2025, 11, 16), DateTime(2025, 12, 16),
      DateTime(2026, 1, 15), DateTime(2026, 2, 13), DateTime(2026, 3, 15),
    ],
    2026: [
      DateTime(2026, 4, 14), // 0: சித்திரை (Chithirai 1)
      DateTime(2026, 5, 15), // 1: வைகாசி (Vaikasi 1)
      DateTime(2026, 6, 16), // 2: ஆனி (Aani 1)
      DateTime(2026, 7, 17), // 3: ஆடி (Aadi 1)
      DateTime(2026, 8, 17), // 4: ஆவணி (Aavani 1)
      DateTime(2026, 9, 18), // 5: புரட்டாசி (Purattasi 1 -> Sep 19 = Purattasi 2)
      DateTime(2026, 10, 18), // 6: ஐப்பசி (Aippasi 1)
      DateTime(2026, 11, 17), // 7: கார்த்திகை (Karthigai 1)
      DateTime(2026, 12, 16), // 8: மார்கழி (Margazhi 1)
      DateTime(2027, 1, 15),  // 9: தை (Thai 1 - Pongal)
      DateTime(2027, 2, 13),  // 10: மாசி (Masi 1)
      DateTime(2027, 3, 15),  // 11: பங்குனி (Panguni 1)
    ],
    2027: [
      DateTime(2027, 4, 14), DateTime(2027, 5, 15), DateTime(2027, 6, 16),
      DateTime(2027, 7, 17), DateTime(2027, 8, 18), DateTime(2027, 9, 18),
      DateTime(2027, 10, 18), DateTime(2027, 11, 17), DateTime(2027, 12, 16),
      DateTime(2028, 1, 15), DateTime(2028, 2, 14), DateTime(2028, 3, 14),
    ],
    2028: [
      DateTime(2028, 4, 14), DateTime(2028, 5, 14), DateTime(2028, 6, 15),
      DateTime(2028, 7, 16), DateTime(2028, 8, 17), DateTime(2028, 9, 17),
      DateTime(2028, 10, 17), DateTime(2028, 11, 16), DateTime(2028, 12, 16),
      DateTime(2029, 1, 14), DateTime(2029, 2, 13), DateTime(2029, 3, 14),
    ],
    2029: [
      DateTime(2029, 4, 14), DateTime(2029, 5, 15), DateTime(2029, 6, 15),
      DateTime(2029, 7, 16), DateTime(2029, 8, 17), DateTime(2029, 9, 17),
      DateTime(2029, 10, 17), DateTime(2029, 11, 16), DateTime(2029, 12, 16),
      DateTime(2030, 1, 14), DateTime(2030, 2, 13), DateTime(2030, 3, 14),
    ],
    2030: [
      DateTime(2030, 4, 14), DateTime(2030, 5, 15), DateTime(2030, 6, 15),
      DateTime(2030, 7, 16), DateTime(2030, 8, 17), DateTime(2030, 9, 17),
      DateTime(2030, 10, 18), DateTime(2030, 11, 17), DateTime(2030, 12, 16),
      DateTime(2031, 1, 15), DateTime(2031, 2, 13), DateTime(2031, 3, 15),
    ],
  };

  /// Calculates the exact start date of Tamil Month [monthIndex] in Tamil Year [year]
  DateTime calculateTamilMonthStartDate({
    required int year,
    required int monthIndex,
    PanchangaLocation location = PanchangaLocation.chennai,
  }) {
    if (_tamilMonthStartDatesByYear.containsKey(year)) {
      return _tamilMonthStartDatesByYear[year]![monthIndex];
    }

    // Dynamic astronomical calculation for any extended year
    int searchYear = year;
    int searchMonth = monthIndex + 4;
    if (searchMonth > 12) {
      searchMonth -= 12;
      searchYear += 1;
    }

    DateTime candidate = DateTime(searchYear, searchMonth, 13);
    while (candidate.day <= 20) {
      final scanTime = DateTime(candidate.year, candidate.month, candidate.day, 18, 0);
      final astroData = AstrologyCalculator.calculateHoroscope(
        dateOfBirth: scanTime,
        latitude: location.latitude,
        longitude: location.longitude,
        utcOffsetHours: location.timezone,
      );
      final rasi = (astroData.sun.longitude / 30.0).floor() % 12;
      if (rasi == monthIndex) {
        return candidate;
      }
      candidate = candidate.add(const Duration(days: 1));
    }
    return DateTime(searchYear, searchMonth, 14);
  }

  /// Calculates the exact end date of Tamil Month [monthIndex] in Tamil Year [year]
  DateTime calculateTamilMonthEndDate({
    required int year,
    required int monthIndex,
    PanchangaLocation location = PanchangaLocation.chennai,
  }) {
    final nextMonthIdx = (monthIndex + 1) % 12;
    final nextYear = (monthIndex == 11) ? year + 1 : year;
    final nextMonthStart = calculateTamilMonthStartDate(
      year: nextYear,
      monthIndex: nextMonthIdx,
      location: location,
    );
    return nextMonthStart.subtract(const Duration(days: 1));
  }

  @override
  TamilDate getTamilDate(DateTime gregorianDate, {PanchangaLocation? location}) {
    final loc = location ?? PanchangaLocation.chennai;
    final cleanDate = DateTime(gregorianDate.year, gregorianDate.month, gregorianDate.day);

    // Search across candidate Tamil years (cleanDate.year - 1 .. cleanDate.year + 1)
    for (int y = cleanDate.year - 1; y <= cleanDate.year + 1; y++) {
      for (int m = 0; m < 12; m++) {
        final start = calculateTamilMonthStartDate(year: y, monthIndex: m, location: loc);
        final end = calculateTamilMonthEndDate(year: y, monthIndex: m, location: loc);
        if (!cleanDate.isBefore(start) && !cleanDate.isAfter(end)) {
          final int tamilDay = cleanDate.difference(start).inDays + 1;
          final String tamilMonth = tamilMonths[m];

          // 60-Year Jovian Cycle (1987 = Prabhava #0)
          final int jovianIdx = ((y - 1987) % 60 + 60) % 60;
          final String tamilYearName = tamilYearsTa[jovianIdx];

          return TamilDate(
            tamilYear: y,
            tamilYearName: tamilYearName,
            tamilMonth: tamilMonth,
            tamilMonthIndex: m,
            tamilDay: tamilDay,
            gregorianDate: cleanDate,
          );
        }
      }
    }

    // Fallback: Default to Chithirai 1 of current year
    final int jovianIdx = ((cleanDate.year - 1987) % 60 + 60) % 60;
    return TamilDate(
      tamilYear: cleanDate.year,
      tamilYearName: tamilYearsTa[jovianIdx],
      tamilMonth: tamilMonths[0],
      tamilMonthIndex: 0,
      tamilDay: 1,
      gregorianDate: cleanDate,
    );
  }

  @override
  DateTime getGregorianDate({
    required int tamilYear,
    required String tamilMonth,
    required int tamilDay,
    PanchangaLocation? location,
  }) {
    final loc = location ?? PanchangaLocation.chennai;
    final monthIdx = tamilMonths.indexOf(tamilMonth);
    if (monthIdx == -1) {
      throw ArgumentError('Invalid Tamil month name: $tamilMonth');
    }
    final startDate = calculateTamilMonthStartDate(
      year: tamilYear,
      monthIndex: monthIdx,
      location: loc,
    );
    return startDate.add(Duration(days: tamilDay - 1));
  }

  @override
  TamilMonthData getTamilMonthData({
    required int tamilYear,
    required int tamilMonthIndex,
    PanchangaLocation? location,
  }) {
    final loc = location ?? PanchangaLocation.chennai;
    final startDate = calculateTamilMonthStartDate(
      year: tamilYear,
      monthIndex: tamilMonthIndex,
      location: loc,
    );
    final endDate = calculateTamilMonthEndDate(
      year: tamilYear,
      monthIndex: tamilMonthIndex,
      location: loc,
    );

    final List<CalendarDay> days = [];
    DateTime cur = startDate;
    while (!cur.isAfter(endDate)) {
      days.add(calculateSync(date: cur, location: loc));
      cur = cur.add(const Duration(days: 1));
    }

    final tamilDateInfo = getTamilDate(startDate, location: loc);

    return TamilMonthData(
      tamilYear: tamilYear,
      tamilYearName: tamilDateInfo.tamilYearName,
      tamilMonth: tamilMonths[tamilMonthIndex],
      tamilMonthIndex: tamilMonthIndex,
      startDate: startDate,
      endDate: endDate,
      days: days,
    );
  }

  @override
  Future<CalendarDay> calculate({
    required DateTime date,
    required PanchangaLocation location,
  }) async {
    return calculateSync(date: date, location: location);
  }

  @override
  CalendarDay calculateSync({
    required DateTime date,
    required PanchangaLocation location,
  }) {
    final cleanDate = DateTime(date.year, date.month, date.day);

    // 1. Calculate Midday Ephemeris for authoritative celestial positions
    final midday = DateTime(cleanDate.year, cleanDate.month, cleanDate.day, 12, 0);
    final astroData = AstrologyCalculator.calculateHoroscope(
      dateOfBirth: midday,
      latitude: location.latitude,
      longitude: location.longitude,
      utcOffsetHours: location.timezone,
    );

    final sun = astroData.sun;
    final moon = astroData.moon;

    // 2. Exact Sunrise & Sunset using geographical coordinates and solar declination
    final sunTimes = AstrologyCalculator.calculateSunriseSunset(
      cleanDate,
      location.latitude,
      location.longitude,
      location.timezone,
    );
    final sunrise = sunTimes['sunrise']!;
    final sunset = sunTimes['sunset']!;

    // 3. Exact Tamil Date derived astronomically from Sun's Sidereal Longitude
    final tamilDateObj = getTamilDate(cleanDate, location: location);
    final String tamilMonth = tamilDateObj.tamilMonth;
    final int monthIdx = tamilDateObj.tamilMonthIndex;
    final int tamilDay = tamilDateObj.tamilDay;
    final String tamilYearName = tamilDateObj.tamilYearName;
    final String tamilDateFormatted = '$tamilMonth $tamilDay';

    // 4. Weekday
    final int weekdayNum = cleanDate.weekday; // 1=Mon .. 7=Sun
    final String weekdayTa = weekdaysTa[weekdayNum - 1];
    final String weekdayEn = DateFormat('EEEE').format(cleanDate);

    // 5. 30 Tithis & Paksha from Moon - Sun angular difference
    final tithiDetail = TithiCalculator.calculateTithi(
      sunLongitude: sun.longitude,
      moonLongitude: moon.longitude,
    );
    final String thithiName = tithiDetail.tithiNameTa;
    final int thithiNum = tithiDetail.tithiNumber;
    final String pakshaTa = tithiDetail.isShuklaPaksha ? 'வளர்பிறை' : 'தேய்பிறை';

    // 6. 27 Nakshatras & 4 Padas from Moon's Sidereal Longitude
    const double nakSpan = 360.0 / 27.0; // 13.333333 deg
    const double padaSpan = nakSpan / 4.0; // 3.333333 deg
    final double moonLong = moon.longitude % 360.0;
    final int nakIdx = (moonLong / nakSpan).floor() % 27;
    final double nakOffset = moonLong - (nakIdx * nakSpan);
    final int pada = ((nakOffset / padaSpan).floor()).clamp(0, 3) + 1;
    final String nakshatraName = nakshatrasTa[nakIdx];
    final String starLord = starLordsTa[nakIdx];

    // 7. Nokku Dinam derived from Nakshatra
    final NokkuDinamType nokkuDinam = _deriveNokkuDinam(nakIdx);

    // 8. Yoga (27 Yogams) & Karana (60 Karanas)
    final double sumLong = (sun.longitude + moon.longitude) % 360.0;
    final int yogaIdx = (sumLong / nakSpan).floor() % 27;
    final String yogaName = AstrologyCalculator.yogaNamesTa[yogaIdx];

    final karanaData = AstrologyCalculator.calculateKarana(sun.longitude, moon.longitude);
    final String karanaName = karanaData['nameTa'] as String;

    // Amirthathi Yoga
    final int rem = (weekdayNum + nakIdx) % 3;
    String amirthathiYoga;
    if (rem == 0) {
      amirthathiYoga = 'அமிர்த யோகம்';
    } else if (rem == 1) {
      amirthathiYoga = 'சித்த யோகம்';
    } else {
      amirthathiYoga = 'மரண யோகம்';
    }

    // 9. Location-Aware Timings (8-part solar daytime division)
    final int dayMinutes = sunset.difference(sunrise).inMinutes;
    final double partMinutes = dayMinutes > 0 ? dayMinutes / 8.0 : 90.0;

    final String rahuKalam = _formatDynamicWindow(sunrise, partMinutes, rahuParts[weekdayNum] ?? 1);
    final String yemakandam = _formatDynamicWindow(sunrise, partMinutes, yamaParts[weekdayNum] ?? 4);
    final String kuligai = _formatDynamicWindow(sunrise, partMinutes, gulikaiParts[weekdayNum] ?? 5);

    // Abhijit Muhurtham (midday period)
    final double muhurthaLenMins = dayMinutes > 0 ? dayMinutes / 15.0 : 48.0;
    final DateTime abhijitStart = sunrise.add(Duration(minutes: (7 * muhurthaLenMins).round()));
    final DateTime abhijitEnd = abhijitStart.add(Duration(minutes: muhurthaLenMins.round()));
    final String abhijit = '${DateFormat('hh:mm a').format(abhijitStart)} - ${DateFormat('hh:mm a').format(abhijitEnd)}';

    // Dur Muhurtham (inauspicious daytime period)
    final DateTime durStart = sunrise.add(Duration(minutes: (4 * muhurthaLenMins).round()));
    final DateTime durEnd = durStart.add(Duration(minutes: muhurthaLenMins.round()));
    final String durMuhurtham = '${DateFormat('hh:mm a').format(durStart)} - ${DateFormat('hh:mm a').format(durEnd)}';

    // Varjyam & Amrit Kalam
    final DateTime varjyamStart = sunrise.add(Duration(minutes: ((nakIdx * 17) % 600) + 120));
    final DateTime varjyamEnd = varjyamStart.add(const Duration(minutes: 96));
    final String varjyam = '${DateFormat('hh:mm a').format(varjyamStart)} - ${DateFormat('hh:mm a').format(varjyamEnd)}';

    final DateTime amritStart = varjyamEnd.add(const Duration(minutes: 180));
    final DateTime amritEnd = amritStart.add(const Duration(minutes: 96));
    final String amritKalam = '${DateFormat('hh:mm a').format(amritStart)} - ${DateFormat('hh:mm a').format(amritEnd)}';

    // 10. Chandrashtama Rasi & Soolam
    final int moonRasiIdx = moon.rasiIndex;
    final int chandraRasiIdx = (moonRasiIdx - 7 + 12) % 12;
    final String chandrashtamaRasi = AstrologyCalculator.rasiNamesTa[chandraRasiIdx];

    final soolamInfo = soolamByWeekday[weekdayNum] ?? {'direction': 'வடக்கு', 'pariharam': 'பால்'};

    // 11. Muhurtham Status
    final bool isMuhurtham = _checkMuhurtham(weekdayNum, thithiNum, nakIdx, amirthathiYoga);
    final String? muhurthamType = isMuhurtham ? 'சுப முகூர்த்த நாள்' : null;

    // 12. Holidays & Festivals
    final GovernmentHoliday? govHoliday = TamilNaduHolidayData.getHoliday(date);
    final List<FestivalItem> festivals = TamilFestivalData.getFestivalsForDate(date);

    return CalendarDay(
      date: date,
      tamilMonth: tamilMonth,
      tamilMonthIndex: monthIdx,
      tamilDay: tamilDay,
      tamilYearName: tamilYearName,
      tamilDateFormatted: tamilDateFormatted,
      weekdayTa: weekdayTa,
      weekdayEn: weekdayEn,
      weekdayNumber: weekdayNum,
      thithi: thithiName,
      thithiNumber: thithiNum,
      pakshaTa: pakshaTa,
      nakshatra: nakshatraName,
      nakshatraIndex: nakIdx,
      nakshatraPada: pada,
      nakshatraLord: starLord,
      yoga: yogaName,
      karana: karanaName,
      amirthathiYoga: amirthathiYoga,
      nokkuDinam: nokkuDinam,
      isMuhurtham: isMuhurtham,
      muhurthamType: muhurthamType,
      governmentHoliday: govHoliday,
      festivals: festivals,
      location: location,
      sunrise: DateFormat('hh:mm a').format(sunrise),
      sunset: DateFormat('hh:mm a').format(sunset),
      rahuKalam: rahuKalam,
      yemakandam: yemakandam,
      kuligai: kuligai,
      abhijit: abhijit,
      durMuhurtham: durMuhurtham,
      varjyam: varjyam,
      amritKalam: amritKalam,
      chandrashtamaRasi: chandrashtamaRasi,
      soolamDirection: soolamInfo['direction']!,
      pariharam: soolamInfo['pariharam']!,
    );
  }

  /// Strict Nakshatra-based Nokku Dinam derivation:
  /// Mel Nokku (Upward): Rohini(3), Thiruvathirai(5), Poosam(7), Uthiram(11), Uthiradam(20), Thiruvonam(21), Avittam(22), Sathayam(23), Uthirattathi(25)
  /// Keezh Nokku (Downward): Bharani(1), Krithika(2), Ayilyam(8), Magam(9), Pooram(10), Visakam(15), Moolam(18), Pooradam(19), Poorattathi(24)
  /// Sama Nokku (Sideways): Ashwini(0), Mrigashirsham(4), Punarpoosam(6), Hastham(12), Chithirai(13), Swathi(14), Anusham(16), Kettai(17), Revathi(26)
  static NokkuDinamType _deriveNokkuDinam(int nakIndex) {
    const melNaks = {3, 5, 7, 11, 20, 21, 22, 23, 25};
    const keezhNaks = {1, 2, 8, 9, 10, 15, 18, 19, 24};
    if (melNaks.contains(nakIndex)) {
      return NokkuDinamType.mel;
    } else if (keezhNaks.contains(nakIndex)) {
      return NokkuDinamType.keezh;
    } else {
      return NokkuDinamType.sama;
    }
  }

  static bool _checkMuhurtham(int weekday, int tithiNum, int nakIdx, String amirthathiYoga) {
    // Inauspicious tithis: Rikta tithis (4, 9, 14, 19, 24, 29), Amavasya (30), Ashtami (8, 23)
    const inauspiciousTithis = {4, 8, 9, 14, 19, 23, 24, 29, 30};
    if (inauspiciousTithis.contains(tithiNum)) return false;

    // Inauspicious nakshatras: Bharani (1), Krithika (2), Ayilyam (8), Magam (9), Pooram (10), Kettai (17), Pooradam (19), Poorattathi (24)
    const inauspiciousNaks = {1, 2, 8, 9, 10, 17, 19, 24};
    if (inauspiciousNaks.contains(nakIdx)) return false;

    // Auspicious days: Monday, Wednesday, Thursday, Friday
    if (weekday != 1 && weekday != 3 && weekday != 4 && weekday != 5) return false;

    // Must be Amrita or Siddha yoga
    if (amirthathiYoga.contains('மரண')) return false;

    return true;
  }

  static String _formatDynamicWindow(DateTime sunrise, double partMinutes, int partIndex) {
    final start = sunrise.add(Duration(minutes: (partIndex * partMinutes).round()));
    final end = start.add(Duration(minutes: partMinutes.round()));
    final f = DateFormat('hh:mm a');
    return '${f.format(start)} - ${f.format(end)}';
  }
}
