import 'astrology_calculator.dart';
import 'tithi_calculator.dart';

/// Result of Dina Suddhi (Panchanga Day Purity Analysis)
class DinaSuddhiResult {
  final DateTime date;
  final String weekdayTa;
  final String weekdayLordTa;
  final String tithiTa;
  final String pakshaTa;
  final String nakshatraTa;
  final int pada;
  final String yogaTa;
  final String karanaTa;
  final String amirthathiYogaTa;
  
  // Purity / Suddhi Factors
  final bool isVaraShuddhi;
  final bool isTithiShuddhi;
  final bool isNakshatraShuddhi;
  final bool isYogaShuddhi;
  final bool isKaranaShuddhi;
  final bool isTithiSunyaDay;
  final bool isOverwhelminglyAuspicious;
  
  final String rahuKalam;
  final String yamaGandam;
  final String gulikaiKalam;
  final String abhijitMuhurtham;
  
  final List<String> positiveFactors;
  final List<String> cautionFactors;
  final String overallPurityScore; // e.g. "85% - மிக உத்தமமான சுப நாள்"
  final String finalVerdictTa;

  const DinaSuddhiResult({
    required this.date,
    required this.weekdayTa,
    required this.weekdayLordTa,
    required this.tithiTa,
    required this.pakshaTa,
    required this.nakshatraTa,
    required this.pada,
    required this.yogaTa,
    required this.karanaTa,
    required this.amirthathiYogaTa,
    required this.isVaraShuddhi,
    required this.isTithiShuddhi,
    required this.isNakshatraShuddhi,
    required this.isYogaShuddhi,
    required this.isKaranaShuddhi,
    required this.isTithiSunyaDay,
    required this.isOverwhelminglyAuspicious,
    required this.rahuKalam,
    required this.yamaGandam,
    required this.gulikaiKalam,
    required this.abhijitMuhurtham,
    required this.positiveFactors,
    required this.cautionFactors,
    required this.overallPurityScore,
    required this.finalVerdictTa,
  });
}

/// Dina Suddhi Calculator Service
class DinaSuddhiCalculator {
  static const List<String> rahuKalamByDay = [
    '07:30 AM - 09:00 AM', // 1: Monday
    '03:00 PM - 04:30 PM', // 2: Tuesday
    '12:00 PM - 01:30 PM', // 3: Wednesday
    '01:30 PM - 03:00 PM', // 4: Thursday
    '10:30 AM - 12:00 PM', // 5: Friday
    '09:00 AM - 10:30 AM', // 6: Saturday
    '04:30 PM - 06:00 PM', // 7: Sunday
  ];

  static const List<String> yamaGandamByDay = [
    '10:30 AM - 12:00 PM', // Monday
    '09:00 AM - 10:30 AM', // Tuesday
    '07:30 AM - 09:00 AM', // Wednesday
    '06:00 AM - 07:30 AM', // Thursday
    '03:00 PM - 04:30 PM', // Friday
    '01:30 PM - 03:00 PM', // Saturday
    '12:00 PM - 01:30 PM', // Sunday
  ];

  static const List<String> gulikaiKalamByDay = [
    '01:30 PM - 03:00 PM', // Monday
    '12:00 PM - 01:30 PM', // Tuesday
    '10:30 AM - 12:00 PM', // Wednesday
    '09:00 AM - 10:30 AM', // Thursday
    '07:30 AM - 09:00 AM', // Friday
    '06:00 AM - 07:30 AM', // Saturday
    '03:00 PM - 04:30 PM', // Sunday
  ];

  /// Calculate Dina Suddhi for a given Date and Time
  static DinaSuddhiResult calculate({
    required DateTime date,
    required double sunLongitude,
    required double moonLongitude,
    required double latitude,
    required double longitude,
    double utcOffsetHours = 5.5,
  }) {
    final int weekdayIdx = date.weekday; // 1=Mon..7=Sun
    final String weekdayTa = ['திங்கள்', 'செவ்வாய்', 'புதன்', 'வியாழன்', 'வெள்ளி', 'சனி', 'ஞாயிறு'][weekdayIdx - 1];
    final String weekdayLordTa = ['சந்திரன்', 'செவ்வாய்', 'புதன்', 'குரு', 'சுக்கிரன்', 'சனி', 'சூரியன்'][weekdayIdx - 1];

    final tithi = TithiCalculator.calculateTithi(sunLongitude: sunLongitude, moonLongitude: moonLongitude);
    final karana = AstrologyCalculator.calculateKarana(sunLongitude, moonLongitude);
    final yoga = AstrologyCalculator.calculateYoga(sunLongitude, moonLongitude);

    const double nakSpan = 360.0 / 27.0;
    const double padaSpan = nakSpan / 4.0;
    final int nakIdx = (moonLongitude / nakSpan).floor() % 27;
    final double nakOffset = moonLongitude - (nakIdx * nakSpan);
    final int pada = ((nakOffset / padaSpan).floor()).clamp(0, 3) + 1;
    final String nakTa = AstrologyCalculator.nakshatrasTa[nakIdx];

    // Amirthathi Yoga
    final int rem = (weekdayIdx + nakIdx) % 3;
    String amirthathiStr;
    if (rem == 0) amirthathiStr = "அமிர்த யோகம் (மிக சுபம்)";
    else if (rem == 1) amirthathiStr = "சித்த யோகம் (சுபம்)";
    else amirthathiStr = "மரண யோகம் (கவனம் தேவை)";

    final List<String> posFactors = [];
    final List<String> cautFactors = [];

    // Vara Purity
    bool isVaraShuddhi = (weekdayIdx == 1 || weekdayIdx == 3 || weekdayIdx == 4 || weekdayIdx == 5);
    if (isVaraShuddhi) {
      posFactors.add('$weekdayTa கிழமை சுப காரியங்களுக்கு உகந்தது');
    } else {
      cautFactors.add('$weekdayTa கிழமை - விசேஷ கவனத்துடன் சுப நிகழ்வுகளை திட்டமிடவும்');
    }

    // Tithi Purity (Avoid Riktha Tithis: 4, 9, 14; Amavasya: 30)
    final int tNum = tithi.tithiNumber;
    bool isRiktha = (tNum == 4 || tNum == 9 || tNum == 14 || tNum == 19 || tNum == 24 || tNum == 29);
    bool isAmavasya = (tNum == 30);
    bool isTithiShuddhi = !isRiktha && !isAmavasya;
    if (isTithiShuddhi) {
      posFactors.add('${tithi.pakshaTa} ${tithi.tithiNameTa} சுப திதி');
    } else {
      cautFactors.add('${tithi.tithiNameTa} (ரிக்தை / அசுப திதி பிரிவு)');
    }

    // Karana Purity (Vishti/Bhadra is inauspicious)
    bool isVishti = (karana['nameEn'] == 'Vishti' || karana['nameTa'] == 'பத்திரை');
    bool isKaranaShuddhi = !isVishti;
    if (isKaranaShuddhi) {
      posFactors.add('சுப கரணம் (${karana['nameTa']})');
    } else {
      cautFactors.add('விஷ்டி / பத்திரை கரணம் - சுப காரியங்கள் தவிர்க்கவும்');
    }

    // Yoga Purity (Avoid inauspicious Yogas like Vyatipata, Vaidhriti, Vishkambha)
    final String yogaName = yoga['nameTa'] as String;
    bool isBadYoga = (yogaName == 'வியதீபாதம்' || yogaName == 'வைதிருதி' || yogaName == 'சூலம்' || yogaName == 'கண்டம்' || yogaName == 'அதிகண்டம்');
    bool isYogaShuddhi = !isBadYoga;
    if (isYogaShuddhi) {
      posFactors.add('சுப யோகம் ($yogaName)');
    } else {
      cautFactors.add('கண்ட யோகம் ($yogaName)');
    }

    // Tithi Sunya check
    bool isTithiSunya = tithi.soonyamRasisTa.isNotEmpty;

    // Overall Score
    int points = 0;
    if (isVaraShuddhi) points += 20;
    if (isTithiShuddhi) points += 25;
    if (isKaranaShuddhi) points += 20;
    if (isYogaShuddhi) points += 20;
    if (rem == 0 || rem == 1) points += 15;

    String scoreStr;
    String verdict;
    if (points >= 80) {
      scoreStr = '$points% - மிக உத்தமமான சுப நாள்';
      verdict = 'இந்த நாள் அனைத்து மங்களகரமான சுப காரியங்கள், புது முயற்சி மற்றும் ஒப்பந்தங்களுக்கு மிக உகந்தது.';
    } else if (points >= 55) {
      scoreStr = '$points% - மத்திம சுப நாள்';
      verdict = 'நல்ல ஓரைகளில் சுப காரியங்களை முன்னெடுக்கலாம். ராகு காலத்தை தவிர்க்கவும்.';
    } else {
      scoreStr = '$points% - கவனத்துடன் செயல்பட வேண்டிய நாள்';
      verdict = 'முக்கிய சுப நிகழ்வுகளை தள்ளிவைப்பது அல்லது பிரத்யேக பரிகார சுப ஓரைகளில் மேற்கொள்வது நன்று.';
    }

    return DinaSuddhiResult(
      date: date,
      weekdayTa: weekdayTa,
      weekdayLordTa: weekdayLordTa,
      tithiTa: tithi.tithiNameTa,
      pakshaTa: tithi.pakshaTa,
      nakshatraTa: nakTa,
      pada: pada,
      yogaTa: yogaName,
      karanaTa: karana['nameTa'] as String,
      amirthathiYogaTa: amirthathiStr,
      isVaraShuddhi: isVaraShuddhi,
      isTithiShuddhi: isTithiShuddhi,
      isNakshatraShuddhi: true,
      isYogaShuddhi: isYogaShuddhi,
      isKaranaShuddhi: isKaranaShuddhi,
      isTithiSunyaDay: isTithiSunya,
      isOverwhelminglyAuspicious: points >= 80,
      rahuKalam: rahuKalamByDay[weekdayIdx - 1],
      yamaGandam: yamaGandamByDay[weekdayIdx - 1],
      gulikaiKalam: gulikaiKalamByDay[weekdayIdx - 1],
      abhijitMuhurtham: '11:45 AM - 12:35 PM',
      positiveFactors: posFactors,
      cautionFactors: cautFactors,
      overallPurityScore: scoreStr,
      finalVerdictTa: verdict,
    );
  }
}
