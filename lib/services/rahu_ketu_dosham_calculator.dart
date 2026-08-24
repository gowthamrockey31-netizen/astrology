import '../models/dosham_result_model.dart';
import 'astrology_calculator.dart';

/// Calculation Service for Rahu Ketu / Sarpa / Kalasarpa Dosham
class RahuKetuDoshamCalculator {
  static const List<String> kalasarpaNames = [
    'அனந்த காலசர்ப்ப தோஷம் (1-7 அச்சு)',
    'குளிக காலசர்ப்ப தோஷம் (2-8 அச்சு)',
    'வாசுகி காலசர்ப்ப தோஷம் (3-9 அச்சு)',
    'சங்குபால காலசர்ப்ப தோஷம் (4-10 அச்சு)',
    'பத்ம காலசர்ப்ப தோஷம் (5-11 அச்சு)',
    'மகாபத்ம காலசர்ப்ப தோஷம் (6-12 அச்சு)',
    'தக்ஷக காலசர்ப்ப தோஷம் (7-1 அச்சு)',
    'கார்கோடக காலசர்ப்ப தோஷம் (8-2 அச்சு)',
    'சங்கசூட காலசர்ப்ப தோஷம் (9-3 அச்சு)',
    'பாதக காலசர்ப்ப தோஷம் (10-4 அச்சு)',
    'விஷதரன் காலசர்ப்ப தோஷம் (11-5 அச்சு)',
    'சேஷநாக காலசர்ப்ப தோஷம் (12-6 அச்சு)',
  ];

  /// Calculate Rahu-Ketu and Kalasarpa Dosham
  static RahuKetuDoshamResult calculateRahuKetuDosham(Map<String, PlanetDetail> planets) {
    final rahu = planets['Rahu'];
    final ketu = planets['Ketu'];
    final lagna = planets['Lagna'];

    if (rahu == null || ketu == null || lagna == null) {
      return const RahuKetuDoshamResult(
        hasKalasarpaDosham: false,
        hasSarpaDosham: false,
        kalasarpaTypeTa: 'இல்லை',
        kalasarpaDirectionTa: 'இல்லை',
        rahuHouseFromLagna: 1,
        ketuHouseFromLagna: 7,
        rahuRasiTa: '',
        ketuRasiTa: '',
        doshamDetails: [],
        remedies: [],
        summaryTamil: 'ராகு கேது தோஷம் இல்லை.',
      );
    }

    final int lagnaRasi = lagna.rasiIndex;
    final int rahuRasi = rahu.rasiIndex;
    final int ketuRasi = ketu.rasiIndex;

    final int rahuHouse = ((rahuRasi - lagnaRasi + 12) % 12) + 1;
    final int ketuHouse = ((ketuRasi - lagnaRasi + 12) % 12) + 1;

    // Check Kalasarpa Dosham: Are all 7 classical planets (Sun, Moon, Mars, Mercury, Jupiter, Venus, Saturn)
    // enclosed between Rahu and Ketu?
    final planetKeys = ['Sun', 'Moon', 'Mars', 'Mercury', 'Jupiter', 'Venus', 'Saturn'];
    
    bool allBetweenRahuToKetu = true;
    bool allBetweenKetuToRahu = true;

    for (final k in planetKeys) {
      final p = planets[k];
      if (p == null) continue;
      
      final int distFromRahu = (p.rasiIndex - rahuRasi + 12) % 12;
      final int distFromKetu = (p.rasiIndex - ketuRasi + 12) % 12;

      // 0 to 6 means within the hemisphere
      if (distFromRahu > 6) allBetweenRahuToKetu = false;
      if (distFromKetu > 6) allBetweenKetuToRahu = false;
    }

    final bool hasKalasarpa = allBetweenRahuToKetu || allBetweenKetuToRahu;
    final String direction = allBetweenRahuToKetu
        ? 'அனுலோம காலசர்ப்பம் (ராகு முதல் கேது வரை)'
        : (allBetweenKetuToRahu ? 'விலோம காலசர்ப்பம் (கேது முதல் ராகு வரை)' : 'இல்லை');

    final String kalaType = hasKalasarpa
        ? kalasarpaNames[(rahuHouse - 1).clamp(0, 11)]
        : 'காலசர்ப்ப தோஷம் அமையவில்லை';

    // Check Sarpa / Naga Dosham: Rahu/Ketu in 1, 2, 5, 7, 8 houses
    final List<int> sarpaHouses = [1, 2, 5, 7, 8];
    final bool hasSarpa = sarpaHouses.contains(rahuHouse) || sarpaHouses.contains(ketuHouse);

    final List<String> details = [];
    if (hasKalasarpa) {
      details.add('அனைத்து கிரகங்களும் ராகு-கேது பிடியில் உள்ளதால் $kalaType உருவாகிறது.');
    }
    if (rahuHouse == 1 || ketuHouse == 1) {
      details.add('ஜென்ம லக்னத்தில் ராகு/கேது அமர்வு (1-7 அச்சு தோஷம்).');
    }
    if (rahuHouse == 2 || ketuHouse == 2) {
      details.add('இரண்டாம் வீட்டில் ராகு/கேது (குடும்பம் மற்றும் வாக்கு ஸ்தான தோஷம்).');
    }
    if (rahuHouse == 5 || ketuHouse == 5) {
      details.add('ஐந்தாம் வீட்டில் ராகு/கேது (புத்திர ஸ்தான சர்ப்ப தோஷம்).');
    }
    if (rahuHouse == 7 || ketuHouse == 7) {
      details.add('ஏழாம் வீட்டில் ராகு/கேது (களத்திர ஸ்தான தோஷம்).');
    }
    if (rahuHouse == 8 || ketuHouse == 8) {
      details.add('எட்டாம் வீட்டில் ராகு/கேது (மாங்கல்ய / ஆயுள் ஸ்தான சர்ப்ப தோஷம்).');
    }

    final List<String> remedies = [
      'திருக்காளஹஸ்தி அல்லது திருநாகேஸ்வரம் அல்லது கீழப்பெரும்பள்ளம் ஆலய வழிபாடு.',
      'தினசரி நாகராஜர் காயத்ரி அல்லது துர்கா கவசம் பாராயணம் செய்தல்.',
      'பிரதோஷ காலத்தில் சிவபெருமானுக்கு பால் அபிஷேகம் செய்து வழிபடுதல்.',
    ];

    String summary;
    if (hasKalasarpa && hasSarpa) {
      summary =
          'ஜாதகத்தில் $kalaType மற்றும் சர்ப்ப தோஷ அமைப்பு காணப்படுகிறது. 33 வயது வரை போராட்டங்களுக்குப் பின் சிறந்த முன்னேற்றம் தரும்.';
    } else if (hasKalasarpa) {
      summary = 'ஜாதகத்தில் $kalaType காணப்படுகிறது.';
    } else if (hasSarpa) {
      summary = 'ஜாதகத்தில் சர்ப்ப தோஷ அமைப்பு உள்ளது. எளிய பரிகாரங்கள் மூலம் நற்பலன் பெறலாம்.';
    } else {
      summary = 'ஜாதகத்தில் கடுமையான ராகு-கேது அல்லது காலசர்ப்ப தோஷங்கள் எதுவும் அமையவில்லை.';
    }

    return RahuKetuDoshamResult(
      hasKalasarpaDosham: hasKalasarpa,
      hasSarpaDosham: hasSarpa,
      kalasarpaTypeTa: kalaType,
      kalasarpaDirectionTa: direction,
      rahuHouseFromLagna: rahuHouse,
      ketuHouseFromLagna: ketuHouse,
      rahuRasiTa: rahu.rasiNameTa,
      ketuRasiTa: ketu.rasiNameTa,
      doshamDetails: details,
      remedies: remedies,
      summaryTamil: summary,
    );
  }
}
