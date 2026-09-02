import '../data/jamakol_arudam_model1_rules.dart';
import '../models/jamakol_arudam_model1.dart';
import '../services/astrology_calculator.dart';
import 'jamakol_arudam_model1_prediction_engine.dart';

/// Core Calculation Engine for Jamakol Arudam Model 1
/// Responsible for:
/// - Real astronomical ephemeris consumption
/// - Longitude normalization & full-precision DMS conversion
/// - Deriving உதயம் (Udhayam), ஆருடம் (Aarudam), and கவிப்பு (Kavippu)
/// - Mapping all 9 Navagrahas relative to Udhayam
/// - Producing structured JamakolArudamModel1Result
class JamakolArudamModel1Engine {
  /// Standard Jamam lords for 8 day jamams (Sun to Rahu)
  static const List<String> jamamLordsDay = [
    'சூரியன்', 'செவ்வாய்', 'குரு', 'புதன்', 'சுக்கிரன்', 'சனி', 'சந்திரன்', 'ராகு'
  ];

  /// Standard Jamam lords for 8 night jamams (Moon to Ketu)
  static const List<String> jamamLordsNight = [
    'சந்திரன்', 'சனி', 'சுக்கிரன்', 'புதன்', 'குரு', 'செவ்வாய்', 'சூரியன்', 'கேது'
  ];

  /// Standard 9 Planet keys in ephemeris
  static const List<String> navagrahaKeys = [
    'Sun',
    'Moon',
    'Mars',
    'Mercury',
    'Jupiter',
    'Venus',
    'Saturn',
    'Rahu',
    'Ketu',
  ];

  /// Normalize longitude strictly into 0° <= longitude < 360°
  static double normalizeLongitude(double longitude) {
    if (longitude.isNaN || longitude.isInfinite) {
      throw ArgumentError('செல்லுபடியாகாத பாகை மதிப்பு (Invalid longitude): $longitude');
    }
    double norm = longitude % 360.0;
    if (norm < 0) norm += 360.0;
    return norm;
  }

  /// Get Rasi Index (0 to 11) from longitude
  static int getRasiIndex(double longitude) {
    final norm = normalizeLongitude(longitude);
    return (norm / 30.0).floor() % 12;
  }

  /// Get Rasi Name in Tamil
  static String getRasiName(int rasiIndex) {
    final idx = rasiIndex.clamp(0, 11);
    return AstrologyCalculator.rasiNamesTa[idx];
  }

  /// Mathematical DMS decomposition without loss of precision: (degree, minute, second)
  static (int degree, int minute, double second) toDMS(double degreeWithinRasi) {
    final d = degreeWithinRasi.floor();
    final minuteFloat = (degreeWithinRasi - d) * 60.0;
    final m = minuteFloat.floor();
    final seconds = (minuteFloat - m) * 60.0;
    return (d, m, seconds);
  }

  /// Input coordinate and date validation
  static void validateInputs({
    required DateTime queryTime,
    required double latitude,
    required double longitude,
  }) {
    if (latitude == 0.0 && longitude == 0.0) {
      throw ArgumentError('அட்சரேகை/தீர்க்கரேகை (Latitude/Longitude) தேவை. 0,0 பயன்படுத்த முடியாது.');
    }
    if (latitude < -90.0 || latitude > 90.0) {
      throw ArgumentError('அட்சரேகை (Latitude) -90 முதல் +90 வரை மட்டுமே இருக்க வேண்டும். பெறப்பட்டது: $latitude');
    }
    if (longitude < -180.0 || longitude > 180.0) {
      throw ArgumentError('தீர்க்கரேகை (Longitude) -180 முதல் +180 வரை மட்டுமே இருக்க வேண்டும். பெறப்பட்டது: $longitude');
    }
    if (queryTime.year < 1800 || queryTime.year > 2200) {
      throw ArgumentError('செல்லுபடியாகும் ஆண்டை உள்ளிடவும் (1800-2200). பெறப்பட்டது: ${queryTime.year}');
    }
  }

  /// Calculate full Jamakol Arudam Model 1 Result
  static JamakolArudamModel1Result calculate({
    required DateTime queryTime,
    int? customAarudamNumber, // 1 to 12
    required double latitude,
    required double longitude,
    double utcOffsetHours = 5.5,
    String placeName = '',
  }) {
    // 1. Strict validation
    validateInputs(
      queryTime: queryTime,
      latitude: latitude,
      longitude: longitude,
    );

    // 2. Sunrise & Sunset for Jamam division
    final sunTimes = AstrologyCalculator.calculateSunriseSunset(
      queryTime,
      latitude,
      longitude,
      utcOffsetHours,
    );
    final sunrise = sunTimes['sunrise']!;
    final sunset = sunTimes['sunset']!;

    final bool isDay = !queryTime.isBefore(sunrise) && queryTime.isBefore(sunset);

    // 3. Jamam Duration & Period
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

    // 4. Astronomical Natal / Ephemeris calculation
    final natal = AstrologyCalculator.calculateHoroscope(
      dateOfBirth: queryTime,
      latitude: latitude,
      longitude: longitude,
      utcOffsetHours: utcOffsetHours,
    );

    // 5. Core Point 1: உதயம் (Udhayam - Ascendant)
    final udhayamLong = natal.lagna.longitude;
    final udhayamRasiIdx = natal.lagna.rasiIndex;
    final udhayamDegWithin = natal.lagna.degreeInRasi;
    final udhayamDms = toDMS(udhayamDegWithin);

    final udhayam = JamakolArudamCorePoint(
      nameTa: 'உதயம்',
      nameEn: 'Udhayam',
      symbol: 'உ',
      absoluteLongitude: udhayamLong,
      rasi: natal.lagna.rasiNameTa,
      rasiIndex: udhayamRasiIdx,
      degreeWithinRasi: udhayamDegWithin,
      degree: udhayamDms.$1,
      minute: udhayamDms.$2,
      second: udhayamDms.$3,
    );

    // 6. Core Point 2: ஆருடம் (Aarudam)
    final int aarudamRasiIdx = (customAarudamNumber != null && customAarudamNumber >= 1 && customAarudamNumber <= 12)
        ? (customAarudamNumber - 1)
        : ((udhayamRasiIdx + jamamIdx * 2 + 1) % 12);

    final aarudamDegWithin = udhayamDegWithin;
    final aarudamLong = normalizeLongitude((aarudamRasiIdx * 30.0) + aarudamDegWithin);
    final aarudamDms = toDMS(aarudamDegWithin);

    final aarudam = JamakolArudamCorePoint(
      nameTa: 'ஆருடம்',
      nameEn: 'Aarudam',
      symbol: 'ஆ',
      absoluteLongitude: aarudamLong,
      rasi: getRasiName(aarudamRasiIdx),
      rasiIndex: aarudamRasiIdx,
      degreeWithinRasi: aarudamDegWithin,
      degree: aarudamDms.$1,
      minute: aarudamDms.$2,
      second: aarudamDms.$3,
    );

    // 7. Core Point 3: கவிப்பு (Kavippu - Opposition / Obstruction point)
    final kavippuLong = normalizeLongitude(aarudamLong + 180.0);
    final kavippuRasiIdx = (aarudamRasiIdx + 6) % 12;
    final kavippuDegWithin = kavippuLong % 30.0;
    final kavippuDms = toDMS(kavippuDegWithin);

    final kavippu = JamakolArudamCorePoint(
      nameTa: 'கவிப்பு',
      nameEn: 'Kavippu',
      symbol: 'கவி',
      absoluteLongitude: kavippuLong,
      rasi: getRasiName(kavippuRasiIdx),
      rasiIndex: kavippuRasiIdx,
      degreeWithinRasi: kavippuDegWithin,
      degree: kavippuDms.$1,
      minute: kavippuDms.$2,
      second: kavippuDms.$3,
    );

    // 8. 9 Navagrahas from Ephemeris
    final List<JamakolArudamPlanet> planets = [];
    for (final key in navagrahaKeys) {
      final p = natal.planets[key];
      if (p == null) continue;

      final houseFromUdhayam = ((p.rasiIndex - udhayamRasiIdx + 12) % 12) + 1;
      final dms = toDMS(p.degreeInRasi);

      planets.add(JamakolArudamPlanet(
        nameTa: p.tamilName,
        englishName: p.name,
        planetKey: p.name,
        longitude: p.longitude,
        rasi: p.rasiNameTa,
        rasiIndex: p.rasiIndex,
        degreeWithinRasi: p.degreeInRasi,
        degree: dms.$1,
        minute: dms.$2,
        second: dms.$3,
        house: houseFromUdhayam,
        nakshatra: p.nakshatraNameTa,
        pada: p.pada,
        isRetrograde: p.isRetrograde,
      ));
    }

    // 9. Predictions
    final predictions = JamakolArudamModel1PredictionEngine.generatePredictions(
      udhayam: udhayam,
      aarudam: aarudam,
      kavippu: kavippu,
      planets: planets,
    );

    // 10. Summary & Sign Analysis
    final favorableSigns = JamakolArudamModel1RulesRepository.getFavorableSigns(
      udhayamRasiIdx,
      aarudamRasiIdx,
    );

    final obstructiveSigns = JamakolArudamModel1RulesRepository.getObstructiveSigns(
      kavippuRasiIdx,
      udhayamRasiIdx,
    );

    final generalSummary = JamakolArudamModel1RulesRepository.generateGeneralSummary(
      udhayam: udhayam,
      aarudam: aarudam,
      kavippu: kavippu,
      jamamLordTa: jamamLord,
      isDay: isDay,
    );

    return JamakolArudamModel1Result(
      queryTime: queryTime,
      latitude: latitude,
      longitude: longitude,
      placeName: placeName,
      jamamNumber: jamamNum,
      isDayJamam: isDay,
      jamamNameTa: jamamName,
      jamamLordTa: jamamLord,
      udhayam: udhayam,
      aarudam: aarudam,
      kavippu: kavippu,
      planets: planets,
      predictions: predictions,
      favorableSignsTa: favorableSigns,
      obstructiveSignsTa: obstructiveSigns,
      generalSummaryTa: generalSummary,
    );
  }
}
