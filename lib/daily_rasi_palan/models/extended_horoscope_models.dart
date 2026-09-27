// ===============================================================
// EXTENDED HOROSCOPE MODELS (வாராந்திர, மாதாந்திர, வருடாந்திர)
// Data structures for Weekly, Monthly and Yearly Rasi Palan
// ===============================================================

import 'package:flutter/foundation.dart';
import 'rasi_palan_models.dart';

/// Horoscope Timeframe Period
enum HoroscopePeriod {
  daily('தினசரி', 'Daily'),
  weekly('வாராந்திர', 'Weekly'),
  monthly('மாதாந்திர', 'Monthly'),
  yearly('வருடாந்திர', 'Yearly');

  final String tamilName;
  final String englishName;

  const HoroscopePeriod(this.tamilName, this.englishName);
}

/// Period transit breakdown highlight (e.g. Start-of-week, Mid-week, End-of-week)
@immutable
class TransitPeriodHighlight {
  final String title;
  final String dateRange;
  final String description;
  final bool isAuspicious; // true = positive/favorable, false = caution

  const TransitPeriodHighlight({
    required this.title,
    required this.dateRange,
    required this.description,
    required this.isAuspicious,
  });
}

/// Complete Weekly Horoscope for a single Rasi over a 7-day period
@immutable
class WeeklyRasiPalan {
  final Rasi rasi;
  final DateTime startDate;
  final DateTime endDate;
  final int score; // 0..100
  final int rating; // 1..5 stars
  final String general; // பொதுப்பலன்
  final String career; // தொழில் / வேலை
  final String finance; // பணவரவு
  final String love; // காதல் / திருமணம்
  final String family; // குடும்பம்
  final String health; // ஆரோக்கியம்
  final String education; // கல்வி
  final String business; // தொழில் / வியாபாரம்
  final String travel; // பயணம்
  final String luckyColor; // அதிர்ஷ்ட நிறம்
  final int luckyNumber; // அதிர்ஷ்ட எண்
  final String luckyDays; // சாதகமான நாட்கள்
  final String cautionDays; // கவனமான நாட்கள்
  final String caution; // கவனம்
  final String remedy; // பரிகாரம்
  final List<TransitPeriodHighlight> periodHighlights;
  final Map<int, int> dailyScores; // Day 0..6 -> score

  const WeeklyRasiPalan({
    required this.rasi,
    required this.startDate,
    required this.endDate,
    required this.score,
    required this.rating,
    required this.general,
    required this.career,
    required this.finance,
    required this.love,
    required this.family,
    required this.health,
    required this.education,
    required this.business,
    required this.travel,
    required this.luckyColor,
    required this.luckyNumber,
    required this.luckyDays,
    required this.cautionDays,
    required this.caution,
    required this.remedy,
    required this.periodHighlights,
    required this.dailyScores,
  });
}

/// Complete Monthly Horoscope for a single Rasi over a calendar month
@immutable
class MonthlyRasiPalan {
  final Rasi rasi;
  final int year;
  final int month;
  final DateTime startDate;
  final DateTime endDate;
  final int score;
  final int rating;
  final String general;
  final String career;
  final String finance;
  final String love;
  final String family;
  final String health;
  final String education;
  final String business;
  final String travel;
  final String luckyColor;
  final int luckyNumber;
  final String auspiciousPeriod; // சுப நாட்கள்
  final String cautionPeriod; // சந்திராஷ்டமம் / கவன நாட்கள்
  final String caution;
  final String remedy;
  final List<TransitPeriodHighlight> periodBreakdowns; // Beginning, Middle, End of month

  const MonthlyRasiPalan({
    required this.rasi,
    required this.year,
    required this.month,
    required this.startDate,
    required this.endDate,
    required this.score,
    required this.rating,
    required this.general,
    required this.career,
    required this.finance,
    required this.love,
    required this.family,
    required this.health,
    required this.education,
    required this.business,
    required this.travel,
    required this.luckyColor,
    required this.luckyNumber,
    required this.auspiciousPeriod,
    required this.cautionPeriod,
    required this.caution,
    required this.remedy,
    required this.periodBreakdowns,
  });
}

/// Single Month Summary Item for Yearly Horoscope
@immutable
class MonthlySummaryItem {
  final int month;
  final String monthNameTa;
  final String monthNameEn;
  final int score;
  final int rating;
  final String summary;
  final String planetaryAspect;

  const MonthlySummaryItem({
    required this.month,
    required this.monthNameTa,
    required this.monthNameEn,
    required this.score,
    required this.rating,
    required this.summary,
    required this.planetaryAspect,
  });
}

/// Complete Yearly Horoscope for a single Rasi over a full calendar year
@immutable
class YearlyRasiPalan {
  final Rasi rasi;
  final int year;
  final DateTime startDate;
  final DateTime endDate;
  final int score;
  final int rating;
  final String general; // ஆண்டுப் பொதுப்பலன்
  final String career;
  final String finance;
  final String love;
  final String family;
  final String health;
  final String education;
  final String business;
  final String travel;
  final String luckyColor;
  final int luckyNumber;
  final String majorTransitInfluences; // குரு, சனி, ராகு-கேது பெயர்ச்சி தாக்கம்
  final String favorableMonths; // அதிக நன்மை தரும் மாதங்கள்
  final String cautionMonths; // கவனம் தேவைப்படும் மாதங்கள்
  final String caution;
  final String remedy;
  final List<MonthlySummaryItem> monthSummaries; // 12 calendar months

  const YearlyRasiPalan({
    required this.rasi,
    required this.year,
    required this.startDate,
    required this.endDate,
    required this.score,
    required this.rating,
    required this.general,
    required this.career,
    required this.finance,
    required this.love,
    required this.family,
    required this.health,
    required this.education,
    required this.business,
    required this.travel,
    required this.luckyColor,
    required this.luckyNumber,
    required this.majorTransitInfluences,
    required this.favorableMonths,
    required this.cautionMonths,
    required this.caution,
    required this.remedy,
    required this.monthSummaries,
  });
}
