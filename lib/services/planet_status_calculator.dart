import '../models/planet_status_model.dart';
import 'astrology_calculator.dart';

/// Calculation Service for Detailed Planetary Status
/// Computes: Graha Pagai/Natpu, Asthamanam (Combustion), Neecham (Debilitation),
/// Utcham (Exaltation), Aatchi (Own House), and Vakiram (Retrograde).
class PlanetStatusCalculator {
  /// Sign Lord map for 12 Signs (0=Mesham ... 11=Meenam)
  static const List<String> rasiLords = [
    'Mars',    // 0: Mesham
    'Venus',   // 1: Rishabam
    'Mercury', // 2: Mithunam
    'Moon',    // 3: Kadagam
    'Sun',     // 4: Simmam
    'Mercury', // 5: Kanni
    'Venus',   // 6: Thulam
    'Mars',    // 7: Viruchigam
    'Jupiter', // 8: Dhanusu
    'Saturn',  // 9: Makaram
    'Saturn',  // 10: Kumbam
    'Jupiter', // 11: Meenam
  ];

  /// Own Sign Indices for each planet
  static const Map<String, List<int>> ownSigns = {
    'Sun': [4],
    'Moon': [3],
    'Mars': [0, 7],
    'Mercury': [2, 5],
    'Jupiter': [8, 11],
    'Venus': [1, 6],
    'Saturn': [9, 10],
    'Rahu': [10], // Kumbam in South Indian tradition
    'Ketu': [7],  // Viruchigam
  };

  /// Exaltation (உச்சம்) Sign Index and Deep Exaltation Degree
  static const Map<String, int> exaltationSigns = {
    'Sun': 0,     // Aries (Mesham) 10°
    'Moon': 1,    // Taurus (Rishabam) 3°
    'Mars': 9,    // Capricorn (Makaram) 28°
    'Mercury': 5, // Virgo (Kanni) 15°
    'Jupiter': 3, // Cancer (Kadagam) 5°
    'Venus': 11,  // Pisces (Meenam) 27°
    'Saturn': 6,  // Libra (Thulam) 20°
    'Rahu': 1,    // Taurus
    'Ketu': 7,    // Scorpio
  };

  /// Debilitation (நீசம்) Sign Index (7th from Exaltation)
  static const Map<String, int> debilitationSigns = {
    'Sun': 6,     // Libra (Thulam)
    'Moon': 7,    // Scorpio (Viruchigam)
    'Mars': 3,    // Cancer (Kadagam)
    'Mercury': 11,// Pisces (Meenam)
    'Jupiter': 9, // Capricorn (Makaram)
    'Venus': 5,   // Virgo (Kanni)
    'Saturn': 0,  // Aries (Mesham)
    'Rahu': 7,    // Scorpio
    'Ketu': 1,    // Taurus
  };

  /// Natural Friends (மித்துரு) for each planet
  static const Map<String, List<String>> naturalFriends = {
    'Sun': ['Moon', 'Mars', 'Jupiter'],
    'Moon': ['Sun', 'Mercury'],
    'Mars': ['Sun', 'Moon', 'Jupiter'],
    'Mercury': ['Sun', 'Venus'],
    'Jupiter': ['Sun', 'Moon', 'Mars'],
    'Venus': ['Mercury', 'Saturn'],
    'Saturn': ['Mercury', 'Venus'],
    'Rahu': ['Mercury', 'Venus', 'Saturn'],
    'Ketu': ['Mars', 'Jupiter'],
  };

  /// Natural Enemies (சத்துரு / பகை) for each planet
  static const Map<String, List<String>> naturalEnemies = {
    'Sun': ['Venus', 'Saturn'],
    'Moon': [], // Moon has no natural enemies
    'Mars': ['Mercury'],
    'Mercury': ['Moon'],
    'Jupiter': ['Mercury', 'Venus'],
    'Venus': ['Sun', 'Moon'],
    'Saturn': ['Sun', 'Moon', 'Mars'],
    'Rahu': ['Sun', 'Moon', 'Mars'],
    'Ketu': ['Sun', 'Moon'],
  };

  /// Standard Combustion (அஸ்தமனம்) angular distance orbs from Sun in degrees
  static const Map<String, double> combustionOrbsDirect = {
    'Moon': 12.0,
    'Mars': 17.0,
    'Mercury': 14.0,
    'Jupiter': 11.0,
    'Venus': 10.0,
    'Saturn': 15.0,
  };

  static const Map<String, double> combustionOrbsRetrograde = {
    'Mercury': 12.0,
    'Venus': 8.0,
  };

  /// Calculate detailed status report for all planets
  static PlanetStatusReport calculatePlanetStatuses(Map<String, PlanetDetail> planets) {
    final sun = planets['Sun'];
    final double sunLongitude = sun?.longitude ?? 0.0;

    final targetKeys = ['Sun', 'Moon', 'Mars', 'Mercury', 'Jupiter', 'Venus', 'Saturn', 'Rahu', 'Ketu', 'Mandi', 'Lagna'];
    final List<SinglePlanetStatus> statuses = [];

    int combustCount = 0;
    int retrogradeCount = 0;
    int debilitatedCount = 0;
    int exaltedCount = 0;
    int ownHouseCount = 0;

    for (final key in targetKeys) {
      final p = planets[key];
      if (p == null) continue;

      final isSunOrLagnaOrNodes = key == 'Sun' || key == 'Lagna' || key == 'Mandi' || key == 'Rahu' || key == 'Ketu';

      // 1. Own House (ஆட்சி)
      final bool isOwn = ownSigns[key]?.contains(p.rasiIndex) ?? false;
      if (isOwn) ownHouseCount++;

      // 2. Exalted (உச்சம்)
      final bool isExalt = (exaltationSigns[key] == p.rasiIndex);
      if (isExalt) exaltedCount++;

      // 3. Debilitated (நீசம்)
      final bool isDebil = (debilitationSigns[key] == p.rasiIndex);
      if (isDebil) debilitatedCount++;

      // 4. Combustion (அஸ்தமனம்) from Sun
      double distFromSun = 0.0;
      double orb = 0.0;
      bool isComb = false;

      if (!isSunOrLagnaOrNodes) {
        final rawDist = (p.longitude - sunLongitude).abs();
        distFromSun = rawDist > 180.0 ? 360.0 - rawDist : rawDist;
        orb = p.isRetrograde
            ? (combustionOrbsRetrograde[key] ?? combustionOrbsDirect[key] ?? 14.0)
            : (combustionOrbsDirect[key] ?? 14.0);
        isComb = distFromSun <= orb;
        if (isComb) combustCount++;
      }

      // 5. Retrograde (வகிரம்)
      if (p.isRetrograde && key != 'Rahu' && key != 'Ketu' && key != 'Sun' && key != 'Moon' && key != 'Lagna') {
        retrogradeCount++;
      }

      // 6. Dignity (நட்பு / பகை / சமம் / ஆட்சி / உச்சம் / நீசம்)
      final dignity = _determineDignity(key, p.rasiIndex, isOwn, isExalt, isDebil);

      // Sign Lord
      final signLordEn = rasiLords[p.rasiIndex];
      final signLordTa = AstrologyCalculator.planetNameToTamil[signLordEn] ?? signLordEn;

      // Special remarks
      String remarks = '';
      if (isExalt) remarks = 'உச்ச பலம்';
      else if (isDebil) remarks = 'நீச பலவீனம்';
      else if (isOwn) remarks = 'சுய ஆட்சி பலம்';
      else if (isComb) remarks = 'சூரியனால் அஸ்தமனம்';
      else if (p.isRetrograde) remarks = 'வக்ர கதி';
      else remarks = dignity.tamilLabel;

      statuses.add(SinglePlanetStatus(
        planetKey: key,
        nameEn: p.name,
        nameTa: p.tamilName,
        symbol: p.symbol,
        rasiNameTa: p.rasiNameTa,
        rasiNameEn: p.rasiNameEn,
        rasiIndex: p.rasiIndex,
        degreeInRasi: p.degreeInRasi,
        degreeFormatted: p.degreeFormatted,
        dignity: dignity,
        isCombust: isComb,
        combustionOrb: orb,
        distanceFromSun: distFromSun,
        isDebilitated: isDebil,
        isExalted: isExalt,
        isOwnHouse: isOwn,
        isRetrograde: p.isRetrograde,
        rasiLordTa: signLordTa,
        specialRemarks: remarks,
      ));
    }

    return PlanetStatusReport(
      planetStatuses: statuses,
      combustCount: combustCount,
      retrogradeCount: retrogradeCount,
      debilitatedCount: debilitatedCount,
      exaltedCount: exaltedCount,
      ownHouseCount: ownHouseCount,
    );
  }

  static PlanetDignity _determineDignity(
    String planetKey,
    int rasiIdx,
    bool isOwn,
    bool isExalt,
    bool isDebil,
  ) {
    if (isExalt) return PlanetDignity.exalted;
    if (isDebil) return PlanetDignity.debilitated;
    if (isOwn) return PlanetDignity.ownHouse;

    final signLord = rasiLords[rasiIdx];
    if (naturalFriends[planetKey]?.contains(signLord) ?? false) {
      return PlanetDignity.friend;
    }
    if (naturalEnemies[planetKey]?.contains(signLord) ?? false) {
      return PlanetDignity.enemy;
    }
    return PlanetDignity.neutral;
  }
}
