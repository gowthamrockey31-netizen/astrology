/// Location details required for accurate Panchanga calculation
class PanchangaLocation {
  final String city;
  final double latitude;
  final double longitude;
  final double timezone; // UTC offset in hours, e.g. 5.5 for IST

  const PanchangaLocation({
    required this.city,
    required this.latitude,
    required this.longitude,
    required this.timezone,
  });

  static const PanchangaLocation chennai = PanchangaLocation(
    city: 'Chennai',
    latitude: 13.0827,
    longitude: 80.2707,
    timezone: 5.5,
  );

  @override
  String toString() => '$city ($latitude, $longitude, UTC+$timezone)';
}

/// Nokku Dinam (Directional Glance of the Day based on Moon's Nakshatra)
enum NokkuDinamType {
  mel('மேல் நோக்கு நாள்', 'Mel Nokku', '⬆'),
  keezh('கீழ் நோக்கு நாள்', 'Keezh Nokku', '⬇'),
  sama('சம நோக்கு நாள்', 'Sama Nokku', '↔');

  final String nameTa;
  final String nameEn;
  final String symbol;

  const NokkuDinamType(this.nameTa, this.nameEn, this.symbol);
}

/// Festival categories
enum FestivalCategory {
  hindu('Hindu', 'இந்து'),
  muslim('Muslim', 'இஸ்லாமிய'),
  christian('Christian', 'கிறிஸ்தவ'),
  jain('Jain', 'சைன'),
  buddhist('Buddhist', 'பௌத்த'),
  national('National', 'தேசிய'),
  other('Other', 'மற்றவை');

  final String labelEn;
  final String labelTa;

  const FestivalCategory(this.labelEn, this.labelTa);
}

/// Single Festival item
class FestivalItem {
  final int year;
  final int month;
  final int day;
  final String nameTa;
  final String nameEn;
  final FestivalCategory category;
  final String? description;

  const FestivalItem({
    required this.year,
    required this.month,
    required this.day,
    required this.nameTa,
    required this.nameEn,
    required this.category,
    this.description,
  });

  DateTime get date => DateTime(year, month, day);
}

/// Tamil Nadu Government Holiday definition
class GovernmentHoliday {
  final int year;
  final int month;
  final int day;
  final String nameTa;
  final String nameEn;
  final bool isGazetted;
  final bool isBankHoliday;

  const GovernmentHoliday({
    required this.year,
    required this.month,
    required this.day,
    required this.nameTa,
    required this.nameEn,
    this.isGazetted = true,
    this.isBankHoliday = true,
  });

  DateTime get date => DateTime(year, month, day);
}

/// Comprehensive Single Calendar Day Panchanga Model
class CalendarDay {
  final DateTime date;

  // Tamil Date Info
  final String tamilMonth;
  final int tamilMonthIndex; // 0..11 (0=Chithirai, 1=Vaikasi, ..., 11=Panguni)
  final int tamilDay;
  final String tamilYearName;
  final String tamilDateFormatted;

  // Weekday Info
  final String weekdayTa;
  final String weekdayEn;
  final int weekdayNumber; // 1=Mon .. 7=Sun

  // Panchanga Elements
  final String thithi;
  final int thithiNumber; // 1..30 (1..15 Shukla, 16..30 Krishna)
  final String pakshaTa;
  final String nakshatra;
  final int nakshatraIndex; // 0..26
  final int nakshatraPada; // 1..4
  final String nakshatraLord;
  final String yoga;
  final String karana;
  final String amirthathiYoga;

  // Nokku Dinam
  final NokkuDinamType nokkuDinam;

  // Muhurtham & Auspicious Status
  final bool isMuhurtham;
  final String? muhurthamType;

  // Holidays & Festivals
  final GovernmentHoliday? governmentHoliday;
  final List<FestivalItem> festivals;

  bool get isGovernmentHoliday => governmentHoliday != null;
  bool get hasFestival => festivals.isNotEmpty;
  String? get primaryFestivalName => festivals.isNotEmpty ? festivals.first.nameTa : null;

  // Location & Timings
  final PanchangaLocation location;
  final String sunrise;
  final String sunset;
  final String rahuKalam;
  final String yemakandam;
  final String kuligai;

  final String abhijit;
  final String durMuhurtham;
  final String varjyam;
  final String amritKalam;

  // Additional Astronomical Insights
  final String chandrashtamaRasi;
  final String soolamDirection;
  final String pariharam;

  const CalendarDay({
    required this.date,
    required this.tamilMonth,
    required this.tamilMonthIndex,
    required this.tamilDay,
    required this.tamilYearName,
    required this.tamilDateFormatted,
    required this.weekdayTa,
    required this.weekdayEn,
    required this.weekdayNumber,
    required this.thithi,
    required this.thithiNumber,
    required this.pakshaTa,
    required this.nakshatra,
    required this.nakshatraIndex,
    required this.nakshatraPada,
    required this.nakshatraLord,
    required this.yoga,
    required this.karana,
    required this.amirthathiYoga,
    required this.nokkuDinam,
    required this.isMuhurtham,
    this.muhurthamType,
    this.governmentHoliday,
    this.festivals = const [],
    required this.location,
    required this.sunrise,
    required this.sunset,
    required this.rahuKalam,
    required this.yemakandam,
    required this.kuligai,
    required this.abhijit,
    required this.durMuhurtham,
    required this.varjyam,
    required this.amritKalam,
    required this.chandrashtamaRasi,
    required this.soolamDirection,
    required this.pariharam,
  });
}
