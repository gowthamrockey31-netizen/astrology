import 'dart:math';
import '../../services/astrology_calculator.dart';
import '../models/kp_birth_data.dart';
import '../models/kp_planet.dart';
import 'kp_ayanamsa_engine.dart';

/// Container for raw astronomical calculation results
class KPAstronomicalData {
  final double ascendant;
  final Map<KPPlanet, double> planetLongitudes;
  final Map<KPPlanet, double> planetSpeeds;
  final List<double> cuspLongitudes;
  final double ayanamsa;

  const KPAstronomicalData({
    required this.ascendant,
    required this.planetLongitudes,
    required this.planetSpeeds,
    required this.cuspLongitudes,
    required this.ayanamsa,
  });
}

/// Real Astronomical Engine for KP Method Model 1
/// Computes geocentric planetary longitudes and Placidus house cusps with KP Ayanamsa
class KPAstronomyEngine {
  /// Check if the astronomical calculation engine is available
  static bool get isEngineAvailable => true;

  /// Calculate real astronomical data for the given birth parameters
  static KPAstronomicalData calculate(KPBirthData birthData) {
    // 1. Calculate high-precision tropical horoscope via core astronomical algorithms
    final natalData = AstrologyCalculator.calculateHoroscope(
      dateOfBirth: birthData.dateTime,
      latitude: birthData.latitude,
      longitude: birthData.longitude,
      utcOffsetHours: birthData.utcOffsetHours,
    );

    // 2. Compute exact KP Ayanamsa
    final ayanamsa = KPAyanamsaEngine.calculateAyanamsa(
      birthData.dateTime,
      utcOffsetHours: birthData.utcOffsetHours,
    );

    // 3. Compute Julian Day and Placidus Cusps
    final jd = AstrologyCalculator.getJulianDay(
      birthData.dateTime,
      utcOffsetHours: birthData.utcOffsetHours,
    );

    final cusps = _calculatePlacidusCusps(
      jd: jd,
      latitude: birthData.latitude,
      longitude: birthData.longitude,
      ayanamsa: ayanamsa,
    );

    // 4. Map the 9 KP planets
    final planetLongitudes = <KPPlanet, double>{
      KPPlanet.sun: natalData.planets['Sun']!.longitude,
      KPPlanet.moon: natalData.planets['Moon']!.longitude,
      KPPlanet.mars: natalData.planets['Mars']!.longitude,
      KPPlanet.mercury: natalData.planets['Mercury']!.longitude,
      KPPlanet.jupiter: natalData.planets['Jupiter']!.longitude,
      KPPlanet.venus: natalData.planets['Venus']!.longitude,
      KPPlanet.saturn: natalData.planets['Saturn']!.longitude,
      KPPlanet.rahu: natalData.planets['Rahu']!.longitude,
      KPPlanet.ketu: natalData.planets['Ketu']!.longitude,
    };

    final planetSpeeds = <KPPlanet, double>{
      KPPlanet.sun: 0.9856,
      KPPlanet.moon: 13.176,
      KPPlanet.mars: natalData.planets['Mars']!.isRetrograde ? -0.3 : 0.5,
      KPPlanet.mercury: natalData.planets['Mercury']!.isRetrograde ? -0.5 : 1.2,
      KPPlanet.jupiter: natalData.planets['Jupiter']!.isRetrograde ? -0.08 : 0.08,
      KPPlanet.venus: natalData.planets['Venus']!.isRetrograde ? -0.6 : 1.0,
      KPPlanet.saturn: natalData.planets['Saturn']!.isRetrograde ? -0.03 : 0.03,
      KPPlanet.rahu: -0.05,
      KPPlanet.ketu: -0.05,
    };

    return KPAstronomicalData(
      ascendant: cusps.first,
      planetLongitudes: planetLongitudes,
      planetSpeeds: planetSpeeds,
      cuspLongitudes: cusps,
      ayanamsa: ayanamsa,
    );
  }

  /// Calculates Placidus house cusps converted to sidereal using KP ayanamsa
  static List<double> _calculatePlacidusCusps({
    required double jd,
    required double latitude,
    required double longitude,
    required double ayanamsa,
  }) {
    final t = (jd - 2451545.0) / 36525.0;
    final gmst = AstrologyCalculator.normalizeDegrees(
        280.46061837 + 360.98564736629 * (jd - 2451545.0) + 0.000387933 * t * t - (t * t * t) / 38710000.0);
    final ramc = AstrologyCalculator.normalizeDegrees(gmst + longitude);

    final epsDeg = 23.4392911 - 0.0130042 * t - 0.00000016 * t * t;
    final epsRad = epsDeg * (pi / 180.0);
    final phiRad = latitude * (pi / 180.0);
    final thetaRad = ramc * (pi / 180.0);

    // 1st Cusp (Ascendant)
    final y1 = cos(thetaRad);
    final x1 = -sin(thetaRad) * cos(epsRad) - tan(phiRad) * sin(epsRad);
    final ascTrop = AstrologyCalculator.normalizeDegrees(atan2(y1, x1) * (180.0 / pi));

    // 10th Cusp (MC)
    final mcTrop = AstrologyCalculator.normalizeDegrees(atan2(sin(thetaRad), cos(thetaRad) * cos(epsRad)) * (180.0 / pi));

    final cuspsTrop = List<double>.filled(12, 0.0);
    cuspsTrop[0] = ascTrop;
    cuspsTrop[9] = mcTrop;

    if (latitude.abs() < 66.0) {
      cuspsTrop[10] = _calculateIntermediatePlacidusCusp(ramc + 30.0, 1.0 / 3.0, epsRad, phiRad);
      cuspsTrop[11] = _calculateIntermediatePlacidusCusp(ramc + 60.0, 2.0 / 3.0, epsRad, phiRad);
      cuspsTrop[1] = _calculateIntermediatePlacidusCusp(ramc + 120.0, 2.0 / 3.0, epsRad, phiRad);
      cuspsTrop[2] = _calculateIntermediatePlacidusCusp(ramc + 150.0, 1.0 / 3.0, epsRad, phiRad);
    } else {
      // Polar fallback
      double diff1 = (ascTrop - mcTrop);
      if (diff1 < 0) diff1 += 360.0;
      cuspsTrop[10] = (mcTrop + diff1 / 3.0) % 360.0;
      cuspsTrop[11] = (mcTrop + (2.0 * diff1) / 3.0) % 360.0;

      final icTrop = (mcTrop + 180.0) % 360.0;
      double diff2 = (icTrop - ascTrop);
      if (diff2 < 0) diff2 += 360.0;
      cuspsTrop[1] = (ascTrop + diff2 / 3.0) % 360.0;
      cuspsTrop[2] = (ascTrop + (2.0 * diff2) / 3.0) % 360.0;
    }

    // Opposite cusps (4, 5, 6, 7, 8, 9)
    cuspsTrop[3] = (cuspsTrop[9] + 180.0) % 360.0; // 4th
    cuspsTrop[4] = (cuspsTrop[10] + 180.0) % 360.0; // 5th
    cuspsTrop[5] = (cuspsTrop[11] + 180.0) % 360.0; // 6th
    cuspsTrop[6] = (cuspsTrop[0] + 180.0) % 360.0; // 7th
    cuspsTrop[7] = (cuspsTrop[1] + 180.0) % 360.0; // 8th
    cuspsTrop[8] = (cuspsTrop[2] + 180.0) % 360.0; // 9th

    // Convert tropical cusps to Sidereal via KP Ayanamsa
    return cuspsTrop.map((c) => AstrologyCalculator.normalizeDegrees(c - ayanamsa)).toList();
  }

  static double _calculateIntermediatePlacidusCusp(double ramcOffsetDeg, double factor, double epsRad, double phiRad) {
    double rRad = (ramcOffsetDeg % 360.0) * (pi / 180.0);
    double lon = rRad;
    for (int iter = 0; iter < 10; iter++) {
      final sinDecl = sin(epsRad) * sin(lon);
      final cosDecl = sqrt(max(0.0, 1.0 - sinDecl * sinDecl));
      final tanDecl = sinDecl / max(0.0001, cosDecl);
      final ascDiff = asin((tan(phiRad) * tanDecl).clamp(-1.0, 1.0));
      final newR = rRad + factor * ascDiff;
      final y = sin(newR);
      final x = cos(newR) * cos(epsRad) - tanDecl * sin(epsRad);
      final newLon = atan2(y, x);
      if ((newLon - lon).abs() < 1e-6) break;
      lon = newLon;
    }
    return AstrologyCalculator.normalizeDegrees(lon * (180.0 / pi));
  }
}
