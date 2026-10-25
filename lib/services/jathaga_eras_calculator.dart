/// Service for calculating various historical and astrological eras/years
/// based on input date and time.
class JathagaErasCalculator {
  /// Calculate all 6 historical and astrological era years
  static Map<String, dynamic> calculateAllEras({
    required int day,
    required int month,
    required int year,
    required int hour,
    required int minute,
  }) {
    // 1. Gregorian Year
    final int gregorianYear = year;

    // 2. Thiruvalluvar Year
    // New year around January 14
    int thiruvalluvarYear = gregorianYear + 31;
    if (month == 1 && day < 14) {
      thiruvalluvarYear -= 1;
    }

    // 3. Salivahana / Saka Era
    // New year around April 14
    int salivahanaYear = gregorianYear - 78;
    if (month < 4 || (month == 4 && day < 14)) {
      salivahanaYear -= 1;
    }

    // 4. Kali Yugadhi Year
    // New year around April 14
    int kaliyugadhiYear = gregorianYear + 3102;
    if (month < 4 || (month == 4 && day < 14)) {
      kaliyugadhiYear -= 1;
    }

    // 5. Kollam Era
    // New year around August 16
    int kollamYear = gregorianYear - 824;
    if (month < 8 || (month == 8 && day < 16)) {
      kollamYear -= 1;
    }

    // 6. Fasli Year (revenue calendar starting July 1)
    int fasliYear = gregorianYear - 590;
    if (month < 7 || (month == 7 && day < 1)) {
      fasliYear -= 1;
    }

    // 7. Hijri Year
    // Astronomical Julian Day Calculation (Epoch: July 16, 622 CE)
    final int hijriYear = calculateHijriYear(gregorianYear, month, day);

    final String formattedDay = day.toString().padLeft(2, '0');
    final String formattedMonth = month.toString().padLeft(2, '0');
    final String formattedHour = hour.toString().padLeft(2, '0');
    final String formattedMinute = minute.toString().padLeft(2, '0');

    return {
      'gregorian_year': gregorianYear,
      'thiruvalluvar_year': thiruvalluvarYear,
      'salivahana_year': salivahanaYear,
      'kaliyugadhi_year': kaliyugadhiYear,
      'kollam_year': kollamYear,
      'fasli_year': fasliYear,
      'hijri_year': hijriYear,
      'formatted_date': "$formattedDay-$formattedMonth-$year",
      'formatted_time': "$formattedHour:$formattedMinute",
    };
  }

  /// Accurate astronomical calculation of Islamic (Hijri) lunar year
  static int calculateHijriYear(int year, int month, int day) {
    int y = year;
    int m = month;
    if (m <= 2) {
      y -= 1;
      m += 12;
    }
    final a = (y / 100).floor();
    final b = 2 - a + (a / 4).floor();
    final jd = (365.25 * (y + 4716)).floor() + (30.6001 * (m + 1)).floor() + day + b - 1524.5;

    // Islamic Epoch: JD 1948439.5 (July 16, 622 CE)
    // Mean synodic lunar year = 354.367068 days
    final hijriYear = ((jd - 1948439.5) / 354.367068).floor() + 1;
    return hijriYear;
  }
}
