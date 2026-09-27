import '../../services/astrology_calculator.dart';
import '../models/rasi_palan_models.dart';

/// Transit Calculator for Daily Rasi Palan.
///
/// Consumes the existing AstroDashaCare calculation engine
/// (AstrologyCalculator.calculateTransits) directly without duplicate
/// planetary calculations.
class DailyTransitCalculator {
  /// Fetches current planetary transits for the given date using the
  /// existing AstrologyCalculator engine.
  static List<PlanetTransit> getTransits({DateTime? date}) {
    final transitsMap = AstrologyCalculator.calculateTransits(date: date);
    return transitsMap.values.map((detail) {
      return PlanetTransit(
        planet: detail.name,
        planetTamil: detail.tamilName,
        symbol: detail.symbol,
        transitRasiIndex: detail.rasiIndex,
        transitRasiName: detail.rasiNameTa,
        degree: detail.degreeInRasi,
        degreeFormatted: detail.degreeFormatted,
        isRetrograde: detail.isRetrograde,
      );
    }).toList();
  }
}
