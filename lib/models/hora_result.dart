/// Structured immutable data model for Hora calculation results
class HoraResult {
  final String currentHoraNameEn;
  final String currentHoraNameTa;
  final String currentHoraSymbol;
  final String nextHoraNameEn;
  final String nextHoraNameTa;
  final int horaNumber; // 1..12 (1st to 12th hora of day or night)
  final bool isDaytime;
  final DateTime horaStartTime;
  final DateTime horaEndTime;
  final Duration remainingDuration;
  final Duration elapsedDuration;
  final Duration totalHoraDuration;
  final double progressRatio; // 0.0 to 1.0
  final DateTime astrologicalDate; // Sunrise date for overnight tracking
  final String dayRulerEn;
  final String dayRulerTa;
  final DateTime sunrise;
  final DateTime sunset;

  const HoraResult({
    required this.currentHoraNameEn,
    required this.currentHoraNameTa,
    required this.currentHoraSymbol,
    required this.nextHoraNameEn,
    required this.nextHoraNameTa,
    required this.horaNumber,
    required this.isDaytime,
    required this.horaStartTime,
    required this.horaEndTime,
    required this.remainingDuration,
    required this.elapsedDuration,
    required this.totalHoraDuration,
    required this.progressRatio,
    required this.astrologicalDate,
    required this.dayRulerEn,
    required this.dayRulerTa,
    required this.sunrise,
    required this.sunset,
  });

  String get remainingFormatted {
    final mins = remainingDuration.inMinutes;
    final secs = remainingDuration.inSeconds % 60;
    return "${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}";
  }
}
