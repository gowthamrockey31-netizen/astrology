import '../models/bnn_models.dart';
import '../models/horoscope_calculation_result.dart';
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

  /// Standard Vimshottari Dasha years for 9 planets (Total: 120 yrs)
  static const Map<String, double> vimshottariYears = {
    'Ketu': 7.0,
    'Venus': 20.0,
    'Sun': 6.0,
    'Moon': 10.0,
    'Mars': 7.0,
    'Rahu': 18.0,
    'Jupiter': 16.0,
    'Saturn': 19.0,
    'Mercury': 17.0,
  };

  static const List<String> dashaLordSequence = [
    'Ketu', 'Venus', 'Sun', 'Moon', 'Mars', 'Rahu', 'Jupiter', 'Saturn', 'Mercury'
  ];

  static const List<String> dashaLordSequenceTa = [
    'கேது', 'சுக்கிரன்', 'சூரியன்', 'சந்திரன்', 'செவ்வாய்', 'ராகு', 'குரு', 'சனி', 'புதன்'
  ];

  /// Classical Planetary Friendship Matrix (Source -> Target)
  static const Map<String, Map<String, BnnPlanetRelationship>> planetFriendships = {
    'Sun': {
      'Moon': BnnPlanetRelationship.friend,
      'Mars': BnnPlanetRelationship.friend,
      'Jupiter': BnnPlanetRelationship.friend,
      'Mercury': BnnPlanetRelationship.neutral,
      'Venus': BnnPlanetRelationship.enemy,
      'Saturn': BnnPlanetRelationship.enemy,
      'Rahu': BnnPlanetRelationship.enemy,
      'Ketu': BnnPlanetRelationship.enemy,
    },
    'Moon': {
      'Sun': BnnPlanetRelationship.friend,
      'Mercury': BnnPlanetRelationship.friend,
      'Mars': BnnPlanetRelationship.neutral,
      'Jupiter': BnnPlanetRelationship.neutral,
      'Venus': BnnPlanetRelationship.neutral,
      'Saturn': BnnPlanetRelationship.neutral,
      'Rahu': BnnPlanetRelationship.enemy,
      'Ketu': BnnPlanetRelationship.enemy,
    },
    'Mars': {
      'Sun': BnnPlanetRelationship.friend,
      'Moon': BnnPlanetRelationship.friend,
      'Jupiter': BnnPlanetRelationship.friend,
      'Venus': BnnPlanetRelationship.neutral,
      'Saturn': BnnPlanetRelationship.neutral,
      'Ketu': BnnPlanetRelationship.neutral,
      'Mercury': BnnPlanetRelationship.enemy,
      'Rahu': BnnPlanetRelationship.enemy,
    },
    'Mercury': {
      'Sun': BnnPlanetRelationship.friend,
      'Venus': BnnPlanetRelationship.friend,
      'Mars': BnnPlanetRelationship.neutral,
      'Jupiter': BnnPlanetRelationship.neutral,
      'Saturn': BnnPlanetRelationship.neutral,
      'Rahu': BnnPlanetRelationship.neutral,
      'Ketu': BnnPlanetRelationship.neutral,
      'Moon': BnnPlanetRelationship.enemy,
    },
    'Jupiter': {
      'Sun': BnnPlanetRelationship.friend,
      'Moon': BnnPlanetRelationship.friend,
      'Mars': BnnPlanetRelationship.friend,
      'Saturn': BnnPlanetRelationship.neutral,
      'Rahu': BnnPlanetRelationship.neutral,
      'Ketu': BnnPlanetRelationship.neutral,
      'Mercury': BnnPlanetRelationship.enemy,
      'Venus': BnnPlanetRelationship.enemy,
    },
    'Venus': {
      'Mercury': BnnPlanetRelationship.friend,
      'Saturn': BnnPlanetRelationship.friend,
      'Rahu': BnnPlanetRelationship.friend,
      'Ketu': BnnPlanetRelationship.friend,
      'Mars': BnnPlanetRelationship.neutral,
      'Jupiter': BnnPlanetRelationship.neutral,
      'Sun': BnnPlanetRelationship.enemy,
      'Moon': BnnPlanetRelationship.enemy,
    },
    'Saturn': {
      'Mercury': BnnPlanetRelationship.friend,
      'Venus': BnnPlanetRelationship.friend,
      'Rahu': BnnPlanetRelationship.friend,
      'Jupiter': BnnPlanetRelationship.neutral,
      'Ketu': BnnPlanetRelationship.neutral,
      'Sun': BnnPlanetRelationship.enemy,
      'Moon': BnnPlanetRelationship.enemy,
      'Mars': BnnPlanetRelationship.enemy,
    },
    'Rahu': {
      'Venus': BnnPlanetRelationship.friend,
      'Saturn': BnnPlanetRelationship.friend,
      'Mercury': BnnPlanetRelationship.friend,
      'Jupiter': BnnPlanetRelationship.neutral,
      'Ketu': BnnPlanetRelationship.neutral,
      'Sun': BnnPlanetRelationship.enemy,
      'Moon': BnnPlanetRelationship.enemy,
      'Mars': BnnPlanetRelationship.enemy,
    },
    'Ketu': {
      'Mars': BnnPlanetRelationship.friend,
      'Venus': BnnPlanetRelationship.friend,
      'Jupiter': BnnPlanetRelationship.friend,
      'Mercury': BnnPlanetRelationship.neutral,
      'Saturn': BnnPlanetRelationship.neutral,
      'Sun': BnnPlanetRelationship.enemy,
      'Moon': BnnPlanetRelationship.enemy,
      'Rahu': BnnPlanetRelationship.enemy,
    },
  };

  /// Get relationship between Source planet and Target planet
  static BnnPlanetRelationship getRelationship(String sourceKey, String targetKey) {
    if (sourceKey == targetKey) return BnnPlanetRelationship.friend;
    return planetFriendships[sourceKey]?[targetKey] ?? BnnPlanetRelationship.neutral;
  }

  /// Normalize existing Map<String, PlanetDetail> into List<BnnPlanetPosition>
  static List<BnnPlanetPosition> normalizePlanets(Map<String, PlanetDetail> planets, {int lagnaRasiIndex = 0}) {
    final List<BnnPlanetPosition> result = [];

    for (final key in standardPlanetKeys) {
      final p = planets[key];
      if (p != null) {
        result.add(BnnPlanetPosition.fromPlanetDetail(p, lagnaRasiIndex: lagnaRasiIndex));
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

  /// Calculate relative BNN Direction Priority and Type for a given relative house (1..12)
  /// Priority order:
  /// 1: 1, 5, 9 (Trine)
  /// 2: 3, 11 (Upachaya)
  /// 3: 7 (Opposite)
  /// 4: 2 (Forward)
  /// 5: 12 (Behind)
  static (int priority, BnnRelationType type)? getDirectionPriority(int relativeHouse) {
    if (relativeHouse == 1 || relativeHouse == 5 || relativeHouse == 9) {
      return (1, BnnRelationType.trine159);
    } else if (relativeHouse == 3 || relativeHouse == 11) {
      return (2, BnnRelationType.upachaya311);
    } else if (relativeHouse == 7) {
      return (3, BnnRelationType.seventh7);
    } else if (relativeHouse == 2) {
      return (4, BnnRelationType.second2);
    } else if (relativeHouse == 12) {
      return (5, BnnRelationType.twelfth12);
    }
    return null;
  }

  /// Find and Sort all BNN Connected Planets for a Source Planet
  /// Strict Sorting Rules:
  /// 1. BNN Directional Priority: (1,5,9) -> (3,11) -> (7) -> (2) -> (12)
  /// 2. If same priority, exact absolute longitude ascending (0° -> 360°)
  static List<BnnConnection> getSortedBnnConnections({
    required BnnPlanetPosition sourcePlanet,
    required List<BnnPlanetPosition> allPlanets,
  }) {
    final List<BnnConnection> connections = [];

    for (final target in allPlanets) {
      if (target.planetKey == sourcePlanet.planetKey) continue;

      final relHouse = ((target.signNumber - sourcePlanet.signNumber + 12) % 12) + 1;
      final dirInfo = getDirectionPriority(relHouse);
      if (dirInfo == null) continue;

      final priority = dirInfo.$1;
      final relType = dirInfo.$2;
      final rel = getRelationship(sourcePlanet.planetKey, target.planetKey);
      final karakatwas = BnnKarakatwa.getKarakatwasForPlanet(target.planetKey);

      final interpretation = '${sourcePlanet.tamilName} - ${target.tamilName} சேர்க்கை (${rel.labelTa}): '
          '${target.tamilName} ${target.signNameTa} ராசியில் ${target.formattedDegreeDMS} பாகையில் ${relType.tamilTitle}யில் உள்ளது.';

      connections.add(BnnConnection(
        sourcePlanet: sourcePlanet,
        targetPlanet: target,
        relativeHouse: relHouse,
        directionType: relType,
        directionPriority: priority,
        relationship: rel,
        karakatwas: karakatwas,
        interpretationTa: interpretation,
      ));
    }

    // Sort: First by directional priority ascending (1 to 5), then by absolute longitude ascending
    connections.sort((a, b) {
      final prioComp = a.directionPriority.compareTo(b.directionPriority);
      if (prioComp != 0) return prioComp;
      return a.targetPlanet.absoluteLongitude.compareTo(b.targetPlanet.absoluteLongitude);
    });

    return connections;
  }

  /// Find related planets in specified signs for legacy compatibility
  static List<BnnPlanetPosition> getRelatedPlanets({
    required BnnPlanetPosition sourcePlanet,
    required List<int> relatedSignsInOrder,
    required List<BnnPlanetPosition> allPlanets,
  }) {
    final List<BnnPlanetPosition> result = [];

    for (final signNum in relatedSignsInOrder) {
      final planetsInSign = allPlanets
          .where((p) => p.signNumber == signNum && p.planetKey != sourcePlanet.planetKey)
          .toList();

      // Sort by absolute longitude ascending
      planetsInSign.sort((a, b) => a.absoluteLongitude.compareTo(b.absoluteLongitude));
      result.addAll(planetsInSign);
    }

    return result;
  }

  /// Analyze all 4 legacy groups and continuous sorted connections for a planet
  static BnnPlanetAnalysis analyzePlanet({
    required BnnPlanetPosition sourcePlanet,
    required List<BnnPlanetPosition> allPlanets,
  }) {
    final Map<BnnRelationType, BnnRelationResult> map = {};
    final allSorted = getSortedBnnConnections(sourcePlanet: sourcePlanet, allPlanets: allPlanets);

    for (final relType in [
      BnnRelationType.trine159,
      BnnRelationType.upachaya311,
      BnnRelationType.seventh7,
      BnnRelationType.secondTwelfth212,
    ]) {
      final relatedSigns = getRelatedSigns(sourcePlanet.signNumber, relType);
      final relatedSignNames = getRelatedSignNamesTa(relatedSigns);
      final matchingConnections = allSorted.where((c) {
        if (relType == BnnRelationType.secondTwelfth212) {
          return c.relativeHouse == 2 || c.relativeHouse == 12;
        }
        return c.directionType == relType;
      }).toList();

      final relatedPlanets = matchingConnections.map((c) => c.targetPlanet).toList();

      final buffer = StringBuffer();
      buffer.writeln('தொடர்பு களம்: ${relType.baseSignificanceTa}');
      if (relatedPlanets.isEmpty) {
        buffer.write('இந்த தொடர்பில் நேரடி கிரகங்கள் இல்லை.');
      } else {
        buffer.writeln('\nநாடி கிரக சேர்க்கை பலன்கள்:');
        for (int i = 0; i < matchingConnections.length; i++) {
          final c = matchingConnections[i];
          final meaning = planetMeaningsTa[c.targetPlanet.planetKey] ?? 'பொதுவான கிரக பலன்கள்.';
          buffer.writeln('${i + 1}. ${c.targetPlanet.tamilName} (${c.relationship.labelTa}, ${c.targetPlanet.signNameTa} - ${c.targetPlanet.formattedDegreeDMS}): $meaning');
        }
      }

      map[relType] = BnnRelationResult(
        sourcePlanet: sourcePlanet,
        relationType: relType,
        relationTitleTa: relType.tamilTitle,
        relatedSigns: relatedSigns,
        relatedSignNamesTa: relatedSignNames,
        relatedPlanets: relatedPlanets,
        connections: matchingConnections,
        baseSignificanceTa: relType.baseSignificanceTa,
        interpretationTa: buffer.toString(),
      );
    }

    return BnnPlanetAnalysis(
      sourcePlanet: sourcePlanet,
      relationResults: map,
      allSortedConnections: allSorted,
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

  /// High-Precision Real Vimshottari Dasha starting from Moon's exact Nakshatra position
  static BnnDashaResult calculateVimshottariDasha({
    required double moonLongitude,
    required DateTime birthDateTime,
  }) {
    final double normMoonLong = AstrologyCalculator.normalizeDegrees(moonLongitude);
    const double nakSpan = 360.0 / 27.0; // 13° 20' = 13.333333°

    final int nakIdx = (normMoonLong / nakSpan).floor().clamp(0, 26);
    final double offsetInNak = normMoonLong - (nakIdx * nakSpan);

    final int startLordIdx = nakIdx % 9;
    final String birthLordEn = dashaLordSequence[startLordIdx];
    final String birthLordTa = dashaLordSequenceTa[startLordIdx];
    final double birthLordTotalYears = vimshottariYears[birthLordEn]!;

    final double spentFraction = (offsetInNak / nakSpan).clamp(0.0, 1.0);
    final double remainingFraction = (1.0 - spentFraction).clamp(0.0, 1.0);
    final double balanceYears = birthLordTotalYears * remainingFraction;

    final balYearsInt = balanceYears.floor();
    final balMonths = ((balanceYears - balYearsInt) * 12.0).floor();
    final balDays = ((((balanceYears - balYearsInt) * 12.0) - balMonths) * 30.4375).round();
    final birthBalanceFormatted = "$birthLordTa மகா தசை இருப்பு: $balYearsInt வருடம் $balMonths மாதம் $balDays நாள்";

    DateTime currentStart = birthDateTime.subtract(Duration(days: (spentFraction * birthLordTotalYears * 365.2425).round()));
    final List<BnnDashaPeriod> mahadashas = [];

    for (int m = 0; m < 9; m++) {
      final int mahaLordIdx = (startLordIdx + m) % 9;
      final String mahaLordEn = dashaLordSequence[mahaLordIdx];
      final String mahaLordTa = dashaLordSequenceTa[mahaLordIdx];
      final double mahaYears = vimshottariYears[mahaLordEn]!;

      final DateTime mahaEnd = currentStart.add(Duration(days: (mahaYears * 365.2425).round()));

      // Bhuktis (Level 2)
      DateTime bhuktiStart = currentStart;
      final List<BnnDashaPeriod> bhuktis = [];
      for (int b = 0; b < 9; b++) {
        final int bhuktiLordIdx = (mahaLordIdx + b) % 9;
        final String bhuktiLordEn = dashaLordSequence[bhuktiLordIdx];
        final String bhuktiLordTa = dashaLordSequenceTa[bhuktiLordIdx];
        final double bhuktiYears = mahaYears * (vimshottariYears[bhuktiLordEn]! / 120.0);

        final DateTime bhuktiEnd = (b == 8)
            ? mahaEnd
            : bhuktiStart.add(Duration(days: (bhuktiYears * 365.2425).round()));

        // Antaras (Level 3)
        DateTime antaraStart = bhuktiStart;
        final List<BnnDashaPeriod> antaras = [];
        for (int a = 0; a < 9; a++) {
          final int antaraLordIdx = (bhuktiLordIdx + a) % 9;
          final String antaraLordEn = dashaLordSequence[antaraLordIdx];
          final String antaraLordTa = dashaLordSequenceTa[antaraLordIdx];
          final double antaraYears = bhuktiYears * (vimshottariYears[antaraLordEn]! / 120.0);

          final DateTime antaraEnd = (a == 8)
              ? bhuktiEnd
              : antaraStart.add(Duration(days: (antaraYears * 365.2425).round()));

          // Sookshmas (Level 4)
          DateTime sookshmaStart = antaraStart;
          final List<BnnDashaPeriod> sookshmas = [];
          for (int s = 0; s < 9; s++) {
            final int sookshmaLordIdx = (antaraLordIdx + s) % 9;
            final String sookshmaLordEn = dashaLordSequence[sookshmaLordIdx];
            final String sookshmaLordTa = dashaLordSequenceTa[sookshmaLordIdx];
            final double sookshmaYears = antaraYears * (vimshottariYears[sookshmaLordEn]! / 120.0);

            final DateTime sookshmaEnd = (s == 8)
                ? antaraEnd
                : sookshmaStart.add(Duration(days: (sookshmaYears * 365.2425).round()));

            sookshmas.add(BnnDashaPeriod(
              level: 'Sookshma',
              planetKey: sookshmaLordEn,
              planetNameTa: sookshmaLordTa,
              startDate: sookshmaStart,
              endDate: sookshmaEnd,
              durationYears: sookshmaYears,
            ));

            sookshmaStart = sookshmaEnd;
          }

          antaras.add(BnnDashaPeriod(
            level: 'Antara',
            planetKey: antaraLordEn,
            planetNameTa: antaraLordTa,
            startDate: antaraStart,
            endDate: antaraEnd,
            durationYears: antaraYears,
            subPeriods: sookshmas,
          ));

          antaraStart = antaraEnd;
        }

        bhuktis.add(BnnDashaPeriod(
          level: 'Bhukti',
          planetKey: bhuktiLordEn,
          planetNameTa: bhuktiLordTa,
          startDate: bhuktiStart,
          endDate: bhuktiEnd,
          durationYears: bhuktiYears,
          subPeriods: antaras,
        ));

        bhuktiStart = bhuktiEnd;
      }

      mahadashas.add(BnnDashaPeriod(
        level: 'Mahadasha',
        planetKey: mahaLordEn,
        planetNameTa: mahaLordTa,
        startDate: currentStart,
        endDate: mahaEnd,
        durationYears: mahaYears,
        subPeriods: bhuktis,
      ));

      currentStart = mahaEnd;
    }

    return BnnDashaResult(
      startingPlanetTa: birthLordTa,
      startingPlanetEn: birthLordEn,
      balanceYears: balanceYears,
      balanceFormatted: birthBalanceFormatted,
      mahadashas: mahadashas,
    );
  }
}

/// Separation layer provider for BNN Chart calculation and astronomy linkage
class BnnChartProvider {
  /// Calculate full BNN Chart data from birth input
  static BnnChartData calculateBnnChart({
    required DateTime birthDateTime,
    required double latitude,
    required double longitude,
    double utcOffsetHours = 5.5,
    String placeName = '',
  }) {
    // Strictly prevent silent fallback with fake 0,0 coordinates
    if (latitude == 0.0 && longitude == 0.0) {
      throw ArgumentError('பிறந்த இடத்தின் அட்ச/தீர்க்கரேகை (Latitude/Longitude) தேவை. 0,0 பயன்படுத்த முடியாது.');
    }

    final astroData = AstrologyCalculator.calculateHoroscope(
      dateOfBirth: birthDateTime,
      latitude: latitude,
      longitude: longitude,
      utcOffsetHours: utcOffsetHours,
    );

    final lagnaRasiIdx = astroData.lagna.rasiIndex;
    final bnnLagna = BnnPlanetPosition.fromPlanetDetail(astroData.lagna, lagnaRasiIndex: lagnaRasiIdx);
    final bnnPlanets = BnnEngine.normalizePlanets(astroData.planets, lagnaRasiIndex: lagnaRasiIdx);
    final analyses = BnnEngine.analyzeAllPlanets(bnnPlanets);
    final dasha = BnnEngine.calculateVimshottariDasha(
      moonLongitude: astroData.moon.longitude,
      birthDateTime: birthDateTime,
    );

    return BnnChartData(
      birthDateTime: birthDateTime,
      latitude: latitude,
      longitude: longitude,
      utcOffsetHours: utcOffsetHours,
      placeName: placeName,
      lagna: bnnLagna,
      planets: bnnPlanets,
      analyses: analyses,
      dashaResult: dasha,
    );
  }
}
