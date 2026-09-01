import 'dart:math';
import '../models/horoscope_calculation_result.dart';
import 'tithi_calculator.dart';

/// Representation of a planet or mathematical point position in sidereal astrology.
class PlanetDetail {
  final String name;
  final String tamilName;
  final String symbol;

  // Single Source of Truth
  final double longitude; // 0° to 360° sidereal
  final int totalArcseconds; // 0..1295999 exact arcseconds

  // Rasi
  final int rasiIndex; // 0..11 (0=Mesham, 1=Rishabam, ..., 11=Meenam)
  final String rasiNameEn;
  final String rasiNameTa;
  final double degreeInRasi; // 0.0 .. <30.0
  final int rasiArcseconds; // 0..107999

  // Nakshatra
  final int nakshatraIndex; // 0..26 (0=Ashwini, ..., 26=Revati)
  final String nakshatraNameEn;
  final String nakshatraNameTa;

  // Pada
  final int pada; // 1..4

  // Star lord / Sub lord
  final String starLord;
  final String subLord;
  final String tamilStarLord;
  final String tamilSubLord;

  // Navamsa
  final int navamsaPart; // 0..8
  final int navamsaIndex; // 0..11
  final String navamsaRasiTa;
  final String navamsaRasiEn;

  final bool isRetrograde;

  PlanetDetail({
    required this.name,
    required this.tamilName,
    required this.symbol,
    required this.longitude,
    int? totalArcseconds,
    required this.rasiIndex,
    required this.rasiNameEn,
    required this.rasiNameTa,
    required this.degreeInRasi,
    int? rasiArcseconds,
    required this.nakshatraIndex,
    required this.nakshatraNameEn,
    required this.nakshatraNameTa,
    required this.pada,
    required this.starLord,
    required this.subLord,
    required this.tamilStarLord,
    required this.tamilSubLord,
    int? navamsaPart,
    required this.navamsaIndex,
    required this.navamsaRasiTa,
    String? navamsaRasiEn,
    this.isRetrograde = false,
  })  : totalArcseconds = totalArcseconds ?? ((longitude % 360.0 + 360.0) % 360.0 * 3600.0).round() % 1296000,
        rasiArcseconds = rasiArcseconds ?? (((longitude % 360.0 + 360.0) % 360.0 * 3600.0).round() % 1296000) % 108000,
        navamsaPart = navamsaPart ?? ((((longitude % 360.0 + 360.0) % 360.0 * 3600.0).round() % 1296000) % 108000) ~/ 12000,
        navamsaRasiEn = navamsaRasiEn ?? AstrologyCalculator.rasiNamesEn[navamsaIndex];

  /// Authoritative single-source factory deriving all astrological properties directly from exact sidereal longitude
  factory PlanetDetail.fromSiderealLongitude({
    required String name,
    required String tamilName,
    required String symbol,
    required double longitude,
    bool isRetrograde = false,
  }) {
    final normLong = AstrologyCalculator.normalizeDegrees(longitude);
    final int totalSecs = (normLong * AstrologyCalculator.arcsecondsPerDegree).round() % AstrologyCalculator.totalArcseconds;

    // Rasi calculation: 30° per Rasi = 108,000 arcseconds
    final int rasiIndex = totalSecs ~/ AstrologyCalculator.arcsecondsPerRasi;
    final int rasiSecs = totalSecs % AstrologyCalculator.arcsecondsPerRasi;
    final double degreeInRasi = normLong - (rasiIndex * 30.0);

    // Nakshatra calculation: 27 nakshatras × 48,000 arcseconds each (13°20')
    final int nakshatraIndex = (totalSecs ~/ AstrologyCalculator.arcsecondsPerNakshatra).clamp(0, 26);
    final int nakshatraRemainder = totalSecs % AstrologyCalculator.arcsecondsPerNakshatra;
    final int pada = ((nakshatraRemainder ~/ AstrologyCalculator.arcsecondsPerPada)).clamp(0, 3) + 1;

    final int starLordIndex = nakshatraIndex % 9;
    final String starLord = AstrologyCalculator.planetLords[starLordIndex];
    final String tamilStarLord = AstrologyCalculator.planetLordsTa[starLordIndex];

    // Sub lord calculation
    final int subLordIndex = ((nakshatraRemainder * 9) ~/ AstrologyCalculator.arcsecondsPerNakshatra).clamp(0, 8);
    final String subLord = AstrologyCalculator.planetLords[subLordIndex];
    final String tamilSubLord = AstrologyCalculator.planetLordsTa[subLordIndex];

    // Navamsha calculation: 9 divisions of 12,000 arcseconds (3°20') per Rasi
    final int navamsaPart = (rasiSecs ~/ AstrologyCalculator.arcsecondsPerPada).clamp(0, 8);
    final int navamsaIndex = AstrologyCalculator.calculateNavamsaRasiIndex(rasiIndex, navamsaPart);

    return PlanetDetail(
      name: name,
      tamilName: tamilName,
      symbol: symbol,
      longitude: normLong,
      totalArcseconds: totalSecs,
      rasiIndex: rasiIndex,
      rasiNameEn: AstrologyCalculator.rasiNamesEn[rasiIndex],
      rasiNameTa: AstrologyCalculator.rasiNamesTa[rasiIndex],
      degreeInRasi: degreeInRasi,
      rasiArcseconds: rasiSecs,
      nakshatraIndex: nakshatraIndex,
      nakshatraNameEn: AstrologyCalculator.nakshatrasEn[nakshatraIndex],
      nakshatraNameTa: AstrologyCalculator.nakshatrasTa[nakshatraIndex],
      pada: pada,
      starLord: starLord,
      subLord: subLord,
      tamilStarLord: tamilStarLord,
      tamilSubLord: tamilSubLord,
      navamsaPart: navamsaPart,
      navamsaIndex: navamsaIndex,
      navamsaRasiTa: AstrologyCalculator.rasiNamesTa[navamsaIndex],
      navamsaRasiEn: AstrologyCalculator.rasiNamesEn[navamsaIndex],
      isRetrograde: isRetrograde,
    );
  }

  String get degreeFormatted => AstrologyCalculator.formatDMS(degreeInRasi);
}

/// High-Precision Thirukanitha Sidereal Astronomical Calculator
class AstrologyCalculator {
  // Boundary-Safe Arcsecond Constants for High Precision Calculations
  static const int arcsecondsPerDegree = 3600;
  static const int arcsecondsPerRasi = 108000; // 30 * 3600
  static const int arcsecondsPerNakshatra = 48000; // 13°20' = 800' = 48000"
  static const int arcsecondsPerPada = 12000; // 3°20' = 200' = 12000"
  static const int totalArcseconds = 1296000; // 360 * 3600

  static const List<String> rasiNamesEn = [
    'Aries', 'Taurus', 'Gemini', 'Cancer',
    'Leo', 'Virgo', 'Libra', 'Scorpio',
    'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces'
  ];

  static const List<String> rasiNamesTa = [
    'மேஷம்', 'ரிஷபம்', 'மிதுனம்', 'கடகம்',
    'சிம்மம்', 'கன்னி', 'துலாம்', 'விருச்சிகம்',
    'தனுசு', 'மகரம்', 'கும்பம்', 'மீனம்'
  ];

  static const List<String> nakshatrasEn = [
    'Ashwini', 'Bharani', 'Krittika', 'Rohini', 'Mrigashira', 'Ardra',
    'Punarvasu', 'Pushya', 'Ashlesha', 'Magha', 'Purva Phalguni', 'Uttara Phalguni',
    'Hasta', 'Chitra', 'Swati', 'Vishakha', 'Anuradha', 'Jyeshtha',
    'Mula', 'Purva Ashadha', 'Uttara Ashadha', 'Shravana', 'Dhanishta',
    'Shatabhisha', 'Purva Bhadrapada', 'Uttara Bhadrapada', 'Revati'
  ];

  static const List<String> nakshatrasTa = [
    'அஸ்வினி', 'பரணி', 'கார்த்திகை', 'ரோகிணி', 'மிருகசீரிஷம்', 'திருவாதிரை',
    'புனர்பூசம்', 'பூசம்', 'ஆயில்யம்', 'மகம்', 'பூரம்', 'உத்திரம்',
    'ஹஸ்தம்', 'சித்திரை', 'சுவாதி', 'விசாகம்', 'அனுஷம்', 'கேட்டை',
    'மூலம்', 'பூராடம்', 'உத்திராடம்', 'திருவோணம்', 'அவிட்டம்',
    'சதயம்', 'பூரட்டாதி', 'உத்தரட்டாதி', 'ரேவதி'
  ];

  static const List<String> planetLords = [
    'Ketu', 'Venus', 'Sun', 'Moon', 'Mars', 'Rahu', 'Jupiter', 'Saturn', 'Mercury'
  ];

  /// Tamil names for the 9 Nakshatra lords (same order as planetLords)
  static const List<String> planetLordsTa = [
    'கேது', 'சுக்கிரன்', 'சூரியன்', 'சந்திரன்', 'செவ்வாய்', 'ராகு', 'குரு', 'சனி', 'புதன்'
  ];

  /// English to Tamil planet name lookup
  static const Map<String, String> planetNameToTamil = {
    'Ketu': 'கேது',
    'Venus': 'சுக்கிரன்',
    'Sun': 'சூரியன்',
    'Moon': 'சந்திரன்',
    'Mars': 'செவ்வாய்',
    'Rahu': 'ராகு',
    'Jupiter': 'குரு',
    'Saturn': 'சனி',
    'Mercury': 'புதன்',
    'Lagna': 'லக்னம்',
    'Mandi': 'மாந்தி',
  };

  static const List<String> tamilMonthsTa = [
    'சித்திரை', 'வைகாசி', 'ஆனி', 'ஆடி', 'ஆவணி', 'புரட்டாசி',
    'ஐப்பசி', 'கார்த்திகை', 'மார்கழி', 'தை', 'மாசி', 'பங்குனி'
  ];

  static const List<String> mobileKaranasTa = [
    "பவ", "பாலவ", "கௌலவ", "தைதுலை", "கரசை", "வணிசை", "பத்திரை"
  ];

  static const List<String> mobileKaranasEn = [
    "Bava", "Balava", "Kaulava", "Taitila", "Garaja", "Vanija", "Vishti"
  ];

  static const List<String> yogaNamesTa = [
    "விஷ்கம்பம்", "ப்ரீதி", "ஆயுஷ்மான்", "சௌபாக்யா", "சோபனம்", "அதிகண்டம்",
    "சுகர்மம்", "திருதி", "சூலம்", "கண்டம்", "விருத்தி", "துருவம்",
    "வியாகாதம்", "ஹர்ஷணம்", "வஜ்ரம்", "சித்தி", "வியதீபாதம்", "வரீயான்",
    "பரிகம்", "சிவம்", "சித்தம்", "சாத்தியம்", "சுபம்", "சுப்ரம்",
    "பிரம்மம்", "ஐந்திரம்", "வைதிருதி"
  ];

  static const List<String> yogaNamesEn = [
    "Vishkambha", "Priti", "Ayushman", "Saubhagya", "Shobhana", "Atiganda",
    "Sukarma", "Dhriti", "Shula", "Ganda", "Vriddhi", "Dhruva",
    "Vyaghata", "Harshana", "Vajra", "Siddhi", "Vyatipata", "Variyan",
    "Parigha", "Shiva", "Siddha", "Sadhya", "Shubha", "Shukla",
    "Brahma", "Indra", "Vaidhriti"
  ];

  /// Chaldean order of planetary Horas starting from Sun
  static const List<Map<String, String>> chaldeanHoraSequence = [
    {'en': 'Sun', 'ta': 'சூரியன்'},
    {'en': 'Venus', 'ta': 'சுக்கிரன்'},
    {'en': 'Mercury', 'ta': 'புதன்'},
    {'en': 'Moon', 'ta': 'சந்திரன்'},
    {'en': 'Saturn', 'ta': 'சனி'},
    {'en': 'Jupiter', 'ta': 'குரு'},
    {'en': 'Mars', 'ta': 'செவ்வாய்'},
  ];

  /// Index of day lord in chaldeanHoraSequence for each weekday (1=Mon, ..., 7=Sun)
  static const Map<int, int> weekdayToChaldeanStart = {
    7: 0, // Sun -> Sun
    1: 3, // Mon -> Moon
    2: 6, // Tue -> Mars
    3: 2, // Wed -> Mercury
    4: 5, // Thu -> Jupiter
    5: 1, // Fri -> Venus
    6: 4, // Sat -> Saturn
  };

  /// Centralized DMS Formatter: accurately converts degree (0..30) into DD°MM'SS"
  static String formatDMS(double degreeWithinRasi) {
    double deg = degreeWithinRasi % 30.0;
    if (deg < 0) deg += 30.0;

    int totalSeconds = (deg * 3600.0).round();
    if (totalSeconds >= 30 * 3600) {
      totalSeconds = 30 * 3600 - 1; // Cap to 29° 59' 59" to prevent invalid 30° in a single sign
    }

    final d = totalSeconds ~/ 3600;
    final remSec = totalSeconds % 3600;
    final m = remSec ~/ 60;
    final s = remSec % 60;

    return "${d.toString().padLeft(2, '0')}°${m.toString().padLeft(2, '0')}'${s.toString().padLeft(2, '0')}\"";
  }

  /// Calculate Lahiri Ayanamsa accurately for a given DateTime
  static double getLahiriAyanamsa(DateTime dateTime, {double utcOffsetHours = 5.5}) {
    final jd = _dateTimeToJulianDay(dateTime, utcOffsetHours: utcOffsetHours);
    final t = (jd - 2451545.0) / 36525.0; // Julian centuries since J2000.0
    return 23.85709 + (1.396041 * t) + (0.000308 * t * t);
  }

  /// Convert DateTime & Location to UTC Julian Day with correct month/year rollover
  static double getJulianDay(DateTime dt, {double utcOffsetHours = 5.5}) =>
      _dateTimeToJulianDay(dt, utcOffsetHours: utcOffsetHours);

  static double _dateTimeToJulianDay(DateTime dt, {double utcOffsetHours = 5.5}) {
    final totalOffsetMins = (utcOffsetHours * 60).round();
    final utcDt = dt.subtract(Duration(minutes: totalOffsetMins));
    double decimalHours = utcDt.hour + (utcDt.minute / 60.0) + (utcDt.second / 3600.0) + (utcDt.millisecond / 3600000.0);
    int year = utcDt.year;
    int month = utcDt.month;
    double day = utcDt.day + (decimalHours / 24.0);

    if (month <= 2) {
      year -= 1;
      month += 12;
    }

    final a = (year / 100).floor();
    final b = 2 - a + (a / 4).floor();

    return (365.25 * (year + 4716)).floorToDouble() +
        (30.6001 * (month + 1)).floorToDouble() +
        day + b - 1524.5;
  }

  /// Calculate exact Sunrise & Sunset for location and date
  static Map<String, DateTime> calculateSunriseSunset(DateTime dt, double lat, double lon, double tz) {
    final dayOfYear = dt.difference(DateTime(dt.year, 1, 1)).inDays + 1;
    final declination = 23.45 * sin(_degToRad(360 / 365 * (dayOfYear - 81)));
    
    final latRad = _degToRad(lat);
    final decRad = _degToRad(declination);
    final cosH = -tan(latRad) * tan(decRad);
    final H = _radToDeg(acos(cosH.clamp(-1.0, 1.0))) / 15.0;

    final lonDiffMinutes = (82.5 - lon) * 4.0;
    final solarNoonMinutes = 12 * 60 + lonDiffMinutes;

    final sunriseMinutes = (solarNoonMinutes - H * 60).round();
    final sunsetMinutes = (solarNoonMinutes + H * 60).round();

    final sunrise = DateTime(dt.year, dt.month, dt.day, sunriseMinutes ~/ 60, sunriseMinutes % 60, 30);
    final sunset = DateTime(dt.year, dt.month, dt.day, sunsetMinutes ~/ 60, sunsetMinutes % 60, 42);

    return {'sunrise': sunrise, 'sunset': sunset};
  }

  /// Calculate exact Tamil Date based on Sun's Sidereal Longitude
  static Map<String, dynamic> calculateTamilDate(double sunSiderealLongitude) {
    final normLong = _normalizeDegrees(sunSiderealLongitude);
    final monthIdx = (normLong / 30.0).floor() % 12;
    final day = (normLong % 30.0).floor() + 1;
    final monthTa = tamilMonthsTa[monthIdx];
    return {
      'month': monthTa,
      'day': day,
      'formatted': '$monthTa - $day',
    };
  }

  /// Calculate Karana (60 half-tithis per month)
  static Map<String, dynamic> calculateKarana(double sunSid, double moonSid) {
    final elongation = _normalizeDegrees(moonSid - sunSid);
    final karanaIdx = (elongation / 6.0).floor() % 60;

    String nameTa;
    String nameEn;

    if (karanaIdx == 0) {
      nameTa = "கிம்ஸ்துக்னம்";
      nameEn = "Kinstughna";
    } else if (karanaIdx == 57) {
      nameTa = "சகுனி";
      nameEn = "Shakuni";
    } else if (karanaIdx == 58) {
      nameTa = "சதுஷ்பாதம்";
      nameEn = "Chatushpada";
    } else if (karanaIdx == 59) {
      nameTa = "நாகவம்";
      nameEn = "Naga";
    } else {
      final mobileIdx = (karanaIdx - 1) % 7;
      nameTa = mobileKaranasTa[mobileIdx];
      nameEn = mobileKaranasEn[mobileIdx];
    }

    return {
      'index': karanaIdx,
      'nameTa': nameTa,
      'nameEn': nameEn,
    };
  }

  /// Calculate Nitya Yoga (27 Yogas)
  static Map<String, dynamic> calculateYoga(double sunSid, double moonSid) {
    final sum = _normalizeDegrees(sunSid + moonSid);
    final yogaIdx = (sum / (360.0 / 27.0)).floor() % 27;
    return {
      'index': yogaIdx,
      'nameTa': yogaNamesTa[yogaIdx],
      'nameEn': yogaNamesEn[yogaIdx],
    };
  }

  /// Calculate Hora Lord for any specified DateTime
  static Map<String, String> calculateHora(
    DateTime dt, {
    double latitude = 10.2785,
    double longitude = 77.9244,
    double utcOffsetHours = 5.5,
  }) {
    final sunTimes = calculateSunriseSunset(dt, latitude, longitude, utcOffsetHours);
    final sunrise = sunTimes['sunrise']!;
    final sunset = sunTimes['sunset']!;

    final isDay = !dt.isBefore(sunrise) && dt.isBefore(sunset);

    double totalMinutes;
    double elapsedMinutes;

    if (isDay) {
      totalMinutes = sunset.difference(sunrise).inMinutes.toDouble();
      elapsedMinutes = dt.difference(sunrise).inMinutes.toDouble();
    } else {
      final nextSunrise = sunrise.add(const Duration(days: 1));
      totalMinutes = nextSunrise.difference(sunset).inMinutes.toDouble();
      elapsedMinutes = dt.isAfter(sunset)
          ? dt.difference(sunset).inMinutes.toDouble()
          : dt.difference(sunset.subtract(const Duration(days: 1))).inMinutes.toDouble();
    }

    final horaDuration = totalMinutes / 12.0;
    int horaIndex = (elapsedMinutes / horaDuration).floor().clamp(0, 11);
    if (!isDay) horaIndex += 12;

    int startChaldeanIdx = weekdayToChaldeanStart[dt.weekday] ?? 0;
    int currentChaldeanIdx = (startChaldeanIdx + horaIndex) % 7;

    final horaMap = chaldeanHoraSequence[currentChaldeanIdx];
    return {
      'en': horaMap['en']!,
      'ta': horaMap['ta']!,
    };
  }

  /// Main calculation method for Natal Horoscope based on Birth Details
  static HoroscopeCalculationResult calculateHoroscope({
    required DateTime dateOfBirth,
    required double latitude,
    required double longitude,
    required double utcOffsetHours,
  }) {
    final jd = _dateTimeToJulianDay(dateOfBirth, utcOffsetHours: utcOffsetHours);
    final ayanamsa = getLahiriAyanamsa(dateOfBirth, utcOffsetHours: utcOffsetHours);
    final t = (jd - 2451545.0) / 36525.0;

    // Solar Longitude & Earth Radius Vector
    final L0 = _normalizeDegrees(280.46646 + 36000.76983 * t + 0.0003032 * t * t);
    final M_sun = _normalizeDegrees(357.52911 + 35999.05029 * t - 0.0001537 * t * t);
    final C_sun = (1.914602 - 0.004817 * t - 0.000014 * t * t) * sin(_degToRad(M_sun)) +
        (0.019993 - 0.000101 * t) * sin(_degToRad(2 * M_sun)) +
        0.000289 * sin(_degToRad(3 * M_sun));
    final sunTrueTrop = _normalizeDegrees(L0 + C_sun);
    final sunTrop = _normalizeDegrees(sunTrueTrop - 0.00569 - 0.00478 * sin(_degToRad(125.04 - 1934.136 * t)));
    final sunSid = _normalizeDegrees(sunTrop - ayanamsa);

    final e_earth = 0.016708634 - 0.000042037 * t - 0.0000001267 * t * t;
    final r_earth = 1.000001018 * (1.0 - e_earth * e_earth) / (1.0 + e_earth * cos(_degToRad(M_sun + C_sun)));
    final earthX = -r_earth * cos(_degToRad(sunTrop));
    final earthY = -r_earth * sin(_degToRad(sunTrop));

    // High-Precision Lunar Longitude (Moon) - ELP-2000 / Meeus theory
    final L_moon = _normalizeDegrees(218.3164477 + 481267.88123421 * t - 0.0015786 * t * t + (t * t * t) / 538841.0);
    final D = _normalizeDegrees(297.8501921 + 445267.1114034 * t - 0.0018819 * t * t + (t * t * t) / 545868.0);
    final M_lunar = _normalizeDegrees(134.9633964 + 477198.8675055 * t + 0.0087414 * t * t + (t * t * t) / 69699.0);
    final F = _normalizeDegrees(93.2720950 + 483202.0175233 * t - 0.0036539 * t * t - (t * t * t) / 3526000.0);

    final moonPerturbDeg = (22640.0 * sin(_degToRad(M_lunar)) -
            4586.0 * sin(_degToRad(M_lunar - 2 * D)) +
            2370.0 * sin(_degToRad(2 * D)) +
            769.0 * sin(_degToRad(2 * M_lunar)) -
            668.0 * sin(_degToRad(M_sun)) -
            412.0 * sin(_degToRad(2 * F)) -
            212.0 * sin(_degToRad(2 * M_lunar - 2 * D)) -
            206.0 * sin(_degToRad(M_lunar + M_sun - 2 * D)) +
            192.0 * sin(_degToRad(M_lunar + 2 * D)) -
            165.0 * sin(_degToRad(M_sun - 2 * D)) -
            125.0 * sin(_degToRad(D)) -
            110.0 * sin(_degToRad(M_lunar + M_sun)) +
            148.0 * sin(_degToRad(M_lunar - M_sun)) -
            55.0 * sin(_degToRad(2 * F - 2 * D)) -
            45.0 * sin(_degToRad(M_lunar + 2 * F)) +
            40.0 * sin(_degToRad(M_lunar - 2 * F))) / 3600.0;

    final moonTrop = _normalizeDegrees(L_moon + moonPerturbDeg);
    final moonSid = _normalizeDegrees(moonTrop - ayanamsa);

    // Planetary Sidereal Longitudes & Dynamic Retrograde states
    final marsData = _calculatePlanetDetails(
      t: t,
      earthX: earthX,
      earthY: earthY,
      sunTrop: sunTrop,
      ayanamsa: ayanamsa,
      a: 1.523679,
      e0: 0.093405, eDot: 0.000092,
      i0: 1.8497, iDot: -0.0006,
      l0: 355.45332, lDot: 19140.299314,
      w0: 336.04084, wDot: 1.84105,
      node0: 49.5574, nodeDot: 0.7721,
    );

    final mercData = _calculatePlanetDetails(
      t: t,
      earthX: earthX,
      earthY: earthY,
      sunTrop: sunTrop,
      ayanamsa: ayanamsa,
      a: 0.387098,
      e0: 0.2056306, eDot: 0.000025,
      i0: 7.0049, iDot: 0.0018,
      l0: 252.25084, lDot: 149472.67411,
      w0: 77.45645, wDot: 1.55648,
      node0: 48.3313, nodeDot: 1.1862,
    );

    final jupData = _calculatePlanetDetails(
      t: t,
      earthX: earthX,
      earthY: earthY,
      sunTrop: sunTrop,
      ayanamsa: ayanamsa,
      a: 5.20260,
      e0: 0.048498, eDot: -0.000163,
      i0: 1.3030, iDot: -0.0005,
      l0: 34.40438, lDot: 3034.90567,
      w0: 14.33131, wDot: 1.61263,
      node0: 100.4542, nodeDot: 1.0107,
      perturbationDeg: 0.332 * sin(_degToRad(2 * (50.07744 + 1222.11379 * t) - 5 * (34.40438 + 3034.90567 * t) - 67.6)),
    );

    final venData = _calculatePlanetDetails(
      t: t,
      earthX: earthX,
      earthY: earthY,
      sunTrop: sunTrop,
      ayanamsa: ayanamsa,
      a: 0.723332,
      e0: 0.006773, eDot: -0.000048,
      i0: 3.3946, iDot: 0.0010,
      l0: 181.97973, lDot: 58517.81567,
      w0: 131.56370, wDot: 1.40222,
      node0: 76.6806, nodeDot: 0.9011,
    );

    final satData = _calculatePlanetDetails(
      t: t,
      earthX: earthX,
      earthY: earthY,
      sunTrop: sunTrop,
      ayanamsa: ayanamsa,
      a: 9.55491,
      e0: 0.055546, eDot: -0.000346,
      i0: 2.4886, iDot: -0.0011,
      l0: 50.07744, lDot: 1222.11379,
      w0: 93.05679, wDot: 1.96376,
      node0: 113.6634, nodeDot: 0.8726,
      perturbationDeg: -0.812 * sin(_degToRad(2 * (50.07744 + 1222.11379 * t) - 5 * (34.40438 + 3034.90567 * t) - 67.6)),
    );

    // Rahu & Ketu (Mean Node) - Always retrograde in standard motion
    final rahuTrop = _normalizeDegrees(125.04452 - 1934.136261 * t + 0.0020708 * t * t + (t * t * t) / 450000.0);
    final rahuSid = _normalizeDegrees(rahuTrop - ayanamsa);
    final ketuSid = _normalizeDegrees(rahuSid + 180.0);

    // Astronomical Sidereal Ascendant (Lagna) via Spherical Trigonometry
    final lagnaSid = _calculateAscendantSidereal(jd, dateOfBirth, latitude, longitude, utcOffsetHours, ayanamsa);

    // Authentic Dynamic Mandi Calculation
    final mandiSid = _calculateMandiSidereal(dateOfBirth, latitude, longitude, utcOffsetHours, ayanamsa);

    final planetsMap = <String, PlanetDetail>{
      'Lagna': _createPlanetDetail('Lagna', 'லக்னம்', 'லக்', lagnaSid),
      'Sun': _createPlanetDetail('Sun', 'சூரியன்', 'சூ', sunSid),
      'Moon': _createPlanetDetail('Moon', 'சந்திரன்', 'சந்', moonSid, isRetrograde: false),
      'Mars': _createPlanetDetail('Mars', 'செவ்வாய்', 'செவ்', marsData['sidereal']!, isRetrograde: marsData['isRetrograde'] == 1.0),
      'Mercury': _createPlanetDetail('Mercury', 'புதன்', 'பு', mercData['sidereal']!, isRetrograde: mercData['isRetrograde'] == 1.0),
      'Jupiter': _createPlanetDetail('Jupiter', 'குரு', 'குரு', jupData['sidereal']!, isRetrograde: jupData['isRetrograde'] == 1.0),
      'Venus': _createPlanetDetail('Venus', 'சுக்கிரன்', 'சுக்', venData['sidereal']!, isRetrograde: venData['isRetrograde'] == 1.0),
      'Saturn': _createPlanetDetail('Saturn', 'சனி', 'சனி', satData['sidereal']!, isRetrograde: satData['isRetrograde'] == 1.0),
      'Rahu': _createPlanetDetail('Rahu', 'ராகு', 'ரா', rahuSid, isRetrograde: true),
      'Ketu': _createPlanetDetail('Ketu', 'கேது', 'கே', ketuSid, isRetrograde: true),
      'Mandi': _createPlanetDetail('Mandi', 'மாந்தி', 'மாந்', mandiSid),
    };

    // Tithi Calculation
    final tithi = TithiCalculator.calculateTithi(sunLongitude: sunSid, moonLongitude: moonSid);

    // Karana Calculation
    final karana = calculateKarana(sunSid, moonSid);

    // Yoga Calculation
    final yoga = calculateYoga(sunSid, moonSid);

    // Tamil Date Calculation
    final tamilDate = calculateTamilDate(sunSid);

    // Birth Hora Calculation
    final birthHora = calculateHora(dateOfBirth, latitude: latitude, longitude: longitude, utcOffsetHours: utcOffsetHours);

    // Sunrise & Sunset Timings
    final sunTimes = calculateSunriseSunset(dateOfBirth, latitude, longitude, utcOffsetHours);
    final sunrise = sunTimes['sunrise']!;
    final sunset = sunTimes['sunset']!;

    // Udayathi Nazhigai Calculation
    final udayathiDuration = dateOfBirth.isAfter(sunrise) ? dateOfBirth.difference(sunrise) : sunrise.difference(dateOfBirth);
    final totalUdayathiSecs = udayathiDuration.inSeconds.abs();
    final udayathiNazhi = (totalUdayathiSecs / 1440).floor();
    final udayathiVinadi = ((totalUdayathiSecs % 1440) / 24).round();
    final udayathiNazhiStr = "$udayathiNazhi நாழிகை $udayathiVinadi வினாடி";

    // Nakshatra Nazhigai Calculation
    final double nakOffsetDeg = moonSid % (360.0 / 27.0);
    final double nakProgressRatio = nakOffsetDeg / (360.0 / 27.0);
    final int elapsedNazhi = (nakProgressRatio * 60).floor();
    final int elapsedVinadi = ((nakProgressRatio * 60 - elapsedNazhi) * 60).round();
    final nakNazhiStr = "$elapsedNazhi நாழிகை $elapsedVinadi வினாடி";

    return HoroscopeCalculationResult(
      dateOfBirth: dateOfBirth,
      latitude: latitude,
      longitude: longitude,
      utcOffsetHours: utcOffsetHours,
      julianDay: jd,
      ayanamsa: ayanamsa,
      planets: planetsMap,
      lagna: planetsMap['Lagna']!,
      moon: planetsMap['Moon']!,
      sun: planetsMap['Sun']!,
      tithi: tithi,
      karanaIndex: karana['index'] as int,
      karanaNameTa: karana['nameTa'] as String,
      karanaNameEn: karana['nameEn'] as String,
      yogaIndex: yoga['index'] as int,
      yogaNameTa: yoga['nameTa'] as String,
      yogaNameEn: yoga['nameEn'] as String,
      tamilMonthTa: tamilDate['month'] as String,
      tamilDay: tamilDate['day'] as int,
      tamilDateFormatted: tamilDate['formatted'] as String,
      birthHoraLordTa: birthHora['ta']!,
      birthHoraLordEn: birthHora['en']!,
      sunrise: sunrise,
      sunset: sunset,
      udayathiNazhiStr: udayathiNazhiStr,
      nakshatraNazhiStr: nakNazhiStr,
    );
  }

  /// Calculate Current Live Gocharam (Transit) Planetary Longitudes
  static Map<String, PlanetDetail> calculateTransits({DateTime? date}) {
    final now = date ?? DateTime.now();
    final data = calculateHoroscope(
      dateOfBirth: now,
      latitude: 13.0827,
      longitude: 80.2707,
      utcOffsetHours: 5.5,
    );
    final Map<String, PlanetDetail> planets = data.planets;

    return {
      'Jupiter': _createPlanetDetail('Jupiter', 'குரு', 'குரு', planets['Jupiter']!.longitude, isRetrograde: planets['Jupiter']!.isRetrograde),
      'Saturn': _createPlanetDetail('Saturn', 'சனி', 'சனி', planets['Saturn']!.longitude, isRetrograde: planets['Saturn']!.isRetrograde),
      'Rahu': _createPlanetDetail('Rahu', 'ராகு', 'ராகு', planets['Rahu']!.longitude, isRetrograde: true),
      'Ketu': _createPlanetDetail('Ketu', 'கேது', 'கேது', planets['Ketu']!.longitude, isRetrograde: true),
      'Mars': _createPlanetDetail('Mars', 'செவ்வாய்', 'செவ்', planets['Mars']!.longitude, isRetrograde: planets['Mars']!.isRetrograde),
      'Sun': _createPlanetDetail('Sun', 'சூரியன்', 'சூ', planets['Sun']!.longitude),
      'Moon': _createPlanetDetail('Moon', 'சந்திரன்', 'சந்', planets['Moon']!.longitude),
    };
  }

  /// Calculate Navamsha starting sign and sign index according to Classical Parashara:
  /// Movable / Chara (Mesham 0, Kadagam 3, Thulam 6, Magaram 9) -> Starts from the same sign
  /// Fixed / Sthira (Rishabam 1, Simmam 4, Viruchigam 7, Kumbam 10) -> Starts from the 9th sign ((rasiIndex + 8) % 12)
  /// Dual / Ubhaya (Mithunam 2, Kanni 5, Dhanusu 8, Meenam 11) -> Starts from the 5th sign ((rasiIndex + 4) % 12)
  static int calculateNavamsaStartIndex(int rasiIndex) {
    final rasiType = rasiIndex % 3; // 0: Movable (0,3,6,9), 1: Fixed (1,4,7,10), 2: Dual (2,5,8,11)
    if (rasiType == 0) {
      return rasiIndex;
    } else if (rasiType == 1) {
      return (rasiIndex + 8) % 12;
    } else {
      return (rasiIndex + 4) % 12;
    }
  }

  static int calculateNavamsaRasiIndex(int rasiIndex, int navamsaPart) {
    final startRasi = calculateNavamsaStartIndex(rasiIndex);
    return (startRasi + navamsaPart) % 12;
  }

  static PlanetDetail _createPlanetDetail(
    String name,
    String tamilName,
    String symbol,
    double longitude, {
    bool isRetrograde = false,
  }) {
    return PlanetDetail.fromSiderealLongitude(
      name: name,
      tamilName: tamilName,
      symbol: symbol,
      longitude: longitude,
      isRetrograde: isRetrograde,
    );
  }

  /// Public helper to compute Nakshatra, Pada, and Lord details from any Sidereal Longitude
  static Map<String, dynamic> calculateNakshatraPadaFromLongitude(double longitude) {
    final normLong = _normalizeDegrees(longitude);
    final int totalSecs = (normLong * arcsecondsPerDegree).round() % totalArcseconds;
    final int nakshatraIndex = (totalSecs ~/ arcsecondsPerNakshatra).clamp(0, 26);
    final int nakshatraRemainder = totalSecs % arcsecondsPerNakshatra;
    final int pada = ((nakshatraRemainder ~/ arcsecondsPerPada)).clamp(0, 3) + 1;

    final int starLordIndex = nakshatraIndex % 9;
    final String starLord = planetLords[starLordIndex];
    final String tamilStarLord = planetLordsTa[starLordIndex];

    final int subLordIndex = ((nakshatraRemainder * 9) ~/ arcsecondsPerNakshatra).clamp(0, 8);
    final String subLord = planetLords[subLordIndex];
    final String tamilSubLord = planetLordsTa[subLordIndex];

    return {
      'nakshatraIndex': nakshatraIndex,
      'nakshatraNameTa': nakshatrasTa[nakshatraIndex],
      'nakshatraNameEn': nakshatrasEn[nakshatraIndex],
      'pada': pada,
      'starLord': starLord,
      'tamilStarLord': tamilStarLord,
      'subLord': subLord,
      'tamilSubLord': tamilSubLord,
    };
  }

  /// Keplerian / 3D orbital calculation helper for planets
  static Map<String, double> _calculatePlanetDetails({
    required double t,
    required double earthX,
    required double earthY,
    required double sunTrop,
    required double ayanamsa,
    required double a,
    required double e0, required double eDot,
    required double i0, required double iDot,
    required double l0, required double lDot,
    required double w0, required double wDot,
    required double node0, required double nodeDot,
    double perturbationDeg = 0.0,
  }) {
    final e = e0 + eDot * t;
    final inc = _degToRad(i0 + iDot * t);
    final L = _normalizeDegrees(l0 + lDot * t + perturbationDeg);
    final peri = _normalizeDegrees(w0 + wDot * t);
    final node = _normalizeDegrees(node0 + nodeDot * t);

    final M = _normalizeDegrees(L - peri);
    final MRad = _degToRad(M);

    // True Anomaly
    final v = MRad + (2.0 * e - (pow(e, 3) / 4.0)) * sin(MRad) + (5.0 / 4.0) * pow(e, 2) * sin(2.0 * MRad);
    final r = a * (1.0 - pow(e, 2)) / (1.0 + e * cos(v));

    // Argument of Latitude
    final u = _degToRad(_normalizeDegrees(_radToDeg(v) + peri - node));
    final nodeRad = _degToRad(node);

    // Heliocentric 3D Ecliptic Coordinates
    final px = r * (cos(nodeRad) * cos(u) - sin(nodeRad) * sin(u) * cos(inc));
    final py = r * (sin(nodeRad) * cos(u) + cos(nodeRad) * sin(u) * cos(inc));

    // Geocentric Vector
    final dx = px - earthX;
    final dy = py - earthY;

    final geoTrop = _normalizeDegrees(_radToDeg(atan2(dy, dx)));
    final geoSid = _normalizeDegrees(geoTrop - ayanamsa);

    // Check retrograde status at t + dt (1 hour offset)
    const dt = 1.0 / (24.0 * 36525.0);
    final t2 = t + dt;
    final L2 = _normalizeDegrees(l0 + lDot * t2 + perturbationDeg);
    final M2 = _normalizeDegrees(L2 - peri);
    final M2Rad = _degToRad(M2);
    final v2 = M2Rad + (2.0 * e - (pow(e, 3) / 4.0)) * sin(M2Rad) + (5.0 / 4.0) * pow(e, 2) * sin(2.0 * M2Rad);
    final r2 = a * (1.0 - pow(e, 2)) / (1.0 + e * cos(v2));
    final u2 = _degToRad(_normalizeDegrees(_radToDeg(v2) + peri - node));
    final px2 = r2 * (cos(nodeRad) * cos(u2) - sin(nodeRad) * sin(u2) * cos(inc));
    final py2 = r2 * (sin(nodeRad) * cos(u2) + cos(nodeRad) * sin(u2) * cos(inc));

    final sunTrop2 = _normalizeDegrees(sunTrop + 0.041068); // ~1 hr sun movement
    final earthX2 = -earthX * cos(_degToRad(0.041068)) + earthY * sin(_degToRad(0.041068));
    final earthY2 = -earthX * sin(_degToRad(0.041068)) - earthY * cos(_degToRad(0.041068));

    final dx2 = px2 - earthX2;
    final dy2 = py2 - earthY2;
    final geoTrop2 = _normalizeDegrees(_radToDeg(atan2(dy2, dx2)));

    double diff = geoTrop2 - geoTrop;
    if (diff > 180.0) diff -= 360.0;
    if (diff < -180.0) diff += 360.0;

    final isRetrograde = diff < 0.0;

    return {
      'sidereal': geoSid,
      'isRetrograde': isRetrograde ? 1.0 : 0.0,
    };
  }

  static double _calculateMandiSidereal(
    DateTime dateOfBirth,
    double latitude,
    double longitude,
    double utcOffsetHours,
    double ayanamsa,
  ) {
    const dayMandiNazhi = {7: 26.0, 1: 22.0, 2: 18.0, 3: 14.0, 4: 10.0, 5: 6.0, 6: 2.0};
    const nightMandiNazhi = {7: 10.0, 1: 6.0, 2: 2.0, 3: 26.0, 4: 22.0, 5: 18.0, 6: 14.0};

    final sunTimes = calculateSunriseSunset(dateOfBirth, latitude, longitude, utcOffsetHours);
    final sunriseDt = sunTimes['sunrise']!;
    final sunsetDt = sunTimes['sunset']!;

    final isDay = dateOfBirth.isAfter(sunriseDt) && dateOfBirth.isBefore(sunsetDt);
    final weekday = dateOfBirth.weekday;

    final nazhiOffset = isDay ? (dayMandiNazhi[weekday] ?? 14.0) : (nightMandiNazhi[weekday] ?? 26.0);
    final hoursOffset = nazhiOffset * 0.4;

    final baseDt = isDay ? sunriseDt : sunsetDt;
    final mandiTime = baseDt.add(Duration(minutes: (hoursOffset * 60).round()));

    final mandiJd = _dateTimeToJulianDay(mandiTime, utcOffsetHours: utcOffsetHours);
    return _calculateAscendantSidereal(mandiJd, mandiTime, latitude, longitude, utcOffsetHours, ayanamsa);
  }

  /// Astronomical Ascendant (Lagna) calculation via Spherical Trigonometry
  static double _calculateAscendantSidereal(
    double jd,
    DateTime dt,
    double latitude,
    double longitude,
    double utcOffsetHours,
    double ayanamsa,
  ) {
    final t = (jd - 2451545.0) / 36525.0;

    // Greenwich Mean Sidereal Time (GMST in degrees)
    final gmst = _normalizeDegrees(280.46061837 + 360.98564736629 * (jd - 2451545.0) + 0.000387933 * t * t - (t * t * t) / 38710000.0);

    // Local Sidereal Time (RAMC in degrees)
    final ramc = _normalizeDegrees(gmst + longitude);

    // True Obliquity of the Ecliptic (in radians)
    final epsDeg = 23.4392911 - 0.0130042 * t - 0.00000016 * t * t;
    final epsRad = _degToRad(epsDeg);

    final thetaRad = _degToRad(ramc);
    final phiRad = _degToRad(latitude);

    // Standard Spherical Trigonometric formula for Tropical Ascendant
    final y = cos(thetaRad);
    final x = -sin(thetaRad) * cos(epsRad) - tan(phiRad) * sin(epsRad);

    final lagnaTrop = _normalizeDegrees(_radToDeg(atan2(y, x)));
    return _normalizeDegrees(lagnaTrop - ayanamsa);
  }

  /// Public degree normalizer ensuring 0.0 <= longitude < 360.0
  static double normalizeDegrees(double deg) {
    double result = deg % 360.0;
    if (result < 0) result += 360.0;
    return result;
  }

  static double _normalizeDegrees(double deg) => normalizeDegrees(deg);

  static double _degToRad(double deg) => deg * (pi / 180.0);
  static double _radToDeg(double rad) => rad * (180.0 / pi);
}

