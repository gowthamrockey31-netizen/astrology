import 'package:intl/intl.dart';
import 'kp2_planet.dart';

/// Birth-time Dasha Balance
class KP2DashaBalance {
  final KP2Planet lord;
  final int years;
  final int months;
  final int days;
  final double balanceYears;

  const KP2DashaBalance({
    required this.lord,
    required this.years,
    required this.months,
    required this.days,
    required this.balanceYears,
  });

  String get formattedTamil =>
      '${lord.nameTa} தசா இருப்பு: $years வருடம் $months மாதம் $days நாள்';
}

/// Dasha / Bhukti / Antara / Sookshma Period
class KP2DashaPeriod {
  final KP2Planet lord;
  final int level; // 1: Maha, 2: Bhukti, 3: Antara, 4: Sookshma
  final DateTime startDate;
  final DateTime endDate;
  final List<KP2DashaPeriod> subPeriods;

  const KP2DashaPeriod({
    required this.lord,
    required this.level,
    required this.startDate,
    required this.endDate,
    this.subPeriods = const [],
  });

  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate);
  }

  String get dateRangeFormatted {
    final df = DateFormat('dd/MM/yyyy');
    return '${df.format(startDate)} - ${df.format(endDate)}';
  }
}
