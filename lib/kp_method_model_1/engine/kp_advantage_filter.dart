/// ADVANTAGE FILTER — MODEL 1
///
/// Implements the isolated Model 1 Advantage House filtering rules:
///
/// Rule 1:
///   STAR = EVEN and SUB = ODD -> SUB HOUSES HAVE PRIORITY
///
/// Rule 2:
///   STAR = ODD and SUB = EVEN -> STAR HOUSES HAVE PRIORITY
///
/// Rule 3:
///   When both contain mixed odd/even houses -> ODD HOUSES HAVE PRIORITY
///
/// Rule 4:
///   If 1 + 12 occur together -> REMOVE 1, KEEP 12
///
/// Final result is normalized: unique, sorted, validated (1..12).
class KPAdvantageFilter {
  /// Filter and return the normalized advantage houses for Model 1
  static List<int> filterAdvantageHouses({
    required List<int> starHouses,
    required List<int> subHouses,
  }) {
    // Sanitize inputs
    final validStar = starHouses.where((h) => h >= 1 && h <= 12).toSet().toList()..sort();
    final validSub = subHouses.where((h) => h >= 1 && h <= 12).toSet().toList()..sort();

    if (validStar.isEmpty && validSub.isEmpty) {
      return const [];
    }
    if (validStar.isEmpty) {
      return normalizeHouses(validSub);
    }
    if (validSub.isEmpty) {
      return normalizeHouses(validStar);
    }

    final bool isStarAllEven = validStar.every((h) => h % 2 == 0);
    final bool isStarAllOdd = validStar.every((h) => h % 2 != 0);

    final bool isSubAllEven = validSub.every((h) => h % 2 == 0);
    final bool isSubAllOdd = validSub.every((h) => h % 2 != 0);

    List<int> candidateHouses;

    // Rule 1: STAR = EVEN, SUB = ODD -> SUB HOUSES HAVE PRIORITY
    if (isStarAllEven && isSubAllOdd) {
      candidateHouses = List<int>.from(validSub);
    }
    // Rule 2: STAR = ODD, SUB = EVEN -> STAR HOUSES HAVE PRIORITY
    else if (isStarAllOdd && isSubAllEven) {
      candidateHouses = List<int>.from(validStar);
    }
    // Rule 3: When both contain mixed odd/even houses (or general case) -> ODD HOUSES HAVE PRIORITY
    else {
      final combined = <int>{...validStar, ...validSub};
      final oddHouses = combined.where((h) => h % 2 != 0).toList();

      if (oddHouses.isNotEmpty) {
        candidateHouses = oddHouses;
      } else {
        // Fallback if no odd houses exist at all: Sub houses take priority
        candidateHouses = validSub.isNotEmpty ? List<int>.from(validSub) : List<int>.from(validStar);
      }
    }

    // Rule 4: If 1 + 12 occur together -> REMOVE 1, KEEP 12
    final bool occurTogether =
        (validStar.contains(1) || validSub.contains(1)) &&
        (validStar.contains(12) || validSub.contains(12));

    final set = candidateHouses.where((h) => h >= 1 && h <= 12).toSet();

    if (occurTogether || (set.contains(1) && set.contains(12))) {
      set.remove(1);
      set.add(12);
    }

    return set.toList()..sort();
  }

  /// Public helper to normalize any list of houses applying Rule 4
  static List<int> normalizeHouses(List<int> houses) {
    final set = houses.where((h) => h >= 1 && h <= 12).toSet();
    if (set.contains(1) && set.contains(12)) {
      set.remove(1);
    }
    return set.toList()..sort();
  }
}
