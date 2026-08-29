import '../services/astrology_calculator.dart';

/// 9 Classical Planets in Mundane Astrology
enum Planet {
  sun('Sun', 'சூரியன்'),
  moon('Moon', 'சந்திரன்'),
  mars('Mars', 'செவ்வாய்'),
  mercury('Mercury', 'புதன்'),
  jupiter('Jupiter', 'குரு'),
  venus('Venus', 'சுக்கிரன்'),
  saturn('Saturn', 'சனி'),
  rahu('Rahu', 'ராகு'),
  ketu('Ketu', 'கேது');

  final String englishName;
  final String tamilName;
  const Planet(this.englishName, this.tamilName);
}

/// Planet Position in Mundane Astrology Chart
class PlanetPosition {
  final String name;
  final String tamilName;
  final double longitude; // Absolute longitude (0.0 to < 360.0)
  final int rasiIndex; // 0 to 11
  final String rasiName;
  final String rasiNameTa;
  final double degreeInRasi; // 0.0 to < 30.0
  final int degree;
  final int minute;
  final int second;
  final int house; // 1 to 12 from Ascendant
  final int nakshatraIndex; // 0 to 26
  final String nakshatra;
  final String nakshatraNameTa;
  final int pada; // 1 to 4
  final bool isRetrograde;

  const PlanetPosition({
    required this.name,
    required this.tamilName,
    required this.longitude,
    required this.rasiIndex,
    required this.rasiName,
    required this.rasiNameTa,
    required this.degreeInRasi,
    required this.degree,
    required this.minute,
    required this.second,
    this.house = 1,
    this.nakshatraIndex = 0,
    this.nakshatra = '',
    this.nakshatraNameTa = '',
    this.pada = 1,
    this.isRetrograde = false,
  });

  /// Factory creating position from sidereal absolute longitude
  factory PlanetPosition.fromAbsoluteLongitude({
    required String name,
    required String tamilName,
    required double absoluteLongitude,
    int house = 1,
    bool isRetrograde = false,
  }) {
    final normLong = AstrologyCalculator.normalizeDegrees(absoluteLongitude);
    final rasiIdx = (normLong / 30.0).floor() % 12;
    final degInRasi = normLong % 30.0;

    final d = degInRasi.floor();
    final remM = (degInRasi - d) * 60.0;
    final m = remM.floor();
    final s = ((remM - m) * 60.0).round();

    final totalSecs = (normLong * AstrologyCalculator.arcsecondsPerDegree).round() % AstrologyCalculator.totalArcseconds;
    final nakIdx = (totalSecs ~/ AstrologyCalculator.arcsecondsPerNakshatra).clamp(0, 26);
    final padaNum = ((totalSecs % AstrologyCalculator.arcsecondsPerNakshatra) ~/ AstrologyCalculator.arcsecondsPerPada).clamp(0, 3) + 1;

    final rasiEn = rasiIdx < AstrologyCalculator.rasiNamesEn.length ? AstrologyCalculator.rasiNamesEn[rasiIdx] : 'Aries';
    final rasiTa = rasiIdx < AstrologyCalculator.rasiNamesTa.length ? AstrologyCalculator.rasiNamesTa[rasiIdx] : 'மேஷம்';
    final nakEn = nakIdx < AstrologyCalculator.nakshatrasEn.length ? AstrologyCalculator.nakshatrasEn[nakIdx] : 'Ashwini';
    final nakTa = nakIdx < AstrologyCalculator.nakshatrasTa.length ? AstrologyCalculator.nakshatrasTa[nakIdx] : 'அசுவினி';

    return PlanetPosition(
      name: name,
      tamilName: tamilName,
      longitude: normLong,
      rasiIndex: rasiIdx,
      rasiName: rasiEn,
      rasiNameTa: rasiTa,
      degreeInRasi: degInRasi,
      degree: d,
      minute: m,
      second: s,
      house: house,
      nakshatraIndex: nakIdx,
      nakshatra: nakEn,
      nakshatraNameTa: nakTa,
      pada: padaNum,
      isRetrograde: isRetrograde,
    );
  }

  /// Formatted DMS string: DD° MM' SS"
  String get formattedDMS => "${degree.toString().padLeft(2, '0')}° ${minute.toString().padLeft(2, '0')}' ${second.toString().padLeft(2, '0')}\"";

  /// Formatted decimal string
  String get formattedDegree => "${degreeInRasi.toStringAsFixed(2)}°";
}

/// Planetary Aspect in Mundane Astrology
class Aspect {
  final String planet1;
  final String planet2;
  final String aspectType; // Conjunction, Sextile, Square, Trine, Opposition
  final String aspectTypeTa;
  final double targetAngle; // 0, 60, 90, 120, 180
  final double angularDistance; // Actual separation in degrees
  final double orb; // Allowed orb ± deg
  final String nature; // Benefic, Malefic, Neutral
  final String natureTa;

  const Aspect({
    required this.planet1,
    required this.planet2,
    required this.aspectType,
    required this.aspectTypeTa,
    required this.targetAngle,
    required this.angularDistance,
    required this.orb,
    required this.nature,
    required this.natureTa,
  });
}

/// House Cluster Detection (3 or more planets in the same house)
class HouseCluster {
  final int houseNumber;
  final List<PlanetPosition> planets;
  final String houseMeaningTa;
  final int predictionStrength; // 0 to 100
  final String interpretationTa;

  const HouseCluster({
    required this.houseNumber,
    required this.planets,
    required this.houseMeaningTa,
    required this.predictionStrength,
    required this.interpretationTa,
  });

  int get planetCount => planets.length;
}

/// Transit Comparison Item (Natal/Event Chart Planet vs Current Transit Planet)
class MundaneTransitComparison {
  final PlanetPosition transitPlanet;
  final PlanetPosition eventPlanet;
  final String aspectType;
  final String aspectTypeTa;
  final double angularDistance;
  final String interpretationTa;
  final int strength; // 0 to 100
  final bool isFavorable;

  const MundaneTransitComparison({
    required this.transitPlanet,
    required this.eventPlanet,
    required this.aspectType,
    required this.aspectTypeTa,
    required this.angularDistance,
    required this.interpretationTa,
    required this.strength,
    this.isFavorable = true,
  });
}

/// Mundane Astrology Prediction Record
class MundanePrediction {
  final String category; // Politics, Economy, Public, Agriculture, Employment, Government, Authority, Foreign Relations, Security, Crisis, Law, Culture, Change, Transit
  final String categoryTa;
  final String title;
  final String titleTa;
  final String descriptionTa;
  final int strength; // 0 to 100
  final bool isFavorable;
  final String intensity; // High, Moderate, Low
  final String intensityTa;
  final List<String> contributingFactors;

  const MundanePrediction({
    required this.category,
    required this.categoryTa,
    required this.title,
    required this.titleTa,
    required this.descriptionTa,
    required this.strength,
    this.isFavorable = true,
    required this.intensity,
    required this.intensityTa,
    this.contributingFactors = const [],
  });
}

/// Complete Mundane Astrology Chart
class MundaneChart {
  final String country;
  final String state;
  final String city;
  final DateTime chartDateTime;
  final double latitude;
  final double longitude;
  final double utcOffsetHours;
  final PlanetPosition ascendant;
  final List<PlanetPosition> planetPositions; // Sorted ascending by absolute longitude
  final List<Aspect> aspects;
  final List<HouseCluster> clusters;
  final List<MundanePrediction> predictions; // Sorted descending by strength
  final List<MundaneTransitComparison> transitComparisons;
  final String overallSummaryTa;

  const MundaneChart({
    this.country = 'India',
    this.state = 'Delhi',
    this.city = 'New Delhi',
    required this.chartDateTime,
    required this.latitude,
    required this.longitude,
    this.utcOffsetHours = 5.5,
    required this.ascendant,
    required this.planetPositions,
    required this.aspects,
    this.clusters = const [],
    required this.predictions,
    this.transitComparisons = const [],
    required this.overallSummaryTa,
  });

  String get regionName => '$city, $state, $country';
}

/// Master Static Data Repository for Mundane Significations
class MundaneData {
  /// 12 Mundane Houses and their National / World Meanings
  static const Map<int, String> houseMeaningsTa = {
    1: 'மக்கள், நாட்டின் பொதுநிலை, தேசிய அடையாளம், பொது நல்வாழ்வு.',
    2: 'தேசிய வருவாய், பொருளாதாரம், நிதி அமைப்புகள், வங்கி மற்றும் கருவூலம்.',
    3: 'தகவல் தொடர்பு, ஊடகம், பத்திரிகை, போக்குவரத்து மற்றும் அண்டை நாடுகள்.',
    4: 'நிலம், விவசாயம், இயற்கை வளங்கள், கனிமங்கள், வானிலை மற்றும் எதிர்க்கட்சிகள்.',
    5: 'கல்வி, குழந்தைகள், கலை, பொழுதுபோக்கு, பங்குச்சந்தை மற்றும் தேசிய விளையாட்டு.',
    6: 'தொழிலாளர், வேலைவாய்ப்பு, பொது சுகாதாரம், பொதுக்கடன் மற்றும் பாதுகாப்பு படை.',
    7: 'வெளிநாட்டு உறவுகள், சர்வதேச ஒப்பந்தங்கள், போர், அமைதி மற்றும் வர்த்தக கூட்டாளிகள்.',
    8: 'கடன், வரி, தேசிய நெருக்கடிகள், இறப்பு விகிதம், பேரிடர்கள் மற்றும் ரகசிய மாற்றங்கள்.',
    9: 'சட்டம், உச்ச நீதிமன்றம், உயர்கல்வி, மதம், ஆன்மீகம் மற்றும் நீண்ட தூர வெளிநாட்டு பயணம்.',
    10: 'அரசு, ஆட்சி, அதிகாரம், தலைமை, பிரதமர்/ஜனாதிபதி மற்றும் தேசிய கௌரவம்.',
    11: 'அரசின் வருவாய், தேசிய வளர்ச்சி, சட்டமியற்றும் மன்றம் மற்றும் நட்பு நாடுகள்.',
    12: 'செலவு, இழப்பு, சிறை, உளவுத்துறை, ரகசிய நடவடிக்கைகள் மற்றும் வெளிநாட்டு முதலீடுகள்.',
  };

  /// 9 Planetary Mundane Significations
  static const Map<String, String> planetarySignificationsTa = {
    'Sun': 'அரசு, ஆட்சி, அதிகாரம், தலைமை, ஜனாதிபதி/பிரதமர், தேசிய கௌரவம்.',
    'Moon': 'மக்கள், பொதுமக்கள் மனநிலை, பெண்கள், நீர்வளம், உணவு உற்பத்தி.',
    'Mars': 'இராணுவம், மோதல், பாதுகாப்பு, நிலம், தீ விபத்து, தொழில்நுட்பம்.',
    'Mercury': 'வணிகம், தகவல் தொடர்பு, ஊடகம், வர்த்தகம், கல்வி, போக்குவரத்து.',
    'Jupiter': 'சட்டம், நிதி, நீதித்துறை, வளர்ச்சி, வங்கி, மதம், அமைதி.',
    'Venus': 'கலை, கலாசாரம், செல்வம், பெண்கள் நலம், பொழுதுபோக்கு, வெளிநாட்டு வர்த்தகம்.',
    'Saturn': 'தொழிலாளர், கட்டுப்பாடு, வறுமை, விவசாயம், சுரங்கம், முதியோர்.',
    'Rahu': 'திடீர் மாற்றம், வெளிநாட்டு தாக்கம், தொழில்நுட்பம், அசாதாரண நிகழ்வுகள்.',
    'Ketu': 'பிரிவு, மறைநிலை மாற்றம், ஆன்மீகம், இயற்கை சீற்றம், நோய்த்தொற்று.',
  };
}

/// Preset Mundane Examples for Demonstration & Testing
class MundaneExample {
  /// India Independence Chart: 15 August 1947, 00:00 AM, New Delhi
  static MundaneChart get indiaIndependenceChart {
    final dt = DateTime(1947, 8, 15, 0, 0);

    final asc = PlanetPosition.fromAbsoluteLongitude(
      name: 'Lagna',
      tamilName: 'லக்னம்',
      absoluteLongitude: 37.5, // Taurus / ரிஷபம் ~ 7° 30'
      house: 1,
    );

    // 9 Planets sorted ascending by absolute longitude
    final planets = [
      PlanetPosition.fromAbsoluteLongitude(
        name: 'Rahu',
        tamilName: 'ராகு',
        absoluteLongitude: 29.8, // Taurus / மேஷம்-ரிஷப சந்தி (29° 48')
        house: 1,
        isRetrograde: true,
      ),
      PlanetPosition.fromAbsoluteLongitude(
        name: 'Mars',
        tamilName: 'செவ்வாய்',
        absoluteLongitude: 74.2, // Gemini / மிதுனம்
        house: 2,
      ),
      PlanetPosition.fromAbsoluteLongitude(
        name: 'Moon',
        tamilName: 'சந்திரன்',
        absoluteLongitude: 93.9, // Cancer / கடகம் (Pushya)
        house: 3,
      ),
      PlanetPosition.fromAbsoluteLongitude(
        name: 'Mercury',
        tamilName: 'புதன்',
        absoluteLongitude: 103.5, // Cancer / கடகம்
        house: 3,
      ),
      PlanetPosition.fromAbsoluteLongitude(
        name: 'Venus',
        tamilName: 'சுக்கிரன்',
        absoluteLongitude: 104.8, // Cancer / கடகம்
        house: 3,
      ),
      PlanetPosition.fromAbsoluteLongitude(
        name: 'Sun',
        tamilName: 'சூரியன்',
        absoluteLongitude: 118.0, // Cancer / கடகம் (Ashlesha)
        house: 3,
      ),
      PlanetPosition.fromAbsoluteLongitude(
        name: 'Saturn',
        tamilName: 'சனி',
        absoluteLongitude: 120.4, // Cancer / கடகம்-சிம்ம சந்தி
        house: 3,
      ),
      PlanetPosition.fromAbsoluteLongitude(
        name: 'Ketu',
        tamilName: 'கேது',
        absoluteLongitude: 209.8, // Scorpio / விருச்சிகம்
        house: 7,
        isRetrograde: true,
      ),
      PlanetPosition.fromAbsoluteLongitude(
        name: 'Jupiter',
        tamilName: 'குரு',
        absoluteLongitude: 227.5, // Libra / துலாம்
        house: 6,
      ),
    ]..sort((a, b) => a.longitude.compareTo(b.longitude));

    final aspects = [
      const Aspect(
        planet1: 'சந்திரன்',
        planet2: 'புதன்',
        aspectType: 'Conjunction',
        aspectTypeTa: 'இணைவு (0°)',
        targetAngle: 0.0,
        angularDistance: 9.6,
        orb: 8.0,
        nature: 'Benefic',
        natureTa: 'சுப அறிவு & தகவல் மேன்மை',
      ),
      const Aspect(
        planet1: 'சூரியன்',
        planet2: 'சனி',
        aspectType: 'Conjunction',
        aspectTypeTa: 'இணைவு (0°)',
        targetAngle: 0.0,
        angularDistance: 2.4,
        orb: 8.0,
        nature: 'Malefic',
        natureTa: 'அரசு & தொழிலாளர் சவால்கள்',
      ),
      const Aspect(
        planet1: 'ராகு',
        planet2: 'கேது',
        aspectType: 'Opposition',
        aspectTypeTa: 'நேரெதிர் பார்வை (180°)',
        targetAngle: 180.0,
        angularDistance: 180.0,
        orb: 8.0,
        nature: 'Malefic',
        natureTa: 'தேசிய & சர்வதேச நிலைமாற்றம்',
      ),
    ];

    final clusters = [
      HouseCluster(
        houseNumber: 3,
        planets: planets.where((p) => p.house == 3).toList(),
        houseMeaningTa: MundaneData.houseMeaningsTa[3]!,
        predictionStrength: 95,
        interpretationTa: '3-ஆம் வீட்டில் 5 கிரகங்கள் (சந்திரன், புதன், சுக்கிரன், சூரியன், சனி) சேர்ந்துள்ளதால் தகவல் தொடர்பு, ஊடகம், விண்வெளி மற்றும் அண்டை நாட்டு உறவுகளில் இந்தியா உலகளவில் அபார வளர்ச்சி அடையும்.',
      ),
    ];

    final predictions = [
      const MundanePrediction(
        category: 'Politics',
        categoryTa: 'அரசியல் & அரசு',
        title: 'Strong Democratic Institutions',
        titleTa: 'வலுவான மக்களாட்சி & சர்வதேச செல்வாக்கு',
        descriptionTa: 'சூரியன் மற்றும் சந்திரன் சுப சேர்க்கை நாட்டின் ஜனநாயக அமைப்புகளை நீண்ட காலத்திற்கு உறுதிப்படுத்தும்.',
        strength: 92,
        isFavorable: true,
        intensity: 'High',
        intensityTa: 'அதிதீவிர சுப பலன்',
        contributingFactors: ['சூரியன் பலம்', '3-ஆம் வீட்டு கிரக சேர்க்கை'],
      ),
      const MundanePrediction(
        category: 'Economy',
        categoryTa: 'பொருளாதாரம் & வர்த்தகம்',
        title: 'Economic Expansion & Trade',
        titleTa: 'பொருளாதார வளர்ச்சி & தகவல் தொழில்நுட்ப புரட்சி',
        descriptionTa: 'புதன் மற்றும் சுக்கிரன் கடக ராசியில் இணைவதால் சேவை துறை, மென்பொருள் மற்றும் சர்வதேச ஏற்றுமதி பெருமளவில் உயரும்.',
        strength: 88,
        isFavorable: true,
        intensity: 'High',
        intensityTa: 'தீவிர சுப பலன்',
        contributingFactors: ['புதன்-சுக்கிரன் இணைவு', '2-ஆம் வீட்டு அதிபதி நிலை'],
      ),
      const MundanePrediction(
        category: 'Security',
        categoryTa: 'பாதுகாப்பு & எல்லைகள்',
        title: 'Border Vigilance & Defense',
        titleTa: 'எல்லை பாதுகாப்பு & தற்காப்பு பலம்',
        descriptionTa: 'செவ்வாய் மிதுனத்திலும் ராகு-கேது அச்சிலும் இருப்பதால் எல்லை பாதுகாப்பு மற்றும் நவீன ஆயுத பலத்தில் விழிப்புணர்வு தேவை.',
        strength: 78,
        isFavorable: false,
        intensity: 'Moderate',
        intensityTa: 'எச்சரிக்கை பலன்',
        contributingFactors: ['செவ்வாய் நிலை', 'ராகு 1-ஆம் வீடு'],
      ),
    ];

    return MundaneChart(
      country: 'India',
      state: 'Delhi',
      city: 'New Delhi',
      chartDateTime: dt,
      latitude: 28.6139,
      longitude: 77.2090,
      utcOffsetHours: 5.5,
      ascendant: asc,
      planetPositions: planets,
      aspects: aspects,
      clusters: clusters,
      predictions: predictions,
      overallSummaryTa: 'இந்திய சுதந்திர ஜாதகத்தில் 3-ஆம் பாவத்தில் அமைந்த 5 கிரக சேர்க்கை (Stellium) நாட்டை உலகளாவிய தகவல், விண்வெளி மற்றும் ஆன்மீக வல்லரசாக உயர்த்துகிறது.',
    );
  }
}
