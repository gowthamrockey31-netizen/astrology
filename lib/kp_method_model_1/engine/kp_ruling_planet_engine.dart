import '../../services/astrology_calculator.dart';
import '../models/kp_ruling_planet.dart';
import 'kp_nakshatra_engine.dart';
import 'kp_sub_lord_engine.dart';

/// Calculation engine for KP Ruling Planets
class KPRulingPlanetEngine {
  static const Map<int, String> weekdayLords = {
    DateTime.monday: 'Moon',
    DateTime.tuesday: 'Mars',
    DateTime.wednesday: 'Mercury',
    DateTime.thursday: 'Jupiter',
    DateTime.friday: 'Venus',
    DateTime.saturday: 'Saturn',
    DateTime.sunday: 'Sun',
  };

  /// Calculate ruling planets from date/time, Moon longitude, and Ascendant longitude
  static KPRulingPlanets calculate({
    required DateTime dateTime,
    required double moonLongitude,
    required double ascendantLongitude,
  }) {
    // 1. Day Lord
    final dayLord = weekdayLords[dateTime.weekday] ?? 'Sun';

    // 2. Moon Lords
    final moonNorm = AstrologyCalculator.normalizeDegrees(moonLongitude);
    final moonRasiIdx = (moonNorm / 30.0).floor().clamp(0, 11);
    final moonSignLord = KPNakshatraEngine.signLordsEn[moonRasiIdx];
    final moonNak = KPNakshatraEngine.calculate(moonNorm);
    final moonStarLord = moonNak.lordEn;
    final moonSub = KPSubLordEngine.calculate(moonNorm);
    final moonSubLord = moonSub.subLordEn;

    // 3. Ascendant Lords
    final ascNorm = AstrologyCalculator.normalizeDegrees(ascendantLongitude);
    final ascRasiIdx = (ascNorm / 30.0).floor().clamp(0, 11);
    final ascSignLord = KPNakshatraEngine.signLordsEn[ascRasiIdx];
    final ascNak = KPNakshatraEngine.calculate(ascNorm);
    final ascStarLord = ascNak.lordEn;
    final ascSub = KPSubLordEngine.calculate(ascNorm);
    final ascSubLord = ascSub.subLordEn;

    // 4. Unique ordered ruling planets
    final rawList = [
      dayLord,
      moonSignLord,
      moonStarLord,
      moonSubLord,
      ascSignLord,
      ascStarLord,
      ascSubLord,
    ];

    final uniqueList = <String>[];
    for (final p in rawList) {
      if (!uniqueList.contains(p)) {
        uniqueList.add(p);
      }
    }

    return KPRulingPlanets(
      dayLord: dayLord,
      moonSignLord: moonSignLord,
      moonStarLord: moonStarLord,
      moonSubLord: moonSubLord,
      ascendantSignLord: ascSignLord,
      ascendantStarLord: ascStarLord,
      ascendantSubLord: ascSubLord,
      uniqueRulingPlanets: uniqueList,
    );
  }
}
