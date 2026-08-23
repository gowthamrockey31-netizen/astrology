/// Structured immutable data model for Nazhigai / Vinazhigai calculations
class NazhigaiResult {
  final int nazhigai;
  final int vinazhigai;
  final double remainingSeconds;
  final double totalElapsedSeconds;
  final String formattedValueTa;
  final String formattedValueEn;
  final DateTime sunriseTime;
  final DateTime eventTime;

  const NazhigaiResult({
    required this.nazhigai,
    required this.vinazhigai,
    required this.remainingSeconds,
    required this.totalElapsedSeconds,
    required this.formattedValueTa,
    required this.formattedValueEn,
    required this.sunriseTime,
    required this.eventTime,
  });

  @override
  String toString() => formattedValueTa;
}
