import '../services/astrology_calculator.dart';

/// BNN Relationship Types according to Classical Bhrigu Nandi Nadi Astrology
enum BnnRelationType {
  trine159,         // (1, 5, 9) திரிகோண தொடர்பு
  upachaya311,      // (3, 11) முயற்சி / லாப தொடர்பு
  seventh7,         // (7) நேரெதிர் தொடர்பு
  secondTwelfth212, // (2, 12) குடும்ப / செலவு தொடர்பு
}

extension BnnRelationTypeExtension on BnnRelationType {
  String get tamilTitle {
    switch (this) {
      case BnnRelationType.trine159:
        return '(1,5,9) திரிகோண தொடர்பு';
      case BnnRelationType.upachaya311:
        return '(3,11) முயற்சி / லாப தொடர்பு';
      case BnnRelationType.seventh7:
        return '(7) நேரெதிர் தொடர்பு';
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
      case BnnRelationType.secondTwelfth212:
        return 'குடும்பம், பணம், சேமிப்பு, செலவு, வெளிநாடு, ஆன்மீக தொடர்பு.';
    }
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
  final double degreeInSign; // 0.0 to < 30.0
  final double absoluteLongitude; // 0.0 to < 360.0
  final bool isRetrograde;

  const BnnPlanetPosition({
    required this.planetKey,
    required this.tamilName,
    required this.englishName,
    required this.signNumber,
    required this.signNameTa,
    required this.signNameEn,
    required this.degreeInSign,
    required this.absoluteLongitude,
    this.isRetrograde = false,
  });

  /// Factory creating normalized position from absolute longitude
  factory BnnPlanetPosition.fromAbsoluteLongitude({
    required String planetKey,
    required String tamilName,
    required String englishName,
    required double absoluteLongitude,
    bool isRetrograde = false,
  }) {
    final double normLong = ((absoluteLongitude % 360.0) + 360.0) % 360.0;
    final int signIndex0 = (normLong / 30.0).floor() % 12; // 0..11
    final int signNum = signIndex0 + 1; // 1..12
    final double deg = normLong % 30.0;

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
      degreeInSign: deg,
      absoluteLongitude: normLong,
      isRetrograde: isRetrograde,
    );
  }

  /// Factory creating normalized position from existing PlanetDetail
  factory BnnPlanetPosition.fromPlanetDetail(PlanetDetail p) {
    return BnnPlanetPosition.fromAbsoluteLongitude(
      planetKey: p.name,
      tamilName: p.tamilName,
      englishName: p.name,
      absoluteLongitude: p.longitude,
      isRetrograde: p.isRetrograde,
    );
  }

  /// Formatted degree for display: e.g. "12.50°" or "12° 30'"
  String get formattedDegree {
    return '${degreeInSign.toStringAsFixed(2)}°';
  }

  /// DMS string: e.g. "12°30'15\""
  String get formattedDegreeDMS {
    final int d = degreeInSign.floor();
    final double remM = (degreeInSign - d) * 60;
    final int m = remM.floor();
    final int s = ((remM - m) * 60).round();
    return "${d.toString().padLeft(2, '0')}°${m.toString().padLeft(2, '0')}'${s.toString().padLeft(2, '0')}\"";
  }
}

/// Result of a single BNN Relationship Group analysis
class BnnRelationResult {
  final BnnPlanetPosition sourcePlanet;
  final BnnRelationType relationType;
  final String relationTitleTa;
  final List<int> relatedSigns;
  final List<String> relatedSignNamesTa;
  final List<BnnPlanetPosition> relatedPlanets;
  final String baseSignificanceTa;
  final String interpretationTa;

  const BnnRelationResult({
    required this.sourcePlanet,
    required this.relationType,
    required this.relationTitleTa,
    required this.relatedSigns,
    required this.relatedSignNamesTa,
    required this.relatedPlanets,
    required this.baseSignificanceTa,
    required this.interpretationTa,
  });

  bool get hasRelatedPlanets => relatedPlanets.isNotEmpty;
}

/// Complete BNN analysis for a selected source planet
class BnnPlanetAnalysis {
  final BnnPlanetPosition sourcePlanet;
  final Map<BnnRelationType, BnnRelationResult> relationResults;

  const BnnPlanetAnalysis({
    required this.sourcePlanet,
    required this.relationResults,
  });

  BnnRelationResult get trine159 => relationResults[BnnRelationType.trine159]!;
  BnnRelationResult get upachaya311 => relationResults[BnnRelationType.upachaya311]!;
  BnnRelationResult get seventh7 => relationResults[BnnRelationType.seventh7]!;
  BnnRelationResult get secondTwelfth212 => relationResults[BnnRelationType.secondTwelfth212]!;
}
