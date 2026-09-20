// ===============================================================
// PROFESSIONAL MUHURTHA / NALLA NERAM - MODELS
// ===============================================================

enum MuhurthaMode {
  general,
  personal,
}

enum MuhurthaActivity {
  general,
  marriage,
  business,
  houseConstruction,
  houseEntry,
  propertyPurchase,
  vehiclePurchase,
  education,
  travel,
  agriculture,
  naming,
  medical,
}

class GeoLocation {
  final String name;
  final double latitude;
  final double longitude;
  final double timeZone;

  const GeoLocation({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.timeZone,
  });
}

class BirthProfile {
  final DateTime birthDate;
  final int birthNakshatra;
  final int birthRasi;

  const BirthProfile({
    required this.birthDate,
    required this.birthNakshatra,
    required this.birthRasi,
  });
}

class MuhurthaWindow {
  final DateTime start;
  final DateTime end;
  final double score;
  final String category;
  final List<String> reasons;

  const MuhurthaWindow({
    required this.start,
    required this.end,
    required this.score,
    required this.category,
    required this.reasons,
  });
}

class MuhurthaResult {
  final DateTime date;
  final GeoLocation location;

  final DateTime sunrise;
  final DateTime sunset;

  final MuhurthaWindow rahuKalam;
  final MuhurthaWindow yamagandam;
  final MuhurthaWindow gulikai;

  final List<MuhurthaWindow> bestWindows;
  final List<MuhurthaWindow> avoidWindows;

  final double highestScore;
  final String finalRecommendation;

  const MuhurthaResult({
    required this.date,
    required this.location,
    required this.sunrise,
    required this.sunset,
    required this.rahuKalam,
    required this.yamagandam,
    required this.gulikai,
    required this.bestWindows,
    required this.avoidWindows,
    required this.highestScore,
    required this.finalRecommendation,
  });
}
