import '../models/numerology_model.dart';

/// Calculation Service for Numerology (Birth Number, Life Path Number, and Name Number)
class NumerologyCalculator {
  /// Planet Lords for numbers 1 to 9
  static const Map<int, String> numberLordsTa = {
    1: 'சூரியன் (Sun)',
    2: 'சந்திரன் (Moon)',
    3: 'குரு (Jupiter)',
    4: 'ராகு (Rahu)',
    5: 'புதன் (Mercury)',
    6: 'சுக்கிரன் (Venus)',
    7: 'கேது (Ketu)',
    8: 'சனி (Saturn)',
    9: 'செவ்வாய் (Mars)',
  };

  /// Chaldean Letter Values Map (1 to 8, 9 is sacred and excluded from direct letters)
  static const Map<String, int> chaldeanLetterValues = {
    'A': 1, 'I': 1, 'J': 1, 'Q': 1, 'Y': 1,
    'B': 2, 'K': 2, 'R': 2,
    'C': 3, 'G': 3, 'L': 3, 'S': 3,
    'D': 4, 'M': 4, 'T': 4,
    'E': 5, 'H': 5, 'N': 5, 'X': 5,
    'U': 6, 'V': 6, 'W': 6,
    'O': 7, 'Z': 7,
    'F': 8, 'P': 8,
  };

  /// Pythagorean Letter Values Map (1 to 9)
  static const Map<String, int> pythagoreanLetterValues = {
    'A': 1, 'B': 2, 'C': 3, 'D': 4, 'E': 5, 'F': 6, 'G': 7, 'H': 8, 'I': 9,
    'J': 1, 'K': 2, 'L': 3, 'M': 4, 'N': 5, 'O': 6, 'P': 7, 'Q': 8, 'R': 9,
    'S': 1, 'T': 2, 'U': 3, 'V': 4, 'W': 5, 'X': 6, 'Y': 7, 'Z': 8,
  };

  /// Numerology Number Traits
  static const Map<int, String> numberTraitsTa = {
    1: 'தலைமைத்துவம், தன்னம்பிக்கை, புதுமை, உறுதி, கௌரவம்',
    2: 'கற்பனை, மென்மை, சமாதானம், கலை ரசனை, கூட்டுறவு',
    3: 'ஞானம், அறிவு, ஆசிரியர் தன்மை, நேர்மை, வளர்ச்சி',
    4: 'திட்டமிடுதல், கடின உழைப்பு, புரட்சி, தொழில்நுட்பம்',
    5: 'புத்தி கூர்மை, வேகம், வியாபாரம், தொடர்பு, பயணம்',
    6: 'அழகு, ஆடம்பரம், காதல், குடும்ப நலம், கவர்ச்சி',
    7: 'ஆராய்ச்சி, ஆன்மீகம், தத்துவம், தனிமை சிந்தனை',
    8: 'நீதி, பொறுமை, ஆளுமை, பொருள் வளம், விடாமுயற்சி',
    9: 'தைரியம், வீரம், தியாகம், மனிதாபிமானம், ஆற்றல்',
  };

  /// Number Compatibility Maps (Friendly, Enemy, Neutral)
  static const Map<int, List<int>> friendlyNumbersMap = {
    1: [1, 2, 3, 9],
    2: [1, 2, 5],
    3: [1, 2, 3, 9],
    4: [5, 6, 7, 8],
    5: [1, 5, 6],
    6: [4, 5, 6, 7],
    7: [1, 2, 4, 7],
    8: [4, 5, 6],
    9: [1, 2, 3, 9],
  };

  static const Map<int, List<int>> enemyNumbersMap = {
    1: [6, 8],
    2: [8, 9],
    3: [6],
    4: [1, 2, 9],
    5: [2],
    6: [1, 3],
    7: [9],
    8: [1, 2],
    9: [2, 4, 7],
  };

  /// Calculate Full Numerology Report
  static NumerologyResult calculate({
    required DateTime birthDate,
    required String name,
    NumerologySystem system = NumerologySystem.chaldean,
  }) {
    // 1. Birth Number (Moolank / Janmank): Reduced Day of Month (1..31)
    final int rawDay = birthDate.day;
    final int birthNumber = _reduceToSingleDigit(rawDay);

    // 2. Life Path Number (Destiny / Bhagyank): Sum of Date + Month + Year
    final int totalDateSum = rawDay + birthDate.month + birthDate.year;
    final int lifePathNumber = _reduceToSingleDigit(totalDateSum);

    // 3. Name Number (Namank): Sum of letter values in the name
    final cleanName = name.toUpperCase().replaceAll(RegExp(r'[^A-Z]'), '');
    int compoundNameSum = 0;

    final letterMap = (system == NumerologySystem.chaldean) ? chaldeanLetterValues : pythagoreanLetterValues;

    for (int i = 0; i < cleanName.length; i++) {
      final char = cleanName[i];
      compoundNameSum += letterMap[char] ?? 0;
    }

    if (compoundNameSum == 0) compoundNameSum = 37; // fallback default
    final int nameNumber = _reduceToSingleDigit(compoundNameSum);

    final friendly = friendlyNumbersMap[birthNumber] ?? [1, 5];
    final enemy = enemyNumbersMap[birthNumber] ?? [8];
    final neutral = [1, 2, 3, 4, 5, 6, 7, 8, 9].where((n) => !friendly.contains(n) && !enemy.contains(n)).toList();

    // Lucky properties based on Birth Number
    final luckyProps = _getLuckyProperties(birthNumber);

    return NumerologyResult(
      birthDate: birthDate,
      personName: name.isNotEmpty ? name : 'Divine Seeker',
      system: system,
      birthNumber: birthNumber,
      birthNumberLordTa: numberLordsTa[birthNumber] ?? '',
      birthNumberTraitTa: numberTraitsTa[birthNumber] ?? '',
      lifePathNumber: lifePathNumber,
      lifePathLordTa: numberLordsTa[lifePathNumber] ?? '',
      lifePathTraitTa: numberTraitsTa[lifePathNumber] ?? '',
      nameNumber: nameNumber,
      nameCompoundNumber: compoundNameSum,
      nameNumberLordTa: numberLordsTa[nameNumber] ?? '',
      nameNumberVibrationTa: 'கூட்டு எண் $compoundNameSum -> ஒற்றை எண் $nameNumber (${numberLordsTa[nameNumber]})',
      friendlyNumbers: friendly,
      enemyNumbers: enemy,
      neutralNumbers: neutral,
      luckyColorsTa: luckyProps['colors'] as List<String>,
      luckyGemsTa: luckyProps['gems'] as List<String>,
      luckyDaysTa: luckyProps['days'] as List<String>,
      luckyDates: luckyProps['dates'] as List<int>,
      careerGuidanceTa: luckyProps['career'] as String,
    );
  }

  /// Reduce a number to a single digit (1..9)
  static int _reduceToSingleDigit(int n) {
    int sum = n;
    while (sum > 9) {
      int currentSum = 0;
      int temp = sum;
      while (temp > 0) {
        currentSum += temp % 10;
        temp ~/= 10;
      }
      sum = currentSum;
    }
    return sum == 0 ? 1 : sum;
  }

  static Map<String, dynamic> _getLuckyProperties(int num) {
    switch (num) {
      case 1:
        return {
          'colors': ['தங்கம்', 'மஞ்சள்', 'ஆரஞ்சு', 'வெளிர் சிவப்பு'],
          'gems': ['மாணிக்கம் (Ruby)', 'கெம்பு'],
          'days': ['ஞாயிறு', 'திங்கள்'],
          'dates': [1, 10, 19, 28],
          'career': 'அரசுப் பணி, நிர்வாகம், தலைமைப் பொறுப்புகள், மருத்துவம், அரசியல், தொழில் முனைவோர்.',
        };
      case 2:
        return {
          'colors': ['வெள்ளை', 'கிரீம்', 'வெள்ளி', 'வெளிர் பச்சை'],
          'gems': ['முத்து (Pearl)', 'சந்திரகாந்தக் கல்'],
          'days': ['திங்கள்', 'வெள்ளி'],
          'dates': [2, 11, 20, 29],
          'career': 'கலை, கவிதை, எழுத்து, உணவு மற்றும் ஹோட்டல் துறை, ஆடை வடிவமைப்பு, உளவியல்.',
        };
      case 3:
        return {
          'colors': ['மஞ்சள்', 'தங்க நிறம்', 'ரோஸ்'],
          'gems': ['புஷ்பராகம் (Yellow Sapphire)', 'டோபாஸ்'],
          'days': ['வியாழன்', 'செவ்வாய்'],
          'dates': [3, 12, 21, 30],
          'career': 'கல்வி, ஆசிரியர், சட்டம், ஆன்மீக உரை, நிதி ஆலோசனை, வங்கித் துறை.',
        };
      case 4:
        return {
          'colors': ['நீலம்', 'சாம்பல்', 'பழுப்பு'],
          'gems': ['கோமேதகம் (Hessonite)', 'நீலக்கல்'],
          'days': ['ஞாயிறு', 'புதன்'],
          'dates': [4, 13, 22, 31],
          'career': 'மென்பொருள் (IT), ஆராய்ச்சி, எலக்ட்ரானிக்ஸ், வடிவமைப்பு, பத்திரிகை.',
        };
      case 5:
        return {
          'colors': ['பச்சை', 'சாம்பல்', 'வெள்ளை'],
          'gems': ['மரகதம் (Emerald)', 'பச்சை டூர்மலைன்'],
          'days': ['புதன்', 'வெள்ளி'],
          'dates': [5, 14, 23],
          'career': 'வியாபாரம், பங்குச்சந்தை, தகவல் தொடர்பு, மக்கள் தொடர்பு, மீடியா, பேச்சாற்றல்.',
        };
      case 6:
        return {
          'colors': ['வெளிர் நீலம்', 'வெள்ளை', 'ரோஸ்', 'பளபளப்பான நிறங்கள்'],
          'gems': ['வைரம் (Diamond)', 'வெள்ளை ஜிர்கான்'],
          'days': ['வெள்ளி', 'செவ்வாய்'],
          'dates': [6, 15, 24],
          'career': 'சினிமா, கலை, ஆபரணத் தொழில், ஆடை வடிவமைப்பு, அழகுக்கலை, ஆடம்பர பொருட்கள்.',
        };
      case 7:
        return {
          'colors': ['வெளிர் பச்சை', 'வெள்ளை', 'சாம்பல்'],
          'gems': ['வைடூரியம் (Cat\'s Eye)', 'மூன்ஸ்டோன்'],
          'days': ['திங்கள்', 'வியாழன்'],
          'dates': [7, 16, 25],
          'career': 'ஆராய்ச்சி, தத்துவம், யோகா, இயற்கை மருத்துவம், கடல் சார் தொழில், ஜோதிடம்.',
        };
      case 8:
        return {
          'colors': ['கருநீலம்', 'கருப்பு', 'சாம்பல்'],
          'gems': ['நீலம் (Blue Sapphire)', 'அமெதிஸ்ட்'],
          'days': ['சனி', 'வெள்ளி'],
          'dates': [8, 17, 26],
          'career': 'கட்டுமானம், இரும்பு, இயந்திரங்கள், எண்ணெய், நில வணிகம், சட்டம், விவசாயம்.',
        };
      case 9:
      default:
        return {
          'colors': ['சிவப்பு', 'மெரூன்', 'ரோஸ்'],
          'gems': ['பவளம் (Coral)', 'ரெட் ஜாஸ்பர்'],
          'days': ['செவ்வாய்', 'வியாழன்'],
          'dates': [9, 18, 27],
          'career': 'ராணுவம், காவல் துறை, விளையாட்டு, அறுவை சிகிச்சை, ரியல் எஸ்டேட், தீயணைப்பு.',
        };
    }
  }
}
