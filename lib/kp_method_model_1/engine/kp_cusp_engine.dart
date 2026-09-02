import '../../services/astrology_calculator.dart';
import '../models/kp_cusp.dart';
import 'kp_nakshatra_engine.dart';
import 'kp_sub_lord_engine.dart';
import 'kp_sub_sub_lord_engine.dart';

/// Calculation engine for 12 KP Placidus Cusps and nested lordships
class KPCuspEngine {
  /// Derive the 12 complete KPCusp models from raw cusp longitudes
  static List<KPCusp> calculateCusps(List<double> rawCuspLongitudes) {
    // First pass: basic cusp info & sign lord identification
    final List<Map<String, dynamic>> rawList = [];

    for (int i = 0; i < 12; i++) {
      final double cLong = AstrologyCalculator.normalizeDegrees(rawCuspLongitudes[i]);
      final int rasiIdx = (cLong / 30.0).floor().clamp(0, 11);
      final double degInRasi = cLong - (rasiIdx * 30.0);
      final int degInt = degInRasi.floor();
      final double remMin = (degInRasi - degInt) * 60.0;
      final int minInt = remMin.floor();
      final double sec = (remMin - minInt) * 60.0;

      final nakInfo = KPNakshatraEngine.calculate(cLong);
      final subInfo = KPSubLordEngine.calculate(cLong);
      final subSubInfo = KPSubSubLordEngine.calculate(cLong);

      final signLordEn = KPNakshatraEngine.signLordsEn[rasiIdx];

      rawList.add({
        'houseNumber': i + 1,
        'longitude': cLong,
        'rasiIndex': rasiIdx,
        'rasiNameEn': AstrologyCalculator.rasiNamesEn[rasiIdx],
        'rasiNameTa': AstrologyCalculator.rasiNamesTa[rasiIdx],
        'degree': degInt,
        'minute': minInt,
        'second': sec,
        'nakshatraIndex': nakInfo.index,
        'nakshatraNameEn': nakInfo.nameEn,
        'nakshatraNameTa': nakInfo.nameTa,
        'pada': nakInfo.pada,
        'signLord': signLordEn,
        'starLord': nakInfo.lordEn,
        'subLord': subInfo.subLordEn,
        'subSubLord': subSubInfo.subSubLordEn,
      });
    }

    // Map which houses are owned by each planet (based on sign lord of the cusps)
    final Map<String, List<int>> planetOwnedHouses = {};
    for (final item in rawList) {
      final String signLord = item['signLord'];
      final int houseNum = item['houseNumber'];
      planetOwnedHouses.putIfAbsent(signLord, () => []).add(houseNum);
    }

    // Second pass: attach starLordHouses, subLordHouses, subSubLordHouses
    return rawList.map((item) {
      final starLord = item['starLord'] as String;
      final subLord = item['subLord'] as String;
      final subSubLord = item['subSubLord'] as String;

      return KPCusp(
        houseNumber: item['houseNumber'] as int,
        longitude: item['longitude'] as double,
        rasiIndex: item['rasiIndex'] as int,
        rasiNameEn: item['rasiNameEn'] as String,
        rasiNameTa: item['rasiNameTa'] as String,
        degree: item['degree'] as int,
        minute: item['minute'] as int,
        second: item['second'] as double,
        nakshatraIndex: item['nakshatraIndex'] as int,
        nakshatraNameEn: item['nakshatraNameEn'] as String,
        nakshatraNameTa: item['nakshatraNameTa'] as String,
        pada: item['pada'] as int,
        signLord: item['signLord'] as String,
        starLord: starLord,
        starLordHouses: planetOwnedHouses[starLord] ?? [],
        subLord: subLord,
        subLordHouses: planetOwnedHouses[subLord] ?? [],
        subSubLord: subSubLord,
        subSubLordHouses: planetOwnedHouses[subSubLord] ?? [],
      );
    }).toList();
  }
}
