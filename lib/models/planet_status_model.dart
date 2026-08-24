/// Friendship / Dignity Relationship of a Planet
enum PlanetDignity {
  ownHouse('ஆட்சி (Own)', 'வலுவான சுப பலன்'),
  exalted('உச்சம் (Exalted)', 'மிக உயர்ந்த பலன்'),
  moolatrikona('மூலத்திரிகோணம்', 'சிறந்த சுப பலன்'),
  friend('நட்பு (Friendly)', 'நன்மையான பலன்'),
  neutral('சமம் (Neutral)', 'மத்திம பலன்'),
  enemy('பகை (Enemy)', 'குறைவான பலன்'),
  debilitated('நீசம் (Debilitated)', 'பலவீனமான நிலை');

  final String tamilLabel;
  final String description;
  const PlanetDignity(this.tamilLabel, this.description);
}

/// Detailed Status of a single Planet
class SinglePlanetStatus {
  final String planetKey;
  final String nameEn;
  final String nameTa;
  final String symbol;
  final String rasiNameTa;
  final String rasiNameEn;
  final int rasiIndex;
  final double degreeInRasi;
  final String degreeFormatted;
  
  // Astrological Conditions
  final PlanetDignity dignity;
  final bool isCombust; // அஸ்தமனம்
  final double combustionOrb;
  final double distanceFromSun;
  final bool isDebilitated; // நீசம்
  final bool isExalted; // உச்சம்
  final bool isOwnHouse; // ஆட்சி
  final bool isRetrograde; // வகிரம்
  final String rasiLordTa;
  final String specialRemarks;

  const SinglePlanetStatus({
    required this.planetKey,
    required this.nameEn,
    required this.nameTa,
    required this.symbol,
    required this.rasiNameTa,
    required this.rasiNameEn,
    required this.rasiIndex,
    required this.degreeInRasi,
    required this.degreeFormatted,
    required this.dignity,
    required this.isCombust,
    required this.combustionOrb,
    required this.distanceFromSun,
    required this.isDebilitated,
    required this.isExalted,
    required this.isOwnHouse,
    required this.isRetrograde,
    required this.rasiLordTa,
    required this.specialRemarks,
  });
}

/// Full Planet Status Table Result
class PlanetStatusReport {
  final List<SinglePlanetStatus> planetStatuses;
  final int combustCount;
  final int retrogradeCount;
  final int debilitatedCount;
  final int exaltedCount;
  final int ownHouseCount;

  const PlanetStatusReport({
    required this.planetStatuses,
    required this.combustCount,
    required this.retrogradeCount,
    required this.debilitatedCount,
    required this.exaltedCount,
    required this.ownHouseCount,
  });
}
