import '../models/mundane_models.dart';
import 'astrology_calculator.dart';

/// Aspect Calculator for Mundane Astrology
class AspectCalculator {
  /// Aspect definitions with target angle, allowed orb, and nature
  static const List<(String typeEn, String typeTa, double targetAngle, double orb, String nature, String natureTa)> aspectRules = [
    ('Conjunction', 'இணைவு (0°)', 0.0, 8.0, 'Neutral', 'நேரடி சேர்க்கை'),
    ('Sextile', 'அறுபாகை பார்வை (60°)', 60.0, 6.0, 'Benefic', 'சுப வாய்ப்புகள்'),
    ('Square', 'கேந்திர பார்வை (90°)', 90.0, 7.0, 'Malefic', 'சவால் & அழுத்தம்'),
    ('Trine', 'திரிகோண பார்வை (120°)', 120.0, 7.0, 'Benefic', 'சுப வளம் & யோகம்'),
    ('Opposition', 'நேரெதிர் பார்வை (180°)', 180.0, 8.0, 'Malefic', 'எதிர்ப்பு & மோதல்'),
  ];

  /// Calculate all major aspects between 9 planets
  static List<Aspect> calculateAspects(List<PlanetPosition> planets) {
    final List<Aspect> aspects = [];

    for (int i = 0; i < planets.length; i++) {
      for (int j = i + 1; j < planets.length; j++) {
        final p1 = planets[i];
        final p2 = planets[j];

        double diff = (p1.longitude - p2.longitude).abs();
        if (diff > 180.0) diff = 360.0 - diff;

        for (final rule in aspectRules) {
          final target = rule.$3;
          final allowedOrb = rule.$4;
          final deviation = (diff - target).abs();

          if (deviation <= allowedOrb) {
            String nature = rule.$5;
            String natureTa = rule.$6;

            // Contextualize Conjunction (0°) nature based on malefic/benefic planets
            if (rule.$1 == 'Conjunction') {
              final isMaleficPair = (p1.name == 'Saturn' || p1.name == 'Mars' || p1.name == 'Rahu' || p1.name == 'Ketu' ||
                  p2.name == 'Saturn' || p2.name == 'Mars' || p2.name == 'Rahu' || p2.name == 'Ketu');
              final isBeneficPair = (p1.name == 'Jupiter' || p1.name == 'Venus' || p1.name == 'Mercury' || p1.name == 'Moon') &&
                  (p2.name == 'Jupiter' || p2.name == 'Venus' || p2.name == 'Mercury' || p2.name == 'Moon');

              if (isBeneficPair) {
                nature = 'Benefic';
                natureTa = 'அதிசுப சேர்க்கை';
              } else if (isMaleficPair) {
                nature = 'Malefic';
                natureTa = 'கடுமையான தாக்க சேர்க்கை';
              } else {
                nature = 'Neutral';
                natureTa = 'கலப்பு பலன் சேர்க்கை';
              }
            }

            aspects.add(Aspect(
              planet1: p1.tamilName,
              planet2: p2.tamilName,
              aspectType: rule.$1,
              aspectTypeTa: rule.$2,
              targetAngle: target,
              angularDistance: diff,
              orb: allowedOrb,
              nature: nature,
              natureTa: natureTa,
            ));
            break; // Match the closest aspect rule for this pair
          }
        }
      }
    }

    return aspects;
  }
}

/// House Cluster Detection (3 or more planets in the same house)
class HouseClusterDetector {
  static List<HouseCluster> detectClusters(List<PlanetPosition> planets) {
    final List<HouseCluster> clusters = [];
    final Map<int, List<PlanetPosition>> houseMap = {};

    for (final p in planets) {
      houseMap.putIfAbsent(p.house, () => []).add(p);
    }

    for (final entry in houseMap.entries) {
      if (entry.value.length >= 3) {
        final houseNum = entry.key;
        final planetsInHouse = entry.value;
        final houseMeaning = MundaneData.houseMeaningsTa[houseNum] ?? 'பொதுவான தேசிய களம்.';
        final planetNames = planetsInHouse.map((p) => p.tamilName).join(', ');

        final strength = (70 + (planetsInHouse.length * 7)).clamp(0, 99);
        final interp = '$houseNum-ஆம் பாவத்தில் ${planetsInHouse.length} முக்கிய கிரகங்கள் ($planetNames) இணைந்து சஞ்சரிக்கின்றன. '
            'இதனால் $houseMeaning தொடர்பான விவகாரங்களில் தீவிர மாற்றங்களும் அதிமுக்கிய தேசிய நிகழ்வுகளும் ஏற்படும்.';

        clusters.add(HouseCluster(
          houseNumber: houseNum,
          planets: planetsInHouse,
          houseMeaningTa: houseMeaning,
          predictionStrength: strength,
          interpretationTa: interp,
        ));
      }
    }

    // Sort by largest cluster first
    clusters.sort((a, b) => b.planetCount.compareTo(a.planetCount));
    return clusters;
  }
}

/// Automatic Prediction Engine for National and Global Trends
class MundanePredictionEngine {
  static List<MundanePrediction> generatePredictions({
    required List<PlanetPosition> planets,
    required List<Aspect> aspects,
    required List<HouseCluster> clusters,
  }) {
    final List<MundanePrediction> list = [];

    PlanetPosition findPlanet(String key) =>
        planets.firstWhere((p) => p.name == key, orElse: () => planets.first);

    final sun = findPlanet('Sun');
    final moon = findPlanet('Moon');
    final mars = findPlanet('Mars');
    final mercury = findPlanet('Mercury');
    final jupiter = findPlanet('Jupiter');
    final venus = findPlanet('Venus');
    final saturn = findPlanet('Saturn');
    final rahu = findPlanet('Rahu');
    final ketu = findPlanet('Ketu');

    // 1. அரசியல் & அரசு / Politics & Government (Sun, Jupiter, 10th House)
    final isSunStrong = sun.rasiName == 'Aries' || sun.rasiName == 'Leo' || sun.house == 10 || sun.house == 1;
    list.add(MundanePrediction(
      category: 'Politics',
      categoryTa: 'அரசியல் & அரசு',
      title: 'Government Stability & Authority',
      titleTa: 'அரசு நிலைத்தன்மை & தலைமைத்துவ அதிகாரம்',
      descriptionTa: 'சூரியன் ${sun.rasiNameTa} ராசியில் ${sun.house}-ஆம் பாவத்தில் சஞ்சரிப்பதால் மத்திய அரசு நிர்வாகத்தில் '
          '${isSunStrong ? "வலுவான தலைமைத்துவமும், சர்வதேச அரங்கில் நற்பெயரும்" : "முக்கிய கொள்கை சீர்திருத்தங்களும் கடுமையான முடிவுகளும்"} முன்னெடுக்கப்படும்.',
      strength: isSunStrong ? 88 : 74,
      isFavorable: isSunStrong,
      intensity: isSunStrong ? 'High' : 'Moderate',
      intensityTa: isSunStrong ? 'அதிதீவிர சுப பலன்' : 'கலப்பு பலன்',
      contributingFactors: ['சூரியன்: ${sun.rasiNameTa} (${sun.house}-ஆம் பாவம்)', 'குரு பார்வை நிலை'],
    ));

    // 2. பொருளாதாரம் / Economy (Jupiter, Mercury, 2nd & 11th House)
    final isJupBenefic = jupiter.rasiName == 'Cancer' || jupiter.rasiName == 'Sagittarius' || jupiter.rasiName == 'Pisces' || jupiter.house == 2 || jupiter.house == 11;
    list.add(MundanePrediction(
      category: 'Economy',
      categoryTa: 'பொருளாதாரம் & நிதி',
      title: 'National Economy & Revenue Trends',
      titleTa: 'பொருளாதார வளர்ச்சி & கருவூல வருவாய்',
      descriptionTa: 'குரு ${jupiter.rasiNameTa} ராசியிலும் புதன் ${mercury.rasiNameTa} ராசியிலும் அமைந்திருப்பது வங்கித்துறை, '
          'பங்குச்சந்தை மற்றும் வெளிநாட்டு வர்த்தகத்தில் ${isJupBenefic ? "நிலையான முன்னேற்றத்தையும் பணப்புழக்கத்தையும்" : "கட்டுப்பாடுகளுடன் கூடிய சீரான வளர்ச்சியையும்"} வழங்கும்.',
      strength: isJupBenefic ? 90 : 76,
      isFavorable: isJupBenefic,
      intensity: isJupBenefic ? 'High' : 'Moderate',
      intensityTa: isJupBenefic ? 'வலுவான சுப பலன்' : 'மிதமான தாக்கம்',
      contributingFactors: ['குரு: ${jupiter.rasiNameTa}', 'புதன்: ${mercury.rasiNameTa}'],
    ));

    // 3. மக்கள் & சமூகம் / Public Welfare (Moon, 1st House)
    final isMoonFavorable = moon.house == 1 || moon.house == 4 || moon.house == 5 || moon.house == 9;
    list.add(MundanePrediction(
      category: 'Public',
      categoryTa: 'மக்கள் & நல்வாழ்வு',
      title: 'Public Sentiment & Health',
      titleTa: 'பொதுமக்கள் மனநிலை & சமூக நல்வாழ்வு',
      descriptionTa: 'சந்திரன் ${moon.rasiNameTa} ராசியில் ${moon.house}-ஆம் வீட்டில் இருப்பதால் மக்கள் மத்தியில் '
          '${isMoonFavorable ? "மகிழ்ச்சியான சூழலும், பொது நல்வாழ்வு திட்டங்களின் வரவேற்பும்" : "உணர்ச்சிவசப்பட்ட விவாதங்களும் பொது சுகாதார விழிப்புணர்வும்"} காணப்படும்.',
      strength: 78,
      isFavorable: isMoonFavorable,
      intensity: 'Moderate',
      intensityTa: 'சமூக தாக்கம்',
      contributingFactors: ['சந்திரன்: ${moon.rasiNameTa} (${moon.formattedDMS})'],
    ));

    // 4. பாதுகாப்பு & இராணுவம் / Defense & Security (Mars, Saturn, 6th & 7th House)
    final hasMarsSaturnAspect = aspects.any((a) => (a.planet1 == 'செவ்வாய்' && a.planet2 == 'சனி') || (a.planet1 == 'சனி' && a.planet2 == 'செவ்வாய்'));
    list.add(MundanePrediction(
      category: 'Security',
      categoryTa: 'பாதுகாப்பு & எல்லைகள்',
      title: 'Defense Readiness & Borders',
      titleTa: 'இராணுவ தயார்நிலை & எல்லை பாதுகாப்பு',
      descriptionTa: 'செவ்வாய் ${mars.rasiNameTa} ராசியில் நிலைகொண்டுள்ளதால் பாதுகாப்பு படைகளின் நவீனமயமாக்கல், '
          '${hasMarsSaturnAspect ? "எல்லைகளில் தீவிர விழிப்புணர்வும், முன்னெச்சரிக்கை நடவடிக்கைகளும்" : "அதிநவீன ஆயுத தயாரிப்பு மற்றும் தற்காப்பு பலம்"} உச்சத்தில் இருக்கும்.',
      strength: hasMarsSaturnAspect ? 92 : 80,
      isFavorable: !hasMarsSaturnAspect,
      intensity: hasMarsSaturnAspect ? 'High' : 'Moderate',
      intensityTa: hasMarsSaturnAspect ? 'தீவிர எச்சரிக்கை' : 'பாதுகாப்பு பலம்',
      contributingFactors: ['செவ்வாய்: ${mars.rasiNameTa}', if (hasMarsSaturnAspect) 'செவ்வாய்-சனி சேர்க்கை/பார்வை'],
    ));

    // 5. தொழிலாளர் & வேலைவாய்ப்பு / Employment (Saturn, 6th House)
    list.add(MundanePrediction(
      category: 'Employment',
      categoryTa: 'தொழிலாளர் & வேலைவாய்ப்பு',
      title: 'Labour & Infrastructure Reforms',
      titleTa: 'உழைப்பாளர் நலம் & உள்கட்டமைப்பு வளர்ச்சி',
      descriptionTa: 'சனி பகவான் ${saturn.rasiNameTa} ராசியில் ${saturn.house}-ஆம் பாவத்தில் சஞ்சரிப்பது தொழிற்சாலைகள், '
          'சுரங்கத்துறை, சாலை உள்கட்டமைப்பு மற்றும் தொழிலாளர் நலன் சார்ந்த புதிய சட்டங்களுக்கு வழிவகுக்கும்.',
      strength: 82,
      isFavorable: true,
      intensity: 'Moderate',
      intensityTa: 'நீண்டகால தாக்கம்',
      contributingFactors: ['சனி: ${saturn.rasiNameTa} (${saturn.house}-ஆம் பாவம்)'],
    ));

    // 6. விவசாயம் & இயற்கை வளம் / Agriculture (Venus, Moon, 4th House)
    list.add(MundanePrediction(
      category: 'Agriculture',
      categoryTa: 'விவசாயம் & பருவமழை',
      title: 'Agricultural Yield & Rainfall',
      titleTa: 'வேளாண்மை உற்பத்தி & நீர்வளப் பெருக்கம்',
      descriptionTa: 'சுக்கிரன் ${venus.rasiNameTa} மற்றும் சந்திரன் அமைவுகள் காரணமாக பருவமழை மற்றும் நதிநீர் பாசனம் மூலம் விவசாய விளைச்சலில் சாதகமான சூழல் நிலவும்.',
      strength: 75,
      isFavorable: true,
      intensity: 'Moderate',
      intensityTa: 'சாதகமான பலன்',
      contributingFactors: ['சுக்கிரன்: ${venus.rasiNameTa}', 'சந்திரன் நீர்ராசி தொடர்பு'],
    ));

    // 7. வெளிநாட்டு உறவுகள் / Foreign Relations (Rahu, Ketu, 7th & 9th House)
    list.add(MundanePrediction(
      category: 'Foreign Relations',
      categoryTa: 'வெளிநாட்டு உறவுகள்',
      title: 'International Diplomacy & Treaties',
      titleTa: 'சர்வதேச ராஜதந்திரம் & புதிய உடன்படிக்கைகள்',
      descriptionTa: 'ராகு ${rahu.rasiNameTa} ராசியிலும் கேது ${ketu.rasiNameTa} ராசியிலும் உள்ள அச்சு சர்வதேச மாநாடுகளில் நாட்டின் குரலை முன்னிலைப்படுத்தும்.',
      strength: 84,
      isFavorable: true,
      intensity: 'High',
      intensityTa: 'அதிமுக்கிய ராஜதந்திரம்',
      contributingFactors: ['ராகு: ${rahu.rasiNameTa}', 'கேது: ${ketu.rasiNameTa}'],
    ));

    // 8. House Cluster Predictions (if any)
    for (final cluster in clusters) {
      list.add(MundanePrediction(
        category: 'Authority',
        categoryTa: 'பாவ சேர்க்கை தாக்கம்',
        title: '${cluster.houseNumber}th House Stellium Power',
        titleTa: '${cluster.houseNumber}-ஆம் பாவத்தில் ${cluster.planetCount} கிரகங்களின் பெருங்கூட்டணி',
        descriptionTa: cluster.interpretationTa,
        strength: cluster.predictionStrength,
        isFavorable: true,
        intensity: 'High',
        intensityTa: 'அதிதீவிர கிரக கூட்டணி',
        contributingFactors: cluster.planets.map((p) => p.tamilName).toList(),
      ));
    }

    // Sort predictions descending by highest strength first (100 -> 0)
    list.sort((a, b) => b.strength.compareTo(a.strength));
    return list;
  }
}

/// Transit Comparison Engine (Event/Natal Chart vs Real-time Transit Planets)
class MundaneTransitEngine {
  static List<MundaneTransitComparison> compareTransits({
    required List<PlanetPosition> eventPlanets,
    required List<PlanetPosition> transitPlanets,
  }) {
    final List<MundaneTransitComparison> comparisons = [];

    for (final transit in transitPlanets) {
      for (final event in eventPlanets) {
        double diff = (transit.longitude - event.longitude).abs();
        if (diff > 180.0) diff = 360.0 - diff;

        // Conjunction (0° ± 8°)
        if (diff <= 8.0) {
          comparisons.add(MundaneTransitComparison(
            transitPlanet: transit,
            eventPlanet: event,
            aspectType: 'Conjunction',
            aspectTypeTa: 'கோச்சார இணைவு (0°)',
            angularDistance: diff,
            interpretationTa: 'கோச்சார ${transit.tamilName} நிகழ்வு ஜாதக ${event.tamilName} மீது சஞ்சரிப்பதால் '
                '${MundaneData.planetarySignificationsTa[transit.name] ?? "கிரக களம்"} உடனடியாக துரிதப்படுத்தப்படும்.',
            strength: 90,
            isFavorable: !(transit.name == 'Saturn' || transit.name == 'Mars' || transit.name == 'Rahu'),
          ));
        }
        // Square (90° ± 7°)
        else if ((diff - 90.0).abs() <= 7.0) {
          comparisons.add(MundaneTransitComparison(
            transitPlanet: transit,
            eventPlanet: event,
            aspectType: 'Square',
            aspectTypeTa: 'கோச்சார கேந்திர பார்வை (90°)',
            angularDistance: diff,
            interpretationTa: 'கோச்சார ${transit.tamilName} நிகழ்வு ஜாதக ${event.tamilName} உடன் 90° பார்வை பெறுவதால் கொள்கை மாற்றங்களில் உடனடி தீர்வு தேவைப்படும்.',
            strength: 78,
            isFavorable: false,
          ));
        }
        // Trine (120° ± 7°)
        else if ((diff - 120.0).abs() <= 7.0) {
          comparisons.add(MundaneTransitComparison(
            transitPlanet: transit,
            eventPlanet: event,
            aspectType: 'Trine',
            aspectTypeTa: 'கோச்சார திரிகோண பார்வை (120°)',
            angularDistance: diff,
            interpretationTa: 'கோச்சார ${transit.tamilName} நிகழ்வு ஜாதக ${event.tamilName} உடன் 120° சுப சேர்க்கை பெறுவது தேசிய முன்னேற்றத்திற்கு மிகுந்த நற்பலன் தரும்.',
            strength: 86,
            isFavorable: true,
          ));
        }
        // Opposition (180° ± 8°)
        else if ((diff - 180.0).abs() <= 8.0) {
          comparisons.add(MundaneTransitComparison(
            transitPlanet: transit,
            eventPlanet: event,
            aspectType: 'Opposition',
            aspectTypeTa: 'கோச்சார நேரெதிர் பார்வை (180°)',
            angularDistance: diff,
            interpretationTa: 'கோச்சார ${transit.tamilName} நிகழ்வு ஜாதக ${event.tamilName} ஐ நேருக்கு நேர் நோக்குவது இருதரப்பு விவாதங்களையும் புதிய ஒப்பந்தங்களையும் உருவாக்கும்.',
            strength: 82,
            isFavorable: false,
          ));
        }
      }
    }

    // Sort by highest strength
    comparisons.sort((a, b) => b.strength.compareTo(a.strength));
    return comparisons;
  }
}

/// Master Mundane Calculator Service
class MundaneCalculator {
  /// Calculate full Mundane Chart from Ephemeris / Astrology Calculator
  static MundaneChart calculateMundaneChart({
    required DateTime dateTime,
    String country = 'India',
    String state = 'Delhi',
    String city = 'New Delhi',
    double latitude = 28.6139,
    double longitude = 77.2090,
    double utcOffsetHours = 5.5,
  }) {
    final horoscope = AstrologyCalculator.calculateHoroscope(
      dateOfBirth: dateTime,
      latitude: latitude,
      longitude: longitude,
      utcOffsetHours: utcOffsetHours,
    );

    final asc = PlanetPosition.fromAbsoluteLongitude(
      name: 'Lagna',
      tamilName: 'லக்னம்',
      absoluteLongitude: horoscope.lagna.longitude,
      house: 1,
    );

    final List<PlanetPosition> planetPositions = [];
    final targetPlanets = ['Sun', 'Moon', 'Mars', 'Mercury', 'Jupiter', 'Venus', 'Saturn', 'Rahu', 'Ketu'];

    for (final key in targetPlanets) {
      final p = horoscope.planets[key];
      if (p != null) {
        final house = ((p.rasiIndex - horoscope.lagna.rasiIndex + 12) % 12) + 1;
        planetPositions.add(PlanetPosition.fromAbsoluteLongitude(
          name: p.name,
          tamilName: p.tamilName,
          absoluteLongitude: p.longitude,
          house: house,
          isRetrograde: p.isRetrograde,
        ));
      }
    }

    // Rule: Sort planet positions in ascending absolute longitude order (0° -> 360°)
    planetPositions.sort((a, b) => a.longitude.compareTo(b.longitude));

    final aspects = AspectCalculator.calculateAspects(planetPositions);
    final clusters = HouseClusterDetector.detectClusters(planetPositions);
    final predictions = MundanePredictionEngine.generatePredictions(
      planets: planetPositions,
      aspects: aspects,
      clusters: clusters,
    );

    // Real-time Current Transits Comparison
    final currentHoroscope = AstrologyCalculator.calculateHoroscope(
      dateOfBirth: DateTime.now(),
      latitude: latitude,
      longitude: longitude,
      utcOffsetHours: utcOffsetHours,
    );

    final List<PlanetPosition> currentTransits = [];
    for (final key in targetPlanets) {
      final cp = currentHoroscope.planets[key];
      if (cp != null) {
        final house = ((cp.rasiIndex - currentHoroscope.lagna.rasiIndex + 12) % 12) + 1;
        currentTransits.add(PlanetPosition.fromAbsoluteLongitude(
          name: cp.name,
          tamilName: cp.tamilName,
          absoluteLongitude: cp.longitude,
          house: house,
          isRetrograde: cp.isRetrograde,
        ));
      }
    }

    final transitComparisons = MundaneTransitEngine.compareTransits(
      eventPlanets: planetPositions,
      transitPlanets: currentTransits,
    );

    return MundaneChart(
      country: country,
      state: state,
      city: city,
      chartDateTime: dateTime,
      latitude: latitude,
      longitude: longitude,
      utcOffsetHours: utcOffsetHours,
      ascendant: asc,
      planetPositions: planetPositions,
      aspects: aspects,
      clusters: clusters,
      predictions: predictions,
      transitComparisons: transitComparisons,
      overallSummaryTa: 'உலகியல் ஜோதிட விதிகளின்படி நாட்டின் லக்னம் ${asc.rasiNameTa} (${asc.formattedDMS}). '
          '9 கிரகங்களின் கோச்சார நிலைகள் மற்றும் சேர்க்கைகளின் அடிப்படையில் நாட்டின் பொருளாதாரம், பாதுகாப்பு, நிர்வாகம் மற்றும் மக்கள் நலன் கணக்கிடப்பட்டுள்ளது.',
    );
  }
}
