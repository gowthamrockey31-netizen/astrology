import '../data/jamakol_arudam_model1_rules.dart';
import '../models/jamakol_arudam_model1.dart';

/// Prediction Engine for Jamakol Arudam Model 1
/// Strictly deterministic layer generating predictions from core points and planetary placements.
class JamakolArudamModel1PredictionEngine {
  /// Generate all Model 1 predictions for the Arudam result
  static List<JamakolArudamPrediction> generatePredictions({
    required JamakolArudamCorePoint udhayam,
    required JamakolArudamCorePoint aarudam,
    required JamakolArudamCorePoint kavippu,
    required List<JamakolArudamPlanet> planets,
  }) {
    final List<JamakolArudamPrediction> predictions = [];

    // 1. Evaluate Udhayam - Aarudam fundamental relationship
    predictions.add(
      JamakolArudamModel1RulesRepository.evaluateUdhayamAarudamRelation(
        udhayam: udhayam,
        aarudam: aarudam,
      ),
    );

    // 2. Evaluate Kavippu obstructions & planetary afflictions
    predictions.addAll(
      JamakolArudamModel1RulesRepository.evaluateKavippuEffects(
        kavippu: kavippu,
        udhayam: udhayam,
        aarudam: aarudam,
        planets: planets,
      ),
    );

    return predictions;
  }
}
