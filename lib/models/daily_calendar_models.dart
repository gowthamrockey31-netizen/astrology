import '../services/astrology_calculator.dart';

/// Single Gowri Time Period (உத்தி, அமிர்தம், ரோகம், லாபம், தனம், விஷம், சுகம், சோரம்)
class GowriPeriod {
  final String nameTa;
  final String timeRange;
  final bool isGood;
  final String natureTa;

  const GowriPeriod({
    required this.nameTa,
    required this.timeRange,
    required this.isGood,
    required this.natureTa,
  });
}

/// Transition info for Tithi, Nakshatra, Yoga, Karana
class PanchangamTransition {
  final String currentName;
  final String currentTiming;
  final String previousName;
  final String previousTiming;
  final String nextName;
  final String nextTiming;

  const PanchangamTransition({
    required this.currentName,
    required this.currentTiming,
    required this.previousName,
    required this.previousTiming,
    required this.nextName,
    required this.nextTiming,
  });
}

/// Planet transit detail for Daily Calendar
class DailyPlanetTransit {
  final String planetKey;
  final String nameTa;
  final String nameEn;
  final String rasiNameTa;
  final String rasiNameEn;
  final int rasiIndex;
  final double degreeInRasi;
  final String formattedDegree;
  final String formattedDMS;
  final String nakshatraNameTa;
  final int pada;
  final bool isRetrograde;
  final String transitSummaryTa;

  const DailyPlanetTransit({
    required this.planetKey,
    required this.nameTa,
    required this.nameEn,
    required this.rasiNameTa,
    required this.rasiNameEn,
    required this.rasiIndex,
    required this.degreeInRasi,
    required this.formattedDegree,
    required this.formattedDMS,
    required this.nakshatraNameTa,
    required this.pada,
    required this.isRetrograde,
    required this.transitSummaryTa,
  });
}

/// Comprehensive Daily Calendar (தினசரி நாள்காட்டி) Result Data Model
class DailyCalendarData {
  final DateTime date;
  final String englishDate;
  final String weekdayTa;
  final String weekdayEn;
  final String tamilMonth;
  final int tamilDay;
  final String tamilDateFormatted;
  final String pakshaTa;
  final String nokkuNaalTa;
  final String naalVisheshamTa;

  // Sunrise / Sunset
  final String sunriseStr;
  final String sunsetStr;
  final DateTime sunriseTime;
  final DateTime sunsetTime;

  // Good Time periods
  final String morningNallaNeram;
  final String eveningNallaNeram;
  final List<GowriPeriod> dayGowriPeriods;
  final List<GowriPeriod> nightGowriPeriods;

  // Panchangam
  final String tithiNameTa;
  final String tithiPakshaTa;
  final int tithiNumber;
  final PanchangamTransition tithiTransition;

  final String nakshatraNameTa;
  final int nakshatraPada;
  final String nakshatraLordTa;
  final PanchangamTransition nakshatraTransition;

  final String yogaNameTa;
  final PanchangamTransition yogaTransition;

  final String amirthathiYogaTa;

  final String karanaNameTa;
  final PanchangamTransition karanaTransition;

  // Chandrashtama
  final String chandrashtamaRasiTa;
  final String chandrashtamaNakshatrasTa;

  // Nendhiram & Jeevan
  final String nendhiramTa;
  final String jeevanTa;

  // Inauspicious & Muhurtha Timings
  final String rahuKalam;
  final String gulikaiKalam;
  final String yamaGandam;
  final String abhijitMuhurtham;

  // Soolam & Pariharam
  final String soolamDirectionTa;
  final String pariharamTa;

  // Nazhigai Traditional Timings
  final String udayathiNazhigai;
  final String nakshatraNazhigai;

  // Transits
  final Map<String, PlanetDetail> rawPlanets;
  final List<DailyPlanetTransit> transits;
  final List<String> padaSaramNotes;
  final List<String> specialEvents;

  const DailyCalendarData({
    required this.date,
    required this.englishDate,
    required this.weekdayTa,
    required this.weekdayEn,
    required this.tamilMonth,
    required this.tamilDay,
    required this.tamilDateFormatted,
    required this.pakshaTa,
    required this.nokkuNaalTa,
    required this.naalVisheshamTa,
    required this.sunriseStr,
    required this.sunsetStr,
    required this.sunriseTime,
    required this.sunsetTime,
    required this.morningNallaNeram,
    required this.eveningNallaNeram,
    required this.dayGowriPeriods,
    required this.nightGowriPeriods,
    required this.tithiNameTa,
    required this.tithiPakshaTa,
    required this.tithiNumber,
    required this.tithiTransition,
    required this.nakshatraNameTa,
    required this.nakshatraPada,
    required this.nakshatraLordTa,
    required this.nakshatraTransition,
    required this.yogaNameTa,
    required this.yogaTransition,
    required this.amirthathiYogaTa,
    required this.karanaNameTa,
    required this.karanaTransition,
    required this.chandrashtamaRasiTa,
    required this.chandrashtamaNakshatrasTa,
    required this.nendhiramTa,
    required this.jeevanTa,
    required this.rahuKalam,
    required this.gulikaiKalam,
    required this.yamaGandam,
    required this.abhijitMuhurtham,
    required this.soolamDirectionTa,
    required this.pariharamTa,
    required this.udayathiNazhigai,
    required this.nakshatraNazhigai,
    required this.rawPlanets,
    required this.transits,
    required this.padaSaramNotes,
    required this.specialEvents,
  });
}
