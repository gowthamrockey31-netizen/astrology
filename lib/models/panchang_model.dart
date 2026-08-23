class PanchangModel {
  final String id;
  final String date;
  final String tithi;
  final String nakshatra;
  final String yoga;
  final String karana;
  final String sunrise;
  final String sunset;
  final String moonrise;
  final String moonset;
  final String rahuKalam;
  final String yamagandam;
  final String kuligai;
  final String auspiciousTime;
  final String paksha;

  PanchangModel({
    required this.id,
    required this.date,
    required this.tithi,
    required this.nakshatra,
    required this.yoga,
    required this.karana,
    required this.sunrise,
    required this.sunset,
    required this.moonrise,
    required this.moonset,
    required this.rahuKalam,
    required this.yamagandam,
    required this.kuligai,
    required this.auspiciousTime,
    required this.paksha,
  });

  factory PanchangModel.today() {
    return PanchangModel(
      id: 'panchang_default',
      date: 'Today, ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
      tithi: 'Shukla Paksha Ekadashi (until 04:15 PM)',
      nakshatra: 'Rohini (until 08:30 PM)',
      yoga: 'Shubha (until 06:10 PM)',
      karana: 'Bava (until 04:15 PM)',
      sunrise: '06:05 AM',
      sunset: '06:42 PM',
      moonrise: '03:12 PM',
      moonset: '04:08 AM',
      rahuKalam: '01:30 PM - 03:00 PM',
      yamagandam: '06:00 AM - 07:30 AM',
      kuligai: '09:00 AM - 10:30 AM',
      auspiciousTime: '11:45 AM - 12:35 PM (Abhijit)',
      paksha: 'Shukla Paksha',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'tithi': tithi,
      'nakshatra': nakshatra,
      'yoga': yoga,
      'karana': karana,
      'sunrise': sunrise,
      'sunset': sunset,
      'moonrise': moonrise,
      'moonset': moonset,
      'rahuKalam': rahuKalam,
      'yamagandam': yamagandam,
      'kuligai': kuligai,
      'auspiciousTime': auspiciousTime,
      'paksha': paksha,
    };
  }

  factory PanchangModel.fromMap(Map<String, dynamic> map) {
    return PanchangModel(
      id: map['id'] ?? 'panchang_${DateTime.now().millisecondsSinceEpoch}',
      date: map['date'] ?? '',
      tithi: map['tithi'] ?? '',
      nakshatra: map['nakshatra'] ?? '',
      yoga: map['yoga'] ?? '',
      karana: map['karana'] ?? '',
      sunrise: map['sunrise'] ?? '06:05 AM',
      sunset: map['sunset'] ?? '06:42 PM',
      moonrise: map['moonrise'] ?? '03:12 PM',
      moonset: map['moonset'] ?? '04:08 AM',
      rahuKalam: map['rahuKalam'] ?? '',
      yamagandam: map['yamagandam'] ?? '',
      kuligai: map['kuligai'] ?? '',
      auspiciousTime: map['auspiciousTime'] ?? '',
      paksha: map['paksha'] ?? 'Shukla Paksha',
    );
  }
}

class PlanetPositionModel {
  final String id;
  final String planet;
  final String rasi;
  final String degrees;
  final bool isRetrograde;
  final String nakshatra;

  PlanetPositionModel({
    required this.id,
    required this.planet,
    required this.rasi,
    required this.degrees,
    required this.isRetrograde,
    required this.nakshatra,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'planet': planet,
      'rasi': rasi,
      'degrees': degrees,
      'isRetrograde': isRetrograde,
      'nakshatra': nakshatra,
    };
  }

  factory PlanetPositionModel.fromMap(Map<String, dynamic> map) {
    return PlanetPositionModel(
      id: map['id'] ?? 'planet_${DateTime.now().millisecondsSinceEpoch}',
      planet: map['planet'] ?? '',
      rasi: map['rasi'] ?? '',
      degrees: map['degrees'] ?? '',
      isRetrograde: map['isRetrograde'] ?? false,
      nakshatra: map['nakshatra'] ?? '',
    );
  }
}
