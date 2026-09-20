import '../../models/user_model.dart';

/// KP Constants for Model 3
class KPConstants {
  // 12 Signs (Rasi)
  static const List<String> signsEn = [
    'Aries', 'Taurus', 'Gemini', 'Cancer',
    'Leo', 'Virgo', 'Libra', 'Scorpio',
    'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces'
  ];

  static const List<String> signsTa = [
    'மேஷம்', 'ரிஷபம்', 'மிதுனம்', 'கடகம்',
    'சிம்மம்', 'கன்னி', 'துலாம்', 'விருச்சிகம்',
    'தனுசு', 'மகரம்', 'கும்பம்', 'மீனம்'
  ];

  // Sign Lords in order 0..11
  static const List<String> signLords = [
    'Mars', 'Venus', 'Mercury', 'Moon',
    'Sun', 'Mercury', 'Venus', 'Mars',
    'Jupiter', 'Saturn', 'Saturn', 'Jupiter'
  ];

  static const List<String> signLordsTa = [
    'செவ்வாய்', 'சுக்கிரன்', 'புதன்', 'சந்திரன்',
    'சூரியன்', 'புதன்', 'சுக்கிரன்', 'செவ்வாய்',
    'குரு', 'சனி', 'சனி', 'குரு'
  ];

  // 9 Planets
  static const List<String> planetsEn = [
    'Ketu', 'Venus', 'Sun', 'Moon', 'Mars', 'Rahu', 'Jupiter', 'Saturn', 'Mercury'
  ];

  static const List<String> planetsTa = [
    'கேது', 'சுக்கிரன்', 'சூரியன்', 'சந்திரன்', 'செவ்வாய்', 'ராகு', 'குரு', 'சனி', 'புதன்'
  ];

  // Vimshottari Dasha Years
  static const Map<String, double> dashaYears = {
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

  // 27 Nakshatras
  static const List<String> nakshatrasEn = [
    'Ashwini', 'Bharani', 'Krittika', 'Rohini', 'Mrigashira', 'Ardra',
    'Punarvasu', 'Pushya', 'Ashlesha', 'Magha', 'Purva Phalguni', 'Uttara Phalguni',
    'Hasta', 'Chitra', 'Swati', 'Vishakha', 'Anuradha', 'Jyeshtha',
    'Mula', 'Purva Ashadha', 'Uttara Ashadha', 'Shravana', 'Dhanishta', 'Shatabhisha',
    'Purva Bhadrapada', 'Uttara Bhadrapada', 'Revati'
  ];

  static const List<String> nakshatrasTa = [
    'அஸ்வினி', 'பரணி', 'கிருத்திகை', 'ரோகிணி', 'மிருகசீரிஷம்', 'திருவாதிரை',
    'புனர்பூசம்', 'பூசம்', 'ஆயில்யம்', 'மகம்', 'பூரம்', 'உத்திரம்',
    'அஸ்தம்', 'சித்திரை', 'சுவாதி', 'விசாகம்', 'அனுஷம்', 'கேட்டை',
    'மூலம்', 'பூராடம்', 'உத்திராடம்', 'திருவோணம்', 'அவிட்டம்', 'சதயம்',
    'பூரட்டாதி', 'உத்திரட்டாதி', 'ரேவதி'
  ];

  // Star Lord for each nakshatra (index 0..26)
  static const List<String> nakshatraLords = [
    'Ketu', 'Venus', 'Sun', 'Moon', 'Mars', 'Rahu', 'Jupiter', 'Saturn', 'Mercury',
    'Ketu', 'Venus', 'Sun', 'Moon', 'Mars', 'Rahu', 'Jupiter', 'Saturn', 'Mercury',
    'Ketu', 'Venus', 'Sun', 'Moon', 'Mars', 'Rahu', 'Jupiter', 'Saturn', 'Mercury',
  ];

  // Translation helpers
  static String planetToTamil(String en) {
    final idx = planetsEn.indexOf(en);
    if (idx != -1) return planetsTa[idx];
    return en;
  }

  static String signToTamil(String en) {
    final idx = signsEn.indexOf(en);
    if (idx != -1) return signsTa[idx];
    return en;
  }
}

/// Helper function to format degrees into DMS: e.g. 24° 12' 35"
String kpDegree(double degrees) {
  double norm = degrees % 360.0;
  if (norm < 0) norm += 360.0;
  final degInSign = norm % 30.0;
  final d = degInSign.floor();
  final mf = (degInSign - d) * 60.0;
  final m = mf.floor();
  final sf = (mf - m) * 60.0;
  final s = sf.round();
  final sClamped = s >= 60 ? 59 : s;
  return '$d° ${m.toString().padLeft(2, '0')}\' ${sClamped.toString().padLeft(2, '0')}"';
}

/// Helper function to format DateTime into string
String kpDate(DateTime dt) {
  final d = dt.day.toString().padLeft(2, '0');
  final m = dt.month.toString().padLeft(2, '0');
  final y = dt.year.toString().padLeft(4, '0');
  return '$d-$m-$y';
}

/// Birth Data encapsulation for KP Method Model 3
class BirthData {
  final DateTime dateTime;
  final String time;
  final String place;
  final double latitude;
  final double longitude;
  final double timezone; // e.g. 5.5 for IST

  BirthData({
    required this.dateTime,
    required this.time,
    required this.place,
    required this.latitude,
    required this.longitude,
    this.timezone = 5.5,
  });

  DateTime get localDateTime => dateTime;

  BirthData copyWith({
    DateTime? dateTime,
    String? time,
    String? place,
    double? latitude,
    double? longitude,
    double? timezone,
  }) {
    return BirthData(
      dateTime: dateTime ?? this.dateTime,
      time: time ?? this.time,
      place: place ?? this.place,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      timezone: timezone ?? this.timezone,
    );
  }

  factory BirthData.fromUserModel(UserModel user) {
    DateTime dt;
    try {
      final dateParts = user.dob.split('-');
      final year = int.parse(dateParts[0]);
      final month = int.parse(dateParts[1]);
      final day = int.parse(dateParts[2]);

      // parse time
      int hour = 12;
      int min = 0;
      final t = user.timeOfBirth.trim().toUpperCase();
      if (t.contains(':')) {
        final isPm = t.contains('PM');
        final isAm = t.contains('AM');
        final cleanT = t.replaceAll('AM', '').replaceAll('PM', '').trim();
        final tp = cleanT.split(':');
        hour = int.tryParse(tp[0]) ?? 12;
        min = int.tryParse(tp.length > 1 ? tp[1] : '0') ?? 0;
        if (isPm && hour < 12) hour += 12;
        if (isAm && hour == 12) hour = 0;
      }
      dt = DateTime(year, month, day, hour, min);
    } catch (_) {
      dt = DateTime.now();
    }

    return BirthData(
      dateTime: dt,
      time: user.timeOfBirth.isNotEmpty ? user.timeOfBirth : '12:00 PM',
      place: user.placeOfBirth.isNotEmpty ? user.placeOfBirth : (user.city.isNotEmpty ? user.city : 'Chennai'),
      latitude: user.latitude != 0.0 ? user.latitude : 13.0827,
      longitude: user.longitude != 0.0 ? user.longitude : 80.2707,
      timezone: user.timezone != 0.0 ? user.timezone : 5.5,
    );
  }

  factory BirthData.defaultProfile() {
    return BirthData(
      dateTime: DateTime(1995, 5, 15, 10, 30),
      time: '10:30 AM',
      place: 'Chennai, Tamil Nadu',
      latitude: 13.0827,
      longitude: 80.2707,
      timezone: 5.5,
    );
  }
}

/// Planet Position encapsulation for Model 3
class PlanetPosition {
  final String planet;
  final String planetTa;
  final double longitude;
  final double degreeInRasi;
  final String degreeStr;
  final int house; // Occupied House (1..12)
  final int signIndex; // 0..11
  final String signName;
  final String signNameTa;
  final String signLord;
  final String starLord;
  final String subLord;
  final String subSubLord;
  final String subSubSubLord;
  final int nakshatraIndex;
  final String nakshatraName;
  final String nakshatraNameTa;
  final int pada;
  final List<int> ownedHouses;
  final bool isRetrograde;

  const PlanetPosition({
    required this.planet,
    required this.planetTa,
    required this.longitude,
    required this.degreeInRasi,
    required this.degreeStr,
    required this.house,
    required this.signIndex,
    required this.signName,
    required this.signNameTa,
    required this.signLord,
    required this.starLord,
    required this.subLord,
    required this.subSubLord,
    required this.subSubSubLord,
    required this.nakshatraIndex,
    required this.nakshatraName,
    required this.nakshatraNameTa,
    required this.pada,
    required this.ownedHouses,
    this.isRetrograde = false,
  });
}

/// Cusp Position encapsulation for Model 3
class CuspPosition {
  final int cuspNumber; // 1..12
  final double longitude;
  final double degreeInRasi;
  final String degreeStr;
  final int signIndex;
  final String signName;
  final String signNameTa;
  final String signLord;
  final String starLord;
  final String subLord;
  final String subSubLord;
  final String subSubSubLord;
  final int nakshatraIndex;
  final String nakshatraName;
  final String nakshatraNameTa;
  final int pada;

  const CuspPosition({
    required this.cuspNumber,
    required this.longitude,
    required this.degreeInRasi,
    required this.degreeStr,
    required this.signIndex,
    required this.signName,
    required this.signNameTa,
    required this.signLord,
    required this.starLord,
    required this.subLord,
    required this.subSubLord,
    required this.subSubSubLord,
    required this.nakshatraIndex,
    required this.nakshatraName,
    required this.nakshatraNameTa,
    required this.pada,
  });
}

/// 4-Fold KP Signification for Model 3
class Signification {
  final String planet;
  final List<int> levelA; // Planet in the star of occupant
  final List<int> levelB; // Planet as occupant
  final List<int> levelC; // Planet in the star of house lord
  final List<int> levelD; // Planet as house lord
  final List<int> allHouses; // Distinct sorted combination

  const Signification({
    required this.planet,
    required this.levelA,
    required this.levelB,
    required this.levelC,
    required this.levelD,
    required this.allHouses,
  });
}

/// Ruling Planet for Model 3 (ரா.அ, ந.அ, உ.அ, உ.உ, உ.உ.உ)
class RulingPlanet {
  final String category; // e.g. 'ரா.அ', 'ந.அ', 'உ.அ', 'உ.உ', 'உ.உ.உ'
  final String categoryEn; // Sign Lord, Star Lord, Sub Lord, Sub-Sub Lord, Sub-Sub-Sub Lord
  final String source; // e.g. 'லக்னம்', 'சந்திரன்', 'கிழமை நாதன்'
  final String planet; // Planet name in English
  final String planetTa; // Planet name in Tamil
  final List<int> houses; // Signified / occupied houses

  const RulingPlanet({
    required this.category,
    required this.categoryEn,
    required this.source,
    required this.planet,
    required this.planetTa,
    required this.houses,
  });
}

/// Cusp Relation Result with Red/Blue classification for Model 3
class CuspRelationResult {
  final int cuspNumber; // 1..12
  final String starLord;
  final String subLord;
  final String subSubLord;
  final List<int> starHouses;
  final List<int> subHouses;
  final List<int> finalHouses;
  final List<int> redHouses; // Fails/Obstacles/Dusthana
  final List<int> blueHouses; // Favorable/Gains/Growth

  const CuspRelationResult({
    required this.cuspNumber,
    required this.starLord,
    required this.subLord,
    required this.subSubLord,
    required this.starHouses,
    required this.subHouses,
    required this.finalHouses,
    required this.redHouses,
    required this.blueHouses,
  });
}

/// Vimshottari Dasha Period for Model 3
class DashaPeriod {
  final String planet;
  final String planetTa;
  final DateTime startDate;
  final DateTime endDate;
  final String startDateFormatted;
  final String endDateFormatted;
  final List<int> relatedHouses;
  final int level; // 1=Maha, 2=Bhukti, 3=Antara

  const DashaPeriod({
    required this.planet,
    required this.planetTa,
    required this.startDate,
    required this.endDate,
    required this.startDateFormatted,
    required this.endDateFormatted,
    required this.relatedHouses,
    this.level = 1,
  });
}

/// Birth Time Rectification Candidate / Result
class BirthTimeRectificationResult {
  final BirthData originalBirthData;
  final BirthData rectifiedBirthData;
  final int offsetSeconds;
  final String offsetFormatted;
  final double originalAscendant;
  final double rectifiedAscendant;
  final String rectifiedLagnaDegreeStr;
  final String rectifiedSubLord;
  final String rectifiedSubSubLord;
  final double congruenceScore; // 0..100
  final List<String> matchedRulingPlanets;
  final String explanationTa;
  final String explanationEn;

  const BirthTimeRectificationResult({
    required this.originalBirthData,
    required this.rectifiedBirthData,
    required this.offsetSeconds,
    required this.offsetFormatted,
    required this.originalAscendant,
    required this.rectifiedAscendant,
    required this.rectifiedLagnaDegreeStr,
    required this.rectifiedSubLord,
    required this.rectifiedSubSubLord,
    required this.congruenceScore,
    required this.matchedRulingPlanets,
    required this.explanationTa,
    required this.explanationEn,
  });
}

/// KP Result container for Model 3
class KPResult {
  final BirthData birthData;
  final double ascendantDegree;
  final String ascendantDegreeStr;
  final String ascendantSignTa;
  final String ascendantNakshatraTa;
  final int ascendantPada;
  final String ascendantStarLord;
  final String ascendantSubLord;
  final String ascendantSubSubLord;
  final double ayanamsa;
  final String ayanamsaStr;
  final List<PlanetPosition> planetPositions;
  final List<CuspPosition> cusps;
  final List<RulingPlanet> rulingPlanets;
  final List<Signification> significations;
  final List<CuspRelationResult> cuspRelations;
  final List<DashaPeriod> dashaPeriods;

  const KPResult({
    required this.birthData,
    required this.ascendantDegree,
    required this.ascendantDegreeStr,
    required this.ascendantSignTa,
    required this.ascendantNakshatraTa,
    required this.ascendantPada,
    required this.ascendantStarLord,
    required this.ascendantSubLord,
    required this.ascendantSubSubLord,
    required this.ayanamsa,
    required this.ayanamsaStr,
    required this.planetPositions,
    required this.cusps,
    required this.rulingPlanets,
    required this.significations,
    required this.cuspRelations,
    required this.dashaPeriods,
  });

  PlanetPosition getPlanet(String name) {
    return planetPositions.firstWhere(
      (p) => p.planet.toLowerCase() == name.toLowerCase(),
      orElse: () => planetPositions.first,
    );
  }

  CuspPosition getCusp(int houseNum) {
    return cusps.firstWhere(
      (c) => c.cuspNumber == houseNum,
      orElse: () => cusps.first,
    );
  }
}
