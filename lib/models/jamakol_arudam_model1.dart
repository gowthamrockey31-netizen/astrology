/// Strongly typed Core Point model for Jamakol Arudam Model 1
/// Covers: உதயம் (Udhayam), ஆருடம் (Aarudam), கவிப்பு (Kavippu)
class JamakolArudamCorePoint {
  final String nameTa; // 'உதயம்', 'ஆருடம்', 'கவிப்பு'
  final String nameEn;
  final String symbol;
  final double absoluteLongitude; // 0.0 <= longitude < 360.0
  final String rasi; // e.g. 'மேஷம்'
  final int rasiIndex; // 0 to 11
  final double degreeWithinRasi; // 0.0 <= deg < 30.0
  final int degree; // DD
  final int minute; // MM
  final double second; // SS

  const JamakolArudamCorePoint({
    required this.nameTa,
    required this.nameEn,
    required this.symbol,
    required this.absoluteLongitude,
    required this.rasi,
    required this.rasiIndex,
    required this.degreeWithinRasi,
    required this.degree,
    required this.minute,
    required this.second,
  });

  /// Formatted DMS representation: DD° MM' SS"
  String get formattedDMS {
    final dd = degree.toString().padLeft(2, '0');
    final mm = minute.toString().padLeft(2, '0');
    final ss = second.toStringAsFixed(0).padLeft(2, '0');
    return "$dd° $mm′ $ss″";
  }

  /// Decimal degree formatted representation
  String get formattedDegree => '${degreeWithinRasi.toStringAsFixed(2)}°';
}

/// Strongly typed Planetary placement model for Jamakol Arudam Model 1
class JamakolArudamPlanet {
  final String nameTa; // 'சூரியன்', 'சந்திரன்', etc.
  final String englishName;
  final String planetKey;
  final double longitude; // 0.0 <= longitude < 360.0
  final String rasi;
  final int rasiIndex; // 0 to 11
  final double degreeWithinRasi; // 0.0 <= deg < 30.0
  final int degree; // DD
  final int minute; // MM
  final double second; // SS
  final int house; // 1 to 12 from Udhayam
  final String nakshatra;
  final int pada; // 1 to 4
  final bool isRetrograde;

  const JamakolArudamPlanet({
    required this.nameTa,
    required this.englishName,
    required this.planetKey,
    required this.longitude,
    required this.rasi,
    required this.rasiIndex,
    required this.degreeWithinRasi,
    required this.degree,
    required this.minute,
    required this.second,
    required this.house,
    required this.nakshatra,
    required this.pada,
    this.isRetrograde = false,
  });

  /// Formatted DMS representation: DD° MM' SS"
  String get formattedDMS {
    final dd = degree.toString().padLeft(2, '0');
    final mm = minute.toString().padLeft(2, '0');
    final ss = second.toStringAsFixed(0).padLeft(2, '0');
    return "$dd° $mm′ $ss″";
  }

  /// Decimal degree formatted representation
  String get formattedDegree => '${degreeWithinRasi.toStringAsFixed(2)}°';
}

/// Prediction & analysis model for Jamakol Arudam Model 1
class JamakolArudamPrediction {
  final String title;
  final String pointName;
  final String planetName;
  final String ruleType;
  final String interpretationTa;
  final bool isFavorable;

  const JamakolArudamPrediction({
    required this.title,
    required this.pointName,
    this.planetName = '',
    required this.ruleType,
    required this.interpretationTa,
    this.isFavorable = true,
  });
}

/// Master Calculation Result container for Jamakol Arudam Model 1
class JamakolArudamModel1Result {
  final DateTime queryTime;
  final double latitude;
  final double longitude;
  final String placeName;
  final int jamamNumber; // 1..8
  final bool isDayJamam;
  final String jamamNameTa;
  final String jamamLordTa;

  // 3 Primary Core Points
  final JamakolArudamCorePoint udhayam; // உதயம்
  final JamakolArudamCorePoint aarudam; // ஆருடம்
  final JamakolArudamCorePoint kavippu; // கவிப்பு

  // 9 Sky/Ephemeris Navagrahas
  final List<JamakolArudamPlanet> planets;

  // Analysis & Predictions
  final List<JamakolArudamPrediction> predictions;
  final List<String> favorableSignsTa;
  final List<String> obstructiveSignsTa;
  final String generalSummaryTa;

  const JamakolArudamModel1Result({
    required this.queryTime,
    required this.latitude,
    required this.longitude,
    this.placeName = '',
    required this.jamamNumber,
    required this.isDayJamam,
    required this.jamamNameTa,
    required this.jamamLordTa,
    required this.udhayam,
    required this.aarudam,
    required this.kavippu,
    required this.planets,
    required this.predictions,
    required this.favorableSignsTa,
    required this.obstructiveSignsTa,
    required this.generalSummaryTa,
  });
}
