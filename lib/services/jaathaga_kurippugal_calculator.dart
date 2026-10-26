import 'package:intl/intl.dart';
import '../models/horoscope_calculation_result.dart';
import '../models/jaathaga_kurippugal_model.dart';
import '../models/user_model.dart';
import 'astrology_calculator.dart';

/// Master Attributes for each of the 27 Nakshatras
class NakshatraAttributes {
  final String name;
  final String nameLetters;
  final String gana;
  final String yoni;
  final String rajju;
  final String bird;
  final String tree;
  final String treeType;

  const NakshatraAttributes({
    required this.name,
    required this.nameLetters,
    required this.gana,
    required this.yoni,
    required this.rajju,
    required this.bird,
    required this.tree,
    required this.treeType,
  });
}

/// Calculator Service for Horoscope Notes (ஜாதக குறிப்புகள்)
class JaathagaKurippugalCalculator {
  /// Master list of 27 Nakshatras with traditional attributes
  static const List<NakshatraAttributes> nakshatraMasterData = [
    NakshatraAttributes(
      name: "அஸ்வினி",
      nameLetters: "சு, சே, சோ, ல",
      gana: "தேவ கணம்",
      yoni: "குதிரை",
      rajju: "பாத ரஜ்ஜு",
      bird: "காட்டு கோழி",
      tree: "எட்டி",
      treeType: "பால் இல்லாத மரம்",
    ),
    NakshatraAttributes(
      name: "பரணி",
      nameLetters: "லி, லு, லே, லோ",
      gana: "மனுஷ்ய கணம்",
      yoni: "யானை",
      rajju: "தொடை ரஜ்ஜு",
      bird: "காகம்",
      tree: "நெல்லி",
      treeType: "பால் இல்லாத மரம்",
    ),
    NakshatraAttributes(
      name: "கார்த்திகை",
      nameLetters: "அ, இ, உ, எ",
      gana: "ராட்சஸ கணம்",
      yoni: "ஆடு",
      rajju: "நாபி ரஜ்ஜு",
      bird: "மயில்",
      tree: "அத்தி",
      treeType: "பால் உள்ள மரம்",
    ),
    NakshatraAttributes(
      name: "ரோகிணி",
      nameLetters: "ஒ, வ, வி, வு",
      gana: "மனுஷ்ய கணம்",
      yoni: "பாம்பு",
      rajju: "கண்ட ரஜ்ஜு",
      bird: "ஆந்தை",
      tree: "நாவல்",
      treeType: "பால் இல்லாத மரம்",
    ),
    NakshatraAttributes(
      name: "மிருகசீரிஷம்",
      nameLetters: "வே, வோ, கா, கி",
      gana: "தேவ கணம்",
      yoni: "சாரைப்பாம்பு",
      rajju: "சிரசு ரஜ்ஜு",
      bird: "வல்லூறு",
      tree: "கருங்காலி",
      treeType: "பால் இல்லாத மரம்",
    ),
    NakshatraAttributes(
      name: "திருவாதிரை",
      nameLetters: "கு, கம், ச, ச்",
      gana: "மனுஷ்ய கணம்",
      yoni: "நாய்",
      rajju: "கண்ட ரஜ்ஜு",
      bird: "ஆந்தை",
      tree: "செங்கருங்காலி",
      treeType: "பால் இல்லாத மரம்",
    ),
    NakshatraAttributes(
      name: "புனர்பூசம்",
      nameLetters: "கே, கோ, ஹா, ஹி",
      gana: "தேவ கணம்",
      yoni: "பூனை",
      rajju: "நாபி ரஜ்ஜு",
      bird: "மயில்",
      tree: "மூங்கில்",
      treeType: "பால் இல்லாத மரம்",
    ),
    NakshatraAttributes(
      name: "பூசம்",
      nameLetters: "ஹு, ஹே, ஹோ, டா",
      gana: "தேவ கணம்",
      yoni: "ஆடு",
      rajju: "தொடை ரஜ்ஜு",
      bird: "காகம்",
      tree: "அரசு",
      treeType: "பால் உள்ள மரம்",
    ),
    NakshatraAttributes(
      name: "ஆயில்யம்",
      nameLetters: "டி, டு, டே, டோ",
      gana: "ராட்சஸ கணம்",
      yoni: "பூனை",
      rajju: "பாத ரஜ்ஜு",
      bird: "காட்டு கோழி",
      tree: "புன்னை",
      treeType: "பால் உள்ள மரம்",
    ),
    NakshatraAttributes(
      name: "மகம்",
      nameLetters: "மா, மி, மு, மே",
      gana: "ராட்சஸ கணம்",
      yoni: "ஆண் எலி",
      rajju: "பாத ரஜ்ஜு",
      bird: "ஆண் கழுகு",
      tree: "ஆலமரம்",
      treeType: "பால் உள்ள மரம்",
    ),
    NakshatraAttributes(
      name: "பூரம்",
      nameLetters: "மோ, டா, டி, டு",
      gana: "மனுஷ்ய கணம்",
      yoni: "பெண் எலி",
      rajju: "தொடை ரஜ்ஜு",
      bird: "பெண் கழுகு",
      tree: "பலா",
      treeType: "பால் உள்ள மரம்",
    ),
    NakshatraAttributes(
      name: "உத்திரம்",
      nameLetters: "டே, டோ, பா, பி",
      gana: "மனுஷ்ய கணம்",
      yoni: "காளை",
      rajju: "நாபி ரஜ்ஜு",
      bird: "வல்லூறு",
      tree: "அலரி",
      treeType: "பால் உள்ள மரம்",
    ),
    NakshatraAttributes(
      name: "ஹஸ்தம்",
      nameLetters: "பூ, ஷ, ண, ட",
      gana: "தேவ கணம்",
      yoni: "எருமை",
      rajju: "கண்ட ரஜ்ஜு",
      bird: "ஆந்தை",
      tree: "அத்தி",
      treeType: "பால் உள்ள மரம்",
    ),
    NakshatraAttributes(
      name: "சித்திரை",
      nameLetters: "பே, போ, ரா, ரி",
      gana: "ராட்சஸ கணம்",
      yoni: "புலி",
      rajju: "சிரசு ரஜ்ஜு",
      bird: "மயில்",
      tree: "வில்வம்",
      treeType: "பால் உள்ள மரம்",
    ),
    NakshatraAttributes(
      name: "சுவாதி",
      nameLetters: "ரு, ரே, ரோ, தா",
      gana: "தேவ கணம்",
      yoni: "எருமை",
      rajju: "கண்ட ரஜ்ஜு",
      bird: "தேனீ",
      tree: "மருது",
      treeType: "பால் இல்லாத மரம்",
    ),
    NakshatraAttributes(
      name: "விசாகம்",
      nameLetters: "தி, து, தே, தோ",
      gana: "ராட்சஸ கணம்",
      yoni: "ஆண் புலி",
      rajju: "நாபி ரஜ்ஜு",
      bird: "கிளி",
      tree: "விளாம்",
      treeType: "பால் இல்லாத மரம்",
    ),
    NakshatraAttributes(
      name: "அனுஷம்",
      nameLetters: "நா, நி, நூ, நே",
      gana: "தேவ கணம்",
      yoni: "மான்",
      rajju: "தொடை ரஜ்ஜு",
      bird: "காகம்",
      tree: "மகிழம்",
      treeType: "பால் இல்லாத மரம்",
    ),
    NakshatraAttributes(
      name: "கேட்டை",
      nameLetters: "நோ, யா, யி, யு",
      gana: "ராட்சஸ கணம்",
      yoni: "மான்",
      rajju: "பாத ரஜ்ஜு",
      bird: "கோழி",
      tree: "பிராய்",
      treeType: "பால் இல்லாத மரம்",
    ),
    NakshatraAttributes(
      name: "மூலம்",
      nameLetters: "யே, யோ, பா, பி",
      gana: "ராட்சஸ கணம்",
      yoni: "நாய்",
      rajju: "பாத ரஜ்ஜு",
      bird: "செம்பகம்",
      tree: "மராமரம்",
      treeType: "பால் இல்லாத மரம்",
    ),
    NakshatraAttributes(
      name: "பூராடம்",
      nameLetters: "பூ, த, ஃப, ட",
      gana: "மனுஷ்ய கணம்",
      yoni: "பெண் குரங்கு",
      rajju: "தொடை ரஜ்ஜு",
      bird: "காகம்",
      tree: "வஞ்சி",
      treeType: "பால் இல்லாத மரம்",
    ),
    NakshatraAttributes(
      name: "உத்திராடம்",
      nameLetters: "பே, போ, ஜா, ஜி",
      gana: "மனுஷ்ய கணம்",
      yoni: "ஆண் குரங்கு",
      rajju: "நாபி ரஜ்ஜு",
      bird: "வல்லூறு",
      tree: "பலாசம்",
      treeType: "பால் உள்ள மரம்",
    ),
    NakshatraAttributes(
      name: "திருவோணம்",
      nameLetters: "கி, கு, கே, கோ",
      gana: "தேவ கணம்",
      yoni: "பெண் குரங்கு",
      rajju: "கண்ட ரஜ்ஜு",
      bird: "நாரை",
      tree: "எருக்கு",
      treeType: "பால் உள்ள மரம்",
    ),
    NakshatraAttributes(
      name: "அவிட்டம்",
      nameLetters: "கா, கி, கூ, கே",
      gana: "ராட்சஸ கணம்",
      yoni: "பெண் சிங்கம்",
      rajju: "சிரசு ரஜ்ஜு",
      bird: "பொன்வண்டு",
      tree: "வன்னி",
      treeType: "பால் இல்லாத மரம்",
    ),
    NakshatraAttributes(
      name: "சதயம்",
      nameLetters: "கோ, சா, சி, சு",
      gana: "ராட்சஸ கணம்",
      yoni: "குதிரை",
      rajju: "கண்ட ரஜ்ஜு",
      bird: "அன்னம்",
      tree: "கடம்பு",
      treeType: "பால் இல்லாத மரம்",
    ),
    NakshatraAttributes(
      name: "பூரட்டாதி",
      nameLetters: "சே, சோ, தா, தி",
      gana: "மனுஷ்ய கணம்",
      yoni: "ஆண் சிங்கம்",
      rajju: "நாபி ரஜ்ஜு",
      bird: "ஆந்தை",
      tree: "தேமா",
      treeType: "பால் உள்ள மரம்",
    ),
    NakshatraAttributes(
      name: "உத்தரட்டாதி",
      nameLetters: "து, ஞ, ச, த",
      gana: "மனுஷ்ய கணம்",
      yoni: "பெண் பசு",
      rajju: "தொடை ரஜ்ஜு",
      bird: "கோழி",
      tree: "வேம்பு",
      treeType: "பால் உள்ள மரம்",
    ),
    NakshatraAttributes(
      name: "ரேவதி",
      nameLetters: "தே, தோ, சா, சி",
      gana: "தேவ கணம்",
      yoni: "பெண் யானை",
      rajju: "பாத ரஜ்ஜு",
      bird: "வல்லூறு",
      tree: "இலுப்பை",
      treeType: "பால் உள்ள மரம்",
    ),
  ];

  static const List<String> tamilWeekdays = [
    "திங்கள்",
    "செவ்வாய்",
    "புதன்",
    "வியாழன்",
    "வெள்ளி",
    "சனி",
    "ஞாயிறு",
  ];

  /// 60 Tamil Year cycle names (பிரபவ முதல் அட்சய வரை)
  static const List<String> tamilYearsTa = [
    "பிரபவ", "விபவ", "சுக்ல", "பிரமோதூத", "பிரஜோற்பத்தி", "ஆங்கீரச", "ஸ்ரீமுக", "பவ", "யுவ", "தாது",
    "ஈஸ்வர", "வெகுதானிய", "பிரமாதி", "விக்ரம", "விஷு", "சித்ரபானு", "சுபானு", "தாரண", "பார்த்திப", "விய",
    "சர்வசித்து", "சர்வதாரி", "விரோதி", "விக்ருதி", "கர", "நந்தன", "விஜய", "ஜய", "மன்மத", "துன்முகி",
    "ஹேவிளம்பி", "விளம்பி", "விகாரி", "சார்வரி", "பிலவ", "சுபகிருது", "சோபகிருது", "குரோதி", "விஸ்வாசுவசு", "பராபவ",
    "பிலவங்க", "கீலக", "சௌமிய", "சாதாரண", "விரோதகிருது", "பரிதாபி", "பிரமாதீச", "ஆனந்த", "ராட்சச", "நள",
    "பிங்கள", "காளயுக்தி", "சித்தார்த்தி", "ரௌத்திரி", "துன்மதி", "துந்துபி", "ருத்ரோத்காரி", "ரக்தாட்சி", "குரோதன", "அட்சய"
  ];

  static const List<String> avaYogiLords = [
    "கேது",
    "சுக்கிரன்",
    "சூரியன்",
    "சந்திரன்",
    "செவ்வாய்",
    "ராகு",
    "குரு",
    "சனி",
    "புதன்",
  ];

  /// Convert Duration into Tamil Nazhigai & Vinadi string
  static String formatNazhigai(Duration duration) {
    final totalSeconds = duration.inSeconds.abs();
    // 1 Nazhigai = 24 minutes = 1440 seconds
    final nazhi = (totalSeconds / 1440).floor();
    final remSecs = totalSeconds % 1440;
    // 1 Vinadi = 24 seconds
    final vinadi = (remSecs / 24).round();

    return "$nazhi நாழிகை $vinadi வினாடி";
  }

  /// Main method to calculate complete Jaathaga Kurippugal
  static JaathagaKurippugalResult calculateNotes({
    required UserModel user,
    DateTime? birthDateTime,
  }) {
    final name = user.name.isNotEmpty ? user.name : 'Divine Seeker';
    final dobStr = user.dob;
    final tobStr = user.timeOfBirth;
    final pobStr = user.placeOfBirth;

    // Parse birth DateTime
    final parsedDob = DateTime.tryParse(dobStr) ?? DateTime(1996, 6, 15);
    final tobParts = tobStr.split(':');
    int hour = 8;
    int minute = 30;
    if (tobParts.length >= 2) {
      hour = int.tryParse(tobParts[0].replaceAll(RegExp(r'[^0-9]'), '')) ?? 8;
      minute = int.tryParse(tobParts[1].replaceAll(RegExp(r'[^0-9]'), '')) ?? 30;
      if (tobStr.toUpperCase().contains('PM') && hour < 12) hour += 12;
      if (tobStr.toUpperCase().contains('AM') && hour == 12) hour = 0;
    }

    final dt = birthDateTime ?? DateTime(parsedDob.year, parsedDob.month, parsedDob.day, hour, minute);

    // 1. Calculate Horoscope using Central Engine
    final HoroscopeCalculationResult astroData = AstrologyCalculator.calculateHoroscope(
      dateOfBirth: dt,
      latitude: user.latitude,
      longitude: user.longitude,
      utcOffsetHours: user.timezone,
    );

    final moon = astroData.moon;
    final lagna = astroData.lagna;

    // 2. Nakshatra Attributes
    final int nakIdx = moon.nakshatraIndex.clamp(0, 26);
    final NakshatraAttributes nakAttr = nakshatraMasterData[nakIdx];

    // 3. English & Tamil Date Formatting
    final englishDateStr = DateFormat("dd-MM-yyyy").format(dt);
    final weekdayStr = tamilWeekdays[dt.weekday - 1];

    // Ava Yogi & Anu Yogi
    final avaYogiLord = avaYogiLords[(nakIdx + 6) % 9];
    final anuYogiLord = avaYogiLords[(nakIdx + 3) % 9];

    // Amirthathi Yoga
    final amirthathiStr = calculateAmirthathiYoga(dt.weekday, moon.nakshatraIndex);

    // Mukkuna Velai (ஜாதக அலங்காரம் - முக்குண வேளை முறை)
    final mukkunaStr = calculateMukkunaVelai(
      birthDateTime: dt,
      sunrise: astroData.sunrise,
    );

    // Dynamic Sunrise/Sunset from Central Engine
    final sunriseFormatted = DateFormat('hh:mm a').format(astroData.sunrise);
    final sunsetFormatted = DateFormat('hh:mm a').format(astroData.sunset);

    // Tamil Year Name (60-year Jovian cycle)
    final bool isBeforeTamilNewYear = (dt.month < 4 || (dt.month == 4 && dt.day < 14));
    final int tamilYearNum = isBeforeTamilNewYear ? dt.year - 1 : dt.year;
    final int jovianIdx = ((tamilYearNum - 1987) % 60 + 60) % 60;
    final String tamilYearName = "${tamilYearsTa[jovianIdx]} வருடம்";

    // Ayana Kalam (Sun's Sidereal Longitude: Kadagam to Dhanusu is Dakshinayana, Makaram to Mithunam is Uttarayana)
    final double sunLong = (astroData.sun.longitude % 360.0 + 360.0) % 360.0;
    final String ayanaKalam = (sunLong >= 90.0 && sunLong < 270.0)
        ? "தட்சிணாயன காலம் (Dakshinayana)"
        : "உத்தராயண காலம் (Uttarayana)";

    // Authentic Nendhiram & Jeevan based on Sun Nakshatra -> Moon Nakshatra count
    final nendhiramJeevan = calculateNendhiramJeevan(astroData.sun.nakshatraIndex, moon.nakshatraIndex);
    final nendhiramStr = nendhiramJeevan['nendhiram']!;
    final jeevanStr = nendhiramJeevan['jeevan']!;

    // Akas
    final akasStr = "30 நாழிகை 0 வினாடி";

    return JaathagaKurippugalResult(
      personName: name,
      gender: user.gender,
      age: "${user.calculatedAge} வருடம்",
      englishDate: englishDateStr,
      tamilDate: astroData.tamilDateFormatted,
      weekday: weekdayStr,
      timeOfBirth: tobStr,
      placeOfBirth: pobStr,
      lagna: "${lagna.rasiNameTa} (${lagna.rasiNameEn})",
      lagnaDegree: lagna.degreeFormatted,
      rasi: "${moon.rasiNameTa} (${moon.rasiNameEn})",
      nakshatra: moon.nakshatraNameTa,
      pada: "${moon.pada}-ஆம் பாதம்",
      starLord: moon.tamilStarLord,
      thithi: astroData.tithi.tithiNameTa,
      paksha: astroData.tithi.pakshaTa,
      yoga: astroData.yogaNameTa,
      karanam: astroData.karanaNameTa,
      amirthathiYoga: amirthathiStr,
      mukkunaVelai: mukkunaStr,
      sunrise: sunriseFormatted,
      sunset: sunsetFormatted,
      thithiSunyam: astroData.tithi.soonyamRasisTa.isNotEmpty ? astroData.tithi.soonyamRasisTa.join(', ') : 'இல்லை',
      nameLetters: nakAttr.nameLetters,
      avaYogi: avaYogiLord,
      anuYogi: anuYogiLord,
      gana: nakAttr.gana,
      yoni: nakAttr.yoni,
      rajju: nakAttr.rajju,
      bird: nakAttr.bird,
      tree: nakAttr.tree,
      treeType: nakAttr.treeType,
      udayathiNazhi: astroData.udayathiNazhiStr,
      nakshatraNazhi: astroData.nakshatraNazhiStr,
      hora: astroData.birthHoraLordTa,
      akas: akasStr,
      nendhiram: nendhiramStr,
      jeevan: jeevanStr,
      tamilYearName: tamilYearName,
      ayanaKalam: ayanaKalam,
    );
  }

  /// Authentic Tamil Panchangam Netram & Jeevan calculation
  /// Count k = 1..27 from Sun Nakshatra to Moon Nakshatra
  static Map<String, String> calculateNendhiramJeevan(int sunNakIdx, int moonNakIdx) {
    final k = ((moonNakIdx - sunNakIdx) % 27 + 27) % 27 + 1; // 1 to 27
    int nVal;
    double jVal;
    String nDesc;
    String jDesc;

    if (k == 1 || k == 2 || k == 3 || k == 27) {
      nVal = 0; jVal = 0.0;
      nDesc = "சுபம் இல்லை (குருட்டு நாள்)";
      jDesc = "ஜீவன் அற்ற நாள்";
    } else if (k == 4 || k == 25 || k == 26) {
      nVal = 0; jVal = 0.5;
      nDesc = "சுபம் இல்லை (குருட்டு நாள்)";
      jDesc = "அரை ஜீவன் (மத்திமம்)";
    } else if ((k >= 5 && k <= 8) || (k >= 21 && k <= 24)) {
      nVal = 1; jVal = 0.5;
      nDesc = "மத்திமம்";
      jDesc = "அரை ஜீவன் (மத்திமம்)";
    } else if (k == 9) {
      nVal = 2; jVal = 0.5;
      nDesc = "முழு சுபம்";
      jDesc = "அரை ஜீவன் (மத்திமம்)";
    } else if (k == 10) {
      nVal = 2; jVal = 0.0;
      nDesc = "முழு சுபம்";
      jDesc = "ஜீவன் அற்ற நாள்";
    } else if (k >= 11 && k <= 19) {
      nVal = 2; jVal = 1.0;
      nDesc = "முழு சுபம்";
      jDesc = "சுப பலன்";
    } else if (k == 20) {
      nVal = 2; jVal = 0.5;
      nDesc = "முழு சுபம்";
      jDesc = "அரை ஜீவன் (மத்திமம்)";
    } else {
      nVal = 1; jVal = 0.5;
      nDesc = "மத்திமம்";
      jDesc = "அரை ஜீவன் (மத்திமம்)";
    }

    final jStr = jVal == 0.0 ? "0" : (jVal == 0.5 ? "½" : "1");
    return {
      'nendhiram': '$nVal நேந்திரம் ($nDesc)',
      'jeevan': '$jStr ஜீவன் ($jDesc)',
    };
  }

  static String calculateAmirthathiYoga(int weekday, int nakshatraIndex) {
    final rem = (weekday + nakshatraIndex) % 3;
    if (rem == 0) return "அமிர்த யோகம் (சுபம்)";
    if (rem == 1) return "சித்த யோகம் (நன்மை)";
    return "மரண யோகம் (கவனம் தேவை)";
  }

  /// Mukkuna Velai Calculation (ஜாதக அலங்காரம் - முக்குண வேளை கணிதம்)
  /// Each Mukkuna Velai is 3.75 Nazhigai (மூன்றே முக்கால் நாழிகை = 90 minutes).
  /// A full 24-hour day (60 Nazhigai) contains 16 Velais (8 Day, 8 Night).
  /// The starting Guna at Sunrise depends on the Weekday:
  ///   - Monday & Thursday (சாத்வீக நாட்கள்): Starts with சாத்வீகம்
  ///   - Tuesday & Friday (ராஜச நாட்கள்): Starts with ராஜசம்
  ///   - Sunday, Wednesday, Saturday (தாமச நாட்கள்): Starts with தாமசம்
  /// The Gunas cycle continuously: சாத்வீகம் -> ராஜசம் -> தாமசம் -> சாத்வீகம்...
  static String calculateMukkunaVelai({
    required DateTime birthDateTime,
    required DateTime sunrise,
  }) {
    DateTime effectiveSunrise = DateTime(
      birthDateTime.year,
      birthDateTime.month,
      birthDateTime.day,
      sunrise.hour,
      sunrise.minute,
      sunrise.second,
    );
    int astrologicalWeekday = birthDateTime.weekday; // 1=Mon .. 7=Sun

    // If born before sunrise, the Vedic astrological day is the previous weekday
    if (birthDateTime.isBefore(effectiveSunrise)) {
      effectiveSunrise = effectiveSunrise.subtract(const Duration(days: 1));
      astrologicalWeekday = (birthDateTime.weekday - 2 + 7) % 7 + 1;
    }

    final diffMins = birthDateTime.difference(effectiveSunrise).inMinutes;
    // Each Mukkuna Velai is 3.75 Nazhigai = 90 minutes
    final periodIndex = (diffMins / 90.0).floor().clamp(0, 15);

    // Starting Guna by astrological weekday:
    // Monday (1), Thursday (4) -> Starts with சாத்வீகம் (0)
    // Tuesday (2), Friday (5) -> Starts with ராஜசம் (1)
    // Sunday (7), Wednesday (3), Saturday (6) -> Starts with தாமசம் (2)
    int startGuna;
    switch (astrologicalWeekday) {
      case 1: // Monday
      case 4: // Thursday
        startGuna = 0; // சாத்வீகம்
        break;
      case 2: // Tuesday
      case 5: // Friday
        startGuna = 1; // ராஜசம்
        break;
      case 3: // Wednesday
      case 6: // Saturday
      case 7: // Sunday
      default:
        startGuna = 2; // தாமசம்
        break;
    }

    const gunas = ['சாத்வீகம்', 'ராஜசம்', 'தாமசம்'];
    final currentGunaIndex = (startGuna + periodIndex) % 3;
    return gunas[currentGunaIndex];
  }
}
