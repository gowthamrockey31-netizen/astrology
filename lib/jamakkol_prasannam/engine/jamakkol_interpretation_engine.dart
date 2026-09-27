import '../../services/astrology_calculator.dart';
import '../models/jamakkol_models.dart';
import '../models/jamakkol_planet_models.dart';
import 'jamakkol_aspect_calculator.dart';

/// Engine that performs interpretation and "Next 1-Hour" analysis for Jamakkol Prasannam
class JamakkolInterpretationEngine {
  /// Sign Lord map (0=Mesham .. 11=Meenam)
  static const List<String> rasiLordsEn = JamakkolAspectCalculator.rasiLordsEn;
  static const List<String> rasiLordsTa = JamakkolAspectCalculator.rasiLordsTa;

  /// Generates the 12 five-minute intervals for the Next 1-Hour Timeline
  static List<JamakkolNextHourSlot> calculateNextHourSlots({
    required DateTime queryDateTime,
    required JamakkolSpecialPoint udayam,
    required JamakkolSpecialPoint kavippu,
    required List<JamakkolPlanet> jamakkolPlanets,
  }) {
    final List<JamakkolNextHourSlot> slots = [];
    final int udayamRasi = udayam.rasiIndex;
    final int kavippuRasi = kavippu.rasiIndex;

    // Arudam traverses 1 Rasi (30°) every 5 minutes
    final double curMinuteWithSec = queryDateTime.minute + (queryDateTime.second / 60.0);

    for (int i = 0; i < 12; i++) {
      final slotStart = queryDateTime.add(Duration(minutes: i * 5));
      final slotEnd = slotStart.add(const Duration(minutes: 5));

      final double slotMidMinute = (curMinuteWithSec + (i * 5) + 2.5) % 60.0;
      final double slotArudamLon = (slotMidMinute * 6.0) % 360.0;
      final int arudamRasiIdx = (slotArudamLon / 30.0).floor() % 12;

      final arudamRasiTa = AstrologyCalculator.rasiNamesTa[arudamRasiIdx];
      final arudamRasiEn = AstrologyCalculator.rasiNamesEn[arudamRasiIdx];
      final arudamLordTa = rasiLordsTa[arudamRasiIdx];
      final arudamLordEn = rasiLordsEn[arudamRasiIdx];

      final houseFromUdayam = JamakkolAspectCalculator.getHouseDistance(udayamRasi, arudamRasiIdx);
      final isKavippuPresent = (arudamRasiIdx == kavippuRasi);

      // Check benefics in this sign
      bool hasBenefic = false;
      for (final jp in jamakkolPlanets) {
        if (jp.rasiIndex == arudamRasiIdx &&
            (jp.key == 'Jupiter' || jp.key == 'Venus' || jp.key == 'Mercury' || jp.key == 'Moon')) {
          hasBenefic = true;
          break;
        }
      }

      // Determine sub-scores
      final isDusthana = (houseFromUdayam == 6 || houseFromUdayam == 8 || houseFromUdayam == 12);
      final isTrineOrKendra = (houseFromUdayam == 1 ||
          houseFromUdayam == 4 ||
          houseFromUdayam == 5 ||
          houseFromUdayam == 7 ||
          houseFromUdayam == 9 ||
          houseFromUdayam == 10);

      final isOverallFavorable = !isKavippuPresent && !isDusthana && (isTrineOrKendra || houseFromUdayam == 11 || houseFromUdayam == 2);
      final negotiationFavorable = !isKavippuPresent && (houseFromUdayam == 1 || houseFromUdayam == 3 || houseFromUdayam == 7 || houseFromUdayam == 11 || arudamLordEn == 'Mercury' || arudamLordEn == 'Jupiter');
      final muhurthamFavorable = !isKavippuPresent && !isDusthana && (houseFromUdayam == 1 || houseFromUdayam == 4 || houseFromUdayam == 5 || houseFromUdayam == 9 || hasBenefic);
      final moneyFavorable = !isKavippuPresent && (houseFromUdayam == 2 || houseFromUdayam == 11 || houseFromUdayam == 5 || arudamLordEn == 'Jupiter' || arudamLordEn == 'Venus');

      final List<String> favorableFactors = [];
      final List<String> unfavorableFactors = [];

      if (isKavippuPresent) {
        unfavorableFactors.add('இந்த நேரத்தில் கவிப்பு குறுக்கிடுகிறது (தடை / நஷ்டம்)');
      }
      if (isDusthana) {
        unfavorableFactors.add('உதயத்திற்கு $houseFromUdayam-ஆம் மறைவு ஸ்தானம்');
      }
      if (isTrineOrKendra) {
        favorableFactors.add('உதயத்திற்கு $houseFromUdayam-ஆம் சுப ஸ்தானம்');
      }
      if (hasBenefic) {
        favorableFactors.add('ஆருடத்தில் சுப கிரக சஞ்சாரம்');
      }
      if (houseFromUdayam == 2 || houseFromUdayam == 11) {
        favorableFactors.add('தன / லாப ஸ்தான தொடர்பு');
      }

      final statusSummaryTa = isOverallFavorable
          ? 'சாதகமான நேரம் — நற்பலன் கைகூடும்'
          : (isKavippuPresent
              ? 'கவிப்பு உள்ளதால் முக்கிய முடிவுகளைத் தவிர்க்கவும்'
              : 'சுமாரான நேரம் — கூடுதல் கவனம் தேவை');

      final statusSummaryEn = isOverallFavorable
          ? 'Favorable period for progress'
          : (isKavippuPresent ? 'Kavippu present - avoid new initiatives' : 'Moderate period - exercise caution');

      slots.add(JamakkolNextHourSlot(
        startTime: slotStart,
        endTime: slotEnd,
        arudamRasiIndex: arudamRasiIdx,
        arudamRasiTa: arudamRasiTa,
        arudamRasiEn: arudamRasiEn,
        arudamLordTa: arudamLordTa,
        arudamLordEn: arudamLordEn,
        isFavorable: isOverallFavorable,
        negotiationFavorable: negotiationFavorable,
        muhurthamFavorable: muhurthamFavorable,
        moneyFavorable: moneyFavorable,
        statusSummaryTa: statusSummaryTa,
        statusSummaryEn: statusSummaryEn,
        favorableFactorsTa: favorableFactors,
        unfavorableFactorsTa: unfavorableFactors,
      ));
    }

    return slots;
  }

  /// Generates the complete, comprehensive interpretation for the query session
  static JamakkolInterpretation generateInterpretation({
    required String question,
    required JamakkolQuestionCategory category,
    required JamakkolSpecialPoint udayam,
    required JamakkolSpecialPoint arudam,
    required JamakkolSpecialPoint kavippu,
    required List<JamakkolPlanet> jamakkolPlanets,
    required List<TransitPlanet> transitPlanets,
    required List<JamakkolCombination> combinations,
    required List<JamakkolAspect> aspects,
  }) {
    final int udayamRasi = udayam.rasiIndex;
    final int arudamRasi = arudam.rasiIndex;
    final int kavippuRasi = kavippu.rasiIndex;

    final int udayamToArudam = JamakkolAspectCalculator.getHouseDistance(udayamRasi, arudamRasi);
    final int arudamToUdayam = JamakkolAspectCalculator.getHouseDistance(arudamRasi, udayamRasi);
    final int udayamToKavippu = JamakkolAspectCalculator.getHouseDistance(udayamRasi, kavippuRasi);
    final int arudamToKavippu = JamakkolAspectCalculator.getHouseDistance(arudamRasi, kavippuRasi);

    final String udayaLordTa = rasiLordsTa[udayamRasi];
    final String arudaLordTa = rasiLordsTa[arudamRasi];

    // Check benefics / malefics
    bool isUdayamBenefic = false;
    bool isArudamBenefic = false;
    for (final jp in jamakkolPlanets) {
      if (jp.rasiIndex == udayamRasi && (jp.key == 'Jupiter' || jp.key == 'Venus' || jp.key == 'Mercury')) {
        isUdayamBenefic = true;
      }
      if (jp.rasiIndex == arudamRasi && (jp.key == 'Jupiter' || jp.key == 'Venus' || jp.key == 'Mercury')) {
        isArudamBenefic = true;
      }
    }

    // Scoring mechanism (0 to 100)
    int score = 50;

    // 1. Distance score
    if (udayamToArudam == 1) {
      score += 25;
    } else if (udayamToArudam == 5 || udayamToArudam == 9) {
      score += 20;
    } else if (udayamToArudam == 4 || udayamToArudam == 7 || udayamToArudam == 10) {
      score += 15;
    } else if (udayamToArudam == 2 || udayamToArudam == 11) {
      score += 20;
    } else if (udayamToArudam == 3) {
      score += 10;
    } else if (udayamToArudam == 6 || udayamToArudam == 8 || udayamToArudam == 12) {
      score -= 25;
    }

    // 2. Kavippu penalty
    if (arudamToKavippu == 1) {
      score -= 35;
    } else if (udayamToKavippu == 1) {
      score -= 20;
    } else if (arudamToKavippu == 7) {
      score -= 15;
    } else {
      score += 10; // Kavippu is away from query
    }

    // 3. Benefic associations
    if (isArudamBenefic) score += 15;
    if (isUdayamBenefic) score += 10;

    score = score.clamp(10, 95);
    final bool isOverallFavorable = score >= 55;

    // Pillar Analyses
    final udayamAnalysisTa = 'உதயம் ${udayam.rasiNameTa} ராசியில் (${udayam.degreeInRasi.toStringAsFixed(1)}°), '
        'நட்சத்திரம் ${udayam.nakshatraTa}-${udayam.pada} பாதத்தில் அமைந்துள்ளது. அதிபதி: $udayaLordTa. '
        'கேள்வி கேட்பவர் தன் எண்ணத்தில் ${isUdayamBenefic ? "தெளிவும் நன்னம்பிக்கையும்" : "அதிக தீவிரமும் உழைப்பும்"} கொண்டுள்ளார்.';

    final udayamAnalysisEn = 'Udayam is located in ${udayam.rasiNameEn} (${udayam.degreeInRasi.toStringAsFixed(1)}°), '
        'Nakshatra ${udayam.nakshatraEn}-${udayam.pada}. Lord: ${rasiLordsEn[udayamRasi]}. '
        'The querent exhibits ${isUdayamBenefic ? "clarity and confidence" : "determination and intensity"}.';

    final String arudamDetailsTa = (udayamToArudam == 1
        ? 'உடனடி வெற்றியைத் தரக்கூடிய நிலையில் உள்ளது.'
        : (udayamToArudam == 5 || udayamToArudam == 9
            ? 'தெய்வ அனுகூலத்துடன் நல்ல பலனைத் தரும்.'
            : (udayamToArudam == 2 || udayamToArudam == 11
                ? 'தன வரவு மற்றும் விருப்பங்களை நிறைவேற்றும்.'
                : (udayamToArudam == 6 || udayamToArudam == 8 || udayamToArudam == 12
                    ? 'தடைகளையும் இழுபறியான போராட்டங்களையும் கடக்க வேண்டும்.'
                    : 'தொடர் முயற்சிகள் மூலம் சாதகமாகும்.'))));

    final arudamAnalysisTa = 'ஆருடம் ${arudam.rasiNameTa} ராசியில், உதயத்திற்கு $udayamToArudam-ஆம் பாவத்தில் அமைந்துள்ளது. '
        'அதிபதி: $arudaLordTa. '
        'கேட்கப்படும் காரியத்தின் வடிவம் $arudamDetailsTa';

    final String arudamDetailsEn = (udayamToArudam == 1
        ? 'in direct alignment with immediate success.'
        : (udayamToArudam == 5 || udayamToArudam == 9
            ? 'blessed with trinal divine assistance.'
            : (udayamToArudam == 2 || udayamToArudam == 11
                ? 'yielding financial profits and fulfillment of desires.'
                : (udayamToArudam == 6 || udayamToArudam == 8 || udayamToArudam == 12
                    ? 'subject to obstacles requiring caution and resilience.'
                    : 'achievable through persistent initiative.'))));

    final arudamAnalysisEn = 'Arudam is in ${arudam.rasiNameEn}, occupying the ${udayamToArudam}th house from Udayam. '
        'Lord: ${rasiLordsEn[arudamRasi]}. '
        'The matter inquired is $arudamDetailsEn';

    final String kavippuDetailTa = (arudamToKavippu == 1
        ? 'ஆருடத்தில் கவிப்பு நிற்பதால் எதிர்பாராத தடைகளும் ஏமாற்றங்களும் நேரலாம். நிதானம் தேவை.'
        : (udayamToKavippu == 1
            ? 'உதயத்தில் கவிப்பு இருப்பதால் முடிவெடுப்பதில் குழப்பங்கள் ஏற்படலாம்.'
            : 'கவிப்பு ஆருடத்தை பாதிக்காத தூரத்தில் அமைந்திருப்பது காரியத்திற்கு பாதுகாப்பானது.'));

    final kavippuAnalysisTa = 'கவிப்பு ${kavippu.rasiNameTa} ராசியில், ஆருடத்திற்கு $arudamToKavippu-ஆம் இடத்திலும், '
        'உதயத்திற்கு $udayamToKavippu-ஆம் இடத்திலும் உள்ளது. $kavippuDetailTa';

    final String kavippuDetailEn = (arudamToKavippu == 1
        ? 'Kavippu conjunct Arudam indicates hidden obstacles or postponements.'
        : (udayamToKavippu == 1
            ? 'Kavippu on Udayam suggests mental dilemma or hesitation.'
            : 'Kavippu is well separated from Arudam, safeguarding the enterprise.'));

    final kavippuAnalysisEn = 'Kavippu is in ${kavippu.rasiNameEn}, standing in the ${arudamToKavippu}th house from Arudam '
        'and ${udayamToKavippu}th from Udayam. $kavippuDetailEn';

    final String udayamToArudamLabelTa = (udayamToArudam == 1
        ? 'முழு அனுகூலம் (1)'
        : (udayamToArudam == 5 || udayamToArudam == 9
            ? 'திரிகோண சுபம் ($udayamToArudam)'
            : (udayamToArudam == 2 || udayamToArudam == 11
                ? 'தன/லாப அனுகூலம் ($udayamToArudam)'
                : (udayamToArudam == 4 || udayamToArudam == 7 || udayamToArudam == 10
                    ? 'கேந்திர முயற்சி ($udayamToArudam)'
                    : (udayamToArudam == 6 || udayamToArudam == 8 || udayamToArudam == 12
                        ? 'மறைவு ஸ்தானம் ($udayamToArudam) - தடைகள்'
                        : 'முயற்சி ஸ்தானம் (3)')))));

    final udayamToArudamTextTa = 'உதயத்திலிருந்து ஆருடம் $udayamToArudam-ஆம் இடம்: $udayamToArudamLabelTa';

    final String udayamToArudamLabelEn = (udayamToArudam == 1
        ? 'Direct Conjunction'
        : (udayamToArudam == 5 || udayamToArudam == 9
            ? 'Auspicious Trine'
            : (udayamToArudam == 2 || udayamToArudam == 11
                ? 'Wealth/Gain House'
                : (udayamToArudam == 4 || udayamToArudam == 7 || udayamToArudam == 10
                    ? 'Kendra / Direct Action'
                    : (udayamToArudam == 6 || udayamToArudam == 8 || udayamToArudam == 12
                        ? 'Dusthana / Obstacle'
                        : 'Courage/Effort')))));

    final udayamToArudamTextEn = 'Udayam to Arudam: ${udayamToArudam}th House ($udayamToArudamLabelEn)';

    // Question Category Specific Guidance
    final categoryBreakdown = _getCategoryDetails(category, udayamToArudam, arudamToKavippu, isOverallFavorable);

    // Positive and warning indicators
    final List<String> positives = [];
    final List<String> warnings = [];

    if (udayamToArudam == 1 || udayamToArudam == 5 || udayamToArudam == 9 || udayamToArudam == 11 || udayamToArudam == 2) {
      positives.add('உதயத்திற்கு ஆருடம் சுப ஸ்தானத்தில் உள்ளது ($udayamToArudam-ஆம் இடம்)');
    }
    if (isArudamBenefic) {
      positives.add('ஆருடத்தில் சுப கிரகங்களின் அனுகூலப் பார்வை / சேர்க்கை உள்ளது');
    }
    if (arudamToKavippu != 1 && udayamToKavippu != 1) {
      positives.add('கவிப்பு தோஷம் நேரடியாக உதயத்தையோ ஆருடத்தையோ பாதிக்கவில்லை');
    }

    if (arudamToKavippu == 1) {
      warnings.add('ஆருடத்தில் கவிப்பு உள்ளதால் வாக்குறுதிகள் அல்லது நிதி பரிவர்த்தனைகளில் எச்சரிக்கை தேவை');
    }
    if (udayamToArudam == 6 || udayamToArudam == 8 || udayamToArudam == 12) {
      warnings.add('மறைவு ஸ்தான தொடர்பு காரணமாக காரியத்தில் காலதாமதமும் கூடுதல் செலவும் ஏற்பட வாய்ப்புள்ளது');
    }
    if (warnings.isEmpty) {
      warnings.add('அவசரப்படாமல் திட்டமிட்டுச் செயல்பட்டால் காரிய சித்தி நிச்சயம்');
    }

    final verdictTitleTa = isOverallFavorable ? 'காரிய சித்தி சாதகம் (வெற்றி உறுதி)' : 'பொறுமையும் எச்சரிக்கையும் தேவை (இழுபறி)';
    final verdictTitleEn = isOverallFavorable ? 'Favorable Outcome (Success Likely)' : 'Caution and Patience Advised';

    final verdictSummaryTa = isOverallFavorable
        ? 'தற்போதைய பிரசன்ன நிலவரப்படி, உதயமும் ஆருடமும் சாதகமான அமைப்பில் இணைந்துள்ளன. எண்ணிய காரியம் நல்ல முறையில் முடியும்.'
        : 'தற்போதைய பிரசன்ன நிலவரப்படி, காரியத்தில் சில தடைகள் அல்லது மறைமுக எதிர்ப்புகள் காணப்படுகின்றன. அவசர முடிவுகளைத் தவிர்ப்பது நல்லது.';

    final verdictSummaryEn = isOverallFavorable
        ? 'Based on the Jamakkol configuration, Udayam and Arudam form a favorable harmony. The inquired objective is poised for success.'
        : 'The chart indicates hindrances or delays in the inquired matter. It is prudent to avoid hasty commitments.';

    return JamakkolInterpretation(
      verdictTitleTa: verdictTitleTa,
      verdictTitleEn: verdictTitleEn,
      verdictSummaryTa: verdictSummaryTa,
      verdictSummaryEn: verdictSummaryEn,
      isOverallFavorable: isOverallFavorable,
      confidenceScore: score,
      udayamAnalysisTa: udayamAnalysisTa,
      udayamAnalysisEn: udayamAnalysisEn,
      arudamAnalysisTa: arudamAnalysisTa,
      arudamAnalysisEn: arudamAnalysisEn,
      kavippuAnalysisTa: kavippuAnalysisTa,
      kavippuAnalysisEn: kavippuAnalysisEn,
      udayamToArudamHouse: udayamToArudam,
      udayamToArudamTextTa: udayamToArudamTextTa,
      udayamToArudamTextEn: udayamToArudamTextEn,
      arudamToUdayamHouse: arudamToUdayam,
      udayamToKavippuHouse: udayamToKavippu,
      arudamToKavippuHouse: arudamToKavippu,
      questionCategory: category,
      questionCategoryLabelTa: categoryBreakdown.labelTa,
      questionCategoryLabelEn: categoryBreakdown.labelEn,
      questionAnalysisTa: categoryBreakdown.analysisTa,
      questionAnalysisEn: categoryBreakdown.analysisEn,
      positiveIndicatorsTa: positives,
      warningIndicatorsTa: warnings,
      practicalRemedyTa: categoryBreakdown.remedyTa,
      practicalRemedyEn: categoryBreakdown.remedyEn,
    );
  }

  static ({
    String labelTa,
    String labelEn,
    String analysisTa,
    String analysisEn,
    String remedyTa,
    String remedyEn,
  }) _getCategoryDetails(
    JamakkolQuestionCategory cat,
    int udayamToArudam,
    int arudamToKavippu,
    bool isFavorable,
  ) {
    switch (cat) {
      case JamakkolQuestionCategory.job:
        return (
          labelTa: 'உத்தியோகம் / தொழில் (Job / Career)',
          labelEn: 'Job & Career',
          analysisTa: isFavorable
              ? 'பணி மாற்றம், பதவி உயர்வு அல்லது புதிய வேலை வாய்ப்பு கைகூடும் அமைப்புகள் உள்ளன. நேர்காணல் நல்ல முடிவைத் தரும்.'
              : 'வேலை இடத்தில் தற்காலிக அழுத்தங்கள் அல்லது எதிர்பார்க்கும் முடிவில் தாமதம் ஏற்படலாம். தற்போதைய பணியைத் தொடர்வது நலம்.',
          analysisEn: isFavorable
              ? 'Promising prospects for job search, promotion, or new responsibilities. Interviews will be favorable.'
              : 'Workplace stress or delays in expected job offers. Better to maintain stability in current role.',
          remedyTa: 'வியாழக்கிழமை அல்லது சனிக்கிழமை விநாயகர் அல்லது குரு வழிபாட்டை மேற்கொள்ளவும்.',
          remedyEn: 'Offer prayers to Lord Ganesha or Guru on Thursdays.',
        );
      case JamakkolQuestionCategory.business:
        return (
          labelTa: 'வியாபாரம் / வணிகம் (Business)',
          labelEn: 'Business & Trade',
          analysisTa: isFavorable
              ? 'வியாபாரத்தில் லாபமும் புதிய வாடிக்கையாளர்கள் வருகையும் அதிகரிக்கும். கூட்டுத் தொழில் சாதகமாக அமையும்.'
              : 'புதிய முதலீடுகளை உடனடியாகச் செய்வதைத் தவிர்க்கவும். கடன் கொடுப்பது அல்லது புதிய பங்குதாரர்களை சேர்ப்பதில் கவனம் தேவை.',
          analysisEn: isFavorable
              ? 'Business profits and customer inflows will expand. Partnerships prove beneficial.'
              : 'Defer speculative investments. Exercise scrutiny in receivables and partnership contracts.',
          remedyTa: 'சுக்கிரன் அல்லது மகாலட்சுமிக்கு நெய்தீபம் ஏற்றி வழிபடவும்.',
          remedyEn: 'Light a ghee lamp for Goddess Lakshmi on Fridays.',
        );
      case JamakkolQuestionCategory.marriage:
        return (
          labelTa: 'திருமணம் / வரன் (Marriage)',
          labelEn: 'Marriage & Proposals',
          analysisTa: isFavorable
              ? 'வரன் நிச்சயம் நல்லபடியாக முடியும். குடும்பத்தாரிடையே இணக்கமான பேச்சுவார்த்தை நடைபெறும்.'
              : 'வரன் பேச்சுவார்த்தையில் மனக்கசப்பு அல்லது தாமதங்கள் உண்டாகலாம். தகவல்களை முழுமையாக உறுதிப்படுத்திய பின் முடிவெடுக்கவும்.',
          analysisEn: isFavorable
              ? 'Alliance finalization proceeds smoothly with mutual family consensus.'
              : 'Misunderstandings or delays in matrimonial talks. Verify horoscope details thoroughly before concluding.',
          remedyTa: 'வெள்ளிக்கிழமைகளில் அம்மன் வழிபாடு அல்லது திருமாங்கல்ய பூஜை நலம் தரும்.',
          remedyEn: 'Pray to Goddess Durga/Amman on Fridays for auspicious alignment.',
        );
      case JamakkolQuestionCategory.money:
        return (
          labelTa: 'தனம் / வருமானம் (Money & Finance)',
          labelEn: 'Money & Wealth',
          analysisTa: isFavorable
              ? 'எதிர்பார்த்த பண வரவு மற்றும் வரவேண்டிய பாக்கிகள் வசூலாகும். பொருளாதார நிலை உயரும்.'
              : 'பணப் பரிவர்த்தனைகளில் எதிர்பாராத இழப்பு அல்லது செலவுகள் கூடும். பிறருக்கு ஜாமீன் போடுவதைத் தவிர்க்கவும்.',
          analysisEn: isFavorable
              ? 'Expected income and pending dues will materialize. Financial stability strengthens.'
              : 'Unforeseen expenses or delays in cash flows. Avoid lending or acting as guarantor.',
          remedyTa: 'வியாழன் தோறும் குபேரன் அல்லது குரு பகவானை வழிபடவும்.',
          remedyEn: 'Offer prayers to Lord Kubera or Lord Brihaspati.',
        );
      case JamakkolQuestionCategory.loan:
        return (
          labelTa: 'கடன் / மீட்பு (Loans & Debts)',
          labelEn: 'Loans & Recovery',
          analysisTa: isFavorable
              ? 'கடன் ஒப்புதல் கிடைக்கும் அல்லது பழைய கடன்களை அடைப்பதற்கான வழி பிறக்கும்.'
              : 'கடன் பெறுவதில் தடைகள் அல்லது அதிக வட்டிச் சுமை ஏற்படலாம். கடன் வாங்குவதை தள்ளிப்போடவும்.',
          analysisEn: isFavorable
              ? 'Loan approval is likely and avenues for debt clearance will open.'
              : 'Hurdles in loan disbursement or high interest commitments. Defer borrowing.',
          remedyTa: 'செவ்வாய்க்கிழமைகளில் கடன் நிவாரண பைரவர் அல்லது முருகன் வழிபாடு சிறந்தது.',
          remedyEn: 'Worship Lord Muruga or Bhairava on Tuesdays.',
        );
      case JamakkolQuestionCategory.property:
        return (
          labelTa: 'சொத்து / மனை / வாகனம் (Property & Vehicle)',
          labelEn: 'Property & Vehicle',
          analysisTa: isFavorable
              ? 'சொத்து வாங்குவது அல்லது விற்பது நல்ல லாபத்தைத் தரும். ஆவணங்கள் சரியாக அமையும்.'
              : 'சொத்து சம்பந்தமான வில்லங்கங்கள் அல்லது ஆவணச் சிக்கல்கள் வரலாம். வழக்கறிஞரின் ஆலோசனை அவசியம்.',
          analysisEn: isFavorable
              ? 'Real estate transactions yield profitable outcomes. Property documentation is clean.'
              : 'Scrutinize title deeds and encumbrance certificates thoroughly before payment.',
          remedyTa: 'பூமிக்காரகன் செவ்வாய் மற்றும் வராக பெருமாளை வழிபடவும்.',
          remedyEn: 'Offer prayers to Lord Varaha.',
        );
      case JamakkolQuestionCategory.travel:
        return (
          labelTa: 'பயணம் / வெளிநாடு (Travel & Overseas)',
          labelEn: 'Travel & Relocation',
          analysisTa: isFavorable
              ? 'பயணம் வெற்றிகரமாகவும் நோக்கத்தை நிறைவேற்றுவதாகவும் அமையும். விசா அனுமதிகள் கிட்டும்.'
              : 'பயணத்தில் அலைச்சல், தாமதங்கள் அல்லது பயணச் சீட்டு தொடர்பான தடைகள் வரலாம். மறுபரிசீலனை செய்யவும்.',
          analysisEn: isFavorable
              ? 'Travel and visa approvals succeed without friction. Purpose of journey achieved.'
              : 'Travel itinerary may face disruptions or visa holdups. Plan carefully.',
          remedyTa: 'பயணத்தின் போது ஆஞ்சநேயர் ஸ்லோகம் கூறி வழிபடவும்.',
          remedyEn: 'Chant Hanuman Chalisa before departure.',
        );
      case JamakkolQuestionCategory.legal:
        return (
          labelTa: 'வழக்கு / தகராறு (Legal & Disputes)',
          labelEn: 'Legal & Disputes',
          analysisTa: isFavorable
              ? 'சமரசம் அல்லது சாதகமான தீர்ப்பு கிடைக்க வாய்ப்புள்ளது. எதிர்ப்புகள் விலகும்.'
              : 'வழக்கு விவகாரங்களில் இழுபறி நீடிக்கும். சமரசப் பேச்சுவார்த்தையே தற்போதைக்கு உசிதமானது.',
          analysisEn: isFavorable
              ? 'Favorable judgment or amicable out-of-court settlement is possible.'
              : 'Protracted proceedings likely. Negotiated compromise is recommended.',
          remedyTa: 'சரபேஸ்வரர் அல்லது நரசிம்மர் வழிபாடு மன தைரியத்தையும் வெற்றியையும் தரும்.',
          remedyEn: 'Pray to Lord Narasimha or Sarabeswara.',
        );
      case JamakkolQuestionCategory.lostItem:
        return (
          labelTa: 'காணாமல் போன பொருள் (Lost Articles)',
          labelEn: 'Lost Articles',
          analysisTa: isFavorable
              ? 'பொருள் அருகிலேயே அல்லது தெரிந்தவர் மூலமாக விரைவில் திரும்பக் கிடைக்கும்.'
              : 'பொருள் வேறு இடத்திற்கு மாற்றப்பட்டிருக்கலாம். தேடுதல் முயற்சியை தீவிரப்படுத்த வேண்டும்.',
          analysisEn: isFavorable
              ? 'Lost item is nearby and will be recovered through known acquaintances.'
              : 'The article may have been misplaced further away. Broaden search radius.',
          remedyTa: 'கார்தவீரியார்ஜுன மந்திரம் அல்லது விநாயகர் அகவல் பாராயணம் செய்யவும்.',
          remedyEn: 'Pray to Lord Ganesha for swift recovery of lost belongings.',
        );
      case JamakkolQuestionCategory.relationship:
        return (
          labelTa: 'உறவு / குடும்பம் (Relationships)',
          labelEn: 'Family & Relationships',
          analysisTa: isFavorable
              ? 'குடும்பத்தில் ஒற்றுமையும் உறவினர்களிடையே நல்லிணக்கமும் ஏற்படும். மனவருத்தங்கள் தீரும்.'
              : 'பேச்சில் நிதானம் தேவை. மூன்றாம் நபரின் பேச்சைக் கேட்டு வாக்குவாதத்தில் ஈடுபடுவதைத் தவிர்க்கவும்.',
          analysisEn: isFavorable
              ? 'Harmonious reconciliation and domestic peace prevail.'
              : 'Guard speech against hasty remarks. Disregard third-party gossip.',
          remedyTa: 'வீட்டில் வெள்ளிக்கிழமை நெய்தீபம் ஏற்றி சிவ-சக்தி வழிபாடு செய்யவும்.',
          remedyEn: 'Worship Shiva-Shakti for domestic harmony.',
        );
      case JamakkolQuestionCategory.health:
        return (
          labelTa: 'ஆரோக்கியம் / நலம் (Health & Wellness)',
          labelEn: 'Health & Recovery',
          analysisTa: isFavorable
              ? 'உடல் நலம் விரைவாகக் குணமாகும். தகுந்த மருத்துவ சிகிச்சை முழு பலன் தரும்.'
              : 'சோர்வு மற்றும் அசதி நீடிக்கலாம். முறையான உணவு மற்றும் மருத்துவப் பரிசோதனைகளை மேற்கொள்ளவும்.',
          analysisEn: isFavorable
              ? 'Rapid recovery and restorative vitality. Treatments will be efficacious.'
              : 'Fatigue may persist. Follow balanced nutrition and medical regimen strictly.',
          remedyTa: 'தன்வந்திரி பகவான் அல்லது வைத்தியநாத சுவாமியை வழிபடவும்.',
          remedyEn: 'Pray to Lord Dhanvantari or Vaidyanatha.',
        );
      case JamakkolQuestionCategory.competition:
        return (
          labelTa: 'தேர்வு / போட்டி (Competition & Exams)',
          labelEn: 'Exams & Competition',
          analysisTa: isFavorable
              ? 'போட்டிகளில் முன்னிலை வகித்து வெற்றி பெறுவீர்கள். கடுமையான உழைப்பு அங்கீகரிக்கப்படும்.'
              : 'போட்டி கடுமையானதாக இருக்கும். கவனச்சிதறலைத் தவிர்த்து கூடுதல் பயிற்சி மேற்கொள்ளவும்.',
          analysisEn: isFavorable
              ? 'Success and top ranking in competitive assessments. Diligence pays off.'
              : 'High competitive hurdle. Sharpen focus and practice thoroughly.',
          remedyTa: 'சரஸ்வதி தேவி மற்றும் ஹயக்ரீவர் வழிபாடு கல்வி அறிவை வளர்க்கும்.',
          remedyEn: 'Worship Goddess Saraswati and Lord Hayagriva.',
        );
      case JamakkolQuestionCategory.general:
        return (
          labelTa: 'பொது பிரசன்னம் (General Prasannam)',
          labelEn: 'General Prasannam',
          analysisTa: isFavorable
              ? 'எண்ணிய காரியத்தில் தெய்வ அனுகூலமும் உதவிகளும் கிட்டும். தன்னம்பிக்கையுடன் செயல்படலாம்.'
              : 'தற்காலிக நிதானமும் விழிப்புணர்வும் தேவை. புதிய முயற்சிகளில் யோசித்து முடிவெடுக்கவும்.',
          analysisEn: isFavorable
              ? 'Auspicious celestial backing for the inquired endeavor. Proceed with confidence.'
              : 'Exercise prudence and measured patience. Avoid rushed starts.',
          remedyTa: 'தினமும் காலையில் குலதெய்வ வழிபாடு மற்றும் சூரிய நமஸ்காரம் செய்யவும்.',
          remedyEn: 'Offer morning prayers to the family deity and Sun.',
        );
    }
  }
}
