import 'kp_birth_data.dart';
import 'kp_cusp.dart';
import 'kp_dasha.dart';
import 'kp_planet_position.dart';
import 'kp_ruling_planet.dart';
import 'kp_significator.dart';

/// Complete result container for KP Method Model 1
class KPMethodModel1Result {
  final KPBirthData birthData;
  final double kpAyanamsa;
  final List<KPPlanetPosition> planets;
  final List<KPCusp> cusps;
  final KPRulingPlanets rulingPlanets;
  final List<KPPlanetSignificator> planetSignificators;
  final List<KPHouseSignificator> houseSignificators;
  final KPDashaHierarchy dashaHierarchy;
  final bool isEngineAvailable;
  final String? errorMessage;

  const KPMethodModel1Result({
    required this.birthData,
    required this.kpAyanamsa,
    required this.planets,
    required this.cusps,
    required this.rulingPlanets,
    required this.planetSignificators,
    required this.houseSignificators,
    required this.dashaHierarchy,
    this.isEngineAvailable = true,
    this.errorMessage,
  });

  /// Factory for when the astronomy engine is unavailable or calculation fails
  factory KPMethodModel1Result.unavailable({
    required KPBirthData birthData,
    String? message,
  }) {
    return KPMethodModel1Result(
      birthData: birthData,
      kpAyanamsa: 0.0,
      planets: const [],
      cusps: const [],
      rulingPlanets: KPRulingPlanets.empty(),
      planetSignificators: const [],
      houseSignificators: const [],
      dashaHierarchy: KPDashaHierarchy(
        birthBalance: KPBirthDashaBalance(
          planet: '---',
          years: 0,
          months: 0,
          days: 0,
          startDate: DateTime.now(),
          endDate: DateTime.now(),
        ),
        mahadashas: const [],
      ),
      isEngineAvailable: false,
      errorMessage: message ??
          'KP Calculation Engine Unavailable\n\nConnect the supported astronomical ephemeris engine to calculate accurate KP planetary positions and cusps.',
    );
  }
}
