import '../models/tara_balam_model.dart';
import 'astrology_calculator.dart';

/// Service for calculating 9 Tara Balam categories and interpretations
class TaraBalaCalculator {
  /// Master list of 27 Nakshatras in Tamil (reused from AstrologyCalculator)
  static List<String> get nakshatras => AstrologyCalculator.nakshatrasTa;

  /// Traditional 9 Tara names in Tamil
  static const List<String> taraNames = [
    "ஜன்ம தாரா",
    "சம்பத் தாரா",
    "விபத் தாரா",
    "க்ஷேம தாரா",
    "பிரத்யக் தாரா",
    "சாதக தாரா",
    "நைதன தாரா",
    "மித்ர தாரா",
    "பரம மித்ர தாரா",
  ];

  /// Tara Nature in Tamil
  static const List<String> taraNature = [
    "சாதாரணம்",
    "நன்மை",
    "தவிர்க்க வேண்டியது",
    "நன்மை",
    "சிரமம்",
    "நன்மை",
    "மிகவும் சிரமம்",
    "நன்மை",
    "மிகவும் நன்மை",
  ];

  /// Reference Tara Result interpretations in Tamil
  static const List<String> taraResult = [
    "மனநிலை மற்றும் உடல்நிலையில் கவனம் தேவை.",
    "செல்வம், பொருளாதாரம் மற்றும் வளர்ச்சிக்கு சாதகம்.",
    "தடைகள், செலவுகள் மற்றும் பிரச்சினைகள் ஏற்படலாம்.",
    "ஆரோக்கியம், பாதுகாப்பு மற்றும் நலனுக்கு சாதகம்.",
    "மனக்குழப்பம் மற்றும் தடைகள் ஏற்படலாம்.",
    "முயற்சிகளில் வெற்றி கிடைக்க வாய்ப்பு.",
    "இழப்பு மற்றும் சிரமங்களைத் தவிர்ப்பது நல்லது.",
    "நண்பர்கள் மற்றும் உறவுகள் மூலம் நன்மை.",
    "மிகச் சிறந்த ஆதரவு மற்றும் வெற்றிக்கான வாய்ப்பு.",
  ];

  /// Calculate Tara Balam given 1-indexed (1..27) or 0-indexed nakshatra numbers
  static TaraResult calculate({
    required int birthNakshatra, // 1..27 or 0..26
    required int currentNakshatra, // 1..27 or 0..26
    bool isOneBased = true,
  }) {
    final int bIndex = isOneBased ? (birthNakshatra - 1) : birthNakshatra;
    final int cIndex = isOneBased ? (currentNakshatra - 1) : currentNakshatra;

    // Safety bounds check
    final safeBIndex = bIndex.clamp(0, 26);
    final safeCIndex = cIndex.clamp(0, 26);

    // Count distance between birth star and target/current star (1 to 27)
    final int count = ((safeCIndex - safeBIndex + 27) % 27) + 1;

    // 9 Tara cycle index (0 to 8)
    final int taraIndex = (count - 1) % 9;

    final String bName = safeBIndex < nakshatras.length ? nakshatras[safeBIndex] : 'அஸ்வினி';
    final String cName = safeCIndex < nakshatras.length ? nakshatras[safeCIndex] : 'அஸ்வினி';

    return TaraResult(
      birthNakshatraIndex: safeBIndex,
      currentNakshatraIndex: safeCIndex,
      birthNakshatraName: bName,
      currentNakshatraName: cName,
      count: count,
      taraNumber: taraIndex + 1,
      taraName: taraNames[taraIndex],
      nature: taraNature[taraIndex],
      result: taraResult[taraIndex],
    );
  }
}
