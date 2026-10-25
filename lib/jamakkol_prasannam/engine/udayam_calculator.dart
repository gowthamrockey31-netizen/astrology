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

  /// Calculates Udayam Rasi Index using authentic Jamakkol day/night proportional movement:
  /// - Daytime: 360° completed between sunrise and sunset
  /// - Nighttime: 360° completed between sunset and next sunrise
  static int calculateUdayamRasiIndex({
    double? sunLongitude,
    int? sunRasi,
    required DateTime consultationTime,
    required DateTime sunriseTime,
    DateTime? sunsetTime,
  }) {
    final sunset = sunsetTime ?? sunriseTime.add(const Duration(hours: 12));
    final bool isDay = !consultationTime.isBefore(sunriseTime) && consultationTime.isBefore(sunset);

    double elapsedMinutes;
    if (isDay) {
      elapsedMinutes = consultationTime.difference(sunriseTime).inSeconds / 60.0;
    } else {
      if (consultationTime.isBefore(sunriseTime)) {
        final yesterdaySunset = sunset.subtract(const Duration(days: 1));
        elapsedMinutes = consultationTime.difference(yesterdaySunset).inSeconds / 60.0;
      } else {
        elapsedMinutes = consultationTime.difference(sunset).inSeconds / 60.0;
      }
    }

    elapsedMinutes = elapsedMinutes.clamp(0.0, 720.0);

    final double baseLon = sunLongitude ?? ((sunRasi ?? 0) * 30.0);
    final double udayamLon = normalize(baseLon + (elapsedMinutes * 0.5));
    return (udayamLon / 30.0).floor() % 12;
  }

  /// Calculates Udayam (உதயம்) for a given query time, location, sunrise, and sunset
  static JamakkolSpecialPoint calculateUdayam({
    required DateTime queryDateTime,
    required JamakkolLocation location,
    required DateTime effectiveSunrise,
    DateTime? effectiveSunset,
    required double sunLongitude,
  }) {
    final sunset = effectiveSunset ?? effectiveSunrise.add(const Duration(hours: 12));
    final bool isDay = !queryDateTime.isBefore(effectiveSunrise) && queryDateTime.isBefore(sunset);

    double elapsedMinutes;
    DateTime anchorTime;

    if (isDay) {
      elapsedMinutes = queryDateTime.difference(effectiveSunrise).inSeconds / 60.0;
      anchorTime = effectiveSunrise;
    } else {
      if (queryDateTime.isBefore(effectiveSunrise)) {
        final yesterdaySunset = sunset.subtract(const Duration(days: 1));
        elapsedMinutes = queryDateTime.difference(yesterdaySunset).inSeconds / 60.0;
        anchorTime = yesterdaySunset;
      } else {
        elapsedMinutes = queryDateTime.difference(sunset).inSeconds / 60.0;
        anchorTime = sunset;
      }
    }

    elapsedMinutes = elapsedMinutes.clamp(0.0, 720.0);

    // Calculate exact Sun longitude at anchor (sunrise/sunset)
    double sunAnchorLon = sunLongitude;
    try {
      final jd = SwissEphemerisCalculator.getJulianDay(anchorTime, utcOffsetHours: location.timezone);
      final ayanamsa = SwissEphemerisCalculator.calculateLahiriAyanamsa(jd);
      final positions = SwissEphemerisCalculator.calculatePlanetaryPositions(jd: jd, ayanamsa: ayanamsa);
      sunAnchorLon = positions['Sun']!.longitude;
    } catch (_) {
      sunAnchorLon = sunLongitude;
    }

    // In Jamakkol Prasannam, Udayam moves uniformly at 0.5° per minute (30° / 60 min, exactly 1 sign per hour)
    const double speed = 0.5;
    final double udayamLon = normalize(sunAnchorLon + (elapsedMinutes * speed));
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
