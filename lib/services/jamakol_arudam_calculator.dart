import '../models/jamakol_arudam_model.dart';
import 'astrology_calculator.dart';

/// Calculation Service for Jamakol Arudam (ஜாமகோள் ஆருடம்) Prasannam
class JamakolArudamCalculator {
  static const List<String> jamamLordsDay = [
    'சூரியன்', 'செவ்வாய்', 'குரு', 'புதன்', 'சுக்கிரன்', 'சனி', 'சந்திரன்', 'ராகு'
  ];

  static const List<String> jamamLordsNight = [
    'சந்திரன்', 'சனி', 'சுக்கிரன்', 'புதன்', 'குரு', 'செவ்வாய்', 'சூரியன்', 'கேது'
  ];

  /// Calculate Jamakol Arudam for a given Query DateTime and Location
  static JamakolArudamResult calculate({
    required DateTime queryTime,
    int? customAarudamNumber, // 1..12 or selected Rasi
    double latitude = 13.0827,
    double longitude = 80.2707,
    double utcOffsetHours = 5.5,
  }) {
    final sunTimes = AstrologyCalculator.calculateSunriseSunset(queryTime, latitude, longitude, utcOffsetHours);
    final sunrise = sunTimes['sunrise']!;
    final sunset = sunTimes['sunset']!;

    final bool isDay = !queryTime.isBefore(sunrise) && queryTime.isBefore(sunset);

    // Calculate Jamam duration (Day / Night divided into 8 Jamams, ~1.5 hours each)
    double totalMinutes;
    double elapsedMinutes;

    if (isDay) {
      totalMinutes = sunset.difference(sunrise).inMinutes.toDouble();
      elapsedMinutes = queryTime.difference(sunrise).inMinutes.toDouble().clamp(0.0, totalMinutes);
    } else {
      final nextSunrise = sunrise.add(const Duration(days: 1));
      totalMinutes = nextSunrise.difference(sunset).inMinutes.toDouble();
      elapsedMinutes = queryTime.isAfter(sunset)
          ? queryTime.difference(sunset).inMinutes.toDouble()
          : queryTime.difference(sunset.subtract(const Duration(days: 1))).inMinutes.toDouble();
    }

    final double jamamDuration = totalMinutes / 8.0;
    final int jamamIdx = (elapsedMinutes / jamamDuration).floor().clamp(0, 7);
    final int jamamNum = jamamIdx + 1;

    final String jamamLord = isDay ? jamamLordsDay[jamamIdx] : jamamLordsNight[jamamIdx];
    final String jamamName = "${isDay ? 'பகல்' : 'இரவு'} $jamamNum-ஆம் சாமம் ($jamamLord ஆதிக்கம்)";

    // 1. Udhayam (உதயம்): Moving sign according to time of day
    final natal = AstrologyCalculator.calculateHoroscope(
      dateOfBirth: queryTime,
      latitude: latitude,
      longitude: longitude,
      utcOffsetHours: utcOffsetHours,
    );
    final int udhayamRasiIdx = natal.lagna.rasiIndex;
    final udhayam = JamakolPlanet(
      nameTa: 'உதயம் (Udhayam)',
      symbol: 'உ',
      rasiIndex: udhayamRasiIdx,
      rasiNameTa: AstrologyCalculator.rasiNamesTa[udhayamRasiIdx],
      isSpecialPoint: true,
    );

    // 2. Aarudam (ஆருடம்): Selected by client / query number / seed
    final int aarudamRasiIdx = (customAarudamNumber != null && customAarudamNumber >= 1 && customAarudamNumber <= 12)
        ? customAarudamNumber - 1
        : ((udhayamRasiIdx + jamamIdx * 2 + 1) % 12);

    final aarudam = JamakolPlanet(
      nameTa: 'ஆருடம் (Aarudam)',
      symbol: 'ஆ',
      rasiIndex: aarudamRasiIdx,
      rasiNameTa: AstrologyCalculator.rasiNamesTa[aarudamRasiIdx],
      isSpecialPoint: true,
    );

    // 3. Kavippu (கவிப்பு): Obstruction point
    // Formula: Kavippu = (Aarudam + 6) % 12 in classical table
    final int kavippuRasiIdx = (aarudamRasiIdx + 6) % 12;
    final kavippu = JamakolPlanet(
      nameTa: 'கவிப்பு (Kavippu)',
      symbol: 'கவி',
      rasiIndex: kavippuRasiIdx,
      rasiNameTa: AstrologyCalculator.rasiNamesTa[kavippuRasiIdx],
      isSpecialPoint: true,
    );

    // 4. Sooriyan (சூரியன்)
    final int sooriyanRasiIdx = natal.sun.rasiIndex;
    final sooriyan = JamakolPlanet(
      nameTa: 'சூரியன் (Sooriyan)',
      symbol: 'சூ',
      rasiIndex: sooriyanRasiIdx,
      rasiNameTa: AstrologyCalculator.rasiNamesTa[sooriyanRasiIdx],
      isSpecialPoint: true,
    );

    // 8 Jamakkol Outer Planets placed in Jamam positions
    final List<JamakolPlanet> jamaPlanets = [
      JamakolPlanet(nameTa: 'ஜா.சூரியன்', symbol: 'ஜா.சூ', rasiIndex: (sooriyanRasiIdx + jamamIdx) % 12, rasiNameTa: AstrologyCalculator.rasiNamesTa[(sooriyanRasiIdx + jamamIdx) % 12]),
      JamakolPlanet(nameTa: 'ஜா.செவ்வாய்', symbol: 'ஜா.செவ்', rasiIndex: (0 + jamamIdx * 2) % 12, rasiNameTa: AstrologyCalculator.rasiNamesTa[(0 + jamamIdx * 2) % 12]),
      JamakolPlanet(nameTa: 'ஜா.குரு', symbol: 'ஜா.குரு', rasiIndex: (3 + jamamIdx) % 12, rasiNameTa: AstrologyCalculator.rasiNamesTa[(3 + jamamIdx) % 12]),
      JamakolPlanet(nameTa: 'ஜா.புதன்', symbol: 'ஜா.பு', rasiIndex: (5 + jamamIdx * 3) % 12, rasiNameTa: AstrologyCalculator.rasiNamesTa[(5 + jamamIdx * 3) % 12]),
      JamakolPlanet(nameTa: 'ஜா.சுக்கிரன்', symbol: 'ஜா.சுக்', rasiIndex: (1 + jamamIdx * 2) % 12, rasiNameTa: AstrologyCalculator.rasiNamesTa[(1 + jamamIdx * 2) % 12]),
      JamakolPlanet(nameTa: 'ஜா.சனி', symbol: 'ஜா.சனி', rasiIndex: (9 + jamamIdx) % 12, rasiNameTa: AstrologyCalculator.rasiNamesTa[(9 + jamamIdx) % 12]),
      JamakolPlanet(nameTa: 'ஜா.சந்திரன்', symbol: 'ஜா.சந்', rasiIndex: (natal.moon.rasiIndex + jamamIdx) % 12, rasiNameTa: AstrologyCalculator.rasiNamesTa[(natal.moon.rasiIndex + jamamIdx) % 12]),
      JamakolPlanet(nameTa: 'ஜா.பாம்பு (ராகு)', symbol: 'ஜா.ரா', rasiIndex: (natal.planets['Rahu']?.rasiIndex ?? 0 + jamamIdx) % 12, rasiNameTa: AstrologyCalculator.rasiNamesTa[(natal.planets['Rahu']?.rasiIndex ?? 0 + jamamIdx) % 12]),
    ];

    // Sky Inner Planets
    final List<JamakolPlanet> skyPlanets = natal.planets.values.map((p) {
      return JamakolPlanet(
        nameTa: p.tamilName,
        symbol: p.symbol,
        rasiIndex: p.rasiIndex,
        rasiNameTa: p.rasiNameTa,
      );
    }).toList();

    // Interpretation & Success analysis
    final bool isUdhayamKavippuConjoined = (udhayamRasiIdx == kavippuRasiIdx);
    final bool isAarudamKavippuConjoined = (aarudamRasiIdx == kavippuRasiIdx);

    String successAnalysis;
    if (isUdhayamKavippuConjoined || isAarudamKavippuConjoined) {
      successAnalysis =
          'கவிப்பு உதயம் அல்லது ஆருடத்துடன் இணைந்துள்ளதால், காரியத்தில் ஆரம்பத் தடைகள் மற்றும் தாமதங்கள் ஏற்படலாம். நிதானமாக செயல்படுவது அவசியம்.';
    } else {
      successAnalysis =
          'உதயம் மற்றும் ஆருடம் சுப ஸ்தானங்களில் கவிப்பு தோஷம் இல்லாமல் அமைந்துள்ளதால், கேட்கப்பட்ட கேள்வி சுபமாக நிறைவேறும்.';
    }

    final String generalPred =
        'தற்போதைய ஜாம அதிபதி $jamamLord ஆவார். ஆருடம் ${AstrologyCalculator.rasiNamesTa[aarudamRasiIdx]} ராசியிலும், உதயம் ${AstrologyCalculator.rasiNamesTa[udhayamRasiIdx]} ராசியிலும் அமைந்துள்ளன.';

    final List<String> favorable = [
      AstrologyCalculator.rasiNamesTa[udhayamRasiIdx],
      AstrologyCalculator.rasiNamesTa[aarudamRasiIdx],
      AstrologyCalculator.rasiNamesTa[(udhayamRasiIdx + 4) % 12],
      AstrologyCalculator.rasiNamesTa[(udhayamRasiIdx + 8) % 12],
    ];

    final List<String> obstructive = [
      AstrologyCalculator.rasiNamesTa[kavippuRasiIdx],
      AstrologyCalculator.rasiNamesTa[(kavippuRasiIdx + 6) % 12],
    ];

    return JamakolArudamResult(
      queryTime: queryTime,
      jamamNumber: jamamNum,
      isDayJamam: isDay,
      jamamNameTa: jamamName,
      jamamLordTa: jamamLord,
      udhayam: udhayam,
      aarudam: aarudam,
      kavippu: kavippu,
      sooriyan: sooriyan,
      jamaPlanets: jamaPlanets,
      skyPlanets: skyPlanets,
      generalPredictionTa: generalPred,
      questionSuccessAnalysisTa: successAnalysis,
      favorableSignsTa: favorable,
      obstructiveSignsTa: obstructive,
    );
  }
}
