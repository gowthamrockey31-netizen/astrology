import '../models/bnn_models.dart';
import 'astrology_calculator.dart';

/// Calculation & Interpretation Engine for Bhrigu Nandi Nadi (BNN)
class BnnEngine {
  /// Planet-specific BNN fundamental indications
  static const Map<String, String> planetMeaningsTa = {
    'Sun': 'அதிகாரம், தலைமை, அரசு மற்றும் தந்தை தொடர்பான பலன்கள்.',
    'Moon': 'மனம், தாய், பயணம் மற்றும் உணர்ச்சி சார்ந்த பலன்கள்.',
    'Mars': 'துணிவு, நிலம், சகோதரம், தொழில்நுட்பம் மற்றும் செயலாற்றல்.',
    'Mercury': 'கல்வி, அறிவு, வியாபாரம், கணக்கு மற்றும் தொடர்புத்திறன்.',
    'Jupiter': 'அதிர்ஷ்டம், கல்வி, குழந்தைகள், செல்வம் மற்றும் குரு அருள்.',
    'Venus': 'திருமணம், காதல், வசதி, கலை மற்றும் செல்வாக்கு.',
    'Saturn': 'தாமதம், கடின உழைப்பு, தொழில், பொறுப்பு மற்றும் நீண்டகால வளர்ச்சி.',
    'Rahu': 'வெளிநாடு, திடீர் உயர்வு, தொழில்நுட்பம் மற்றும் அசாதாரண பலன்.',
    'Ketu': 'ஆன்மீகம், ஆய்வு, ஆராய்ச்சி மற்றும் துறவு மனப்பான்மை.',
  };

  /// Ordered list of all 9 target planets in BNN
  static const List<String> standardPlanetKeys = [
    'Sun',
    'Moon',
    'Mars',
    'Mercury',
    'Jupiter',
    'Venus',
    'Saturn',
    'Rahu',
    'Ketu',
  ];

  /// Normalize existing Map<String, PlanetDetail> into List<BnnPlanetPosition>
  static List<BnnPlanetPosition> normalizePlanets(Map<String, PlanetDetail> planets) {
    final List<BnnPlanetPosition> result = [];

    for (final key in standardPlanetKeys) {
      final p = planets[key];
      if (p != null) {
        result.add(BnnPlanetPosition.fromPlanetDetail(p));
      }
    }

    return result;
  }

  /// Circular Zodiac Calculation (1-indexed: 1 = Mesham ... 12 = Meenam)
  static int getRelativeSign(int baseSign, int offset) {
    return ((baseSign - 1 + offset) % 12) + 1;
  }

  /// Get related signs for a base sign according to BNN relation type
  static List<int> getRelatedSigns(int baseSign, BnnRelationType relationType) {
    return relationType.offsets.map((offset) => getRelativeSign(baseSign, offset)).toList();
  }

  /// Get related sign names in Tamil
  static List<String> getRelatedSignNamesTa(List<int> signs) {
    return signs.map((s) {
      final idx = (s - 1).clamp(0, 11);
      return AstrologyCalculator.rasiNamesTa[idx];
    }).toList();
  }

  /// Find related planets in the specified signs, excluding the source planet.
  /// Sorting Rule:
  /// 1. Primary order: Follows relationship sign sequence (e.g. 1 -> 5 -> 9)
  /// 2. Secondary order: Within the same sign, sort by degree ascending.
  static List<BnnPlanetPosition> getRelatedPlanets({
    required BnnPlanetPosition sourcePlanet,
    required List<int> relatedSignsInOrder,
    required List<BnnPlanetPosition> allPlanets,
  }) {
    final List<BnnPlanetPosition> result = [];

    for (final signNum in relatedSignsInOrder) {
      // Find all planets in this sign, excluding the source planet
      final planetsInSign = allPlanets
          .where((p) => p.signNumber == signNum && p.planetKey != sourcePlanet.planetKey)
          .toList();

      // Sort ascending by degree within this sign
      planetsInSign.sort((a, b) => a.degreeInSign.compareTo(b.degreeInSign));

      result.addAll(planetsInSign);
    }

    return result;
  }

  /// Generate contextual BNN interpretation for a relationship group
  static String generateInterpretation({
    required BnnPlanetPosition sourcePlanet,
    required BnnRelationType relationType,
    required List<BnnPlanetPosition> relatedPlanets,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('தொடர்பு களம்: ${relationType.baseSignificanceTa}');

    if (relatedPlanets.isEmpty) {
      buffer.write('இந்த தொடர்பில் நேரடி கிரகங்கள் இல்லை. இந்த பாவ தொடர்பு அதிபதி மற்றும் சுப பார்வையின் மூலமாக இயங்கும்.');
      return buffer.toString();
    }

    buffer.writeln('\nநாடி கிரக சேர்க்கை பலன்கள்:');
    for (int i = 0; i < relatedPlanets.length; i++) {
      final p = relatedPlanets[i];
      final meaning = planetMeaningsTa[p.planetKey] ?? 'பொதுவான கிரக பலன்கள்.';
      buffer.writeln('${i + 1}. ${p.tamilName} (${p.signNameTa} - ${p.formattedDegree}): $meaning');
    }

    // Additional specific synthesis
    buffer.write('\nநாடி குறிப்பு: ${sourcePlanet.tamilName} உடன் இணையும் ${relatedPlanets.map((e) => e.tamilName).join(', ')} கிரக அமைப்புகள் ஜாதகருக்கு குறித்த காலங்களில் முக்கிய திருப்புமுனைகளை ஏற்படுத்தும்.');

    return buffer.toString();
  }

  /// Analyze a single relationship group for a source planet
  static BnnRelationResult analyzeRelation({
    required BnnPlanetPosition sourcePlanet,
    required BnnRelationType relationType,
    required List<BnnPlanetPosition> allPlanets,
  }) {
    final relatedSigns = getRelatedSigns(sourcePlanet.signNumber, relationType);
    final relatedSignNames = getRelatedSignNamesTa(relatedSigns);
    final relatedPlanets = getRelatedPlanets(
      sourcePlanet: sourcePlanet,
      relatedSignsInOrder: relatedSigns,
      allPlanets: allPlanets,
    );

    final interpretation = generateInterpretation(
      sourcePlanet: sourcePlanet,
      relationType: relationType,
      relatedPlanets: relatedPlanets,
    );

    return BnnRelationResult(
      sourcePlanet: sourcePlanet,
      relationType: relationType,
      relationTitleTa: relationType.tamilTitle,
      relatedSigns: relatedSigns,
      relatedSignNamesTa: relatedSignNames,
      relatedPlanets: relatedPlanets,
      baseSignificanceTa: relationType.baseSignificanceTa,
      interpretationTa: interpretation,
    );
  }

  /// Analyze all 4 BNN relation groups for a given source planet
  static BnnPlanetAnalysis analyzePlanet({
    required BnnPlanetPosition sourcePlanet,
    required List<BnnPlanetPosition> allPlanets,
  }) {
    final Map<BnnRelationType, BnnRelationResult> map = {};

    for (final relType in BnnRelationType.values) {
      map[relType] = analyzeRelation(
        sourcePlanet: sourcePlanet,
        relationType: relType,
        allPlanets: allPlanets,
      );
    }

    return BnnPlanetAnalysis(
      sourcePlanet: sourcePlanet,
      relationResults: map,
    );
  }

  /// Analyze all 9 planets in the chart
  static Map<String, BnnPlanetAnalysis> analyzeAllPlanets(List<BnnPlanetPosition> allPlanets) {
    final Map<String, BnnPlanetAnalysis> result = {};

    for (final p in allPlanets) {
      result[p.planetKey] = analyzePlanet(sourcePlanet: p, allPlanets: allPlanets);
    }

    return result;
  }
}
