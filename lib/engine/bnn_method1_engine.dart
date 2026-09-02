import '../data/bnn_method1_karakatwa.dart';
import '../models/bnn_models.dart';
import '../models/bnn_method1_model.dart';
import 'bnn_method1_prediction_engine.dart';
import 'bnn_method1_relation_engine.dart';

/// Main Calculation Engine for BNN Method 1
/// Strictly implements:
/// - Exact Degree / DMS precision without pre-rounding
/// - Relative House: ((target - source + 12) % 12) + 1
/// - Direction Priority: 1, 5, 9 (1) -> 3, 11 (2) -> 7 (3) -> 2 (4) -> 12 (5)
/// - Degree Order ranking across all 9 planets
/// - Connection sorting by priority ascending, then longitude ascending
class BnnMethod1Engine {
  /// Standard 9 Planet Keys in BNN
  static const List<String> standardPlanetKeys = [
    'Sun',
    'Moon',
    'Mars',
    'Mercury',
    'Jupiter',
    'Venus',
    'Saturn',
    'Rahu',
    'Ketu',
  ];

  /// Normalized Longitude: 0° <= longitude < 360°
  static double normalizeLongitude(double longitude) {
    if (longitude.isNaN || longitude.isInfinite) {
      throw ArgumentError('Invalid planetary longitude: $longitude');
    }
    double norm = longitude % 360.0;
    if (norm < 0) norm += 360.0;
    return norm;
  }

  /// Exact Zodiac Sign index: 1 to 12 (1 = Mesham ... 12 = Meenam)
  static int getSign(double longitude) {
    final norm = normalizeLongitude(longitude);
    return (norm / 30.0).floor() + 1;
  }

  /// Exact Degree within Sign: 0.0 <= degree < 30.0
  static double getDegreeWithinSign(double longitude) {
    final norm = normalizeLongitude(longitude);
    return norm % 30.0;
  }

  /// Mathematical DMS decomposition without loss of precision: (degree, minute, second)
  static (int degree, int minute, double second) toDMS(double degreeWithinSign) {
    final d = degreeWithinSign.floor();
    final minuteFloat = (degreeWithinSign - d) * 60.0;
    final m = minuteFloat.floor();
    final seconds = (minuteFloat - m) * 60.0;
    return (d, m, seconds);
  }

  /// Relative House Calculation: ((target - source + 12) % 12) + 1
  /// Guaranteed result: 1 to 12
  static int calculateRelativeHouse(int sourceHouse, int targetHouse) {
    return ((targetHouse - sourceHouse + 12) % 12) + 1;
  }

  /// Assign Degree Order (1 to N) to planets based on absolute longitude ascending
  static List<BnnMethod1Planet> assignDegreeOrder(List<BnnMethod1Planet> planets) {
    final sorted = List<BnnMethod1Planet>.from(planets);
    // Sort strictly by normalized absolute longitude without loss of precision
    sorted.sort((a, b) => a.longitude.compareTo(b.longitude));

    final List<BnnMethod1Planet> ordered = [];
    for (int i = 0; i < sorted.length; i++) {
      ordered.add(sorted[i].copyWith(degreeOrder: i + 1));
    }

    // Return in original planet sequence but with assigned degreeOrder
    final Map<String, int> orderMap = {
      for (final p in ordered) p.planetKey: p.degreeOrder,
    };

    return planets.map((p) => p.copyWith(degreeOrder: orderMap[p.planetKey] ?? 0)).toList();
  }

  /// Calculate and sort connections for a single source planet
  /// Strict BNN Method 1 Sequence:
  /// Primary Sort: Direction Priority 1 (1,5,9) -> 2 (3,11) -> 3 (7) -> 4 (2) -> 5 (12)
  /// Secondary Sort: Actual longitude / degree ascending
  static List<BnnMethod1Connection> calculatePlanetConnections({
    required BnnMethod1Planet sourcePlanet,
    required List<BnnMethod1Planet> allPlanets,
  }) {
    final List<BnnMethod1Connection> connections = [];

    for (final target in allPlanets) {
      // Rule 4: Do not include the same planet as its own connection
      if (target.planetKey == sourcePlanet.planetKey) continue;

      // Relative house calculation
      final relHouse = calculateRelativeHouse(sourcePlanet.sign, target.sign);

      // Rule 5: Direction group & priority sequence
      final dirGroup = BnnMethod1DirectionGroup.fromRelativeHouse(relHouse);
      if (dirGroup == null) continue; // Only valid Method 1 direction groups

      // Rule 7: Planetary relation from centralized engine
      final relation = BnnMethod1PlanetRelationEngine.getRelation(
        sourcePlanet.planetKey,
        target.planetKey,
      );

      // Rule 8: Karakatwas (Max 10) from centralized repository
      final karakatwas = BnnMethod1KarakatwaRepository.getKarakatwas(target.planetKey);

      connections.add(BnnMethod1Connection(
        sourcePlanet: sourcePlanet,
        targetPlanet: target,
        sourceHouse: sourcePlanet.house,
        targetHouse: target.house,
        relativeHouse: relHouse,
        sourceLongitude: sourcePlanet.longitude,
        targetLongitude: target.longitude,
        sourceSign: sourcePlanet.sign,
        targetSign: target.sign,
        relation: relation,
        directionGroup: dirGroup,
        directionPriority: dirGroup.priority,
        degreeOrder: target.degreeOrder,
        karakatwas: karakatwas,
      ));
    }

    // Rule 5: Priority Sort (1 to 5), then Secondary Sort by actual longitude ascending
    connections.sort((a, b) {
      final prioComp = a.directionPriority.compareTo(b.directionPriority);
      if (prioComp != 0) return prioComp;
      return a.targetLongitude.compareTo(b.targetLongitude);
    });

    return connections;
  }

  /// Master calculation for BNN Method 1
  static BnnMethod1Result calculate({
    required DateTime birthDate,
    required String birthTime,
    required double latitude,
    required double longitude,
    required String place,
    required double utcOffsetHours,
    required BnnMethod1Planet lagna,
    required List<BnnMethod1Planet> rawPlanets,
    BnnDashaResult? dashaResult,
  }) {
    // 1. Assign strict degree order across all 9 planets
    final orderedPlanets = assignDegreeOrder(rawPlanets);

    // Sorted planets by degree order for degree order table
    final degreeOrderSorted = List<BnnMethod1Planet>.from(orderedPlanets)
      ..sort((a, b) => a.degreeOrder.compareTo(b.degreeOrder));

    // 2. Generate sorted connections for all planets
    final Map<String, List<BnnMethod1Connection>> connectionsByPlanet = {};
    final List<BnnMethod1Connection> allConnections = [];

    for (final p in orderedPlanets) {
      final conns = calculatePlanetConnections(
        sourcePlanet: p,
        allPlanets: orderedPlanets,
      );
      connectionsByPlanet[p.planetKey] = conns;
      allConnections.addAll(conns);
    }

    // 3. Generate deterministic predictions from connections
    final predictions = BnnMethod1PredictionEngine.generatePredictions(allConnections);

    return BnnMethod1Result(
      birthDate: birthDate,
      birthTime: birthTime,
      latitude: latitude,
      longitude: longitude,
      place: place,
      utcOffsetHours: utcOffsetHours,
      lagna: lagna,
      planetaryPositions: orderedPlanets,
      degreeOrder: degreeOrderSorted,
      connectionsByPlanet: connectionsByPlanet,
      allConnections: allConnections,
      predictions: predictions,
      calculationStatus: 'Success',
      dashaResult: dashaResult,
    );
  }
}
