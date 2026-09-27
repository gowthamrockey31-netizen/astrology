import 'package:flutter/foundation.dart';

/// 12 Zodiac Rasis (0-indexed to match AstrologyCalculator)
enum Rasi {
  mesham('மேஷம்', 'Mesham', 'Aries', 'சிவப்பு', 'முருகன் வழிபாடு செய்யவும்.'),
  rishabam('ரிஷபம்', 'Rishabam', 'Taurus', 'வெள்ளை', 'லட்சுமி வழிபாடு செய்யவும்.'),
  mithunam('மிதுனம்', 'Mithunam', 'Gemini', 'பச்சை', 'விஷ்ணு வழிபாடு செய்யவும்.'),
  kadagam('கடகம்', 'Kadagam', 'Cancer', 'வெள்ளை', 'அம்பாள் வழிபாடு செய்யவும்.'),
  simmam('சிம்மம்', 'Simmam', 'Leo', 'தங்க நிறம்', 'சூரிய நமஸ்காரம் செய்யவும்.'),
  kanni('கன்னி', 'Kanni', 'Virgo', 'பச்சை', 'பெருமாள் வழிபாடு செய்யவும்.'),
  thulam('துலாம்', 'Thulam', 'Libra', 'நீலம்', 'மகாலட்சுமி வழிபாடு செய்யவும்.'),
  viruchigam('விருச்சிகம்', 'Viruchigam', 'Scorpio', 'சிவப்பு', 'சுப்பிரமணியர் வழிபாடு செய்யவும்.'),
  dhanusu('தனுசு', 'Dhanusu', 'Sagittarius', 'மஞ்சள்', 'குரு பகவான் வழிபாடு செய்யவும்.'),
  magaram('மகரம்', 'Magaram', 'Capricorn', 'கருநீலம்', 'சனி பகவான் வழிபாடு செய்யவும்.'),
  kumbam('கும்பம்', 'Kumbam', 'Aquarius', 'நீலம்', 'ஆஞ்சநேயர் வழிபாடு செய்யவும்.'),
  meenam('மீனம்', 'Meenam', 'Pisces', 'மஞ்சள்', 'குரு மற்றும் விஷ்ணு வழிபாடு செய்யவும்.');

  final String tamilName;
  final String transliteratedName;
  final String englishName;
  final String luckyColor;
  final String remedy;

  const Rasi(
    this.tamilName,
    this.transliteratedName,
    this.englishName,
    this.luckyColor,
    this.remedy,
  );

  /// 1-based Rasi number (1..12)
  int get rasiNumber => index + 1;

  static Rasi fromIndex(int idx) {
    final normalized = (idx % 12 + 12) % 12;
    return Rasi.values[normalized];
  }

  static Rasi fromTamilName(String name) {
    return Rasi.values.firstWhere(
      (r) => r.tamilName == name || name.contains(r.tamilName),
      orElse: () => Rasi.mesham,
    );
  }
}

/// Planetary Transit representation consumed from existing calculation
@immutable
class PlanetTransit {
  final String planet;
  final String planetTamil;
  final String symbol;
  final int transitRasiIndex; // 0..11
  final String transitRasiName;
  final double degree;
  final String degreeFormatted;
  final bool isRetrograde;

  const PlanetTransit({
    required this.planet,
    required this.planetTamil,
    required this.symbol,
    required this.transitRasiIndex,
    required this.transitRasiName,
    required this.degree,
    required this.degreeFormatted,
    this.isRetrograde = false,
  });
}

/// Planet house placement from Janma Rasi and its score contribution
@immutable
class PlanetHousePosition {
  final PlanetTransit transit;
  final int house; // 1..12
  final bool isGoodHouse;
  final int scoreContribution;

  const PlanetHousePosition({
    required this.transit,
    required this.house,
    required this.isGoodHouse,
    required this.scoreContribution,
  });
}

/// Complete Daily Horoscope for a single Rasi on a given Date
@immutable
class DailyRasiPalan {
  final Rasi rasi;
  final DateTime date;
  final int score; // 0..100
  final int rating; // 1..5 stars
  final String general; // பொதுப்பலன்
  final String career; // தொழில் / வேலை
  final String finance; // பணவரவு
  final String love; // காதல் / திருமணம்
  final String family; // குடும்பம்
  final String health; // ஆரோக்கியம்
  final String education; // கல்வி
  final String travel; // பயணம்
  final String luckyColor; // அதிர்ஷ்ட நிறம்
  final int luckyNumber; // அதிர்ஷ்ட எண்
  final String caution; // கவனம்
  final String remedy; // பரிகாரம்
  final List<PlanetHousePosition> planetPositions;

  const DailyRasiPalan({
    required this.rasi,
    required this.date,
    required this.score,
    required this.rating,
    required this.general,
    required this.career,
    required this.finance,
    required this.love,
    required this.family,
    required this.health,
    required this.education,
    required this.travel,
    required this.luckyColor,
    required this.luckyNumber,
    required this.caution,
    required this.remedy,
    required this.planetPositions,
  });
}
