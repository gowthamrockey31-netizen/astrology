/// Birth Dasha Balance model based on Moon's longitude within Nakshatra
class KPBirthDashaBalance {
  final String planet;
  final int years;
  final int months;
  final int days;
  final DateTime startDate;
  final DateTime endDate;

  const KPBirthDashaBalance({
    required this.planet,
    required this.years,
    required this.months,
    required this.days,
    required this.startDate,
    required this.endDate,
  });

  String get durationFormatted => '$years Y, $months M, $days D';
}

/// A specific Dasha period (Mahadasha, Bhukti, Antara, or Sookshma)
class KPDashaPeriod {
  final String planet;
  final String level; // 'Mahadasha', 'Bhukti', 'Antara', 'Sookshma'
  final DateTime startDate;
  final DateTime endDate;
  final List<int> relatedHouses;
  final bool isCurrent;
  final List<KPDashaPeriod> children;

  const KPDashaPeriod({
    required this.planet,
    required this.level,
    required this.startDate,
    required this.endDate,
    required this.relatedHouses,
    this.isCurrent = false,
    this.children = const [],
  });
}

/// Dasha Hierarchy container
class KPDashaHierarchy {
  final KPBirthDashaBalance birthBalance;
  final KPDashaPeriod? currentMahadasha;
  final KPDashaPeriod? currentBhukti;
  final KPDashaPeriod? currentAntara;
  final KPDashaPeriod? currentSookshma;
  final List<KPDashaPeriod> mahadashas;

  const KPDashaHierarchy({
    required this.birthBalance,
    this.currentMahadasha,
    this.currentBhukti,
    this.currentAntara,
    this.currentSookshma,
    required this.mahadashas,
  });
}
