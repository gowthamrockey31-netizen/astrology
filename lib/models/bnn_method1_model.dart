import 'bnn_models.dart';

/// Planetary Relationship Type for BNN Method 1
enum BnnMethod1Relation {
  friend('🟢 நட்பு', 'Friend'),
  enemy('🔴 பகை', 'Enemy'),
  neutral('🟡 சமம்', 'Neutral');

  final String labelTa;
  final String labelEn;
  const BnnMethod1Relation(this.labelTa, this.labelEn);
}

/// BNN Method 1 Direction Groups in Strict Priority Sequence:
/// 1, 5, 9 → 3, 11 → 7 → 2 → 12
enum BnnMethod1DirectionGroup {
  trine159(1, '1, 5, 9', '(1, 5, 9) திரிகோண தொடர்பு', [1, 5, 9]),
  upachaya311(2, '3, 11', '(3, 11) முயற்சி / லாப தொடர்பு', [3, 11]),
  seventh7(3, '7', '(7) நேரெதிர் தொடர்பு', [7]),
  second2(4, '2', '(2) தன / குடும்ப / முன்னோக்கு தொடர்பு', [2]),
  twelfth12(5, '12', '(12) விரய / பின்னோக்கு தொடர்பு', [12]);

  final int priority;
  final String label;
  final String titleTa;
  final List<int> relativeHouses;

  const BnnMethod1DirectionGroup(
    this.priority,
    this.label,
    this.titleTa,
    this.relativeHouses,
  );

  static BnnMethod1DirectionGroup? fromRelativeHouse(int relativeHouse) {
    if (relativeHouse == 1 || relativeHouse == 5 || relativeHouse == 9) {
      return BnnMethod1DirectionGroup.trine159;
    } else if (relativeHouse == 3 || relativeHouse == 11) {
      return BnnMethod1DirectionGroup.upachaya311;
    } else if (relativeHouse == 7) {
      return BnnMethod1DirectionGroup.seventh7;
    } else if (relativeHouse == 2) {
      return BnnMethod1DirectionGroup.second2;
    } else if (relativeHouse == 12) {
      return BnnMethod1DirectionGroup.twelfth12;
    }
    return null;
  }
}

/// Strongly typed planetary position model for BNN Method 1
class BnnMethod1Planet {
  final String planetKey; // 'Sun', 'Moon', 'Mars', 'Mercury', 'Jupiter', 'Venus', 'Saturn', 'Rahu', 'Ketu'
  final String planetName; // Tamil name: சூரியன், சந்திரன், etc.
  final String englishName;
  final double longitude; // 0.0 <= longitude < 360.0
  final int sign; // 1 to 12 (1 = Mesham ... 12 = Meenam)
  final String signNameTa;
  final String signNameEn;
  final double degreeWithinSign; // 0.0 to < 30.0
  final int degree; // DD (0..29)
  final int minute; // MM (0..59)
  final double second; // SS (0..59.99)
  final int house; // House from Lagna (1..12)
  final String nakshatra; // Tamil Nakshatra name
  final int nakshatraIndex; // 0..26
  final int nakshatraPada; // 1..4
  final int degreeOrder; // 1 to 9 (assigned based on degree/longitude sorting)
  final bool isRetrograde;

  const BnnMethod1Planet({
    required this.planetKey,
    required this.planetName,
    required this.englishName,
    required this.longitude,
    required this.sign,
    required this.signNameTa,
    required this.signNameEn,
    required this.degreeWithinSign,
    required this.degree,
    required this.minute,
    required this.second,
    required this.house,
    required this.nakshatra,
    required this.nakshatraIndex,
    required this.nakshatraPada,
    this.degreeOrder = 0,
    this.isRetrograde = false,
  });

  /// CopyWith to assign computed degree order
  BnnMethod1Planet copyWith({
    int? degreeOrder,
    int? house,
  }) {
    return BnnMethod1Planet(
      planetKey: planetKey,
      planetName: planetName,
      englishName: englishName,
      longitude: longitude,
      sign: sign,
      signNameTa: signNameTa,
      signNameEn: signNameEn,
      degreeWithinSign: degreeWithinSign,
      degree: degree,
      minute: minute,
      second: second,
      house: house ?? this.house,
      nakshatra: nakshatra,
      nakshatraIndex: nakshatraIndex,
      nakshatraPada: nakshatraPada,
      degreeOrder: degreeOrder ?? this.degreeOrder,
      isRetrograde: isRetrograde,
    );
  }

  /// Exact DMS representation: DD° MM' SS"
  String get formattedDMS {
    final ss = second.toStringAsFixed(0).padLeft(2, '0');
    final mm = minute.toString().padLeft(2, '0');
    final dd = degree.toString().padLeft(2, '0');
    return "$dd° $mm′ $ss″";
  }

  /// Decimal degree formatted representation
  String get formattedDegree => '${degreeWithinSign.toStringAsFixed(2)}°';
}

/// Strongly typed BNN Method 1 planetary connection
class BnnMethod1Connection {
  final BnnMethod1Planet sourcePlanet;
  final BnnMethod1Planet targetPlanet;
  final int sourceHouse;
  final int targetHouse;
  final int relativeHouse; // ((targetHouse - sourceHouse + 12) % 12) + 1
  final double sourceLongitude;
  final double targetLongitude;
  final int sourceSign;
  final int targetSign;
  final BnnMethod1Relation relation;
  final BnnMethod1DirectionGroup directionGroup;
  final int directionPriority; // 1 (1,5,9) -> 2 (3,11) -> 3 (7) -> 4 (2) -> 5 (12)
  final int degreeOrder; // targetPlanet's degree order
  final List<String> karakatwas;

  const BnnMethod1Connection({
    required this.sourcePlanet,
    required this.targetPlanet,
    required this.sourceHouse,
    required this.targetHouse,
    required this.relativeHouse,
    required this.sourceLongitude,
    required this.targetLongitude,
    required this.sourceSign,
    required this.targetSign,
    required this.relation,
    required this.directionGroup,
    required this.directionPriority,
    required this.degreeOrder,
    required this.karakatwas,
  });
}

/// Strongly typed prediction result for a connection
class BnnMethod1Prediction {
  final BnnMethod1Planet sourcePlanet;
  final BnnMethod1Planet targetPlanet;
  final int relativeHouse;
  final BnnMethod1DirectionGroup directionGroup;
  final String directionTitle;
  final BnnMethod1Relation relation;
  final String relationLabel;
  final List<String> karakatwas;
  final String summary;
  final String explanationTa;

  const BnnMethod1Prediction({
    required this.sourcePlanet,
    required this.targetPlanet,
    required this.relativeHouse,
    required this.directionGroup,
    required this.directionTitle,
    required this.relation,
    required this.relationLabel,
    required this.karakatwas,
    required this.summary,
    required this.explanationTa,
  });
}

/// Immutable master calculation result for BNN Method 1
class BnnMethod1Result {
  final DateTime birthDate;
  final String birthTime;
  final double latitude;
  final double longitude;
  final String place;
  final double utcOffsetHours;
  final BnnMethod1Planet lagna;
  final List<BnnMethod1Planet> planetaryPositions;
  final List<BnnMethod1Planet> degreeOrder;
  final Map<String, List<BnnMethod1Connection>> connectionsByPlanet;
  final List<BnnMethod1Connection> allConnections;
  final List<BnnMethod1Prediction> predictions;
  final String calculationStatus;
  final BnnDashaResult? dashaResult;

  const BnnMethod1Result({
    required this.birthDate,
    required this.birthTime,
    required this.latitude,
    required this.longitude,
    required this.place,
    required this.utcOffsetHours,
    required this.lagna,
    required this.planetaryPositions,
    required this.degreeOrder,
    required this.connectionsByPlanet,
    required this.allConnections,
    required this.predictions,
    this.calculationStatus = 'Success',
    this.dashaResult,
  });
}
