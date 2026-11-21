enum PoruthamStatus {
  matched,
  notMatched,
  notCalculated,
}

class PoruthamItem {
  final String id;
  final String nameTa;
  final String nameEn;
  final PoruthamStatus status;
  final String descriptionTa;
  final String? femaleInfoTa;
  final String? maleInfoTa;
  final String? metricInfoTa;

  PoruthamItem({
    required this.id,
    required this.nameTa,
    required this.nameEn,
    required this.status,
    required this.descriptionTa,
    this.femaleInfoTa,
    this.maleInfoTa,
    this.metricInfoTa,
  });

  bool get isMatched => status == PoruthamStatus.matched;

  String get statusTextTa {
    switch (status) {
      case PoruthamStatus.matched:
        return 'பொருந்தும்';
      case PoruthamStatus.notMatched:
        return 'பொருந்தாது';
      case PoruthamStatus.notCalculated:
        return 'கணிக்கப்படவில்லை';
    }
  }
}

/// A single row in the Bhava Dosham table (Lagna, Chandran, or Sukran)
class BhavaDoshamTableRow {
  final String refNameTa; // லக்னம், சந்திரன், சுக்கிரன்
  final Map<int, List<String>> houseOccupants; // 1, 2, 4, 7, 8, 12 -> List of planet symbols
  final int planetCount;
  final double weightPerRow; // 1.0, 0.5, 0.25
  final double rowAmount;
  final String rowAmountStr; // e.g. "2", "1/2", "1/4"

  BhavaDoshamTableRow({
    required this.refNameTa,
    required this.houseOccupants,
    required this.planetCount,
    required this.weightPerRow,
    required this.rowAmount,
    required this.rowAmountStr,
  });

  /// Get formatted occupant string for a specific house column (e.g. "செ, சனி" or "-")
  String getOccupantsString(int house) {
    final list = houseOccupants[house];
    if (list == null || list.isEmpty) return '-';
    return list.join(' ');
  }
}

/// The Bhava Dosham calculation table for one person (Male or Female)
class BhavaDoshamChartData {
  final String titleTa; // e.g. "ஆண் ஜாதகத்தில் பாவதோச அளவு:"
  final List<BhavaDoshamTableRow> rows; // Lagna, Moon, Venus
  final double totalAmount;
  final String totalAmountStr; // e.g. "4 1/2" or "2 3/4"

  BhavaDoshamChartData({
    required this.titleTa,
    required this.rows,
    required this.totalAmount,
    required this.totalAmountStr,
  });
}

/// Model for Bhava Samyam Dhosham (பாவசம்யம் தோஷம்)
class BhavaSamyamResult {
  final PoruthamStatus status;
  final String titleTa;
  final String statusTextTa;
  final String descriptionTa;
  final bool isPending;
  final bool hasDetailedData;
  final BhavaDoshamChartData? maleChart;
  final BhavaDoshamChartData? femaleChart;
  final double difference;
  final String differenceStr;
  final String comparisonConclusionTa;

  const BhavaSamyamResult({
    this.status = PoruthamStatus.notCalculated,
    this.titleTa = 'பாவசம்யம் தோஷம் (Bhava Samyam Dhosham)',
    this.statusTextTa = 'கணக்கீடு நிலுவை',
    this.descriptionTa = 'பாவ சாம்ய தோஷ கணிப்புக்கு பிறப்பு விவரங்கள் தேவை.',
    this.isPending = false,
    this.hasDetailedData = false,
    this.maleChart,
    this.femaleChart,
    this.difference = 0.0,
    this.differenceStr = '0',
    this.comparisonConclusionTa = '',
  });

  bool get isMatched => status == PoruthamStatus.matched;
}

class MarriagePoruthamResult {
  final List<PoruthamItem> items;
  final int matchedCount;
  final int totalCount;
  final bool isRajjuMatched;
  final bool isVedhaMatched;
  final String overallConclusionTa;
  final String summaryDetailsTa;
  final BhavaSamyamResult bhavaSamyam;

  MarriagePoruthamResult({
    required this.items,
    required this.matchedCount,
    this.totalCount = 11,
    required this.isRajjuMatched,
    required this.isVedhaMatched,
    required this.overallConclusionTa,
    required this.summaryDetailsTa,
    this.bhavaSamyam = const BhavaSamyamResult(),
  });

  String get scoreText => '$matchedCount / $totalCount';
}
