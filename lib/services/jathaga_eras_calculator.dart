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
    int kaliyugadhiYear = gregorianYear + 3101;
    if (month < 4 || (month == 4 && day < 14)) {
      kaliyugadhiYear -= 1;
    }

    // 5. Kollam Era
    // New year around August 16
    int kollamYear = gregorianYear - 824;
    if (month < 8 || (month == 8 && day < 16)) {
      kollamYear -= 1;
    }

    // 6. Hijri Year
    // Mathematical approximation supplied by client
    final double hijriCalc = (gregorianYear - 622) * (32 / 33);
    int hijriYear = hijriCalc.floor();
    if (month > 7) {
      hijriYear += 1;
    }

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
      'hijri_year': hijriYear,
      'formatted_date': "$formattedDay-$formattedMonth-$year",
      'formatted_time': "$formattedHour:$formattedMinute",
    };
  }
}
