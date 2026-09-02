import '../data/bnn_method1_rules.dart';
import '../models/bnn_method1_model.dart';

/// Prediction Engine for BNN Method 1
/// Pure deterministic layer translating connections into structured Tamil predictions.
class BnnMethod1PredictionEngine {
  /// Generate a structured prediction for a single BNN Method 1 Connection
  static BnnMethod1Prediction generatePrediction(BnnMethod1Connection connection) {
    final sPlanet = connection.sourcePlanet;
    final tPlanet = connection.targetPlanet;
    final summary = '${sPlanet.planetName} → ${tPlanet.planetName}';

    final explanation = BnnMethod1RulesRepository.getInterpretation(
      sourceKey: sPlanet.planetKey,
      targetKey: tPlanet.planetKey,
      sourceNameTa: sPlanet.planetName,
      targetNameTa: tPlanet.planetName,
      relativeHouse: connection.relativeHouse,
      directionGroup: connection.directionGroup,
      relation: connection.relation,
      targetKarakatwas: connection.karakatwas,
    );

    return BnnMethod1Prediction(
      sourcePlanet: sPlanet,
      targetPlanet: tPlanet,
      relativeHouse: connection.relativeHouse,
      directionGroup: connection.directionGroup,
      directionTitle: connection.directionGroup.label,
      relation: connection.relation,
      relationLabel: connection.relation.labelTa,
      karakatwas: connection.karakatwas,
      summary: summary,
      explanationTa: explanation,
    );
  }

  /// Generate structured predictions for a list of connections
  static List<BnnMethod1Prediction> generatePredictions(List<BnnMethod1Connection> connections) {
    return connections.map((conn) => generatePrediction(conn)).toList();
  }
}
