import '../models/dosham_result_model.dart';
import 'astrology_calculator.dart';

/// Calculation Service for Sevvai (Manglik / Kuja) Dosham with Classical Exceptions & Cancellations
class SevvaiDoshamCalculator {
  /// Check Sevvai Dosham from Lagna, Moon, and Venus
  static SevvaiDoshamResult calculateSevvaiDosham(Map<String, PlanetDetail> planets) {
    final mars = planets['Mars'];
    final lagna = planets['Lagna'];
    final moon = planets['Moon'];
    final venus = planets['Venus'];
    final jupiter = planets['Jupiter'];

    if (mars == null || lagna == null) {
      return const SevvaiDoshamResult(
        hasDosham: false,
        hasExemption: false,
        marsRasiIndex: 0,
        marsRasiTa: '',
        houseFromLagna: 1,
        houseFromMoon: 1,
        houseFromVenus: 1,
        isDoshamFromLagna: false,
        isDoshamFromMoon: false,
        isDoshamFromVenus: false,
        applicableRules: [],
        exemptionReasons: [],
        severityLevel: 'இல்லை',
        summaryTamil: 'செவ்வாய் தோஷம் இல்லை.',
      );
    }

    final int marsRasi = mars.rasiIndex;
    final int lagnaRasi = lagna.rasiIndex;
    final int moonRasi = moon?.rasiIndex ?? lagnaRasi;
    final int venusRasi = venus?.rasiIndex ?? lagnaRasi;

    // Houses 1-indexed (1..12)
    final int houseLagna = ((marsRasi - lagnaRasi + 12) % 12) + 1;
    final int houseMoon = ((marsRasi - moonRasi + 12) % 12) + 1;
    final int houseVenus = ((marsRasi - venusRasi + 12) % 12) + 1;

    // Classical Dosham houses in South Indian tradition: 1, 2, 4, 7, 8, 12
    const doshamHouses = [1, 2, 4, 7, 8, 12];

    final bool isLagnaDosham = doshamHouses.contains(houseLagna);
    final bool isMoonDosham = doshamHouses.contains(houseMoon);
    final bool isVenusDosham = doshamHouses.contains(houseVenus);

    final List<String> rules = [];
    if (isLagnaDosham) rules.add('லக்னத்திலிருந்து $houseLagna-ஆம் வீட்டில் செவ்வாய் அமர்வு');
    if (isMoonDosham) rules.add('சந்திரனிலிருந்து $houseMoon-ஆம் வீட்டில் செவ்வாய் அமர்வு');
    if (isVenusDosham) rules.add('சுக்கிரனிலிருந்து $houseVenus-ஆம் வீட்டில் செவ்வாய் அமர்வு');

    final bool rawHasDosham = isLagnaDosham || isMoonDosham || isVenusDosham;

    // Check Classical Exceptions / Cancellations (தோஷ நிவர்த்திகள்):
    // 1. Mars in own signs (Aries=0, Scorpio=7)
    // 2. Mars exalted in Capricorn=9
    // 3. Mars debilitated in Cancer=3 (Loses strength to afflict)
    // 4. Conjoined with Jupiter (Guru Mangala Yoga) or Moon (Chandra Mangala Yoga)
    // 5. Jupiter aspects Mars (5th, 7th, 9th aspect)
    // 6. Mars in Leo (Simmam) or Sagittarius (Dhanusu)
    final List<String> exemptions = [];

    if (marsRasi == 0 || marsRasi == 7) {
      exemptions.add('செவ்வாய் சொந்த வீட்டில் (மேஷம்/விருச்சிகம்) ஆட்சி பெற்றுள்ளதால் தோஷ நிவர்த்தி.');
    }
    if (marsRasi == 9) {
      exemptions.add('செவ்வாய் மகரத்தில் உச்சம் பெற்றுள்ளதால் தோஷ நிவர்த்தி.');
    }
    if (marsRasi == 4 || marsRasi == 8) {
      exemptions.add('செவ்வாய் சிம்மம் அல்லது தனுசு ராசியில் இருப்பதால் தோஷ பங்க நிவர்த்தி.');
    }

    if (jupiter != null) {
      final int distJupMars = ((marsRasi - jupiter.rasiIndex + 12) % 12) + 1;
      if (distJupMars == 1) {
        exemptions.add('குரு - செவ்வாய் சேர்க்கை (குரு மங்கள யோகம்) தோஷத்தை முழுமையாக போக்குகிறது.');
      } else if (distJupMars == 5 || distJupMars == 7 || distJupMars == 9) {
        exemptions.add('சுப கிரகமான குருவின் நேரடி பார்வை செவ்வாய் மீது விழுவதால் தோஷம் நிவர்த்தியாகிறது.');
      }
    }

    if (moon != null && moon.rasiIndex == marsRasi) {
      exemptions.add('சந்திர மங்கள யோகம் காரணமாக செவ்வாய் தோஷ வீரியம் குறைகிறது.');
    }

    final bool hasExemption = exemptions.isNotEmpty;
    final bool finalHasDosham = rawHasDosham && !hasExemption;

    String severity;
    String summary;

    if (!rawHasDosham) {
      severity = 'இல்லை (None)';
      summary = 'இந்த ஜாதகத்தில் செவ்வாய் சுப ஸ்தானங்களில் இருப்பதால் செவ்வாய் தோஷம் எதுவும் இல்லை.';
    } else if (hasExemption) {
      severity = 'நிவர்த்தி (Cancelled)';
      summary =
          'ஜாதகத்தில் செவ்வாய் தோஷ ஸ்தானத்தில் இருந்தாலும், விதிவிலக்குகள் மற்றும் சுப கிரக பார்வைகளால் தோஷம் முழுமையாக நிவர்த்தி அடைந்துள்ளது.';
    } else if (isLagnaDosham && isMoonDosham) {
      severity = 'தீவிரம் (High)';
      summary =
          'லக்னம் மற்றும் சந்திரன் இரண்டிலிருந்தும் செவ்வாய் தோஷ ஸ்தானத்தில் உள்ளார். அதே அமைப்பிலுள்ள ஜாதகத்தை இணைப்பது உத்தமம்.';
    } else {
      severity = 'மத்திமம் (Moderate)';
      summary =
          'செவ்வாய் தோஷ அமைப்பு காணப்படுகிறது. பொருத்தமான செவ்வாய் அமைப்பிலுள்ள ஜாதகத்தை தேர்ந்தெடுப்பது நன்று.';
    }

    return SevvaiDoshamResult(
      hasDosham: finalHasDosham,
      hasExemption: hasExemption,
      marsRasiIndex: marsRasi,
      marsRasiTa: mars.rasiNameTa,
      houseFromLagna: houseLagna,
      houseFromMoon: houseMoon,
      houseFromVenus: houseVenus,
      isDoshamFromLagna: isLagnaDosham,
      isDoshamFromMoon: isMoonDosham,
      isDoshamFromVenus: isVenusDosham,
      applicableRules: rules,
      exemptionReasons: exemptions,
      severityLevel: severity,
      summaryTamil: summary,
    );
  }
}
