import '../models/jamakkol_models.dart';
import '../models/jamakkol_planet_models.dart';

/// Calculates aspects and astrological combinations in Jamakkol Prasannam
class JamakkolAspectCalculator {
  /// Sign Lord map (0=Mesham .. 11=Meenam)
  static const List<String> rasiLordsEn = [
    'Mars', // 0: Mesham
    'Venus', // 1: Rishabam
    'Mercury', // 2: Mithunam
    'Moon', // 3: Katakam
    'Sun', // 4: Simham
    'Mercury', // 5: Kanni
    'Venus', // 6: Thulam
    'Mars', // 7: Viruchigam
    'Jupiter', // 8: Dhanusu
    'Saturn', // 9: Makaram
    'Saturn', // 10: Kumbam
    'Jupiter', // 11: Meenam
  ];

  static const List<String> rasiLordsTa = [
    'செவ்வாய்',
    'சுக்கிரன்',
    'புதன்',
    'சந்திரன்',
    'சூரியன்',
    'புதன்',
    'சுக்கிரன்',
    'செவ்வாய்',
    'குரு',
    'சனி',
    'சனி',
    'குரு',
  ];

  /// Calculates house distance from source rasi to target rasi (1 to 12)
  static int getHouseDistance(int sourceRasi, int targetRasi) {
    return (((targetRasi - sourceRasi) % 12 + 12) % 12) + 1;
  }

  /// Calculates aspects between Key Points, Jamakkol Planets, and Transit Planets
  static List<JamakkolAspect> calculateAspects({
    required JamakkolSpecialPoint udayam,
    required JamakkolSpecialPoint arudam,
    required JamakkolSpecialPoint kavippu,
    required List<JamakkolPlanet> jamakkolPlanets,
    required List<TransitPlanet> transitPlanets,
  }) {
    final List<JamakkolAspect> aspects = [];

    // Helper to evaluate aspects from a planet to key points
    void evaluatePlanetToPoints(String pNameEn, String pNameTa, int pRasi, bool isBenefic) {
      final points = [
        (nameEn: 'Udayam', nameTa: 'உதயம்', rasi: udayam.rasiIndex),
        (nameEn: 'Arudam', nameTa: 'ஆருடம்', rasi: arudam.rasiIndex),
        (nameEn: 'Kavippu', nameTa: 'கவிப்பு', rasi: kavippu.rasiIndex),
      ];

      for (final pt in points) {
        final dist = getHouseDistance(pRasi, pt.rasi);

        // Conjunction (1st)
        if (dist == 1) {
          aspects.add(JamakkolAspect(
            sourceNameEn: pNameEn,
            sourceNameTa: pNameTa,
            targetNameEn: pt.nameEn,
            targetNameTa: pt.nameTa,
            houseDistance: 1,
            aspectTypeEn: 'Conjunction (1st)',
            aspectTypeTa: 'இணைவு (1-ஆம் இடம்)',
            isBenefic: isBenefic,
            descriptionTa: '$pNameTa ${pt.nameTa}-உடன் ஒரே ராசியில் இணைந்துள்ளார்',
            descriptionEn: '$pNameEn is conjunct with ${pt.nameEn}',
          ));
        }
        // Opposition (7th)
        else if (dist == 7) {
          aspects.add(JamakkolAspect(
            sourceNameEn: pNameEn,
            sourceNameTa: pNameTa,
            targetNameEn: pt.nameEn,
            targetNameTa: pt.nameTa,
            houseDistance: 7,
            aspectTypeEn: 'Opposition (7th)',
            aspectTypeTa: 'சமசப்தம பார்வை (7-ஆம் இடம்)',
            isBenefic: isBenefic,
            descriptionTa: '$pNameTa ${pt.nameTa}-ஐ நேர் 7-ஆம் பார்வையாக பார்க்கிறார்',
            descriptionEn: '$pNameEn aspects ${pt.nameEn} directly (7th house aspect)',
          ));
        }
        // Trine (5th / 9th)
        else if (dist == 5 || dist == 9) {
          aspects.add(JamakkolAspect(
            sourceNameEn: pNameEn,
            sourceNameTa: pNameTa,
            targetNameEn: pt.nameEn,
            targetNameTa: pt.nameTa,
            houseDistance: dist,
            aspectTypeEn: 'Trine (${dist}th)',
            aspectTypeTa: 'திரிகோண பார்வை ($dist-ஆம் இடம்)',
            isBenefic: isBenefic,
            descriptionTa: '$pNameTa ${pt.nameTa}-ஐ திரிகோண பார்வையாக ($dist-ஆம் இடம்) பார்க்கிறார்',
            descriptionEn: '$pNameEn aspects ${pt.nameEn} with trine aspect (${dist}th house)',
          ));
        }

        // Special Mars aspects: 4th, 8th
        if (pNameEn.toLowerCase().contains('mars') || pNameTa.contains('செவ்வாய்')) {
          if (dist == 4 || dist == 8) {
            aspects.add(JamakkolAspect(
              sourceNameEn: pNameEn,
              sourceNameTa: pNameTa,
              targetNameEn: pt.nameEn,
              targetNameTa: pt.nameTa,
              houseDistance: dist,
              aspectTypeEn: 'Special Mars Aspect (${dist}th)',
              aspectTypeTa: 'செவ்வாய் விசேஷ பார்வை ($dist-ஆம் இடம்)',
              isBenefic: false,
              descriptionTa: '$pNameTa ${pt.nameTa}-ஐ $dist-ஆம் விசேஷ பார்வையாக பார்க்கிறார்',
              descriptionEn: '$pNameEn casts special ${dist}th aspect on ${pt.nameEn}',
            ));
          }
        }

        // Special Saturn aspects: 3rd, 10th
        if (pNameEn.toLowerCase().contains('saturn') || pNameTa.contains('சனி')) {
          if (dist == 3 || dist == 10) {
            aspects.add(JamakkolAspect(
              sourceNameEn: pNameEn,
              sourceNameTa: pNameTa,
              targetNameEn: pt.nameEn,
              targetNameTa: pt.nameTa,
              houseDistance: dist,
              aspectTypeEn: 'Special Saturn Aspect (${dist}th)',
              aspectTypeTa: 'சனி விசேஷ பார்வை ($dist-ஆம் இடம்)',
              isBenefic: false,
              descriptionTa: '$pNameTa ${pt.nameTa}-ஐ $dist-ஆம் விசேஷ பார்வையாக பார்க்கிறார்',
              descriptionEn: '$pNameEn casts special ${dist}th aspect on ${pt.nameEn}',
            ));
          }
        }
      }
    }

    // 1. Evaluate Jamakkol Outer Planets
    for (final jp in jamakkolPlanets) {
      final isBenefic = jp.key == 'Jupiter' || jp.key == 'Venus' || jp.key == 'Mercury' || jp.key == 'Moon';
      evaluatePlanetToPoints('ஜாம ${jp.nameTa}', 'ஜாம ${jp.nameTa}', jp.rasiIndex, isBenefic);
    }

    // 2. Evaluate Gocharam Transit Planets
    for (final tp in transitPlanets) {
      final isBenefic = tp.nameEn == 'Jupiter' || tp.nameEn == 'Venus' || tp.nameEn == 'Mercury' || tp.nameEn == 'Moon';
      evaluatePlanetToPoints('கோச்சார ${tp.nameTa}', 'கோச்சார ${tp.nameTa}', tp.rasiIndex, isBenefic);
    }

    return aspects;
  }

  /// Calculates astrological combinations (Yogas / Factors) for the query
  static List<JamakkolCombination> calculateCombinations({
    required JamakkolSpecialPoint udayam,
    required JamakkolSpecialPoint arudam,
    required JamakkolSpecialPoint kavippu,
    required List<JamakkolPlanet> jamakkolPlanets,
    required List<TransitPlanet> transitPlanets,
  }) {
    final List<JamakkolCombination> combs = [];

    // 1. Udayam - Arudam House Relationship
    final udayamToArudam = getHouseDistance(udayam.rasiIndex, arudam.rasiIndex);
    if (udayamToArudam == 1) {
      combs.add(const JamakkolCombination(
        titleTa: 'உதயம் – ஆருடம் இணைவு (1-ஆம் இடம்)',
        titleEn: 'Udayam and Arudam Conjunction',
        descriptionTa: 'கேள்வி கேட்பவரும் கேட்கப்படும் காரியமும் ஒரே இடத்தில் உள்ளன. காரியம் விரைவாகவும் சாதகமாகவும் கைகூடும்.',
        descriptionEn: 'The querent and the matter are in complete alignment in the same house. Swift success indicated.',
        isFavorable: true,
        category: 'Udayam-Arudam',
      ));
    } else if (udayamToArudam == 5 || udayamToArudam == 9) {
      combs.add(JamakkolCombination(
        titleTa: 'உதயத்திற்கு $udayamToArudam-ல் ஆருடம் (திரிகோணம்)',
        titleEn: 'Arudam in Trine ($udayamToArudam) from Udayam',
        descriptionTa: 'மிகவும் சுபகரமான திரிகோண அமைப்பு. தெய்வ அனுகூலம் மற்றும் நற்பலன்கள் கிட்டும்.',
        descriptionEn: 'Highly auspicious trinal relationship. Divine support and excellent outcomes.',
        isFavorable: true,
        category: 'Udayam-Arudam',
      ));
    } else if (udayamToArudam == 4 || udayamToArudam == 7 || udayamToArudam == 10) {
      combs.add(JamakkolCombination(
        titleTa: 'உதயத்திற்கு $udayamToArudam-ல் ஆருடம் (கேந்திரம்)',
        titleEn: 'Arudam in Kendra ($udayamToArudam) from Udayam',
        descriptionTa: 'நேரடி முயற்சி மற்றும் உழைப்பினால் காரியம் வெற்றிகரமாக முடியும்.',
        descriptionEn: 'Angular house placement indicates success through direct initiative.',
        isFavorable: true,
        category: 'Udayam-Arudam',
      ));
    } else if (udayamToArudam == 6 || udayamToArudam == 8 || udayamToArudam == 12) {
      combs.add(JamakkolCombination(
        titleTa: 'உதயத்திற்கு $udayamToArudam-ல் ஆருடம் (மறைவு ஸ்தானம்)',
        titleEn: 'Arudam in Dusthana ($udayamToArudam) from Udayam',
        descriptionTa: 'காரியத்தில் தடைகள், தாமதங்கள் அல்லது கூடுதல் போராட்டங்கள் ஏற்படலாம். எச்சரிக்கை தேவை.',
        descriptionEn: 'Placed in adverse house. Obstacles, delays, or disputes likely.',
        isFavorable: false,
        category: 'Udayam-Arudam',
      ));
    } else if (udayamToArudam == 2 || udayamToArudam == 11) {
      combs.add(JamakkolCombination(
        titleTa: 'உதயத்திற்கு $udayamToArudam-ல் ஆருடம் (தனம் / லாபம்)',
        titleEn: 'Arudam in Gain/Wealth House ($udayamToArudam)',
        descriptionTa: 'காரியத்தில் எதிர்பாராத நன்மைகளும் பொருளாதார லாபமும் கிட்டும்.',
        descriptionEn: 'Favorable financial gains and achievement of desires.',
        isFavorable: true,
        category: 'Udayam-Arudam',
      ));
    } else {
      combs.add(const JamakkolCombination(
        titleTa: 'உதயத்திற்கு 3-ல் ஆருடம் (தைரிய ஸ்தானம்)',
        titleEn: 'Arudam in 3rd House from Udayam',
        descriptionTa: 'தொடர் முயற்சிகள் மற்றும் தகவல் தொடர்புகள் மூலம் காரிய சித்தி உண்டு.',
        descriptionEn: 'Efforts, communications, and courage lead to victory.',
        isFavorable: true,
        category: 'Udayam-Arudam',
      ));
    }

    // 2. Kavippu position relative to Arudam and Udayam
    final arudamToKavippu = getHouseDistance(arudam.rasiIndex, kavippu.rasiIndex);
    final udayamToKavippu = getHouseDistance(udayam.rasiIndex, kavippu.rasiIndex);

    if (arudamToKavippu == 1) {
      combs.add(const JamakkolCombination(
        titleTa: 'ஆருடத்தில் கவிப்பு (கவிப்பு தோஷம்)',
        titleEn: 'Kavippu in Arudam',
        descriptionTa: 'காரியம் பெரும் தடையையும் எதிர்ப்பையும் சந்திக்கும். இப்போது புதிய முயற்சிகளைத் தொடங்குவதைத் தவிர்க்கவும்.',
        descriptionEn: 'Severe obstruction on the inquired matter. Postpone major decisions.',
        isFavorable: false,
        category: 'Kavippu',
      ));
    } else if (udayamToKavippu == 1) {
      combs.add(const JamakkolCombination(
        titleTa: 'உதயத்தில் கவிப்பு',
        titleEn: 'Kavippu in Udayam',
        descriptionTa: 'கேள்வி கேட்பவருக்கு மனக் குழப்பம் அல்லது உடல் சோர்வு ஏற்படலாம். பொறுமை அவசியம்.',
        descriptionEn: 'Querent experiences mental stress or uncertainty.',
        isFavorable: false,
        category: 'Kavippu',
      ));
    } else if (arudamToKavippu == 7) {
      combs.add(const JamakkolCombination(
        titleTa: 'ஆருடத்திற்கு 7-ல் கவிப்பு',
        titleEn: 'Kavippu in 7th from Arudam',
        descriptionTa: 'மறைமுக எதிர்ப்புகள் மற்றும் பிறரின் தலையீடுகளால் இடையூறு உண்டாகலாம்.',
        descriptionEn: 'Opposition from partners or third parties creates friction.',
        isFavorable: false,
        category: 'Kavippu',
      ));
    }

    // 3. Check Benefics in Udayam or Arudam
    final udayaLordTa = rasiLordsTa[udayam.rasiIndex];
    final arudaLordTa = rasiLordsTa[arudam.rasiIndex];

    for (final jp in jamakkolPlanets) {
      if (jp.rasiIndex == udayam.rasiIndex && (jp.key == 'Jupiter' || jp.key == 'Venus')) {
        combs.add(JamakkolCombination(
          titleTa: 'உதயத்தில் சுப கிரகம் (${jp.nameTa})',
          titleEn: 'Benefic in Udayam (${jp.nameEn})',
          descriptionTa: 'உதயத்தில் சுப கிரகம் இருப்பது கேள்வி கேட்பவருக்கு நல்வழி மற்றும் அதிர்ஷ்டத்தைத் தரும்.',
          descriptionEn: 'Presence of benefic in Udayam blesses the querent with luck and clarity.',
          isFavorable: true,
          category: 'Planetary',
        ));
      }
      if (jp.rasiIndex == arudam.rasiIndex && (jp.key == 'Jupiter' || jp.key == 'Venus')) {
        combs.add(JamakkolCombination(
          titleTa: 'ஆருடத்தில் சுப கிரகம் (${jp.nameTa})',
          titleEn: 'Benefic in Arudam (${jp.nameEn})',
          descriptionTa: 'ஆருடத்தில் சுப கிரகம் இருப்பது காரிய வெற்றிக்கு உறுதியான அனுகூலம் தரும்.',
          descriptionEn: 'Presence of benefic in Arudam strongly indicates success in the matter.',
          isFavorable: true,
          category: 'Planetary',
        ));
      }
    }

    // 4. Parivarthana / Mutual Lord Exchange
    if (udayaLordTa == arudaLordTa) {
      combs.add(JamakkolCombination(
        titleTa: 'ஒரே அதிபதி யோகம் ($udayaLordTa)',
        titleEn: 'Single Lord Yoga ($udayaLordTa)',
        descriptionTa: 'உதயத்திற்கும் ஆருடத்திற்கும் ஒரே அதிபதி. எண்ணிய காரியம் எவ்வித தடையுமின்றி நிறைவேறும்.',
        descriptionEn: 'Same planet rules both Udayam and Arudam. Highly harmonious execution.',
        isFavorable: true,
        category: 'Lords',
      ));
    }

    return combs;
  }
}
