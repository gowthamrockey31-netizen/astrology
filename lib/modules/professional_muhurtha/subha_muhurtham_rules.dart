// ===============================================================
// SUBHA MUHURTHAM - CONFIGURABLE RULES & REFERENCE DATA
// Centralized Source of Truth for Subha Muhurtham Day Selection
// ===============================================================

/// Rule Presets to handle documented source conflicts
enum MuhurthamRulePreset {
  /// Standard / Canonical (Source List 1):
  /// - 16 Classical Nakshatras (includes Chitra & Swati; excludes Mula)
  /// - Traditional Tithis: 2, 3, 5, 7, 10, 11, 12, 13 (excludes Chaturthi, Shashti, Chaturdashi)
  standard,

  /// Extended Variant (Source List 2):
  /// - 15 Nakshatras (adds Mula; does not explicitly list Chitra & Swati)
  /// - Extended Tithis: 2, 3, 4, 5, 6, 7, 10, 11, 12, 13, 14 (includes Chaturthi, Shashti, Chaturdashi)
  extended,

  /// User customized rules
  custom,
}

/// Centralized Configurable Rules for Subha Muhurtham
class SubhaMuhurthamRules {
  final MuhurthamRulePreset preset;

  /// Allowed Weekdays (1=Mon, 2=Tue, 3=Wed, 4=Thu, 5=Fri, 6=Sat, 7=Sun)
  /// Classical: Sunday(7), Monday(1), Wednesday(3), Thursday(4), Friday(5)
  /// Avoided: Tuesday(2), Saturday(6)
  final List<int> allowedWeekdays;

  /// Allowed Tithis (1..15 single tithi index)
  final List<int> allowedTithis;

  /// Explicitly Avoided Tithis (Amavasya=15/30, Pournami=15, Ashtami=8, Navami=9, Chaturthi=4 in source 1)
  final List<int> avoidedTithis;

  /// Allowed Nakshatras (0..26 index)
  final List<int> allowedNakshatras;

  /// Allowed Amirthathi Yogas ('சித்த யோகம்', 'அமிர்த யோகம்')
  final List<String> allowedAmirthathiYogas;

  /// Avoided Amirthathi Yogas ('மரண யோகம்')
  final List<String> avoidedAmirthathiYogas;

  /// Allowed Karanas ('Bava', 'Balava', 'Kaulava', 'Taitula', 'Garaja', 'Vanija')
  final List<String> allowedKaranas;

  /// Avoided Karanas ('Vishti' / 'பத்திரை', etc.)
  final List<String> avoidedKaranas;

  /// Avoided Tamil Month indices (0=Chithirai .. 11=Panguni)
  /// Classical major avoidances: Aadi(3), Purattasi(5), Margazhi(8)
  final List<int> avoidedTamilMonths;

  /// Kari Days (கரி நாட்கள்) per Tamil Month index (0..11)
  final Map<int, List<int>> kariDaysMap;

  /// Avoidance flags
  final bool avoidRahuKalam;
  final bool avoidYamagandam;
  final bool avoidKuligai;

  /// Jathaga check flags
  final bool checkChandrashtama;
  final bool checkTarabalam;
  final bool checkGuruBalam;
  final bool checkSuryaBalam;

  /// Lagna & Papa Graha check settings
  final bool checkLagnaLord;
  final bool checkHouse7And8;
  final List<String> papaGrahas;

  const SubhaMuhurthamRules({
    required this.preset,
    required this.allowedWeekdays,
    required this.allowedTithis,
    required this.avoidedTithis,
    required this.allowedNakshatras,
    required this.allowedAmirthathiYogas,
    required this.avoidedAmirthathiYogas,
    required this.allowedKaranas,
    required this.avoidedKaranas,
    required this.avoidedTamilMonths,
    required this.kariDaysMap,
    this.avoidRahuKalam = true,
    this.avoidYamagandam = true,
    this.avoidKuligai = true,
    this.checkChandrashtama = true,
    this.checkTarabalam = true,
    this.checkGuruBalam = true,
    this.checkSuryaBalam = true,
    this.checkLagnaLord = true,
    this.checkHouse7And8 = true,
    this.papaGrahas = const ['Sun', 'Mars', 'Saturn', 'Rahu', 'Ketu'],
  });

  // ===============================================================
  // CANONICAL REFERENCE LISTS (PRESERVED EXPLICITLY)
  // ===============================================================

  /// Weekdays: Sunday (7), Monday (1), Wednesday (3), Thursday (4), Friday (5)
  static const List<int> canonicalWeekdays = [7, 1, 3, 4, 5];
  static const List<int> avoidedWeekdays = [2, 6]; // Tuesday, Saturday

  /// SOURCE 1 TITHIS (Earlier requirement text)
  /// Favourable: Dwitiya(2), Tritiya(3), Panchami(5), Saptami(7), Dashami(10), Ekadashi(11), Dwadashi(12), Trayodashi(13)
  /// Avoid: Amavasya(15/30), Pournami(15), Ashtami(8), Navami(9), Chaturthi(4)
  static const List<int> source1FavourableTithis = [2, 3, 5, 7, 10, 11, 12, 13];
  static const List<int> source1AvoidedTithis = [4, 8, 9, 14, 15, 30];

  /// SOURCE 2 TITHIS (Later requirement text)
  /// Suitable: Dwitiya(2), Tritiya(3), Chaturthi(4), Panchami(5), Shashti(6), Saptami(7), Dashami(10), Ekadashi(11), Dwadashi(12), Trayodashi(13), Chaturdashi(14)
  static const List<int> source2SuitableTithis = [2, 3, 4, 5, 6, 7, 10, 11, 12, 13, 14];
  static const List<int> source2AvoidedTithis = [8, 9, 15, 30];

  /// SOURCE 1 NAKSHATRAS (16 classical Nakshatras - 0-indexed)
  /// Includes Chitra(13), Swati(14); does NOT include Mula(18)
  static const List<int> source1Nakshatras = [
    0,  // Ashwini / அசுவினி
    3,  // Rohini / ரோகிணி
    4,  // Mrigashira / மிருகசீரிஷம்
    6,  // Punarvasu / புனர்பூசம்
    7,  // Pushya / பூசம்
    11, // Uttara Phalguni / உத்திரம்
    12, // Hasta / ஹஸ்தம்
    13, // Chitra / சித்திரை
    14, // Swati / சுவாதி
    16, // Anuradha / அனுஷம்
    20, // Uttara Ashadha / உத்திராடம்
    21, // Shravana / திருவோணம்
    22, // Dhanishta / அவிட்டம்
    23, // Shatabhisha / சதயம்
    25, // Uttara Bhadrapada / உத்திரட்டாதி
    26, // Revati / ரேவதி
  ];

  /// SOURCE 2 NAKSHATRAS (15 Nakshatras - 0-indexed)
  /// Adds Mula(18); does NOT explicitly list Chitra(13), Swati(14)
  static const List<int> source2Nakshatras = [
    0,  // Ashwini / அசுவினி
    3,  // Rohini / ரோகிணி
    4,  // Mrigashira / மிருகசீரிஷம்
    6,  // Punarvasu / புனர்பூசம்
    7,  // Pushya / பூசம்
    11, // Uttara Phalguni / உத்திரம்
    12, // Hasta / ஹஸ்தம்
    16, // Anuradha / அனுஷம்
    18, // Mula / மூலம் (Added in Source 2)
    20, // Uttara Ashadha / உத்திராடம்
    21, // Shravana / திருவோணம்
    22, // Dhanishta / அவிட்டம்
    23, // Shatabhisha / சதயம்
    25, // Uttara Bhadrapada / உத்திரட்டாதி
    26, // Revati / ரேவதி
  ];

  /// Suitable Yogas: Siddha Yoga, Amirtha Yoga. Avoided: Marana Yoga, Prabala Arishta Yoga
  static const List<String> canonicalAllowedYogas = [
    'சித்த யோகம்', 'அமிர்த யோகம்',
    'சித்தயோகம்', 'அமிர்தயோகம்',
    'Siddha Yogam', 'Amirtha Yogam',
  ];
  static const List<String> canonicalAvoidedYogas = [
    'மரண யோகம்', 'மரணயோகம்',
    'பிரபலாரிஷ்ட யோகம்', 'பிரபலாரிஷ்டயோகம்',
    'Marana Yogam', 'Prabala Arishta Yogam',
  ];

  /// Suitable Karanas: Bava, Balava, Kaulava, Taitula, Garaja, Vanija / Vanijai
  static const List<String> canonicalAllowedKaranas = [
    'பவ', 'பாலவ', 'கௌலவ', 'தைதுலை', 'கரசை', 'வணிசை',
    'Bava', 'Balava', 'Kaulava', 'Taitula', 'Garaja', 'Vanija'
  ];
  static const List<String> canonicalAvoidedKaranas = [
    'பத்திரை', 'விஷ்டி', 'சகுனி', 'சதுஷ்பாதம்', 'நாகவம்', 'கிமிஸ்துக்னம்',
    'Vishti', 'Bhadra', 'Shakuni', 'Chatushpada', 'Naga', 'Kimstughna'
  ];

  /// Avoided Tamil Months: Aadi (3), Purattasi (5), Margazhi (8), Maasi (10)
  static const List<int> canonicalAvoidedMonths = [3, 5, 8, 10];

  /// Kari Days (கரி நாட்கள்) per Tamil solar month (tamilMonthIdx: 0..11)
  /// 0: Chithirai -> 6, 15
  /// 1: Vaikasi -> 7, 16, 17
  /// 2: Aani -> 1, 6
  /// 3: Aadi -> 2, 10, 20
  /// 4: Avani -> 2, 9, 28
  /// 5: Purattasi -> 16, 29
  /// 6: Aippasi -> 6, 20
  /// 7: Karthigai -> 1, 10, 17
  /// 8: Margazhi -> 6, 9, 11
  /// 9: Thai -> 1, 2, 3, 11, 17
  /// 10: Masi -> 15, 16, 17
  /// 11: Panguni -> 6, 15, 19
  static const Map<int, List<int>> canonicalKariDays = {
    0: [6, 15],
    1: [7, 16, 17],
    2: [1, 6],
    3: [2, 10, 20],
    4: [2, 9, 28],
    5: [16, 29],
    6: [6, 20],
    7: [1, 10, 17],
    8: [6, 9, 11],
    9: [1, 2, 3, 11, 17],
    10: [15, 16, 17],
    11: [6, 15, 19],
  };

  /// Factory for Standard / Canonical Preset (Source List 1)
  factory SubhaMuhurthamRules.standard() {
    return const SubhaMuhurthamRules(
      preset: MuhurthamRulePreset.standard,
      allowedWeekdays: canonicalWeekdays,
      allowedTithis: source1FavourableTithis,
      avoidedTithis: source1AvoidedTithis,
      allowedNakshatras: source1Nakshatras,
      allowedAmirthathiYogas: canonicalAllowedYogas,
      avoidedAmirthathiYogas: canonicalAvoidedYogas,
      allowedKaranas: canonicalAllowedKaranas,
      avoidedKaranas: canonicalAvoidedKaranas,
      avoidedTamilMonths: canonicalAvoidedMonths,
      kariDaysMap: canonicalKariDays,
    );
  }

  /// Factory for Extended Preset (Source List 2)
  factory SubhaMuhurthamRules.extended() {
    return const SubhaMuhurthamRules(
      preset: MuhurthamRulePreset.extended,
      allowedWeekdays: canonicalWeekdays,
      allowedTithis: source2SuitableTithis,
      avoidedTithis: source2AvoidedTithis,
      allowedNakshatras: source2Nakshatras,
      allowedAmirthathiYogas: canonicalAllowedYogas,
      avoidedAmirthathiYogas: canonicalAvoidedYogas,
      allowedKaranas: canonicalAllowedKaranas,
      avoidedKaranas: canonicalAvoidedKaranas,
      avoidedTamilMonths: canonicalAvoidedMonths,
      kariDaysMap: canonicalKariDays,
    );
  }

  /// Default application rule set
  static SubhaMuhurthamRules get defaultRules => SubhaMuhurthamRules.standard();

  // ===============================================================
  // CONFLICT IDENTIFICATION AND TRANSPARENCY HELPERS
  // ===============================================================

  /// Identifies and returns documented Tithi conflict explanation
  static String? getTithiConflictNote(int singleTithiNum) {
    if (singleTithiNum == 4) {
      return 'திதி முரண்பாடு (Tithi Conflict): சதுர்த்தி (Chaturthi) முதல் மூல விதியில் தவிர்க்கப்பட்டுள்ளது (Avoid); ஆனால் இரண்டாம் மூல விதியில் சுப திதியாக ஏற்கப்பட்டுள்ளது (Suitable).';
    }
    if (singleTithiNum == 6) {
      return 'திதி மாறுபாடு (Tithi Variation): சஷ்டி (Shashti) முதல் மூல விதியில் சேர்க்கப்படவில்லை; இரண்டாம் மூல விதியில் சுப திதியாக ஏற்கப்பட்டுள்ளது.';
    }
    if (singleTithiNum == 14) {
      return 'திதி மாறுபாடு (Tithi Variation): சதுர்த்தசி (Chaturdashi) முதல் மூல விதியில் விலக்கப்பட்டுள்ளது; இரண்டாம் மூல விதியில் சுப திதியாக பட்டியலிடப்பட்டுள்ளது.';
    }
    return null;
  }

  /// Identifies and returns documented Nakshatra conflict explanation
  static String? getNakshatraConflictNote(int nakIdx) {
    if (nakIdx == 13) {
      return 'நட்சத்திர முரண்பாடு (Nakshatra Conflict): சித்திரை (Chitra) முதல் மூல விதியில் (16 உத்தம நட்சத்திரங்கள்) சேர்க்கப்பட்டுள்ளது; ஆனால் இரண்டாம் மூல விதியில் பட்டியலிடப்படவில்லை.';
    }
    if (nakIdx == 14) {
      return 'நட்சத்திர முரண்பாடு (Nakshatra Conflict): சுவாதி (Swati) முதல் மூல விதியில் (16 உத்தம நட்சத்திரங்கள்) சேர்க்கப்பட்டுள்ளது; ஆனால் இரண்டாம் மூல விதியில் பட்டியலிடப்படவில்லை.';
    }
    if (nakIdx == 18) {
      return 'நட்சத்திர முரண்பாடு (Nakshatra Conflict): மூலம் (Mula) இரண்டாம் மூல விதியில் சுப நட்சத்திரமாக சேர்க்கப்பட்டுள்ளது; ஆனால் முதல் மூல விதியில் சேர்க்கப்படவில்லை.';
    }
    return null;
  }

  /// Lagna Lord mapping: 0=Mesham (Mars) .. 11=Meenam (Jupiter)
  static const Map<int, String> lagnaLordMap = {
    0: 'Mars',    // Mesham -> செவ்வாய்
    1: 'Venus',   // Rishabam -> சுக்கிரன்
    2: 'Mercury', // Mithunam -> புதன்
    3: 'Moon',    // Kadagam -> சந்திரன்
    4: 'Sun',     // Simmam -> சூரியன்
    5: 'Mercury', // Kanni -> புதன்
    6: 'Venus',   // Thulam -> சுக்கிரன்
    7: 'Mars',    // Viruchigam -> செவ்வாய்
    8: 'Jupiter', // Dhanusu -> குரு
    9: 'Saturn',  // Makaram -> சனி
    10: 'Saturn', // Kumbam -> சனி
    11: 'Jupiter',// Meenam -> குரு
  };

  /// Planetary Lord names in Tamil
  static const Map<String, String> planetNamesTa = {
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

  /// Checks if a day is a Kari Day (கரி நாள்)
  bool isKariDay(int tamilMonthIdx, int tamilDay) {
    final list = kariDaysMap[tamilMonthIdx];
    if (list == null) return false;
    return list.contains(tamilDay);
  }

  /// Copies this rule object with specific overrides
  SubhaMuhurthamRules copyWith({
    MuhurthamRulePreset? preset,
    List<int>? allowedWeekdays,
    List<int>? allowedTithis,
    List<int>? avoidedTithis,
    List<int>? allowedNakshatras,
    List<String>? allowedAmirthathiYogas,
    List<String>? avoidedAmirthathiYogas,
    List<String>? allowedKaranas,
    List<String>? avoidedKaranas,
    List<int>? avoidedTamilMonths,
    Map<int, List<int>>? kariDaysMap,
    bool? avoidRahuKalam,
    bool? avoidYamagandam,
    bool? avoidKuligai,
    bool? checkChandrashtama,
    bool? checkTarabalam,
    bool? checkGuruBalam,
    bool? checkSuryaBalam,
    bool? checkLagnaLord,
    bool? checkHouse7And8,
    List<String>? papaGrahas,
  }) {
    return SubhaMuhurthamRules(
      preset: preset ?? this.preset,
      allowedWeekdays: allowedWeekdays ?? this.allowedWeekdays,
      allowedTithis: allowedTithis ?? this.allowedTithis,
      avoidedTithis: avoidedTithis ?? this.avoidedTithis,
      allowedNakshatras: allowedNakshatras ?? this.allowedNakshatras,
      allowedAmirthathiYogas: allowedAmirthathiYogas ?? this.allowedAmirthathiYogas,
      avoidedAmirthathiYogas: avoidedAmirthathiYogas ?? this.avoidedAmirthathiYogas,
      allowedKaranas: allowedKaranas ?? this.allowedKaranas,
      avoidedKaranas: avoidedKaranas ?? this.avoidedKaranas,
      avoidedTamilMonths: avoidedTamilMonths ?? this.avoidedTamilMonths,
      kariDaysMap: kariDaysMap ?? this.kariDaysMap,
      avoidRahuKalam: avoidRahuKalam ?? this.avoidRahuKalam,
      avoidYamagandam: avoidYamagandam ?? this.avoidYamagandam,
      avoidKuligai: avoidKuligai ?? this.avoidKuligai,
      checkChandrashtama: checkChandrashtama ?? this.checkChandrashtama,
      checkTarabalam: checkTarabalam ?? this.checkTarabalam,
      checkGuruBalam: checkGuruBalam ?? this.checkGuruBalam,
      checkSuryaBalam: checkSuryaBalam ?? this.checkSuryaBalam,
      checkLagnaLord: checkLagnaLord ?? this.checkLagnaLord,
      checkHouse7And8: checkHouse7And8 ?? this.checkHouse7And8,
      papaGrahas: papaGrahas ?? this.papaGrahas,
    );
  }
}
