/// Model representing one of the 12 KP Placidus House Cusps
class KPCusp {
  final int houseNumber;
  final double longitude;
  final int rasiIndex;
  final String rasiNameEn;
  final String rasiNameTa;
  final int degree;
  final int minute;
  final double second;
  final int nakshatraIndex;
  final String nakshatraNameEn;
  final String nakshatraNameTa;
  final int pada;
  final String signLord;
  final String starLord;
  final List<int> starLordHouses;
  final String subLord;
  final List<int> subLordHouses;
  final String subSubLord;
  final List<int> subSubLordHouses;

  const KPCusp({
    required this.houseNumber,
    required this.longitude,
    required this.rasiIndex,
    required this.rasiNameEn,
    required this.rasiNameTa,
    required this.degree,
    required this.minute,
    required this.second,
    required this.nakshatraIndex,
    required this.nakshatraNameEn,
    required this.nakshatraNameTa,
    required this.pada,
    required this.signLord,
    required this.starLord,
    required this.starLordHouses,
    required this.subLord,
    required this.subLordHouses,
    required this.subSubLord,
    required this.subSubLordHouses,
  });

  /// Formatted DMS string within the rasi (e.g. 21° 04' 18")
  String get dmsFormatted {
    final secInt = second.round();
    final degStr = degree.toString().padLeft(2, '0');
    final minStr = minute.toString().padLeft(2, '0');
    final secStr = secInt.toString().padLeft(2, '0');
    return "$degStr° $minStr' $secStr\"";
  }
}
