/// Data definitions for the Nakshatra Prasannam (நட்சத்திர பிரசன்னம்) module.
/// Preserves Planet enum, Tamil names, Dasha years, 27 Nakshatras, Lords, Rasis, Gunas, and Drekkana attributes.
library;

enum Planet {
  ketu,
  venus,
  sun,
  moon,
  mars,
  rahu,
  jupiter,
  saturn,
  mercury,
}

/// Tamil names for each planet
const Map<Planet, String> kPlanetTamilNames = {
  Planet.ketu: 'கேது',
  Planet.venus: 'சுக்கிரன்',
  Planet.sun: 'சூரியன்',
  Planet.moon: 'சந்திரன்',
  Planet.mars: 'செவ்வாய்',
  Planet.rahu: 'ராகு',
  Planet.jupiter: 'குரு',
  Planet.saturn: 'சனி',
  Planet.mercury: 'புதன்',
};

/// English names for each planet
const Map<Planet, String> kPlanetEnglishNames = {
  Planet.ketu: 'Ketu',
  Planet.venus: 'Venus',
  Planet.sun: 'Sun',
  Planet.moon: 'Moon',
  Planet.mars: 'Mars',
  Planet.rahu: 'Rahu',
  Planet.jupiter: 'Jupiter',
  Planet.saturn: 'Saturn',
  Planet.mercury: 'Mercury',
};

/// Vimshottari Dasha years for each planet (Total = 120 years)
const Map<Planet, int> kPlanetDashaYears = {
  Planet.ketu: 7,
  Planet.venus: 20,
  Planet.sun: 6,
  Planet.moon: 10,
  Planet.mars: 7,
  Planet.rahu: 18,
  Planet.jupiter: 16,
  Planet.saturn: 19,
  Planet.mercury: 17,
};

/// Sequential order of Vimshottari Dasha lords
const List<Planet> kVimshottariOrder = [
  Planet.ketu,
  Planet.venus,
  Planet.sun,
  Planet.moon,
  Planet.mars,
  Planet.rahu,
  Planet.jupiter,
  Planet.saturn,
  Planet.mercury,
];

/// Nakshatra data definition
class NakshatraData {
  final int index; // 0 to 26
  final String tamilName;
  final String englishName;
  final Planet lord;
  final String guna; // சாத்வீகம் / ராஜசம் / தாமசம்

  const NakshatraData({
    required this.index,
    required this.tamilName,
    required this.englishName,
    required this.lord,
    required this.guna,
  });
}

/// 27 Nakshatras list with Lords and Gunas
const List<NakshatraData> kNakshatras = [
  NakshatraData(index: 0, tamilName: 'அசுவினி', englishName: 'Ashwini', lord: Planet.ketu, guna: 'சாத்வீகம்'),
  NakshatraData(index: 1, tamilName: 'பரணி', englishName: 'Bharani', lord: Planet.venus, guna: 'ராஜசம்'),
  NakshatraData(index: 2, tamilName: 'கார்த்திகை', englishName: 'Krittika', lord: Planet.sun, guna: 'தாமசம்'),
  NakshatraData(index: 3, tamilName: 'ரோகிணி', englishName: 'Rohini', lord: Planet.moon, guna: 'சாத்வீகம்'),
  NakshatraData(index: 4, tamilName: 'மிருகசீரிஷம்', englishName: 'Mrigashira', lord: Planet.mars, guna: 'ராஜசம்'),
  NakshatraData(index: 5, tamilName: 'திருவாதிரை', englishName: 'Ardra', lord: Planet.rahu, guna: 'தாமசம்'),
  NakshatraData(index: 6, tamilName: 'புனர்பூசம்', englishName: 'Punarvasu', lord: Planet.jupiter, guna: 'சாத்வீகம்'),
  NakshatraData(index: 7, tamilName: 'பூசம்', englishName: 'Pushya', lord: Planet.saturn, guna: 'தாமசம்'),
  NakshatraData(index: 8, tamilName: 'ஆயில்யம்', englishName: 'Ashlesha', lord: Planet.mercury, guna: 'தாமசம்'),
  NakshatraData(index: 9, tamilName: 'மகம்', englishName: 'Magha', lord: Planet.ketu, guna: 'தாமசம்'),
  NakshatraData(index: 10, tamilName: 'பூரம்', englishName: 'Purva Phalguni', lord: Planet.venus, guna: 'ராஜசம்'),
  NakshatraData(index: 11, tamilName: 'உத்திரம்', englishName: 'Uttara Phalguni', lord: Planet.sun, guna: 'சாத்வீகம்'),
  NakshatraData(index: 12, tamilName: 'அஸ்தம்', englishName: 'Hasta', lord: Planet.moon, guna: 'சாத்வீகம்'),
  NakshatraData(index: 13, tamilName: 'சித்திரை', englishName: 'Chitra', lord: Planet.mars, guna: 'ராஜசம்'),
  NakshatraData(index: 14, tamilName: 'சுவாதி', englishName: 'Swati', lord: Planet.rahu, guna: 'தாமசம்'),
  NakshatraData(index: 15, tamilName: 'விசாகம்', englishName: 'Vishakha', lord: Planet.jupiter, guna: 'ராஜசம்'),
  NakshatraData(index: 16, tamilName: 'அனுஷம்', englishName: 'Anuradha', lord: Planet.saturn, guna: 'சாத்வீகம்'),
  NakshatraData(index: 17, tamilName: 'கேட்டை', englishName: 'Jyeshtha', lord: Planet.mercury, guna: 'தாமசம்'),
  NakshatraData(index: 18, tamilName: 'மூலம்', englishName: 'Mula', lord: Planet.ketu, guna: 'தாமசம்'),
  NakshatraData(index: 19, tamilName: 'பூராடம்', englishName: 'Purva Ashadha', lord: Planet.venus, guna: 'ராஜசம்'),
  NakshatraData(index: 20, tamilName: 'உத்திராடம்', englishName: 'Uttara Ashadha', lord: Planet.sun, guna: 'சாத்வீகம்'),
  NakshatraData(index: 21, tamilName: 'திருவோணம்', englishName: 'Shravana', lord: Planet.moon, guna: 'சாத்வீகம்'),
  NakshatraData(index: 22, tamilName: 'அவிட்டம்', englishName: 'Dhanishta', lord: Planet.mars, guna: 'ராஜசம்'),
  NakshatraData(index: 23, tamilName: 'சதயம்', englishName: 'Shatabhisha', lord: Planet.rahu, guna: 'தாமசம்'),
  NakshatraData(index: 24, tamilName: 'பூரட்டாதி', englishName: 'Purva Bhadrapada', lord: Planet.jupiter, guna: 'ராஜசம்'),
  NakshatraData(index: 25, tamilName: 'உத்திரட்டாதி', englishName: 'Uttara Bhadrapada', lord: Planet.saturn, guna: 'தாமசம்'),
  NakshatraData(index: 26, tamilName: 'ரேவதி', englishName: 'Revati', lord: Planet.mercury, guna: 'சாத்வீகம்'),
];

/// 12 Rasis definition
class RasiData {
  final int index; // 0 to 11
  final String tamilName;
  final String englishName;
  final Planet lord;
  final String nature; // சரம், ஸ்திரம், உபயம்

  const RasiData({
    required this.index,
    required this.tamilName,
    required this.englishName,
    required this.lord,
    required this.nature,
  });
}

/// 12 Rasis list
const List<RasiData> kRasis = [
  RasiData(index: 0, tamilName: 'மேஷம்', englishName: 'Aries', lord: Planet.mars, nature: 'சரம்'),
  RasiData(index: 1, tamilName: 'ரிஷபம்', englishName: 'Taurus', lord: Planet.venus, nature: 'ஸ்திரம்'),
  RasiData(index: 2, tamilName: 'மிதுனம்', englishName: 'Gemini', lord: Planet.mercury, nature: 'உபயம்'),
  RasiData(index: 3, tamilName: 'கடகம்', englishName: 'Cancer', lord: Planet.moon, nature: 'சரம்'),
  RasiData(index: 4, tamilName: 'சிம்மம்', englishName: 'Leo', lord: Planet.sun, nature: 'ஸ்திரம்'),
  RasiData(index: 5, tamilName: 'கன்னி', englishName: 'Virgo', lord: Planet.mercury, nature: 'உபயம்'),
  RasiData(index: 6, tamilName: 'துலாம்', englishName: 'Libra', lord: Planet.venus, nature: 'சரம்'),
  RasiData(index: 7, tamilName: 'விருச்சிகம்', englishName: 'Scorpio', lord: Planet.mars, nature: 'ஸ்திரம்'),
  RasiData(index: 8, tamilName: 'தனுசு', englishName: 'Sagittarius', lord: Planet.jupiter, nature: 'உபயம்'),
  RasiData(index: 9, tamilName: 'மகரம்', englishName: 'Capricorn', lord: Planet.saturn, nature: 'சரம்'),
  RasiData(index: 10, tamilName: 'கும்பம்', englishName: 'Aquarius', lord: Planet.saturn, nature: 'ஸ்திரம்'),
  RasiData(index: 11, tamilName: 'மீனம்', englishName: 'Pisces', lord: Planet.jupiter, nature: 'உபயம்'),
];

/// Planetary Relationship Type
enum PlanetaryRelationship {
  same,
  friend,
  neutral,
  enemy,
}

/// Natural Friendship table for Vedic / Nakshatra astrology
const Map<Planet, List<Planet>> kPlanetFriends = {
  Planet.sun: [Planet.moon, Planet.mars, Planet.jupiter],
  Planet.moon: [Planet.sun, Planet.mercury],
  Planet.mars: [Planet.sun, Planet.moon, Planet.jupiter],
  Planet.mercury: [Planet.sun, Planet.venus],
  Planet.jupiter: [Planet.sun, Planet.moon, Planet.mars],
  Planet.venus: [Planet.mercury, Planet.saturn, Planet.rahu, Planet.ketu],
  Planet.saturn: [Planet.mercury, Planet.venus, Planet.rahu],
  Planet.rahu: [Planet.venus, Planet.saturn, Planet.mercury],
  Planet.ketu: [Planet.mars, Planet.venus, Planet.saturn],
};

const Map<Planet, List<Planet>> kPlanetEnemies = {
  Planet.sun: [Planet.venus, Planet.saturn, Planet.rahu, Planet.ketu],
  Planet.moon: [Planet.rahu, Planet.ketu],
  Planet.mars: [Planet.mercury, Planet.rahu, Planet.ketu],
  Planet.mercury: [Planet.moon, Planet.rahu, Planet.ketu],
  Planet.jupiter: [Planet.mercury, Planet.venus, Planet.rahu, Planet.ketu],
  Planet.venus: [Planet.sun, Planet.moon],
  Planet.saturn: [Planet.sun, Planet.moon, Planet.mars, Planet.ketu],
  Planet.rahu: [Planet.sun, Planet.moon, Planet.mars, Planet.ketu],
  Planet.ketu: [Planet.sun, Planet.moon, Planet.rahu],
};
