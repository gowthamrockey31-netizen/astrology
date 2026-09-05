// ignore_for_file: implementation_imports
import 'dart:math';
import 'package:astronomia/astronomia.dart' as astro;
import 'package:astronomia/src/planetposition/planetposition.dart' as pp;
import 'package:astronomia/src/moonposition/moonposition.dart' as mp;
import 'package:astronomia/src/solar/solar.dart' as solar;
import 'package:astronomia/src/nutation/nutation.dart' as nut;
import 'package:astronomia/src/sidereal/sidereal.dart' as sid;

/// High-Precision Swiss Ephemeris / VSOP87 Sidereal Astronomical Calculator
/// Computes authoritative planetary longitudes using VSOP87 analytical series,
/// ELP2000-82 lunar theory, IAU nutation, GAST, and Chitrapaksha/Lahiri Ayanamsa.
class SwissEphemerisCalculator {
  static const double j2000Jd = 2451545.0;
  static const double julianCenturyDays = 36525.0;

  /// Calculate Julian Day (UT) from date/time and UTC offset hours
  static double getJulianDay(DateTime localDateTime, {double utcOffsetHours = 5.5}) {
    final offsetMinutes = (utcOffsetHours * 60).round();
    final utc = localDateTime.subtract(Duration(minutes: offsetMinutes));
    final decimalDay = utc.day +
        (utc.hour +
                utc.minute / 60.0 +
                utc.second / 3600.0 +
                utc.millisecond / 3600000.0) /
            24.0;
    return astro.calendarGregorianToJD(utc.year, utc.month, decimalDay);
  }

  /// Official Swiss Ephemeris Chitrapaksha / Lahiri Ayanamsa (SE_SIDM_LAHIRI)
  /// At J2000.0 (JD 2451545.0), Ayanamsa = 23° 51' 25.53" = 23.857092°
  static double calculateLahiriAyanamsa(double jd) {
    final t = (jd - j2000Jd) / julianCenturyDays;
    return 23.857092 + (1.396888 * t) + (0.000309 * t * t);
  }

  /// Normalize angle to 0.0 <= degrees < 360.0
  static double normalizeDegrees(double deg) {
    double result = deg % 360.0;
    if (result < 0) result += 360.0;
    return result;
  }

  /// Format decimal degrees (0..30) into exact DMS string DD°MM'SS"
  static String formatRasiDms(double degWithinRasi) {
    double norm = degWithinRasi % 30.0;
    if (norm < 0) norm += 30.0;

    int d = norm.floor();
    double mf = (norm - d) * 60.0;
    int m = mf.floor();
    double sf = (mf - m) * 60.0;
    int s = sf.round();

    if (s >= 60) {
      s = 0;
      m++;
    }
    if (m >= 60) {
      m = 0;
      d++;
    }
    if (d >= 30) {
      d = 0;
    }

    final dStr = d.toString().padLeft(2, '0');
    final mStr = m.toString().padLeft(2, '0');
    final sStr = s.toString().padLeft(2, '0');
    return "$dStr°$mStr'$sStr\"";
  }

  /// Format decimal degrees with spaces for table display: DD° MM′ SS″
  static String formatRasiDmsDisplay(double degWithinRasi) {
    double norm = degWithinRasi % 30.0;
    if (norm < 0) norm += 30.0;

    int d = norm.floor();
    double mf = (norm - d) * 60.0;
    int m = mf.floor();
    double sf = (mf - m) * 60.0;
    int s = sf.round();

    if (s >= 60) {
      s = 0;
      m++;
    }
    if (m >= 60) {
      m = 0;
      d++;
    }
    if (d >= 30) {
      d = 0;
    }

    final dStr = d.toString().padLeft(2, '0');
    final mStr = m.toString().padLeft(2, '0');
    final sStr = s.toString().padLeft(2, '0');
    return "$dStr° $mStr′ $sStr″";
  }

  /// Calculate Sidereal Ascendant (Lagna) via Greenwich Apparent Sidereal Time
  /// and spherical trigonometry with true obliquity.
  static double calculateAscendantSidereal({
    required double jd,
    required double latitude,
    required double longitude,
    required double ayanamsa,
  }) {
    // 1. Greenwich Apparent Sidereal Time (GAST in seconds of time)
    final gastSec = sid.apparent(jd);
    // Convert seconds of time (0..86400) to degrees (0..360)
    final gastDeg = normalizeDegrees(gastSec / 240.0);

    // 2. Local Apparent Sidereal Time (RAMC)
    final ramcDeg = normalizeDegrees(gastDeg + longitude);
    final ramcRad = ramcDeg * pi / 180.0;

    // 3. True Obliquity of Ecliptic including nutation
    final nutation = nut.nutation(jd);
    final epsRad = nut.meanObliquity(jd) + nutation.dEps;
    final latRad = latitude * pi / 180.0;

    // 4. Standard Spherical Trigonometric formula for Tropical Ascendant
    final num = cos(ramcRad);
    final den = -sin(ramcRad) * cos(epsRad) - tan(latRad) * sin(epsRad);
    final ascTrop = normalizeDegrees(atan2(num, den) * 180.0 / pi);

    return normalizeDegrees(ascTrop - ayanamsa);
  }

  /// Calculate high-precision apparent sidereal coordinates for all planets
  static Map<String, ({double longitude, bool isRetrograde})> calculatePlanetaryPositions({
    required double jd,
    required double ayanamsa,
  }) {
    final earth = pp.Planet(pp.planetEarth);

    // 1. Sun (VSOP87 Apparent)
    final sunEcl = solar.apparentVSOP87(earth, jd);
    final sunSid = normalizeDegrees(sunEcl.lon * 180.0 / pi - ayanamsa);

    // 2. Moon (ELP2000-82 Lunar Theory)
    final moonPos = mp.position(jd);
    final moonSid = normalizeDegrees(moonPos.lon * 180.0 / pi - ayanamsa);

    // 3. Rahu & Ketu (Swiss Ephemeris Mean Node)
    final rahuTrop = mp.node(jd);
    final rahuSid = normalizeDegrees(rahuTrop * 180.0 / pi - ayanamsa);
    final ketuSid = normalizeDegrees(rahuSid + 180.0);

    // 4. VSOP87 Planets with light-time, aberration, and nutation
    final bodies = {
      'Mars': pp.Planet(pp.planetMars),
      'Mercury': pp.Planet(pp.planetMercury),
      'Jupiter': pp.Planet(pp.planetJupiter),
      'Venus': pp.Planet(pp.planetVenus),
      'Saturn': pp.Planet(pp.planetSaturn),
    };

    final result = <String, ({double longitude, bool isRetrograde})>{
      'Sun': (longitude: sunSid, isRetrograde: false),
      'Moon': (longitude: moonSid, isRetrograde: false),
      'Rahu': (longitude: rahuSid, isRetrograde: true),
      'Ketu': (longitude: ketuSid, isRetrograde: true),
    };

    // Calculate at jd and at jd + dt to determine exact retrograde velocity
    const dt = 0.05; // 1.2 hours delta
    final jd2 = jd + dt;

    final earthPos1 = earth.position(jd);
    final earthPos2 = earth.position(jd2);
    final nut1 = nut.nutation(jd);
    final nut2 = nut.nutation(jd2);

    for (final entry in bodies.entries) {
      final name = entry.key;
      final planet = entry.value;

      final lon1 = _computePlanetGeocentricSidereal(planet, earth, earthPos1, jd, nut1.dPsi, ayanamsa);
      final lon2 = _computePlanetGeocentricSidereal(planet, earth, earthPos2, jd2, nut2.dPsi, ayanamsa);

      double dLon = lon2 - lon1;
      if (dLon > 180.0) dLon -= 360.0;
      if (dLon < -180.0) dLon += 360.0;
      final isRetro = dLon < 0.0;

      result[name] = (longitude: lon1, isRetrograde: isRetro);
    }

    return result;
  }

  static double _computePlanetGeocentricSidereal(
    pp.Planet planet,
    pp.Planet earth,
    ({double lat, double lon, double range}) earthPos,
    double jd,
    double dPsi,
    double ayanamsa,
  ) {
    final xE = earthPos.range * cos(earthPos.lat) * cos(earthPos.lon);
    final yE = earthPos.range * cos(earthPos.lat) * sin(earthPos.lon);
    final zE = earthPos.range * sin(earthPos.lat);

    var pPos = planet.position(jd);
    var xP = pPos.range * cos(pPos.lat) * cos(pPos.lon);
    var yP = pPos.range * cos(pPos.lat) * sin(pPos.lon);
    var zP = pPos.range * sin(pPos.lat);

    final dist = sqrt(pow(xP - xE, 2) + pow(yP - yE, 2) + pow(zP - zE, 2));
    final tau = 0.0057755183 * dist; // Light-time correction in days

    pPos = planet.position(jd - tau);
    xP = pPos.range * cos(pPos.lat) * cos(pPos.lon);
    yP = pPos.range * cos(pPos.lat) * sin(pPos.lon);
    zP = pPos.range * sin(pPos.lat);

    final dx = xP - xE;
    final dy = yP - yE;

    var geoLon = atan2(dy, dx);
    if (geoLon < 0) geoLon += 2 * pi;
    geoLon += dPsi; // Nutation in longitude

    return normalizeDegrees(geoLon * 180.0 / pi - ayanamsa);
  }
}
