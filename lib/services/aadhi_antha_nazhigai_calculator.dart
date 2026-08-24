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
    const double nakSpan = 360.0 / 27.0; // 13.333333°
    const double padaSpan = nakSpan / 4.0; // 3.333333°

    final double normLong = moonLongitude % 360.0;
    final int nakIdx = (normLong / nakSpan).floor() % 27;
    final double offset = normLong - (nakIdx * nakSpan);
    final int pada = ((offset / padaSpan).floor()).clamp(0, 3) + 1;

    // Progress fraction (0.0 to 1.0) through the current Nakshatra
    final double fraction = (offset / nakSpan).clamp(0.0, 1.0);

    final double aadhi = fraction * standardParamaNazhigai;
    final double andha = (1.0 - fraction) * standardParamaNazhigai;

    return AadhiAnthaNazhigaiResult(
      moonLongitude: moonLongitude,
      nakshatraIndex: nakIdx,
      nakshatraNameTa: nakshatraNameTa,
      pada: pada,
      paramaNazhigaiTotal: standardParamaNazhigai,
      paramaNazhigaiFormatted: _formatNazhigai(standardParamaNazhigai),
      aadhiNazhigai: aadhi,
      aadhiNazhigaiFormatted: _formatNazhigai(aadhi),
      andhaNazhigai: andha,
      andhaNazhigaiFormatted: _formatNazhigai(andha),
      progressPercent: fraction * 100.0,
    );
  }

  static String _formatNazhigai(double totalNazhi) {
    final int nazhi = totalNazhi.floor();
    final double vinadiTotal = (totalNazhi - nazhi) * 60.0;
    final int vinadi = vinadiTotal.round();
    return "$nazhi நாழிகை $vinadi வினாடி";
  }
}
