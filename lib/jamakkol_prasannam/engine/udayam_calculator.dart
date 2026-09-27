import '../../services/astrology_calculator.dart';
import '../../services/swiss_ephemeris_calculator.dart';
import '../models/jamakkol_models.dart';
import '../models/jamakkol_planet_models.dart';

/// Calculation engine for Udayam (உதயம்)
/// In Jamakkol Prasannam, Udayam represents the querent / commencement of event.
class UdayamCalculator {
  /// Normalize degrees strictly to [0.0, 360.0)
  static double normalize(double deg) {
    double n = deg % 360.0;
    if (n < 0) n += 360.0;
    return n;
  }

  /// Calculates Udayam (உதயம்) for a given query time, location, and sunrise
  static JamakkolSpecialPoint calculateUdayam({
    required DateTime queryDateTime,
    required JamakkolLocation location,
    required DateTime effectiveSunrise,
    required double sunLongitude,
  }) {
    // 1. In traditional South Indian Jamakkol Prasannam:
    // At sunrise, Udayam aligns with the Sun's position/sign.
    // As time advances from Sunrise, Udayam rotates through the zodiac:
    // Classical rate: 30° per hour (0.5° per minute = 1 Rasi per Jamam duration / hour)
    final double curMinutes = queryDateTime.hour * 60.0 + queryDateTime.minute + (queryDateTime.second / 60.0);
    final double sunriseMinutes = effectiveSunrise.hour * 60.0 + effectiveSunrise.minute + (effectiveSunrise.second / 60.0);
    double elapsedFromSunrise = curMinutes - sunriseMinutes;
    if (elapsedFromSunrise < 0) elapsedFromSunrise += 1440.0;

    final int sunRasiIndex = (normalize(sunLongitude) / 30.0).floor() % 12;
    final double sunSignBaseLon = sunRasiIndex * 30.0;

    // Classical Jamakkol Udayam traverses forward from Sun's sign base
    final double udayamLon = normalize(sunSignBaseLon + (elapsedFromSunrise * 0.5));
    final int rasiIdx = (udayamLon / 30.0).floor() % 12;
    final double degInRasi = udayamLon % 30.0;

    // Derived Star & Pada
    final totalMinutes = udayamLon * 60.0;
    final padaIndex = (totalMinutes / 200.0).floor().clamp(0, 107);
    final nakIdx = (padaIndex ~/ 4).clamp(0, 26);
    final pada = (padaIndex % 4) + 1;

    final formattedDms = AstrologyCalculator.formatRasiDegree(degInRasi);

    return JamakkolSpecialPoint(
      type: SpecialPointType.udayam,
      nameEn: 'Udayam',
      nameTa: 'உதயம்',
      shortCode: 'உ',
      absoluteLongitude: udayamLon,
      rasiIndex: rasiIdx,
      rasiNameTa: AstrologyCalculator.rasiNamesTa[rasiIdx],
      rasiNameEn: AstrologyCalculator.rasiNamesEn[rasiIdx],
      degreeInRasi: degInRasi,
      formattedDms: formattedDms,
      nakshatraTa: AstrologyCalculator.nakshatrasTa[nakIdx],
      nakshatraEn: AstrologyCalculator.nakshatrasEn[nakIdx],
      nakshatraIndex: nakIdx,
      pada: pada,
      houseFromUdayam: 1,
      descriptionTa: 'கேள்வி கேட்பவர் / காரியத் தொடக்கத்தைக் குறிக்கும் புள்ளி',
    );
  }

  /// Computes the exact Sidereal Lagna (Ascendant) via Swiss Ephemeris for comparative validation
  static JamakkolSpecialPoint calculateSiderealLagna({
    required DateTime queryDateTime,
    required JamakkolLocation location,
    required int udayamRasiIndex,
  }) {
    final jd = SwissEphemerisCalculator.getJulianDay(queryDateTime, utcOffsetHours: location.timezone);
    final ayanamsa = SwissEphemerisCalculator.calculateLahiriAyanamsa(jd);
    final lagnaLon = SwissEphemerisCalculator.calculateAscendantSidereal(
      jd: jd,
      latitude: location.latitude,
      longitude: location.longitude,
      ayanamsa: ayanamsa,
    );

    final int rasiIdx = (lagnaLon / 30.0).floor() % 12;
    final double degInRasi = lagnaLon % 30.0;
    final totalMinutes = lagnaLon * 60.0;
    final padaIndex = (totalMinutes / 200.0).floor().clamp(0, 107);
    final nakIdx = (padaIndex ~/ 4).clamp(0, 26);
    final pada = (padaIndex % 4) + 1;
    final int houseFromUdayam = (((rasiIdx - udayamRasiIndex) % 12 + 12) % 12) + 1;

    return JamakkolSpecialPoint(
      type: SpecialPointType.lagna,
      nameEn: 'Lagna',
      nameTa: 'லக்னம்',
      shortCode: 'லக்',
      absoluteLongitude: lagnaLon,
      rasiIndex: rasiIdx,
      rasiNameTa: AstrologyCalculator.rasiNamesTa[rasiIdx],
      rasiNameEn: AstrologyCalculator.rasiNamesEn[rasiIdx],
      degreeInRasi: degInRasi,
      formattedDms: AstrologyCalculator.formatRasiDegree(degInRasi),
      nakshatraTa: AstrologyCalculator.nakshatrasTa[nakIdx],
      nakshatraEn: AstrologyCalculator.nakshatrasEn[nakIdx],
      nakshatraIndex: nakIdx,
      pada: pada,
      houseFromUdayam: houseFromUdayam,
      descriptionTa: 'வானியல் முறைப்படி துல்லிய உதைய லக்னம்',
    );
  }
}
