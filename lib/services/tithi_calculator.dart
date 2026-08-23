class TithiDetail {
  final int tithiNumber; // 1 to 30 (1..15 Shukla Paksha, 16..30 Krishna Paksha)
  final String tithiNameEn;
  final String tithiNameTa;
  final String pakshaEn;
  final String pakshaTa;
  final List<String> soonyamRasisEn;
  final List<String> soonyamRasisTa;

  bool get isShuklaPaksha => tithiNumber <= 15;

  TithiDetail({
    required this.tithiNumber,
    required this.tithiNameEn,
    required this.tithiNameTa,
    required this.pakshaEn,
    required this.pakshaTa,
    required this.soonyamRasisEn,
    required this.soonyamRasisTa,
  });
}

class TithiCalculator {
  static const List<String> tithiNamesEn = [
    'Prathamai', 'Dwithiyai', 'Thrithiyai', 'Chathurthi', 'Panchami',
    'Shashti', 'Sapthami', 'Ashtami', 'Navami', 'Dasami',
    'Ekadashi', 'Dwadashi', 'Trayodashi', 'Chaturdashi', 'Full Moon / New Moon'
  ];

  static const List<String> tithiNamesTa = [
    'பிரதமை', 'த்விதியை', 'த்ரிதியை', 'சதுர்த்தி', 'பஞ்சமி',
    'ஷஷ்டி', 'சப்தமி', 'அஷ்டமி', 'நவமி', 'தசமி',
    'ஏகாதசி', 'துவாதசி', 'திரயோதசி', 'சதுர்தசி', 'பௌர்ணமி / அமாவாசை'
  ];

  /// Mapping from Tithi index (1..14) to Tithi Soonyam Rasis (English & Tamil)
  static final Map<int, Map<String, List<String>>> _soonyamMapping = {
    1: {'en': ['Libra', 'Capricorn'], 'ta': ['துலாம்', 'மகரம்']},
    2: {'en': ['Sagittarius', 'Pisces'], 'ta': ['தனுசு', 'மீனம்']},
    3: {'en': ['Capricorn', 'Leo'], 'ta': ['மகரம்', 'சிம்மம்']},
    4: {'en': ['Aquarius', 'Taurus'], 'ta': ['கும்பம்', 'ரிஷபம்']},
    5: {'en': ['Gemini', 'Virgo'], 'ta': ['மிதுனம்', 'கன்னி']},
    6: {'en': ['Aries', 'Leo'], 'ta': ['மேஷம்', 'சிம்மம்']},
    7: {'en': ['Cancer', 'Sagittarius'], 'ta': ['கடகம்', 'தனுசு']},
    8: {'en': ['Gemini', 'Virgo'], 'ta': ['மிதுனம்', 'கன்னி']},
    9: {'en': ['Leo', 'Scorpio'], 'ta': ['சிம்மம்', 'விருச்சிகம்']},
    10: {'en': ['Leo', 'Scorpio'], 'ta': ['சிம்மம்', 'விருச்சிகம்']},
    11: {'en': ['Sagittarius', 'Pisces'], 'ta': ['தனுசு', 'மீனம்']},
    12: {'en': ['Libra', 'Capricorn'], 'ta': ['துலாம்', 'மகரம்']},
    13: {'en': ['Taurus', 'Leo'], 'ta': ['ரிஷபம்', 'சிம்மம்']},
    14: {'en': ['Gemini', 'Virgo', 'Sagittarius', 'Pisces'], 'ta': ['மிதுனம்', 'கன்னி', 'தனுசு', 'மீனம்']},
  };

  /// Calculate Tithi from Sun and Moon sidereal longitudes
  static TithiDetail calculateTithi({
    required double sunLongitude,
    required double moonLongitude,
  }) {
    double diff = moonLongitude - sunLongitude;
    if (diff < 0) diff += 360.0;

    int tithiNum = (diff / 12.0).floor() + 1; // 1 to 30
    if (tithiNum > 30) tithiNum = 30;

    final isShukla = tithiNum <= 15;
    final pakshaEn = isShukla ? 'Shukla Paksha' : 'Krishna Paksha';
    final pakshaTa = isShukla ? 'சுக்ல பக்ஷம்' : 'கிருஷ்ண பக்ஷம்';

    final tithiIdx = (tithiNum % 15 == 0) ? 14 : (tithiNum % 15) - 1;
    final tithiNameEn = (tithiNum == 15) ? 'Purnima' : (tithiNum == 30) ? 'Amavasya' : tithiNamesEn[tithiIdx];
    final tithiNameTa = (tithiNum == 15) ? 'பௌர்ணமி' : (tithiNum == 30) ? 'அமாவாசை' : tithiNamesTa[tithiIdx];

    final soonyamKey = (tithiNum % 15 == 0) ? 0 : (tithiNum % 15);
    final soonyamMap = _soonyamMapping[soonyamKey] ?? {'en': [], 'ta': []};

    return TithiDetail(
      tithiNumber: tithiNum,
      tithiNameEn: tithiNameEn,
      tithiNameTa: tithiNameTa,
      pakshaEn: pakshaEn,
      pakshaTa: pakshaTa,
      soonyamRasisEn: soonyamMap['en']!,
      soonyamRasisTa: soonyamMap['ta']!,
    );
  }

  /// Get TithiDetail for a specific manual Tithi selection (1..15)
  static TithiDetail getTithiByNumber(int tithiNumber) {
    final t = (tithiNumber < 1) ? 1 : (tithiNumber > 15 ? 15 : tithiNumber);
    final soonyamMap = _soonyamMapping[t] ?? {'en': [], 'ta': []};

    return TithiDetail(
      tithiNumber: t,
      tithiNameEn: tithiNamesEn[t - 1],
      tithiNameTa: tithiNamesTa[t - 1],
      pakshaEn: 'Shukla / Krishna',
      pakshaTa: 'பக்ஷம்',
      soonyamRasisEn: soonyamMap['en']!,
      soonyamRasisTa: soonyamMap['ta']!,
    );
  }
}
