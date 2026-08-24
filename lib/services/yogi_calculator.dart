import '../models/yogi_calculation_result.dart';
import 'astrology_calculator.dart';

/// Accurate Classical Yogi, Ava Yogi, and Anu Yogi calculation service
class YogiCalculator {
  /// Calculate Yogi details from Sun and Moon Sidereal Longitudes
  static YogiCalculationResult calculateYogi({
    required double sunLongitude,
    required double moonLongitude,
  }) {
    // Standard Classical Formula: Yogi Point = (Sun Longitude + Moon Longitude + 93° 20') % 360°
    // 93° 20' = 93.33333333° (Point of Pushya Nakshatra)
    const double pushyaOffset = 93.33333333333333;
    final double yogiPoint = (sunLongitude + moonLongitude + pushyaOffset) % 360.0;
    final double normYogi = yogiPoint < 0 ? yogiPoint + 360.0 : yogiPoint;

    final int yogiRasiIdx = (normYogi / 30.0).floor() % 12;
    final double yogiDegInRasi = normYogi % 30.0;
    final int yogiDeg = yogiDegInRasi.floor();
    final int yogiMin = ((yogiDegInRasi - yogiDeg) * 60).floor();
    final int yogiSec = ((((yogiDegInRasi - yogiDeg) * 60) - yogiMin) * 60).round();
    final String yogiDegFormatted =
        "${yogiDeg.toString().padLeft(2, '0')}°${yogiMin.toString().padLeft(2, '0')}'${yogiSec.toString().padLeft(2, '0')}\"";

    // Nakshatra of Yogi point (27 Nakshatras = 13°20' each)
    const double nakSpan = 360.0 / 27.0; // 13.333333°
    const double padaSpan = nakSpan / 4.0; // 3.333333°
    final int yogiNakIdx = (normYogi / nakSpan).floor() % 27;
    final double yogiNakOffset = normYogi - (yogiNakIdx * nakSpan);
    final int yogiPada = ((yogiNakOffset / padaSpan).floor()).clamp(0, 3) + 1;

    final String yogiNakTa = AstrologyCalculator.nakshatrasTa[yogiNakIdx];
    final String yogiNakEn = AstrologyCalculator.nakshatrasEn[yogiNakIdx];

    // Yogi Planet (Lord of the Yogi Nakshatra)
    final int yogiLordIdx = yogiNakIdx % 9;
    final String yogiPlanetTa = AstrologyCalculator.planetLordsTa[yogiLordIdx];
    final String yogiPlanetEn = AstrologyCalculator.planetLords[yogiLordIdx];

    // Ava Yogi Point = (Yogi Point + 186° 40') % 360° (6th Nakshatra from Yogi Nakshatra)
    const double avaYogiOffset = 186.66666666666666;
    final double avaYogiPoint = (normYogi + avaYogiOffset) % 360.0;
    final double normAvaYogi = avaYogiPoint < 0 ? avaYogiPoint + 360.0 : avaYogiPoint;

    final int avaYogiRasiIdx = (normAvaYogi / 30.0).floor() % 12;
    final int avaYogiNakIdx = (normAvaYogi / nakSpan).floor() % 27;
    final String avaYogiNakTa = AstrologyCalculator.nakshatrasTa[avaYogiNakIdx];

    final int avaYogiLordIdx = (yogiLordIdx + 5) % 9; // 6th in Vimshottari dasha cycle
    final String avaYogiPlanetTa = AstrologyCalculator.planetLordsTa[avaYogiLordIdx];
    final String avaYogiPlanetEn = AstrologyCalculator.planetLords[avaYogiLordIdx];

    // Anu Yogi Planet (Duplicate Yogi Lord helper in Vimshottari order)
    final int anuYogiLordIdx = (yogiLordIdx + 3) % 9;
    final String anuYogiPlanetTa = AstrologyCalculator.planetLordsTa[anuYogiLordIdx];
    final int anuYogiNakIdx = (yogiNakIdx + 9) % 27;
    final String anuYogiNakTa = AstrologyCalculator.nakshatrasTa[anuYogiNakIdx];

    return YogiCalculationResult(
      sunLongitude: sunLongitude,
      moonLongitude: moonLongitude,
      pushyaOffset: pushyaOffset,
      yogiPointLongitude: normYogi,
      yogiRasiTa: AstrologyCalculator.rasiNamesTa[yogiRasiIdx],
      yogiRasiEn: AstrologyCalculator.rasiNamesEn[yogiRasiIdx],
      yogiRasiIndex: yogiRasiIdx,
      yogiDegreeFormatted: yogiDegFormatted,
      yogiNakshatraTa: yogiNakTa,
      yogiNakshatraEn: yogiNakEn,
      yogiPada: yogiPada,
      yogiPlanetTa: yogiPlanetTa,
      yogiPlanetEn: yogiPlanetEn,
      avaYogiPointLongitude: normAvaYogi,
      avaYogiRasiTa: AstrologyCalculator.rasiNamesTa[avaYogiRasiIdx],
      avaYogiNakshatraTa: avaYogiNakTa,
      avaYogiPlanetTa: avaYogiPlanetTa,
      avaYogiPlanetEn: avaYogiPlanetEn,
      anuYogiNakshatraTa: anuYogiNakTa,
      anuYogiPlanetTa: anuYogiPlanetTa,
      yogiDescription:
          'யோகி கிரகம் ($yogiPlanetTa): ஜாதகருக்கு அதிர்ஷ்டம், வளர்ச்சி மற்றும் செல்வத்தை வழங்கும் தலைமை சுப காரகர்.',
      avaYogiDescription:
          'அவயோகி கிரகம் ($avaYogiPlanetTa): ஜாதகருக்கு சில தடைகள் மற்றும் எச்சரிக்கை தேவைப்படும் சூழல்களை குறிக்கும் கிரகம்.',
    );
  }
}
