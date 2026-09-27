// ===============================================================
// EXTENDED HOROSCOPE ENGINE (வாராந்திர, மாதாந்திர, வருடாந்திர பலன்கள்)
// Authoritative Astrological Calculation for Weekly, Monthly, & Yearly
// ===============================================================

import 'package:intl/intl.dart';
import '../models/extended_horoscope_models.dart';
import '../models/rasi_palan_models.dart';
import 'daily_rasi_palan_engine.dart';
import 'transit_calculator.dart';

class ExtendedHoroscopeEngine {
  /// Date range for a 7-day Monday-to-Sunday week
  static Map<String, DateTime> getWeekRange(DateTime anchorDate) {
    final clean = DateTime(anchorDate.year, anchorDate.month, anchorDate.day);
    // Monday is weekday 1, Sunday is 7
    final startDate = clean.subtract(Duration(days: clean.weekday - 1));
    final endDate = startDate.add(const Duration(days: 6));
    return {'start': startDate, 'end': endDate};
  }

  /// Date range for an authentic calendar month (handles 28, 29, 30, 31 dynamically)
  static Map<String, DateTime> getMonthRange(DateTime anchorDate) {
    final startDate = DateTime(anchorDate.year, anchorDate.month, 1);
    final daysInMonth = DateTime(anchorDate.year, anchorDate.month + 1, 0).day;
    final endDate = DateTime(anchorDate.year, anchorDate.month, daysInMonth);
    return {'start': startDate, 'end': endDate};
  }

  /// Date range for a full calendar year
  static Map<String, DateTime> getYearRange(int year) {
    final startDate = DateTime(year, 1, 1);
    final endDate = DateTime(year, 12, 31);
    return {'start': startDate, 'end': endDate};
  }

  static const List<String> weekdaysTa = [
    'திங்கட்கிழமை',
    'செவ்வாய்க்கிழமை',
    'புதன்கிழமை',
    'வியாழக்கிழமை',
    'வெள்ளிக்கிழமை',
    'சனிக்கிழமை',
    'ஞாயிற்றுக்கிழமை',
  ];

  static const List<String> monthsTa = [
    'ஜனவரி',
    'பிப்ரவரி',
    'மார்ச்',
    'ஏப்ரல்',
    'மே',
    'ஜூன்',
    'ஜூலை',
    'ஆகஸ்ட்',
    'செப்டம்பர்',
    'அக்டோபர்',
    'நவம்பர்',
    'டிசம்பர்',
  ];

  static const List<String> monthsEn = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  // =============================================================
  // 1. WEEKLY HOROSCOPE CALCULATION
  // =============================================================

  static WeeklyRasiPalan calculateWeeklyPalan({
    required Rasi rasi,
    required DateTime anchorDate,
  }) {
    final week = getWeekRange(anchorDate);
    final startDate = week['start']!;
    final endDate = week['end']!;

    final Map<int, int> dailyScores = {};
    int totalScore = 0;
    int maxScore = -1;
    int minScore = 999;
    int bestDayIndex = 0;
    int cautionDayIndex = 0;

    // Calculate daily transits and scores across the 7 days
    final List<DailyRasiPalan> days = [];
    for (int i = 0; i < 7; i++) {
      final curDate = startDate.add(Duration(days: i));
      final p = DailyRasiPalanEngine.calculatePalan(rasi: rasi, date: curDate);
      days.add(p);
      dailyScores[i] = p.score;
      totalScore += p.score;

      if (p.score > maxScore) {
        maxScore = p.score;
        bestDayIndex = i;
      }
      if (p.score < minScore) {
        minScore = p.score;
        cautionDayIndex = i;
      }
    }

    final int avgScore = (totalScore / 7.0).round().clamp(0, 100);
    final int rating = DailyRasiPalanEngine.calculateRating(avgScore);

    // Analyze Moon's transit progression (Start, Mid, End of week)
    final monMoonHouse = days[0].planetPositions.firstWhere((p) => p.transit.planet.toLowerCase() == 'moon').house;
    final wedMoonHouse = days[2].planetPositions.firstWhere((p) => p.transit.planet.toLowerCase() == 'moon').house;
    final satMoonHouse = days[5].planetPositions.firstWhere((p) => p.transit.planet.toLowerCase() == 'moon').house;

    final dateFmt = DateFormat('dd MMM');

    final periodHighlights = [
      TransitPeriodHighlight(
        title: 'வாரத் தொடக்கம் (Start of Week)',
        dateRange: '${dateFmt.format(startDate)} - ${dateFmt.format(startDate.add(const Duration(days: 1)))}',
        description: monMoonHouse == 8
            ? 'சந்திராஷ்டம தாக்கம் நிலவுவதால் புதிய காரியங்களைத் தள்ளிப்போடுவது நல்லது.'
            : ([1, 3, 6, 7, 10, 11].contains(monMoonHouse)
                ? 'சந்திரனின் சுப சஞ்சாரத்தால் வாரத் தொடக்கம் உற்சாகமாகவும் நற்பலன்களுடனும் தொடங்கும்.'
                : 'வழக்கமான பணிகளில் சீரான முன்னேற்றம் காணப்படும்.'),
        isAuspicious: monMoonHouse != 8 && monMoonHouse != 12,
      ),
      TransitPeriodHighlight(
        title: 'வாரத்தின் நடுப்பகுதி (Mid-Week)',
        dateRange: '${dateFmt.format(startDate.add(const Duration(days: 2)))} - ${dateFmt.format(startDate.add(const Duration(days: 3)))}',
        description: wedMoonHouse == 8
            ? 'மனக்குழப்பங்களைத் தவிர்த்து அமைதியைக் கடைப்பிடிக்கவும்.'
            : ([2, 5, 9, 11].contains(wedMoonHouse)
                ? 'முக்கிய சந்திப்புகள் மற்றும் பொருளாதார முயற்சிகளுக்கு உகந்த காலம்.'
                : 'பணிச்சுமை சற்று கூடுதலாக இருந்தாலும் திறம்பட சமாளிப்பீர்கள்.'),
        isAuspicious: wedMoonHouse != 8,
      ),
      TransitPeriodHighlight(
        title: 'வார இறுதி (Weekend)',
        dateRange: '${dateFmt.format(startDate.add(const Duration(days: 4)))} - ${dateFmt.format(endDate)}',
        description: satMoonHouse == 8
            ? 'பயணங்களில் கவனமும், குடும்பத்தினருடன் அமைதியான போக்கும் தேவை.'
            : 'குடும்பத்தினருடன் மகிழ்ச்சியாக பொழுதை கழிக்கவும் ஆன்மீக வழிபாட்டிற்கும் ஏற்ற தருணம்.',
        isAuspicious: satMoonHouse != 8,
      ),
    ];

    // Weekly Overview / General
    final String general;
    if (avgScore >= 75) {
      general = 'இந்த வாரம் உங்களுக்கு மிகச் சிறப்பான பலன்களை அள்ளித் தரும் பொன்னான வாரமாகும். அனைத்து முயற்சிகளிலும் தன்னம்பிக்கையுடன் செயல்பட்டு வெற்றி காண்பீர்கள். சுப காரிய பேச்சுவார்த்தைகள் கைகூடும்.';
    } else if (avgScore >= 60) {
      general = 'இந்த வாரம் அனுகூலமான முன்னேற்றங்கள் நிறைந்த வாரமாக அமையும். திட்டமிட்ட காரியங்கள் ஒவ்வொன்றாக நிறைவேறும். பெரியோர்களின் ஆதரவு மனதிற்கு நிம்மதியைத் தரும்.';
    } else if (avgScore >= 45) {
      general = 'இந்த வாரம் கலவையான பலன்கள் உண்டாகும். வாரத்தின் சில நாட்களில் எதிர்பாராத சுபச் செலவுகள் ஏற்படலாம். எதிலும் நிதானத்துடன் செயல்படுவது நன்மைகளைத் தரும்.';
    } else {
      general = 'இந்த வாரம் பொறுமையையும் விவேகத்தையும் கடைப்பிடிக்க வேண்டிய காலமாகும். உணர்ச்சிவசப்பட்டு எடுக்கும் முடிவுகளைத் தவிர்க்கவும். ஆன்மீக நாட்டம் மன அமைதியை வழங்கும்.';
    }

    // Career
    final String career;
    if (avgScore >= 65) {
      career = 'உத்தியோகத்தில் மேலதிகாரிகளின் நன்மதிப்பும் பாராட்டும் கிடைக்கும். புதிய வேலைவாய்ப்புகள் அல்லது பதவி உயர்வுக்கான சாதகமான சூழல் நிலவும்.';
    } else if (avgScore >= 45) {
      career = 'வேலைச்சுமை சீராக இருக்கும். சக ஊழியர்களிடம் இணக்கமான போக்கைக் கடைப்பிடிப்பது பணிகளை விரைவாக முடிக்க உதவும்.';
    } else {
      career = 'அலுவலக விவகாரங்களில் அடுத்தவர் பேச்சைக் கேட்டு அவசர முடிவெடுப்பதை தவிர்க்கவும். பணிகளில் கூடுதல் கவனம் தேவை.';
    }

    // Finance
    final String finance;
    if (avgScore >= 65) {
      finance = 'தனவரவு திருப்திகரமாக இருக்கும். பழைய பாக்கிகள் வசூலாகும். புதிய முதலீடுகள் அல்லது சேமிப்பு திட்டங்களில் ஈடுபட நல்ல வாய்ப்புகள் அமையும்.';
    } else if (avgScore >= 45) {
      finance = 'வரவும் செலவும் சமமாக இருக்கும். சுப நிகழ்ச்சிகளுக்கான திட்டமிடப்பட்ட செலவுகள் ஏற்படும். தேவையற்ற கடன்களைத் தவிர்க்கவும்.';
    } else {
      finance = 'பணப்பரிவர்த்தனைகளில் விழிப்புணர்வு அவசியம். ஆடம்பரச் செலவுகளைக் குறைத்து அத்தியாவசியத் தேவைகளுக்கு முன்னுரிமை அளிக்கவும்.';
    }

    // Love & Marriage
    final String love;
    if (avgScore >= 60) {
      love = 'காதல் மற்றும் திருமண வாழ்க்கையில் இனிமையான தருணங்கள் அமையும். தம்பதியரிடையே அன்யோன்யமும் பரஸ்பர புரிதலும் கூடும்.';
    } else {
      love = 'வாழ்க்கைத் துணையுடன் சிறு கருத்து வேறுபாடுகள் தோன்றினாலும் பேசி தீர்த்துக் கொள்வது நல்லது. விட்டுக்கொடுத்துச் செல்வது அமைதி தரும்.';
    }

    // Family
    final String family = avgScore >= 60
        ? 'குடும்பத்தில் அமைதியும் மகிழ்ச்சியும் நிலவும். சுப நிகழ்ச்சிகள் பற்றிய பேச்சுக்கள் முடிவுக்கு வரும்.'
        : 'குடும்ப மூத்தவர்களின் ஆலோசனையைக் கேட்டு நடப்பது குடும்ப ஒற்றுமையை பலப்படுத்தும்.';

    // Health
    final String health = avgScore >= 50
        ? 'உடல் ஆரோக்கியம் சீராக இருக்கும். மன உற்சாகமும் சுறுசுறுப்பும் பணிகளில் வேகத்தைக் கூட்டும்.'
        : 'உணவு முறைகளில் கட்டுப்பாடு மற்றும் போதுமான தூக்கம் அவசியம். சிறிய உடல் உபாதைகளையும் அலட்சியம் செய்ய வேண்டாம்.';

    // Education
    final String education = 'மாணவ மாணவியர் படிப்பில் ஆர்வம் காட்டுவர். ஆசிரியர்களின் வழிகாட்டுதல் தேர்வுகளில் நல்ல மதிப்பெண் பெற உதவும்.';

    // Business
    final String business = avgScore >= 60
        ? 'வியாபாரத்தில் புதிய வாடிக்கையாளர்கள் கிடைப்பர். கூட்டாளிகளுடன் இணக்கமான சூழல் நிலவி லாபம் பெருகும்.'
        : 'தொழிலில் போட்டிகளை சமாளிக்க விவேகமான உத்திகளைக் கையாளவும். புதிய விரிவாக்கங்களை சற்று தள்ளிப்போடலாம்.';

    // Travel
    final String travel = 'பயணங்களால் நன்மைகளும் அலைச்சலுக்கேற்ற ஆதாயமும் உண்டு. வாகனப் பயணங்களில் வேகம் தவிர்ப்பது நல்லது.';

    final String luckyDays = '${weekdaysTa[bestDayIndex]} (${DateFormat('dd-MM').format(startDate.add(Duration(days: bestDayIndex)))})';
    final String cautionDays = '${weekdaysTa[cautionDayIndex]} (${DateFormat('dd-MM').format(startDate.add(Duration(days: cautionDayIndex)))})';

    final String caution = avgScore < 50
        ? 'முக்கிய முடிவுகள் எடுப்பதிலும், ஒப்பந்தங்களில் கையெழுத்திடுவதிலும் விழிப்புணர்வு தேவை.'
        : 'எதிர்பாராத வீண் வாக்குவாதங்களில் ஈடுபடுவதைத் தவிர்ப்பது மன அமைதியைத் தரும்.';

    final int luckyNumber = ((rasi.rasiNumber + startDate.day) % 9) + 1;

    return WeeklyRasiPalan(
      rasi: rasi,
      startDate: startDate,
      endDate: endDate,
      score: avgScore,
      rating: rating,
      general: general,
      career: career,
      finance: finance,
      love: love,
      family: family,
      health: health,
      education: education,
      business: business,
      travel: travel,
      luckyColor: rasi.luckyColor,
      luckyNumber: luckyNumber,
      luckyDays: luckyDays,
      cautionDays: cautionDays,
      caution: caution,
      remedy: rasi.remedy,
      periodHighlights: periodHighlights,
      dailyScores: dailyScores,
    );
  }

  // =============================================================
  // 2. MONTHLY HOROSCOPE CALCULATION
  // =============================================================

  static MonthlyRasiPalan calculateMonthlyPalan({
    required Rasi rasi,
    required DateTime anchorDate,
  }) {
    final monthRange = getMonthRange(anchorDate);
    final startDate = monthRange['start']!;
    final endDate = monthRange['end']!;
    final int year = anchorDate.year;
    final int month = anchorDate.month;
    final int daysInMonth = endDate.day;

    // Sample transits at 1st, 15th (Sun ingress window), and 25th
    final t1 = DailyRasiPalanEngine.calculatePalan(rasi: rasi, date: startDate);
    final t15 = DailyRasiPalanEngine.calculatePalan(rasi: rasi, date: DateTime(year, month, 15));
    final tEnd = DailyRasiPalanEngine.calculatePalan(rasi: rasi, date: DateTime(year, month, daysInMonth > 25 ? 25 : daysInMonth));

    final int avgScore = ((t1.score + t15.score + tEnd.score) / 3.0).round().clamp(0, 100);
    final int rating = DailyRasiPalanEngine.calculateRating(avgScore);

    final monthNameTa = monthsTa[month - 1];

    // Period Breakdowns (Days 1-10, 11-20, 21-End)
    final periodBreakdowns = [
      TransitPeriodHighlight(
        title: 'மாதத்தின் முதல் பகுதி (1 - 10 தேதிகள்)',
        dateRange: '01-$month-$year முதல் 10-$month-$year வரை',
        description: t1.score >= 50
            ? 'மாதத் தொடக்கம் சுப பலன்களை வழங்கும். புதிய முயற்சிகளைத் தொடங்கவும் முதலீடுகளுக்கும் சாதகமான காலம்.'
            : 'ஆரம்பத்தில் சில காரியத் தடைகள் ஏற்பட்டாலும் விடாமுயற்சியால் காரியங்களை வெற்றிகரமாக முடிப்பீர்கள்.',
        isAuspicious: t1.score >= 50,
      ),
      TransitPeriodHighlight(
        title: 'மாதத்தின் இடைப்பகுதி (11 - 20 தேதிகள்)',
        dateRange: '11-$month-$year முதல் 20-$month-$year வரை',
        description: t15.score >= 50
            ? 'சூரியன் மற்றும் கிரக நிலைகளின் ஆதரவால் பொருளாதார வளம் மற்றும் தொழில் முன்னேற்றம் சிறப்பாக அமையும்.'
            : 'நடுத்தர நாட்களில் வீண் செலவுகள் அதிகரிக்க வாய்ப்புள்ளதால் வரவு-செலவில் விழிப்புணர்வு தேவை.',
        isAuspicious: t15.score >= 50,
      ),
      TransitPeriodHighlight(
        title: 'மாதத்தின் இறுதிப்பகுதி (21 முதல் இறுதி வரை)',
        dateRange: '21-$month-$year முதல் $daysInMonth-$month-$year வரை',
        description: tEnd.score >= 50
            ? 'மாத இறுதியில் எதிர்பாராத நற்செய்திகள் வந்து சேரும். குடும்பத்தில் சுபகாரிய பேச்சுக்கள் வெற்றிகரமாக முடியும்.'
            : 'அலுவலக மற்றும் குடும்ப விவகாரங்களில் அமைதியான அணுகுமுறை அமைதியைத் தரும்.',
        isAuspicious: tEnd.score >= 50,
      ),
    ];

    // Monthly Overview
    final String general;
    if (avgScore >= 70) {
      general = '$monthNameTa மாதத்தில் உங்கள் ராசிக்கு கிரக நிலைகள் மிக அனுகூலமாக அமைந்துள்ளன. தொட்ட காரியங்கள் துலங்கும். நீண்ட நாட்களாக நிலுவையில் இருந்த சுப காரியங்கள் இனிதே நிறைவேறும்.';
    } else if (avgScore >= 55) {
      general = '$monthNameTa மாதம் உங்களுக்கு நன்மையான பலன்களை வாரி வழங்கும் மாதமாகும். தொழில், உத்தியோகம் மற்றும் குடும்பத்தில் சீரான வளர்ச்சி காணப்படும்.';
    } else {
      general = '$monthNameTa மாதத்தில் கலவையான பலன்கள் எதிர்பார்க்கப்படுகின்றன. எதையும் ஒருமுறைக்கு இருமுறை சிந்தித்துச் செயல்படுத்துவது சங்கடங்களைத் தவிர்க்கும்.';
    }

    // Categories
    final String career = avgScore >= 60
        ? 'உத்தியோகத்தில் மேன்மை நிலவும். பதவி உயர்வு, ஊதிய உயர்வு தொடர்பான கோரிக்கைகள் பரிசீலிக்கப்படும்.'
        : 'பணியிடத்தில் பொறுமையைக் கடைப்பிடிக்கவும். மேலதிகாரிகளிடம் வீண் விவாதங்களைத் தவிர்ப்பது நல்லது.';

    final String finance = avgScore >= 60
        ? 'தன வரவு தாராளமாக இருக்கும். புதிய சொத்துக்கள் அல்லது ஆபரணங்கள் வாங்கும் யோகம் உண்டாகும்.'
        : 'வரவுக்கு மீறிய செலவுகளைக் கட்டுப்படுத்தவும். கடன் கொடுப்பது, ஜாமீன் போடுவதைத் தவிர்க்கவும்.';

    final String love = avgScore >= 55
        ? 'காதல் மற்றும் குடும்ப பந்தங்கள் பலப்படும். பிரிந்திருந்த தம்பதியினர் ஒன்று சேருவர்.'
        : 'உறவினர்களிடையே விட்டுக் கொடுத்துச் செல்வது குடும்ப ஒற்றுமையை பாதுகாக்கும்.';

    final String family = 'குடும்பத்தில் அமைதியும் மகிழ்ச்சியும் நிறைந்திருக்கும். பிள்ளைகளின் கல்வி முன்னேற்றம் பெருமிதம் தரும்.';

    final String health = avgScore >= 50
        ? 'உடல் நலம் சீராக இருக்கும். பழைய நோய்களில் இருந்து நல்ல நிவாரணம் கிடைக்கும்.'
        : 'சீரான உணவு, தியானம் மற்றும் உடற்பயிற்சிகளை மேற்கொள்வது நலம் பயக்கும்.';

    final String education = 'மாணவர்களுக்கு நினைவாற்றலும் கவனமும் கூடும். போட்டித் தேர்வுகளில் வெற்றி வாய்ப்புகள் பிரகாசம்.';

    final String business = avgScore >= 60
        ? 'தொழில் மற்றும் வர்த்தகத்தில் சிறப்பான லாபம் ஈட்டுவீர்கள். புதிய கூட்டாண்மை முயற்சிகள் பலனளிக்கும்.'
        : 'வியாபாரத்தில் புதிய முதலீடுகளை நிபுணர்களுடன் ஆலோசித்த பின் மேற்கொள்வது உத்தமம்.';

    final String travel = 'தொழில் மற்றும் ஆன்மீகப் பயணங்கள் திருப்திகரமாக அமையும். பயணங்களின் மூலம் அனுகூலம் உண்டு.';

    final String auspiciousPeriod = 'மாதத்தின் 5, 11, 19, 24 ஆகிய தேதிகள் மிகச் சாதகமானவை.';
    final String cautionPeriod = 'சந்திராஷ்டம நாட்கள் மற்றும் மாதத்தின் 8, 17 தேதிகளில் கூடுதல் கவனம் தேவை.';

    final String caution = 'ஆவணங்களில் கையெழுத்திடும் போது விவரங்களை முழுமையாக வாசித்துப் பார்க்கவும்.';

    final int luckyNumber = ((rasi.rasiNumber + month) % 9) + 1;

    return MonthlyRasiPalan(
      rasi: rasi,
      year: year,
      month: month,
      startDate: startDate,
      endDate: endDate,
      score: avgScore,
      rating: rating,
      general: general,
      career: career,
      finance: finance,
      love: love,
      family: family,
      health: health,
      education: education,
      business: business,
      travel: travel,
      luckyColor: rasi.luckyColor,
      luckyNumber: luckyNumber,
      auspiciousPeriod: auspiciousPeriod,
      cautionPeriod: cautionPeriod,
      caution: caution,
      remedy: rasi.remedy,
      periodBreakdowns: periodBreakdowns,
    );
  }

  // =============================================================
  // 3. YEARLY HOROSCOPE CALCULATION
  // =============================================================

  static YearlyRasiPalan calculateYearlyPalan({
    required Rasi rasi,
    required int year,
  }) {
    final yearRange = getYearRange(year);
    final startDate = yearRange['start']!;
    final endDate = yearRange['end']!;

    // 12 Months summary calculations
    final List<MonthlySummaryItem> monthSummaries = [];
    int totalYearScore = 0;
    final List<String> highMonths = [];
    final List<String> lowMonths = [];

    for (int m = 1; m <= 12; m++) {
      final midMonthDate = DateTime(year, m, 15);
      final p = DailyRasiPalanEngine.calculatePalan(rasi: rasi, date: midMonthDate);
      totalYearScore += p.score;

      final mNameTa = monthsTa[m - 1];
      final mNameEn = monthsEn[m - 1];

      final summary = p.score >= 65
          ? 'முயற்சிகளில் வெற்றி, தனலாபம் மற்றும் குடும்பத்தில் சுபகாரியங்கள் கைகூடும் மாதமாகும்.'
          : (p.score >= 45
              ? 'சீரான பலன்கள் உண்டு. திட்டமிட்டு செயல்பட்டால் பொருளாதார முன்னேற்றம் கிடைக்கும்.'
              : 'பணிகளில் கூடுதல் கவனமும், வீண் விவாதங்களை தவிர்ப்பதும் நன்மை பயக்கும்.');

      final aspect = p.score >= 60
          ? 'கிரகங்களின் சுப சஞ்சாரம் சாதகமாக உள்ளது.'
          : 'கவனமுடன் செயல்பட வேண்டிய கிரக நிலை.';

      if (p.score >= 65) highMonths.add(mNameTa);
      if (p.score < 45) lowMonths.add(mNameTa);

      monthSummaries.add(MonthlySummaryItem(
        month: m,
        monthNameTa: mNameTa,
        monthNameEn: mNameEn,
        score: p.score,
        rating: p.rating,
        summary: summary,
        planetaryAspect: aspect,
      ));
    }

    final int avgScore = (totalYearScore / 12.0).round().clamp(0, 100);
    final int rating = DailyRasiPalanEngine.calculateRating(avgScore);

    // Major transit overview for the Rasi
    final sampleTransit = DailyTransitCalculator.getTransits(date: DateTime(year, 6, 15));
    final jupiterTransit = sampleTransit.firstWhere((t) => t.planet.toLowerCase() == 'jupiter');
    final saturnTransit = sampleTransit.firstWhere((t) => t.planet.toLowerCase() == 'saturn');

    final jupHouse = DailyRasiPalanEngine.calculateHouse(
      transitRasiIndex: jupiterTransit.transitRasiIndex,
      birthRasiIndex: rasi.index,
    );
    final satHouse = DailyRasiPalanEngine.calculateHouse(
      transitRasiIndex: saturnTransit.transitRasiIndex,
      birthRasiIndex: rasi.index,
    );

    final String majorTransitInfluences =
        'குரு பகவான் உங்கள் ராசிக்கு $jupHouse-ஆம் இடத்திலும், சனி பகவான் $satHouse-ஆம் இடத்திலும் சஞ்சரிக்கின்றனர். '
        '${[2, 5, 7, 9, 11].contains(jupHouse) ? 'குருவின் சுப பார்வை உங்களுக்கு அபரிமிதமான நற்பலன்களையும் சுப நிகழ்வுகளையும் கொண்டு சேர்க்கும்.' : 'குருவின் சஞ்சாரத்தால் பொறுமை கலந்த உழைப்புக்கு நல்ல அங்கீகாரம் கிடைக்கும்.'} '
        '${[3, 6, 11].contains(satHouse) ? 'சனியின் நிலை உங்களுக்கு தைரியத்தையும், எதிரிகளை வெல்லும் ஆற்றலையும், தொழில் மேன்மையையும் வழங்கும்.' : 'சனியின் பார்வை காரணமாக உடல்நலனிலும் பணிச்சுமையிலும் விழிப்புணர்வு தேவை.'}';

    // Yearly Overview
    final String general;
    if (avgScore >= 65) {
      general = '$year-ஆம் ஆண்டு உங்களுக்கு யோகமான ஆண்டாக அமையும். எடுக்கும் முயற்சிகளில் வெற்றி வாகை சூடுவீர்கள். சமூகத்தில் கௌரவமும் மரியாதையும் உயரும்.';
    } else if (avgScore >= 50) {
      general = '$year-ஆம் ஆண்டு நன்மைகளும் முன்னேற்றங்களும் நிறைந்த நற்பலன் தரும் ஆண்டாகும். உழைப்புக்கேற்ற பலன் கிட்டும்.';
    } else {
      general = '$year-ஆம் ஆண்டு உங்களை பக்குவப்படுத்தும் ஆண்டாக அமையும். விவேகமான திட்டமிடல் காரியங்களை எளிதாக்கும்.';
    }

    final String career = avgScore >= 60
        ? 'ஆண்டு முழுவதும் உத்தியோகத்தில் நல்ல வாய்ப்புகள் தேடி வரும். புதிய பொறுப்புகள் உங்களை நாடி வரும்.'
        : 'பணியிடத்தில் விசுவாசமும் கடின உழைப்பும் உயர் அதிகாரிகளின் நன்மதிப்பைப் பெற்றுத் தரும்.';

    final String finance = avgScore >= 60
        ? 'நிதி நிலைமை சீராக உயரும். பூர்வீக சொத்து விவகாரங்கள் சுமுகமாக முடியும். சுப காரியங்களுக்கான செலவுகள் மகிழ்ச்சி தரும்.'
        : 'பொருளாதாரத்தில் எச்சரிக்கை தேவை. பெரிய தொகைகளை முதலீடு செய்யும் முன் தகுந்த ஆலோசனை பெறுவது நல்லது.';

    final String love = 'குடும்ப வாழ்க்கையில் அன்பும் அன்யோன்யமும் பெருகும். திருமணம் போன்ற சுப காரிய பேச்சுக்கள் இனிதே முடியும்.';
    final String family = 'குடும்பத்தினரின் தேவைகளை நிறைவேற்றி மகிழ்வீர்கள். உறவினர்களின் வருகை உற்சாகம் அளிக்கும்.';
    final String health = 'ஆரோக்கியத்தில் நல்ல முன்னேற்றம் காணப்படும். ஆன்மீகப் பழக்கங்களும் நடைப்பயிற்சியும் உடலையும் மனதையும் புத்துணர்ச்சியுடன் வைத்திருக்கும்.';
    final String education = 'மாணவ மாணவிகள் உயர்கல்வி வாய்ப்புகளைப் பெறுவர். வெளிநாடு செல்லும் யோகமும் கைகூடும்.';
    final String business = 'தொழிலில் நல்ல திருப்புமுனைகள் ஏற்படும். புதிய முதலீடுகளும் கூட்டாண்மைகளும் எதிர்பார்ப்பை விட அதிக பலன் தரும்.';
    final String travel = 'தீர்த்த யாத்திரைகளும் ஆன்மீக ஸ்தல தரிசனங்களும் மன அமைதியை தரும். வெளிநாட்டுப் பயண யோகம் உண்டு.';

    final String favorableMonths = highMonths.isNotEmpty
        ? highMonths.join(', ')
        : 'மார்ச், மே, ஆகஸ்ட், நவம்பர்';

    final String cautionMonths = lowMonths.isNotEmpty
        ? lowMonths.join(', ')
        : 'ஜனவரி, ஜூலை';

    final String caution = 'எந்தவொரு முக்கிய முடிவையும் அனுபவசாலிகளின் ஆலோசனை பெற்றே எடுக்கவும். அவசரப்பட வேண்டாம்.';

    final int luckyNumber = ((rasi.rasiNumber + year) % 9) + 1;

    return YearlyRasiPalan(
      rasi: rasi,
      year: year,
      startDate: startDate,
      endDate: endDate,
      score: avgScore,
      rating: rating,
      general: general,
      career: career,
      finance: finance,
      love: love,
      family: family,
      health: health,
      education: education,
      business: business,
      travel: travel,
      luckyColor: rasi.luckyColor,
      luckyNumber: luckyNumber,
      majorTransitInfluences: majorTransitInfluences,
      favorableMonths: favorableMonths,
      cautionMonths: cautionMonths,
      caution: caution,
      remedy: rasi.remedy,
      monthSummaries: monthSummaries,
    );
  }
}
