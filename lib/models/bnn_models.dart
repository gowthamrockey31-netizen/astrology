import '../services/astrology_calculator.dart';

/// BNN Relationship Types with Exact Directional Priority
enum BnnRelationType {
  trine159,    // Priority 1: (1, 5, 9) திரிகோண தொடர்பு
  upachaya311, // Priority 2: (3, 11) முயற்சி / லாப தொடர்பு
  seventh7,    // Priority 3: (7) நேரெதிர் தொடர்பு
  second2,     // Priority 4: (2) தன / குடும்ப / முன்னோக்கு தொடர்பு
  twelfth12,   // Priority 5: (12) விரய / பின்னோக்கு தொடர்பு
  secondTwelfth212, // Legacy alias for backward compatibility
}

extension BnnRelationTypeExtension on BnnRelationType {
  int get priority {
    switch (this) {
      case BnnRelationType.trine159:
        return 1;
      case BnnRelationType.upachaya311:
        return 2;
      case BnnRelationType.seventh7:
        return 3;
      case BnnRelationType.second2:
      case BnnRelationType.secondTwelfth212:
        return 4;
      case BnnRelationType.twelfth12:
        return 5;
    }
  }

  String get tamilTitle {
    switch (this) {
      case BnnRelationType.trine159:
        return '(1,5,9) திரிகோண தொடர்பு';
      case BnnRelationType.upachaya311:
        return '(3,11) முயற்சி / லாப தொடர்பு';
      case BnnRelationType.seventh7:
        return '(7) நேரெதிர் தொடர்பு';
      case BnnRelationType.second2:
        return '(2) தன / குடும்ப / முன்னோக்கு தொடர்பு';
      case BnnRelationType.twelfth12:
        return '(12) விரய / பின்னோக்கு தொடர்பு';
      case BnnRelationType.secondTwelfth212:
        return '(2,12) குடும்ப / செலவு தொடர்பு';
    }
  }

  String get englishTitle {
    switch (this) {
      case BnnRelationType.trine159:
        return 'Trine Relationship (1, 5, 9)';
      case BnnRelationType.upachaya311:
        return 'Upachaya Relationship (3, 11)';
      case BnnRelationType.seventh7:
        return 'Opposite Relationship (7)';
      case BnnRelationType.second2:
        return 'Forward Relationship (2)';
      case BnnRelationType.twelfth12:
        return 'Behind Relationship (12)';
      case BnnRelationType.secondTwelfth212:
        return 'Adjacent Relationship (2, 12)';
    }
  }

  List<int> get offsets {
    switch (this) {
      case BnnRelationType.trine159:
        return [0, 4, 8];
      case BnnRelationType.upachaya311:
        return [2, 10];
      case BnnRelationType.seventh7:
        return [6];
      case BnnRelationType.second2:
        return [1];
      case BnnRelationType.twelfth12:
        return [11];
      case BnnRelationType.secondTwelfth212:
        return [1, 11];
    }
  }

  String get baseSignificanceTa {
    switch (this) {
      case BnnRelationType.trine159:
        return 'பூர்வ புண்ணியம், புத்தி, கல்வி, குழந்தைகள், அதிர்ஷ்டம், தர்ம வளர்ச்சி.';
      case BnnRelationType.upachaya311:
        return 'முயற்சி, துணிவு, தொடர்பு, வளர்ச்சி, லாபம், ஆசை நிறைவேற்றம்.';
      case BnnRelationType.seventh7:
        return 'திருமணம், வாழ்க்கைத்துணை, கூட்டுத்தொழில், பொதுமக்கள் தொடர்பு.';
      case BnnRelationType.second2:
        return 'தன வரவு, குடும்ப வளர்ச்சி, வாக்கு, அடுத்தகட்ட வாழ்வியல் நிகழ்வுகள்.';
      case BnnRelationType.twelfth12:
        return 'செலவு, முதலீடு, வெளிநாடு, ஆன்மீகம், பூர்வ கர்ம தொடர்பு.';
      case BnnRelationType.secondTwelfth212:
        return 'குடும்பம், பணம், சேமிப்பு, செலவு, வெளிநாடு, ஆன்மீக தொடர்பு.';
    }
  }
}

/// Planetary Relationship Status in BNN
enum BnnPlanetRelationship {
  friend('🟢 நட்பு', 'Friend'),
  enemy('🔴 பகை', 'Enemy'),
  neutral('🟡 சமம்', 'Neutral');

  final String labelTa;
  final String labelEn;
  const BnnPlanetRelationship(this.labelTa, this.labelEn);
}

/// Karakatwa Master Data for BNN Planets (Max 10 per planet)
class BnnKarakatwa {
  final String planetKey;
  final String tamilName;
  final List<String> karakatwas;

  const BnnKarakatwa({
    required this.planetKey,
    required this.tamilName,
    required this.karakatwas,
  });

  static const Map<String, List<String>> masterKarakatwas = {
    'Jupiter': [
      'ஜீவகாரகன் (உயிர், தான்)',
      'குரு அருள் & ஆசி',
      'ஞானம் & தெய்வீக அறிவு',
      'குழந்தைகள் பாக்கியம்',
      'செல்வம் & நிதி வளர்ச்சி',
      'மரியாதை & சமூக அந்தஸ்து',
      'ஆன்மீக ஈடுபாடு',
      'உயர் கல்வி & வழிகாட்டுதல்',
      'அதிர்ஷ்டம் & நல்வாய்ப்புகள்',
      'நற்பெயர் & அறச்சிந்தனை',
    ],
    'Saturn': [
      'கர்மகாரகன் (தொழில், வேலை)',
      'உழைப்பு & விடாமுயற்சி',
      'பொறுப்பு & கடமை',
      'நீண்ட கால வளர்ச்சி',
      'தாமதங்கள் & சோதனைகள்',
      'சேவை & கீழ்நிலை பணியாளர்கள்',
      'ஆயுள் & விவேகம்',
      'ஒழுக்கம் & கட்டுப்பாடு',
      'இயந்திரங்கள் & தொழிற்சாலை',
      'பூர்வ கர்ம பாக்கிகள்',
    ],
    'Venus': [
      'களத்திரகாரகன் (மனைவி/துணை)',
      'தனம் & பணப்புழக்கம்',
      'வாகனம் & சொகுசு வாழ்க்கை',
      'கலை, இசை & அழகுணர்வு',
      'மகிழ்ச்சி & சுகபோகம்',
      'ஆடை ஆபரணங்கள்',
      'திருமண வாழ்வு & அன்பு',
      'வியாபார ஈர்ப்பு',
      'பெண்கள் தொடர்பு',
      'வசீகர சக்தி',
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
      'கோபம் & உணர்ச்சி வேகம்',
    ],
    'Sun': [
      'பிதுர்காரகன் (தந்தை)',
      'அரசு & நிர்வாகம்',
      'தலைமைத்துவ பண்பு',
      'கௌரவம் & புகழ்',
      'ஆத்ம பலம் & உறுதி',
      'அரசியல் செல்வாக்கு',
      'உயர் அதிகாரிகள் தொடர்பு',
      'ஆரோக்கியம் & ஒளி',
      'தன்னம்பிக்கை',
      'அதிகார பதவி',
    ],
    'Moon': [
      'மாதுர்காரகன் (தாய்)',
      'மனம் & உணர்வுகள்',
      'பயணங்கள் & இடமாற்றம்',
      'கற்பனை & படைப்பாற்றல்',
      'நீர் நிலைகள் & திரவங்கள்',
      'உணவு & விருந்தோம்பல்',
      'மாற்றம் & சலனம்',
      'இரக்கம் & தாய்மை அன்பு',
      'பொதுமக்கள் தொடர்பு',
      'கலை ஆர்வம்',
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
      'சட்ட அறிவு',
      'தகவல் தொழில்நுட்பம்',
    ],
    'Rahu': [
      'மாயை & பேராசை',
      'வெளிநாட்டு பயணம் & தொடர்பு',
      'திடீர் உயர்வு & பிரம்மாண்டம்',
      'தொழில்நுட்பம் & எலக்ட்ரானிக்ஸ்',
      'தந்தை வழி பாட்டனார்',
      'வித்தியாசமான சிந்தனை',
      'மருந்து & ரசாயனம்',
      'திரைத்துறை & மாய உலகம்',
      'மறைமுக வருமானம்',
      'அதிவேக வளர்ச்சி',
    ],
    'Ketu': [
      'மோக்ஷ & ஞானகாரகன்',
      'ஆன்மீகம் & துறவு',
      'ஆராய்ச்சி & ஆழ்ந்த ஆய்வு',
      'தாய் வழி பாட்டனார்',
      'தடைகள் மூலம் பக்குவம்',
      'மருத்துவம் & மூலிகைகள்',
      'சட்ட நிபுணத்துவம்',
      'மின்னணு நுட்பங்கள்',
      'பற்றற்ற மனநிலை',
      'முக்தி நோக்கம்',
    ],
  };

  static List<String> getKarakatwasForPlanet(String planetKey) {
    return masterKarakatwas[planetKey] ?? ['பொதுவான கிரக காரகத்துவம்.'];
  }
}

/// Normalized Planet Position representation for BNN analysis
class BnnPlanetPosition {
  final String planetKey; // 'Sun', 'Moon', 'Mars', 'Mercury', 'Jupiter', 'Venus', 'Saturn', 'Rahu', 'Ketu'
  final String tamilName; // 'சூரியன்', 'சந்திரன்', etc.
  final String englishName;
  final int signNumber; // 1 to 12 (1 = Mesham, ..., 12 = Meenam)
  final String signNameTa;
  final String signNameEn;
  final int houseNumber; // 1 to 12 from Lagna
  final double degreeInSign; // 0.0 to < 30.0
  final double absoluteLongitude; // 0.0 to < 360.0
  final int nakshatraIndex;
  final String nakshatraNameTa;
  final String nakshatraNameEn;
  final int pada;
  final bool isRetrograde;

  const BnnPlanetPosition({
    required this.planetKey,
    required this.tamilName,
    required this.englishName,
    required this.signNumber,
    required this.signNameTa,
    required this.signNameEn,
    this.houseNumber = 1,
    required this.degreeInSign,
    required this.absoluteLongitude,
    this.nakshatraIndex = 0,
    this.nakshatraNameTa = '',
    this.nakshatraNameEn = '',
    this.pada = 1,
    this.isRetrograde = false,
  });

  /// Factory creating normalized position from absolute longitude
  factory BnnPlanetPosition.fromAbsoluteLongitude({
    required String planetKey,
    required String tamilName,
    required String englishName,
    required double absoluteLongitude,
    int houseNumber = 1,
    bool isRetrograde = false,
  }) {
    final double normLong = AstrologyCalculator.normalizeDegrees(absoluteLongitude);
    final int signIndex0 = (normLong / 30.0).floor() % 12; // 0..11
    final int signNum = signIndex0 + 1; // 1..12
    final double deg = normLong % 30.0;

    final int totalSecs = (normLong * AstrologyCalculator.arcsecondsPerDegree).round() % AstrologyCalculator.totalArcseconds;
    final int nakIdx = (totalSecs ~/ AstrologyCalculator.arcsecondsPerNakshatra).clamp(0, 26);
    final int padaNum = ((totalSecs % AstrologyCalculator.arcsecondsPerNakshatra) ~/ AstrologyCalculator.arcsecondsPerPada).clamp(0, 3) + 1;

    final rasiTa = signIndex0 < AstrologyCalculator.rasiNamesTa.length
        ? AstrologyCalculator.rasiNamesTa[signIndex0]
        : 'மேஷம்';
    final rasiEn = signIndex0 < AstrologyCalculator.rasiNamesEn.length
        ? AstrologyCalculator.rasiNamesEn[signIndex0]
        : 'Aries';

    return BnnPlanetPosition(
      planetKey: planetKey,
      tamilName: tamilName,
      englishName: englishName,
      signNumber: signNum,
      signNameTa: rasiTa,
      signNameEn: rasiEn,
      houseNumber: houseNumber,
      degreeInSign: deg,
      absoluteLongitude: normLong,
      nakshatraIndex: nakIdx,
      nakshatraNameTa: AstrologyCalculator.nakshatrasTa[nakIdx],
      nakshatraNameEn: AstrologyCalculator.nakshatrasEn[nakIdx],
      pada: padaNum,
      isRetrograde: isRetrograde,
    );
  }

  /// Factory creating normalized position from existing PlanetDetail
  factory BnnPlanetPosition.fromPlanetDetail(PlanetDetail p, {int lagnaRasiIndex = 0}) {
    final int house = ((p.rasiIndex - lagnaRasiIndex + 12) % 12) + 1;
    return BnnPlanetPosition(
      planetKey: p.name,
      tamilName: p.tamilName,
      englishName: p.name,
      signNumber: p.rasiIndex + 1,
      signNameTa: p.rasiNameTa,
      signNameEn: p.rasiNameEn,
      houseNumber: house,
      degreeInSign: p.degreeInRasi,
      absoluteLongitude: p.longitude,
      nakshatraIndex: p.nakshatraIndex,
      nakshatraNameTa: p.nakshatraNameTa,
      nakshatraNameEn: p.nakshatraNameEn,
      pada: p.pada,
      isRetrograde: p.isRetrograde,
    );
  }

  String get formattedDegree => '${degreeInSign.toStringAsFixed(2)}°';

  String get formattedDegreeDMS => AstrologyCalculator.formatDMS(degreeInSign);
}

/// Single BNN Connection between a source planet and a target planet
class BnnConnection {
  final BnnPlanetPosition sourcePlanet;
  final BnnPlanetPosition targetPlanet;
  final int relativeHouse; // 1, 5, 9, 3, 11, 7, 2, 12
  final BnnRelationType directionType;
  final int directionPriority; // 1 (1,5,9) -> 2 (3,11) -> 3 (7) -> 4 (2) -> 5 (12)
  final BnnPlanetRelationship relationship;
  final List<String> karakatwas;
  final String interpretationTa;

  const BnnConnection({
    required this.sourcePlanet,
    required this.targetPlanet,
    required this.relativeHouse,
    required this.directionType,
    required this.directionPriority,
    required this.relationship,
    required this.karakatwas,
    required this.interpretationTa,
  });
}

/// Result of a single BNN Relationship Group analysis
class BnnRelationResult {
  final BnnPlanetPosition sourcePlanet;
  final BnnRelationType relationType;
  final String relationTitleTa;
  final List<int> relatedSigns;
  final List<String> relatedSignNamesTa;
  final List<BnnPlanetPosition> relatedPlanets;
  final List<BnnConnection> connections;
  final String baseSignificanceTa;
  final String interpretationTa;

  const BnnRelationResult({
    required this.sourcePlanet,
    required this.relationType,
    required this.relationTitleTa,
    required this.relatedSigns,
    required this.relatedSignNamesTa,
    required this.relatedPlanets,
    this.connections = const [],
    required this.baseSignificanceTa,
    required this.interpretationTa,
  });

  bool get hasRelatedPlanets => relatedPlanets.isNotEmpty;
}

/// Complete BNN analysis for a selected source planet
class BnnPlanetAnalysis {
  final BnnPlanetPosition sourcePlanet;
  final Map<BnnRelationType, BnnRelationResult> relationResults;
  final List<BnnConnection> allSortedConnections;

  const BnnPlanetAnalysis({
    required this.sourcePlanet,
    required this.relationResults,
    this.allSortedConnections = const [],
  });

  BnnRelationResult get trine159 => relationResults[BnnRelationType.trine159]!;
  BnnRelationResult get upachaya311 => relationResults[BnnRelationType.upachaya311]!;
  BnnRelationResult get seventh7 => relationResults[BnnRelationType.seventh7]!;
  BnnRelationResult get second2 =>
      relationResults[BnnRelationType.second2] ??
      relationResults[BnnRelationType.secondTwelfth212]!;
  BnnRelationResult get twelfth12 =>
      relationResults[BnnRelationType.twelfth12] ??
      relationResults[BnnRelationType.secondTwelfth212]!;
  BnnRelationResult get secondTwelfth212 => relationResults[BnnRelationType.secondTwelfth212]!;
}

/// Continuous Vimshottari Dasha period for BNN
class BnnDashaPeriod {
  final String level; // Mahadasha, Bhukti, Antara, Sookshma
  final String planetKey;
  final String planetNameTa;
  final DateTime startDate;
  final DateTime endDate;
  final double durationYears;
  final List<BnnDashaPeriod> subPeriods;

  const BnnDashaPeriod({
    required this.level,
    required this.planetKey,
    required this.planetNameTa,
    required this.startDate,
    required this.endDate,
    required this.durationYears,
    this.subPeriods = const [],
  });
}

/// Vimshottari Dasha calculation result from Moon's actual position
class BnnDashaResult {
  final String startingPlanetTa;
  final String startingPlanetEn;
  final double balanceYears;
  final String balanceFormatted;
  final List<BnnDashaPeriod> mahadashas;

  const BnnDashaResult({
    required this.startingPlanetTa,
    required this.startingPlanetEn,
    required this.balanceYears,
    required this.balanceFormatted,
    required this.mahadashas,
  });
}

/// Complete BNN Horoscope Chart Data container
class BnnChartData {
  final DateTime birthDateTime;
  final double latitude;
  final double longitude;
  final double utcOffsetHours;
  final String placeName;
  final BnnPlanetPosition lagna;
  final List<BnnPlanetPosition> planets;
  final Map<String, BnnPlanetAnalysis> analyses;
  final BnnDashaResult dashaResult;

  const BnnChartData({
    required this.birthDateTime,
    required this.latitude,
    required this.longitude,
    required this.utcOffsetHours,
    this.placeName = '',
    required this.lagna,
    required this.planets,
    required this.analyses,
    required this.dashaResult,
  });
}
