import '../models/jamakol_arudam_model1.dart';
import '../services/astrology_calculator.dart';

/// Centralized Rules Repository for Jamakol Arudam Model 1
class JamakolArudamModel1RulesRepository {
  /// Sign Lord mapping (0=Mesham ... 11=Meenam)
  static const List<String> rasiLordsEn = [
    'Mars',    // 0: Mesham
    'Venus',   // 1: Rishabam
    'Mercury', // 2: Mithunam
    'Moon',    // 3: Kadagam
    'Sun',     // 4: Simmam
    'Mercury', // 5: Kanni
    'Venus',   // 6: Thulam
    'Mars',    // 7: Viruchigam
    'Jupiter', // 8: Dhanusu
    'Saturn',  // 9: Makaram
    'Saturn',  // 10: Kumbam
    'Jupiter', // 11: Meenam
  ];

  static const Map<String, String> planetNameEnToTa = {
    'Sun': 'சூரியன்',
    'Moon': 'சந்திரன்',
    'Mars': 'செவ்வாய்',
    'Mercury': 'புதன்',
    'Jupiter': 'குரு',
    'Venus': 'சுக்கிரன்',
    'Saturn': 'சனி',
    'Rahu': 'ராகு',
    'Ketu': 'கேது',
  };

  /// Evaluate relationship between Udhayam and Aarudam
  static JamakolArudamPrediction evaluateUdhayamAarudamRelation({
    required JamakolArudamCorePoint udhayam,
    required JamakolArudamCorePoint aarudam,
  }) {
    final int relHouse = ((aarudam.rasiIndex - udhayam.rasiIndex + 12) % 12) + 1;

    String title = 'உதயம் - ஆருடம் தொடர்பு ($relHouse-ஆம் பாவம்)';
    String interpretation;
    bool favorable;

    if (relHouse == 1) {
      interpretation = 'உதயமும் ஆருடமும் ஒரே ராசியில் இணைந்துள்ளன. எண்ணிய காரியம் மிக விரைவாகவும் தடையின்றியும் நேரடியாக கைகூடும் சிறந்த அமைப்பு.';
      favorable = true;
    } else if (relHouse == 5 || relHouse == 9) {
      interpretation = 'உதயத்திற்கு ஆருடம் திரிகோண ஸ்தானத்தில் ($relHouse-ஆம் பாவம்) அமர்ந்துள்ளது. பூர்வ புண்ணிய பலத்தாலும் தெய்வீக அருளாலும் முயற்சி முழு வெற்றி பெறும்.';
      favorable = true;
    } else if (relHouse == 3 || relHouse == 11) {
      interpretation = 'உதயத்திற்கு ஆருடம் உபசய ஸ்தானத்தில் ($relHouse-ஆம் பாவம்) உள்ளது. சுய முயற்சியினாலும் நலம் விரும்பிகளின் ஆதரவினாலும் காரிய வெற்றி நிச்சயம் கிட்டும்.';
      favorable = true;
    } else if (relHouse == 4 || relHouse == 7 || relHouse == 10) {
      interpretation = 'உதயத்திற்கு ஆருடம் கேந்திர ஸ்தானத்தில் ($relHouse-ஆம் பாவம்) உள்ளது. சமுதாய நற்பெயர் மற்றும் முறையான நிர்வாக அணுகுமுறையால் செயல் நிறைவேறும்.';
      favorable = true;
    } else if (relHouse == 2) {
      interpretation = 'உதயத்திற்கு ஆருடம் 2-ஆம் பாவத்தில் தன ஸ்தானத்தில் உள்ளது. பொருளாதார ஆதாயம் மற்றும் குடும்ப ஒத்துழைப்புடன் காரியம் முடியும்.';
      favorable = true;
    } else if (relHouse == 6) {
      interpretation = 'உதயத்திற்கு ஆருடம் 6-ஆம் பாவத்தில் (மறைவு) உள்ளது. போட்டி, சவால்கள் மற்றும் எதிர்ப்புகளை முறியடித்து தாமதமாக வெற்றி கிடைக்கும்.';
      favorable = false;
    } else if (relHouse == 8) {
      interpretation = 'உதயத்திற்கு ஆருடம் 8-ஆம் பாவத்தில் உள்ளது. எதிர்பாராத தடைகள், மன உளைச்சல் அல்லது தாமதங்கள் உண்டாகலாம். கூடுதல் கவனமும் பொறுமையும் தேவை.';
      favorable = false;
    } else if (relHouse == 12) {
      interpretation = 'உதயத்திற்கு ஆருடம் 12-ஆம் பாவத்தில் உள்ளது. விரயங்கள், செலவுகள் அல்லது பயணங்களுக்குப் பின்னரே காரியம் நிலைபெறும்.';
      favorable = false;
    } else {
      interpretation = 'உதயத்திற்கும் ஆருடத்திற்கும் இடையேயான தொடர்பு சமநிலையான பலன்களைக் குறிக்கிறது.';
      favorable = true;
    }

    return JamakolArudamPrediction(
      title: title,
      pointName: 'ஆருடம்',
      ruleType: 'Udhayam-Aarudam',
      interpretationTa: interpretation,
      isFavorable: favorable,
    );
  }

  /// Evaluate Kavippu placement & obstruction
  static List<JamakolArudamPrediction> evaluateKavippuEffects({
    required JamakolArudamCorePoint kavippu,
    required JamakolArudamCorePoint udhayam,
    required JamakolArudamCorePoint aarudam,
    required List<JamakolArudamPlanet> planets,
  }) {
    final List<JamakolArudamPrediction> result = [];

    // 1. Kavippu on Udhayam or Aarudam
    if (kavippu.rasiIndex == udhayam.rasiIndex) {
      result.add(const JamakolArudamPrediction(
        title: 'கவிப்பு உதயம் மீது அமர்வு',
        pointName: 'கவிப்பு',
        ruleType: 'Kavippu-Udhayam',
        interpretationTa: 'கவிப்பு புள்ளி உதய ராசியிலேயே அமைந்துள்ளது. ஜாதகரின் சொந்த முடிவுகளிலோ அல்லது அவசர செயலாலோ தற்காலிக தடைகள் வரக்கூடும். எச்சரிக்கையான அணுகுமுறை நன்று.',
        isFavorable: false,
      ));
    }

    if (kavippu.rasiIndex == aarudam.rasiIndex) {
      result.add(const JamakolArudamPrediction(
        title: 'கவிப்பு ஆருடம் மீது அமர்வு',
        pointName: 'கவிப்பு',
        ruleType: 'Kavippu-Aarudam',
        interpretationTa: 'கவிப்பு புள்ளி ஆருட ராசியிலேயே நேரிடையாகப் பதிகிறது. கேட்கப்பட்ட காரியத்தில் எதிர்பாராத முட்டுக்கட்டைகள் தோன்றலாம். பரிகாரம் மற்றும் கால அவகாசம் தேவை.',
        isFavorable: false,
      ));
    }

    // 2. Planets situated in Kavippu Rasi
    final planetsInKavippu = planets.where((p) => p.rasiIndex == kavippu.rasiIndex).toList();

    for (final p in planetsInKavippu) {
      String meaning;
      switch (p.planetKey) {
        case 'Sun':
          meaning = 'சூரியன் கவிப்பில் உள்ளதால் அரசு, தந்தை அல்லது உயர் அதிகாரிகளால் சிறு தடைகள் அல்லது காலதாமதம் ஏற்படலாம்.';
          break;
        case 'Moon':
          meaning = 'சந்திரன் கவிப்பில் உள்ளதால் மனக்குழப்பம், இடமாற்ற சலனம் அல்லது தாய் வழி கவலைகள் தோன்றலாம்.';
          break;
        case 'Mars':
          meaning = 'செவ்வாய் கவிப்பில் உள்ளதால் நிலம், சகோதரர் அல்லது அவசர கோபத்தால் காரியத்தில் பின்னடைவு வரலாம்.';
          break;
        case 'Mercury':
          meaning = 'புதன் கவிப்பில் உள்ளதால் தகவல் பரிமாற்றம், ஒப்பந்தம் அல்லது வணிக பேச்சுவார்த்தைகளில் தெளிவின்மை ஏற்படலாம்.';
          break;
        case 'Jupiter':
          meaning = 'குரு கவிப்பில் உள்ளதால் பொருளாதார வரவு அல்லது குழந்தைகள் தொடர்பான விவகாரங்களில் காலதாமதம் ஏற்படலாம்.';
          break;
        case 'Venus':
          meaning = 'சுக்கிரன் கவிப்பில் உள்ளதால் திருமணம், வாகனம் அல்லது பெண் தொடர்பான விவகாரங்களில் நிதானம் அவசியம்.';
          break;
        case 'Saturn':
          meaning = 'சனி கவிப்பில் உள்ளதால் தொழிலில் மந்த நிலை அல்லது கீழ்நிலை பணியாளர்களால் பொறுப்பு கூடும்.';
          break;
        case 'Rahu':
          meaning = 'ராகு கவிப்பில் உள்ளதால் மாயை, தவறான ஆலோசனைகள் அல்லது புதிய மனிதர்களை நம்புவதில் விழிப்புணர்வு தேவை.';
          break;
        case 'Ketu':
          meaning = 'கேது கவிப்பில் உள்ளதால் ஆன்மீக ஈடுபாட்டால் பக்குவம் ஏற்படும், உலகியல் காரியங்களில் சற்றே விலகல் தோன்றும்.';
          break;
        default:
          meaning = '${p.nameTa} கவிப்பில் உள்ளதால் அதன் காரக வழியில் விழிப்புணர்வு தேவை.';
      }

      result.add(JamakolArudamPrediction(
        title: '${p.nameTa} கவிப்பில் அமர்ந்த பலன்',
        pointName: 'கவிப்பு',
        planetName: p.nameTa,
        ruleType: 'Planet-in-Kavippu',
        interpretationTa: meaning,
        isFavorable: false,
      ));
    }

    if (result.isEmpty) {
      result.add(JamakolArudamPrediction(
        title: 'கவிப்பு தோஷம் அற்ற நிலை',
        pointName: 'கவிப்பு',
        ruleType: 'Kavippu-Clean',
        interpretationTa: 'கவிப்பு ராசியில் நேரடி கிரக அமர்வுகள் இல்லை. காரியத் தடைகள் குறைந்து சுமுகமான சூழல் நிலவும்.',
        isFavorable: true,
      ));
    }

    return result;
  }

  /// Generate overall summary of question success
  static String generateGeneralSummary({
    required JamakolArudamCorePoint udhayam,
    required JamakolArudamCorePoint aarudam,
    required JamakolArudamCorePoint kavippu,
    required String jamamLordTa,
    required bool isDay,
  }) {
    final int relHouse = ((aarudam.rasiIndex - udhayam.rasiIndex + 12) % 12) + 1;
    final buffer = StringBuffer();

    buffer.write('பிரசன்ன கேள்விக்கான ஜாமகோள் முறை 1 கணிப்பின்படி, ');
    if (relHouse == 1 || relHouse == 5 || relHouse == 9 || relHouse == 11) {
      buffer.write('ஆருடம் உதயத்திற்கு சுப ஸ்தானத்தில் ($relHouse-ஆம் பாவம்) அமைந்திருப்பதால் காரியம் மிகச் சிறப்பான வெற்றியை அடையும். ');
    } else if (relHouse == 4 || relHouse == 7 || relHouse == 10 || relHouse == 2) {
      buffer.write('ஆருடம் உதயத்திற்கு கேந்திர/தன ஸ்தானத்தில் ($relHouse-ஆம் பாவம்) உள்ளதால் முறையான அணுகுமுறையால் செயல் நன்மையில் முடியும். ');
    } else {
      buffer.write('ஆருடம் உதயத்திற்கு மறைவு ஸ்தானத்தில் ($relHouse-ஆம் பாவம்) உள்ளதால் கால அவகாசமும் நிதானமும் தேவை. ');
    }

    buffer.write('நடப்பு ${isDay ? "பகல்" : "இரவு"} ஜாம அதிபதி $jamamLordTa காரிய சூழலை வழிநடத்துகிறார்.');
    return buffer.toString();
  }

  /// Calculate favorable signs
  static List<String> getFavorableSigns(int udhayamRasiIdx, int aarudamRasiIdx) {
    final Set<int> indices = {
      udhayamRasiIdx,
      (udhayamRasiIdx + 4) % 12,
      (udhayamRasiIdx + 8) % 12,
      aarudamRasiIdx,
      (aarudamRasiIdx + 4) % 12,
      (aarudamRasiIdx + 8) % 12,
      (udhayamRasiIdx + 10) % 12,
    };
    return indices.map((idx) => AstrologyCalculator.rasiNamesTa[idx]).toList();
  }

  /// Calculate obstructive signs
  static List<String> getObstructiveSigns(int kavippuRasiIdx, int udhayamRasiIdx) {
    final Set<int> indices = {
      kavippuRasiIdx,
      (udhayamRasiIdx + 5) % 12, // 6th from udhayam
      (udhayamRasiIdx + 7) % 12, // 8th from udhayam
    };
    return indices.map((idx) => AstrologyCalculator.rasiNamesTa[idx]).toList();
  }
}
