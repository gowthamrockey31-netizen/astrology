import '../models/kp2_planet.dart';
import '../models/kp2_planet_position.dart';
import '../models/kp2_cusp.dart';
import '../models/kp2_ruling_planet.dart';
import 'kp2_rasi_engine.dart';
import 'kp2_sub_sub_lord_engine.dart';

/// Ruling Planets Calculation Engine for KP Method 2
class KP2RulingPlanetEngine {
  static const Map<int, KP2Planet> weekdayLords = {
    DateTime.sunday: KP2Planet.sun,
    DateTime.monday: KP2Planet.moon,
    DateTime.tuesday: KP2Planet.mars,
    DateTime.wednesday: KP2Planet.mercury,
    DateTime.thursday: KP2Planet.jupiter,
    DateTime.friday: KP2Planet.venus,
    DateTime.saturday: KP2Planet.saturn,
  };

  static KP2RulingPlanets calculate({
    required DateTime localDateTime,
    required KP2PlanetPosition moonPosition,
    required KP2Cusp ascendantCusp,
    double? moonLongitude,
    double? ascendantLongitude,
  }) {
    final dayLord = weekdayLords[localDateTime.weekday] ?? KP2Planet.sun;

    // 1. Transit Ascendant — Five Ruling Planets
    final double ascLong = ascendantLongitude ?? ascendantCusp.longitude;
    final ascSignLord = ascendantCusp.signLord;
    final ascStarLord = ascendantCusp.starLord;
    final ascSubLord = ascendantCusp.subLord;
    final ascSubSubLord = KP2SubSubLordEngine.calculateSubSubLord(ascLong);
    final ascSubSubSubLord = KP2SubSubLordEngine.calculateSubSubSubLord(ascLong);

    // 2. Transit Moon — Five Ruling Planets
    final double moonLong = moonLongitude ?? moonPosition.siderealLongitude;
    final moonSignLord = KP2RasiEngine.getRasiLord(moonPosition.rasiIndex);
    final moonStarLord = moonPosition.starLord;
    final moonSubLord = moonPosition.subLord;
    final moonSubSubLord = KP2SubSubLordEngine.calculateSubSubLord(moonLong);
    final moonSubSubSubLord = KP2SubSubLordEngine.calculateSubSubSubLord(moonLong);

    return KP2RulingPlanets(
      dayLord: dayLord,
      ascSignLord: ascSignLord,
      ascStarLord: ascStarLord,
      ascSubLord: ascSubLord,
      ascSubSubLord: ascSubSubLord,
      ascSubSubSubLord: ascSubSubSubLord,
      moonSignLord: moonSignLord,
      moonStarLord: moonStarLord,
      moonSubLord: moonSubLord,
      moonSubSubLord: moonSubSubLord,
      moonSubSubSubLord: moonSubSubSubLord,
    );
  }
}
