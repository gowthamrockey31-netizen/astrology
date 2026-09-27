// ===============================================================
// DHANISHTA PANCHAMI / TITHI ADAIPPU CALCULATOR (BRIDGE)
// ===============================================================

import 'dhanishta_panchami_engine.dart';
import 'dhanishta_panchami_models.dart';

class DhanishtaCalculator {
  /// Calculate Dhanishta Panchami and Tithi Adaippu for a given DateTime
  static TithiResult calculate(
    DateTime dateTime, {
    double latitude = 13.0827,
    double longitude = 80.2707,
    double utcOffsetHours = 5.5,
    String place = 'Chennai',
  }) {
    return DhanishtaPanchamiEngine.calculate(
      dateTime: dateTime,
      place: place,
      latitude: latitude,
      longitude: longitude,
      utcOffsetHours: utcOffsetHours,
    );
  }

  /// Calculate from precise Sun and Moon longitudes
  static TithiResult calculateFromLongitudes({
    required double sunLongitude,
    required double moonLongitude,
    DateTime? dateTime,
    String place = 'Chennai',
    double latitude = 13.0827,
    double longitude = 80.2707,
  }) {
    return DhanishtaPanchamiEngine.calculateFromLongitudes(
      sunLongitude: sunLongitude,
      moonLongitude: moonLongitude,
      dateTime: dateTime,
      place: place,
      latitude: latitude,
      longitude: longitude,
    );
  }

  /// Calculate directly from Nakshatra (1..27) and Tithi (1..30)
  static TithiResult calculateFromIndices({
    required int nakshatraNumber,
    required int tithiNumber,
    int pada = 1,
    DateTime? dateTime,
    String place = 'Chennai',
    double latitude = 13.0827,
    double longitude = 80.2707,
  }) {
    return DhanishtaPanchamiEngine.calculateFromIndices(
      nakshatraNumber: nakshatraNumber,
      tithiNumber: tithiNumber,
      pada: pada,
      dateTime: dateTime,
      place: place,
      latitude: latitude,
      longitude: longitude,
    );
  }
}
