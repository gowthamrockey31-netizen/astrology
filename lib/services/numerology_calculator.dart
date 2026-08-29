import '../models/numerology_model.dart';

/// Calculation Service for Numerology (Birth Number, Life Path Number, Name Number & Personal Cycles)
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

  /// Numerology Number Core Traits
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
    11: 'ஆன்மீக விழிப்புணர்வு, உயர் உள்ளுணர்வு, தீவிர சக்தி (Master Number)',
    22: 'பெரும் சாதனை, உலகளாவிய திட்டமிடல், தலைமை ஆளுமை (Master Builder)',
    33: 'சேவை மனப்பான்மை, ஆன்மீக ஒளி, உயர்ந்த குரு அருள் (Master Teacher)',
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

  /// Compound Number Database (Authoritative Chaldean/Vedic meanings)
  static const Map<int, Map<String, String>> compoundMeanings = {
    10: {
      'title': 'அதிர்ஷ்ட சக்கரம் (Wheel of Fortune)',
      'desc': 'சுய கௌரவம், புதுமையான தொடக்கம், முன்னேற்றம் மற்றும் சமூக மதிப்பு கொண்ட எண்.',
    },
    11: {
      'title': 'உயரிய உள்ளுணர்வு (Master Number)',
      'desc': 'ஆன்மீக விழிப்புணர்வு, மறைமுக எச்சரிக்கை, சோதனைகளைக் கடந்து சாதிக்கும் மன வலிமை.',
    },
    12: {
      'title': 'தியாகமும் அறிவும் (The Sacrifice)',
      'desc': 'பொறுமை, பிறருக்கு வழிகாட்டும் ஆளுமை, திட்டமிட்ட உழைப்பால் உயர்வு.',
    },
    13: {
      'title': 'மாற்றத்தின் குறியீடு (Transformation)',
      'desc': 'திடீர் திருப்பங்கள், சூழ்நிலைகளுக்கு ஏற்ப மாறும் தன்மை, விடாமுயற்சியால் பெரும் வெற்றி.',
    },
    14: {
      'title': 'இயக்கம் மற்றும் வர்த்தகம் (Movement)',
      'desc': 'வியாபாரம், தொடர்பு, பயணம், பணப் புழக்கத்தில் விவேகம் தேவைப்படும் எண்.',
    },
    15: {
      'title': 'கலையும் வசீகரமும் (The Magician)',
      'desc': 'சுக்கிரனின் பரிபூரண அருள், கவர்ச்சி, கலைத்துறை மேன்மை மற்றும் பண வளம் தரும் எண்.',
    },
    16: {
      'title': 'விழிப்புணர்வும் மறுமலர்ச்சியும் (Shattered Citadel)',
      'desc': 'ஆன்மீக சிந்தனை, விழிப்புணர்வுடன் முடிவெடுத்தல், சுய ஆளுமையால் வளர்ச்சி.',
    },
    17: {
      'title': 'அதிர்ஷ்ட நட்சத்திரம் (Star of the Magi)',
      'desc': 'அமைதி, நம்பிக்கை, ஆன்மீக உயர்நிலை, காலத்தால் அழியாத நற்புகழ் தரும் உன்னத எண்.',
    },
    18: {
      'title': 'உள்மன வலிமை (Spiritual Conflict)',
      'desc': 'துணிச்சல், எச்சரிக்கையான கூட்டுறவு, கடின உழைப்பால் வெற்றியை எட்டும் ஆற்றல்.',
    },
    19: {
      'title': 'வெற்றியின் இளவரசன் (Prince of Heaven)',
      'desc': 'சூரியனின் அதீத அருள், பெரும் வெற்றி, செல்வாக்கு மற்றும் அனைத்து நன்மைகளும் தரும் அதிர்ஷ்ட எண்.',
    },
    20: {
      'title': 'விழிப்புணர்வு (The Awakening)',
      'desc': 'புதிய திட்டங்கள், நியாயமான செயல்பாடுகள், அமைதியான குடும்ப வாழ்க்கை.',
    },
    21: {
      'title': 'முழுமையான கிரீடம் (Crown of the Magi)',
      'desc': 'நீண்ட கால உழைப்புக்குக் கிடைக்கும் உயரிய வெற்றி, சமூக அந்தஸ்து, முன்னேற்றம்.',
    },
    22: {
      'title': 'மாபெரும் சாதனையாளர் (Master Builder)',
      'desc': 'உலகளாவிய பார்வை, பெரிய திட்டங்களை நிறைவேற்றும் ஆற்றல், நடைமுறைத் தலைமை.',
    },
    23: {
      'title': 'சிங்கத்தின் ராஜ நட்சத்திரம் (Royal Star of the Lion)',
      'desc': 'உயர் அதிகாரிகளின் ஆதரவு, அனைத்து முயற்சிகளிலும் தொடர் வெற்றி, செல்வாக்கு.',
    },
    24: {
      'title': 'அன்பும் செல்வமும் (Love & Money)',
      'desc': 'குடும்ப மகிழ்ச்சி, நிதி ஸ்திரத்தன்மை, கலை ஈர்ப்பு, உயர்மட்ட நபர்களின் உதவி.',
    },
    25: {
      'title': 'அனுபவ அறிவு (Discrimination & Analysis)',
      'desc': 'சுய அனுபவத்தால் ஞானம், ஆன்மீக நாட்டம், தீவிர ஆராய்ச்சித் திறன்.',
    },
    26: {
      'title': 'நீதியும் கூட்டுறவும் (Partnerships)',
      'desc': 'நிதானமான கூட்டுறவு, நேர்மை, கவனமான நிதி மேலாண்மை தேவைப்படும் எண்.',
    },
    27: {
      'title': 'செங்கோல் மற்றும் ஆளுமை (The Sceptre)',
      'desc': 'தலைமைப் பண்பு, தளராத முயற்சி, நிர்வாகத் திறன் மற்றும் அதிகார வளம்.',
    },
    28: {
      'title': 'விவேகமும் கவனமும் (The Trusting Lamb)',
      'desc': 'கவனமான நிதி முடிவுகள், புதிய முதலீடுகளில் விவேகம், உழைப்பால் உயர்வு.',
    },
    29: {
      'title': 'பொறுமையும் கருணையும் (Grace under Trial)',
      'desc': 'ஆன்மீக வலிமை, பொறுமை, சோதனைகளை நேர்மறையாக மாற்றும் ஆற்றல்.',
    },
    30: {
      'title': 'அறிவும் புகழும் (Intellectual Power)',
      'desc': 'எழுத்து, கல்வி, சிந்தனை வளம், ஆசிரியர் பணி, நற்பெயர் மற்றும் சிந்தனைத் தெளிவு.',
    },
    31: {
      'title': 'தனித்துவமான சிந்தனை (The Recluse)',
      'desc': 'சுய சார்பு, ஆழமான சிந்தனை, தனித்துவமான பாதையில் சென்று சாதிக்கும் தன்மை.',
    },
    32: {
      'title': 'மக்கள் செல்வாக்கு (Communication & Power)',
      'desc': 'பொது வாழ்க்கை வெற்றி, வியாபார வளம், மக்கள் தொடர்பு மற்றும் பேச்சாற்றல்.',
    },
    33: {
      'title': 'குருவின் மாபெரும் அருள் (Master Teacher)',
      'desc': 'சேவை மனப்பான்மை, ஆன்மீக ஒளி, உயர்ந்த வழிகாட்டுதல், தர்ம சிந்தனை.',
    },
    34: {
      'title': 'உழைப்பால் வளர்ச்சி (Strength through Effort)',
      'desc': '25-ன் நற்பண்புகள், படிப்படியான முன்னேற்றம், நேர்மையான உழைப்பு.',
    },
    35: {
      'title': 'செழிப்பும் மாற்றமும் (Material Gains)',
      'desc': 'வர்த்தகம், புதிய முயற்சிகள், முதலீடுகளில் முன்னேற்றம் தரும் எண்.',
    },
    36: {
      'title': 'கலை மற்றும் வெற்றி (Artistic Triumph)',
      'desc': 'கலைத்துறை வெற்றி, நிர்வாகத் திறமை, சுக்கிரன்-குருவின் இணைவு தரும் நற்பலன்.',
    },
    37: {
      'title': 'நட்பும் அதிர்ஷ்டமும் (Good Friendship & Luck)',
      'desc': 'சிறந்த நட்பு வட்டம், கூட்டுத் தொழில் மேன்மை, மகிழ்ச்சி மற்றும் அமைதி தரும் எண்.',
    },
    38: {
      'title': 'அமைதியும் விவேகமும் (Peace & Caution)',
      'desc': 'நிதானமான செயல்பாடு, நட்பு தேர்வில் கவனம், அமைதியான முன்னேற்றம்.',
    },
    39: {
      'title': 'வெற்றியாளர் (The Victor)',
      'desc': 'போராட்டங்களைக் கடந்து வெற்றி, ஆரோக்கியம், விடாமுயற்சியால் தலைமைப் பொறுப்பு.',
    },
    40: {
      'title': 'உறுதியான அடித்தளம் (Stability)',
      'desc': 'ஒழுக்கம், உறுதியான கொள்கைகள், நிலையான அடித்தளத்தில் கட்டப்படும் வெற்றி.',
    },
    41: {
      'title': 'வணிகத்தில் மேன்மை (Business Success)',
      'desc': '32-ன் சக்தி வாய்ந்த அதிர்வு, வியாபாரத்தில் அபார வளர்ச்சி, பேச்சாற்றல்.',
    },
    42: {
      'title': 'குடும்ப நன்மையும் அன்பும் (Love & Harmony)',
      'desc': '24-ன் அதிர்வு, குடும்ப அமைதி, அன்பு, கலை ஈடுபாடு மற்றும் நிதி பலம்.',
    },
    43: {
      'title': 'திட்டமிட்ட உழைப்பு (Hard Work)',
      'desc': 'பொறுமையுடன் கூடிய தொடர் செயல்பாடு, நடைமுறை சிந்தனை.',
    },
    44: {
      'title': 'இரு மடங்கு சக்தி (Master Vibrations)',
      'desc': 'பெரும் பொறுப்புகள், தொழில்துறை மேன்மை, உலகளாவிய சிந்தனை.',
    },
    45: {
      'title': 'ஞானமும் சமூக மதிப்பும் (Wisdom & Honor)',
      'desc': '27-ன் அதிர்வு, தர்ம சிந்தனை, சமூகத்தில் உயர்ந்த கௌரவம் மற்றும் வெற்றி.',
    },
    46: {
      'title': 'கவர்ச்சியும் செல்வாக்கும் (Popularity)',
      'desc': 'மக்கள் ஈர்ப்பு, கலை மற்றும் வர்த்தகத்தில் வெற்றி, பொருளாதார மேன்மை.',
    },
    47: {
      'title': 'ஆன்மீக உண்மை (Inner Truth)',
      'desc': 'ஆராய்ச்சி மற்றும் தத்துவ நாட்டம், உள்ளுணர்வு வளர்ச்சி, தெளிவான சிந்தனை.',
    },
    48: {
      'title': 'நீதியான உழைப்பு (Justice & Effort)',
      'desc': 'சனி-ராகு இணைவு, நேர்மையான உழைப்பால் பெரும் பண வளம்.',
    },
    49: {
      'title': 'ஆன்மீகத் தெளிவு (Spiritual Wisdom)',
      'desc': 'உள்மன அமைதி, உயர்ந்த எண்ணங்கள், ஆன்மீக ஈடுபாடு.',
    },
    50: {
      'title': 'சுதந்திரமும் வேகமும் (Communication & Liberty)',
      'desc': 'சுறுசுறுப்பு, பல்துறை அறிவு, புதிய சூழல்களை எளிதில் கையாளுதல்.',
    },
    51: {
      'title': 'தளபதி போன்ற வெற்றி (The Commander)',
      'desc': 'அஞ்சா நெஞ்சம், நிர்வாக மேன்மை, போட்டிகளில் அபார வெற்றி.',
    },
    52: {
      'title': 'அனுபவத்தால் உயர்வு (Experience)',
      'desc': 'பொறுமை, வாழ்க்கை அனுபவங்களால் வழிநடத்தப்படும் வெற்றி.',
    },
  };

  /// Centralized Number Reducer Method
  /// Supports:
  /// - Normal digit reduction (e.g. 1996 -> 25 -> 7)
  /// - Compound number preservation (immediate 2-digit sum)
  /// - Optional Master Number handling (11, 22, 33)
  static NumberReductionResult reduceNumber(
    int value, {
    bool preserveMasterNumbers = false,
  }) {
    if (value <= 0) {
      return const NumberReductionResult(
        originalValue: 0,
        compoundValue: 1,
        reducedValue: 1,
        isMasterNumber: false,
        stepSums: [1],
      );
    }

    if (value <= 9) {
      return NumberReductionResult(
        originalValue: value,
        compoundValue: value,
        reducedValue: value,
        isMasterNumber: false,
        stepSums: [value],
      );
    }

    final List<int> steps = [value];
    int current = value;
    int firstCompound = value;

    while (current > 9) {
      if (preserveMasterNumbers && (current == 11 || current == 22 || current == 33)) {
        return NumberReductionResult(
          originalValue: value,
          compoundValue: firstCompound,
          reducedValue: current,
          isMasterNumber: true,
          stepSums: steps,
        );
      }

      int sum = 0;
      int temp = current;
      while (temp > 0) {
        sum += temp % 10;
        temp ~/= 10;
      }

      if (firstCompound == value && sum > 9) {
        firstCompound = sum;
      }

      current = sum;
      steps.add(current);
    }

    final int finalReduced = current == 0 ? 1 : current;

    return NumberReductionResult(
      originalValue: value,
      compoundValue: (value > 9 && value <= 99) ? value : (firstCompound > 9 ? firstCompound : finalReduced),
      reducedValue: finalReduced,
      isMasterNumber: false,
      stepSums: steps,
    );
  }

  /// Reduce to single digit helper
  static int _reduceToSingleDigit(int n, {bool preserveMasterNumbers = false}) {
    return reduceNumber(n, preserveMasterNumbers: preserveMasterNumbers).reducedValue;
  }

  /// Get Compound Number Details
  static CompoundNumberDetail getCompoundDetail(int compoundNum, int reducedNum) {
    final existing = compoundMeanings[compoundNum];
    if (existing != null) {
      return CompoundNumberDetail(
        number: compoundNum,
        reducedNumber: reducedNum,
        lordTa: numberLordsTa[reducedNum] ?? '',
        titleTa: existing['title'] ?? 'கூட்டு எண் $compoundNum',
        descriptionTa: existing['desc'] ?? '',
      );
    }

    final lord = numberLordsTa[reducedNum] ?? '';
    final trait = numberTraitsTa[reducedNum] ?? '';
    return CompoundNumberDetail(
      number: compoundNum,
      reducedNumber: reducedNum,
      lordTa: lord,
      titleTa: 'கூட்டு எண் $compoundNum ($lord)',
      descriptionTa: 'கூட்டு எண் $compoundNum மூல எண் $reducedNum-ன் ஆற்றலைக் குறிக்கிறது. முக்கிய இயல்பு: $trait.',
    );
  }

  /// Calculate Personal Cycles (Personal Year, Month, Day)
  static PersonalCycleResult calculatePersonalCycles({
    required DateTime birthDate,
    int? targetYear,
    int? targetMonth,
    int? targetDay,
  }) {
    final now = DateTime.now();
    final year = targetYear ?? now.year;
    final month = targetMonth ?? now.month;
    final day = targetDay ?? now.day;

    // Formula:
    // Personal Year = Birth Day + Birth Month + Target Year
    final pYearRaw = birthDate.day + birthDate.month + year;
    final pYearReduction = reduceNumber(pYearRaw);

    // Personal Month = Personal Year Number + Target Month
    final pMonthRaw = pYearReduction.reducedValue + month;
    final pMonthReduction = reduceNumber(pMonthRaw);

    // Personal Day = Personal Month Number + Target Day
    final pDayRaw = pMonthReduction.reducedValue + day;
    final pDayReduction = reduceNumber(pDayRaw);

    return PersonalCycleResult(
      targetYear: year,
      targetMonth: month,
      targetDay: day,
      personalYear: pYearReduction,
      personalMonth: pMonthReduction,
      personalDay: pDayReduction,
      personalYearDescriptionTa: _getPersonalYearMeaning(pYearReduction.reducedValue),
      personalMonthDescriptionTa: _getPersonalMonthMeaning(pMonthReduction.reducedValue),
      personalDayDescriptionTa: _getPersonalDayMeaning(pDayReduction.reducedValue),
    );
  }

  /// Calculate Full Numerology Report
  static NumerologyResult calculate({
    required DateTime birthDate,
    required String name,
    NumerologySystem system = NumerologySystem.chaldean,
    int? targetYear,
    int? targetMonth,
    int? targetDay,
    bool supportMasterNumbers = false,
  }) {
    // 1. Birth Number (Moolank / Janmank): from Day of Birth (1..31)
    final int rawDay = birthDate.day;
    final birthReduction = reduceNumber(rawDay, preserveMasterNumbers: false);
    final int birthNumber = birthReduction.reducedValue;

    // 2. Life Path Number (Destiny / Bhagyank): Sum of Date + Month + Year
    final int totalDateSum = rawDay + birthDate.month + birthDate.year;
    final lifePathReduction = reduceNumber(totalDateSum, preserveMasterNumbers: supportMasterNumbers);
    final int lifePathNumber = lifePathReduction.reducedValue;

    // 3. Attitude Number (Sun Number): Day + Month
    final int attitudeRaw = rawDay + birthDate.month;
    final attitudeReduction = reduceNumber(attitudeRaw, preserveMasterNumbers: false);
    final int attitudeNumber = attitudeReduction.reducedValue;

    // 4. Name Number (Namank): Sum of letter values
    final cleanName = name.toUpperCase();
    final letterMap = (system == NumerologySystem.chaldean)
        ? chaldeanLetterValues
        : pythagoreanLetterValues;

    final List<NameLetterValue> letterBreakdown = [];
    int compoundNameSum = 0;

    for (int i = 0; i < cleanName.length; i++) {
      final char = cleanName[i];
      if (letterMap.containsKey(char)) {
        final val = letterMap[char]!;
        compoundNameSum += val;
        letterBreakdown.add(NameLetterValue(letter: char, value: val));
      }
    }

    if (compoundNameSum == 0 && cleanName.isNotEmpty) {
      compoundNameSum = 37; // fallback default if no mapped letters
    } else if (compoundNameSum == 0) {
      compoundNameSum = 1;
    }

    final nameReduction = reduceNumber(compoundNameSum, preserveMasterNumbers: supportMasterNumbers);
    final int nameNumber = nameReduction.reducedValue;

    // 5. Personal Cycles
    final personalCycles = calculatePersonalCycles(
      birthDate: birthDate,
      targetYear: targetYear,
      targetMonth: targetMonth,
      targetDay: targetDay,
    );

    // 6. Compound Number Details
    final birthCompoundDetail = rawDay > 9 ? getCompoundDetail(rawDay, birthNumber) : null;
    final lifePathCompoundDetail = getCompoundDetail(lifePathReduction.compoundValue, lifePathNumber);
    final nameCompoundDetail = getCompoundDetail(compoundNameSum, nameNumber);

    // 7. Compatibility & Lucky Guidance based on Birth Number
    final friendly = friendlyNumbersMap[birthNumber] ?? [1, 5];
    final enemy = enemyNumbersMap[birthNumber] ?? [8];
    final neutral = [1, 2, 3, 4, 5, 6, 7, 8, 9]
        .where((n) => !friendly.contains(n) && !enemy.contains(n))
        .toList();

    final luckyProps = _getLuckyProperties(birthNumber);

    final personDisplayName = name.trim().isNotEmpty ? name.trim() : 'Divine Seeker';

    return NumerologyResult(
      birthDate: birthDate,
      personName: personDisplayName,
      system: system,
      birthNumber: birthNumber,
      birthCompoundNumber: rawDay,
      birthReduction: birthReduction,
      birthNumberLordTa: numberLordsTa[birthNumber] ?? '',
      birthNumberTraitTa: numberTraitsTa[birthNumber] ?? '',
      lifePathNumber: lifePathNumber,
      lifePathCompoundNumber: lifePathReduction.compoundValue,
      lifePathReduction: lifePathReduction,
      lifePathLordTa: numberLordsTa[lifePathNumber] ?? '',
      lifePathTraitTa: numberTraitsTa[lifePathNumber] ?? '',
      attitudeNumber: attitudeNumber,
      attitudeReduction: attitudeReduction,
      attitudeLordTa: numberLordsTa[attitudeNumber] ?? '',
      attitudeTraitTa: numberTraitsTa[attitudeNumber] ?? '',
      nameNumber: nameNumber,
      nameCompoundNumber: compoundNameSum,
      nameReduction: nameReduction,
      letterBreakdown: letterBreakdown,
      nameNumberLordTa: numberLordsTa[nameNumber] ?? '',
      nameNumberVibrationTa: 'கூட்டு எண் $compoundNameSum -> ஒற்றை எண் $nameNumber (${numberLordsTa[nameNumber]})',
      personalCycles: personalCycles,
      birthCompoundDetail: birthCompoundDetail,
      lifePathCompoundDetail: lifePathCompoundDetail,
      nameCompoundDetail: nameCompoundDetail,
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

  static String _getPersonalYearMeaning(int py) {
    switch (py) {
      case 1:
        return 'புதிய தொடக்கங்களின் ஆண்டு. புதிய முயற்சிகள், சுய முதலீடுகள் மற்றும் தலைமைப் பொறுப்புகளுக்கு உகந்த காலம்.';
      case 2:
        return 'கூட்டுறவு மற்றும் பொறுமையின் ஆண்டு. நட்புறவு, அமைதியான பேச்சுவார்த்தை மற்றும் திட்டமிடல் சிறப்பு.';
      case 3:
        return 'வளர்ச்சி மற்றும் ஆக்கப்பூர்வ ஆண்டு. சமூக தொடர்பு, கலை ஆர்வம், மகிழ்ச்சி மற்றும் வெளிப்பாடு அதிகரிக்கும்.';
      case 4:
        return 'கடின உழைப்பு மற்றும் அடித்தளத்தின் ஆண்டு. ஒழுக்கம், திட்டமிட்ட சேமிப்பு மற்றும் அமைப்பை உருவாக்குதல்.';
      case 5:
        return 'மாற்றம் மற்றும் சுதந்திரத்தின் ஆண்டு. பயணங்கள், புதிய அனுபவங்கள், மாற்றங்கள் மற்றும் வேகம்.';
      case 6:
        return 'குடும்பம் மற்றும் பொறுப்புகளின் ஆண்டு. குடும்ப மகிழ்ச்சி, இல்லற நலம், அன்பு மற்றும் கடமைகளை ஆற்றுதல்.';
      case 7:
        return 'சுய பரிசீலனை மற்றும் ஆன்மீக ஆண்டு. ஆராய்ச்சி, கல்வி, தனிமை சிந்தனை மற்றும் மன அமைதி.';
      case 8:
        return 'வெற்றி மற்றும் பொருள் வளத்தின் ஆண்டு. தொழில் வளர்ச்சி, நிதி முன்னேற்றம், நிர்வாக ஆளுமை.';
      case 9:
      default:
        return 'முழுமை மற்றும் நிறைவின் ஆண்டு. பழையவற்றை முடித்தல், புதிய கட்டத்திற்கு தயாராகுதல், தர்ம காரியங்கள்.';
    }
  }

  static String _getPersonalMonthMeaning(int pm) {
    switch (pm) {
      case 1:
        return 'புதிய முயற்சிகள் மற்றும் துரித முடிவுகளுக்கான மாதம்.';
      case 2:
        return 'பொறுமை, சமாதானம் மற்றும் உறவுகளை பலப்படுத்தும் மாதம்.';
      case 3:
        return 'பேச்சுத்திறன், மகிழ்ச்சி மற்றும் உற்சாகமான மாதம்.';
      case 4:
        return 'கவனம், திட்டமிட்ட உழைப்பு மற்றும் ஒழுங்குமுறை தேவைப்படும் மாதம்.';
      case 5:
        return 'மாற்றங்கள், பயணங்கள் மற்றும் புதிய வாய்ப்புகள் தேடி வரும் மாதம்.';
      case 6:
        return 'குடும்ப விவகாரங்கள், அழகு, ஆடம்பரம் மற்றும் பொறுப்புகள்.';
      case 7:
        return 'ஆன்மீகம், அமைதி மற்றும் ஆழமான சிந்தனைக்கான மாதம்.';
      case 8:
        return 'நிதி ஆதாயம், வர்த்தக வளர்ச்சி மற்றும் தொழில் மேன்மை.';
      case 9:
      default:
        return 'பணிகளை நிறைவு செய்தல் மற்றும் விவேகமான முடிவுகள் எடுக்கும் மாதம்.';
    }
  }

  static String _getPersonalDayMeaning(int pd) {
    switch (pd) {
      case 1:
        return 'முன்னெடுப்புகள் மற்றும் முக்கிய முடிவுகளுக்கு உகந்த நாள்.';
      case 2:
        return 'அமைதியான பேச்சுவார்த்தை மற்றும் ஒத்துழைப்புக்கு ஏற்ற நாள்.';
      case 3:
        return 'நண்பர்களுடன் உரையாடல், கலை மற்றும் ஆக்கப்பூர்வ பணிகளுக்கு சிறந்தது.';
      case 4:
        return 'நிலுவைப் பணிகளை முடித்து ஒழுங்குபடுத்த உகந்த நாள்.';
      case 5:
        return 'தகவல் தொடர்பு, பயணம் மற்றும் புதிய மனிதர்களை சந்திக்க சாதகமானது.';
      case 6:
        return 'குடும்பத்தினருடன் நேரம் செலவிடவும் இல்லற பணிகளுக்கும் உகந்தது.';
      case 7:
        return 'சுய பரிசீலனை, வாசிப்பு மற்றும் ஆன்மீக வழிபாட்டிற்கு ஏற்ற நாள்.';
      case 8:
        return 'நிதி பரிவர்த்தனைகள், முக்கிய வியாபார முடிவுகளுக்கு சாதகமான நாள்.';
      case 9:
      default:
        return 'பிறருக்கு உதவுதல், பணிகளை நிறைவு செய்தல் மற்றும் நேர்மறை சிந்தனை.';
    }
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
