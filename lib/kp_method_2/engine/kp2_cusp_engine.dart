import 'dart:math';
import '../models/kp2_birth_data.dart';
import '../models/kp2_cusp.dart';
import 'kp2_rasi_engine.dart';
import 'kp2_nakshatra_engine.dart';
import 'kp2_sub_lord_engine.dart';
import 'kp2_sub_sub_lord_engine.dart';

/// Placidus Cusp Calculation Engine for KP Method 2
class KP2CuspEngine {
  /// Calculate the 12 Placidus House Cusps converted to Sidereal with Lahiri Ayanamsa
  static List<KP2Cusp> calculateCusps({
    required KP2BirthData birthData,
    required double jd,
    required double ayanamsa,
  }) {
    final rawLongitudes = _calculatePlacidusCusps(
      jd: jd,
      latitude: birthData.latitude,
      longitude: birthData.longitude,
      ayanamsa: ayanamsa,
    );

    final List<KP2Cusp> cusps = [];

    for (int i = 0; i < 12; i++) {
      final double cLong = KP2RasiEngine.normalizeDegrees(rawLongitudes[i]);
      final int rasiIdx = KP2RasiEngine.getRasiIndex(cLong);
      final double degInRasi = KP2RasiEngine.getDegreeInRasi(cLong);
      final String formattedDms = KP2RasiEngine.formatDms(degInRasi);

      final int nakIdx = KP2NakshatraEngine.getNakshatraIndex(cLong);
      final String nakNameTa = KP2NakshatraEngine.getNakshatraNameTa(nakIdx);
      final int pada = KP2NakshatraEngine.getPada(cLong);

      final signLord = KP2RasiEngine.getRasiLord(rasiIdx);
      final starLord = KP2NakshatraEngine.getStarLord(nakIdx);
      final subLord = KP2SubLordEngine.calculateSubLord(cLong);
      final subSubLord = KP2SubSubLordEngine.calculateSubSubLord(cLong);

      cusps.add(
        KP2Cusp(
          house: i + 1,
          longitude: cLong,
          rasiIndex: rasiIdx,
          rasiNameTa: KP2RasiEngine.getRasiNameTa(rasiIdx),
          rasiNameEn: KP2RasiEngine.getRasiNameEn(rasiIdx),
          degreeInRasi: degInRasi,
          formattedDms: formattedDms,
          nakshatraIndex: nakIdx,
          nakshatraNameTa: nakNameTa,
          pada: pada,
          signLord: signLord,
          starLord: starLord,
          subLord: subLord,
          subSubLord: subSubLord,
        ),
      );
    }

    return cusps;
  }

  /// Calculates Placidus house cusps converted to sidereal using Lahiri Ayanamsa
  static List<double> _calculatePlacidusCusps({
    required double jd,
    required double latitude,
    required double longitude,
    required double ayanamsa,
  }) {
    final t = (jd - 2451545.0) / 36525.0;
    final gmst = KP2RasiEngine.normalizeDegrees(
        280.46061837 + 360.98564736629 * (jd - 2451545.0) + 0.000387933 * t * t - (t * t * t) / 38710000.0);
    final ramc = KP2RasiEngine.normalizeDegrees(gmst + longitude);

    final epsDeg = 23.4392911 - 0.0130042 * t - 0.00000016 * t * t;
    final epsRad = epsDeg * (pi / 180.0);
    final phiRad = latitude * (pi / 180.0);
    final thetaRad = ramc * (pi / 180.0);

    // 1st Cusp (Ascendant / Lagna)
    final y1 = cos(thetaRad);
    final x1 = -sin(thetaRad) * cos(epsRad) - tan(phiRad) * sin(epsRad);
    final ascTrop = KP2RasiEngine.normalizeDegrees(atan2(y1, x1) * (180.0 / pi));

    // 10th Cusp (MC / Midheaven)
    final mcTrop = KP2RasiEngine.normalizeDegrees(atan2(sin(thetaRad), cos(thetaRad) * cos(epsRad)) * (180.0 / pi));

    final cuspsTrop = List<double>.filled(12, 0.0);
    cuspsTrop[0] = ascTrop; // 1st house
    cuspsTrop[9] = mcTrop;  // 10th house

    if (latitude.abs() < 66.0) {
      cuspsTrop[10] = _calculateIntermediatePlacidusCusp(ramc + 30.0, 1.0 / 3.0, epsRad, phiRad); // 11th
      cuspsTrop[11] = _calculateIntermediatePlacidusCusp(ramc + 60.0, 2.0 / 3.0, epsRad, phiRad); // 12th
      cuspsTrop[1] = _calculateIntermediatePlacidusCusp(ramc + 120.0, 2.0 / 3.0, epsRad, phiRad); // 2nd
      cuspsTrop[2] = _calculateIntermediatePlacidusCusp(ramc + 150.0, 1.0 / 3.0, epsRad, phiRad); // 3rd
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

    // Convert tropical cusps to Sidereal via Lahiri Ayanamsa
    return cuspsTrop.map((c) => KP2RasiEngine.normalizeDegrees(c - ayanamsa)).toList();
  }

  static double _calculateIntermediatePlacidusCusp(
      double ramcOffsetDeg, double factor, double epsRad, double phiRad) {
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
    return KP2RasiEngine.normalizeDegrees(lon * (180.0 / pi));
  }
}
