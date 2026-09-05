/// Pure mathematical calculation engine for completed age in Years, Months, and Days.
///
/// Complies with Vedic astrology birth profile rules:
/// - Real-time calculation using [DateTime.now()] or specified [asOfDateTime].
/// - Accurately handles leap years, variable month lengths (28, 29, 30, 31 days).
/// - Accurately handles birthdays today (including birth time evaluation).
/// - Strict protection against negative numbers or future birth dates.
class CurrentAgeCalculator {
  static AgeResult calculate({
    required DateTime birthDateTime,
    DateTime? asOfDateTime,
  }) {
    final now = asOfDateTime ?? DateTime.now();

    if (birthDateTime.isAfter(now)) {
      throw ArgumentError(
        'பிறந்த தேதி/நேரம் எதிர்காலமாக இருக்க முடியாது.',
      );
    }

    int years = now.year - birthDateTime.year;
    int months = now.month - birthDateTime.month;
    int days = now.day - birthDateTime.day;

    // Time-of-day precision: If today is the birthday anniversary and
    // current time has not yet reached the birth time, the year is not yet completed.
    if (now.month == birthDateTime.month &&
        now.day == birthDateTime.day &&
        (now.hour < birthDateTime.hour ||
            (now.hour == birthDateTime.hour && now.minute < birthDateTime.minute))) {
      days--;
    }

    if (days < 0) {
      months--;

      // Day 0 of the current month resolves to the last day of the previous month
      final previousMonth = DateTime(now.year, now.month, 0);
      days += previousMonth.day;
    }

    if (months < 0) {
      years--;
      months += 12;
    }

    return AgeResult(
      years: years,
      months: months,
      days: days,
    );
  }
}

class AgeResult {
  final int years;
  final int months;
  final int days;

  const AgeResult({
    required this.years,
    required this.months,
    required this.days,
  });

  String get tamilText {
    return '$years வருடம் $months மாதம் $days நாள்';
  }

  String get englishText {
    return '$years Years $months Months $days Days';
  }

  @override
  String toString() => '$tamilText ($englishText)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AgeResult &&
          runtimeType == other.runtimeType &&
          years == other.years &&
          months == other.months &&
          days == other.days;

  @override
  int get hashCode => years.hashCode ^ months.hashCode ^ days.hashCode;
}
