import '../models/porutham_model.dart';

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
  }) {
    final dina = _calculateDinaPorutham(femaleStarIndex, maleStarIndex);
    final gana = _calculateGanaPorutham(femaleStarIndex, maleStarIndex);
    final mahendra = _calculateMahendraPorutham(femaleStarIndex, maleStarIndex);
    final sthreeDeergha = _calculateSthreeDeerghaPorutham(femaleStarIndex, maleStarIndex);
    final yoni = _calculateYoniPorutham(femaleStarIndex, maleStarIndex);
    final rasi = _calculateRasiPorutham(femaleRasiIndex, maleRasiIndex);
    final rasiAthipathi = _calculateRasiAthipathiPorutham(femaleRasiIndex, maleRasiIndex);
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

    return MarriagePoruthamResult(
      items: items,
      matchedCount: matchedCount,
      totalCount: 11,
      isRajjuMatched: isRajjuMatched,
      isVedhaMatched: isVedhaMatched,
      overallConclusionTa: conclusion,
      summaryDetailsTa: summaryDetails,
    );
  }

  // ---------------------------------------------------------------------------
  // 1. Dina Porutham (தினப் பொருத்தம்)
  // ---------------------------------------------------------------------------
  static PoruthamItem _calculateDinaPorutham(int femaleStar, int maleStar) {
    final count = ((maleStar - femaleStar + 27) % 27) + 1;
    final rem = count % 9;

    // Favorable remainders: 2 (Bharani/wealth), 4 (Kshema), 6 (Sadhana), 8 (Mitra), 0 (Param Mitra)
    final bool matched = (rem == 2 || rem == 4 || rem == 6 || rem == 8 || rem == 0);

    final desc = matched
        ? 'பெண் நட்சத்திரத்திலிருந்து ஆண் நட்சத்திரம் $count-வது தாரையாக ($rem) வருவதால் ஆரோக்கியமும் செல்வமும் பெருகும்.'
        : 'பெண் நட்சத்திரத்திலிருந்து ஆண் நட்சத்திரம் $count-வது தாரையாக ($rem) வருவதால் தினப் பொருத்தம் பொருந்தவில்லை.';

    return PoruthamItem(
      id: 'dina',
      nameTa: 'தினப் பொருத்தம்',
      nameEn: 'Dina Porutham',
      status: matched ? PoruthamStatus.matched : PoruthamStatus.notMatched,
      descriptionTa: desc,
    );
  }

  // ---------------------------------------------------------------------------
  // 2. Gana Porutham (கணப் பொருத்தம்)
  // ---------------------------------------------------------------------------
  static PoruthamItem _calculateGanaPorutham(int femaleStar, int maleStar) {
    final femaleGana = _getGana(femaleStar);
    final maleGana = _getGana(maleStar);

    bool matched = false;
    String desc = '';

    if (femaleGana == maleGana) {
      matched = true;
      desc = 'இருவரும் ஒரே கணத்தைச் (${_ganaNameTa(femaleGana)}) சார்ந்தவர்கள். தம்பதியரிடையே நல்இணக்கம் நிலவும்.';
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
      desc = 'பெண் ${_ganaNameTa(femaleGana)} கணமும், ஆண் ${_ganaNameTa(maleGana)} கணமும் ஆகும். கணப் பொருத்தம் பொருந்தாது.';
    }

    return PoruthamItem(
      id: 'gana',
      nameTa: 'கணப் பொருத்தம்',
      nameEn: 'Gana Porutham',
      status: matched ? PoruthamStatus.matched : PoruthamStatus.notMatched,
      descriptionTa: desc,
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
  static PoruthamItem _calculateMahendraPorutham(int femaleStar, int maleStar) {
    final count = ((maleStar - femaleStar + 27) % 27) + 1;
    final bool matched = {4, 7, 10, 13, 16, 19, 22, 25}.contains(count);

    final desc = matched
        ? 'நட்சத்திர எண்ணிக்கை $count ஆக அமைவதால் புத்திர பாக்கியமும் வம்ச விருத்தியும் உண்டாகும்.'
        : 'நட்சத்திர எண்ணிக்கை $count ஆக அமைவதால் மகேந்திரப் பொருத்தம் அமையவில்லை.';

    return PoruthamItem(
      id: 'mahendra',
      nameTa: 'மகேந்திரப் பொருத்தம்',
      nameEn: 'Mahendra Porutham',
      status: matched ? PoruthamStatus.matched : PoruthamStatus.notMatched,
      descriptionTa: desc,
    );
  }

  // ---------------------------------------------------------------------------
  // 4. Sthree Deergha Porutham (ஸ்திரீ தீர்க்கப் பொருத்தம்)
  // ---------------------------------------------------------------------------
  static PoruthamItem _calculateSthreeDeerghaPorutham(int femaleStar, int maleStar) {
    final count = ((maleStar - femaleStar + 27) % 27) + 1;
    final bool matched = count > 13;

    final desc = matched
        ? 'பெண் நட்சத்திரத்திலிருந்து ஆண் நட்சத்திரம் $count நட்சத்திரங்கள் தள்ளி இருப்பதால் தீர்க்க சுமங்கலி யோகம் தரும்.'
        : 'பெண் நட்சத்திரத்திலிருந்து ஆண் நட்சத்திரம் $count நட்சத்திரங்கள் மட்டுமே தள்ளி இருப்பதால் ஸ்திரீ தீர்க்கப் பொருத்தம் குறைவு.';

    return PoruthamItem(
      id: 'sthree_deergha',
      nameTa: 'ஸ்திரீ தீர்க்கப் பொருத்தம்',
      nameEn: 'Sthree Deergha Porutham',
      status: matched ? PoruthamStatus.matched : PoruthamStatus.notMatched,
      descriptionTa: desc,
    );
  }

  // ---------------------------------------------------------------------------
  // 5. Yoni Porutham (யோனிப் பொருத்தம்)
  // ---------------------------------------------------------------------------
  static PoruthamItem _calculateYoniPorutham(int femaleStar, int maleStar) {
    final femaleAnimal = _getYoniAnimal(femaleStar);
    final maleAnimal = _getYoniAnimal(maleStar);

    final bool isEnemy = _isEnemyYoni(femaleAnimal, maleAnimal);
    final bool matched = !isEnemy;

    final desc = matched
        ? 'பெண் யோனி ($femaleAnimal), ஆண் யோனி ($maleAnimal) இரண்டும் பகை அல்ல என்பதால் தாம்பத்திய சுகம் சிறப்பாக இருக்கும்.'
        : 'பெண் யோனி ($femaleAnimal) மற்றும் ஆண் யோனி ($maleAnimal) இரண்டும் இயற்கை எதிரிகளாக அமைவதால் யோனிப் பொருத்தம் இல்லை.';

    return PoruthamItem(
      id: 'yoni',
      nameTa: 'யோனிப் பொருத்தம்',
      nameEn: 'Yoni Porutham',
      status: matched ? PoruthamStatus.matched : PoruthamStatus.notMatched,
      descriptionTa: desc,
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
  static PoruthamItem _calculateRasiPorutham(int femaleRasi, int maleRasi) {
    final count = ((maleRasi - femaleRasi + 12) % 12) + 1;
    final bool matched = (count == 1 || count == 7 || count == 9 || count == 10 || count == 11 || count == 12);

    final desc = matched
        ? 'பெண் ராசியிலிருந்து ஆண் ராசி $count-வது ராசியாக வருவதால் வம்ச விருத்தியும் குடும்ப மகிழ்ச்சியும் பெருகும்.'
        : 'பெண் ராசியிலிருந்து ஆண் ராசி $count-வது ராசியாக (ஷஷ்டாஷ்டகம்/த்விர்த்வாதசம்) அமைவதால் ராசிப் பொருத்தம் இல்லை.';

    return PoruthamItem(
      id: 'rasi',
      nameTa: 'ராசிப் பொருத்தம்',
      nameEn: 'Rasi Porutham',
      status: matched ? PoruthamStatus.matched : PoruthamStatus.notMatched,
      descriptionTa: desc,
    );
  }

  // ---------------------------------------------------------------------------
  // 7. Rasi Athipathi Porutham (ராசி அதிபதிப் பொருத்தம்)
  // ---------------------------------------------------------------------------
  static PoruthamItem _calculateRasiAthipathiPorutham(int femaleRasi, int maleRasi) {
    final femaleLord = _getRasiLord(femaleRasi);
    final maleLord = _getRasiLord(maleRasi);

    final bool matched = _areLordsFriendly(femaleLord, maleLord);

    final desc = matched
        ? 'பெண் ராசி அதிபதி ($femaleLord) மற்றும் ஆண் ராசி அதிபதி ($maleLord) நட்பு/ஒரே கிரகம் என்பதால் நல்ல புரிதல் இருக்கும்.'
        : 'பெண் ராசி அதிபதி ($femaleLord) மற்றும் ஆண் ராசி அதிபதி ($maleLord) பகை கிரகங்களாக அமைவதால் அதிபதிப் பொருத்தம் இல்லை.';

    return PoruthamItem(
      id: 'rasi_athipathi',
      nameTa: 'ராசி அதிபதிப் பொருத்தம்',
      nameEn: 'Rasi Athipathi Porutham',
      status: matched ? PoruthamStatus.matched : PoruthamStatus.notMatched,
      descriptionTa: desc,
    );
  }

  static String _getRasiLord(int rasiIndex) {
    const lords = ['செவ்வாய்', 'சுக்கிரன்', 'புதன்', 'சந்திரன்', 'சூரியன்', 'புதன்', 'சுக்கிரன்', 'செவ்வாய்', 'குரு', 'சனி', 'சனி', 'குரு'];
    return lords[rasiIndex % 12];
  }

  static bool _areLordsFriendly(String l1, String l2) {
    if (l1 == l2) return true;
    const group1 = {'சூரியன்', 'சந்திரன்', 'செவ்வாய்', 'குரு'};
    const group2 = {'புதன்', 'சுக்கிரன்', 'சனி'};
    if (group1.contains(l1) && group1.contains(l2)) return true;
    if (group2.contains(l1) && group2.contains(l2)) return true;
    return false;
  }

  // ---------------------------------------------------------------------------
  // 8. Vasya Porutham (வசியப் பொருத்தம்)
  // ---------------------------------------------------------------------------
  static PoruthamItem _calculateVasyaPorutham(int femaleRasi, int maleRasi) {
    final bool matched = _isVasyaPair(femaleRasi, maleRasi);

    final desc = matched
        ? 'பெண் மற்றும் ஆண் ராசிகளிடையே வசியப் பொருத்தம் உள்ளதால் தம்பதியரிடையே அன்யோன்ய அன்பும் ஈர்ப்பும் பெருகும்.'
        : 'ராசிகளிடையே வசியப் பொருத்தம் அமையவில்லை.';

    return PoruthamItem(
      id: 'vasya',
      nameTa: 'வசியப் பொருத்தம்',
      nameEn: 'Vasya Porutham',
      status: matched ? PoruthamStatus.matched : PoruthamStatus.notMatched,
      descriptionTa: desc,
    );
  }

  static bool _isVasyaPair(int r1, int r2) {
    const Map<int, List<int>> vasyaMap = {
      0: [4, 7], // Mesham -> Simmam, Viruchigam
      1: [3, 6], // Rishabam -> Kadagam, Thulam
      2: [5], // Mithunam -> Kanni
      3: [7, 8], // Kadagam -> Viruchigam, Dhanusu
      4: [6], // Simmam -> Thulam
      5: [2, 11], // Kanni -> Mithunam, Meenam
      6: [9], // Thulam -> Makaram
      7: [3], // Viruchigam -> Kadagam
      8: [11], // Dhanusu -> Meenam
      9: [10], // Makaram -> Kumbam
      10: [11], // Kumbam -> Meenam
      11: [9], // Meenam -> Makaram
    };
    return (vasyaMap[r1]?.contains(r2) ?? false) || (vasyaMap[r2]?.contains(r1) ?? false);
  }

  // ---------------------------------------------------------------------------
  // 9. Rajju Porutham (ரஜ்ஜுப் பொருத்தம்) - CRITICAL
  // ---------------------------------------------------------------------------
  static PoruthamItem _calculateRajjuPorutham(int femaleStar, int maleStar) {
    final femaleRajju = _getRajju(femaleStar);
    final maleRajju = _getRajju(maleStar);

    final bool matched = (femaleRajju != maleRajju);

    final desc = matched
        ? 'பெண் நட்சத்திரம் (${_rajjuNameTa(femaleRajju)} ரஜ்ஜு) மற்றும் ஆண் நட்சத்திரம் (${_rajjuNameTa(maleRajju)} ரஜ்ஜு) வெவ்வேறு ரஜ்ஜுவில் அமைவதால் தீர்க்க சுமங்கலி யோகம் உண்டு.'
        : 'இருவரது நட்சத்திரங்களும் ஒரே ரஜ்ஜுவில் (${_rajjuNameTa(femaleRajju)} ரஜ்ஜு) அமைவதால் ரஜ்ஜு தோஷம் உள்ளது. இது பொருத்தமற்றது.';

    return PoruthamItem(
      id: 'rajju',
      nameTa: 'ரஜ்ஜுப் பொருத்தம்',
      nameEn: 'Rajju Porutham',
      status: matched ? PoruthamStatus.matched : PoruthamStatus.notMatched,
      descriptionTa: desc,
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

    final desc = matched
        ? 'இருவரது நட்சத்திரங்களுக்கும் இடையே வேதை (பகைத் துன்பம்) இல்லை.'
        : 'இருவரது நட்சத்திரங்களும் ஒன்றை ஒன்று வேதை (தாக்கும்) என்பதால் வேதை தோஷம் உள்ளது.';

    return PoruthamItem(
      id: 'vedha',
      nameTa: 'வேதைப் பொருத்தம்',
      nameEn: 'Vedha Porutham',
      status: matched ? PoruthamStatus.matched : PoruthamStatus.notMatched,
      descriptionTa: desc,
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
  static PoruthamItem _calculateNadiPorutham(int femaleStar, int maleStar) {
    final femaleNadi = _getNadi(femaleStar);
    final maleNadi = _getNadi(maleStar);

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
    );
  }

  static int _getNadi(int starIndex) {
    // 0: Vata, 1: Pitta, 2: Kapha
    const vata = {0, 5, 6, 11, 12, 17, 18, 23, 24};
    const pitta = {1, 4, 7, 10, 13, 16, 19, 22, 25};
    if (vata.contains(starIndex)) return 0;
    if (pitta.contains(starIndex)) return 1;
    return 2; // Kapha
  }

  static String _nadiNameTa(int nadi) {
    if (nadi == 0) return 'வாத (பார்ஸ்வ)';
    if (nadi == 1) return 'பித்த (மத்ய)';
    return 'சிலேத்தும (சமண)';
  }
}
