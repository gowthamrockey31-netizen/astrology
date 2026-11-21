import '../models/porutham_model.dart';

/// Dedicated calculator for Bhava Samyam Dhosham (பாவசம்யம் தோஷம்)
/// Based on classical South Indian astrological system and reference literature (Siddhayogi Sivadasan Ravi p. 69)
class BhavaSamyamCalculator {
  static const List<int> targetHouses = [1, 2, 4, 7, 8, 12];

  // Malefic planets considered for Papa / Bhava Dosham
  static const Map<String, String> maleficSymbols = {
    'Sun': 'சூ',
    'Mars': 'செ',
    'Saturn': 'சனி',
    'Rahu': 'ரா',
    'Ketu': 'கே',
  };

  /// Calculate Bhava Samyam from male and female horoscope data
  static BhavaSamyamResult calculate({
    dynamic maleAstroData,
    dynamic femaleAstroData,
  }) {
    if (maleAstroData == null || femaleAstroData == null) {
      return const BhavaSamyamResult(
        status: PoruthamStatus.notCalculated,
        titleTa: 'பாவசம்யம் தோஷம் (Bhava Samyam Dhosham)',
        statusTextTa: 'பிறந்த விவரங்கள் தேவை',
        descriptionTa: 'பாவ சாம்ய தோஷத்தை முழுமையாக கணக்கிட ஆண் மற்றும் பெண் இருவரின் பிறந்த தேதி, நேரம் மற்றும் ஊர் விவரங்கள் (Mode A) அவசியம். மேனுவல் முறையில் லக்னம் மற்றும் சுக்கிரன் விவரங்கள் இல்லாததால் இது கணிக்க இயலாது.',
        isPending: false,
        hasDetailedData: false,
      );
    }

    try {
      final maleChart = _computeChartFromAstroData(
        titleTa: 'ஆண் ஜாதகத்தில் பாவதோச அளவு:',
        astroData: maleAstroData,
      );

      final femaleChart = _computeChartFromAstroData(
        titleTa: 'பெண் ஜாதகத்தில் பாவ தோச அளவு:',
        astroData: femaleAstroData,
      );

      return _evaluateCharts(maleChart, femaleChart);
    } catch (e) {
      return BhavaSamyamResult(
        status: PoruthamStatus.notCalculated,
        titleTa: 'பாவசம்யம் தோஷம் (Bhava Samyam Dhosham)',
        statusTextTa: 'கணக்கீட்டுப் பிழை',
        descriptionTa: 'பாவசாம்ய தோஷம் கணக்கிடுவதில் பிழை ஏற்பட்டது: $e',
        isPending: false,
        hasDetailedData: false,
      );
    }
  }

  /// Direct calculation from sign positions (0..11) for testing & explicit charts (e.g. Page 69 Benchmark)
  static BhavaSamyamResult calculateFromRasiPositions({
    required int maleLagnaRasi,
    required int maleMoonRasi,
    required int maleVenusRasi,
    required Map<String, int> maleMaleficRasis,
    required int femaleLagnaRasi,
    required int femaleMoonRasi,
    required int femaleVenusRasi,
    required Map<String, int> femaleMaleficRasis,
  }) {
    final maleChart = _computeChartFromRasis(
      titleTa: 'ஆண் ஜாதகத்தில் பாவதோச அளவு:',
      lagnaRasi: maleLagnaRasi,
      moonRasi: maleMoonRasi,
      venusRasi: maleVenusRasi,
      maleficRasis: maleMaleficRasis,
    );

    final femaleChart = _computeChartFromRasis(
      titleTa: 'பெண் ஜாதகத்தில் பாவ தோச அளவு:',
      lagnaRasi: femaleLagnaRasi,
      moonRasi: femaleMoonRasi,
      venusRasi: femaleVenusRasi,
      maleficRasis: femaleMaleficRasis,
    );

    return _evaluateCharts(maleChart, femaleChart);
  }

  static BhavaSamyamResult _evaluateCharts(
    BhavaDoshamChartData maleChart,
    BhavaDoshamChartData femaleChart,
  ) {
    final maleTotal = maleChart.totalAmount;
    final femaleTotal = femaleChart.totalAmount;
    final diff = (maleTotal - femaleTotal).abs();
    final diffStr = formatFraction(diff);

    PoruthamStatus status;
    String statusText;
    String conclusion;

    if (maleTotal > femaleTotal) {
      status = PoruthamStatus.matched;
      statusText = 'பொருந்தும்';
      conclusion = 'ஆணுக்கு பெண்ணைவிட பாவதோச அளவு அதிகமாக உள்ளதால் ஜாதகங்கள் பொருந்தும்.';
    } else if (maleTotal == femaleTotal) {
      status = PoruthamStatus.matched;
      statusText = 'சம பலன் (பொருந்தும்)';
      conclusion = 'இருவருக்கும் பாவதோச அளவு சமமாக உள்ளதால் ஜாதகங்கள் பொருந்தும்.';
    } else {
      status = PoruthamStatus.notMatched;
      statusText = 'பொருந்தாது';
      conclusion = 'பெண்ணுக்கு ஆணைவிட பாவதோச அளவு அதிகமாக உள்ளதால் பாவசாம்ய தோஷப்படி பொருந்தாது.';
    }

    return BhavaSamyamResult(
      status: status,
      titleTa: 'பாவசம்யம் தோஷம் (Bhava Samyam Dhosham)',
      statusTextTa: statusText,
      descriptionTa: conclusion,
      isPending: false,
      hasDetailedData: true,
      maleChart: maleChart,
      femaleChart: femaleChart,
      difference: diff,
      differenceStr: diffStr,
      comparisonConclusionTa: conclusion,
    );
  }

  static BhavaDoshamChartData _computeChartFromAstroData({
    required String titleTa,
    required dynamic astroData,
  }) {
    final lagnaRasi = _extractRasi(astroData.lagna ?? astroData['lagna']);
    final moonRasi = _extractRasi(astroData.moon ?? astroData['moon']);

    final planetsMap = astroData.planets ?? astroData['planets'];
    final venusRasi = _extractRasi(planetsMap['Venus']);

    final maleficRasis = <String, int>{};
    for (final name in maleficSymbols.keys) {
      maleficRasis[name] = _extractRasi(planetsMap[name]);
    }

    return _computeChartFromRasis(
      titleTa: titleTa,
      lagnaRasi: lagnaRasi,
      moonRasi: moonRasi,
      venusRasi: venusRasi,
      maleficRasis: maleficRasis,
    );
  }

  static BhavaDoshamChartData _computeChartFromRasis({
    required String titleTa,
    required int lagnaRasi,
    required int moonRasi,
    required int venusRasi,
    required Map<String, int> maleficRasis,
  }) {
    final rows = <BhavaDoshamTableRow>[];

    // Row 1: Lagna (Weight 1.0)
    rows.add(_buildRow(
      refNameTa: 'லக்னம்',
      refRasi: lagnaRasi,
      weight: 1.0,
      maleficRasis: maleficRasis,
    ));

    // Row 2: Chandran (Weight 0.5)
    rows.add(_buildRow(
      refNameTa: 'சந்திரன்',
      refRasi: moonRasi,
      weight: 0.5,
      maleficRasis: maleficRasis,
    ));

    // Row 3: Sukran (Weight 0.25)
    rows.add(_buildRow(
      refNameTa: 'சுக்கிரன்',
      refRasi: venusRasi,
      weight: 0.25,
      maleficRasis: maleficRasis,
    ));

    final total = rows.fold<double>(0.0, (acc, r) => acc + r.rowAmount);

    return BhavaDoshamChartData(
      titleTa: titleTa,
      rows: rows,
      totalAmount: total,
      totalAmountStr: formatFraction(total),
    );
  }

  static BhavaDoshamTableRow _buildRow({
    required String refNameTa,
    required int refRasi,
    required double weight,
    required Map<String, int> maleficRasis,
  }) {
    final houseOccupants = <int, List<String>>{
      1: [],
      2: [],
      4: [],
      7: [],
      8: [],
      12: [],
    };

    int maleficCount = 0;

    for (final entry in maleficSymbols.entries) {
      final pRasi = maleficRasis[entry.key];
      if (pRasi != null) {
        final house = ((pRasi - refRasi + 12) % 12) + 1;
        if (targetHouses.contains(house)) {
          houseOccupants[house]!.add(entry.value);
          maleficCount++;
        }
      }
    }

    final rowAmount = maleficCount * weight;

    return BhavaDoshamTableRow(
      refNameTa: refNameTa,
      houseOccupants: houseOccupants,
      planetCount: maleficCount,
      weightPerRow: weight,
      rowAmount: rowAmount,
      rowAmountStr: formatFraction(rowAmount),
    );
  }

  static int _extractRasi(dynamic obj) {
    if (obj is int) return obj;
    if (obj == null) return 0;
    try {
      final rasi = obj.rasiIndex;
      if (rasi is int) return rasi;
    } catch (_) {}
    if (obj is Map && obj['rasiIndex'] is int) return obj['rasiIndex'] as int;
    return 0;
  }

  /// Formats double as a clean fractional string matching classical astrology books
  /// (e.g. 4.5 -> "4 1/2", 2.75 -> "2 3/4", 0.5 -> "1/2", 0.25 -> "1/4", 2.0 -> "2")
  static String formatFraction(double val) {
    final intWhole = val.floor();
    final rem = val - intWhole;
    String frac = '';
    if ((rem - 0.25).abs() < 0.05) {
      frac = '1/4';
    } else if ((rem - 0.5).abs() < 0.05) {
      frac = '1/2';
    } else if ((rem - 0.75).abs() < 0.05) {
      frac = '3/4';
    }
    if (intWhole == 0 && frac.isNotEmpty) return frac;
    if (frac.isEmpty) return intWhole.toString();
    return '$intWhole $frac';
  }
}

/// Traditional Tamil/Vedic 11 Porutham Calculation Engine
class PoruthamCalculator {
  /// Calculate 11 Poruthams from Male & Female Star, Pada, and Rasi indices
  static MarriagePoruthamResult calculatePorutham({
    required int maleStarIndex, // 0..26
    required int malePada, // 1..4
    required int maleRasiIndex, // 0..11
    required int femaleStarIndex, // 0..26
    required int femalePada, // 1..4
    required int femaleRasiIndex, // 0..11
    dynamic maleAstroData,
    dynamic femaleAstroData,
  }) {
    final dina = _calculateDinaPorutham(femaleStarIndex, maleStarIndex);
    final gana = _calculateGanaPorutham(femaleStarIndex, maleStarIndex);
    final mahendra = _calculateMahendraPorutham(femaleStarIndex, maleStarIndex);
    final sthreeDeergha = _calculateSthreeDeerghaPorutham(femaleStarIndex, maleStarIndex);
    final yoni = _calculateYoniPorutham(femaleStarIndex, maleStarIndex);
    final rasi = _calculateRasiPorutham(femaleRasiIndex, maleRasiIndex);
    final rasiAthipathi = _calculateRasiAthipathiPorutham(femaleRasiIndex, maleRasiIndex, maleStar: maleStarIndex);
    final vasya = _calculateVasyaPorutham(femaleRasiIndex, maleRasiIndex);
    final rajju = _calculateRajjuPorutham(femaleStarIndex, maleStarIndex);
    final vedha = _calculateVedhaPorutham(femaleStarIndex, maleStarIndex);
    final nadi = _calculateNadiPorutham(femaleStarIndex, maleStarIndex);

    final items = [
      dina,
      gana,
      mahendra,
      sthreeDeergha,
      yoni,
      rasi,
      rasiAthipathi,
      vasya,
      rajju,
      vedha,
      nadi,
    ];

    final matchedCount = items.where((i) => i.isMatched).length;
    final isRajjuMatched = rajju.isMatched;
    final isVedhaMatched = vedha.isMatched;

    // Determine overall compatibility text in Tamil
    String conclusion = '';
    String summaryDetails = '';

    if (!isRajjuMatched) {
      conclusion = 'பொருத்தம் இல்லை (ரஜ்ஜு தோஷம் உள்ளது)';
      summaryDetails = 'ரஜ்ஜு பொருத்தம் இல்லாததால் இந்த திருமணம் பரிந்துரைக்கப்படவில்லை.';
    } else if (!isVedhaMatched) {
      conclusion = 'பொருத்தம் குறைவு (வேதை தோஷம் உள்ளது)';
      summaryDetails = 'வேதை தோஷம் உள்ளதால் பிற பொருத்தங்களை ஆராய வேண்டும்.';
    } else if (matchedCount >= 8) {
      conclusion = 'உத்தம பொருத்தம் (மிகச் சிறந்த பொருத்தம்)';
      summaryDetails = '11 பொருத்தங்களில் $matchedCount பொருத்தங்கள் சிறப்பாக அமைந்துள்ளது. திருமணத்திற்கு மிகவும் உகந்தது.';
    } else if (matchedCount >= 6) {
      conclusion = 'மத்திய பொருத்தம் (மிதமான பொருத்தம்)';
      summaryDetails = '11 பொருத்தங்களில் $matchedCount பொருத்தங்கள் பொருந்தி வருகின்றன. ஜாதக தோஷங்களை சரிபார்த்து முடிவு செய்யலாம்.';
    } else {
      conclusion = 'பொருத்தம் குறைவு (அதம பொருத்தம்)';
      summaryDetails = '11 பொருத்தங்களில் $matchedCount பொருத்தங்கள் மட்டுமே பொருந்துகின்றன.';
    }

    final bhavaSamyam = BhavaSamyamCalculator.calculate(
      maleAstroData: maleAstroData,
      femaleAstroData: femaleAstroData,
    );

    return MarriagePoruthamResult(
      items: items,
      matchedCount: matchedCount,
      totalCount: 11,
      isRajjuMatched: isRajjuMatched,
      isVedhaMatched: isVedhaMatched,
      overallConclusionTa: conclusion,
      summaryDetailsTa: summaryDetails,
      bhavaSamyam: bhavaSamyam,
    );
  }

  // ---------------------------------------------------------------------------
  // Reference Data: 27 Nakshatras & 12 Rasis in Tamil
  // ---------------------------------------------------------------------------
  static const List<String> nakshatraNamesTa = [
    'அசுவினி',
    'பரணி',
    'கார்த்திகை',
    'ரோகிணி',
    'மிருகசீரிஷம்',
    'திருவாதிரை',
    'புனர்பூசம்',
    'பூசம்',
    'ஆயில்யம்',
    'மகம்',
    'பூரம்',
    'உத்திரம்',
    'அஸ்தம்',
    'சித்திரை',
    'சுவாதி',
    'விசாகம்',
    'அனுஷம்',
    'கேட்டை',
    'மூலம்',
    'பூராடம்',
    'உத்திராடம்',
    'திருவோணம்',
    'அவிட்டம்',
    'சதயம்',
    'பூரட்டாதி',
    'உத்திரட்டாதி',
    'ரேவதி',
  ];

  static const List<String> rasiNamesTa = [
    'மேஷம்',
    'ரிஷபம்',
    'மிதுனம்',
    'கடகம்',
    'சிம்மம்',
    'கன்னி',
    'துலாம்',
    'விருச்சிகம்',
    'தனுசு',
    'மகரம்',
    'கும்பம்',
    'மீனம்',
  ];

  static String _getStarNameTa(int starIndex) {
    if (starIndex >= 0 && starIndex < nakshatraNamesTa.length) {
      return nakshatraNamesTa[starIndex];
    }
    return 'நட்சத்திரம் ${starIndex + 1}';
  }

  static String _getRasiNameTa(int rasiIndex) {
    return rasiNamesTa[rasiIndex % 12];
  }

  // ---------------------------------------------------------------------------
  // 1. Dina Porutham (தினப் பொருத்தம்)
  // ---------------------------------------------------------------------------
  static PoruthamItem calculateDinaPorutham(int femaleStar, int maleStar) {
    return _calculateDinaPorutham(femaleStar, maleStar);
  }

  static PoruthamItem _calculateDinaPorutham(int femaleStar, int maleStar) {
    final count = ((maleStar - femaleStar + 27) % 27) + 1;
    final fName = _getStarNameTa(femaleStar);
    final mName = _getStarNameTa(maleStar);

    bool matched;
    String desc;

    // Explicit Rejection Conditions:
    // 17th position = NOT MATCHED
    // 22nd position = NOT MATCHED (Vainasika)
    if (count == 17 || count == 22) {
      matched = false;
      desc = 'பெண் நட்சத்திரத்திலிருந்து ($fName) ஆண் நட்சத்திரம் ($mName) $count-வது இடமாக வருவதால் (விசேஷ விலக்கு) தினப் பொருத்தம் பொருந்தவில்லை.';
    } else {
      final rem = count % 9;
      // Favorable remainders: 2 (Sampat), 4 (Kshema), 6 (Sadhana), 8 (Mitra), 0 (Param Mitra)
      matched = (rem == 2 || rem == 4 || rem == 6 || rem == 8 || rem == 0);
      desc = matched
          ? 'பெண் நட்சத்திரத்திலிருந்து ($fName) ஆண் நட்சத்திரம் ($mName) $count-வது தாரையாக ($rem) வருவதால் ஆரோக்கியமும் செல்வமும் பெருகும்.'
          : 'பெண் நட்சத்திரத்திலிருந்து ($fName) ஆண் நட்சத்திரம் ($mName) $count-வது தாரையாக ($rem) வருவதால் தினப் பொருத்தம் பொருந்தவில்லை.';
    }

    return PoruthamItem(
      id: 'dina',
      nameTa: 'தினப் பொருத்தம்',
      nameEn: 'Dina Porutham',
      status: matched ? PoruthamStatus.matched : PoruthamStatus.notMatched,
      descriptionTa: desc,
      femaleInfoTa: 'பெண்: $fName',
      maleInfoTa: 'ஆண்: $mName',
      metricInfoTa: 'எண்ணிக்கை: $count',
    );
  }

  // ---------------------------------------------------------------------------
  // 2. Gana Porutham (கணப் பொருத்தம்)
  // ---------------------------------------------------------------------------
  static PoruthamItem calculateGanaPorutham(int femaleStar, int maleStar) {
    return _calculateGanaPorutham(femaleStar, maleStar);
  }

  static PoruthamItem _calculateGanaPorutham(int femaleStar, int maleStar) {
    final count = ((maleStar - femaleStar + 27) % 27) + 1;
    final femaleGana = _getGana(femaleStar);
    final maleGana = _getGana(maleStar);
    final fName = _getStarNameTa(femaleStar);
    final mName = _getStarNameTa(maleStar);
    final fGanaName = _ganaNameTa(femaleGana);
    final mGanaName = _ganaNameTa(maleGana);

    bool matched = false;
    String desc = '';

    // Special Exception: If Male's Nakshatra falls at position 14 or greater, return MATCHED.
    if (count >= 14) {
      matched = true;
      desc = 'பெண் நட்சத்திரத்திலிருந்து ($fName - $fGanaName கணம்) ஆண் நட்சத்திரம் ($mName - $mGanaName கணம்) $count-வது நட்சத்திரமாக (14 அல்லது அதற்கு மேல்) வருவதால் சிறப்பு விதிவிலக்குப்படி கண தோஷமின்றி பொருந்தும்.';
    } else {
      if (femaleGana == maleGana) {
        matched = true;
        desc = 'இருவரும் ஒரே கணத்தைச் ($fGanaName) சார்ந்தவர்கள். தம்பதியரிடையே நல்இணக்கம் நிலவும்.';
      } else if (femaleGana == 0 && maleGana == 1) { // Deva F + Manusha M
        matched = true;
        desc = 'பெண் தேவ கணமும் ஆண் மனித கணமும் ஆகும். சுமுகமான குடும்ப வாழ்க்கை அமையும்.';
      } else if (femaleGana == 1 && maleGana == 0) { // Manusha F + Deva M
        matched = true;
        desc = 'பெண் மனித கணமும் ஆண் தேவ கணமும் ஆகும். உத்தமமான கணப் பொருத்தம்.';
      } else if (femaleGana == 0 && maleGana == 2) { // Deva F + Rakshasa M
        matched = true;
        desc = 'பெண் தேவ கணமும் ஆண் ராட்சச கணமும் ஆகும். மிதமான நற்பலன் தரும்.';
      } else {
        matched = false;
        desc = 'பெண் $fGanaName கணமும், ஆண் $mGanaName கணமும் ஆகும் ($count-வது நட்சத்திரம்). கணப் பொருத்தம் பொருந்தாது.';
      }
    }

    return PoruthamItem(
      id: 'gana',
      nameTa: 'கணப் பொருத்தம்',
      nameEn: 'Gana Porutham',
      status: matched ? PoruthamStatus.matched : PoruthamStatus.notMatched,
      descriptionTa: desc,
      femaleInfoTa: 'பெண்: $fName ($fGanaName)',
      maleInfoTa: 'ஆண்: $mName ($mGanaName)',
      metricInfoTa: 'எண்ணிக்கை: $count',
    );
  }

  static int _getGana(int starIndex) {
    // 0: Deva, 1: Manusha, 2: Rakshasa
    const devaStars = {0, 4, 6, 7, 12, 14, 16, 21, 26};
    const manushaStars = {1, 3, 5, 10, 11, 19, 20, 24, 25};
    if (devaStars.contains(starIndex)) return 0;
    if (manushaStars.contains(starIndex)) return 1;
    return 2; // Rakshasa
  }

  static String _ganaNameTa(int gana) {
    if (gana == 0) return 'தேவ';
    if (gana == 1) return 'மனித';
    return 'ராட்சச';
  }

  // ---------------------------------------------------------------------------
  // 3. Mahendra Porutham (மகேந்திரப் பொருத்தம்)
  // ---------------------------------------------------------------------------
  static PoruthamItem calculateMahendraPorutham(int femaleStar, int maleStar) {
    return _calculateMahendraPorutham(femaleStar, maleStar);
  }

  static PoruthamItem _calculateMahendraPorutham(int femaleStar, int maleStar) {
    final count = ((maleStar - femaleStar + 27) % 27) + 1;
    final fName = _getStarNameTa(femaleStar);
    final mName = _getStarNameTa(maleStar);

    // Position 1 = MATCHED (new condition).
    // Positions 4, 7, 10, 13, 16, 19, 22, 25 = MATCHED (existing classical rules).
    final bool matched = const {1, 4, 7, 10, 13, 16, 19, 22, 25}.contains(count);

    final desc = matched
        ? 'பெண் நட்சத்திரத்திலிருந்து ($fName) ஆண் நட்சத்திரம் ($mName) $count-வது நட்சத்திரமாக அமைவதால் மகேந்திரப் பொருத்தம் உண்டு. புத்திர பாக்கியமும் வம்ச விருத்தியும் உண்டாகும்.'
        : 'பெண் நட்சத்திரத்திலிருந்து ($fName) ஆண் நட்சத்திரம் ($mName) $count-வது நட்சத்திரமாக அமைவதால் மகேந்திரப் பொருத்தம் அமையவில்லை.';

    return PoruthamItem(
      id: 'mahendra',
      nameTa: 'மகேந்திரப் பொருத்தம்',
      nameEn: 'Mahendra Porutham',
      status: matched ? PoruthamStatus.matched : PoruthamStatus.notMatched,
      descriptionTa: desc,
      femaleInfoTa: 'பெண்: $fName',
      maleInfoTa: 'ஆண்: $mName',
      metricInfoTa: 'எண்ணிக்கை: $count',
    );
  }

  // ---------------------------------------------------------------------------
  // 4. Sthree Deergha Porutham (ஸ்திரீ தீர்க்கப் பொருத்தம்)
  // ---------------------------------------------------------------------------
  static PoruthamItem calculateSthreeDeerghaPorutham(int femaleStar, int maleStar) {
    return _calculateSthreeDeerghaPorutham(femaleStar, maleStar);
  }

  static PoruthamItem _calculateSthreeDeerghaPorutham(int femaleStar, int maleStar) {
    final count = ((maleStar - femaleStar + 27) % 27) + 1;
    final fName = _getStarNameTa(femaleStar);
    final mName = _getStarNameTa(maleStar);

    // If count > 7 -> MATCHED (positions 8 through 27)
    // If count <= 7 -> NOT MATCHED (positions 1 through 7)
    final bool matched = count > 7;

    final desc = matched
        ? 'பெண் நட்சத்திரத்திலிருந்து ($fName) ஆண் நட்சத்திரம் ($mName) $count-வது நட்சத்திரமாக (7-க்கு மேல்) தள்ளி இருப்பதால் ஸ்திரீ தீர்க்கப் பொருத்தம் பொருந்தும். தீர்க்க சுமங்கலி யோகம் உண்டாகும்.'
        : 'பெண் நட்சத்திரத்திலிருந்து ($fName) ஆண் நட்சத்திரம் ($mName) $count-வது நட்சத்திரமாக (7 அல்லது அதற்கு கீழ்) அமைவதால் ஸ்திரீ தீர்க்கப் பொருத்தம் பொருந்தாது.';

    return PoruthamItem(
      id: 'sthree_deergha',
      nameTa: 'ஸ்திரீ தீர்க்கப் பொருத்தம்',
      nameEn: 'Sthree Deergha Porutham',
      status: matched ? PoruthamStatus.matched : PoruthamStatus.notMatched,
      descriptionTa: desc,
      femaleInfoTa: 'பெண்: $fName',
      maleInfoTa: 'ஆண்: $mName',
      metricInfoTa: 'எண்ணிக்கை: $count',
    );
  }

  // ---------------------------------------------------------------------------
  // 5. Yoni Porutham (யோனிப் பொருத்தம்)
  // ---------------------------------------------------------------------------
  static PoruthamItem calculateYoniPorutham(int femaleStar, int maleStar) {
    return _calculateYoniPorutham(femaleStar, maleStar);
  }

  static PoruthamItem _calculateYoniPorutham(int femaleStar, int maleStar) {
    final femaleAnimal = _getYoniAnimal(femaleStar);
    final maleAnimal = _getYoniAnimal(maleStar);
    final fName = _getStarNameTa(femaleStar);
    final mName = _getStarNameTa(maleStar);

    // 5 Explicitly Rejected Combinations (symmetric, regardless of input order):
    // 1. Uthiradam (20) x Visakam (15)
    // 2. Rohini (3) x Magam (9)
    // 3. Rohini (3) x Pooram (10)
    // 4. Mirugaseerisham (4) x Magam (9)
    // 5. Mirugaseerisham (4) x Pooram (10)
    final pairSet = {femaleStar, maleStar};
    final bool isExplicitRejection =
        (pairSet.contains(20) && pairSet.contains(15)) ||
        (pairSet.contains(3) && pairSet.contains(9)) ||
        (pairSet.contains(3) && pairSet.contains(10)) ||
        (pairSet.contains(4) && pairSet.contains(9)) ||
        (pairSet.contains(4) && pairSet.contains(10));

    bool matched;
    String desc;

    if (isExplicitRejection) {
      matched = false;
      desc = 'பெண் நட்சத்திரம் ($fName - $femaleAnimal) மற்றும் ஆண் நட்சத்திரம் ($mName - $maleAnimal) சேர்க்கை விசேஷ விலக்கப்பட்ட பகை சேர்க்கையாக அமைவதால் யோனிப் பொருத்தம் பொருந்தாது.';
    } else {
      final bool isEnemy = _isEnemyYoni(femaleAnimal, maleAnimal);
      matched = !isEnemy;
      desc = matched
          ? 'பெண் யோனி ($femaleAnimal), ஆண் யோனி ($maleAnimal) இரண்டும் பகை அல்ல என்பதால் தாம்பத்திய சுகம் சிறப்பாக இருக்கும்.'
          : 'பெண் யோனி ($femaleAnimal) மற்றும் ஆண் யோனி ($maleAnimal) இரண்டும் இயற்கை எதிரிகளாக அமைவதால் யோனிப் பொருத்தம் இல்லை.';
    }

    return PoruthamItem(
      id: 'yoni',
      nameTa: 'யோனிப் பொருத்தம்',
      nameEn: 'Yoni Porutham',
      status: matched ? PoruthamStatus.matched : PoruthamStatus.notMatched,
      descriptionTa: desc,
      femaleInfoTa: 'பெண்: $fName ($femaleAnimal)',
      maleInfoTa: 'ஆண்: $mName ($maleAnimal)',
      metricInfoTa: 'யோனி சேர்க்கை',
    );
  }

  static String _getYoniAnimal(int starIndex) {
    const animals = [
      'குதிரை', // 0 Ashwini
      'யானை', // 1 Bharani
      'ஆடு', // 2 Krittika
      'பாம்பு', // 3 Rohini
      'பாம்பு', // 4 Mrigashira
      'நாய்', // 5 Ardra
      'பூனை', // 6 Punarvasu
      'ஆடு', // 7 Pushya
      'பூனை', // 8 Ashlesha
      'எலி', // 9 Magha
      'எலி', // 10 Purva Phalguni
      'பசு', // 11 Uttara Phalguni
      'எருமை', // 12 Hasta
      'புலி', // 13 Chitra
      'எருமை', // 14 Swati
      'புலி', // 15 Vishakha
      'மான்', // 16 Anuradha
      'மான்', // 17 Jyeshtha
      'நாய்', // 18 Mula
      'குரங்கு', // 19 Purva Ashadha
      'கீரி', // 20 Uttara Ashadha
      'குரங்கு', // 21 Shravana
      'சிங்கம்', // 22 Dhanishta
      'குதிரை', // 23 Shatabhisha
      'சிங்கம்', // 24 Purva Bhadrapada
      'பசு', // 25 Uttara Bhadrapada
      'யானை', // 26 Revati
    ];
    return animals[starIndex % 27];
  }

  static bool _isEnemyYoni(String a1, String a2) {
    if ((a1 == 'குதிரை' && a2 == 'எருமை') || (a1 == 'எருமை' && a2 == 'குதிரை')) return true;
    if ((a1 == 'யானை' && a2 == 'சிங்கம்') || (a1 == 'சிங்கம்' && a2 == 'யானை')) return true;
    if ((a1 == 'ஆடு' && a2 == 'குரங்கு') || (a1 == 'குரங்கு' && a2 == 'ஆடு')) return true;
    if ((a1 == 'பாம்பு' && a2 == 'கீரி') || (a1 == 'கீரி' && a2 == 'பாம்பு')) return true;
    if ((a1 == 'நாய்' && a2 == 'மான்') || (a1 == 'மான்' && a2 == 'நாய்')) return true;
    if ((a1 == 'பூனை' && a2 == 'எலி') || (a1 == 'எலி' && a2 == 'பூனை')) return true;
    if ((a1 == 'பசு' && a2 == 'புலி') || (a1 == 'புலி' && a2 == 'பசு')) return true;
    return false;
  }

  // ---------------------------------------------------------------------------
  // 6. Rasi Porutham (ராசிப் பொருத்தம்)
  // ---------------------------------------------------------------------------
  static PoruthamItem calculateRasiPorutham(int femaleRasi, int maleRasi) {
    return _calculateRasiPorutham(femaleRasi, maleRasi);
  }

  static PoruthamItem _calculateRasiPorutham(int femaleRasi, int maleRasi) {
    // Starting point: Bride's Rasi (0..11) counting to Groom's Rasi (0..11)
    final count = ((maleRasi - femaleRasi + 12) % 12) + 1;
    final fRasiName = _getRasiNameTa(femaleRasi);
    final mRasiName = _getRasiNameTa(maleRasi);

    // Newly supplied rejection positions:
    // NOT MATCHED positions: 2, 3, 4, 5, 6, 8
    // MATCHED positions: 1, 7, 9, 10, 11, 12
    const notMatchedPositions = {2, 3, 4, 5, 6, 8};
    final bool matched = !notMatchedPositions.contains(count);

    final desc = matched
        ? 'பெண் ராசியான $fRasiName-லிருந்து ஆண் ராசி $mRasiName $count-வது ராசியாக அமைவதால் ராசிப் பொருத்தம் பொருந்தும். வம்ச விருத்தியும் குடும்ப மகிழ்ச்சியும் உண்டாகும்.'
        : 'பெண் ராசியான $fRasiName-லிருந்து ஆண் ராசி $mRasiName $count-வது ராசியாக அமைவதால் ($count-வது இடம் விலக்கப்பட்டது) ராசிப் பொருத்தம் பொருந்தாது.';

    return PoruthamItem(
      id: 'rasi',
      nameTa: 'ராசிப் பொருத்தம்',
      nameEn: 'Rasi Porutham',
      status: matched ? PoruthamStatus.matched : PoruthamStatus.notMatched,
      descriptionTa: desc,
      femaleInfoTa: 'பெண் ராசி: $fRasiName',
      maleInfoTa: 'ஆண் ராசி: $mRasiName',
      metricInfoTa: 'ராசி இடம்: $count',
    );
  }

  // ---------------------------------------------------------------------------
  // 7. Rasi Athipathi Porutham (ராசி அதிபதிப் பொருத்தம்)
  // ---------------------------------------------------------------------------
  static PoruthamItem calculateRasiAthipathiPorutham(int femaleRasi, int maleRasi, {int? maleStar, String? maleTarget}) {
    return _calculateRasiAthipathiPorutham(femaleRasi, maleRasi, maleStar: maleStar, maleTarget: maleTarget);
  }

  /// Checks if a Female Rasi x Male Target combination is in the 25 rejection list
  static bool isRasiAthipathiCombinationRejected({
    required int femaleRasi,
    int? maleRasi,
    int? maleStar,
    String? maleTarget,
  }) {
    // Handle Visakam explicitly (Flagged anomaly: Visakam is a Nakshatra)
    if (maleTarget != null) {
      final t = maleTarget.trim().toLowerCase();
      if (t == 'visakam' || t == 'விசாகம்') {
        return femaleRasi == 9 || femaleRasi == 10;
      }
      final rIdx = rasiNamesTa.indexWhere((r) => r.toLowerCase() == t);
      if (rIdx != -1) {
        return _isRasiAthipathiPairRejected(femaleRasi, rIdx);
      }
    }
    if (maleStar == 15 && (femaleRasi == 9 || femaleRasi == 10)) {
      return true;
    }
    if (maleRasi != null) {
      return _isRasiAthipathiPairRejected(femaleRasi, maleRasi);
    }
    return false;
  }

  static bool _isRasiAthipathiPairRejected(int femaleRasi, int maleRasi) {
    // 23 Explicit Rasi x Rasi rejection pairs:
    const rejectedPairs = {
      '0,2',  // 1. Mesham x Mithunam
      '0,5',  // 2. Mesham x Kanni
      '1,3',  // 3. Rishabam x Kadagam
      '1,4',  // 4. Rishabam x Simham
      '2,3',  // 5. Mithunam x Kadagam
      '4,6',  // 6. Simham x Thulam
      '4,1',  // 7. Simham x Rishabam
      '4,9',  // 8. Simham x Makaram
      '4,10', // 9. Simham x Kumbam
      '8,1',  // 10. Dhanusu x Rishabam
      '8,2',  // 11. Dhanusu x Mithunam
      '8,5',  // 12. Dhanusu x Kanni
      '8,6',  // 13. Dhanusu x Thulam
      '11,1', // 14. Meenam x Rishabam
      '11,2', // 15. Meenam x Mithunam
      '11,5', // 16. Meenam x Kanni
      '11,6', // 17. Meenam x Thulam
      '9,0',  // 18. Makaram x Mesham
      '9,3',  // 19. Makaram x Kadagam
      '9,4',  // 20. Makaram x Simham
      // 21. Makaram x Visakam (Handled via maleStar / maleTarget)
      '10,0', // 22. Kumbam x Mesham
      '10,3', // 23. Kumbam x Kadagam
      '10,4', // 24. Kumbam x Simham
      // 25. Kumbam x Visakam (Handled via maleStar / maleTarget)
    };
    return rejectedPairs.contains('$femaleRasi,$maleRasi');
  }

  static PoruthamItem _calculateRasiAthipathiPorutham(int femaleRasi, int maleRasi, {int? maleStar, String? maleTarget}) {
    final bool rejected = isRasiAthipathiCombinationRejected(
      femaleRasi: femaleRasi,
      maleRasi: maleRasi,
      maleStar: maleStar,
      maleTarget: maleTarget,
    );
    final bool matched = !rejected;

    final femaleRasiName = _getRasiNameTa(femaleRasi);
    final maleTargetDisplay = (maleTarget != null && (maleTarget.toLowerCase() == 'visakam' || maleTarget == 'விசாகம்'))
        ? 'விசாகம்'
        : (maleStar == 15 && (femaleRasi == 9 || femaleRasi == 10))
            ? 'விசாகம்'
            : _getRasiNameTa(maleRasi);

    final desc = matched
        ? 'பெண் ராசியான $femaleRasiName மற்றும் ஆண் $maleTargetDisplay சேர்க்கை விலக்கப்பட்ட 25 சேர்க்கைகளில் இல்லாததால் அதிபதிப் பொருத்தம் சிறப்பாகப் பொருந்துகிறது.'
        : 'பெண் ராசியான $femaleRasiName மற்றும் ஆண் $maleTargetDisplay சேர்க்கை விலக்கப்பட்ட 25 சேர்க்கைகளில் ஒன்றாக அமைவதால் அதிபதிப் பொருத்தம் பொருந்தாது.';

    return PoruthamItem(
      id: 'rasi_athipathi',
      nameTa: 'ராசி அதிபதிப் பொருத்தம்',
      nameEn: 'Rasi Athipathi Porutham',
      status: matched ? PoruthamStatus.matched : PoruthamStatus.notMatched,
      descriptionTa: desc,
      femaleInfoTa: 'பெண்: $femaleRasiName',
      maleInfoTa: 'ஆண்: $maleTargetDisplay',
      metricInfoTa: 'அதிபதி சேர்க்கை',
    );
  }

  // ---------------------------------------------------------------------------
  // 8. Vasya Porutham (வசியப் பொருத்தம்)
  // ---------------------------------------------------------------------------
  static const Map<int, Set<int>> _vasyaDirectionalMap = {
    0: {4, 7},      // Mesham -> Simham (1) [Viruchigam preserved]
    1: {3, 6},      // Rishabam -> Kadagam (2) [Thulam preserved]
    2: {5},         // Mithunam -> Kanni (3)
    3: {7, 8},      // Kadagam -> Viruchigam (4) [Dhanusu preserved]
    4: {6, 11},     // Simham -> Thulam (5) [Meenam preserved p. 110]
    5: {1, 11},     // Kanni -> Rishabam (6), Meenam (7)
    6: {9},         // Thulam -> Makaram (8)
    7: {3, 5},      // Viruchigam -> Kadagam (9), Kanni (10)
    8: {11},        // Dhanusu -> Meenam (11)
    9: {0, 10},     // Makaram -> Mesham (12), Kumbam (13)
    10: {11},       // Kumbam -> Meenam (14)
    11: {9},        // Meenam -> Makaram (15)
  };

  static PoruthamItem calculateVasyaPorutham(int femaleRasi, int maleRasi) {
    return _calculateVasyaPorutham(femaleRasi, maleRasi);
  }

  static PoruthamItem _calculateVasyaPorutham(int femaleRasi, int maleRasi) {
    // Strictly directional: Female Rasi is starting point, Male Rasi is destination.
    final bool matched = _vasyaDirectionalMap[femaleRasi]?.contains(maleRasi) ?? false;
    final fRasiName = _getRasiNameTa(femaleRasi);
    final mRasiName = _getRasiNameTa(maleRasi);

    final desc = matched
        ? 'பெண் ராசி ($fRasiName) ஆண் ராசிக்கு ($mRasiName) வசியப் பொருத்தம் கொண்டுள்ளதால் தம்பதியரிடையே அன்யோன்ய அன்பும் ஈர்ப்பும் பெருகும்.'
        : 'பெண் ராசி ($fRasiName) ஆண் ராசிக்கு ($mRasiName) வசியப் பொருத்தம் அமையவில்லை.';

    return PoruthamItem(
      id: 'vasya',
      nameTa: 'வசியப் பொருத்தம்',
      nameEn: 'Vasya Porutham',
      status: matched ? PoruthamStatus.matched : PoruthamStatus.notMatched,
      descriptionTa: desc,
      femaleInfoTa: 'பெண்: $fRasiName',
      maleInfoTa: 'ஆண்: $mRasiName',
      metricInfoTa: 'வசியம்: $fRasiName → $mRasiName',
    );
  }

  // ---------------------------------------------------------------------------
  // 9. Rajju Porutham (ரஜ்ஜுப் பொருத்தம்) - CRITICAL
  // ---------------------------------------------------------------------------
  static PoruthamItem _calculateRajjuPorutham(int femaleStar, int maleStar) {
    final femaleRajju = _getRajju(femaleStar);
    final maleRajju = _getRajju(maleStar);
    final fName = _getStarNameTa(femaleStar);
    final mName = _getStarNameTa(maleStar);

    final bool matched = (femaleRajju != maleRajju);

    final desc = matched
        ? 'பெண் நட்சத்திரம் ($fName - ${_rajjuNameTa(femaleRajju)} ரஜ்ஜு) மற்றும் ஆண் நட்சத்திரம் ($mName - ${_rajjuNameTa(maleRajju)} ரஜ்ஜு) வெவ்வேறு ரஜ்ஜுவில் அமைவதால் தீர்க்க சுமங்கலி யோகம் உண்டு.'
        : 'இருவரது நட்சத்திரங்களும் ஒரே ரஜ்ஜுவில் (${_rajjuNameTa(femaleRajju)} ரஜ்ஜு) அமைவதால் ரஜ்ஜு தோஷம் உள்ளது. இது பொருத்தமற்றது.';

    return PoruthamItem(
      id: 'rajju',
      nameTa: 'ரஜ்ஜுப் பொருத்தம்',
      nameEn: 'Rajju Porutham',
      status: matched ? PoruthamStatus.matched : PoruthamStatus.notMatched,
      descriptionTa: desc,
      femaleInfoTa: 'பெண்: $fName (${_rajjuNameTa(femaleRajju)})',
      maleInfoTa: 'ஆண்: $mName (${_rajjuNameTa(maleRajju)})',
      metricInfoTa: matched ? 'வெவ்வேறு ரஜ்ஜு' : 'ஒரே ரஜ்ஜு (தோஷம்)',
    );
  }

  static int _getRajju(int starIndex) {
    // 0: Shiro (Head), 1: Kanta (Neck), 2: Nabhi (Navel), 3: Kati (Thigh), 4: Pada (Foot)
    const shiro = {4, 13, 22};
    const kanta = {3, 5, 14, 15, 20, 21};
    const nabhi = {2, 6, 11, 19, 25};
    const kati = {1, 7, 10, 18, 24};

    if (shiro.contains(starIndex)) return 0;
    if (kanta.contains(starIndex)) return 1;
    if (nabhi.contains(starIndex)) return 2;
    if (kati.contains(starIndex)) return 3;
    return 4; // Pada
  }

  static String _rajjuNameTa(int rajju) {
    switch (rajju) {
      case 0:
        return 'சிரோ (தலை)';
      case 1:
        return 'கண்ட (கழுத்து)';
      case 2:
        return 'நாபி (விறு)';
      case 3:
        return 'கடி (தொடை)';
      case 4:
        return 'பாத (பதம்)';
      default:
        return '';
    }
  }

  // ---------------------------------------------------------------------------
  // 10. Vedha Porutham (வேதைப் பொருத்தம்)
  // ---------------------------------------------------------------------------
  static PoruthamItem _calculateVedhaPorutham(int femaleStar, int maleStar) {
    final bool isVedha = _isVedhaPair(femaleStar, maleStar);
    final bool matched = !isVedha;
    final fName = _getStarNameTa(femaleStar);
    final mName = _getStarNameTa(maleStar);

    final desc = matched
        ? 'இருவரது நட்சத்திரங்களுக்கும் ($fName, $mName) இடையே வேதை (பகைத் துன்பம்) இல்லை.'
        : 'இருவரது நட்சத்திரங்களும் ($fName, $mName) ஒன்றை ஒன்று வேதை (தாக்கும்) என்பதால் வேதை தோஷம் உள்ளது.';

    return PoruthamItem(
      id: 'vedha',
      nameTa: 'வேதைப் பொருத்தம்',
      nameEn: 'Vedha Porutham',
      status: matched ? PoruthamStatus.matched : PoruthamStatus.notMatched,
      descriptionTa: desc,
      femaleInfoTa: 'பெண்: $fName',
      maleInfoTa: 'ஆண்: $mName',
      metricInfoTa: matched ? 'வேதை இல்லை' : 'வேதை தோஷம்',
    );
  }

  static bool _isVedhaPair(int s1, int s2) {
    const Map<int, int> vedhaPairs = {
      0: 17, 17: 0, // Ashwini <-> Jyeshtha
      1: 16, 16: 1, // Bharani <-> Anuradha
      2: 15, 15: 2, // Krittika <-> Vishakha
      3: 14, 14: 3, // Rohini <-> Swati
      4: 22, 22: 4, // Mrigashira <-> Dhanishta
      5: 21, 21: 5, // Ardra <-> Shravana
      6: 20, 20: 6, // Punarvasu <-> Uttara Ashadha
      7: 19, 19: 7, // Pushya <-> Purva Ashadha
      8: 18, 18: 8, // Ashlesha <-> Mula
      9: 26, 26: 9, // Magha <-> Revati
      10: 25, 25: 10, // Purva Phalguni <-> Uttara Bhadrapada
      11: 24, 24: 11, // Uttara Phalguni <-> Purva Bhadrapada
      12: 23, 23: 12, // Hasta <-> Shatabhisha
    };
    return vedhaPairs[s1] == s2;
  }

  // ---------------------------------------------------------------------------
  // 11. Nadi Porutham (நாடிப் பொருத்தம்)
  // ---------------------------------------------------------------------------
  static PoruthamItem calculateNadiPorutham(int femaleStar, int maleStar) {
    return _calculateNadiPorutham(femaleStar, maleStar);
  }

  static PoruthamItem _calculateNadiPorutham(int femaleStar, int maleStar) {
    final femaleNadi = _getNadi(femaleStar);
    final maleNadi = _getNadi(maleStar);
    final fName = _getStarNameTa(femaleStar);
    final mName = _getStarNameTa(maleStar);

    final bool matched = (femaleNadi != maleNadi);

    final desc = matched
        ? 'பெண் நாடி (${_nadiNameTa(femaleNadi)}) மற்றும் ஆண் நாடி (${_nadiNameTa(maleNadi)}) வெவ்வேறு நாடிகளாக அமைவதால் சந்தான பாக்கியம் உண்டு.'
        : 'இருவருக்கும் ஒரே நாடி (${_nadiNameTa(femaleNadi)}) அமைவதால் நாடி தோஷம் உண்டாகிறது.';

    return PoruthamItem(
      id: 'nadi',
      nameTa: 'நாடிப் பொருத்தம்',
      nameEn: 'Nadi Porutham',
      status: matched ? PoruthamStatus.matched : PoruthamStatus.notMatched,
      descriptionTa: desc,
      femaleInfoTa: 'பெண்: $fName (${_nadiNameTa(femaleNadi)})',
      maleInfoTa: 'ஆண்: $mName (${_nadiNameTa(maleNadi)})',
      metricInfoTa: matched ? 'வெவ்வேறு நாடி' : 'ஒரே நாடி (தோஷம்)',
    );
  }

  static int getNadi(int starIndex) => _getNadi(starIndex);

  static int _getNadi(int starIndex) {
    // 0: Aadi Nadi (Vatha), 1: Madhya Nadi (Pitha), 2: Anthiya Nadi (Kapha)
    const aadi = {0, 5, 6, 11, 12, 17, 18, 23, 24};
    const madhya = {1, 4, 7, 10, 13, 16, 19, 22, 25};
    if (aadi.contains(starIndex)) return 0;
    if (madhya.contains(starIndex)) return 1;
    return 2; // Anthiya
  }

  static String getNadiNameTa(int nadi) => _nadiNameTa(nadi);

  static String _nadiNameTa(int nadi) {
    switch (nadi) {
      case 0:
        return 'ஆதி நாடி / பார்சுவ நாடி (வாதம்)';
      case 1:
        return 'மத்திய நாடி (பித்தம்)';
      case 2:
      default:
        return 'அந்திய நாடி / சமான நாடி (கபம் / சிலேத்துமம்)';
    }
  }

  static String getNadiNameEn(int nadi) => _nadiNameEn(nadi);

  static String _nadiNameEn(int nadi) {
    switch (nadi) {
      case 0:
        return 'Aadi Nadi (Vatha)';
      case 1:
        return 'Madhya Nadi (Pitha)';
      case 2:
      default:
        return 'Anthiya Nadi (Kapha / Sleshma)';
    }
  }
}
