import 'bnn_method_2_models.dart';
import '../../services/astrology_calculator.dart';

/// Pure calculation engine for BNN Method 2
class BNNMethod2Engine {
  /// Strict BNN Direction sequence specified for Method 2:
  /// [1, 5, 9, 3, 11, 7, 2, 12]
  static const List<int> directionOrder = [
    1,
    5,
    9,
    3,
    11,
    7,
    2,
    12,
  ];

  /// Calculate relative house direction from source to target:
  /// Formula: ((target.house - source.house) % 12) + 1
  /// Normalized for positive 1..12 return value
  static int calculateRelativeHouse(int sourceHouse, int targetHouse) {
    return (((targetHouse - sourceHouse) % 12 + 12) % 12) + 1;
  }

  /// Evaluates if a relative house is a valid BNN direction
  static bool isValidDirection(int relativeHouse) {
    return directionOrder.contains(relativeHouse);
  }

  /// Calculate all BNN Method 2 connections for a source planet against target planets
  static List<BNNMethod2Connection> calculateConnections({
    required BNNMethod2PlanetPosition sourcePlanet,
    required List<BNNMethod2PlanetPosition> allPlanets,
  }) {
    final List<BNNMethod2Connection> connections = [];

    for (final target in allPlanets) {
      // Exclude self comparison
      if (target.planetKey == sourcePlanet.planetKey) continue;

      final relHouse = calculateRelativeHouse(sourcePlanet.house, target.house);

      if (directionOrder.contains(relHouse)) {
        final dirIndex = directionOrder.indexOf(relHouse);
        final relType = BNNMethod2PlanetRelationTable.getRelation(
          sourcePlanet.planetKey,
          target.planetKey,
        );

        connections.add(
          BNNMethod2Connection(
            sourcePlanet: sourcePlanet,
            targetPlanet: target,
            relativeHouse: relHouse,
            directionIndex: dirIndex,
            relationship: relType,
          ),
        );
      }
    }

    // Strict Connection Sorting:
    // 1. directionOrder index
    // 2. target.degree (target planet degree in sign)
    connections.sort((a, b) {
      final dirCompare = a.directionIndex.compareTo(b.directionIndex);
      if (dirCompare != 0) return dirCompare;
      return a.targetPlanet.degreeInSign.compareTo(b.targetPlanet.degreeInSign);
    });

    return connections;
  }
}

/// Analysis helper for BNN Method 2
class BNNMethod2Calculator {
  static BNNMethod2PlanetAnalysis analyzePlanet({
    required BNNMethod2PlanetPosition sourcePlanet,
    required List<BNNMethod2PlanetPosition> allPlanets,
  }) {
    final connections = BNNMethod2Engine.calculateConnections(
      sourcePlanet: sourcePlanet,
      allPlanets: allPlanets,
    );

    return BNNMethod2PlanetAnalysis(
      sourcePlanet: sourcePlanet,
      planetKarakas: BNNMethod2PlanetKaraka.get(sourcePlanet.planetKey),
      diseaseKarakas: BNNMethod2DiseaseKaraka.get(sourcePlanet.planetKey),
      houseKarakas: BNNMethod2HouseKaraka.get(sourcePlanet.house),
      connections: connections,
    );
  }

  static Map<String, BNNMethod2PlanetAnalysis> analyzeAllPlanets(
    List<BNNMethod2PlanetPosition> planets,
  ) {
    final Map<String, BNNMethod2PlanetAnalysis> map = {};
    for (final p in planets) {
      map[p.planetKey] = analyzePlanet(sourcePlanet: p, allPlanets: planets);
    }
    return map;
  }
}

/// Adapter converting existing application calculated planet positions
/// into strongly-typed [BNNMethod2PlanetPosition] without modifying existing data.
class BNNMethod2Adapter {
  static const List<String> planetOrder = [
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

  static List<BNNMethod2PlanetPosition> fromExistingPlanetsMap({
    required Map<String, PlanetDetail> planetsMap,
    required int lagnaRasiIndex, // 0..11 (0=Mesham)
  }) {
    final List<BNNMethod2PlanetPosition> list = [];

    for (final key in planetOrder) {
      final detail = planetsMap[key];
      if (detail == null) continue;

      // Calculate house from Lagna: 1 to 12
      final house = (((detail.rasiIndex - lagnaRasiIndex) % 12 + 12) % 12) + 1;

      list.add(
        BNNMethod2PlanetPosition(
          planetKey: detail.name,
          tamilName: detail.tamilName,
          englishName: detail.name,
          sign: detail.rasiIndex + 1,
          signNameTa: detail.rasiNameTa,
          signNameEn: detail.rasiNameEn,
          house: house,
          degreeInSign: detail.degreeInRasi,
          absoluteLongitude: detail.longitude,
          degree: detail.degree,
          minute: detail.minute,
          second: detail.second,
          nakshatra: detail.nakshatraNameTa,
          pada: detail.pada,
          isRetrograde: detail.isRetrograde,
        ),
      );
    }

    return list;
  }
}
