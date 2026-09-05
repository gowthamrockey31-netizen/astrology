/// KP Method 2 Advantage Filter (அட்வான்டேஜ் விதிமுறை)
///
/// Rules:
/// 1. Star Even + Sub Odd -> Sub priority (Sub houses favored)
/// 2. Star Odd + Sub Even -> Star priority (Star houses favored)
/// 3. Mixed Odd + Even -> Odd priority (Odd houses take precedence)
/// 4. 1 + 12 together -> 12 ONLY (1st house is cancelled by 12th)
class KP2AdvantageFilter {
  /// Applies KP2 Advantage rule between Star Lord houses and Sub Lord houses
  static List<int> filter({
    required List<int> starHouses,
    required List<int> subHouses,
  }) {
    final sList = starHouses.toSet().toList();
    final subList = subHouses.toSet().toList();

    if (sList.isEmpty && subList.isEmpty) return [];
    if (sList.isEmpty) return cleanHouses(subList);
    if (subList.isEmpty) return cleanHouses(sList);

    final bool starAllEven = sList.every((h) => h % 2 == 0);
    final bool starAllOdd = sList.every((h) => h % 2 != 0);

    final bool subAllEven = subList.every((h) => h % 2 == 0);
    final bool subAllOdd = subList.every((h) => h % 2 != 0);

    List<int> selected;

    // Rule 1: Star Even + Sub Odd -> Sub priority
    if (starAllEven && subAllOdd) {
      selected = List<int>.from(subList);
    }
    // Rule 2: Star Odd + Sub Even -> Star priority
    else if (starAllOdd && subAllEven) {
      selected = List<int>.from(sList);
    }
    // Rule 3: Mixed Odd + Even -> Odd priority
    else {
      final combined = {...sList, ...subList}.toList();
      final oddHouses = combined.where((h) => h % 2 != 0).toList();
      if (oddHouses.isNotEmpty) {
        selected = oddHouses;
      } else {
        selected = combined;
      }
    }

    // Rule 4: 1 + 12 together -> 12 ONLY
    return cleanHouses(selected);
  }

  /// Clean, sort, deduplicate, and enforce "1 + 12 together -> 12 ONLY"
  static List<int> cleanHouses(Iterable<int> houses) {
    final set = houses.toSet();
    if (set.contains(1) && set.contains(12)) {
      set.remove(1); // 1 cancelled, 12 ONLY
    }
    final sorted = set.toList()..sort();
    return sorted;
  }
}
