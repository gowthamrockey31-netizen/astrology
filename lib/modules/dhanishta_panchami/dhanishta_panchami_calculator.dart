import 'dart:math' as math;
import '../../services/swiss_ephemeris_calculator.dart';
import 'dhanishta_panchami_models.dart';

/// ===============================================================
/// DHANISHTA PANCHAMI / TITHI ADAIPPU CALCULATOR
/// ===============================================================
class DhanishtaCalculator {
  static const List<String> nakshatrasTamil = [
    '', // 0-index unused, 1-indexed to match Nakshatra numbers 1..27
    'அஸ்வினி',
    'பரணி',
    'கார்த்திகை',
    'ரோகிணி',
    'மிருகசீரிஷம்',
    'திருவாதிரை',
    'புனர்பூசம்',
    'பூசம்',
    'ஆயில்யம்',
    'மகம்',
    'பூரம்',
    'உத்திரம்',
    'ஹஸ்தம்',
    'சித்திரை',
    'சுவாதி',
    'விசாகம்',
    'அனுஷம்',
    'கேட்டை',
    'மூலம்',
    'பூராடம்',
    'உத்திராடம்',
    'திருவோணம்',
    'அவிட்டம்', // 23: Dhanishta
    'சதயம்',   // 24: Shatabhisha
    'பூரட்டாதி', // 25: Purva Bhadrapada
    'உத்திரட்டாதி', // 26: Uttara Bhadrapada
    'ரேவதி',   // 27: Revati
  ];

  static const List<String> tithisTamil = [
    '',
    'பிரதமை',
    'துவிதியை',
    'திரிதியை',
    'சதுர்த்தி',
    'பஞ்சமி',
    'சஷ்டி',
    'சப்தமி',
    'அஷ்டமி',
    'நவமி',
    'தசமி',
    'ஏகாதசி',
    'துவாதசி',
    'திரயோதசி',
    'சதுர்த்தசி',
    'பௌர்ணமி',
  ];

  /// Calculate Dhanishta Panchami and Tithi Adaippu for a given DateTime
  static TithiResult calculate(
    DateTime dateTime, {
    double latitude = 13.0827,
    double longitude = 80.2707,
    double utcOffsetHours = 5.5,
  }) {
    double sunLong;
    double moonLong;

    // 1. Try authoritative Swiss Ephemeris calculation if available
    try {
      final jd = SwissEphemerisCalculator.getJulianDay(
        dateTime,
        utcOffsetHours: utcOffsetHours,
      );
      final ayanamsa = SwissEphemerisCalculator.calculateLahiriAyanamsa(jd);
      final planets = SwissEphemerisCalculator.calculatePlanetaryPositions(
        jd: jd,
        ayanamsa: ayanamsa,
      );
      sunLong = planets['Sun']!.longitude;
      moonLong = planets['Moon']!.longitude;
    } catch (_) {
      // 2. Reliable astronomical mathematical fallback
      final jd = _julianDay(dateTime);
      sunLong = _sunLongitude(jd);
      moonLong = _moonLongitude(jd);
    }

    return calculateFromLongitudes(
      sunLongitude: sunLong,
      moonLongitude: moonLong,
    );
  }

  /// Calculate from precise Sun and Moon longitudes
  static TithiResult calculateFromLongitudes({
    required double sunLongitude,
    required double moonLongitude,
  }) {
    // Angular distance Moon - Sun normalized to 0..360
    final double elongation = _normalize360(moonLongitude - sunLongitude);

    // 12 degrees = one Tithi
    int tithiNumber = (elongation / 12).floor() + 1;
    if (tithiNumber < 1) tithiNumber = 1;
    if (tithiNumber > 30) tithiNumber = 30;

    final String paksha =
        tithiNumber <= 15 ? 'சுக்ல பக்ஷம்' : 'கிருஷ்ண பக்ஷம்';

    final int tithiIndex =
        tithiNumber <= 15 ? tithiNumber : tithiNumber - 15;

    final String tithiTamil = _tithiTamil(
      tithiIndex,
      isKrishnaAmavasya: tithiNumber == 30,
    );

    // Nakshatra: 360 / 27 = 13°20' = 13.333333 degrees
    final int rawNakshatra = (moonLongitude / (360.0 / 27.0)).floor() + 1;
    final int safeNakshatra = rawNakshatra.clamp(1, 27);
    final String nakshatraTamil = _nakshatraTamil(safeNakshatra);

    return _evaluate(
      tithiNumber: tithiNumber,
      tithiIndex: tithiIndex,
      tithiTamil: tithiTamil,
      pakshaTamil: paksha,
      safeNakshatra: safeNakshatra,
      nakshatraTamil: nakshatraTamil,
    );
  }

  /// Calculate directly from Nakshatra (1..27) and Tithi (1..30)
  static TithiResult calculateFromIndices({
    required int nakshatraNumber,
    required int tithiNumber,
  }) {
    final int safeNak = nakshatraNumber.clamp(1, 27);
    final int safeTithi = tithiNumber.clamp(1, 30);

    final String paksha =
        safeTithi <= 15 ? 'சுக்ல பக்ஷம்' : 'கிருஷ்ண பக்ஷம்';
    final int tithiIndex =
        safeTithi <= 15 ? safeTithi : safeTithi - 15;

    final String tithiTamil = _tithiTamil(
      tithiIndex,
      isKrishnaAmavasya: safeTithi == 30,
    );
    final String nakshatraTamil = _nakshatraTamil(safeNak);

    return _evaluate(
      tithiNumber: safeTithi,
      tithiIndex: tithiIndex,
      tithiTamil: tithiTamil,
      pakshaTamil: paksha,
      safeNakshatra: safeNak,
      nakshatraTamil: nakshatraTamil,
    );
  }

  static TithiResult _evaluate({
    required int tithiNumber,
    required int tithiIndex,
    required String tithiTamil,
    required String pakshaTamil,
    required int safeNakshatra,
    required String nakshatraTamil,
  }) {
    // Dhanishta / Avittam = 23rd Nakshatra
    final bool isDhanishta = (safeNakshatra == 23);

    // Panchami = 5th Tithi in either Paksha
    final bool isPanchami = (tithiIndex == 5);

    // Dhanishta Panchami condition: Avittam (23) + Panchami (5)
    final bool isDhanishtaPanchami = isDhanishta && isPanchami;

    final adaippu = _adaippuRule(safeNakshatra);

    return TithiResult(
      tithiNumber: tithiNumber,
      tithiTamil: tithiTamil,
      pakshaTamil: pakshaTamil,
      nakshatraNumber: safeNakshatra,
      nakshatraTamil: nakshatraTamil,
      isDhanishtaPanchami: isDhanishtaPanchami,
      isAdaippuNakshatra: adaippu.months > 0,
      adaippuMonths: adaippu.months,
      adaippuType: adaippu.type,
      explanation: _buildExplanation(
        isDhanishtaPanchami: isDhanishtaPanchami,
        safeNakshatra: safeNakshatra,
        nakshatraTamil: nakshatraTamil,
        tithiIndex: tithiIndex,
        tithiTamil: tithiTamil,
        adaippuMonths: adaippu.months,
      ),
      remedy: _remedyText(safeNakshatra, isDhanishtaPanchami),
    );
  }

  /// Reference Adaippu Rule Table:
  /// Avittam (23)      -> 6 months
  /// Sathayam (24)     -> 6 months
  /// Poorattathi (25)  -> 6 months
  /// Uthirattathi (26) -> 6 months
  /// Revathi (27)      -> 6 months
  /// Rohini (4)        -> 4 months
  /// Karthigai (3)     -> 3 months
  /// Uthiram (12)      -> 3 months
  /// Mrigashiram (5)   -> 2 months
  /// Chithirai (14)    -> 2 months
  /// Punarpoosam (7)   -> 2 months
  /// Visakam (16)      -> 2 months
  /// Uthiradam (21)    -> 2 months
  /// All other Nakshatras -> No Adaippu
  static AdaippuData _adaippuRule(int n) {
    switch (n) {
      case 23: // Avittam
      case 24: // Sathayam
      case 25: // Poorattathi
      case 26: // Uthirattathi
      case 27: // Revathi
        return const AdaippuData(6, 'ஆறு மாத அடைப்பு');

      case 4: // Rohini
        return const AdaippuData(4, 'நான்கு மாத அடைப்பு');

      case 3: // Karthigai
      case 12: // Uthiram
        return const AdaippuData(3, 'மூன்று மாத அடைப்பு');

      case 5: // Mrigashiram
      case 14: // Chithirai
      case 7: // Punarpoosam
      case 16: // Visakam
      case 21: // Uthiradam
        return const AdaippuData(2, 'இரண்டு மாத அடைப்பு');

      default:
        return const AdaippuData(0, 'அடைப்பு இல்லை');
    }
  }

  static String _tithiTamil(int n, {bool isKrishnaAmavasya = false}) {
    if (isKrishnaAmavasya && n == 15) {
      return 'அமாவாசை';
    }
    if (n >= 1 && n < tithisTamil.length) {
      return tithisTamil[n];
    }
    return 'திதி $n';
  }

  static String _nakshatraTamil(int n) {
    if (n >= 1 && n < nakshatrasTamil.length) {
      return nakshatrasTamil[n];
    }
    return 'நட்சத்திரம் $n';
  }

  static String _buildExplanation({
    required bool isDhanishtaPanchami,
    required int safeNakshatra,
    required String nakshatraTamil,
    required int tithiIndex,
    required String tithiTamil,
    required int adaippuMonths,
  }) {
    if (isDhanishtaPanchami) {
      return 'அவிட்டம் (23) நட்சத்திரமும் பஞ்சமி திதியும் இணைந்து தனிஷ்டா பஞ்சமி தோஷம் ஏற்பட்டுள்ளது. '
          'அவிட்டம் முதல் ரேவதி வரையிலான பஞ்சக நட்சத்திரங்களில் மரணம் அல்லது அசுப நிகழ்வுகள் நிகழும்போது, '
          'சாஸ்திர விதிப்படி ஆறு மாதங்கள் வரை வீடு அடைப்பு மற்றும் விசேஷ சாந்தி வழிபாடுகள் செய்யப்படுவது பாரம்பரிய வழக்கம்.';
    }

    if (adaippuMonths > 0) {
      return '$nakshatraTamil நட்சத்திரம் ($safeNakshatra) அடைப்பு நட்சத்திரப் பட்டியலில் இடம்பெறுகிறது. '
          'இந்த நட்சத்திரத்தில் மரணம் அல்லது விசேஷ அசுப நிகழ்வுகள் ஏற்பட்டால் சாஸ்திரப்படி $adaippuMonths மாதங்கள் அடைப்பு காலமாகக் கணக்கிடப்படுகிறது.';
    }

    return '$nakshatraTamil நட்சத்திரத்தில் ($safeNakshatra) மற்றும் $tithiTamil திதியில் தனிஷ்டா பஞ்சமி சேர்க்கையோ '
        'அல்லது அடைப்பு நட்சத்திர தோஷமோ இல்லை. சாதாரண விதிமுறைகள் பொருந்தும்.';
  }

  static String _remedyText(int safeNakshatra, bool isDhanishtaPanchami) {
    if (isDhanishtaPanchami || (safeNakshatra >= 23 && safeNakshatra <= 27)) {
      return 'பாரம்பரிய சாந்தி பரிகாரக் குறிப்பு: தனிஷ்டா பஞ்சமி அல்லது பஞ்சக நட்சத்திர அடைப்பு காலங்களில், '
          'தகுந்த வேத விற்பன்னர்களின் வழிகாட்டுதலுடன் ருத்ர சாந்தி, நவகிரக சாந்தி, எம தீபம், தான தர்மங்கள் (எள், வஸ்திரம், தீபம், அன்னதானம்) '
          'மற்றும் குலதெய்வ வழிபாடு மேற்கொள்ளப்படுவது நலம் பயக்கும் எனப் பாரம்பரிய நூல்கள் கூறுகின்றன. '
          '(குறிப்பு: இது சாஸ்திரங்களின் பொதுவான தகவல் குறிப்பே தவிர, எவ்வித உத்திரவாதமோ அல்லது மருத்துவ/சட்ட ஆலோசனையோ அல்ல).';
    }

    if (safeNakshatra == 4 || safeNakshatra == 3 || safeNakshatra == 12 ||
        safeNakshatra == 5 || safeNakshatra == 14 || safeNakshatra == 7 ||
        safeNakshatra == 16 || safeNakshatra == 21) {
      return 'பாரம்பரிய சாந்தி பரிகாரக் குறிப்பு: இந்த அடைப்பு நட்சத்திர காலத்தில் தோஷ நிவர்த்திக்காக வீடு சுத்தி, '
          'தினசரி தீப வழிபாடு, சிவபெருமானுக்கு அர்ச்சனை மற்றும் எளிய தானங்கள் செய்வது உசிதம் எனக் கூறப்படுகிறது. '
          '(குறிப்பு: இது சாஸ்திரங்களின் பொதுவான தகவல் குறிப்பே தவிர, எவ்வித உத்திரவாதமோ அல்லது மருத்துவ/சட்ட ஆலோசனையோ அல்ல).';
    }

    return 'பொதுவான குறிப்பு: இந்த நட்சத்திரத்திற்கு விசேஷ அடைப்பு தோஷங்கள் ஏதுமில்லை. வழக்கமான மங்களகரமான வழிபாடுகளைத் தொடரலாம்.';
  }

  // ===============================================================
  // ASTRONOMICAL FALLBACK MATHEMATICS
  // ===============================================================

  static double _julianDay(DateTime dt) {
    final utc = dt.toUtc();
    int y = utc.year;
    int m = utc.month;
    final d = utc.day + (utc.hour + utc.minute / 60.0 + utc.second / 3600.0) / 24.0;

    if (m <= 2) {
      y -= 1;
      m += 12;
    }

    final a = (y / 100).floor();
    final b = 2 - a + (a / 4).floor();

    return (365.25 * (y + 4716)).floor() + (30.6001 * (m + 1)).floor() + d + b - 1524.5;
  }

  static double _sunLongitude(double jd) {
    final n = jd - 2451545.0;
    final L = _normalize360(280.460 + 0.9856474 * n);
    final g = _degToRad(_normalize360(357.528 + 0.9856003 * n));
    final lambda = L + 1.915 * math.sin(g) + 0.020 * math.sin(2 * g);
    return _normalize360(lambda);
  }

  static double _moonLongitude(double jd) {
    final d = jd - 2451543.5;
    final N = _normalize360(125.1228 - 0.0529538083 * d);
    const i = 5.1454;
    final w = _normalize360(318.0634 + 0.1643573223 * d);
    const a = 60.2666;
    const e = 0.054900;
    final M = _normalize360(115.3654 + 13.0649929509 * d);
    final E = M + _radToDeg(e * math.sin(_degToRad(M)) * (1 + e * math.cos(_degToRad(M))));

    final x = a * (math.cos(_degToRad(E)) - e);
    final y = a * math.sqrt(1 - e * e) * math.sin(_degToRad(E));
    final r = math.sqrt(x * x + y * y);
    final v = _radToDeg(math.atan2(y, x));

    final xeclip = r * (math.cos(_degToRad(N)) * math.cos(_degToRad(v + w)) -
        math.sin(_degToRad(N)) * math.sin(_degToRad(v + w)) * math.cos(_degToRad(i)));
    final yeclip = r * (math.sin(_degToRad(N)) * math.cos(_degToRad(v + w)) +
        math.cos(_degToRad(N)) * math.sin(_degToRad(v + w)) * math.cos(_degToRad(i)));

    final longitude = _radToDeg(math.atan2(yeclip, xeclip));
    return _normalize360(longitude);
  }

  static double _normalize360(double deg) {
    double result = deg % 360.0;
    if (result < 0) result += 360.0;
    return result;
  }

  static double _degToRad(double deg) => deg * (math.pi / 180.0);
  static double _radToDeg(double rad) => rad * (180.0 / math.pi);
}
