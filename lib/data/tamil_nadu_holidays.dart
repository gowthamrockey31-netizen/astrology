import '../models/tamil_calendar_models.dart';

/// Isolated repository of Tamil Nadu Government Holidays
/// Separated completely from festival and astronomical calculation data.
class TamilNaduHolidayData {
  /// Static holiday database keyed by "YYYY-MM-DD"
  static final Map<String, GovernmentHoliday> _holidays = {
    // --- 2025 ---
    '2025-01-01': const GovernmentHoliday(year: 2025, month: 1, day: 1, nameTa: 'புத்தாண்டு', nameEn: "New Year's Day"),
    '2025-01-14': const GovernmentHoliday(year: 2025, month: 1, day: 14, nameTa: 'பொங்கல் பண்டிகை', nameEn: 'Pongal'),
    '2025-01-15': const GovernmentHoliday(year: 2025, month: 1, day: 15, nameTa: 'திருவள்ளுவர் தினம்', nameEn: 'Thiruvalluvar Day'),
    '2025-01-16': const GovernmentHoliday(year: 2025, month: 1, day: 16, nameTa: 'உழவர் திருநாள்', nameEn: 'Uzhavar Thirunal'),
    '2025-01-26': const GovernmentHoliday(year: 2025, month: 1, day: 26, nameTa: 'குடியரசு தினம்', nameEn: 'Republic Day'),
    '2025-03-30': const GovernmentHoliday(year: 2025, month: 3, day: 30, nameTa: 'ரம்ஜான் (ஈகைத் திருநாள்)', nameEn: 'Ramzan (Idul Fitr)'),
    '2025-04-14': const GovernmentHoliday(year: 2025, month: 4, day: 14, nameTa: 'தமிழ்ப் புத்தாண்டு / அம்பேத்கர் ஜெயந்தி', nameEn: 'Tamil New Year / Dr. Ambedkar Birthday'),
    '2025-04-18': const GovernmentHoliday(year: 2025, month: 4, day: 18, nameTa: 'புனித வெள்ளி', nameEn: 'Good Friday'),
    '2025-05-01': const GovernmentHoliday(year: 2025, month: 5, day: 1, nameTa: 'மே தினம் (உழைப்பாளர் தினம்)', nameEn: 'May Day'),
    '2025-06-07': const GovernmentHoliday(year: 2025, month: 6, day: 7, nameTa: 'பக்ரீத்', nameEn: 'Bakrid'),
    '2025-07-06': const GovernmentHoliday(year: 2025, month: 7, day: 6, nameTa: 'மொஹரம்', nameEn: 'Muharram'),
    '2025-08-15': const GovernmentHoliday(year: 2025, month: 8, day: 15, nameTa: 'சுதந்திர தினம்', nameEn: 'Independence Day'),
    '2025-08-27': const GovernmentHoliday(year: 2025, month: 8, day: 27, nameTa: 'விநாயகர் சதுர்த்தி', nameEn: 'Vinayakar Chathurthi'),
    '2025-09-05': const GovernmentHoliday(year: 2025, month: 9, day: 5, nameTa: 'மிலாதுன் நபி', nameEn: 'Milad-un-Nabi'),
    '2025-10-01': const GovernmentHoliday(year: 2025, month: 10, day: 1, nameTa: 'ஆயுத பூஜை', nameEn: 'Ayutha Pooja'),
    '2025-10-02': const GovernmentHoliday(year: 2025, month: 10, day: 2, nameTa: 'விஜயதசமி / காந்தி ஜெயந்தி', nameEn: 'Vijaya Dasami / Gandhi Jayanthi'),
    '2025-10-20': const GovernmentHoliday(year: 2025, month: 10, day: 20, nameTa: 'தீபாவளி பண்டிகை', nameEn: 'Deepavali'),
    '2025-12-25': const GovernmentHoliday(year: 2025, month: 12, day: 25, nameTa: 'கிறிஸ்துமஸ்', nameEn: 'Christmas'),

    // --- 2026 ---
    '2026-01-01': const GovernmentHoliday(year: 2026, month: 1, day: 1, nameTa: 'புத்தாண்டு', nameEn: "New Year's Day"),
    '2026-01-14': const GovernmentHoliday(year: 2026, month: 1, day: 14, nameTa: 'பொங்கல் பண்டிகை', nameEn: 'Pongal'),
    '2026-01-15': const GovernmentHoliday(year: 2026, month: 1, day: 15, nameTa: 'திருவள்ளுவர் தினம்', nameEn: 'Thiruvalluvar Day'),
    '2026-01-16': const GovernmentHoliday(year: 2026, month: 1, day: 16, nameTa: 'உழவர் திருநாள்', nameEn: 'Uzhavar Thirunal'),
    '2026-01-26': const GovernmentHoliday(year: 2026, month: 1, day: 26, nameTa: 'குடியரசு தினம்', nameEn: 'Republic Day'),
    '2026-03-20': const GovernmentHoliday(year: 2026, month: 3, day: 20, nameTa: 'ரம்ஜான் (ஈகைத் திருநாள்)', nameEn: 'Ramzan (Idul Fitr)'),
    '2026-04-03': const GovernmentHoliday(year: 2026, month: 4, day: 3, nameTa: 'புனித வெள்ளி', nameEn: 'Good Friday'),
    '2026-04-14': const GovernmentHoliday(year: 2026, month: 4, day: 14, nameTa: 'தமிழ்ப் புத்தாண்டு / அம்பேத்கர் ஜெயந்தி', nameEn: 'Tamil New Year / Dr. Ambedkar Birthday'),
    '2026-05-01': const GovernmentHoliday(year: 2026, month: 5, day: 1, nameTa: 'மே தினம் (உழைப்பாளர் தினம்)', nameEn: 'May Day'),
    '2026-05-27': const GovernmentHoliday(year: 2026, month: 5, day: 27, nameTa: 'பக்ரீத்', nameEn: 'Bakrid'),
    '2026-06-25': const GovernmentHoliday(year: 2026, month: 6, day: 25, nameTa: 'மொஹரம்', nameEn: 'Muharram'),
    '2026-08-15': const GovernmentHoliday(year: 2026, month: 8, day: 15, nameTa: 'சுதந்திர தினம்', nameEn: 'Independence Day'),
    '2026-08-25': const GovernmentHoliday(year: 2026, month: 8, day: 25, nameTa: 'மிலாதுன் நபி', nameEn: 'Milad-un-Nabi'),
    '2026-09-14': const GovernmentHoliday(year: 2026, month: 9, day: 14, nameTa: 'விநாயகர் சதுர்த்தி', nameEn: 'Vinayakar Chathurthi'),
    '2026-10-02': const GovernmentHoliday(year: 2026, month: 10, day: 2, nameTa: 'காந்தி ஜெயந்தி', nameEn: 'Gandhi Jayanthi'),
    '2026-10-19': const GovernmentHoliday(year: 2026, month: 10, day: 19, nameTa: 'ஆயுத பூஜை', nameEn: 'Ayutha Pooja'),
    '2026-10-20': const GovernmentHoliday(year: 2026, month: 10, day: 20, nameTa: 'விஜயதசமி', nameEn: 'Vijaya Dasami'),
    '2026-11-08': const GovernmentHoliday(year: 2026, month: 11, day: 8, nameTa: 'தீபாவளி பண்டிகை', nameEn: 'Deepavali'),
    '2026-12-25': const GovernmentHoliday(year: 2026, month: 12, day: 25, nameTa: 'கிறிஸ்துமஸ்', nameEn: 'Christmas'),

    // --- 2027 ---
    '2027-01-01': const GovernmentHoliday(year: 2027, month: 1, day: 1, nameTa: 'புத்தாண்டு', nameEn: "New Year's Day"),
    '2027-01-14': const GovernmentHoliday(year: 2027, month: 1, day: 14, nameTa: 'பொங்கல் பண்டிகை', nameEn: 'Pongal'),
    '2027-01-15': const GovernmentHoliday(year: 2027, month: 1, day: 15, nameTa: 'திருவள்ளுவர் தினம்', nameEn: 'Thiruvalluvar Day'),
    '2027-01-16': const GovernmentHoliday(year: 2027, month: 1, day: 16, nameTa: 'உழவர் திருநாள்', nameEn: 'Uzhavar Thirunal'),
    '2027-01-26': const GovernmentHoliday(year: 2027, month: 1, day: 26, nameTa: 'குடியரசு தினம்', nameEn: 'Republic Day'),
    '2027-03-10': const GovernmentHoliday(year: 2027, month: 3, day: 10, nameTa: 'ரம்ஜான் (ஈகைத் திருநாள்)', nameEn: 'Ramzan (Idul Fitr)'),
    '2027-03-26': const GovernmentHoliday(year: 2027, month: 3, day: 26, nameTa: 'புனித வெள்ளி', nameEn: 'Good Friday'),
    '2027-04-14': const GovernmentHoliday(year: 2027, month: 4, day: 14, nameTa: 'தமிழ்ப் புத்தாண்டு / அம்பேத்கர் ஜெயந்தி', nameEn: 'Tamil New Year / Dr. Ambedkar Birthday'),
    '2027-05-01': const GovernmentHoliday(year: 2027, month: 5, day: 1, nameTa: 'மே தினம்', nameEn: 'May Day'),
    '2027-05-17': const GovernmentHoliday(year: 2027, month: 5, day: 17, nameTa: 'பக்ரீத்', nameEn: 'Bakrid'),
    '2027-08-15': const GovernmentHoliday(year: 2027, month: 8, day: 15, nameTa: 'சுதந்திர தினம்', nameEn: 'Independence Day'),
    '2027-09-04': const GovernmentHoliday(year: 2027, month: 9, day: 4, nameTa: 'விநாயகர் சதுர்த்தி', nameEn: 'Vinayakar Chathurthi'),
    '2027-10-02': const GovernmentHoliday(year: 2027, month: 10, day: 2, nameTa: 'காந்தி ஜெயந்தி', nameEn: 'Gandhi Jayanthi'),
    '2027-10-09': const GovernmentHoliday(year: 2027, month: 10, day: 9, nameTa: 'ஆயுத பூஜை', nameEn: 'Ayutha Pooja'),
    '2027-10-10': const GovernmentHoliday(year: 2027, month: 10, day: 10, nameTa: 'விஜயதசமி', nameEn: 'Vijaya Dasami'),
    '2027-10-29': const GovernmentHoliday(year: 2027, month: 10, day: 29, nameTa: 'தீபாவளி பண்டிகை', nameEn: 'Deepavali'),
    '2027-12-25': const GovernmentHoliday(year: 2027, month: 12, day: 25, nameTa: 'கிறிஸ்துமஸ்', nameEn: 'Christmas'),
  };

  /// Query Government Holiday for a given Date
  static GovernmentHoliday? getHoliday(DateTime date) {
    final key = _formatDateKey(date);
    return _holidays[key];
  }

  /// Get all holidays for a given year
  static List<GovernmentHoliday> getHolidaysForYear(int year) {
    return _holidays.values.where((h) => h.year == year).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  static String _formatDateKey(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
