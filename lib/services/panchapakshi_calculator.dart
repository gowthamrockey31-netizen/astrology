import 'astrology_calculator.dart';
import 'tithi_calculator.dart';

class PanchapakshiBirdInfo {
  final String nameTa;
  final String nameEn;
  final String symbol;
  final String description;

  const PanchapakshiBirdInfo({
    required this.nameTa,
    required this.nameEn,
    required this.symbol,
    required this.description,
  });
}

class PanchapakshiActivityResult {
  final PanchapakshiBirdInfo bird;
  final String currentActivityTa;
  final String currentActivityEn;
  final int powerPercentage;
  final bool isAuspicious;
  final int currentYamamIndex; // 1..5
  final String yamamTimeRange;

  const PanchapakshiActivityResult({
    required this.bird,
    required this.currentActivityTa,
    required this.currentActivityEn,
    required this.powerPercentage,
    required this.isAuspicious,
    required this.currentYamamIndex,
    required this.yamamTimeRange,
  });
}

class PanchapakshiCalculator {
  static const List<PanchapakshiBirdInfo> birds = [
    PanchapakshiBirdInfo(nameTa: 'வல்லூறு', nameEn: 'Vulture / Hawk', symbol: '🦅', description: 'வல்லமை, வேகம் மற்றும் தைரியம்'),
    PanchapakshiBirdInfo(nameTa: 'ஆந்தை', nameEn: 'Owl', symbol: '🦉', description: 'நுண்ணறிவு, அமைதி மற்றும் ரகசியம்'),
    PanchapakshiBirdInfo(nameTa: 'காகம்', nameEn: 'Crow', symbol: '🐦‍⬛', description: 'சுறுசுறுப்பு மற்றும் எச்சரிக்கை'),
    PanchapakshiBirdInfo(nameTa: 'கோழி', nameEn: 'Rooster / Fowl', symbol: '🐓', description: 'நேர்மை, விழிப்புணர்வு மற்றும் வேகம்'),
    PanchapakshiBirdInfo(nameTa: 'மயில்', nameEn: 'Peacock', symbol: '🦚', description: 'அழகு, செல்வாக்கு மற்றும் வெற்றி'),
  ];

  static const List<Map<String, dynamic>> activities = [
    {'ta': 'அரசு', 'en': 'Ruling / Crown', 'power': 100, 'good': true},
    {'ta': 'ஊண்', 'en': 'Eating / Feeding', 'power': 80, 'good': true},
    {'ta': 'நடை', 'en': 'Walking / Motion', 'power': 50, 'good': true},
    {'ta': 'துயில்', 'en': 'Sleeping / Rest', 'power': 20, 'good': false},
    {'ta': 'சாவு', 'en': 'Dying / Inactive', 'power': 0, 'good': false},
  ];

  /// Determine Birth Bird based on Nakshatra Index (0..26) and Paksha (Shukla/Krishna)
  static PanchapakshiBirdInfo getBirthBird({
    required int nakshatraIndex,
    required bool isShuklaPaksha,
  }) {
    int birdIndex = 0;
    final nak = nakshatraIndex % 27;

    if (isShuklaPaksha) {
      if (nak <= 4) birdIndex = 0;      // Ashwini to Mrigashira -> Valluru
      else if (nak <= 10) birdIndex = 1; // Ardra to Purva Phalguni -> Aandhai
      else if (nak <= 15) birdIndex = 2; // Uttara Phalguni to Vishakha -> Kaagam
      else if (nak <= 20) birdIndex = 3; // Anuradha to Uttara Ashadha -> Kozhi
      else birdIndex = 4;                // Shravana to Revati -> Mayil
    } else {
      if (nak <= 4) birdIndex = 4;       // Mayil
      else if (nak <= 10) birdIndex = 3; // Kozhi
      else if (nak <= 15) birdIndex = 2; // Kaagam
      else if (nak <= 20) birdIndex = 1; // Aandhai
      else birdIndex = 0;                // Valluru
    }

    return birds[birdIndex];
  }

  /// Calculate live Panchapakshi activity for a target moment
  static PanchapakshiActivityResult calculateCurrentActivity({
    required int nakshatraIndex,
    required bool isShuklaPaksha,
    DateTime? targetTime,
  }) {
    final now = targetTime ?? DateTime.now();
    final bird = getBirthBird(nakshatraIndex: nakshatraIndex, isShuklaPaksha: isShuklaPaksha);

    // Sunrise & Sunset for the day
    final sunrise = DateTime(now.year, now.month, now.day, 6, 0);
    final sunset = DateTime(now.year, now.month, now.day, 18, 0);

    final isDay = !now.isBefore(sunrise) && now.isBefore(sunset);
    final baseTime = isDay ? sunrise : sunset;

    // Yamam calculation (5 Yamams in 12 hours = 2h 24m per Yamam = 144 mins)
    final diffMinutes = now.difference(baseTime).inMinutes.abs();
    final yamamIndex = (diffMinutes / 144).floor().clamp(0, 4);

    // Time range text
    final startYamamTime = baseTime.add(Duration(minutes: yamamIndex * 144));
    final endYamamTime = baseTime.add(Duration(minutes: (yamamIndex + 1) * 144));
    final timeRangeStr = "${_formatTime(startYamamTime)} - ${_formatTime(endYamamTime)}";

    // Activity index offset based on bird index and yamam
    final birdIdx = birds.indexWhere((b) => b.nameTa == bird.nameTa);
    final actIdx = (birdIdx + yamamIndex + (now.weekday % 5)) % 5;
    final actMap = activities[actIdx];

    return PanchapakshiActivityResult(
      bird: bird,
      currentActivityTa: actMap['ta'] as String,
      currentActivityEn: actMap['en'] as String,
      powerPercentage: actMap['power'] as int,
      isAuspicious: actMap['good'] as bool,
      currentYamamIndex: yamamIndex + 1,
      yamamTimeRange: timeRangeStr,
    );
  }

  static String _formatTime(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return "$h:$m $ampm";
  }
}
