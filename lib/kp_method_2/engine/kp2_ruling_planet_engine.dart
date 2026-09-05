import '../models/kp2_planet.dart';
import '../models/kp2_planet_position.dart';
import '../models/kp2_cusp.dart';
import '../models/kp2_ruling_planet.dart';
import 'kp2_rasi_engine.dart';

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
  }) {
    final dayLord = weekdayLords[localDateTime.weekday] ?? KP2Planet.sun;
    final moonSignLord = KP2RasiEngine.getRasiLord(moonPosition.rasiIndex);
    final moonStarLord = moonPosition.starLord;
    final moonSubLord = moonPosition.subLord;

    final ascSignLord = ascendantCusp.signLord;
    final ascStarLord = ascendantCusp.starLord;
    final ascSubLord = ascendantCusp.subLord;

    return KP2RulingPlanets(
      dayLord: dayLord,
      moonSignLord: moonSignLord,
      moonStarLord: moonStarLord,
      moonSubLord: moonSubLord,
      ascSignLord: ascSignLord,
      ascStarLord: ascStarLord,
      ascSubLord: ascSubLord,
    );
  }
}
