import '../services/astrology_calculator.dart';

/// Divisional Chart (Varga) definition and calculation model
enum VargaType {
  d1('D1', 'ராசி', 'Rasi', 1, 'உடல், ஆளுமை, பொது வாழ்க்கை'),
  d2('D2', 'ஹோரா', 'Hora', 2, 'செல்வம், தனம், வருமானம்'),
  d3('D3', 'திரேக்காணம்', 'Drekkana', 3, 'சகோதரர்கள், தைரியம், ஆற்றல்'),
  d4('D4', 'சதுர்த்தாம்சம்', 'Chaturthamsha', 4, 'சொத்துக்கள், வீடு, வாகனங்கள், சுகம்'),
  d7('D7', 'சப்தாம்சம்', 'Saptamsha', 7, 'குழந்தைகள், சந்ததி, மகிழ்ச்சி'),
  d9('D9', 'நவாம்சம்', 'Navamsha', 9, 'திருமணம், வாழ்க்கை துணை, தர்மம்'),
  d10('D10', 'தசாம்சம்', 'Dasamsha', 10, 'தொழில், வேலை, கௌரவம், பதவி'),
  d12('D12', 'துவாதசாம்சம்', 'Dwadasamsha', 12, 'பெற்றோர்கள், பூர்வீகம், பரம்பரை'),
  d16('D16', 'ஷோடசாம்சம்', 'Shodashamsha', 16, 'வாகன சுகம், மன அமைதி'),
  d20('D20', 'விம்சாம்சம்', 'Vimshamsha', 20, 'ஆன்மீகம், பக்தி, உபாசனை'),
  d24('D24', 'சதுர்விம்சாம்சம்', 'Chaturvimshamsha', 24, 'கல்வி, அறிவு, கலைகள்'),
  d27('D27', 'பம்சாம்சம் (நட்சத்திராம்சம்)', 'Bhamsa', 27, 'பலம், பலவீனம், ஆளுமை'),
  d30('D30', 'திரிம்சாம்சம்', 'Trimsamsha', 30, 'தோஷங்கள், தடைகள், அரிஷ்டம்'),
  d40('D40', 'கவேதாம்சம்', 'Khavedamsha', 40, 'சுப அசுப பலன்கள், பாக்கியம்'),
  d45('D45', 'அக்ஷவேதாம்சம்', 'Akshavedamsha', 45, 'குணநலன்கள், பொது விசேஷம்'),
  d60('D60', 'ஷஷ்டியாம்சம்', 'Shastiamsha', 60, 'முழுமையான பூர்வ புண்ணியம் & கர்ம பலன்');

  final String code;
  final String tamilName;
  final String englishName;
  final int division;
  final String significance;

  const VargaType(this.code, this.tamilName, this.englishName, this.division, this.significance);
}

/// Planet placement in a specific Divisional Chart
class VargaPlanetPosition {
  final String planetKey;
  final String tamilName;
  final String symbol;
  final int rasiIndex; // 0..11
  final String rasiNameTa;
  final String rasiNameEn;
  final double degreeInVarga;

  const VargaPlanetPosition({
    required this.planetKey,
    required this.tamilName,
    required this.symbol,
    required this.rasiIndex,
    required this.rasiNameTa,
    required this.rasiNameEn,
    required this.degreeInVarga,
  });
}

/// Full Result of a Divisional Chart
class VargaChartResult {
  final VargaType type;
  final Map<String, VargaPlanetPosition> planets;
  final Map<int, List<VargaPlanetPosition>> rasiPlanets;

  const VargaChartResult({
    required this.type,
    required this.planets,
    required this.rasiPlanets,
  });
}
