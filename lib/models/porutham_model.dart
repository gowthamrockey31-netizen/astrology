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

  PoruthamItem({
    required this.id,
    required this.nameTa,
    required this.nameEn,
    required this.status,
    required this.descriptionTa,
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

class MarriagePoruthamResult {
  final List<PoruthamItem> items;
  final int matchedCount;
  final int totalCount;
  final bool isRajjuMatched;
  final bool isVedhaMatched;
  final String overallConclusionTa;
  final String summaryDetailsTa;

  MarriagePoruthamResult({
    required this.items,
    required this.matchedCount,
    this.totalCount = 11,
    required this.isRajjuMatched,
    required this.isVedhaMatched,
    required this.overallConclusionTa,
    required this.summaryDetailsTa,
  });

  String get scoreText => '$matchedCount / $totalCount';
}
