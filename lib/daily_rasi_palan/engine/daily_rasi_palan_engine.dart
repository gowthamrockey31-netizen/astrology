import '../models/rasi_palan_models.dart';
import 'transit_calculator.dart';

/// Calculation and interpretation engine for Daily Rasi Palan.
///
/// Follows the authoritative Daily Horoscope rules based on:
/// 1. Selected date
/// 2. Planetary transits from existing AstroDashaCare engine
/// 3. House placement from Janma Rasi
/// 4. Planetary scoring system (base score 50, clamped 0..100)
class DailyRasiPalanEngine {
  /// Base score for daily horoscope
  static const int baseScore = 50;

  /// Calculates house position from Janma Rasi using the standard formula:
  /// house = ((transitRasi - birthRasi + 12) % 12) + 1
  static int calculateHouse({
    required int transitRasiIndex,
    required int birthRasiIndex,
  }) {
    return ((transitRasiIndex - birthRasiIndex + 12) % 12) + 1;
  }

  /// Calculates planetary score delta for a single planet based on its house from Janma Rasi
  static int calculatePlanetScore(String planetName, int house) {
    switch (planetName.toLowerCase()) {
      case 'jupiter':
        // Good houses: 2, 5, 7, 9, 11 (+8), other (-2)
        return const [2, 5, 7, 9, 11].contains(house) ? 8 : -2;

      case 'venus':
        // Good houses: 1, 2, 3, 4, 5, 8, 9, 11, 12 (+5), other (-3)
        return const [1, 2, 3, 4, 5, 8, 9, 11, 12].contains(house) ? 5 : -3;

      case 'mercury':
        // Good houses: 2, 4, 6, 8, 10, 11 (+5), other (-2)
        return const [2, 4, 6, 8, 10, 11].contains(house) ? 5 : -2;

      case 'sun':
        // Good houses: 3, 6, 10, 11 (+4), other (-3)
        return const [3, 6, 10, 11].contains(house) ? 4 : -3;

      case 'mars':
        // Good houses: 3, 6, 10, 11 (+5), other (-4)
        return const [3, 6, 10, 11].contains(house) ? 5 : -4;

      case 'saturn':
        // Good houses: 3, 6, 11 (+5), other (-5)
        return const [3, 6, 11].contains(house) ? 5 : -5;

      case 'rahu':
        // Good houses: 3, 6, 10, 11 (+4), other (-4)
        return const [3, 6, 10, 11].contains(house) ? 4 : -4;

      case 'ketu':
        // Good houses: 3, 6, 10, 11 (+3), other (-3)
        return const [3, 6, 10, 11].contains(house) ? 3 : -3;

      case 'moon':
        // Good houses: 1, 3, 6, 7, 10, 11 (+6), other (-4)
        return const [1, 3, 6, 7, 10, 11].contains(house) ? 6 : -4;

      default:
        return 0;
    }
  }

  /// Calculates star rating from score (0..100)
  static int calculateRating(int score) {
    if (score >= 80) return 5;
    if (score >= 60) return 4;
    if (score >= 40) return 3;
    if (score >= 20) return 2;
    return 1;
  }

  /// Generates the Daily Rasi Palan for a specific Rasi on the given date
  static DailyRasiPalan calculatePalan({
    required Rasi rasi,
    required DateTime date,
    List<PlanetTransit>? transits,
  }) {
    final effectiveTransits = transits ?? DailyTransitCalculator.getTransits(date: date);

    // Calculate house and score contribution for each transit planet
    final List<PlanetHousePosition> positions = [];
    int totalDelta = 0;

    for (final t in effectiveTransits) {
      final house = calculateHouse(
        transitRasiIndex: t.transitRasiIndex,
        birthRasiIndex: rasi.index,
      );
      final scoreContribution = calculatePlanetScore(t.planet, house);
      final isGood = scoreContribution > 0;

      positions.add(PlanetHousePosition(
        transit: t,
        house: house,
        isGoodHouse: isGood,
        scoreContribution: scoreContribution,
      ));

      totalDelta += scoreContribution;
    }

    // Clamp final score between 0 and 100
    final int score = (baseScore + totalDelta).clamp(0, 100);
    final int rating = calculateRating(score);

    // Helper map of planet to its house from Janma Rasi
    final Map<String, int> planetHouses = {};
    for (final p in positions) {
      planetHouses[p.transit.planet.toLowerCase()] = p.house;
    }

    // 1. General Prediction (பொதுப்பலன்)
    final String general;
    if (score >= 80) {
      general = 'இன்று மிகச் சிறப்பான நாளாக அமையும்.\nமுக்கிய முயற்சிகளில் வெற்றி கிடைக்கும்.';
    } else if (score >= 60) {
      general = 'இன்று சாதகமான முன்னேற்றம் கிடைக்கும்.\nதிட்டமிட்டு செயல்பட்டால் நல்ல பலன் உண்டு.';
    } else if (score >= 40) {
      general = 'இன்று கலவையான பலன்கள் கிடைக்கும்.\nஅவசர முடிவுகளை தவிர்ப்பது நல்லது.';
    } else {
      general = 'இன்று பொறுமையுடன் செயல்படுவது அவசியம்.\nமுக்கிய முடிவுகளை சிந்தித்து எடுக்கவும்.';
    }

    // 2. Career / Job (தொழில் / வேலை): Sun + Mars + Saturn + Mercury (Good: 3, 6, 10, 11)
    const careerGoodHouses = [3, 6, 10, 11];
    int careerScore = 0;
    final sunHouse = planetHouses['sun'] ?? 1;
    final marsHouse = planetHouses['mars'] ?? 1;
    final saturnHouse = planetHouses['saturn'] ?? 1;
    final mercuryHouse = planetHouses['mercury'] ?? 1;

    careerScore += careerGoodHouses.contains(sunHouse) ? 4 : -3;
    careerScore += careerGoodHouses.contains(marsHouse) ? 5 : -4;
    careerScore += careerGoodHouses.contains(saturnHouse) ? 5 : -5;
    careerScore += careerGoodHouses.contains(mercuryHouse) ? 5 : -2;

    final String career;
    if (careerScore > 10) {
      career = 'தொழில் மற்றும் வேலை விஷயங்களில் முன்னேற்றம் கிடைக்கும்.';
    } else if (careerScore < 0) {
      career = 'வேலை தொடர்பான முடிவுகளில் பொறுமை தேவை.';
    } else {
      career = 'தொழிலில் வழக்கமான நிலை இருக்கும்.';
    }

    // 3. Finance (பணவரவு): Jupiter + Venus + Mercury (Good: 2, 5, 9, 11)
    const financeGoodHouses = [2, 5, 9, 11];
    int financeScore = 0;
    final jupiterHouse = planetHouses['jupiter'] ?? 1;
    final venusHouse = planetHouses['venus'] ?? 1;

    financeScore += financeGoodHouses.contains(jupiterHouse) ? 8 : -2;
    financeScore += financeGoodHouses.contains(venusHouse) ? 5 : -3;
    financeScore += financeGoodHouses.contains(mercuryHouse) ? 5 : -2;

    final String finance;
    if (financeScore > 8) {
      finance = 'பணவரவு மற்றும் லாப வாய்ப்புகள் அதிகரிக்கும்.';
    } else if (financeScore < 0) {
      finance = 'தேவையற்ற செலவுகளை கட்டுப்படுத்துவது நல்லது.';
    } else {
      finance = 'பொருளாதார நிலை சீராக இருக்கும்.';
    }

    // 4. Love / Marriage (காதல் / திருமணம்): Venus + Moon (Good: 1, 5, 7, 9, 11)
    const loveGoodHouses = [1, 5, 7, 9, 11];
    int loveScore = 0;
    final moonHouse = planetHouses['moon'] ?? 1;

    loveScore += loveGoodHouses.contains(venusHouse) ? 5 : -3;
    loveScore += loveGoodHouses.contains(moonHouse) ? 6 : -4;

    final String love;
    if (loveScore > 5) {
      love = 'காதல் மற்றும் உறவுகளில் நல்ல புரிதல் ஏற்படும்.';
    } else if (loveScore < 0) {
      love = 'உணர்ச்சிவசப்பட்டு பேசுவதை தவிர்க்கவும்.';
    } else {
      love = 'உறவுகளில் சமநிலையை கடைபிடிக்கவும்.';
    }

    // 5. Family (குடும்பம்)
    const String family = 'குடும்ப உறுப்பினர்களுடன் ஆலோசித்து செயல்பட்டால் நல்லிணக்கம் அதிகரிக்கும்.';

    // 6. Health (ஆரோக்கியம்): Moon + Mars + Saturn (Good: 1, 3, 6, 11)
    const healthGoodHouses = [1, 3, 6, 11];
    int healthScore = 0;
    healthScore += healthGoodHouses.contains(moonHouse) ? 6 : -4;
    healthScore += healthGoodHouses.contains(marsHouse) ? 5 : -4;
    healthScore += healthGoodHouses.contains(saturnHouse) ? 5 : -5;

    final String health;
    if (healthScore < 0) {
      health = 'உடல் சோர்வை தவிர்க்க போதுமான ஓய்வு அவசியம்.';
    } else {
      health = 'உடல்நிலை பொதுவாக சீராக இருக்கும்.';
    }

    // 7. Education (கல்வி)
    const String education = 'மாணவர்கள் கவனத்துடன் படித்தால் நல்ல முன்னேற்றம் கிடைக்கும்.';

    // 8. Travel (பயணம்)
    const String travel = 'பயணத் திட்டங்களை முன்கூட்டியே அமைத்துக்கொள்வது நல்லது.';

    // 9. Lucky Color (அதிர்ஷ்ட நிறம்)
    final String luckyColor = rasi.luckyColor;

    // 10. Lucky Number (அதிர்ஷ்ட எண்): ((RasiNumber + Date.day) % 9) + 1
    final int luckyNumber = ((rasi.rasiNumber + date.day) % 9) + 1;

    // 11. Caution (கவனம்)
    final String caution;
    if (score < 40) {
      caution = 'அவசர முடிவுகள், தேவையற்ற வாக்குவாதங்களை தவிர்க்கவும்.';
    } else {
      caution = 'முக்கிய ஆவணங்களை கவனமாக சரிபார்க்கவும்.';
    }

    // 12. Remedy (பரிகாரம்)
    final String remedy = rasi.remedy;

    return DailyRasiPalan(
      rasi: rasi,
      date: date,
      score: score,
      rating: rating,
      general: general,
      career: career,
      finance: finance,
      love: love,
      family: family,
      health: health,
      education: education,
      travel: travel,
      luckyColor: luckyColor,
      luckyNumber: luckyNumber,
      caution: caution,
      remedy: remedy,
      planetPositions: positions,
    );
  }

  /// Generates Daily Horoscope for all 12 Rasis for the selected date
  static Map<int, DailyRasiPalan> calculateAllRasis({
    required DateTime date,
    List<PlanetTransit>? transits,
  }) {
    final effectiveTransits = transits ?? DailyTransitCalculator.getTransits(date: date);
    final Map<int, DailyRasiPalan> results = {};

    for (final rasi in Rasi.values) {
      results[rasi.index] = calculatePalan(
        rasi: rasi,
        date: date,
        transits: effectiveTransits,
      );
    }

    return results;
  }
}
