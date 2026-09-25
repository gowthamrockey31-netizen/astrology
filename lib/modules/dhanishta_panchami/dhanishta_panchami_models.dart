// ===============================================================
// DHANISHTA PANCHAMI / TITHI ADAIPPU - MODELS
// ===============================================================

class AdaippuData {
  final int months;
  final String type;

  const AdaippuData(this.months, this.type);
}

class TithiResult {
  final int tithiNumber; // 1..30
  final String tithiTamil;
  final String pakshaTamil;
  final int nakshatraNumber; // 1..27 (Avittam = 23)
  final String nakshatraTamil;
  final bool isDhanishtaPanchami;
  final bool isAdaippuNakshatra;
  final int adaippuMonths;
  final String adaippuType;
  final String explanation;
  final String remedy;

  const TithiResult({
    required this.tithiNumber,
    required this.tithiTamil,
    required this.pakshaTamil,
    required this.nakshatraNumber,
    required this.nakshatraTamil,
    required this.isDhanishtaPanchami,
    required this.isAdaippuNakshatra,
    required this.adaippuMonths,
    required this.adaippuType,
    required this.explanation,
    required this.remedy,
  });
}
