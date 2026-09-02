import '../models/kp_birth_data.dart';
import '../models/kp_ruling_planet.dart';
import 'kp_astronomy_engine.dart';
import 'kp_nakshatra_engine.dart';
import 'kp_sub_lord_engine.dart';

class KPRectificationCandidate {
  final DateTime candidateTime;
  final int offsetSeconds;
  final double ascendantLongitude;
  final String ascendantSignLord;
  final String ascendantStarLord;
  final String ascendantSubLord;
  final double matchingScore; // 0..100
  final List<String> matchedRulingPlanets;
  final bool isBestCandidate;

  const KPRectificationCandidate({
    required this.candidateTime,
    required this.offsetSeconds,
    required this.ascendantLongitude,
    required this.ascendantSignLord,
    required this.ascendantStarLord,
    required this.ascendantSubLord,
    required this.matchingScore,
    required this.matchedRulingPlanets,
    this.isBestCandidate = false,
  });

  String get timeFormatted {
    final h = candidateTime.hour.toString().padLeft(2, '0');
    final m = candidateTime.minute.toString().padLeft(2, '0');
    final s = candidateTime.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  String get offsetFormatted {
    if (offsetSeconds == 0) return 'Base';
    final sign = offsetSeconds > 0 ? '+' : '-';
    final mins = offsetSeconds.abs() ~/ 60;
    final secs = offsetSeconds.abs() % 60;
    if (secs == 0) return '$sign$mins m';
    return '$sign$mins m $secs s';
  }
}

/// Birth Time Rectification Engine using KP Ruling Planets methodology
class KPRectificationEngine {
  /// Generate candidate times within range minutes (e.g. 2, 5, 10) and score against Ruling Planets
  static List<KPRectificationCandidate> rectify({
    required KPBirthData birthData,
    required KPRulingPlanets rulingPlanets,
    int searchRangeMinutes = 5,
    int stepSeconds = 30,
  }) {
    final List<KPRectificationCandidate> candidates = [];
    final rulingSet = rulingPlanets.uniqueRulingPlanets.toSet();

    final int totalSecondsRange = searchRangeMinutes * 60;

    for (int offset = -totalSecondsRange; offset <= totalSecondsRange; offset += stepSeconds) {
      final candidateDt = birthData.dateTime.add(Duration(seconds: offset));
      final candidateBirth = birthData.copyWith(dateTime: candidateDt);

      final astro = KPAstronomyEngine.calculate(candidateBirth);
      final ascLong = astro.ascendant;
      final int ascRasi = (ascLong / 30.0).floor().clamp(0, 11);
      final ascSignLord = KPNakshatraEngine.signLordsEn[ascRasi];
      final ascNak = KPNakshatraEngine.calculate(ascLong);
      final ascStarLord = ascNak.lordEn;
      final ascSub = KPSubLordEngine.calculate(ascLong);
      final ascSubLord = ascSub.subLordEn;

      // Score matching against ruling planets
      final matched = <String>[];
      double score = 0.0;

      // 1. Ascendant Sub Lord match (Weight: 45%)
      if (rulingSet.contains(ascSubLord)) {
        score += 45.0;
        matched.add('Sub: $ascSubLord');
      }

      // 2. Ascendant Star Lord match (Weight: 35%)
      if (rulingSet.contains(ascStarLord)) {
        score += 35.0;
        matched.add('Star: $ascStarLord');
      }

      // 3. Ascendant Sign Lord match (Weight: 20%)
      if (rulingSet.contains(ascSignLord)) {
        score += 20.0;
        matched.add('Sign: $ascSignLord');
      }

      candidates.add(KPRectificationCandidate(
        candidateTime: candidateDt,
        offsetSeconds: offset,
        ascendantLongitude: ascLong,
        ascendantSignLord: ascSignLord,
        ascendantStarLord: ascStarLord,
        ascendantSubLord: ascSubLord,
        matchingScore: score,
        matchedRulingPlanets: matched,
      ));
    }

    // Identify the best matching candidate (highest score, tiebreaker closest to base time)
    if (candidates.isNotEmpty) {
      double maxScore = -1.0;
      int bestIdx = 0;
      int minOffsetDist = 999999;

      for (int i = 0; i < candidates.length; i++) {
        final c = candidates[i];
        if (c.matchingScore > maxScore ||
            (c.matchingScore == maxScore && c.offsetSeconds.abs() < minOffsetDist)) {
          maxScore = c.matchingScore;
          bestIdx = i;
          minOffsetDist = c.offsetSeconds.abs();
        }
      }

      candidates[bestIdx] = KPRectificationCandidate(
        candidateTime: candidates[bestIdx].candidateTime,
        offsetSeconds: candidates[bestIdx].offsetSeconds,
        ascendantLongitude: candidates[bestIdx].ascendantLongitude,
        ascendantSignLord: candidates[bestIdx].ascendantSignLord,
        ascendantStarLord: candidates[bestIdx].ascendantStarLord,
        ascendantSubLord: candidates[bestIdx].ascendantSubLord,
        matchingScore: candidates[bestIdx].matchingScore,
        matchedRulingPlanets: candidates[bestIdx].matchedRulingPlanets,
        isBestCandidate: true,
      );
    }

    return candidates;
  }
}
