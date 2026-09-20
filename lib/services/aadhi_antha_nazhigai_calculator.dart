/// Calculation result of Aadhi, Andha, and Parama Nazhigai
class AadhiAnthaNazhigaiResult {
  final double moonLongitude;
  final int nakshatraIndex;
  final String nakshatraNameTa;
  final int pada;
  
  // Parama Nazhigai (பரம நாழிகை - மொத்த நட்சத்திர கால அளவு: பொதுவாக 60 நாழிகை அல்லது துல்லிய மதிப்பு)
  final double paramaNazhigaiTotal;
  final String paramaNazhigaiFormatted;

  // Aadhi Nazhigai (ஆதி நாழிகை / சென்ற நாழிகை - நட்சத்திரத்தில் இதுவரை கழிந்த நாழிகை)
  final double aadhiNazhigai;
  final String aadhiNazhigaiFormatted;

  // Andha Nazhigai (அந்த நாழிகை / மீதமுள்ள நாழிகை - நட்சத்திரத்தில் இனி இருக்கும் நாழிகை)
  final double andhaNazhigai;
  final String andhaNazhigaiFormatted;

  // Total Vinazhigai metrics (மொத்த விநாடிகள்)
  final int totalVinadi;
  final double padaVinadi;
  final int aadhiVinadi;
  final int andhaVinadi;

  // Progress Percentage
  final double progressPercent;

  const AadhiAnthaNazhigaiResult({
    required this.moonLongitude,
    required this.nakshatraIndex,
    required this.nakshatraNameTa,
    required this.pada,
    required this.paramaNazhigaiTotal,
    required this.paramaNazhigaiFormatted,
    required this.aadhiNazhigai,
    required this.aadhiNazhigaiFormatted,
    required this.andhaNazhigai,
    required this.andhaNazhigaiFormatted,
    this.totalVinadi = 3600,
    this.padaVinadi = 900.0,
    this.aadhiVinadi = 0,
    this.andhaVinadi = 3600,
    required this.progressPercent,
  });
}

/// Aadhi, Andha, Parama Nazhigai Calculator Service
class AadhiAnthaNazhigaiCalculator {
  /// Calculate Aadhi, Andha, and Parama Nazhigai from Moon Longitude
  static AadhiAnthaNazhigaiResult calculate({
    required double moonLongitude,
    required String nakshatraNameTa,
    double standardParamaNazhigai = 60.0,
  }) {
    const double nakSpan = 360.0 / 27.0; // 13.333333° (13° 20')
    const double padaSpan = nakSpan / 4.0; // 3.333333° (3° 20')

    final double normLong = moonLongitude % 360.0;
    final int nakIdx = (normLong / nakSpan).floor() % 27;
    final double offset = normLong - (nakIdx * nakSpan);
    final int pada = ((offset / padaSpan).floor()).clamp(0, 3) + 1;

    // Progress fraction (0.0 to 1.0) through the current Nakshatra
    final double fraction = (offset / nakSpan).clamp(0.0, 1.0);

    // Total Vinazhigai (பரம நாழிகை மொத்த விநாடி)
    final int totalVinadi = (standardParamaNazhigai * 60.0).round();
    final double padaVinadi = totalVinadi / 4.0;

    final int aadhiVinadi = (fraction * totalVinadi).round();
    final int andhaVinadi = totalVinadi - aadhiVinadi;

    final double aadhi = aadhiVinadi / 60.0;
    final double andha = andhaVinadi / 60.0;

    return AadhiAnthaNazhigaiResult(
      moonLongitude: moonLongitude,
      nakshatraIndex: nakIdx,
      nakshatraNameTa: nakshatraNameTa,
      pada: pada,
      paramaNazhigaiTotal: standardParamaNazhigai,
      paramaNazhigaiFormatted: formatNazhigaiFromVinadi(totalVinadi),
      aadhiNazhigai: aadhi,
      aadhiNazhigaiFormatted: formatNazhigaiFromVinadi(aadhiVinadi),
      andhaNazhigai: andha,
      andhaNazhigaiFormatted: formatNazhigaiFromVinadi(andhaVinadi),
      totalVinadi: totalVinadi,
      padaVinadi: padaVinadi,
      aadhiVinadi: aadhiVinadi,
      andhaVinadi: andhaVinadi,
      progressPercent: fraction * 100.0,
    );
  }

  /// Convert Hours and Minutes duration to Nazhigai & Vinazhigai
  /// Formula:
  /// Hours * 5/2 = Nazhigai (1 hour = 2.5 Nazhigai = 2 Nazhigai 30 Vinazhigai)
  /// Minutes * 5/2 = Vinazhigai (1 min = 2.5 Vinazhigai)
  static (int nazhigai, int vinadi, int totalVinadi) convertDurationToNazhigai({
    required int hours,
    required int minutes,
  }) {
    final double nazhiFromHours = hours * 2.5;
    final double vinadiFromMins = minutes * 2.5;

    final int baseNazhi = nazhiFromHours.floor();
    final double extraVinadiFromHours = (nazhiFromHours - baseNazhi) * 60.0;

    final double totalVinadiSum = extraVinadiFromHours + vinadiFromMins;
    final int addNazhi = (totalVinadiSum / 60.0).floor();
    final int remVinadi = (totalVinadiSum - (addNazhi * 60.0)).round();

    final int finalNazhigai = baseNazhi + addNazhi;
    final int finalVinadi = remVinadi;
    final int totalVinadi = (finalNazhigai * 60) + finalVinadi;

    return (finalNazhigai, finalVinadi, totalVinadi);
  }

  /// Calculate Nakshatra metrics from traditional Panchang duration
  static AadhiAnthaNazhigaiResult calculateFromDuration({
    required String nakshatraNameTa,
    required int durationHours,
    required int durationMinutes,
    required int elapsedNazhigai,
    required int elapsedVinadi,
    double moonLongitude = 0.0,
    int nakshatraIndex = 0,
  }) {
    final (_, _, totalVinadi) = convertDurationToNazhigai(
      hours: durationHours,
      minutes: durationMinutes,
    );

    final double paramaNazhiTotal = totalVinadi / 60.0;
    final double padaVinadi = totalVinadi / 4.0;

    final int aadhiVinadi = (elapsedNazhigai * 60) + elapsedVinadi;
    final int andhaVinadi = (totalVinadi - aadhiVinadi).clamp(0, totalVinadi);

    final double aadhiNazhigai = aadhiVinadi / 60.0;
    final double andhaNazhigai = andhaVinadi / 60.0;

    final int pada = padaVinadi > 0 ? ((aadhiVinadi / padaVinadi).floor()).clamp(0, 3) + 1 : 1;
    final double progressPercent = totalVinadi > 0 ? (aadhiVinadi / totalVinadi) * 100.0 : 0.0;

    return AadhiAnthaNazhigaiResult(
      moonLongitude: moonLongitude,
      nakshatraIndex: nakshatraIndex,
      nakshatraNameTa: nakshatraNameTa,
      pada: pada,
      paramaNazhigaiTotal: paramaNazhiTotal,
      paramaNazhigaiFormatted: formatNazhigaiFromVinadi(totalVinadi),
      aadhiNazhigai: aadhiNazhigai,
      aadhiNazhigaiFormatted: formatNazhigaiFromVinadi(aadhiVinadi),
      andhaNazhigai: andhaNazhigai,
      andhaNazhigaiFormatted: formatNazhigaiFromVinadi(andhaVinadi),
      totalVinadi: totalVinadi,
      padaVinadi: padaVinadi,
      aadhiVinadi: aadhiVinadi,
      andhaVinadi: andhaVinadi,
      progressPercent: progressPercent,
    );
  }

  /// Formats Nazhigai & Vinadi from total Vinadi count
  static String formatNazhigaiFromVinadi(int totalVinadi) {
    final int nazhi = (totalVinadi / 60).floor();
    final int vinadi = totalVinadi % 60;
    return "$nazhi நாழிகை $vinadi வினாடி";
  }

  static String _formatNazhigai(double totalNazhi) {
    final int nazhi = totalNazhi.floor();
    final double vinadiTotal = (totalNazhi - nazhi) * 60.0;
    final int vinadi = vinadiTotal.round();
    return "$nazhi நாழிகை $vinadi வினாடி";
  }
}
