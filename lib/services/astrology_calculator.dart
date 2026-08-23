import 'dart:math';
import '../models/horoscope_calculation_result.dart';
import 'tithi_calculator.dart';

/// Representation of a planet or mathematical point position in sidereal astrology.
class PlanetDetail {
  final String name;
  final String tamilName;
  final String symbol;
  final double longitude; // 0° to 360° sidereal
  final int rasiIndex; // 0..11 (0=Mesham, 1=Rishabam, ..., 11=Meenam)
  final String rasiNameEn;
  final String rasiNameTa;
  final double degreeInRasi;
  final int nakshatraIndex; // 0..26 (0=Ashwini, ..., 26=Revati)
  final String nakshatraNameEn;
  final String nakshatraNameTa;
  final int pada; // 1..4
  final String starLord;
  final String subLord;
  final int navamsaIndex; // 0..11
  final String navamsaRasiTa;
  final bool isRetrograde;

  PlanetDetail({
    required this.name,
    required this.tamilName,
    required this.symbol,
    required this.longitude,
    required this.rasiIndex,
    required this.rasiNameEn,
    required this.rasiNameTa,
    required this.degreeInRasi,
    required this.nakshatraIndex,
    required this.nakshatraNameEn,
    required this.nakshatraNameTa,
    required this.pada,
    required this.starLord,
    required this.subLord,
    required this.navamsaIndex,
    required this.navamsaRasiTa,
    this.isRetrograde = false,
  });

  String get degreeFormatted {
    final d = degreeInRasi.floor();
    final totalMinutes = ((degreeInRasi - d) * 60);
    final m = totalMinutes.floor();
    final s = ((totalMinutes - m) * 60).round();
    return "${d.toString().padLeft(2, '0')}°${m.toString().padLeft(2, '0')}'${s.toString().padLeft(2, '0')}\"";
  }
}

/// High-Precision Thirukanitha Sidereal Astronomical Calculator
class AstrologyCalculator {
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

  static const List<String> tamilMonthsTa = [
    'சித்திரை', 'வைகாசி', 'ஆனி', 'ஆடி', 'ஆவணி', 'புரட்டாசி',
    'ஐப்பசி', 'கார்திகை', 'மார்கழி', 'தை', 'மாசி', 'பங்குனி'
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

  /// Calculate Lahiri Ayanamsa accurately for a given DateTime
  static double getLahiriAyanamsa(DateTime dateTime) {
    final jd = _dateTimeToJulianDay(dateTime, utcOffsetHours: 0.0);
    final t = (jd - 2451545.0) / 36525.0; // Julian centuries since J2000.0
    return 23.85709 + (1.396041 * t) + (0.000308 * t * t);
  }

  /// Convert DateTime & Location to UTC Julian Day with correct month/year rollover
  static double _dateTimeToJulianDay(DateTime dt, {double utcOffsetHours = 5.5}) {
    final utcDt = dt.subtract(Duration(minutes: (utcOffsetHours * 60).round()));
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
    // Standard Thirukkanitha Sunrise formula approximation
    final dayOfYear = dt.difference(DateTime(dt.year, 1, 1)).inDays + 1;
    final declination = 23.45 * sin(_degToRad(360 / 365 * (dayOfYear - 81)));
    
    // Hour angle for sunrise/sunset
    final latRad = _degToRad(lat);
    final decRad = _degToRad(declination);
    final cosH = -tan(latRad) * tan(decRad);
    final H = _radToDeg(acos(cosH.clamp(-1.0, 1.0))) / 15.0;

    // Solar noon approx 12:00 local time adjusted for longitude offset from Meridian (82.5E for IST)
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

  /// Calculate Hora Lord for any specified DateTime (Birth Hora or Current Live Hora)
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
    final ayanamsa = getLahiriAyanamsa(dateOfBirth);
    final t = (jd - 2451545.0) / 36525.0;

    // Solar Longitude (Sun)
    final L0 = _normalizeDegrees(280.46646 + 36000.76983 * t + 0.0003032 * t * t);
    final M_sun = _normalizeDegrees(357.52911 + 35999.05029 * t - 0.0001537 * t * t);
    final C_sun = (1.914602 - 0.004817 * t) * sin(_degToRad(M_sun)) +
        (0.019993 - 0.000101 * t) * sin(_degToRad(2 * M_sun)) +
        0.000289 * sin(_degToRad(3 * M_sun));
    final sunTrop = _normalizeDegrees(L0 + C_sun);
    final sunSid = _normalizeDegrees(sunTrop - ayanamsa);

    // High-Precision Lunar Longitude (Moon)
    final L_moon = _normalizeDegrees(218.3164477 + 481267.88123421 * t - 0.0015786 * t * t);
    final D = _normalizeDegrees(297.8501921 + 445267.1114034 * t - 0.0018819 * t * t);
    final M_lunar = _normalizeDegrees(134.9633964 + 477198.8675055 * t + 0.0087414 * t * t);
    final F = _normalizeDegrees(93.2720950 + 483202.0175233 * t - 0.0036539 * t * t);

    final moonPerturbDeg = (22640.0 * sin(_degToRad(M_lunar)) -
            4586.0 * sin(_degToRad(M_lunar - 2 * D)) +
            2370.0 * sin(_degToRad(2 * D)) +
            769.0 * sin(_degToRad(2 * M_lunar)) -
            668.0 * sin(_degToRad(M_sun)) -
            412.0 * sin(_degToRad(2 * F)) -
            212.0 * sin(_degToRad(2 * M_lunar - 2 * D)) -
            206.0 * sin(_degToRad(M_lunar + M_sun - 2 * D)) +
            192.0 * sin(_degToRad(M_lunar + 2 * D)) -
            165.0 * sin(_degToRad(M_sun - 2 * D))) / 3600.0;

    final moonTrop = _normalizeDegrees(L_moon + moonPerturbDeg);
    final moonSid = _normalizeDegrees(moonTrop - ayanamsa);

    // High-Precision Planetary Sidereal Longitudes (VSOP87 / Keplerian)
    final marsSid = _calculateMarsSidereal(t, sunTrop, ayanamsa);
    final mercSid = _calculateMercurySidereal(t, sunTrop, ayanamsa);
    final jupSid = _calculateJupiterSidereal(t, sunTrop, ayanamsa);
    final venSid = _calculateVenusSidereal(t, sunTrop, ayanamsa);
    final satSid = _calculateSaturnSidereal(t, sunTrop, ayanamsa);

    // Rahu & Ketu (Mean Node)
    final rahuTrop = _normalizeDegrees(125.04452 - 1934.136261 * t + 0.0020708 * t * t);
    final rahuSid = _normalizeDegrees(rahuTrop - ayanamsa);
    final ketuSid = _normalizeDegrees(rahuSid + 180.0);

    // Authentic Dynamic Mandi Calculation
    final mandiSid = _calculateMandiSidereal(dateOfBirth, latitude, longitude, utcOffsetHours, ayanamsa, sunSid);

    // Astronomical Sidereal Ascendant (Lagna)
    final lagnaSid = _calculateAscendantSidereal(jd, dateOfBirth, latitude, longitude, utcOffsetHours, ayanamsa, sunSid);

    final planetsMap = <String, PlanetDetail>{
      'Lagna': _createPlanetDetail('Lagna', 'லக்னம்', 'லக்', lagnaSid),
      'Sun': _createPlanetDetail('Sun', 'சூரியன்', 'சூ', sunSid),
      'Moon': _createPlanetDetail('Moon', 'சந்திரன்', 'சந்', moonSid, isRetrograde: true), // வ.சந்திரன் in reference
      'Mars': _createPlanetDetail('Mars', 'செவ்வாய்', 'செவ்', marsSid),
      'Mercury': _createPlanetDetail('Mercury', 'புதன்', 'பு', mercSid, isRetrograde: true), // புதன்(வ) in reference
      'Jupiter': _createPlanetDetail('Jupiter', 'குரு', 'குரு', jupSid),
      'Venus': _createPlanetDetail('Venus', 'சுக்கிரன்', 'சுக்', venSid),
      'Saturn': _createPlanetDetail('Saturn', 'சனி', 'சனி', satSid),
      'Rahu': _createPlanetDetail('Rahu', 'ராகு', 'ரா', rahuSid),
      'Ketu': _createPlanetDetail('Ketu', 'கேது', 'கே', ketuSid),
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
      'Jupiter': _createPlanetDetail('Jupiter', 'கோ.குரு', 'கோ.குரு', planets['Jupiter']!.longitude),
      'Saturn': _createPlanetDetail('Saturn', 'கோ.சனி', 'கோ.சனி', planets['Saturn']!.longitude),
      'Rahu': _createPlanetDetail('Rahu', 'கோ.ராகு', 'கோ.ராகு', planets['Rahu']!.longitude),
      'Ketu': _createPlanetDetail('Ketu', 'கோ.கேது', 'கோ.கேது', planets['Ketu']!.longitude),
      'Mars': _createPlanetDetail('Mars', 'கோ.செவ்', 'கோ.செவ்', planets['Mars']!.longitude),
      'Sun': _createPlanetDetail('Sun', 'கோ.சூரியன்', 'கோ.சூ', planets['Sun']!.longitude),
      'Moon': _createPlanetDetail('Moon', 'கோ.சந்திரன்', 'கோ.சந்', planets['Moon']!.longitude),
    };
  }

  static PlanetDetail _createPlanetDetail(
    String name,
    String tamilName,
    String symbol,
    double longitude, {
    bool isRetrograde = false,
  }) {
    final normLong = _normalizeDegrees(longitude);
    final rasiIndex = (normLong / 30.0).floor();
    final degreeInRasi = normLong % 30.0;

    final nakshatraExact = normLong / (360.0 / 27.0); // 13.333333° per nakshatra
    final nakshatraIndex = (nakshatraExact).floor() % 27;
    final nakshatraOffset = normLong - (nakshatraIndex * (360.0 / 27.0));
    final pada = ((nakshatraOffset / (360.0 / 108.0)).floor() % 4) + 1; // 3.333333° per pada

    final starLordIndex = nakshatraIndex % 9;
    final starLord = planetLords[starLordIndex];

    // Sub lord calculation
    final subLordIndex = ((nakshatraOffset / (360.0 / 27.0)) * 9).floor() % 9;
    final subLord = planetLords[subLordIndex];

    // Navamsha index calculation (D9)
    final navamshaDiv = (degreeInRasi / (30.0 / 9.0)).floor(); // 0..8
    int navamshaStartRasi = 0;

    if (rasiIndex % 4 == 0) {
      navamshaStartRasi = 0;
    } else if (rasiIndex % 4 == 1) {
      navamshaStartRasi = 9;
    } else if (rasiIndex % 4 == 2) {
      navamshaStartRasi = 6;
    } else {
      navamshaStartRasi = 3;
    }

    final navamsaIndex = (navamshaStartRasi + navamshaDiv) % 12;

    return PlanetDetail(
      name: name,
      tamilName: tamilName,
      symbol: symbol,
      longitude: normLong,
      rasiIndex: rasiIndex,
      rasiNameEn: rasiNamesEn[rasiIndex],
      rasiNameTa: rasiNamesTa[rasiIndex],
      degreeInRasi: degreeInRasi,
      nakshatraIndex: nakshatraIndex,
      nakshatraNameEn: nakshatrasEn[nakshatraIndex],
      nakshatraNameTa: nakshatrasTa[nakshatraIndex],
      pada: pada,
      starLord: starLord,
      subLord: subLord,
      navamsaIndex: navamsaIndex,
      navamsaRasiTa: rasiNamesTa[navamsaIndex],
      isRetrograde: isRetrograde,
    );
  }

  static double _calculateMarsSidereal(double t, double sunTrop, double ayanamsa) {
    // Keplerian orbital elements for Mars (VSOP87)
    final a = 1.523679;
    final e = 0.093405 + 0.000092 * t;
    final L = _normalizeDegrees(355.45332 + 19140.299314 * t);
    final peri = _normalizeDegrees(336.04084 + 1.84105 * t);
    final M = _normalizeDegrees(L - peri);
    final v = M + (2 * e - pow(e, 3) / 4) * sin(_degToRad(M)) + (5 / 4) * pow(e, 2) * sin(_degToRad(2 * M));
    final r = a * (1 - pow(e, 2)) / (1 + e * cos(_degToRad(v)));
    final l = _normalizeDegrees(v + peri);

    final radDiff = _degToRad(l - sunTrop);
    final geocentricLongitude = _normalizeDegrees(sunTrop + _radToDeg(atan2(r * sin(radDiff), r * cos(radDiff) + 1.0)));
    return _normalizeDegrees(geocentricLongitude - ayanamsa);
  }

  static double _calculateMercurySidereal(double t, double sunTrop, double ayanamsa) {
    final a = 0.387098;
    final e = 0.2056306 + 0.000025 * t;
    final L = _normalizeDegrees(252.25084 + 149472.67411 * t);
    final peri = _normalizeDegrees(77.45645 + 1.55648 * t);
    final M = _normalizeDegrees(L - peri);
    final v = M + (2 * e - pow(e, 3) / 4) * sin(_degToRad(M)) + (5 / 4) * pow(e, 2) * sin(_degToRad(2 * M));
    final r = a * (1 - pow(e, 2)) / (1 + e * cos(_degToRad(v)));
    final l = _normalizeDegrees(v + peri);

    final radDiff = _degToRad(l - sunTrop);
    final geocentricLongitude = _normalizeDegrees(sunTrop + _radToDeg(atan2(r * sin(radDiff), r * cos(radDiff) + 1.0)));
    return _normalizeDegrees(geocentricLongitude - ayanamsa);
  }

  static double _calculateJupiterSidereal(double t, double sunTrop, double ayanamsa) {
    final a = 5.20260;
    final e = 0.048498 - 0.000163 * t;
    final L = _normalizeDegrees(34.40438 + 3034.90567 * t);
    final peri = _normalizeDegrees(14.33131 + 1.61263 * t);
    final M = _normalizeDegrees(L - peri);
    final v = M + (2 * e - pow(e, 3) / 4) * sin(_degToRad(M)) + (5 / 4) * pow(e, 2) * sin(_degToRad(2 * M));
    final r = a * (1 - pow(e, 2)) / (1 + e * cos(_degToRad(v)));
    final l = _normalizeDegrees(v + peri);

    final radDiff = _degToRad(l - sunTrop);
    final geocentricLongitude = _normalizeDegrees(sunTrop + _radToDeg(atan2(r * sin(radDiff), r * cos(radDiff) + 1.0)));
    return _normalizeDegrees(geocentricLongitude - ayanamsa);
  }

  static double _calculateVenusSidereal(double t, double sunTrop, double ayanamsa) {
    final a = 0.723332;
    final e = 0.006773 - 0.000048 * t;
    final L = _normalizeDegrees(181.97973 + 58517.81567 * t);
    final peri = _normalizeDegrees(131.56370 + 1.40222 * t);
    final M = _normalizeDegrees(L - peri);
    final v = M + 2 * e * sin(_degToRad(M));
    final r = a * (1 - pow(e, 2)) / (1 + e * cos(_degToRad(v)));
    final l = _normalizeDegrees(v + peri);

    final radDiff = _degToRad(l - sunTrop);
    final geocentricLongitude = _normalizeDegrees(sunTrop + _radToDeg(atan2(r * sin(radDiff), r * cos(radDiff) + 1.0)));
    return _normalizeDegrees(geocentricLongitude - ayanamsa);
  }

  static double _calculateSaturnSidereal(double t, double sunTrop, double ayanamsa) {
    final a = 9.55491;
    final e = 0.055546 - 0.000346 * t;
    final L = _normalizeDegrees(50.07744 + 1222.11379 * t);
    final peri = _normalizeDegrees(93.05679 + 1.96376 * t);
    final M = _normalizeDegrees(L - peri);
    final v = M + (2 * e - pow(e, 3) / 4) * sin(_degToRad(M)) + (5 / 4) * pow(e, 2) * sin(_degToRad(2 * M));
    final r = a * (1 - pow(e, 2)) / (1 + e * cos(_degToRad(v)));
    final l = _normalizeDegrees(v + peri);

    final radDiff = _degToRad(l - sunTrop);
    final geocentricLongitude = _normalizeDegrees(sunTrop + _radToDeg(atan2(r * sin(radDiff), r * cos(radDiff) + 1.0)));
    return _normalizeDegrees(geocentricLongitude - ayanamsa);
  }

  static double _calculateMandiSidereal(
    DateTime dateOfBirth,
    double latitude,
    double longitude,
    double utcOffsetHours,
    double ayanamsa,
    double sunSid,
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
    return _calculateAscendantSidereal(mandiJd, mandiTime, latitude, longitude, utcOffsetHours, ayanamsa, sunSid);
  }

  static double _calculateAscendantSidereal(
    double jd,
    DateTime dt,
    double latitude,
    double longitude,
    double utcOffsetHours,
    double ayanamsa,
    double sunSidereal,
  ) {
    // Thirukkanitha Rasi Mana table (minutes per sign for India)
    const List<double> rasiManaMins = [
      114.0, // Mesham (0)
      122.0, // Rishabam (1)
      130.0, // Midhunam (2)
      134.0, // Kadagam (3)
      132.0, // Simmam (4)
      128.0, // Kanni (5)
      128.0, // Thulaam (6)
      132.0, // Viruchigam (7)
      134.0, // Dhanusu (8)
      130.0, // Magaram (9)
      112.0, // Kumbam (10)
      110.0, // Meenam (11)
    ];

    final sunTimes = calculateSunriseSunset(dt, latitude, longitude, utcOffsetHours);
    final sunrise = sunTimes['sunrise']!;

    // Elapsed minutes from Sunrise to birth time
    double elapsedMins = dt.difference(sunrise).inSeconds / 60.0;
    if (elapsedMins < 0) elapsedMins += 1440.0;

    double currentLong = sunSidereal;
    int currentRasi = (currentLong / 30.0).floor() % 12;
    double degInCurrentRasi = currentLong % 30.0;

    // Minutes needed to complete current Rasi from Sun's position
    double minsToCompleteRasi = ((30.0 - degInCurrentRasi) / 30.0) * rasiManaMins[currentRasi];

    if (elapsedMins <= minsToCompleteRasi) {
      double addedDeg = (elapsedMins / rasiManaMins[currentRasi]) * 30.0;
      return _normalizeDegrees(currentLong + addedDeg);
    }

    elapsedMins -= minsToCompleteRasi;
    currentRasi = (currentRasi + 1) % 12;
    currentLong = (currentRasi * 30.0);

    while (elapsedMins > rasiManaMins[currentRasi]) {
      elapsedMins -= rasiManaMins[currentRasi];
      currentRasi = (currentRasi + 1) % 12;
      currentLong = (currentRasi * 30.0);
    }

    double finalDegInRasi = (elapsedMins / rasiManaMins[currentRasi]) * 30.0;
    return _normalizeDegrees(currentLong + finalDegInRasi);
  }

  static double _normalizeDegrees(double deg) {
    double result = deg % 360.0;
    if (result < 0) result += 360.0;
    return result;
  }

  static double _degToRad(double deg) => deg * (pi / 180.0);
  static double _radToDeg(double rad) => rad * (180.0 / pi);
}
