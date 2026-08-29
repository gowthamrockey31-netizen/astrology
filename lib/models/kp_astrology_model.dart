import '../services/astrology_calculator.dart';
import '../services/planet_status_calculator.dart';

/// Target KP Planets enum
enum KPPlanet {
  sun,
  moon,
  mars,
  mercury,
  jupiter,
  venus,
  saturn,
  rahu,
  ketu,
  ascendant,
}

/// Birth Data for KP Calculations
class KPBirthData {
  final DateTime birthDateTime;
  final double latitude;
  final double longitude;
  final double utcOffsetHours;
  final double? ayanamsa;
  final String? placeName;

  const KPBirthData({
    required this.birthDateTime,
    required this.latitude,
    required this.longitude,
    this.utcOffsetHours = 5.5,
    this.ayanamsa,
    this.placeName,
  });
}

/// Raw Astronomical ephemeris output
class AstronomicalData {
  final double ascendant;
  final Map<KPPlanet, double> planetLongitudes;
  final Map<KPPlanet, double> planetSpeeds;
  final List<double> cuspLongitudes;

  const AstronomicalData({
    required this.ascendant,
    required this.planetLongitudes,
    this.planetSpeeds = const {},
    this.cuspLongitudes = const [],
  });
}

/// Abstract Astronomy Provider interface for real ephemeris adapters
abstract class AstronomyProvider {
  AstronomicalData calculateAstronomicalData(KPBirthData data);
}

/// KP Cusp Detail (Placidus / KP House System)
class KpCuspDetail {
  final int cuspNumber; // 1..12
  final double cuspLongitude;
  final int rasiIndex;
  final String rasiNameTa;
  final String rasiNameEn;
  final double degreeInRasi;
  final String degreeFormatted;
  final int nakshatraIndex;
  final String nakshatraNameTa;
  final String nakshatraNameEn;
  final int pada;
  final int navamsaRasiIndex;
  final String signLordTa;
  final String signLordEn;
  final String starLordTa;
  final String starLordEn;
  final String subLordTa;
  final String subLordEn;
  final String subSubLordTa;
  final String subSubLordEn;

  const KpCuspDetail({
    required this.cuspNumber,
    required this.cuspLongitude,
    required this.rasiIndex,
    required this.rasiNameTa,
    required this.rasiNameEn,
    required this.degreeInRasi,
    required this.degreeFormatted,
    this.nakshatraIndex = 0,
    this.nakshatraNameTa = '',
    this.nakshatraNameEn = '',
    this.pada = 1,
    this.navamsaRasiIndex = 0,
    required this.signLordTa,
    this.signLordEn = '',
    required this.starLordTa,
    this.starLordEn = '',
    required this.subLordTa,
    this.subLordEn = '',
    required this.subSubLordTa,
    this.subSubLordEn = '',
  });
}

/// Alias for modern KPCusp
typedef KPCusp = KpCuspDetail;

/// KP Planet Position with Sub-Lord and Sub-Sub-Lord
class KpPlanetDetail {
  final String planetNameEn;
  final String planetNameTa;
  final String symbol;
  final double longitude;
  final double speed;
  final int rasiIndex;
  final String rasiNameTa;
  final String rasiNameEn;
  final double degreeInRasi;
  final String degreeFormatted;
  final int nakshatraIndex;
  final String nakshatraNameTa;
  final String nakshatraNameEn;
  final int pada;
  final int navamsaPart;
  final int navamsaRasiIndex;
  final String navamsaRasiTa;
  final String navamsaRasiEn;
  final String signLordTa;
  final String signLordEn;
  final String starLordTa;
  final String starLordEn;
  final String subLordTa;
  final String subLordEn;
  final String subSubLordTa;
  final String subSubLordEn;
  final int cuspOccupied;
  final bool isRetrograde;

  const KpPlanetDetail({
    required this.planetNameEn,
    required this.planetNameTa,
    required this.symbol,
    required this.longitude,
    this.speed = 1.0,
    required this.rasiIndex,
    required this.rasiNameTa,
    this.rasiNameEn = '',
    required this.degreeInRasi,
    required this.degreeFormatted,
    this.nakshatraIndex = 0,
    this.nakshatraNameTa = '',
    this.nakshatraNameEn = '',
    this.pada = 1,
    this.navamsaPart = 0,
    this.navamsaRasiIndex = 0,
    this.navamsaRasiTa = '',
    this.navamsaRasiEn = '',
    required this.signLordTa,
    this.signLordEn = '',
    required this.starLordTa,
    this.starLordEn = '',
    required this.subLordTa,
    this.subLordEn = '',
    required this.subSubLordTa,
    this.subSubLordEn = '',
    required this.cuspOccupied,
    required this.isRetrograde,
  });

  double get siderealLongitude => longitude;
}

/// Alias for modern KPPlanetPosition
typedef KPPlanetPosition = KpPlanetDetail;

/// KP Significator Table (Levels A, B, C, D)
class KpPlanetSignificator {
  final String planetNameTa;
  final String planetNameEn;
  final List<int> levelA; // Occupant of Star Lord's house
  final List<int> levelB; // Planet's own house occupied
  final List<int> levelC; // Houses owned by Star Lord
  final List<int> levelD; // Houses owned by Planet

  const KpPlanetSignificator({
    required this.planetNameTa,
    this.planetNameEn = '',
    required this.levelA,
    required this.levelB,
    required this.levelC,
    required this.levelD,
  });
}

/// Alias for modern KPSignificator
typedef KPSignificator = KpPlanetSignificator;

/// KP Ruling Planets model
class KPRulingPlanets {
  final String ascendantSignLordTa;
  final String ascendantStarLordTa;
  final String ascendantSubLordTa;
  final String moonSignLordTa;
  final String moonStarLordTa;
  final String moonSubLordTa;
  final String dayLordTa;

  const KPRulingPlanets({
    required this.ascendantSignLordTa,
    required this.ascendantStarLordTa,
    required this.ascendantSubLordTa,
    required this.moonSignLordTa,
    required this.moonStarLordTa,
    required this.moonSubLordTa,
    required this.dayLordTa,
  });

  Map<String, String> toMap() => {
        'Ascendant Sign Lord': ascendantSignLordTa,
        'Ascendant Star Lord': ascendantStarLordTa,
        'Ascendant Sub Lord': ascendantSubLordTa,
        'Moon Sign Lord': moonSignLordTa,
        'Moon Star Lord': moonStarLordTa,
        'Moon Sub Lord': moonSubLordTa,
        'Day Lord': dayLordTa,
      };
}

/// Continuous Vimshottari Dasha period
class KPDashaPeriod {
  final String level; // Mahadasha, Bhukti, Anthara, Sookshma
  final String planetNameEn;
  final String planetNameTa;
  final DateTime startDate;
  final DateTime endDate;
  final double durationYears;
  final List<KPDashaPeriod> subPeriods;

  const KPDashaPeriod({
    required this.level,
    required this.planetNameEn,
    required this.planetNameTa,
    required this.startDate,
    required this.endDate,
    required this.durationYears,
    this.subPeriods = const [],
  });
}

/// Vimshottari Dasha Hierarchy starting from birth balance
class KPDashaHierarchy {
  final String birthBalancePlanetEn;
  final String birthBalancePlanetTa;
  final double birthBalanceYears;
  final String birthBalanceFormatted;
  final List<KPDashaPeriod> mahadashas;

  const KPDashaHierarchy({
    required this.birthBalancePlanetEn,
    required this.birthBalancePlanetTa,
    required this.birthBalanceYears,
    required this.birthBalanceFormatted,
    required this.mahadashas,
  });
}

/// KP Cusp Sub Lord House Relation Result (KP பாவ உப நட்சத்திராதிபதி தொடர்பு)
class KpCuspHouseRelationResult {
  final int houseNumber; // 1..12
  final double cuspLongitude;
  final String nakshatraNameTa;
  final String nakshatraNameEn;
  final String cuspStarLordTa;
  final String cuspSubLordTa;

  // Sub Lord breakdown
  final List<int> subLordOccupiedHouses;
  final List<int> subLordOwnedHouses;

  // Sub Lord's Star Lord breakdown
  final String subLordStarLordTa;
  final List<int> starLordOccupiedHouses;
  final List<int> starLordOwnedHouses;

  // Node breakdown (if Sub Lord or Star Lord is Rahu / Ketu)
  final bool isSubLordNode;
  final String? nodeSignLordTa;
  final List<int> nodeSignLordHouses;
  final List<String> conjunctPlanetsTa;
  final List<int> conjunctPlanetsHouses;

  // Final unique, sorted house numbers (1..12)
  final List<int> finalRelatedHouses;

  const KpCuspHouseRelationResult({
    required this.houseNumber,
    required this.cuspLongitude,
    required this.nakshatraNameTa,
    required this.nakshatraNameEn,
    required this.cuspStarLordTa,
    required this.cuspSubLordTa,
    required this.subLordOccupiedHouses,
    required this.subLordOwnedHouses,
    required this.subLordStarLordTa,
    required this.starLordOccupiedHouses,
    required this.starLordOwnedHouses,
    this.isSubLordNode = false,
    this.nodeSignLordTa,
    this.nodeSignLordHouses = const [],
    this.conjunctPlanetsTa = const [],
    this.conjunctPlanetsHouses = const [],
    required this.finalRelatedHouses,
  });

  String get finalRelatedHousesFormatted =>
      finalRelatedHouses.isEmpty ? '-' : finalRelatedHouses.join(', ');
}

/// Complete KP Astrology Calculation Result
class KpAstrologyResult {
  final double kpAyanamsa;
  final String kpAyanamsaFormatted;
  final List<KpCuspDetail> cusps;
  final List<KpPlanetDetail> planets;
  final List<KpPlanetSignificator> significators;
  final Map<String, String> rulingPlanets;
  final List<KpCuspHouseRelationResult> cuspHouseRelations;
  final KPDashaHierarchy? dashaHierarchy;

  const KpAstrologyResult({
    required this.kpAyanamsa,
    required this.kpAyanamsaFormatted,
    required this.cusps,
    required this.planets,
    required this.significators,
    required this.rulingPlanets,
    this.cuspHouseRelations = const [],
    this.dashaHierarchy,
  });
}

/// Alias for modern KPChartResult
typedef KPChartResult = KpAstrologyResult;
