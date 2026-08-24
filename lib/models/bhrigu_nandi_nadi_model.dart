/// Directional Element in Bhrigu Nandi Nadi
enum NadiDirection {
  east('கிழக்கு (East - Fire)', [0, 4, 8], 'மேஷம், சிம்மம், தனுசு (தர்ம திரிகோணம்)'),
  south('தெற்கு (South - Earth)', [1, 5, 9], 'ரிஷபம், கன்னி, மகரம் (அர்த்த திரிகோணம்)'),
  west('மேற்கு (West - Air)', [2, 6, 10], 'மிதுனம், துலாம், கும்பம் (காம திரிகோணம்)'),
  north('வடக்கு (North - Water)', [3, 7, 11], 'கடகம், விருச்சிகம், மீனம் (மோக்ஷ திரிகோணம்)');

  final String labelTa;
  final List<int> rasiIndices;
  final String signsTa;
  const NadiDirection(this.labelTa, this.rasiIndices, this.signsTa);
}

/// Nadi Planetary Combination
class NadiCombination {
  final String primaryPlanetTa;
  final String primaryRoleTa; // e.g. ஜீவகாரகன் (குரு), கர்மகாரகன் (சனி)
  final List<String> combinedPlanetsTa;
  final String relationTypeTa; // '1-5-9 திரிகோண சேர்க்கை', '2-12 சேர்க்கை', '3-7-11 சேர்க்கை'
  final String predictionTa;

  const NadiCombination({
    required this.primaryPlanetTa,
    required this.primaryRoleTa,
    required this.combinedPlanetsTa,
    required this.relationTypeTa,
    required this.predictionTa,
  });
}

/// Complete Bhrigu Nandi Nadi Chart Result
class BhriguNandiNadiResult {
  final Map<NadiDirection, List<String>> directionalPlanetsTa;
  final List<NadiCombination> combinations;
  final String jeevaKarakaAnalysisTa;
  final String karmaKarakaAnalysisTa;
  final String dhanaKarakaAnalysisTa;
  final String vidyaKarakaAnalysisTa;

  const BhriguNandiNadiResult({
    required this.directionalPlanetsTa,
    required this.combinations,
    required this.jeevaKarakaAnalysisTa,
    required this.karmaKarakaAnalysisTa,
    required this.dhanaKarakaAnalysisTa,
    required this.vidyaKarakaAnalysisTa,
  });
}
