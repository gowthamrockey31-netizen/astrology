import 'kp2_planet.dart';

/// Single House Cusp in KP Method 2 (Placidus / Semi-arc Cusp)
class KP2Cusp {
  final int house; // 1..12
  final double longitude;
  final int rasiIndex;
  final String rasiNameTa;
  final String rasiNameEn;
  final double degreeInRasi;
  final String formattedDms;
  final int nakshatraIndex;
  final String nakshatraNameTa;
  final int pada;
  final KP2Planet signLord;
  final KP2Planet starLord;
  final KP2Planet subLord;
  final KP2Planet subSubLord;

  const KP2Cusp({
    required this.house,
    required this.longitude,
    required this.rasiIndex,
    required this.rasiNameTa,
    required this.rasiNameEn,
    required this.degreeInRasi,
    required this.formattedDms,
    required this.nakshatraIndex,
    required this.nakshatraNameTa,
    required this.pada,
    required this.signLord,
    required this.starLord,
    required this.subLord,
    required this.subSubLord,
  });
}
