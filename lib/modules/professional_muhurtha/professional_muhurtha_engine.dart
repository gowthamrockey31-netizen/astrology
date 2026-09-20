import 'dart:math' as math;
import 'professional_muhurtha_models.dart';

/// ===============================================================
/// PROFESSIONAL MUHURTHA / NALLA NERAM ENGINE
/// ===============================================================

class ProfessionalMuhurthaEngine {
  static const List<String> weekdays = [
    'ஞாயிறு',
    'திங்கள்',
    'செவ்வாய்',
    'புதன்',
    'வியாழன்',
    'வெள்ளி',
    'சனி',
  ];

  static const List<String> nakshatras = [
    'அஸ்வினி',
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
    'ஹஸ்தம்',
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

  static const List<String> rasis = [
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

  /// =============================================================
  /// MAIN API
  /// =============================================================

  MuhurthaResult calculate({
    required DateTime date,
    required GeoLocation location,
    required MuhurthaActivity activity,
    MuhurthaMode mode = MuhurthaMode.general,
    BirthProfile? birth,
  }) {
    final sunrise = _sunrise(date, location);
    final sunset = _sunset(date, location);

    final weekday = date.weekday % 7;

    final rahu = _rahu(
      sunrise,
      sunset,
      weekday,
    );

    final yama = _yamagandam(
      sunrise,
      sunset,
      weekday,
    );

    final gulikai = _gulikai(
      sunrise,
      sunset,
      weekday,
    );

    final minuteResults = <MuhurthaWindow>[];

    var current = sunrise;

    while (current.isBefore(sunset)) {
      final next = current.add(const Duration(minutes: 1));

      final evaluation = _evaluateMinute(
        time: current,
        sunrise: sunrise,
        sunset: sunset,
        weekday: weekday,
        activity: activity,
        mode: mode,
        birth: birth,
        rahu: rahu,
        yama: yama,
        gulikai: gulikai,
      );

      minuteResults.add(
        MuhurthaWindow(
          start: current,
          end: next,
          score: evaluation.score,
          category: _category(evaluation.score),
          reasons: evaluation.reasons,
        ),
      );

      current = next;
    }

    final best = _mergeWindows(
      minuteResults.where((e) => e.score >= 75).toList(),
    );

    final avoid = _mergeWindows(
      minuteResults.where((e) => e.score < 40).toList(),
    );

    final highestScore = minuteResults.isEmpty
        ? 0.0
        : minuteResults.map((e) => e.score).reduce(math.max);

    return MuhurthaResult(
      date: date,
      location: location,
      sunrise: sunrise,
      sunset: sunset,
      rahuKalam: rahu,
      yamagandam: yama,
      gulikai: gulikai,
      bestWindows: best.take(10).toList(),
      avoidWindows: avoid.take(10).toList(),
      highestScore: highestScore,
      finalRecommendation: _recommendation(highestScore),
    );
  }

  /// =============================================================
  /// MINUTE EVALUATION
  /// =============================================================

  _MinuteEvaluation _evaluateMinute({
    required DateTime time,
    required DateTime sunrise,
    required DateTime sunset,
    required int weekday,
    required MuhurthaActivity activity,
    required MuhurthaMode mode,
    required BirthProfile? birth,
    required MuhurthaWindow rahu,
    required MuhurthaWindow yama,
    required MuhurthaWindow gulikai,
  }) {
    double score = 60;

    final reasons = <String>[];

    /// -----------------------------------------------------------
    /// WEEKDAY
    /// -----------------------------------------------------------

    final weekdayScore = _weekdayScore(
      weekday,
      activity,
    );

    score += weekdayScore;

    if (weekdayScore > 0) {
      reasons.add(
        '${weekdays[weekday]} காரியத்திற்கு சாதகமான நாள்',
      );
    }

    if (weekdayScore < 0) {
      reasons.add(
        '${weekdays[weekday]} இந்த காரியத்திற்கு குறைந்த சாதகம்',
      );
    }

    /// -----------------------------------------------------------
    /// RAHU
    /// -----------------------------------------------------------

    if (_contains(rahu, time)) {
      score -= 55;
      reasons.add('ராகுகாலம்');
    }

    /// -----------------------------------------------------------
    /// YAMAGANDAM
    /// -----------------------------------------------------------

    if (_contains(yama, time)) {
      score -= 40;
      reasons.add('எமகண்டம்');
    }

    /// -----------------------------------------------------------
    /// GULIKAI
    /// -----------------------------------------------------------

    if (_contains(gulikai, time)) {
      score -= 25;
      reasons.add('குளிகை நேரம்');
    }

    /// -----------------------------------------------------------
    /// SUNRISE / SUNSET
    /// -----------------------------------------------------------

    final fromSunrise = time.difference(sunrise).inMinutes;

    final toSunset = sunset.difference(time).inMinutes;

    if (fromSunrise < 20) {
      score -= 5;
      reasons.add('சூரிய உதயத்திற்கு மிக அருகில்');
    }

    if (toSunset < 20) {
      score -= 5;
      reasons.add('சூரிய அஸ்தமனத்திற்கு மிக அருகில்');
    }

    /// -----------------------------------------------------------
    /// ACTIVITY
    /// -----------------------------------------------------------

    final activityScore = _activityScore(
      time,
      sunrise,
      sunset,
      activity,
    );

    score += activityScore;

    if (activityScore >= 5) {
      reasons.add(
        '${_activityName(activity)} நேரத்திற்கு சாதகம்',
      );
    }

    /// -----------------------------------------------------------
    /// HORA
    /// -----------------------------------------------------------

    final horaPlanet = _horaPlanet(
      time,
      sunrise,
      sunset,
      weekday,
    );

    final horaScore = _horaScore(
      horaPlanet,
      activity,
    );

    score += horaScore;

    if (horaScore >= 5) {
      reasons.add(
        '$horaPlanet ஹோரா சாதகம்',
      );
    }

    /// -----------------------------------------------------------
    /// PERSONAL MUHURTHA
    /// -----------------------------------------------------------

    if (mode == MuhurthaMode.personal && birth != null) {
      final tara = _taraBala(
        birth.birthNakshatra,
        time,
      );

      final chandra = _chandraBala(
        birth.birthRasi,
        time,
      );

      score += tara.score;
      score += chandra.score;

      reasons.addAll(tara.reasons);
      reasons.addAll(chandra.reasons);
    }

    score = score.clamp(0, 100).toDouble();

    if (score >= 75 && reasons.isEmpty) {
      reasons.add('மொத்த முகூர்த்த பலம் சாதகம்');
    }

    return _MinuteEvaluation(
      score: score,
      reasons: reasons,
    );
  }

  /// =============================================================
  /// WEEKDAY RULES
  /// =============================================================

  double _weekdayScore(
    int weekday,
    MuhurthaActivity activity,
  ) {
    switch (activity) {
      case MuhurthaActivity.marriage:
        if (weekday == 1 || weekday == 4 || weekday == 5) {
          return 12;
        }
        if (weekday == 2 || weekday == 6) {
          return -8;
        }
        return 0;

      case MuhurthaActivity.business:
        if (weekday == 3 || weekday == 4 || weekday == 5) {
          return 12;
        }
        return 2;

      case MuhurthaActivity.education:
        if (weekday == 3 || weekday == 4) {
          return 12;
        }
        return 2;

      case MuhurthaActivity.houseEntry:
      case MuhurthaActivity.houseConstruction:
        if (weekday == 1 || weekday == 3 || weekday == 4 || weekday == 5) {
          return 10;
        }
        return 0;

      case MuhurthaActivity.propertyPurchase:
        if (weekday == 3 || weekday == 4 || weekday == 5) {
          return 10;
        }
        return 0;

      case MuhurthaActivity.vehiclePurchase:
        if (weekday == 3 || weekday == 5) {
          return 8;
        }
        return 0;

      case MuhurthaActivity.travel:
        if (weekday == 1 || weekday == 3 || weekday == 5) {
          return 8;
        }
        return 0;

      case MuhurthaActivity.agriculture:
        if (weekday == 1 || weekday == 3 || weekday == 4 || weekday == 5) {
          return 10;
        }
        return 0;

      case MuhurthaActivity.naming:
        if (weekday == 1 || weekday == 3 || weekday == 4 || weekday == 5) {
          return 10;
        }
        return 0;

      case MuhurthaActivity.medical:
        return 0;

      case MuhurthaActivity.general:
        return 5;
    }
  }

  /// =============================================================
  /// ACTIVITY TIME RULES
  /// =============================================================

  double _activityScore(
    DateTime time,
    DateTime sunrise,
    DateTime sunset,
    MuhurthaActivity activity,
  ) {
    final h = time.hour + time.minute / 60.0;

    switch (activity) {
      case MuhurthaActivity.marriage:
        return h >= 7 && h <= 12 ? 8 : 0;

      case MuhurthaActivity.business:
        return h >= 9 && h <= 16 ? 8 : 0;

      case MuhurthaActivity.education:
        return h >= 6 && h <= 11 ? 8 : 0;

      case MuhurthaActivity.houseEntry:
        return h >= 6 && h <= 12 ? 8 : 0;

      case MuhurthaActivity.houseConstruction:
        return h >= 6 && h <= 12 ? 6 : 0;

      case MuhurthaActivity.propertyPurchase:
        return h >= 9 && h <= 16 ? 6 : 0;

      case MuhurthaActivity.vehiclePurchase:
        return h >= 8 && h <= 16 ? 6 : 0;

      case MuhurthaActivity.travel:
        return h >= 6 && h <= 18 ? 5 : 0;

      case MuhurthaActivity.agriculture:
        return h >= 5 && h <= 10 ? 8 : 0;

      case MuhurthaActivity.naming:
        return h >= 7 && h <= 12 ? 8 : 0;

      case MuhurthaActivity.medical:
        return 0;

      case MuhurthaActivity.general:
        return 3;
    }
  }

  /// =============================================================
  /// HORA
  /// =============================================================

  String _horaPlanet(
    DateTime time,
    DateTime sunrise,
    DateTime sunset,
    int weekday,
  ) {
    const dayRulers = [
      'சூரியன்',
      'சந்திரன்',
      'செவ்வாய்',
      'புதன்',
      'குரு',
      'சுக்கிரன்',
      'சனி',
    ];

    const horaOrder = [
      'சூரியன்',
      'சுக்கிரன்',
      'புதன்',
      'சந்திரன்',
      'சனி',
      'குரு',
      'செவ்வாய்',
    ];

    final first = dayRulers[weekday];

    int index = horaOrder.indexOf(first);

    if (index < 0) index = 0;

    final dayMinutes = sunset.difference(sunrise).inMinutes;

    final horaLength = dayMinutes / 12.0;

    final elapsed = time.difference(sunrise).inMinutes;

    final hora = (elapsed / horaLength).floor();

    final horaIdx = ((index + hora) % 7 + 7) % 7;

    return horaOrder[horaIdx];
  }

  double _horaScore(
    String planet,
    MuhurthaActivity activity,
  ) {
    switch (activity) {
      case MuhurthaActivity.marriage:
        if (planet == 'சுக்கிரன்' || planet == 'குரு' || planet == 'சந்திரன்') {
          return 8;
        }
        return 0;

      case MuhurthaActivity.business:
        if (planet == 'புதன்' || planet == 'குரு' || planet == 'சுக்கிரன்') {
          return 8;
        }
        return 0;

      case MuhurthaActivity.education:
        if (planet == 'புதன்' || planet == 'குரு' || planet == 'சந்திரன்') {
          return 8;
        }
        return 0;

      case MuhurthaActivity.travel:
        if (planet == 'சந்திரன்' || planet == 'சுக்கிரன்' || planet == 'புதன்') {
          return 6;
        }
        return 0;

      case MuhurthaActivity.propertyPurchase:
        if (planet == 'சந்திரன்' || planet == 'சுக்கிரன்' || planet == 'குரு') {
          return 7;
        }
        return 0;

      case MuhurthaActivity.vehiclePurchase:
        if (planet == 'சுக்கிரன்' || planet == 'சந்திரன்') {
          return 7;
        }
        return 0;

      case MuhurthaActivity.agriculture:
        if (planet == 'சந்திரன்' || planet == 'சுக்கிரன்') {
          return 7;
        }
        return 0;

      default:
        if (planet == 'குரு' || planet == 'சுக்கிரன்' || planet == 'புதன்') {
          return 4;
        }
        return 0;
    }
  }

  /// =============================================================
  /// TARA BALA
  /// =============================================================

  _BalanceResult _taraBala(
    int birthNakshatra,
    DateTime time,
  ) {
    final currentNakshatra = _estimatedNakshatra(time);

    final distance =
        (((currentNakshatra - birthNakshatra) % 27 + 27) % 27) + 1;

    final tara = ((distance - 1) % 9) + 1;

    const taraNames = [
      'ஜன்ம',
      'சம்பத்',
      'விபத்',
      'க்ஷேம',
      'ப்ரத்யக்',
      'சாதக',
      'நைதன',
      'மித்ர',
      'பரமமித்ர',
    ];

    final name = taraNames[tara - 1];

    if (tara == 2 || tara == 4 || tara == 6 || tara == 8 || tara == 9) {
      return _BalanceResult(
        score: 10,
        reasons: [
          'தாராபலம்: $name',
        ],
      );
    }

    if (tara == 3 || tara == 5 || tara == 7) {
      return _BalanceResult(
        score: -8,
        reasons: [
          'தாராபலம்: $name — கவனம்',
        ],
      );
    }

    return _BalanceResult(
      score: 0,
      reasons: [
        'தாராபலம்: $name',
      ],
    );
  }

  /// =============================================================
  /// CHANDRA BALA
  /// =============================================================

  _BalanceResult _chandraBala(
    int birthRasi,
    DateTime time,
  ) {
    final currentRasi = _estimatedMoonRasi(time);

    final distance = (((currentRasi - birthRasi) % 12 + 12) % 12) + 1;

    const goodHouses = {
      1,
      3,
      6,
      7,
      10,
      11,
    };

    if (goodHouses.contains(distance)) {
      return const _BalanceResult(
        score: 10,
        reasons: [
          'சந்திரபலம் சாதகம்',
        ],
      );
    }

    return const _BalanceResult(
      score: -6,
      reasons: [
        'சந்திரபலம் குறைவு',
      ],
    );
  }

  /// =============================================================
  /// APPROXIMATE NAKSHATRA
  /// =============================================================

  int _estimatedNakshatra(
    DateTime time,
  ) {
    final days =
        time.millisecondsSinceEpoch / Duration.millisecondsPerDay;

    final value = (days * 0.036) % 27;

    return value.floor();
  }

  /// =============================================================
  /// APPROXIMATE MOON RASI
  /// =============================================================

  int _estimatedMoonRasi(
    DateTime time,
  ) {
    final days =
        time.millisecondsSinceEpoch / Duration.millisecondsPerDay;

    final value = (days * 0.036 / 2.25) % 12;

    return value.floor();
  }

  /// =============================================================
  /// RAHU
  /// =============================================================

  MuhurthaWindow _rahu(
    DateTime sunrise,
    DateTime sunset,
    int weekday,
  ) {
    const segments = [
      7,
      1,
      6,
      4,
      5,
      3,
      2,
    ];

    return _daySegment(
      sunrise,
      sunset,
      segments[weekday],
      'ராகுகாலம்',
    );
  }

  /// =============================================================
  /// YAMAGANDAM
  /// =============================================================

  MuhurthaWindow _yamagandam(
    DateTime sunrise,
    DateTime sunset,
    int weekday,
  ) {
    const segments = [
      4,
      3,
      2,
      1,
      7,
      6,
      5,
    ];

    return _daySegment(
      sunrise,
      sunset,
      segments[weekday],
      'எமகண்டம்',
    );
  }

  /// =============================================================
  /// GULIKAI
  /// =============================================================

  MuhurthaWindow _gulikai(
    DateTime sunrise,
    DateTime sunset,
    int weekday,
  ) {
    const segments = [
      6,
      5,
      4,
      3,
      2,
      1,
      7,
    ];

    return _daySegment(
      sunrise,
      sunset,
      segments[weekday],
      'குளிகை',
    );
  }

  MuhurthaWindow _daySegment(
    DateTime sunrise,
    DateTime sunset,
    int segmentNumber,
    String reason,
  ) {
    final total = sunset.difference(sunrise).inSeconds;

    final segment = total / 8;

    final start = sunrise.add(
      Duration(
        seconds: ((segmentNumber - 1) * segment).round(),
      ),
    );

    final end = sunrise.add(
      Duration(
        seconds: (segmentNumber * segment).round(),
      ),
    );

    return MuhurthaWindow(
      start: start,
      end: end,
      score: 0,
      category: 'தவிர்க்கவும்',
      reasons: [reason],
    );
  }

  /// =============================================================
  /// SUNRISE
  /// =============================================================

  DateTime _sunrise(
    DateTime date,
    GeoLocation location,
  ) {
    return _solarEvent(
      date,
      location,
      sunrise: true,
    );
  }

  /// =============================================================
  /// SUNSET
  /// =============================================================

  DateTime _sunset(
    DateTime date,
    GeoLocation location,
  ) {
    return _solarEvent(
      date,
      location,
      sunrise: false,
    );
  }

  /// =============================================================
  /// SOLAR EVENT
  /// =============================================================

  DateTime _solarEvent(
    DateTime date,
    GeoLocation location, {
    required bool sunrise,
  }) {
    final n = _dayOfYear(date);

    final lngHour = location.longitude / 15;

    final approx = sunrise ? n + ((6 - lngHour) / 24) : n + ((18 - lngHour) / 24);

    final meanAnomaly = (0.9856 * approx) - 3.289;

    var longitude = meanAnomaly +
        1.916 * math.sin(_rad(meanAnomaly)) +
        0.020 * math.sin(_rad(2 * meanAnomaly)) +
        282.634;

    longitude = _normalize(longitude);

    var ra = _deg(
      math.atan(
        0.91764 * math.tan(_rad(longitude)),
      ),
    );

    ra = _normalize(ra);

    final lq = (longitude / 90).floor() * 90;

    final raq = (ra / 90).floor() * 90;

    ra += lq - raq;

    final sinDec = 0.39782 * math.sin(_rad(longitude));

    final dec = math.asin(sinDec);

    final cosDec = math.cos(dec);

    const zenith = 90.833;

    final cosH = (math.cos(_rad(zenith)) -
            sinDec * math.sin(_rad(location.latitude))) /
        (cosDec * math.cos(_rad(location.latitude)));

    if (cosH.abs() > 1) {
      return DateTime(
        date.year,
        date.month,
        date.day,
        sunrise ? 6 : 18,
      );
    }

    var h = _deg(
      math.acos(cosH),
    );

    if (sunrise) {
      h = 360 - h;
    }

    final localMean = h / 15 + ra / 15 - 0.06571 * approx - 6.622;

    var utc = localMean - lngHour;

    utc %= 24;
    if (utc < 0) {
      utc += 24;
    }

    final hour = utc.floor();

    final minute = ((utc - hour) * 60).round();

    final utcDate = DateTime.utc(
      date.year,
      date.month,
      date.day,
    );

    return utcDate
        .add(
          Duration(
            hours: hour,
            minutes: minute,
          ),
        )
        .add(
          Duration(
            minutes: (location.timeZone * 60).round(),
          ),
        );
  }

  /// =============================================================
  /// MERGE MINUTE WINDOWS
  /// =============================================================

  List<MuhurthaWindow> _mergeWindows(
    List<MuhurthaWindow> source,
  ) {
    if (source.isEmpty) {
      return [];
    }

    final sorted = [...source]
      ..sort(
        (a, b) => a.start.compareTo(b.start),
      );

    final output = <MuhurthaWindow>[];

    var current = sorted.first;

    for (int i = 1; i < sorted.length; i++) {
      final next = sorted[i];

      final gap = next.start.difference(current.end).inMinutes;

      if (gap <= 1) {
        current = MuhurthaWindow(
          start: current.start,
          end: next.end,
          score: math.max(current.score, next.score),
          category: _category(math.max(current.score, next.score)),
          reasons: {...current.reasons, ...next.reasons}.toList(),
        );
      } else {
        output.add(current);
        current = next;
      }
    }

    output.add(current);

    output.sort(
      (a, b) => b.score.compareTo(a.score),
    );

    return output;
  }

  /// =============================================================
  /// CATEGORY
  /// =============================================================

  String _category(
    double score,
  ) {
    if (score >= 90) {
      return 'மிகச் சிறப்பு';
    }

    if (score >= 80) {
      return 'சிறந்த நேரம்';
    }

    if (score >= 75) {
      return 'நல்ல நேரம்';
    }

    if (score >= 55) {
      return 'சாதாரணம்';
    }

    if (score >= 40) {
      return 'கவனம்';
    }

    return 'தவிர்க்கவும்';
  }

  String _recommendation(
    double score,
  ) {
    if (score >= 90) {
      return 'மிகச் சிறந்த முகூர்த்த நேரம் கிடைத்துள்ளது';
    }

    if (score >= 80) {
      return 'சிறந்த நல்ல நேரம் கிடைத்துள்ளது';
    }

    if (score >= 75) {
      return 'நல்ல நேரம் பயன்படுத்தலாம்';
    }

    if (score >= 55) {
      return 'சாதாரண நேரம்';
    }

    return 'மேலும் சிறந்த முகூர்த்தத்தை தேர்வு செய்யவும்';
  }

  /// =============================================================
  /// ACTIVITY NAME
  /// =============================================================

  String _activityName(
    MuhurthaActivity activity,
  ) {
    switch (activity) {
      case MuhurthaActivity.general:
        return 'பொதுவான காரியம்';
      case MuhurthaActivity.marriage:
        return 'திருமணம்';
      case MuhurthaActivity.business:
        return 'தொழில் தொடக்கம்';
      case MuhurthaActivity.houseConstruction:
        return 'வீடு கட்டுதல்';
      case MuhurthaActivity.houseEntry:
        return 'கிரகப்பிரவேசம்';
      case MuhurthaActivity.propertyPurchase:
        return 'சொத்து வாங்குதல்';
      case MuhurthaActivity.vehiclePurchase:
        return 'வாகனம் வாங்குதல்';
      case MuhurthaActivity.education:
        return 'கல்வி';
      case MuhurthaActivity.travel:
        return 'பயணம்';
      case MuhurthaActivity.agriculture:
        return 'விவசாயம்';
      case MuhurthaActivity.naming:
        return 'பெயர் சூட்டுதல்';
      case MuhurthaActivity.medical:
        return 'மருத்துவம்';
    }
  }

  /// =============================================================
  /// HELPERS
  /// =============================================================

  bool _contains(
    MuhurthaWindow window,
    DateTime time,
  ) {
    return !time.isBefore(window.start) && time.isBefore(window.end);
  }

  int _dayOfYear(
    DateTime date,
  ) {
    return date.difference(DateTime(date.year, 1, 1)).inDays + 1;
  }

  double _rad(
    double degree,
  ) {
    return degree * math.pi / 180;
  }

  double _deg(
    double radian,
  ) {
    return radian * 180 / math.pi;
  }

  double _normalize(
    double value,
  ) {
    var x = value % 360;

    if (x < 0) {
      x += 360;
    }

    return x;
  }
}

/// ===============================================================
/// INTERNAL EVALUATION CLASSES
/// ===============================================================

class _MinuteEvaluation {
  final double score;
  final List<String> reasons;

  const _MinuteEvaluation({
    required this.score,
    required this.reasons,
  });
}

class _BalanceResult {
  final double score;
  final List<String> reasons;

  const _BalanceResult({
    required this.score,
    required this.reasons,
  });
}
