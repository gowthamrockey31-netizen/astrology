import 'package:intl/intl.dart';
import '../../services/astrology_calculator.dart';
import '../../services/panchanga_provider.dart';
import '../../services/swiss_ephemeris_calculator.dart';
import '../../services/tithi_calculator.dart';
import 'professional_muhurtha_models.dart';

/// Authoritative Subha Muhurtham Calculation Engine
/// Consumes the existing Swiss Ephemeris and Panchanga engines
/// Evaluates classical 5 Angas, Tara/Chandra/Guru/Surya Bala, Lagna Shuddhi,
/// Panchaka Dosha, Visha Kadigai, Month Sunyam, Agni Nakshatra, and Abhijit Muhurtham.
class ProfessionalMuhurthaEngine {
  static const List<String> rasiNamesTa = [
    'மேஷம்', 'ரிஷபம்', 'மிதுனம்', 'கடகம்',
    'சிம்மம்', 'கன்னி', 'துலாம்', 'விருச்சிகம்',
    'தனுசு', 'மகரம்', 'கும்பம்', 'மீனம்'
  ];

  static const List<String> rasiNamesEn = [
    'Aries', 'Taurus', 'Gemini', 'Cancer',
    'Leo', 'Virgo', 'Libra', 'Scorpio',
    'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces'
  ];

  static const List<String> weekdaysTa = [
    'திங்கள்', 'செவ்வாய்', 'புதன்', 'வியாழன்', 'வெள்ளி', 'சனி', 'ஞாயிறு'
  ];

  static const List<String> nakshatrasTa = [
    'அஸ்வினி', 'பரணி', 'கார்த்திகை', 'ரோகிணி', 'மிருகசீரிஷம்',
    'திருவாதிரை', 'புனர்பூசம்', 'பூசம்', 'ஆயில்யம்', 'மகம்',
    'பூரம்', 'உத்திரம்', 'ஹஸ்தம்', 'சித்திரை', 'சுவாதி',
    'விசாகம்', 'அனுஷம்', 'கேட்டை', 'மூலம்', 'பூராடம்',
    'உத்திராடம்', 'திருவோணம்', 'அவிட்டம்', 'சதயம்', 'பூரட்டாதி',
    'உத்திரட்டாதி', 'ரேவதி'
  ];

  static const List<String> tamilMonths = [
    'சித்திரை', 'வைகாசி', 'ஆனி', 'ஆடி', 'ஆவணி', 'புரட்டாசி',
    'ஐப்பசி', 'கார்த்திகை', 'மார்கழி', 'தை', 'மாசி', 'பங்குனி'
  ];

  /// The 16 classical Muhurtha suitable Nakshatras (0-indexed)
  /// Ashwini (0), Rohini (3), Mrigashirsha (4), Punarvasu (6), Pushya (7),
  /// Uttara Phalguni (11), Hasta (12), Chitra (13), Swati (14), Anuradha (16),
  /// Uttara Ashadha (20), Shravana (21), Dhanishta (22), Shatabhisha (23),
  /// Uttara Bhadrapada (25), Revati (26).
  static const Set<int> suitableNakshatras = {
    0, 3, 4, 6, 7, 11, 12, 13, 14, 16, 20, 21, 22, 23, 25, 26
  };

  /// Month Sunya Rasis (Masa Sunyam) in classical Tamil astrology (1..12 index)
  static const Map<int, List<int>> monthSunyaRasiMap = {
    0: [9],        // Chithirai: Makaram (9)
    1: [8, 11],    // Vaikasi: Dhanusu (8), Meenam (11)
    2: [0, 10],    // Aani: Mesham (0), Kumbam (10)
    3: [9],        // Aadi: Makaram (9)
    4: [8, 5],     // Avani: Dhanusu (8), Kanni (5)
    5: [0, 10],    // Purattasi: Mesham (0), Kumbam (10)
    6: [3],        // Aippasi: Kadagam (3)
    7: [7, 2],     // Karthigai: Viruchigam (7), Mithunam (2)
    8: [4],        // Margazhi: Simmam (4)
    9: [6, 10],    // Thai: Thulam (6), Kumbam (10)
    10: [9, 1],    // Masi: Makaram (9), Rishabam (1)
    11: [8, 5],    // Panguni: Dhanusu (8), Kanni (5)
  };

  /// Traditional 27 Nakshatras Visha Nazhigai start points (out of 60 Nazhigais, span = 4 Nazhigais)
  static const List<int> vishaNazhigaiStart = [
    50, // 0: Ashwini
    24, // 1: Bharani
    30, // 2: Krittika
    40, // 3: Rohini
    14, // 4: Mrigashirsha
    21, // 5: Ardra
    30, // 6: Punarvasu
    20, // 7: Pushya
    32, // 8: Ashlesha
    30, // 9: Magha
    20, // 10: Purva Phalguni
    18, // 11: Uttara Phalguni
    21, // 12: Hasta
    20, // 13: Chitra
    14, // 14: Swati
    14, // 15: Vishakha
    10, // 16: Anuradha
    14, // 17: Jyeshtha
    56, // 18: Mula
    24, // 19: Purva Ashadha
    20, // 20: Uttara Ashadha
    10, // 21: Shravana
    10, // 22: Dhanishta
    18, // 23: Shatabhisha
    16, // 24: Purva Bhadrapada
    24, // 25: Uttara Bhadrapada
    30, // 26: Revati
  ];

  /// 8-part solar division for Rahu Kalam, Yamagandam, Gulikai (1=Mon..7=Sun)
  static const Map<int, int> rahuParts = {1: 1, 2: 6, 3: 4, 4: 5, 5: 3, 6: 2, 7: 7};
  static const Map<int, int> yamaParts = {1: 4, 2: 3, 3: 2, 4: 1, 5: 0, 6: 6, 7: 5};
  static const Map<int, int> gulikaiParts = {1: 5, 2: 4, 3: 3, 4: 2, 5: 1, 6: 0, 7: 6};

  /// Main calculation method for Subha Muhurtham
  MuhurthaResult calculate({
    required DateTime date,
    required GeoLocation location,
    required MuhurthaCategory category,
    BirthProfile? birthProfile,
  }) {
    final cleanDate = DateTime(date.year, date.month, date.day, 12, 0);

    // 1. Julian Day & Ayanamsa
    final jd = SwissEphemerisCalculator.getJulianDay(cleanDate, utcOffsetHours: location.timeZone);
    final ayanamsa = SwissEphemerisCalculator.calculateLahiriAyanamsa(jd);

    // 2. Accurate Planetary Positions
    final planets = SwissEphemerisCalculator.calculatePlanetaryPositions(
      jd: jd,
      ayanamsa: ayanamsa,
    );
    final sunLong = planets['Sun']!.longitude;
    final moonLong = planets['Moon']!.longitude;
    final jupiterLong = planets['Jupiter']!.longitude;

    // 3. Exact Sunrise & Sunset
    final sunTimes = AstrologyCalculator.calculateSunriseSunset(
      cleanDate,
      location.latitude,
      location.longitude,
      location.timeZone,
    );
    final sunrise = sunTimes['sunrise']!;
    final sunset = sunTimes['sunset']!;
    final solarNoon = sunrise.add(Duration(milliseconds: (sunset.difference(sunrise).inMilliseconds / 2).round()));

    // 4. Tamil Date
    final sunRasiIdx = (sunLong / 30.0).floor() % 12;
    final tamilMonthIdx = sunRasiIdx;
    final tamilMonth = tamilMonths[tamilMonthIdx];
    final tamilDay = (sunLong % 30.0).floor() + 1;
    final int tamilYearCycle = ((cleanDate.year - 1987) % 60 + 60) % 60;
    final String tamilYearName = AstronomicalPanchangaProvider.tamilYearsTa[tamilYearCycle];

    // Month Preferences
    // Generally avoided for major Subha Karyas: Aadi (3), Margazhi (8), Purattasi (5), Masi (10)
    final bool isMonthAvoided = (tamilMonthIdx == 3 || tamilMonthIdx == 5 || tamilMonthIdx == 8 || tamilMonthIdx == 10);
    final bool isMonthPreferred = !isMonthAvoided;
    final String monthRestrictionReason = isMonthAvoided
        ? '$tamilMonth மாதம் முக்கிய சுப காரியங்களுக்கு தவிர்க்கப்பட வேண்டிய மாதம் (Avoided Month)'
        : '$tamilMonth மாதம் சுப காரியங்களுக்கு உகந்த மாதம் (Preferred Month)';

    // Month Sunyam Rasis
    final sunyaRasiIndices = monthSunyaRasiMap[tamilMonthIdx] ?? [];
    final List<String> monthSunyamRasis = sunyaRasiIndices.map((idx) => rasiNamesTa[idx]).toList();

    // Agni Nakshatra (Kathiri): Sun in Krittika (26.6667° to 40.0° longitude)
    final bool isKathiriAgniActive = (sunLong >= 26.6667 && sunLong < 40.0);
    final String kathiriReason = isKathiriAgniActive
        ? 'அக்னி நட்சத்திரம் (கத்திரி வெயில்) காலம் - பூமி பூஜை, வீடு கட்ட ஆரம்பிக்க தவிர்க்கவும்'
        : 'அக்னி நட்சத்திர பாதிப்பு இல்லை';

    // 5. Five Angas
    final angas = evaluateFiveAngas(
      date: cleanDate,
      sunLong: sunLong,
      moonLong: moonLong,
      category: category,
    );

    // 6. Inauspicious Periods Calculation
    final inauspiciousPeriods = calculateInauspiciousPeriods(
      sunrise: sunrise,
      sunset: sunset,
      weekday: cleanDate.weekday,
      moonLong: moonLong,
    );

    // 7. Abhijit Muhurtham (8th of 15 daytime muhurthas)
    final dayMins = sunset.difference(sunrise).inMinutes;
    final double muhurthaLenMins = dayMins > 0 ? dayMins / 15.0 : 48.0;
    final DateTime abhijitStart = sunrise.add(Duration(minutes: (7 * muhurthaLenMins).round()));
    final DateTime abhijitEnd = abhijitStart.add(Duration(minutes: muhurthaLenMins.round()));
    final abhijitWindow = SubhaTimeWindow(
      start: abhijitStart,
      end: abhijitEnd,
      timingFormatted: '${DateFormat('hh:mm a').format(abhijitStart)} - ${DateFormat('hh:mm a').format(abhijitEnd)}',
      durationFormatted: '${muhurthaLenMins.round()} நிமிடங்கள்',
      lagnaName: rasiNamesTa[(sunRasiIdx + 3) % 12],
      panchakaName: 'அபிஜித் பலம்',
      suitabilityScore: 85.0,
      reasons: const ['மத்தியான அபிஜித் முகூர்த்தம் - அனைத்து தோஷங்களையும் போக்கும் உத்தம நேரம்'],
    );

    // 8. Personal Balas (if Birth Profile is provided)
    TaraBalaResult? taraBala;
    ChandraBalaResult? chandraBala;
    GuruBalaResult? guruBala;
    SuryaBalaResult? suryaBala;

    if (birthProfile != null) {
      taraBala = evaluateTaraBala(
        birthNakshatra: birthProfile.birthNakshatra,
        targetNakshatra: angas.nakshatraIndex,
      );

      chandraBala = evaluateChandraBala(
        birthRasi: birthProfile.birthRasi,
        moonLong: moonLong,
      );

      guruBala = evaluateGuruBala(
        birthRasi: birthProfile.birthRasi,
        jupiterLong: jupiterLong,
      );

      suryaBala = evaluateSuryaBala(
        birthRasi: birthProfile.birthRasi,
        sunLong: sunLong,
      );
    }

    // 9. Date-Wise Calculation: Continuous Valid Time Windows
    final validWindows = calculateValidTimeWindows(
      cleanDate: cleanDate,
      sunrise: sunrise,
      sunset: sunset,
      location: location,
      ayanamsa: ayanamsa,
      planets: planets,
      angas: angas,
      category: category,
      birthProfile: birthProfile,
      inauspiciousPeriods: inauspiciousPeriods,
      sunyaRasiIndices: sunyaRasiIndices,
      isKathiriAgniActive: isKathiriAgniActive,
    );

    // Summary Verdict
    String summaryVerdict;
    if (chandraBala != null && chandraBala.isChandrashtama) {
      summaryVerdict = 'சந்திராஷ்டம நாள் - இந்த நாளில் சுப முகூர்த்தம் அமைப்பது முற்றிலும் தவிர்க்கப்பட வேண்டும்.';
    } else if (validWindows.isNotEmpty) {
      summaryVerdict = 'இந்த நாளில் ${validWindows.length} சுப முகூர்த்த நேர இடைவெளிகள் வெற்றிகரமாக கணக்கிடப்பட்டுள்ளன.';
    } else {
      summaryVerdict = 'இந்த நாளில் பொதுவான முகூர்த்த விதிமுறைகளின்படி உகந்த நேர இடைவெளிகள் அமையவில்லை. விதிவிலக்காக அபிஜித் முகூர்த்தத்தை பரிசீலிக்கலாம்.';
    }

    return MuhurthaResult(
      date: cleanDate,
      location: location,
      category: category,
      birthProfile: birthProfile,
      tamilMonth: tamilMonth,
      tamilDay: tamilDay,
      tamilYearName: tamilYearName,
      isMonthPreferred: isMonthPreferred,
      monthRestrictionReason: monthRestrictionReason,
      monthSunyamRasis: monthSunyamRasis,
      isKathiriAgniActive: isKathiriAgniActive,
      kathiriReason: kathiriReason,
      sunrise: sunrise,
      sunset: sunset,
      solarNoon: solarNoon,
      angas: angas,
      taraBala: taraBala,
      chandraBala: chandraBala,
      guruBala: guruBala,
      suryaBala: suryaBala,
      abhijitMuhurtham: abhijitWindow,
      inauspiciousPeriods: inauspiciousPeriods,
      validWindows: validWindows,
      summaryVerdict: summaryVerdict,
    );
  }

  /// Evaluates the 5 Panchanga Angas
  PanchangaAngasResult evaluateFiveAngas({
    required DateTime date,
    required double sunLong,
    required double moonLong,
    required MuhurthaCategory category,
  }) {
    // 1. Tithi
    final tithiDetail = TithiCalculator.calculateTithi(
      sunLongitude: sunLong,
      moonLongitude: moonLong,
    );
    final tNum = tithiDetail.tithiNumber;
    final int singleTNum = (tNum > 15) ? (tNum - 15) : tNum;

    // Preferred Tithis: Dvitiya (2), Tritiya (3), Panchami (5), Saptami (7),
    // Dashami (10), Ekadashi (11), Dwadashi (12), Trayodashi (13)
    final bool isPreferredTithi = (singleTNum == 2 || singleTNum == 3 || singleTNum == 5 ||
        singleTNum == 7 || singleTNum == 10 || singleTNum == 11 || singleTNum == 12 || singleTNum == 13);

    // Avoided: Amavasya (30), Purnima (15), Ashtami (8), Navami (9), Chaturdashi (14)
    final bool isAvoidedTithi = (tNum == 15 || tNum == 30 || singleTNum == 8 || singleTNum == 9 || singleTNum == 14);

    String tReason;
    if (isPreferredTithi) {
      tReason = '${tithiDetail.tithiNameTa} சுப காரியங்களுக்கு உகந்த சிறந்த திதியாகும் (Preferred Tithi)';
    } else if (isAvoidedTithi) {
      tReason = '${tithiDetail.tithiNameTa} சுப காரியங்களுக்கு தவிர்க்கப்பட வேண்டிய திதி (Avoided Tithi)';
    } else {
      tReason = '${tithiDetail.tithiNameTa} மத்திமமான திதியாகும்';
    }

    // 2. Weekday (Vara)
    final int weekdayNum = date.weekday; // 1=Mon..7=Sun
    final String weekdayName = weekdaysTa[weekdayNum - 1];

    // Preferred: Monday, Wednesday, Thursday, Friday
    final bool isPreferredVara = (weekdayNum == 1 || weekdayNum == 3 || weekdayNum == 4 || weekdayNum == 5);
    final bool isAvoidedVara = (weekdayNum == 2 || weekdayNum == 6); // Tuesday, Saturday

    String vReason;
    if (isPreferredVara) {
      vReason = '$weekdayName கிழமை சுப காரியங்களுக்கு உகந்த மங்களகரமான நாள்';
    } else if (isAvoidedVara) {
      vReason = '$weekdayName கிழமை சுப முகூர்த்தங்களுக்கு பொதுவாக விலக்கப்பட வேண்டும்';
    } else {
      // Sunday
      if (category == MuhurthaCategory.marriage) {
        vReason = 'ஞாயிற்றுக்கிழமை திருமண சுப காரியங்களுக்கு பொதுவாக தவிர்க்கப்படும்';
      } else {
        vReason = 'ஞாயிற்றுக்கிழமை சூரிய பலம் கொண்ட காரியங்களுக்கு மத்திம பலன் தரும்';
      }
    }

    // 3. Nakshatra
    const nakSpan = 360.0 / 27.0;
    final int nakIdx = (moonLong % 360.0 / nakSpan).floor() % 27;
    final String nakName = nakshatrasTa[nakIdx];
    final bool isNakSuitable = suitableNakshatras.contains(nakIdx);
    final String nakReason = isNakSuitable
        ? '$nakName சுப முகூர்த்தத்திற்கு பரிந்துரைக்கப்பட்ட 16 உத்தம நட்சத்திரங்களில் ஒன்றாகும்'
        : '$nakName சுப முகூர்த்தத்திற்கு பரிந்துரைக்கப்படாத நட்சத்திரம் (விலக்கப்பட வேண்டும்)';

    // 4. Yoga (Amirthathi Yoga)
    final int rem = (weekdayNum + nakIdx) % 3;
    String amirthathiYoga;
    bool isYogaAuspicious;
    String yogaReason;
    if (rem == 0) {
      amirthathiYoga = 'அமிர்த யோகம்';
      isYogaAuspicious = true;
      yogaReason = 'அமிர்த யோகம் - சகல சுப காரியங்களுக்கும் மிக உன்னதமானது';
    } else if (rem == 1) {
      amirthathiYoga = 'சித்த யோகம்';
      isYogaAuspicious = true;
      yogaReason = 'சித்த யோகம் - காரிய வெற்றி தரக்கூடிய உகந்த யோகம்';
    } else {
      amirthathiYoga = 'மரண யோகம்';
      isYogaAuspicious = false;
      yogaReason = 'மரண யோகம் - சுப காரியங்களை முற்றிலும் தவிர்க்கவும்';
    }

    final yogaData = AstrologyCalculator.calculateYoga(sunLong, moonLong);
    final String yogaName = yogaData['nameTa'] as String;

    // 5. Karana
    final karanaData = AstrologyCalculator.calculateKarana(sunLong, moonLong);
    final String karanaName = karanaData['nameTa'] as String;
    final bool isVishti = (karanaData['nameEn'] == 'Vishti' || karanaName.contains('பத்திரை'));
    final bool isKaranaAuspicious = !isVishti;
    final String karanaReason = isVishti
        ? 'விஷ்டி / பத்திரை கரணம் - சுப காரியங்களை தவிர்க்க வேண்டும்'
        : '$karanaName சுப காரியங்களுக்கு உகந்த கரணம்';

    return PanchangaAngasResult(
      tithiName: tithiDetail.tithiNameTa,
      tithiNumber: tNum,
      paksha: tithiDetail.pakshaTa,
      isTithiPreferred: isPreferredTithi,
      tithiReason: tReason,
      weekdayName: weekdayName,
      weekdayNumber: weekdayNum,
      isVaraPreferred: isPreferredVara,
      varaReason: vReason,
      nakshatraName: nakName,
      nakshatraIndex: nakIdx,
      isNakshatraSuitable: isNakSuitable,
      nakshatraReason: nakReason,
      yogaName: yogaName,
      amirthathiYoga: amirthathiYoga,
      isYogaAuspicious: isYogaAuspicious,
      yogaReason: yogaReason,
      karanaName: karanaName,
      isKaranaAuspicious: isKaranaAuspicious,
      karanaReason: karanaReason,
    );
  }

  /// Tara Bala evaluation (1..9 cyclical)
  TaraBalaResult evaluateTaraBala({
    required int birthNakshatra,
    required int targetNakshatra,
  }) {
    final distance = (((targetNakshatra - birthNakshatra) % 27 + 27) % 27) + 1;
    final tara = ((distance - 1) % 9) + 1;

    const names = [
      'ஜன்ம தாரை', 'சம்பத் தாரை', 'விபத் தாரை',
      'க்ஷேம தாரை', 'ப்ரத்யக் தாரை', 'சாதக தாரை',
      'வத / நைதன தாரை', 'மித்ர தாரை', 'பரம மித்ர தாரை'
    ];
    final taraName = names[tara - 1];

    final bool isAccepted = (tara == 2 || tara == 4 || tara == 6 || tara == 8 || tara == 9);
    String status;
    String reason;

    if (isAccepted) {
      status = 'உத்தமம் (Accepted)';
      switch (tara) {
        case 2: reason = 'சம்பத் தாரை - தன தான்ய சம்பத்து மற்றும் மங்களம் தரும்'; break;
        case 4: reason = 'க்ஷேம தாரை - பாதுகாப்பு, அமைதி மற்றும் சுகம் தரும்'; break;
        case 6: reason = 'சாதக தாரை - காரிய சித்தி, வெற்றி மற்றும் முன்னேற்றம் தரும்'; break;
        case 8: reason = 'மித்ர தாரை - இணக்கமான நல்லுறவு மற்றும் மகிழ்ச்சி தரும்'; break;
        case 9: reason = 'பரம மித்ர தாரை - உச்சகட்ட சுப பலன் மற்றும் சகல சௌபாக்கியம் தரும்'; break;
        default: reason = 'சுப தாரை';
      }
    } else {
      status = 'விலக்கப்பட வேண்டும் (Avoid)';
      switch (tara) {
        case 1: reason = 'ஜன்ம தாரை - உடல் உபாதைகள் ஏற்படலாம், தவிர்க்கவும்'; break;
        case 3: reason = 'விபத் தாரை - ஆபத்து, இழப்புகள் ஏற்படலாம், தவிர்க்கவும்'; break;
        case 5: reason = 'ப்ரத்யக் தாரை - தடைகள், எதிர்ப்புகள் வரலாம், தவிர்க்கவும்'; break;
        case 7: reason = 'வத தாரை - மிக கொடிய அசுப தாரை, முற்றிலும் தவிர்க்கவும்'; break;
        default: reason = 'அசுப தாரை';
      }
    }

    return TaraBalaResult(
      taraNumber: tara,
      taraName: taraName,
      isAccepted: isAccepted,
      status: status,
      reason: reason,
    );
  }

  /// Chandra Bala evaluation
  ChandraBalaResult evaluateChandraBala({
    required int birthRasi,
    required double moonLong,
  }) {
    final int moonRasi = (moonLong % 360.0 / 30.0).floor() % 12;
    final int relativeHouse = (((moonRasi - birthRasi) % 12 + 12) % 12) + 1;

    final bool isChandrashtama = (relativeHouse == 8);
    final bool isPreferred = (relativeHouse == 2 || relativeHouse == 5 || relativeHouse == 9 || relativeHouse == 11);

    String status;
    String reason;

    if (isChandrashtama) {
      status = 'சந்திராஷ்டமம் (Invalid / Rejected)';
      reason = 'சந்திரன் உங்கள் ராசிக்கு 8-ம் இடத்தில் உள்ளதால் சந்திராஷ்டம தோஷம். எவ்வித சுப காரியமும் செய்யலாகாது.';
    } else if (isPreferred) {
      status = 'உத்தமம் (Preferred)';
      reason = 'சந்திரன் உங்கள் ராசிக்கு $relativeHouse-ம் இடத்தில் அமைந்து சிறந்த சந்திரபலனைத் தருகிறது.';
    } else if (relativeHouse == 6 || relativeHouse == 12) {
      status = 'மத்திமம் / கவனம் (Weak)';
      reason = 'சந்திரன் $relativeHouse-ம் மறைவு ஸ்தானத்தில் இருப்பதால் சந்திரபலம் குறைவு.';
    } else {
      status = 'சாதகம் (Accepted)';
      reason = 'சந்திரன் உங்கள் ராசிக்கு $relativeHouse-ம் இடத்தில் உள்ளது.';
    }

    return ChandraBalaResult(
      birthRasi: rasiNamesTa[birthRasi],
      moonRasi: rasiNamesTa[moonRasi],
      relativeHouse: relativeHouse,
      isPreferred: isPreferred && !isChandrashtama,
      isChandrashtama: isChandrashtama,
      status: status,
      reason: reason,
    );
  }

  /// Guru Bala evaluation (for Marriage)
  GuruBalaResult evaluateGuruBala({
    required int birthRasi,
    required double jupiterLong,
  }) {
    final int jupiterRasi = (jupiterLong % 360.0 / 30.0).floor() % 12;
    final int relativeHouse = (((jupiterRasi - birthRasi) % 12 + 12) % 12) + 1;

    // Preferred positions: 2, 5, 7, 9, 11
    final bool isAuspicious = (relativeHouse == 2 || relativeHouse == 5 || relativeHouse == 7 ||
        relativeHouse == 9 || relativeHouse == 11);

    String status;
    String reason;
    if (isAuspicious) {
      status = 'குருபலம் உத்தமம் (Auspicious)';
      reason = 'குருபகவான் உங்கள் ராசிக்கு $relativeHouse-ம் இடத்தில் அமைந்திருப்பது திருமணத்திற்கு மிகச் சிறந்த குருபலனாகும்.';
    } else {
      status = 'குருபலம் குறைவு (Weak)';
      reason = 'குருபகவான் உங்கள் ராசிக்கு $relativeHouse-ம் இடத்தில் சஞ்சரிக்கிறார்.';
    }

    return GuruBalaResult(
      birthRasi: rasiNamesTa[birthRasi],
      jupiterRasi: rasiNamesTa[jupiterRasi],
      relativeHouse: relativeHouse,
      isAuspicious: isAuspicious,
      status: status,
      reason: reason,
    );
  }

  /// Surya Bala evaluation
  SuryaBalaResult evaluateSuryaBala({
    required int birthRasi,
    required double sunLong,
  }) {
    final int sunRasi = (sunLong % 360.0 / 30.0).floor() % 12;
    final int relativeHouse = (((sunRasi - birthRasi) % 12 + 12) % 12) + 1;

    // Preferred positions: 3, 6, 10, 11
    final bool isAuspicious = (relativeHouse == 3 || relativeHouse == 6 || relativeHouse == 10 || relativeHouse == 11);

    String status;
    String reason;
    if (isAuspicious) {
      status = 'சூரிய பலம் உத்தமம்';
      reason = 'சூரியன் உங்கள் ராசிக்கு உபசெய ஸ்தானமான $relativeHouse-ம் இடத்தில் அமைந்து அதிக பலம் தருகிறார்.';
    } else {
      status = 'சூரிய பலம் சமம்';
      reason = 'சூரியன் உங்கள் ராசிக்கு $relativeHouse-ம் இடத்தில் சஞ்சரிக்கிறார்.';
    }

    return SuryaBalaResult(
      birthRasi: rasiNamesTa[birthRasi],
      sunRasi: rasiNamesTa[sunRasi],
      relativeHouse: relativeHouse,
      isAuspicious: isAuspicious,
      status: status,
      reason: reason,
    );
  }

  /// Lagna Shuddhi evaluation for a specific candidate time
  LagnaShuddhiResult evaluateLagnaShuddhi({
    required double ascLong,
    required Map<String, ({double longitude, bool isRetrograde})> planets,
    BirthProfile? birthProfile,
  }) {
    final int lagnaRasi = (ascLong % 360.0 / 30.0).floor() % 12;
    final double degInRasi = ascLong % 30.0;
    final lagnaDegStr = '${degInRasi.floor()}° ${(degInRasi * 60 % 60).floor()}\'';

    // 1. Ashtama Lagna Check
    bool isAshtamaLagna = false;
    if (birthProfile != null) {
      final distance = (((lagnaRasi - birthProfile.birthRasi) % 12 + 12) % 12) + 1;
      if (distance == 8) {
        isAshtamaLagna = true;
      }
    }

    // 2. 7th, 8th, 12th houses from Lagna
    final int house7 = (lagnaRasi + 6) % 12;
    final int house8 = (lagnaRasi + 7) % 12;
    final int house12 = (lagnaRasi + 11) % 12;

    // Malefic planets: Sun, Mars, Rahu, Ketu, Saturn
    const malefics = ['Sun', 'Mars', 'Rahu', 'Ketu', 'Saturn'];
    final List<String> maleficInfluences = [];

    for (final m in malefics) {
      final pos = planets[m];
      if (pos != null) {
        final pRasi = (pos.longitude % 360.0 / 30.0).floor() % 12;
        final pNameTa = _planetTa(m);
        if (pRasi == house7) {
          maleficInfluences.add('7-ம் இடத்தில் $pNameTa (ஜாமித்ர தோஷம்)');
        } else if (pRasi == house8) {
          maleficInfluences.add('8-ம் இடத்தில் $pNameTa (அஷ்டம தோஷம்)');
        } else if (pRasi == house12) {
          maleficInfluences.add('12-ம் இடத்தில் $pNameTa (விரய தோஷம்)');
        }
      }
    }

    final bool isClean = (!isAshtamaLagna && maleficInfluences.isEmpty);
    String status;
    String reason;

    if (isAshtamaLagna) {
      status = 'அஷ்டம லக்ன தோஷம் (Rejected)';
      reason = 'முகூர்த்த லக்னம் பிறப்பு ராசிக்கு 8-ம் வீடாக அமைந்துள்ளதால் நிராகரிக்கப்பட்டது.';
    } else if (maleficInfluences.isNotEmpty) {
      status = 'லக்ன அசுத்தி (Malefic In 7/8/12)';
      reason = maleficInfluences.join(', ');
    } else {
      status = 'லக்ன சுத்தி உத்தமம் (Pure)';
      reason = '7, 8, 12 ஆகிய இடங்களில் பாப கிரகங்கள் இல்லை; லக்னம் தூய்மையாக உள்ளது.';
    }

    return LagnaShuddhiResult(
      lagnaRasi: rasiNamesTa[lagnaRasi],
      lagnaDegreeStr: lagnaDegStr,
      isAshtamaLagna: isAshtamaLagna,
      isClean: isClean,
      maleficPlanetsIn7812: maleficInfluences,
      status: status,
      reason: reason,
    );
  }

  /// Panchaka Dosha evaluation: (Day + Tithi + Nakshatra + Lagna) % 9
  PanchakaResult evaluatePanchaka({
    required int weekdayNum, // 1=Mon..7=Sun
    required int tithiNum,   // 1..30
    required int nakIdx,     // 0..26
    required int lagnaRasi,  // 0..11
  }) {
    // Day index: Sunday=1, Monday=2, Tuesday=3, Wednesday=4, Thursday=5, Friday=6, Saturday=7
    final int dayVal = (weekdayNum % 7) + 1;

    // Tithi index: 1..15
    final int tithiVal = ((tithiNum - 1) % 15) + 1;

    // Nakshatra index: 1..27
    final int nakVal = nakIdx + 1;

    // Lagna index: 1..12
    final int lagnaVal = lagnaRasi + 1;

    final int total = dayVal + tithiVal + nakVal + lagnaVal;
    final int rem = total % 9;

    String typeName;
    bool isGood;
    String reason;

    switch (rem) {
      case 1:
        typeName = 'மிருத்யு பஞ்சகம்';
        isGood = false;
        reason = 'மிருத்யு பஞ்சகம் (1) - மரண பயம், ஆபத்து தரும் அசுப பஞ்சகம்';
        break;
      case 2:
        typeName = 'அக்னி பஞ்சகம்';
        isGood = false;
        reason = 'அக்னி பஞ்சகம் (2) - தீ பயம் தரும் அசுப பஞ்சகம்';
        break;
      case 4:
        typeName = 'ராஜ பஞ்சகம்';
        isGood = false;
        reason = 'ராஜ பஞ்சகம் (4) - அரசு/அதிகார பாதிப்பு தரும் அசுப பஞ்சகம்';
        break;
      case 6:
        typeName = 'சோர பஞ்சகம்';
        isGood = false;
        reason = 'சோர பஞ்சகம் (6) - களவு, துரோகம், விரயம் தரும் அசுப பஞ்சகம்';
        break;
      case 8:
        typeName = 'ரோக பஞ்சகம்';
        isGood = false;
        reason = 'ரோக பஞ்சகம் (8) - நோய், ஆரோக்கிய குறைபாடு தரும் அசுப பஞ்சகம்';
        break;
      default:
        // 0, 3, 5, 7
        typeName = 'சுப பஞ்சகம்';
        isGood = true;
        reason = 'சுப பஞ்சகம் ($rem) - தோஷமற்ற உத்தம சுப பஞ்சகம்';
        break;
    }

    return PanchakaResult(
      dayVal: dayVal,
      tithiVal: tithiVal,
      nakshatraVal: nakVal,
      lagnaVal: lagnaVal,
      total: total,
      remainder: rem,
      typeName: typeName,
      isGood: isGood,
      reason: reason,
    );
  }

  /// Calculates Inauspicious Periods (Rahu Kalam, Yamagandam, Gulikai, Visha Kadigai, Sandhya)
  List<InauspiciousPeriod> calculateInauspiciousPeriods({
    required DateTime sunrise,
    required DateTime sunset,
    required int weekday,
    required double moonLong,
  }) {
    final List<InauspiciousPeriod> list = [];
    final dayMins = sunset.difference(sunrise).inMinutes;
    final double partMins = dayMins > 0 ? dayMins / 8.0 : 90.0;

    // 1. Rahu Kalam
    final rPart = rahuParts[weekday] ?? 1;
    final rStart = sunrise.add(Duration(minutes: (rPart * partMins).round()));
    final rEnd = rStart.add(Duration(minutes: partMins.round()));
    list.add(InauspiciousPeriod(
      name: 'ராகுகாலம்',
      start: rStart,
      end: rEnd,
      timingFormatted: '${_time(rStart)} - ${_time(rEnd)}',
      description: 'ராகு ஆதிக்கம் - சுப காரியங்கள் முற்றிலும் தவிர்க்கப்பட வேண்டும்',
    ));

    // 2. Yamagandam
    final yPart = yamaParts[weekday] ?? 4;
    final yStart = sunrise.add(Duration(minutes: (yPart * partMins).round()));
    final yEnd = yStart.add(Duration(minutes: partMins.round()));
    list.add(InauspiciousPeriod(
      name: 'எமகண்டம்',
      start: yStart,
      end: yEnd,
      timingFormatted: '${_time(yStart)} - ${_time(yEnd)}',
      description: 'எமனுக்குரிய நேரம் - காரியத் தடை மற்றும் அபாயம்',
    ));

    // 3. Gulikai
    final gPart = gulikaiParts[weekday] ?? 5;
    final gStart = sunrise.add(Duration(minutes: (gPart * partMins).round()));
    final gEnd = gStart.add(Duration(minutes: partMins.round()));
    list.add(InauspiciousPeriod(
      name: 'குளிகை காலம்',
      start: gStart,
      end: gEnd,
      timingFormatted: '${_time(gStart)} - ${_time(gEnd)}',
      description: 'மந்தன் ஆதிக்கம் - திரும்பத் திரும்ப நிகழும், சில சுப நிகழ்வுகளுக்கு விலக்கு',
    ));

    // 4. Visha Kadigai (Varjyam)
    const nakSpan = 360.0 / 27.0;
    final int nakIdx = (moonLong % 360.0 / nakSpan).floor() % 27;
    final int vStartNazhigai = vishaNazhigaiStart[nakIdx];
    // 1 Nazhigai = 24 minutes. 60 Nazhigais = 24 hours.
    final int vOffsetMins = (vStartNazhigai * 24);
    final vStart = sunrise.add(Duration(minutes: vOffsetMins % 1440));
    final vEnd = vStart.add(const Duration(minutes: 96)); // 4 Nazhigais = 96 mins
    list.add(InauspiciousPeriod(
      name: 'விஷ கடிகை (வர்ஜ்யம்)',
      start: vStart,
      end: vEnd,
      timingFormatted: '${_time(vStart)} - ${_time(vEnd)}',
      description: '${nakshatrasTa[nakIdx]} நட்சத்திரத்தின் விஷ நாழிகை - விஷம பலன் தரும்',
    ));

    // 5. Pratah Sandhya (Morning Twilight: 24 mins before and after sunrise)
    final pratahStart = sunrise.subtract(const Duration(minutes: 24));
    final pratahEnd = sunrise.add(const Duration(minutes: 24));
    list.add(InauspiciousPeriod(
      name: 'பிராத சந்தியா காலம்',
      start: pratahStart,
      end: pratahEnd,
      timingFormatted: '${_time(pratahStart)} - ${_time(pratahEnd)}',
      description: 'சூரிய உதய சந்திப்பு நேரம் - முக்கிய முகூர்த்தங்கள் தவிர்க்கவும்',
    ));

    // 6. Sayam Sandhya (Evening Twilight: 24 mins before and after sunset)
    final sayamStart = sunset.subtract(const Duration(minutes: 24));
    final sayamEnd = sunset.add(const Duration(minutes: 24));
    list.add(InauspiciousPeriod(
      name: 'சாய சந்தியா காலம்',
      start: sayamStart,
      end: sayamEnd,
      timingFormatted: '${_time(sayamStart)} - ${_time(sayamEnd)}',
      description: 'சூரிய அஸ்தமன சந்திப்பு நேரம் - முக்கிய முகூர்த்தங்கள் தவிர்க்கவும்',
    ));

    return list;
  }

  /// Calculates Continuous Valid Subha Muhurtham Windows across the day
  List<SubhaTimeWindow> calculateValidTimeWindows({
    required DateTime cleanDate,
    required DateTime sunrise,
    required DateTime sunset,
    required GeoLocation location,
    required double ayanamsa,
    required Map<String, ({double longitude, bool isRetrograde})> planets,
    required PanchangaAngasResult angas,
    required MuhurthaCategory category,
    required List<InauspiciousPeriod> inauspiciousPeriods,
    required List<int> sunyaRasiIndices,
    required bool isKathiriAgniActive,
    BirthProfile? birthProfile,
  }) {
    // If Chandrashtama is active, reject the entire day
    if (birthProfile != null) {
      final moonRasi = (planets['Moon']!.longitude % 360.0 / 30.0).floor() % 12;
      final int relHouse = (((moonRasi - birthProfile.birthRasi) % 12 + 12) % 12) + 1;
      if (relHouse == 8) {
        return [];
      }
    }

    // If Kathiri is active and activity is Bhoomi Pooja or Gruha Pravesham, reject
    if (isKathiriAgniActive && (category == MuhurthaCategory.bhoomiPooja || category == MuhurthaCategory.houseEntry)) {
      return [];
    }

    // Step across daytime in 5-minute increments
    final List<({DateTime time, String lagna, String panchaka, double score})> validMinutes = [];

    DateTime cur = sunrise.add(const Duration(minutes: 25)); // Skip morning sandhya
    final endTime = sunset.subtract(const Duration(minutes: 25)); // Skip evening sandhya

    while (cur.isBefore(endTime)) {
      // 1. Check if inside inauspicious periods (Rahu, Yama, Gulikai, Visha, Sandhya)
      bool isInauspicious = false;
      for (final period in inauspiciousPeriods) {
        if (!cur.isBefore(period.start) && cur.isBefore(period.end)) {
          isInauspicious = true;
          break;
        }
      }

      if (!isInauspicious) {
        // Calculate Lagna at this exact minute
        final jdCur = SwissEphemerisCalculator.getJulianDay(cur, utcOffsetHours: location.timeZone);
        final ascLong = SwissEphemerisCalculator.calculateAscendantSidereal(
          jd: jdCur,
          latitude: location.latitude,
          longitude: location.longitude,
          ayanamsa: ayanamsa,
        );
        final lagnaRasi = (ascLong % 360.0 / 30.0).floor() % 12;

        // Check Month Sunyam Rasi
        final isMonthSunyam = sunyaRasiIndices.contains(lagnaRasi);

        // Check Lagna Shuddhi
        final lagnaShuddhi = evaluateLagnaShuddhi(
          ascLong: ascLong,
          planets: planets,
          birthProfile: birthProfile,
        );

        // Check Panchaka Dosha
        final panchaka = evaluatePanchaka(
          weekdayNum: cur.weekday,
          tithiNum: angas.tithiNumber,
          nakIdx: angas.nakshatraIndex,
          lagnaRasi: lagnaRasi,
        );

        // Filter: Must be Clean Lagna, Good Panchaka, and Not Month Sunyam
        if (!isMonthSunyam && lagnaShuddhi.isClean && panchaka.isGood) {
          double score = 75.0;
          if (angas.isTithiPreferred) score += 10;
          if (angas.isVaraPreferred) score += 5;
          if (angas.isNakshatraSuitable) score += 10;

          validMinutes.add((
            time: cur,
            lagna: lagnaShuddhi.lagnaRasi,
            panchaka: panchaka.typeName,
            score: score,
          ));
        }
      }

      cur = cur.add(const Duration(minutes: 5));
    }

    if (validMinutes.isEmpty) {
      return [];
    }

    // Merge contiguous minutes into continuous time windows (min duration >= 15 mins)
    final List<SubhaTimeWindow> windows = [];
    DateTime winStart = validMinutes.first.time;
    DateTime winEnd = winStart.add(const Duration(minutes: 5));
    String curLagna = validMinutes.first.lagna;
    String curPanchaka = validMinutes.first.panchaka;
    double maxScore = validMinutes.first.score;

    for (int i = 1; i < validMinutes.length; i++) {
      final m = validMinutes[i];
      if (m.time.isAtSameMomentAs(winEnd) && m.lagna == curLagna) {
        // Contiguous in same lagna
        winEnd = m.time.add(const Duration(minutes: 5));
        if (m.score > maxScore) maxScore = m.score;
      } else {
        // Boundary reached
        final durMins = winEnd.difference(winStart).inMinutes;
        if (durMins >= 15) {
          windows.add(_createWindow(winStart, winEnd, curLagna, curPanchaka, maxScore));
        }
        winStart = m.time;
        winEnd = winStart.add(const Duration(minutes: 5));
        curLagna = m.lagna;
        curPanchaka = m.panchaka;
        maxScore = m.score;
      }
    }

    // Final window
    final finalDur = winEnd.difference(winStart).inMinutes;
    if (finalDur >= 15) {
      windows.add(_createWindow(winStart, winEnd, curLagna, curPanchaka, maxScore));
    }

    return windows;
  }

  static SubhaTimeWindow _createWindow(
    DateTime start,
    DateTime end,
    String lagna,
    String panchaka,
    double score,
  ) {
    final dur = end.difference(start).inMinutes;
    final hrs = dur ~/ 60;
    final mins = dur % 60;
    final durStr = hrs > 0 ? '$hrs மணி $mins நிமிடம்' : '$mins நிமிடங்கள்';

    return SubhaTimeWindow(
      start: start,
      end: end,
      timingFormatted: '${_time(start)} - ${_time(end)}',
      durationFormatted: durStr,
      lagnaName: '$lagna லக்னம்',
      panchakaName: panchaka,
      suitabilityScore: score,
      reasons: [
        '$lagna லக்ன சுத்தி பெற்றது (7, 8, 12-ல் பாப கிரகங்கள் இல்லை)',
        '$panchaka யோகம் அமையப்பெற்றது',
        'ராகுகாலம், எமகண்டம், குளிகை, விஷ கடிகை அற்ற தூய நேரம்',
      ],
    );
  }

  static String _time(DateTime dt) {
    return DateFormat('hh:mm a').format(dt);
  }

  static String _planetTa(String en) {
    switch (en) {
      case 'Sun': return 'சூரியன்';
      case 'Moon': return 'சந்திரன்';
      case 'Mars': return 'செவ்வாய்';
      case 'Mercury': return 'புதன்';
      case 'Jupiter': return 'குரு';
      case 'Venus': return 'சுக்கிரன்';
      case 'Saturn': return 'சனி';
      case 'Rahu': return 'ராகு';
      case 'Ketu': return 'கேது';
      default: return en;
    }
  }
}
