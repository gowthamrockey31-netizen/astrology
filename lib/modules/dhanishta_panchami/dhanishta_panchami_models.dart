// ===============================================================
// DHANISHTA PANCHAMI / TITHI ADAIPPU - MODELS
// ===============================================================

import '../../services/swiss_ephemeris_calculator.dart';

class AdaippuData {
  final int months;
  final String type;

  const AdaippuData(this.months, this.type);
}

class DhanistaResult {
  final DateTime deathDateTime;
  final String place;
  final double latitude;
  final double longitude;
  final double sunLongitude;
  final double moonLongitude;
  final String nakshatra;
  final int nakshatraNumber; // 1..27 (Avittam = 23, Revati = 27)
  final int pada; // 1..4
  final String tithi;
  final int tithiNumber; // 1..30
  final String pakshaTamil;
  final bool isPanchaka;
  final bool isDhanishtaPanchami;
  final bool isAdaippu; // same as isAdaippuNakshatra
  final int closureMonths; // same as adaippuMonths
  final String closureType; // e.g. 'ஆறு மாத அடைப்பு'
  final DateTime? closureEndDate;
  final String statusTamil;
  final String explanation;
  final List<String> remedies;
  final String disclaimer;

  const DhanistaResult({
    required this.deathDateTime,
    this.place = 'Chennai',
    this.latitude = 13.0827,
    this.longitude = 80.2707,
    required this.sunLongitude,
    required this.moonLongitude,
    required this.nakshatra,
    required this.nakshatraNumber,
    required this.pada,
    required this.tithi,
    required this.tithiNumber,
    required this.pakshaTamil,
    required this.isPanchaka,
    required this.isDhanishtaPanchami,
    required this.isAdaippu,
    required this.closureMonths,
    required this.closureType,
    this.closureEndDate,
    required this.statusTamil,
    required this.explanation,
    required this.remedies,
    this.disclaimer =
        'இவை பாரம்பரிய/சம்பிரதாய வழிமுறைகள். குடும்ப குலாசாரம் மற்றும் தகுந்த ஆசார்யர்/புரோகிதரின் வழிகாட்டுதலை முன்னுரிமையாகக் கொள்ளவும்.',
  });

  // Backward-compatibility getters for existing code & tests
  String get nakshatraTamil => nakshatra;
  String get tithiTamil => tithi;
  bool get isAdaippuNakshatra => isAdaippu;
  int get adaippuMonths => closureMonths;
  String get adaippuType => closureType;
  String get remedy => remedies.join('\n\n');
  String get sunLongitudeDms => SwissEphemerisCalculator.formatRasiDmsDisplay(sunLongitude);
  String get moonLongitudeDms => SwissEphemerisCalculator.formatRasiDmsDisplay(moonLongitude);
}

/// Backward compatibility typedef
typedef TithiResult = DhanistaResult;
