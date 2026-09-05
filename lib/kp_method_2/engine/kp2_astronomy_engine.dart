import '../../services/swiss_ephemeris_calculator.dart';
import '../models/kp2_birth_data.dart';
import '../models/kp2_planet.dart';
import '../models/kp2_planet_position.dart';
import '../models/kp2_cusp.dart';
import 'kp2_rasi_engine.dart';
import 'kp2_nakshatra_engine.dart';
import 'kp2_sub_lord_engine.dart';
import 'kp2_sub_sub_lord_engine.dart';

/// Astronomical calculation engine for KP Method 2
class KP2AstronomyEngine {
  /// Calculate Julian Day (UT) from birth data
  static double getJulianDay(KP2BirthData data) {
    return SwissEphemerisCalculator.getJulianDay(
      data.localDateTime,
      utcOffsetHours: data.timezone,
    );
  }

  /// Official Swiss Ephemeris Chitrapaksha / Lahiri Ayanamsa
  static double getLahiriAyanamsa(double jd) {
    return SwissEphemerisCalculator.calculateLahiriAyanamsa(jd);
  }

  /// Format Ayanamsa into DD° MM' SS"
  static String formatAyanamsa(double ayanamsa) {
    return SwissEphemerisCalculator.formatRasiDmsDisplay(ayanamsa);
  }

  /// Calculate all 9 planets positions
  static List<KP2PlanetPosition> calculatePlanets({
    required KP2BirthData birthData,
    required double jd,
    required double ayanamsa,
    required List<KP2Cusp> cusps,
  }) {
    final ephem = SwissEphemerisCalculator.calculatePlanetaryPositions(
      jd: jd,
      ayanamsa: ayanamsa,
    );

    final List<KP2PlanetPosition> positions = [];

    final planetOrder = [
      KP2Planet.sun,
      KP2Planet.moon,
      KP2Planet.mars,
      KP2Planet.mercury,
      KP2Planet.jupiter,
      KP2Planet.venus,
      KP2Planet.saturn,
      KP2Planet.rahu,
      KP2Planet.ketu,
    ];

    for (final planet in planetOrder) {
      final info = ephem[planet.nameEn]!;
      final siderealLong = KP2RasiEngine.normalizeDegrees(info.longitude);
      final tropicalLong = KP2RasiEngine.normalizeDegrees(siderealLong + ayanamsa);

      final rasiIdx = KP2RasiEngine.getRasiIndex(siderealLong);
      final rasiNameTa = KP2RasiEngine.getRasiNameTa(rasiIdx);
      final rasiNameEn = KP2RasiEngine.getRasiNameEn(rasiIdx);
      final degInRasi = KP2RasiEngine.getDegreeInRasi(siderealLong);
      final formattedDms = KP2RasiEngine.formatDms(degInRasi);

      final nakIdx = KP2NakshatraEngine.getNakshatraIndex(siderealLong);
      final nakNameTa = KP2NakshatraEngine.getNakshatraNameTa(nakIdx);
      final pada = KP2NakshatraEngine.getPada(siderealLong);

      final starLord = KP2NakshatraEngine.getStarLord(nakIdx);
      final subLord = KP2SubLordEngine.calculateSubLord(siderealLong);
      final subSubLord = KP2SubSubLordEngine.calculateSubSubLord(siderealLong);

      final occupiedHouse = _determineOccupiedHouse(siderealLong, cusps);

      positions.add(
        KP2PlanetPosition(
          planet: planet,
          tropicalLongitude: tropicalLong,
          siderealLongitude: siderealLong,
          rasiIndex: rasiIdx,
          rasiNameTa: rasiNameTa,
          rasiNameEn: rasiNameEn,
          degreeInRasi: degInRasi,
          formattedDms: formattedDms,
          nakshatraIndex: nakIdx,
          nakshatraNameTa: nakNameTa,
          pada: pada,
          starLord: starLord,
          subLord: subLord,
          subSubLord: subSubLord,
          occupiedHouse: occupiedHouse,
          isRetrograde: info.isRetrograde,
        ),
      );
    }

    return positions;
  }

  /// Determines which house (1..12) a planet occupies based on cusp boundaries
  static int _determineOccupiedHouse(double planetLong, List<KP2Cusp> cusps) {
    if (cusps.length < 12) return 1;

    for (int i = 0; i < 12; i++) {
      final currentCusp = cusps[i].longitude;
      final nextCusp = cusps[(i + 1) % 12].longitude;

      if (_isBetween(planetLong, currentCusp, nextCusp)) {
        return cusps[i].house;
      }
    }

    return 1;
  }

  static bool _isBetween(double val, double start, double end) {
    val = KP2RasiEngine.normalizeDegrees(val);
    start = KP2RasiEngine.normalizeDegrees(start);
    end = KP2RasiEngine.normalizeDegrees(end);

    if (start < end) {
      return val >= start && val < end;
    } else {
      // Wraps around 0° (e.g. Pisces to Aries)
      return val >= start || val < end;
    }
  }
}
