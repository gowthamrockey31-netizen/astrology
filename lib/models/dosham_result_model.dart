/// Result of Sevvai (Manglik) Dosham Analysis
class SevvaiDoshamResult {
  final bool hasDosham;
  final bool hasExemption;
  final int marsRasiIndex;
  final String marsRasiTa;
  
  // Placements from reference points
  final int houseFromLagna; // 1..12
  final int houseFromMoon;  // 1..12
  final int houseFromVenus; // 1..12
  
  final bool isDoshamFromLagna;
  final bool isDoshamFromMoon;
  final bool isDoshamFromVenus;
  
  final List<String> applicableRules;
  final List<String> exemptionReasons;
  final String severityLevel; // 'இல்லை' (None), 'குறைவு' (Mild), 'மத்திமம்' (Medium), 'தீவிரம்' (High), 'நிவர்த்தி' (Cancelled)
  final String summaryTamil;

  const SevvaiDoshamResult({
    required this.hasDosham,
    required this.hasExemption,
    required this.marsRasiIndex,
    required this.marsRasiTa,
    required this.houseFromLagna,
    required this.houseFromMoon,
    required this.houseFromVenus,
    required this.isDoshamFromLagna,
    required this.isDoshamFromMoon,
    required this.isDoshamFromVenus,
    required this.applicableRules,
    required this.exemptionReasons,
    required this.severityLevel,
    required this.summaryTamil,
  });
}

/// Result of Rahu Ketu / Sarpa / Kalasarpa Dosham Analysis
class RahuKetuDoshamResult {
  final bool hasKalasarpaDosham;
  final bool hasSarpaDosham;
  final String kalasarpaTypeTa; // அனந்த காலசர்ப்பம், குளிக, வாசுகி, சங்குபால, பத்ம, மகாபத்ம, தக்ஷக, கார்கோடக, சங்கசூட, பாதக, விஷதரன், சேஷநாகம்
  final String kalasarpaDirectionTa; // 'ராகு முதல் கேது வரை (அனுலோம)' / 'கேது முதல் ராகு வரை (விலோம)'
  
  final int rahuHouseFromLagna;
  final int ketuHouseFromLagna;
  final String rahuRasiTa;
  final String ketuRasiTa;
  
  final List<String> doshamDetails;
  final List<String> remedies;
  final String summaryTamil;

  const RahuKetuDoshamResult({
    required this.hasKalasarpaDosham,
    required this.hasSarpaDosham,
    required this.kalasarpaTypeTa,
    required this.kalasarpaDirectionTa,
    required this.rahuHouseFromLagna,
    required this.ketuHouseFromLagna,
    required this.rahuRasiTa,
    required this.ketuRasiTa,
    required this.doshamDetails,
    required this.remedies,
    required this.summaryTamil,
  });
}
