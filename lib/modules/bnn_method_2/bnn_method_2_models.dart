/// Data models for isolated BNN Method 2 astrology module.
///
/// Contains:
/// - [BNNMethod2RelationType]
/// - [BNNMethod2PlanetPosition]
/// - [BNNMethod2PlanetKaraka]
/// - [BNNMethod2DiseaseKaraka]
/// - [BNNMethod2HouseKaraka]
/// - [BNNMethod2PlanetRelationTable]
/// - [BNNMethod2Connection]
/// - [BNNMethod2PlanetAnalysis]
library;

/// Relationship classification for BNN Method 2
enum BNNMethod2RelationType {
  friend('நட்பு', 'Friend'),
  enemy('பகை', 'Enemy'),
  neutral('சமம்', 'Neutral');

  final String labelTa;
  final String labelEn;
  const BNNMethod2RelationType(this.labelTa, this.labelEn);
}

/// Normalized planetary position model for BNN Method 2
class BNNMethod2PlanetPosition {
  final String planetKey; // Sun, Moon, Mars, Mercury, Jupiter, Venus, Saturn, Rahu, Ketu
  final String tamilName; // சூரியன், சந்திரன், etc.
  final String englishName;
  final int sign; // 1 to 12 (1 = Mesham ... 12 = Meenam)
  final String signNameTa;
  final String signNameEn;
  final int house; // 1 to 12 from Lagna
  final double degreeInSign; // 0.0 to < 30.0
  final double absoluteLongitude; // 0.0 to < 360.0
  final int degree; // DD
  final int minute; // MM
  final double second; // SS
  final String nakshatra;
  final int pada;
  final bool isRetrograde;

  const BNNMethod2PlanetPosition({
    required this.planetKey,
    required this.tamilName,
    required this.englishName,
    required this.sign,
    required this.signNameTa,
    required this.signNameEn,
    required this.house,
    required this.degreeInSign,
    required this.absoluteLongitude,
    required this.degree,
    required this.minute,
    required this.second,
    this.nakshatra = '',
    this.pada = 1,
    this.isRetrograde = false,
  });

  /// Formatted DMS string: DD° MM' SS"
  String get formattedDMS {
    final dd = degree.toString().padLeft(2, '0');
    final mm = minute.toString().padLeft(2, '0');
    final ss = second.toStringAsFixed(0).padLeft(2, '0');
    return "$dd°$mm'$ss\"";
  }

  /// Compact representation
  String get summaryText => '$tamilName | $signNameTa | $formattedDMS | பாவம்: $house';
}

/// ① கிரகத்தின் மிக முக்கியமான 10 காரகங்கள்
class BNNMethod2PlanetKaraka {
  static const Map<String, List<String>> _karakas = {
    'Sun': [
      'பிதுர்காரகன் (தந்தை)',
      'அரசு & நிர்வாக அதிகாரம்',
      'தலைமைத்துவ பண்பு',
      'கௌரவம், மதிப்பு & புகழ்',
      'ஆத்ம பலம் & மன உறுதி',
      'அரசியல் செல்வாக்கு',
      'உயர் அதிகாரிகள் தொடர்பு',
      'உடல் நலம் & உயிர் ஒளி',
      'தன்னம்பிக்கை & நேர்மை',
      'அதிகார பதவி & ஆளுமை',
    ],
    'Moon': [
      'மாதுர்காரகன் (தாய்)',
      'மனம் & ஆழ்ந்த உணர்வுகள்',
      'பயணங்கள் & இடமாற்றம்',
      'கற்பனை & படைப்பாற்றல்',
      'நீர் நிலைகள் & திரவங்கள்',
      'உணவு & விருந்தோம்பல்',
      'மாற்றங்கள் & சலனம்',
      'இரக்கம் & தாய்மை அன்பு',
      'பொதுமக்கள் தொடர்பு & செல்வாக்கு',
      'கலை ஆர்வம் & சுவை',
    ],
    'Mars': [
      'சகோதர காரகன்',
      'துணிவு, வீரம் & தைரியம்',
      'நிலம் & பூமி சொத்துக்கள்',
      'தொழில்நுட்பம் & பொறியியல்',
      'அதிகாரம் & வேகம்',
      'போராட்ட குணம் & வெற்றி',
      'கணவன் (பெண் ஜாதகத்தில்)',
      'மருத்துவம் & அறுவைசிகிச்சை',
      'பாதுகாப்பு & சீருடை பணி',
      'செயலாற்றல் & விடாமுயற்சி',
    ],
    'Mercury': [
      'வித்யா & புத்திகாரகன்',
      'கல்வி & நுண்ணறிவு',
      'வியாபாரம் & வர்த்தகம்',
      'தொடர்பு & பேச்சுத்திறன்',
      'கணிதம் & கணக்கு',
      'நண்பர்கள் & இளையோர்',
      'எழுத்து, ஊடகம் & ஜோதிடம்',
      'நகைச்சுவை & சாமர்த்தியம்',
      'சட்ட அறிவு & தர்க்கம்',
      'தகவல் தொழில்நுட்பம்',
    ],
    'Jupiter': [
      'ஜீவகாரகன் (உயிர், தான்)',
      'குரு அருள் & தெய்வீக ஆசி',
      'ஞானம் & மெய்யறிவு',
      'குழந்தைகள் பாக்கியம்',
      'செல்வம் & நிதி வளர்ச்சி',
      'மரியாதை & சமூக அந்தஸ்து',
      'ஆன்மீக ஈடுபாடு & தர்மம்',
      'உயர் கல்வி & வழிகாட்டுதல்',
      'அதிர்ஷ்டம் & நல்வாய்ப்புகள்',
      'நற்பெயர் & அறச்சிந்தனை',
    ],
    'Venus': [
      'களத்திரகாரகன் (மனைவி/துணை)',
      'தனம் & பணப்புழக்கம்',
      'வாகனம் & சொகுசு வாழ்க்கை',
      'கலை, இசை & அழகுணர்வு',
      'மகிழ்ச்சி & சுகபோகம்',
      'ஆடை ஆபரணங்கள் & அழகு',
      'திருமண வாழ்வு & அன்பு',
      'வியாபார ஈர்ப்பு & கவர்ச்சி',
      'பெண்கள் தொடர்பு & உதவி',
      'வசீகர சக்தி & புகழ்',
    ],
    'Saturn': [
      'கர்மகாரகன் (தொழில், வேலை)',
      'உழைப்பு & விடாமுயற்சி',
      'பொறுப்பு & கடமை உணர்வு',
      'நீண்ட கால வளர்ச்சி & நிலைப்பு',
      'தாமதங்கள் & அனுபவ பாடம்',
      'சேவை & அடித்தட்டு மக்கள் தொடர்பு',
      'ஆயுள் & விவேகம்',
      'ஒழுக்கம் & சுய கட்டுப்பாடு',
      'இயந்திரங்கள் & தொழிற்சாலை',
      'பூர்வ கர்ம பாக்கிகள் தீர்தல்',
    ],
    'Rahu': [
      'மாயை & பேராசை',
      'வெளிநாட்டு பயணம் & தொடர்பு',
      'திடீர் உயர்வு & பிரம்மாண்டம்',
      'தொழில்நுட்பம் & எலக்ட்ரானிக்ஸ்',
      'தந்தை வழி பாட்டனார்',
      'வித்தியாசமான சிந்தனை & உத்தி',
      'மருந்து & ரசாயனம்',
      'திரைத்துறை & மாய உலகம்',
      'மறைமுக வருமானம்',
      'அதிவேக வளர்ச்சி & சாதனை',
    ],
    'Ketu': [
      'மோக்ஷ & ஞானகாரகன்',
      'ஆன்மீகம் & துறவு நிலை',
      'ஆராய்ச்சி & ஆழ்ந்த நுண்ணறிவு',
      'தாய் வழி பாட்டனார்',
      'தடைகள் மூலம் பக்குவம்',
      'மருத்துவம் & மூலிகைகள்',
      'சட்ட நிபுணத்துவம் & நீதி',
      'மின்னணு நுட்பங்கள்',
      'பற்றற்ற மனநிலை & எளிமை',
      'முக்தி நோக்கம் & வேதாந்தம்',
    ],
  };

  static List<String> get(String planetKey) {
    return _karakas[planetKey] ?? const ['பொதுவான கிரக காரகத்துவம்.'];
  }
}

/// ② நோய் / உடல் காரகங்கள் (Exactly 5 items per planet)
class BNNMethod2DiseaseKaraka {
  static const Map<String, List<String>> _diseases = {
    'Sun': [
      'எலும்பு & தண்டுவடம்',
      'இதயம் & ரத்த ஓட்டம்',
      'வலது கண் பார்வை',
      'தலைவலி & பித்தம்',
      'உயிர் சக்தி & நோய் எதிர்ப்பு ஆற்றல்',
    ],
    'Moon': [
      'நுரையீரல் & சுவாசக் கோளாறுகள்',
      'இடது கண் & பார்வை',
      'மன அழுத்தம் & தூக்கமின்மை',
      'உடல் திரவங்கள் & ரத்த சோகை',
      'வயிறு & செரிமான மந்தம்',
    ],
    'Mars': [
      'தசை நரம்புகள் & தசைப்பிடிப்பு',
      'ரத்தக் கொதிப்பு & ரத்த அழுத்தம்',
      'விபத்து & காயங்கள்',
      'உஷ்ண நோய்கள் & கட்டிகள்',
      'எலும்பு மஜ்ஜை கோளாறுகள்',
    ],
    'Mercury': [
      'நரம்பு மண்டலம் & நரம்பு தளர்ச்சி',
      'தோல் அலர்ஜி & தோல் நோய்கள்',
      'பேச்சுத்திறன் & திக்குவாய்',
      'தொண்டை & குரல்வளை',
      'கை, விரல்கள் & மூளை நரம்புகள்',
    ],
    'Jupiter': [
      'கல்லீரல் & பித்தப்பை',
      'கணையம் & சர்க்கரை நோய்',
      'உடல் பருமன் & கொழுப்பு',
      'காது கேளாமை & காது வலி',
      'தமனிகள் & ரத்த நாளங்கள்',
    ],
    'Venus': [
      'சிறுநீரகம் & சிறுநீரகப் பாதை',
      'இனப்பெருக்க உறுப்புகள்',
      'கண் பார்வை & முகம்',
      'ஹார்மோன் சமநிலையின்மை',
      'சர்க்கரை நோய் & பலவீனம்',
    ],
    'Saturn': [
      'மூட்டு வலி & வாத நோய்கள்',
      'கால், பாதம் & எலும்பு தேய்மானம்',
      'வாயுத் தொல்லை & மலச்சிக்கல்',
      'பக்கவாதம் & மரத்துப்போதல்',
      'பல் & நாள்பட்ட வியாதிகள்',
    ],
    'Rahu': [
      'விஷக்கடி & ஒவ்வாமை',
      'விவரிக்க முடியாத விசித்திர நோய்கள்',
      'குடல் புண் & வாயுக்கோளாறு',
      'தோல் அரிப்பு & தொற்று வியாதிகள்',
      'மன பிரமை & மாயை அச்சம்',
    ],
    'Ketu': [
      'தோல் புண் & கொப்பளங்கள்',
      'சிறுநீரக கல் & அடைப்பு',
      'அம்மை & ரத்த நச்சு',
      'நரம்பு சுளுக்கு & வலிப்பு',
      'அறுவை சிகிச்சை & தழும்புகள்',
    ],
  };

  static List<String> get(String planetKey) {
    return _diseases[planetKey] ?? const ['பொதுவான உடல் காரகத்துவம்.'];
  }
}

/// ③ லக்னத்திலிருந்து {house}ம் பாவத்தின் 10 காரகங்கள்
class BNNMethod2HouseKaraka {
  static const Map<int, List<String>> _houseKarakas = {
    1: [
      'ஜாதகர் (உயிர், தான்)',
      'உடல் தோற்றம் & ஆரோக்கியம்',
      'குணம் & சுபாவம்',
      'தன்னம்பிக்கை & ஆளுமை',
      'புகழ் & அந்தஸ்து',
      'ஆயுள் பலம்',
      'தலை & மூளை',
      'வாழ்வியல் தொடக்கம்',
      'சுய முயற்சி',
      'சமூக மரியாதை',
    ],
    2: [
      'தன வரவு & சேமிப்பு',
      'குடும்பம் & குடும்ப வளர்ச்சி',
      'வாக்கு & பேச்சுத்திறன்',
      'வலது கண்',
      'முகம் & பற்கள்',
      'ஆரம்பக் கல்வி',
      'அசையும் சொத்துக்கள் & வைப்பு நிதி',
      'உணவுப் பழக்கம்',
      'வாக்கு நாணயம்',
      'செல்வ நிலை',
    ],
    3: [
      'இளைய சகோதரம்',
      'தைரியம், துணிவு & வீரம்',
      'குறுகிய பயணங்கள்',
      'தகவல் தொடர்பு & எழுத்து',
      'கைகள் & தோள்கள்',
      'சுய முயற்சி & ஆர்வம்',
      'உடன்பிறப்புகள் உதவி',
      'ஆவணங்கள் & ஒப்பந்தங்கள்',
      'மன உறுதி',
      'விழிப்புணர்வு',
    ],
    4: [
      'தாய் & தாய்வழி உறவுகள்',
      'வீடு & அசையா சொத்துக்கள்',
      'நிலம், தோட்டம் & மனை',
      'வாகனங்கள் & சுகபோகம்',
      'அடிப்படை உயர்கல்வி',
      'மன நிம்மதி & மகிழ்ச்சி',
      'மார்பு & நுரையீரல்',
      'சொந்த ஊர் & வசதி',
      'பந்தா & ஆடம்பரம்',
      'அமைதியான வாழ்வு',
    ],
    5: [
      'பூர்வ புண்ணியம்',
      'குழந்தைகள் & வாரிசு பாக்கியம்',
      'புத்தி கூர்மை & நுண்ணறிவு',
      'கலை, இலக்கியம் & படைப்பாற்றல்',
      'ஆன்மீக ஈடுபாடு & மந்திர சித்தி',
      'காதல் & அன்பு',
      'முதலீடு & ஊக வணிகம்',
      'தர்ம சிந்தனை',
      'மகிழ்ச்சியான பொழுதுபோக்கு',
      'குலதெய்வ அருள்',
    ],
    6: [
      'கடன் & நிதி சுமைகள்',
      'நோய் & உடல் உபாதைகள்',
      'எதிரிகள் & போட்டி மனப்பான்மை',
      'வழக்கு & சட்ட சிக்கல்கள்',
      'உத்தியோகம் & தினசரி வேலை',
      'சேவை & அடிமைத் தொழில்',
      'தாய்மாமன் தொடர்பு',
      'தடைகள் & சவால்கள்',
      'விழிப்புணர்வு & வெற்றி',
      'செரிமான மண்டலம்',
    ],
    7: [
      'களத்திரம் (மனைவி/கணவன்)',
      'திருமண வாழ்வு & தாம்பத்தியம்',
      'கூட்டுத் தொழில் & கூட்டாளிகள்',
      'பொது மக்கள் தொடர்பு & வாடிக்கையாளர்கள்',
      'வெளி உலக தொடர்பு',
      'வர்த்தக ஒப்பந்தங்கள்',
      'இடுப்பு & சிறுநீரகம்',
      'பயணங்கள்',
      'சமூக உறவுகள்',
      'வாழ்க்கை துணைவர் ஆதரவு',
    ],
    8: [
      'ஆயுள் பலம் & மறைவு',
      'திடீர் அதிர்ஷ்டம் & எதிர்பாராத தனவரவு',
      'விபத்து & அவமானம்',
      'மாங்கல்ய பலம் (பெண்களுக்கு)',
      'ரகசிய விவகாரங்கள் & மறைமுக ஞானம்',
      'தீவிர சோதனைகள் & துன்பங்கள்',
      'இன்சூரன்ஸ் & பரம்பரை சொத்து',
      'ஆராய்ச்சி & ஆழ்கடல் நுட்பம்',
      'முடக்கம்',
      'கர்ம வினைகள்',
    ],
    9: [
      'தந்தை & தந்தைவழி உறவுகள்',
      'பாக்கியம் & அதிர்ஷ்டம்',
      'தர்ம சிந்தனை & அறநெறி',
      'உயர் கல்வி & ஆராய்ச்சி படிப்பு',
      'ஆன்மீக குரு & தீட்சை',
      'நீண்ட தூர மற்றும் வெளிநாட்டு பயணம்',
      'கோவில் வழிபாடு & திருப்பணி',
      'தர்ம தானம்',
      'தொடை & இடுப்பு பகுதி',
      'தெய்வ அருள்',
    ],
    10: [
      'தொழில் & உத்தியோகம்',
      'அதிகாரம் & தலைமைப் பதவி',
      'சமூக அந்தஸ்து & கௌரவம்',
      'ஜீவனம் & வருமானம்',
      'அரசு அங்கீகாரம் & விருதுகள்',
      'புகழ் & கீர்த்தி',
      'முழங்கால்கள்',
      'பொது வாழ்வு & அரசியல்',
      'கர்ம வினை இயக்கம்',
      'கடமை & பொறுப்புகள்',
    ],
    11: [
      'லாபம் & வருமான பெருக்கம்',
      'ஆசைகள் & விருப்பங்கள் நிறைவேறுதல்',
      'மூத்த சகோதரம்',
      'நண்பர்கள் வட்டம் & நலம் விரும்பிகள்',
      'வெற்றிகள் & சாதனைகள்',
      'தொழில் விரிவாக்கம் & பல வழிகளில் வருமானம்',
      'வலது காது & கால்கள்',
      'சமூக அமைப்புகள் & சங்கங்கள்',
      'அதிர்ஷ்ட வாய்ப்புகள்',
      'சந்தோஷம் & மனநிறைவு',
    ],
    12: [
      'விரயம் & செலவுகள்',
      'வெளிநாட்டு குடியேற்றம் & தொலைதூர பயணம்',
      'மோக்ஷம் & முக்தி நிலை',
      'தூக்கம் & கட்டில் சுகம்',
      'ஆன்மீக துறவு & தியானம்',
      'மருத்துவமனை & தனிமைப்படுதல்',
      'ரகசிய எதிரிகள்',
      'பாதங்கள் & இடது கண்',
      'முதலீடுகள்',
      'புண்ணிய தானங்கள்',
    ],
  };

  static List<String> get(int houseNumber) {
    final validHouse = ((houseNumber - 1) % 12) + 1;
    return _houseKarakas[validHouse] ?? const ['பாவ காரகத்துவம்'];
  }
}

/// ⑩ Planet Relation Table (Friend: நட்பு, Enemy: பகை, Neutral: சமம்)
class BNNMethod2PlanetRelationTable {
  static const Map<String, Map<String, BNNMethod2RelationType>> _matrix = {
    'Sun': {
      'Moon': BNNMethod2RelationType.friend,
      'Mars': BNNMethod2RelationType.friend,
      'Jupiter': BNNMethod2RelationType.friend,
      'Mercury': BNNMethod2RelationType.neutral,
      'Venus': BNNMethod2RelationType.enemy,
      'Saturn': BNNMethod2RelationType.enemy,
      'Rahu': BNNMethod2RelationType.enemy,
      'Ketu': BNNMethod2RelationType.enemy,
    },
    'Moon': {
      'Sun': BNNMethod2RelationType.friend,
      'Mercury': BNNMethod2RelationType.friend,
      'Mars': BNNMethod2RelationType.neutral,
      'Jupiter': BNNMethod2RelationType.neutral,
      'Venus': BNNMethod2RelationType.neutral,
      'Saturn': BNNMethod2RelationType.neutral,
      'Rahu': BNNMethod2RelationType.enemy,
      'Ketu': BNNMethod2RelationType.enemy,
    },
    'Mars': {
      'Sun': BNNMethod2RelationType.friend,
      'Moon': BNNMethod2RelationType.friend,
      'Jupiter': BNNMethod2RelationType.friend,
      'Venus': BNNMethod2RelationType.neutral,
      'Saturn': BNNMethod2RelationType.neutral,
      'Ketu': BNNMethod2RelationType.neutral,
      'Mercury': BNNMethod2RelationType.enemy,
      'Rahu': BNNMethod2RelationType.enemy,
    },
    'Mercury': {
      'Sun': BNNMethod2RelationType.friend,
      'Venus': BNNMethod2RelationType.friend,
      'Mars': BNNMethod2RelationType.neutral,
      'Jupiter': BNNMethod2RelationType.neutral,
      'Saturn': BNNMethod2RelationType.neutral,
      'Rahu': BNNMethod2RelationType.neutral,
      'Ketu': BNNMethod2RelationType.neutral,
      'Moon': BNNMethod2RelationType.enemy,
    },
    'Jupiter': {
      'Sun': BNNMethod2RelationType.friend,
      'Moon': BNNMethod2RelationType.friend,
      'Mars': BNNMethod2RelationType.friend,
      'Saturn': BNNMethod2RelationType.neutral,
      'Rahu': BNNMethod2RelationType.neutral,
      'Ketu': BNNMethod2RelationType.neutral,
      'Mercury': BNNMethod2RelationType.enemy,
      'Venus': BNNMethod2RelationType.enemy,
    },
    'Venus': {
      'Mercury': BNNMethod2RelationType.friend,
      'Saturn': BNNMethod2RelationType.friend,
      'Rahu': BNNMethod2RelationType.friend,
      'Ketu': BNNMethod2RelationType.friend,
      'Mars': BNNMethod2RelationType.neutral,
      'Jupiter': BNNMethod2RelationType.neutral,
      'Sun': BNNMethod2RelationType.enemy,
      'Moon': BNNMethod2RelationType.enemy,
    },
    'Saturn': {
      'Mercury': BNNMethod2RelationType.friend,
      'Venus': BNNMethod2RelationType.friend,
      'Rahu': BNNMethod2RelationType.friend,
      'Jupiter': BNNMethod2RelationType.neutral,
      'Ketu': BNNMethod2RelationType.neutral,
      'Sun': BNNMethod2RelationType.enemy,
      'Moon': BNNMethod2RelationType.enemy,
      'Mars': BNNMethod2RelationType.enemy,
    },
    'Rahu': {
      'Mercury': BNNMethod2RelationType.friend,
      'Venus': BNNMethod2RelationType.friend,
      'Saturn': BNNMethod2RelationType.friend,
      'Jupiter': BNNMethod2RelationType.neutral,
      'Sun': BNNMethod2RelationType.enemy,
      'Moon': BNNMethod2RelationType.enemy,
      'Mars': BNNMethod2RelationType.enemy,
      'Ketu': BNNMethod2RelationType.enemy,
    },
    'Ketu': {
      'Mercury': BNNMethod2RelationType.friend,
      'Venus': BNNMethod2RelationType.friend,
      'Mars': BNNMethod2RelationType.neutral,
      'Jupiter': BNNMethod2RelationType.neutral,
      'Saturn': BNNMethod2RelationType.neutral,
      'Sun': BNNMethod2RelationType.enemy,
      'Moon': BNNMethod2RelationType.enemy,
      'Rahu': BNNMethod2RelationType.enemy,
    },
  };

  static BNNMethod2RelationType getRelation(String sourcePlanetKey, String targetPlanetKey) {
    if (sourcePlanetKey == targetPlanetKey) return BNNMethod2RelationType.neutral;
    return _matrix[sourcePlanetKey]?[targetPlanetKey] ?? BNNMethod2RelationType.neutral;
  }
}

/// Single BNN Connection between a source planet and a target planet
class BNNMethod2Connection {
  final BNNMethod2PlanetPosition sourcePlanet;
  final BNNMethod2PlanetPosition targetPlanet;
  final int relativeHouse; // Direction (1, 5, 9, 3, 11, 7, 2, 12)
  final int directionIndex; // Index in directionOrder [1, 5, 9, 3, 11, 7, 2, 12]
  final BNNMethod2RelationType relationship; // நட்பு, பகை, சமம்

  const BNNMethod2Connection({
    required this.sourcePlanet,
    required this.targetPlanet,
    required this.relativeHouse,
    required this.directionIndex,
    required this.relationship,
  });
}

/// Comprehensive planet analysis container for BNN Method 2
class BNNMethod2PlanetAnalysis {
  final BNNMethod2PlanetPosition sourcePlanet;
  final List<String> planetKarakas;
  final List<String> diseaseKarakas;
  final List<String> houseKarakas;
  final List<BNNMethod2Connection> connections;

  const BNNMethod2PlanetAnalysis({
    required this.sourcePlanet,
    required this.planetKarakas,
    required this.diseaseKarakas,
    required this.houseKarakas,
    required this.connections,
  });

  bool get hasConnections => connections.isNotEmpty;
}
