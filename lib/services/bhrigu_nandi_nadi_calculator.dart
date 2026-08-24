import '../models/bhrigu_nandi_nadi_model.dart';
import 'astrology_calculator.dart';

/// Calculation Service for Classical Bhrigu Nandi Nadi Astrology
class BhriguNandiNadiCalculator {
  /// Calculate Bhrigu Nandi Nadi chart analysis from planetary positions
  static BhriguNandiNadiResult calculate(Map<String, PlanetDetail> planets) {
    // 1. Group planets by Directional Trines (1-5-9): East, South, West, North
    final Map<NadiDirection, List<String>> directionalPlanets = {
      NadiDirection.east: [],
      NadiDirection.south: [],
      NadiDirection.west: [],
      NadiDirection.north: [],
    };

    final targetPlanets = ['Jupiter', 'Saturn', 'Venus', 'Mars', 'Sun', 'Moon', 'Mercury', 'Rahu', 'Ketu'];

    for (final key in targetPlanets) {
      final p = planets[key];
      if (p == null) continue;

      for (final dir in NadiDirection.values) {
        if (dir.rasiIndices.contains(p.rasiIndex)) {
          directionalPlanets[dir]!.add("${p.tamilName} (${p.rasiNameTa})");
          break;
        }
      }
    }

    // 2. Identify Nadi Combinations for Primary Karakas
    final List<NadiCombination> combinations = [];

    // Jeeva Karaka: Jupiter (குரு)
    final jup = planets['Jupiter'];
    String jeevaPred = 'குரு பகவான் சுப ஸ்தானத்தில் அமைந்துள்ளார்.';
    if (jup != null) {
      final combined = _findTrineAndAdjacentPlanets(jup, planets);
      jeevaPred = _generateJeevaKarakaPrediction(combined);
      combinations.add(NadiCombination(
        primaryPlanetTa: 'குரு (Jupiter)',
        primaryRoleTa: 'ஜீவகாரகன் (உயிர், ஆத்மா, அறிவு, சுப பலன்)',
        combinedPlanetsTa: combined,
        relationTypeTa: '1-5-9 திரிகோண & 2-12 சேர்க்கை',
        predictionTa: jeevaPred,
      ));
    }

    // Karma Karaka: Saturn (சனி)
    final sat = planets['Saturn'];
    String karmaPred = 'சனி பகவான் உழைப்பு மற்றும் கர்ம ஸ்தானத்தை குறிக்கிறார்.';
    if (sat != null) {
      final combined = _findTrineAndAdjacentPlanets(sat, planets);
      karmaPred = _generateKarmaKarakaPrediction(combined);
      combinations.add(NadiCombination(
        primaryPlanetTa: 'சனி (Saturn)',
        primaryRoleTa: 'கர்மகாரகன் (தொழில், வேலை, வாழ்வாதாரம்)',
        combinedPlanetsTa: combined,
        relationTypeTa: '1-5-9 திரிகோண & 2-12 சேர்க்கை',
        predictionTa: karmaPred,
      ));
    }

    // Dhana Karaka: Venus (சுக்கிரன்)
    final ven = planets['Venus'];
    String dhanaPred = 'சுக்கிரன் தனம், வாகனம் மற்றும் வாழ்க்கை துணையை குறிக்கிறார்.';
    if (ven != null) {
      final combined = _findTrineAndAdjacentPlanets(ven, planets);
      dhanaPred = _generateDhanaKarakaPrediction(combined);
      combinations.add(NadiCombination(
        primaryPlanetTa: 'சுக்கிரன் (Venus)',
        primaryRoleTa: 'தன & களத்திர காரகன் (செல்வம், சுகபோகம், துணை)',
        combinedPlanetsTa: combined,
        relationTypeTa: '1-5-9 திரிகோண & 2-12 சேர்க்கை',
        predictionTa: dhanaPred,
      ));
    }

    // Vidya / Buddhi Karaka: Mercury (புதன்)
    final merc = planets['Mercury'];
    String vidyaPred = 'புதன் கல்வி, வியாபாரம் மற்றும் புத்திக்கூர்மையை குறிக்கிறார்.';
    if (merc != null) {
      final combined = _findTrineAndAdjacentPlanets(merc, planets);
      vidyaPred = _generateVidyaKarakaPrediction(combined);
      combinations.add(NadiCombination(
        primaryPlanetTa: 'புதன் (Mercury)',
        primaryRoleTa: 'வித்யா & வியாபார காரகன் (கல்வி, வியாபாரம், புத்தி)',
        combinedPlanetsTa: combined,
        relationTypeTa: '1-5-9 திரிகோண சேர்க்கை',
        predictionTa: vidyaPred,
      ));
    }

    return BhriguNandiNadiResult(
      directionalPlanetsTa: directionalPlanets,
      combinations: combinations,
      jeevaKarakaAnalysisTa: jeevaPred,
      karmaKarakaAnalysisTa: karmaPred,
      dhanaKarakaAnalysisTa: dhanaPred,
      vidyaKarakaAnalysisTa: vidyaPred,
    );
  }

  static List<String> _findTrineAndAdjacentPlanets(PlanetDetail basePlanet, Map<String, PlanetDetail> allPlanets) {
    final List<String> result = [];
    final int baseRasi = basePlanet.rasiIndex;

    // Trine signs (1, 5, 9 from base = same element direction)
    final trineRasis = [baseRasi, (baseRasi + 4) % 12, (baseRasi + 8) % 12];
    final nextRasi = (baseRasi + 1) % 12; // 2nd house (Ahead)

    for (final entry in allPlanets.entries) {
      if (entry.key == basePlanet.name) continue;
      final p = entry.value;

      if (trineRasis.contains(p.rasiIndex)) {
        result.add("${p.tamilName} (திரிகோண சேர்க்கை)");
      } else if (p.rasiIndex == nextRasi) {
        result.add("${p.tamilName} (2-ஆம் இடம் / முன்னோக்கு சேர்க்கை)");
      }
    }
    return result;
  }

  static String _generateJeevaKarakaPrediction(List<String> combined) {
    if (combined.any((c) => c.contains('சனி'))) {
      return 'குரு + சனி சேர்க்கை: தர்ம-கர்மாதிபதி யோகம். ஆன்மீக ஈடுபாடு, சமூக அந்தஸ்து மற்றும் நீண்ட கால உழைப்பால் உயர்வு.';
    }
    if (combined.any((c) => c.contains('சுக்கிரன்'))) {
      return 'குரு + சுக்கிரன் சேர்க்கை: பிரம்ம யோகம். செல்வ வளம், உயர் ரசனை, சுகபோக வாழ்வு மற்றும் நல்மதிப்பு.';
    }
    if (combined.any((c) => c.contains('சூரியன்'))) {
      return 'குரு + சூரியன் சேர்க்கை: சிவ-ராஜ யோகம். தலைமைத்துவ பண்பு, அரசு தொடர்பு மற்றும் தந்தையின் ஆசி.';
    }
    return 'ஜீவகாரகன் குரு சுப நிலையுடன் வாழ்க்கைப் பயணத்தில் வழிகாட்டுகிறார்.';
  }

  static String _generateKarmaKarakaPrediction(List<String> combined) {
    if (combined.any((c) => c.contains('புதன்'))) {
      return 'சனி + புதன் சேர்க்கை: வியாபாரம், ஆடிட்டிங், ஐடி, தரகு மற்றும் நிர்வாகத் துறைகளில் சிறந்த தொழில் வெற்றி.';
    }
    if (combined.any((c) => c.contains('செவ்வாய்'))) {
      return 'சனி + செவ்வாய் சேர்க்கை: இன்ஜினியரிங், இயந்திரங்கள், நிலம், கட்டிடம் மற்றும் தொழில்நுட்பத் துறைகளில் சிறந்து விளங்குவர்.';
    }
    if (combined.any((c) => c.contains('சுக்கிரன்'))) {
      return 'சனி + சுக்கிரன் சேர்க்கை: நிதி, கலை, ஆடம்பர பொருட்கள், வங்கி மற்றும் ஆடை துறைகளில் நிரந்தர வருமானம்.';
    }
    return 'கர்மகாரகன் சனி தொழில் துறையில் நிலைத்த முன்னேற்றத்தை வழங்குவார்.';
  }

  static String _generateDhanaKarakaPrediction(List<String> combined) {
    if (combined.any((c) => c.contains('கேது'))) {
      return 'சுக்கிரன் + கேது சேர்க்கை: ஆன்மீக கலைகள், ஆடை வடிவமைப்பு அல்லது சுயதொழில் மூலம் தன லாபம்.';
    }
    if (combined.any((c) => c.contains('ராகு'))) {
      return 'சுக்கிரன் + ராகு சேர்க்கை: எதிர்பாராத பெரும் தன வரவு, வெளிநாட்டு தொடர்பு மற்றும் சொகுசு வாழ்க்கை.';
    }
    return 'தனகாரகன் சுக்கிரன் சுப பலன்களை தந்து மகிழ்ச்சியான குடும்ப அமைப்பை உருவாக்குகிறார்.';
  }

  static String _generateVidyaKarakaPrediction(List<String> combined) {
    if (combined.any((c) => c.contains('சந்திரன்'))) {
      return 'புதன் + சந்திரன் சேர்க்கை: கற்பனை வளம், எழுத்து, படைப்பாற்றல், கவிதை மற்றும் பேச்சாற்றலில் மேன்மை.';
    }
    return 'புதன் கல்வி மற்றும் அறிவாற்றலில் கூர்மையான சிந்தனையை அருள்கிறார்.';
  }
}
