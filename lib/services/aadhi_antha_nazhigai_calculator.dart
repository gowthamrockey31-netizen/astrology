import 'package:intl/intl.dart';
import 'swiss_ephemeris_calculator.dart';

/// Calculation result of Aadhi, Andha, and Parama Nazhigai (Nakshatra Duration Metrics)
class AadhiAnthaNazhigaiResult {
  final double moonLongitude;
  final int nakshatraIndex;
  final String nakshatraNameTa;
  final int pada;

  // Parama Nazhigai (பரம நாழிகை - மொத்த நட்சத்திர கால அளவு: பொதுவாக 60 நாழிகை அல்லது துல்லிய மதிப்பு)
  final double paramaNazhigaiTotal;
  final String paramaNazhigaiFormatted;

  // Aadhi Nazhigai (ஆதி நாழிகை / சென்ற நாழிகை - நட்சத்திரத்தில் இதுவரை கழிந்த நாழிகை)
  final double aadhiNazhigai;
  final String aadhiNazhigaiFormatted;

  // Andha Nazhigai (அந்த நாழிகை / மீதமுள்ள நாழிகை - நட்சத்திரத்தில் இனி இருக்கும் நாழிகை)
  final double andhaNazhigai;
  final String andhaNazhigaiFormatted;

  // Total Vinazhigai metrics (மொத்த விநாடிகள்)
  final int totalVinadi;
  final double padaVinadi;
  final int aadhiVinadi;
  final int andhaVinadi;

  // Progress Percentage
  final double progressPercent;

  // --- Exposed outputs required by Nakshatra Duration Metrics specification ---
  // 1. Nakshatra start time
  final DateTime? nakshatraStartTime;
  final String nakshatraStartTimeFormatted;

  // 2. Nakshatra end time
  final DateTime? nakshatraEndTime;
  final String nakshatraEndTimeFormatted;

  // 3. Original duration
  final Duration? originalDuration;
  final String originalDurationFormatted;

  // 4. Converted duration
  final String convertedDurationFormatted;

  // 5. Nazhigai (X)
  final int nazhigai;

  // 6. Vinadi (Y)
  final int vinadi;

  // 7. Total working units (X * 60 + Y)
  final int totalWorkingUnits;

  // 8. One-Pada duration (totalUnits / 4)
  final double onePadaDuration;
  final String padaDurationFormatted;

  // 9. Duration of all 4 Padas
  final List<double> padaDurations;

  const AadhiAnthaNazhigaiResult({
    required this.moonLongitude,
    required this.nakshatraIndex,
    required this.nakshatraNameTa,
    required this.pada,
    required this.paramaNazhigaiTotal,
    required this.paramaNazhigaiFormatted,
    required this.aadhiNazhigai,
    required this.aadhiNazhigaiFormatted,
    required this.andhaNazhigai,
    required this.andhaNazhigaiFormatted,
    this.totalVinadi = 3600,
    this.padaVinadi = 900.0,
    this.aadhiVinadi = 0,
    this.andhaVinadi = 3600,
    required this.progressPercent,
    this.nakshatraStartTime,
    this.nakshatraStartTimeFormatted = '',
    this.nakshatraEndTime,
    this.nakshatraEndTimeFormatted = '',
    this.originalDuration,
    this.originalDurationFormatted = '',
    this.convertedDurationFormatted = '',
    this.nazhigai = 60,
    this.vinadi = 0,
    this.totalWorkingUnits = 3600,
    this.onePadaDuration = 900.0,
    this.padaDurationFormatted = '',
    this.padaDurations = const [900.0, 900.0, 900.0, 900.0],
  });
}

/// Aadhi, Andha, Parama Nazhigai Calculator Service
class AadhiAnthaNazhigaiCalculator {
  /// Calculate Aadhi, Andha, and Parama Nazhigai from Moon Longitude or exact Timings
  static AadhiAnthaNazhigaiResult calculate({
    required double moonLongitude,
    required String nakshatraNameTa,
    DateTime? birthDateTime,
    double utcOffsetHours = 5.5,
    DateTime? nakshatraStartTime,
    DateTime? nakshatraEndTime,
    double standardParamaNazhigai = 60.0,
  }) {
    const double nakSpan = 360.0 / 27.0; // 13.333333° (13° 20')
    const double padaSpan = nakSpan / 4.0; // 3.333333° (3° 20')

    final double normLong = moonLongitude % 360.0;
    final int nakIdx = (normLong / nakSpan).floor() % 27;
    final double offset = normLong - (nakIdx * nakSpan);
    final int pada = ((offset / padaSpan).floor()).clamp(0, 3) + 1;

    // Progress fraction (0.0 to 1.0) through the current Nakshatra
    final double fraction = (offset / nakSpan).clamp(0.0, 1.0);

    DateTime? startTime = nakshatraStartTime;
    DateTime? endTime = nakshatraEndTime;
    Duration? duration;

    if (startTime == null || endTime == null) {
      if (birthDateTime != null) {
        final timings = calculateNakshatraTimings(
          birthDateTime: birthDateTime,
          utcOffsetHours: utcOffsetHours,
        );
        startTime = timings.startTime;
        endTime = timings.endTime;
        duration = timings.duration;
      }
    } else {
      if (endTime.isBefore(startTime)) {
        endTime = endTime.add(const Duration(days: 1));
      }
      duration = endTime.difference(startTime);
    }

    if (duration != null && startTime != null && endTime != null) {
      final int totalHours = duration.inHours;
      final int remainingMinutes = duration.inMinutes % 60;

      final (finalNazhigai, finalVinadi, totalUnits) = convertDurationToNazhigai(
        hours: totalHours,
        minutes: remainingMinutes,
      );

      final double paramaNazhiTotal = totalUnits / 60.0;
      final double padaDuration = totalUnits / 4.0;

      // Elapsed duration from Nakshatra start to birthDateTime
      int aadhiUnits;
      if (birthDateTime != null && !birthDateTime.isBefore(startTime)) {
        final elapsed = birthDateTime.difference(startTime);
        final elHours = elapsed.inHours;
        final elMins = elapsed.inMinutes % 60;
        final (_, _, elUnits) = convertDurationToNazhigai(hours: elHours, minutes: elMins);
        aadhiUnits = elUnits.clamp(0, totalUnits);
      } else {
        aadhiUnits = (fraction * totalUnits).round().clamp(0, totalUnits);
      }

      final int andhaUnits = (totalUnits - aadhiUnits).clamp(0, totalUnits);
      final double aadhiNazhi = aadhiUnits / 60.0;
      final double andhaNazhi = andhaUnits / 60.0;
      final double progressPercent = totalUnits > 0 ? (aadhiUnits / totalUnits) * 100.0 : 0.0;

      final startFormatted = DateFormat('dd-MM-yyyy hh:mm a').format(startTime);
      final endFormatted = DateFormat('dd-MM-yyyy hh:mm a').format(endTime);
      final durFormatted = '$totalHours மணி $remainingMinutes நிமிடம்';

      final padaNazhi = (padaDuration / 60.0).floor();
      final padaRemVinadi = padaDuration - (padaNazhi * 60.0);
      final padaFormatted = (padaRemVinadi == padaRemVinadi.roundToDouble())
          ? '$padaNazhi நாழிகை ${padaRemVinadi.round()} வினாடி'
          : '$padaNazhi நாழிகை ${padaRemVinadi.toStringAsFixed(2)} வினாடி ($padaDuration விநாடி)';

      return AadhiAnthaNazhigaiResult(
        moonLongitude: moonLongitude,
        nakshatraIndex: nakIdx,
        nakshatraNameTa: nakshatraNameTa,
        pada: pada,
        paramaNazhigaiTotal: paramaNazhiTotal,
        paramaNazhigaiFormatted: formatNazhigaiFromVinadi(totalUnits),
        aadhiNazhigai: aadhiNazhi,
        aadhiNazhigaiFormatted: formatNazhigaiFromVinadi(aadhiUnits),
        andhaNazhigai: andhaNazhi,
        andhaNazhigaiFormatted: formatNazhigaiFromVinadi(andhaUnits),
        totalVinadi: totalUnits,
        padaVinadi: padaDuration,
        aadhiVinadi: aadhiUnits,
        andhaVinadi: andhaUnits,
        progressPercent: progressPercent,
        nakshatraStartTime: startTime,
        nakshatraStartTimeFormatted: startFormatted,
        nakshatraEndTime: endTime,
        nakshatraEndTimeFormatted: endFormatted,
        originalDuration: duration,
        originalDurationFormatted: durFormatted,
        convertedDurationFormatted: formatNazhigaiFromVinadi(totalUnits),
        nazhigai: finalNazhigai,
        vinadi: finalVinadi,
        totalWorkingUnits: totalUnits,
        onePadaDuration: padaDuration,
        padaDurationFormatted: padaFormatted,
        padaDurations: [padaDuration, padaDuration, padaDuration, padaDuration],
      );
    }

    // Fallback when neither start/end times nor birthDateTime are supplied
    final int totalVinadi = (standardParamaNazhigai * 60.0).round();
    final double padaVinadi = totalVinadi / 4.0;

    final int aadhiVinadi = (fraction * totalVinadi).round();
    final int andhaVinadi = totalVinadi - aadhiVinadi;

    final double aadhi = aadhiVinadi / 60.0;
    final double andha = andhaVinadi / 60.0;

    final int defNazhi = standardParamaNazhigai.floor();
    final int defVinadi = ((standardParamaNazhigai - defNazhi) * 60).round();
    final padaNazhi = (padaVinadi / 60.0).floor();
    final padaRemVinadi = (padaVinadi - (padaNazhi * 60.0)).round();

    return AadhiAnthaNazhigaiResult(
      moonLongitude: moonLongitude,
      nakshatraIndex: nakIdx,
      nakshatraNameTa: nakshatraNameTa,
      pada: pada,
      paramaNazhigaiTotal: standardParamaNazhigai,
      paramaNazhigaiFormatted: formatNazhigaiFromVinadi(totalVinadi),
      aadhiNazhigai: aadhi,
      aadhiNazhigaiFormatted: formatNazhigaiFromVinadi(aadhiVinadi),
      andhaNazhigai: andha,
      andhaNazhigaiFormatted: formatNazhigaiFromVinadi(andhaVinadi),
      totalVinadi: totalVinadi,
      padaVinadi: padaVinadi,
      aadhiVinadi: aadhiVinadi,
      andhaVinadi: andhaVinadi,
      progressPercent: fraction * 100.0,
      nazhigai: defNazhi,
      vinadi: defVinadi,
      totalWorkingUnits: totalVinadi,
      onePadaDuration: padaVinadi,
      padaDurationFormatted: '$padaNazhi நாழிகை $padaRemVinadi வினாடி',
      padaDurations: [padaVinadi, padaVinadi, padaVinadi, padaVinadi],
    );
  }

  /// High-precision calculation of Nakshatra start and end times
  /// Reuses existing SwissEphemerisCalculator moon sidereal positions
  static ({DateTime startTime, DateTime endTime, Duration duration}) calculateNakshatraTimings({
    required DateTime birthDateTime,
    double utcOffsetHours = 5.5,
  }) {
    final sm = SwissEphemerisCalculator.calculateSunMoonSidereal(birthDateTime, utcOffsetHours: utcOffsetHours);
    const double nakSpan = 360.0 / 27.0; // 13.333333333333334°
    final int currentIdx = (sm.moon / nakSpan).floor() % 27;

    // 1. Find end time (forward search)
    final targetEndBoundary = ((currentIdx + 1) * nakSpan) % 360.0;
    final effectiveEndTarget = (targetEndBoundary == 0.0) ? 360.0 : targetEndBoundary;

    bool isPastEnd(double angle) {
      if (effectiveEndTarget == 360.0) {
        return angle < (currentIdx * nakSpan) || angle >= 360.0;
      }
      return angle >= effectiveEndTarget;
    }

    DateTime endLower = birthDateTime;
    DateTime endUpper = birthDateTime.add(const Duration(hours: 36));

    DateTime t = endLower;
    while (t.isBefore(endUpper)) {
      final nextT = t.add(const Duration(minutes: 10));
      final a1 = SwissEphemerisCalculator.calculateSunMoonSidereal(t, utcOffsetHours: utcOffsetHours).moon;
      final a2 = SwissEphemerisCalculator.calculateSunMoonSidereal(nextT, utcOffsetHours: utcOffsetHours).moon;
      if (!isPastEnd(a1) && isPastEnd(a2)) {
        endLower = t;
        endUpper = nextT;
        break;
      }
      t = nextT;
    }

    while (endUpper.difference(endLower).inSeconds > 1) {
      final mid = endLower.add(Duration(milliseconds: endUpper.difference(endLower).inMilliseconds ~/ 2));
      final aMid = SwissEphemerisCalculator.calculateSunMoonSidereal(mid, utcOffsetHours: utcOffsetHours).moon;
      if (isPastEnd(aMid)) {
        endUpper = mid;
      } else {
        endLower = mid;
      }
    }
    final exactEnd = endLower.add(Duration(seconds: endUpper.difference(endLower).inSeconds ~/ 2));
    final endMinute = (exactEnd.second >= 30) ? exactEnd.minute + 1 : exactEnd.minute;
    final nakEndTime = DateTime(exactEnd.year, exactEnd.month, exactEnd.day, exactEnd.hour, endMinute);

    // 2. Find start time (backward search)
    final startTarget = currentIdx * nakSpan;
    bool isBeforeStart(double angle) {
      if (currentIdx == 0) {
        return angle > 300.0;
      }
      return angle < startTarget && angle > (startTarget - nakSpan - 5.0);
    }

    DateTime startLower = birthDateTime.subtract(const Duration(hours: 36));
    DateTime startUpper = birthDateTime;

    DateTime bt = birthDateTime;
    while (bt.isAfter(startLower)) {
      final prevT = bt.subtract(const Duration(minutes: 10));
      final a1 = SwissEphemerisCalculator.calculateSunMoonSidereal(prevT, utcOffsetHours: utcOffsetHours).moon;
      final a2 = SwissEphemerisCalculator.calculateSunMoonSidereal(bt, utcOffsetHours: utcOffsetHours).moon;
      if (isBeforeStart(a1) && !isBeforeStart(a2)) {
        startLower = prevT;
        startUpper = bt;
        break;
      }
      bt = prevT;
    }

    while (startUpper.difference(startLower).inSeconds > 1) {
      final mid = startLower.add(Duration(milliseconds: startUpper.difference(startLower).inMilliseconds ~/ 2));
      final aMid = SwissEphemerisCalculator.calculateSunMoonSidereal(mid, utcOffsetHours: utcOffsetHours).moon;
      if (isBeforeStart(aMid)) {
        startLower = mid;
      } else {
        startUpper = mid;
      }
    }
    final exactStart = startLower.add(Duration(seconds: startUpper.difference(startLower).inSeconds ~/ 2));
    final startMinute = (exactStart.second >= 30) ? exactStart.minute + 1 : exactStart.minute;
    final nakStartTime = DateTime(exactStart.year, exactStart.month, exactStart.day, exactStart.hour, startMinute);

    DateTime finalEnd = nakEndTime;
    if (finalEnd.isBefore(nakStartTime)) {
      finalEnd = finalEnd.add(const Duration(days: 1));
    }
    final duration = finalEnd.difference(nakStartTime);

    return (startTime: nakStartTime, endTime: finalEnd, duration: duration);
  }

  /// Convert Hours and Minutes duration to Nazhigai & Vinazhigai
  /// Formula:
  /// Hours * 5/2 = Nazhigai (1 hour = 2.5 Nazhigai = 2 Nazhigai 30 Vinazhigai)
  /// Minutes * 5/2 = Vinazhigai (1 min = 2.5 Vinazhigai)
  static (int nazhigai, int vinadi, int totalVinadi) convertDurationToNazhigai({
    required int hours,
    required int minutes,
  }) {
    final double nazhiFromHours = hours * 2.5;
    final double vinadiFromMins = minutes * 2.5;

    final int baseNazhi = nazhiFromHours.floor();
    final double extraVinadiFromHours = (nazhiFromHours - baseNazhi) * 60.0;

    final double totalVinadiSum = extraVinadiFromHours + vinadiFromMins;
    final int addNazhi = (totalVinadiSum / 60.0).floor();
    final int remVinadi = (totalVinadiSum - (addNazhi * 60.0)).round();

    int finalNazhigai = baseNazhi + addNazhi;
    int finalVinadi = remVinadi;
    if (finalVinadi >= 60) {
      finalNazhigai += (finalVinadi ~/ 60);
      finalVinadi = finalVinadi % 60;
    }
    final int totalVinadi = (finalNazhigai * 60) + finalVinadi;

    return (finalNazhigai, finalVinadi, totalVinadi);
  }

  /// Calculate Nakshatra metrics from traditional Panchang duration
  static AadhiAnthaNazhigaiResult calculateFromDuration({
    required String nakshatraNameTa,
    required int durationHours,
    required int durationMinutes,
    required int elapsedNazhigai,
    required int elapsedVinadi,
    DateTime? nakshatraStartTime,
    DateTime? nakshatraEndTime,
    double moonLongitude = 0.0,
    int nakshatraIndex = 0,
  }) {
    final (finalNazhigai, finalVinadi, totalVinadi) = convertDurationToNazhigai(
      hours: durationHours,
      minutes: durationMinutes,
    );

    final double paramaNazhiTotal = totalVinadi / 60.0;
    final double padaVinadi = totalVinadi / 4.0;

    final int aadhiVinadi = (elapsedNazhigai * 60) + elapsedVinadi;
    final int andhaVinadi = (totalVinadi - aadhiVinadi).clamp(0, totalVinadi);

    final double aadhiNazhigai = aadhiVinadi / 60.0;
    final double andhaNazhigai = andhaVinadi / 60.0;

    final int pada = padaVinadi > 0 ? ((aadhiVinadi / padaVinadi).floor()).clamp(0, 3) + 1 : 1;
    final double progressPercent = totalVinadi > 0 ? (aadhiVinadi / totalVinadi) * 100.0 : 0.0;

    final dur = Duration(hours: durationHours, minutes: durationMinutes);
    final durFormatted = '$durationHours மணி $durationMinutes நிமிடம்';

    final padaNazhi = (padaVinadi / 60.0).floor();
    final padaRemVinadi = padaVinadi - (padaNazhi * 60.0);
    final padaFormatted = (padaRemVinadi == padaRemVinadi.roundToDouble())
        ? '$padaNazhi நாழிகை ${padaRemVinadi.round()} வினாடி'
        : '$padaNazhi நாழிகை ${padaRemVinadi.toStringAsFixed(2)} வினாடி ($padaVinadi விநாடி)';

    final startFormatted = nakshatraStartTime != null ? DateFormat('dd-MM-yyyy hh:mm a').format(nakshatraStartTime) : '';
    final endFormatted = nakshatraEndTime != null ? DateFormat('dd-MM-yyyy hh:mm a').format(nakshatraEndTime) : '';

    return AadhiAnthaNazhigaiResult(
      moonLongitude: moonLongitude,
      nakshatraIndex: nakshatraIndex,
      nakshatraNameTa: nakshatraNameTa,
      pada: pada,
      paramaNazhigaiTotal: paramaNazhiTotal,
      paramaNazhigaiFormatted: formatNazhigaiFromVinadi(totalVinadi),
      aadhiNazhigai: aadhiNazhigai,
      aadhiNazhigaiFormatted: formatNazhigaiFromVinadi(aadhiVinadi),
      andhaNazhigai: andhaNazhigai,
      andhaNazhigaiFormatted: formatNazhigaiFromVinadi(andhaVinadi),
      totalVinadi: totalVinadi,
      padaVinadi: padaVinadi,
      aadhiVinadi: aadhiVinadi,
      andhaVinadi: andhaVinadi,
      progressPercent: progressPercent,
      nakshatraStartTime: nakshatraStartTime,
      nakshatraStartTimeFormatted: startFormatted,
      nakshatraEndTime: nakshatraEndTime,
      nakshatraEndTimeFormatted: endFormatted,
      originalDuration: dur,
      originalDurationFormatted: durFormatted,
      convertedDurationFormatted: formatNazhigaiFromVinadi(totalVinadi),
      nazhigai: finalNazhigai,
      vinadi: finalVinadi,
      totalWorkingUnits: totalVinadi,
      onePadaDuration: padaVinadi,
      padaDurationFormatted: padaFormatted,
      padaDurations: [padaVinadi, padaVinadi, padaVinadi, padaVinadi],
    );
  }

  /// Formats Nazhigai & Vinadi from total Vinadi count
  static String formatNazhigaiFromVinadi(int totalVinadi) {
    final int nazhi = (totalVinadi / 60).floor();
    final int vinadi = totalVinadi % 60;
    return "$nazhi நாழிகை $vinadi வினாடி";
  }
}
