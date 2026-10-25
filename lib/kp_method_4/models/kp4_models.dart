// ignore_for_file: constant_identifier_names
import '../../models/user_model.dart';

/// KP Proportional Level
enum KpLevel { star, sub, subSub }

/// Hierarchy Source Level for KP Method 4 Lord & Contact Resolution
/// Priority 1: SUB_LORD
/// Priority 2: SUB_SUB_LORD
/// Priority 3: STAR_LORD
enum KpSourceLevel {
  SUB_LORD,
  SUB_SUB_LORD,
  STAR_LORD;

  String get displayNameTa {
    switch (this) {
      case KpSourceLevel.SUB_LORD:
        return 'உப நாதன்';
      case KpSourceLevel.SUB_SUB_LORD:
        return 'உப-உப நாதன்';
      case KpSourceLevel.STAR_LORD:
        return 'நட்சத்திர நாதன்';
    }
  }

  String get displayNameEn {
    switch (this) {
      case KpSourceLevel.SUB_LORD:
        return 'Sub Lord';
      case KpSourceLevel.SUB_SUB_LORD:
        return 'Sub-Sub Lord';
      case KpSourceLevel.STAR_LORD:
        return 'Star Lord';
    }
  }
}

/// Represents a single house number with fallback indicator for KP Method 4
class KpHouseNumber implements Comparable<KpHouseNumber> {
  final int house;
  final bool isSubSubFallback;
  final bool isStarLordFallback;
  final KpSourceLevel sourceLevel;

  const KpHouseNumber(
    this.house, {
    this.isSubSubFallback = false,
    this.isStarLordFallback = false,
    KpSourceLevel? sourceLevel,
  }) : sourceLevel = sourceLevel ??
            (isSubSubFallback
                ? KpSourceLevel.SUB_SUB_LORD
                : (isStarLordFallback ? KpSourceLevel.STAR_LORD : KpSourceLevel.SUB_LORD));

  /// Displays the number with '$' if derived from Sub-Sub level fallback,
  /// or '*' if derived from Star Lord fallback
  String get displayText {
    if (isSubSubFallback || sourceLevel == KpSourceLevel.SUB_SUB_LORD) {
      return '$house\$';
    }
    if (isStarLordFallback || sourceLevel == KpSourceLevel.STAR_LORD) {
      return '$house*';
    }
    return '$house';
  }

  @override
  int compareTo(KpHouseNumber other) {
    return house.compareTo(other.house);
  }

  @override
  String toString() => displayText;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KpHouseNumber &&
          runtimeType == other.runtimeType &&
          house == other.house &&
          isSubSubFallback == other.isSubSubFallback &&
          isStarLordFallback == other.isStarLordFallback &&
          sourceLevel == other.sourceLevel;

  @override
  int get hashCode =>
      house.hashCode ^
      isSubSubFallback.hashCode ^
      isStarLordFallback.hashCode ^
      sourceLevel.hashCode;
}

/// Represents a resolved contact between a Bhava and a Planet in KP Method 4
class BhavaContact {
  final int bhava; // 1..12
  final String planet;
  final KpSourceLevel sourceLevel;

  const BhavaContact({
    required this.bhava,
    required this.planet,
    required this.sourceLevel,
  });

  @override
  String toString() =>
      'BhavaContact(bhava: $bhava, planet: $planet, sourceLevel: ${sourceLevel.name})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BhavaContact &&
          runtimeType == other.runtimeType &&
          bhava == other.bhava &&
          planet.toLowerCase() == other.planet.toLowerCase() &&
          sourceLevel == other.sourceLevel;

  @override
  int get hashCode =>
      bhava.hashCode ^ planet.toLowerCase().hashCode ^ sourceLevel.hashCode;
}

/// Planetary position encapsulation for KP Method 4
class PlanetPosition {
  final String planet;
  final String planetTa;
  final double longitude;
  final int signIndex; // 0..11
  final String signName;
  final String signNameTa;
  final double degreeInRasi;
  final String degreeStr;
  final String starLord;
  final String starLordTa;
  final String subLord;
  final String subLordTa;
  final String subSubLord;
  final String subSubLordTa;
  final int nakshatraIndex; // 0..26
  final String nakshatraName;
  final String nakshatraNameTa;
  final int pada;
  final bool isRetrograde;

  const PlanetPosition({
    required this.planet,
    required this.planetTa,
    required this.longitude,
    required this.signIndex,
    required this.signName,
    required this.signNameTa,
    required this.degreeInRasi,
    required this.degreeStr,
    required this.starLord,
    required this.starLordTa,
    required this.subLord,
    required this.subLordTa,
    required this.subSubLord,
    required this.subSubLordTa,
    required this.nakshatraIndex,
    required this.nakshatraName,
    required this.nakshatraNameTa,
    required this.pada,
    this.isRetrograde = false,
  });
}

/// Bhava Cusp position encapsulation for KP Method 4
class CuspPosition {
  final int cuspNumber; // 1..12
  final double longitude;
  final int signIndex; // 0..11
  final String signName;
  final String signNameTa;
  final double degreeInRasi;
  final String degreeStr;
  final String starLord;
  final String starLordTa;
  final String subLord;
  final String subLordTa;
  final String subSubLord;
  final String subSubLordTa;
  final int nakshatraIndex; // 0..26
  final String nakshatraName;
  final String nakshatraNameTa;
  final int pada;

  const CuspPosition({
    required this.cuspNumber,
    required this.longitude,
    required this.signIndex,
    required this.signName,
    required this.signNameTa,
    required this.degreeInRasi,
    required this.degreeStr,
    required this.starLord,
    required this.starLordTa,
    required this.subLord,
    required this.subLordTa,
    required this.subSubLord,
    required this.subSubLordTa,
    required this.nakshatraIndex,
    required this.nakshatraName,
    required this.nakshatraNameTa,
    required this.pada,
  });
}

/// Graha Thodarbhu (Planet Relations) for KP Method 4
/// Evaluates:
/// Step 1: Star Lord -> Bhavas where Star Lord appears as Sub Lord
/// Step 2: Sub Lord -> Bhavas where Sub Lord appears as Sub Lord
/// Step 3: Sub-Sub Fallback -> if none found, check Sub-Sub Lord with '$'
class PlanetRelation {
  final String planet;
  final String planetTa;
  final String starLord;
  final String starLordTa;
  final List<KpHouseNumber> starLordHouses;
  final bool isStarLordFallback;
  final KpSourceLevel starLordSourceLevel;
  final String subLord;
  final String subLordTa;
  final List<KpHouseNumber> subLordHouses;
  final bool isSubLordFallback;
  final KpSourceLevel subLordSourceLevel;
  final String subSubLord;
  final String subSubLordTa;
  final List<KpHouseNumber> combinedHouses;
  final List<KpHouseNumber> planetHouses;
  final List<BhavaContact> planetContacts;
  final KpSourceLevel? planetSourceLevel;

  const PlanetRelation({
    required this.planet,
    required this.planetTa,
    required this.starLord,
    required this.starLordTa,
    required this.starLordHouses,
    required this.isStarLordFallback,
    this.starLordSourceLevel = KpSourceLevel.SUB_LORD,
    required this.subLord,
    required this.subLordTa,
    required this.subLordHouses,
    required this.isSubLordFallback,
    this.subLordSourceLevel = KpSourceLevel.SUB_LORD,
    required this.subSubLord,
    required this.subSubLordTa,
    required this.combinedHouses,
    this.planetHouses = const [],
    this.planetContacts = const [],
    this.planetSourceLevel,
  });
}

/// Bhava Graha Thodarbhu (Bhava Planetary Connections) for KP Method 4
/// For each of 12 Bhavas:
/// Reads the Bhava's Sub Lord and directly retrieves that planet's existing Planetary Connections:
/// - Connected Bhavas
/// - Star Lord and its connected Bhavas
/// - Sub Lord and its connected Bhavas
class HouseRelation {
  final int houseNumber; // 1..12
  final String cuspSubLord;
  final String cuspSubLordTa;
  final List<KpHouseNumber> cuspSubLordRelations;
  final String cuspSubLordStarLord;
  final String cuspSubLordStarLordTa;
  final List<KpHouseNumber> cuspSubLordStarLordRelations;
  final String cuspSubLordSubLord;
  final String cuspSubLordSubLordTa;
  final List<KpHouseNumber> cuspSubLordSubLordRelations;
  final List<KpHouseNumber> combinedHouses;
  final PlanetRelation? planetRelation;
  final bool isStarLordFallback;
  final bool isSubLordFallback;

  const HouseRelation({
    required this.houseNumber,
    required this.cuspSubLord,
    required this.cuspSubLordTa,
    required this.cuspSubLordRelations,
    required this.cuspSubLordStarLord,
    required this.cuspSubLordStarLordTa,
    required this.cuspSubLordStarLordRelations,
    this.cuspSubLordSubLord = '',
    this.cuspSubLordSubLordTa = '',
    this.cuspSubLordSubLordRelations = const [],
    required this.combinedHouses,
    this.planetRelation,
    this.isStarLordFallback = false,
    this.isSubLordFallback = false,
  });
}

/// Dasha Relation for KP Method 4
/// Dasha / Bhukti / Antara / Sookshma retrieved directly from Planet Relations
class DashaRelation {
  final String levelName; // e.g. 'தசா நாதன்', 'புத்தி நாதன்', 'அந்தரம் நாதன்', 'சூட்சும நாதன்'
  final String levelNameEn; // e.g. 'Dasha Lord', 'Bhukti Lord', 'Antara Lord', 'Sookshma Lord'
  final String planet;
  final String planetTa;
  final List<KpHouseNumber> relations;
  final List<KpHouseNumber> starLordRelations;
  final List<KpHouseNumber> subLordRelations;

  const DashaRelation({
    required this.levelName,
    required this.levelNameEn,
    required this.planet,
    required this.planetTa,
    required this.relations,
    required this.starLordRelations,
    required this.subLordRelations,
  });
}

/// Birth data container for KP Method 4
class Kp4BirthData {
  final DateTime dateTime;
  final String time;
  final String place;
  final double latitude;
  final double longitude;
  final double timezone;

  const Kp4BirthData({
    required this.dateTime,
    required this.time,
    required this.place,
    required this.latitude,
    required this.longitude,
    this.timezone = 5.5,
  });

  Kp4BirthData copyWith({
    DateTime? dateTime,
    String? time,
    String? place,
    double? latitude,
    double? longitude,
    double? timezone,
  }) {
    return Kp4BirthData(
      dateTime: dateTime ?? this.dateTime,
      time: time ?? this.time,
      place: place ?? this.place,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      timezone: timezone ?? this.timezone,
    );
  }

  factory Kp4BirthData.fromUserModel(UserModel user) {
    DateTime dt;
    try {
      final dateParts = user.dob.split('-');
      final year = int.parse(dateParts[0]);
      final month = int.parse(dateParts[1]);
      final day = int.parse(dateParts[2]);

      int hour = 12;
      int min = 0;
      final t = user.timeOfBirth.trim().toUpperCase();
      if (t.contains(':')) {
        final isPm = t.contains('PM');
        final isAm = t.contains('AM');
        final cleanT = t.replaceAll('AM', '').replaceAll('PM', '').trim();
        final tp = cleanT.split(':');
        hour = int.tryParse(tp[0]) ?? 12;
        min = int.tryParse(tp.length > 1 ? tp[1] : '0') ?? 0;
        if (isPm && hour < 12) hour += 12;
        if (isAm && hour == 12) hour = 0;
      }
      dt = DateTime(year, month, day, hour, min);
    } catch (_) {
      dt = DateTime.now();
    }

    return Kp4BirthData(
      dateTime: dt,
      time: user.timeOfBirth.isNotEmpty ? user.timeOfBirth : '12:00 PM',
      place: user.placeOfBirth.isNotEmpty
          ? user.placeOfBirth
          : (user.city.isNotEmpty ? user.city : 'Chennai'),
      latitude: user.latitude != 0.0 ? user.latitude : 13.0827,
      longitude: user.longitude != 0.0 ? user.longitude : 80.2707,
      timezone: user.timezone != 0.0 ? user.timezone : 5.5,
    );
  }

  factory Kp4BirthData.defaultProfile() {
    return Kp4BirthData(
      dateTime: DateTime(1995, 5, 15, 10, 30),
      time: '10:30 AM',
      place: 'Chennai, Tamil Nadu',
      latitude: 13.0827,
      longitude: 80.2707,
      timezone: 5.5,
    );
  }
}

/// Complete output container for KP Method 4
class KpResult {
  final Kp4BirthData birthData;
  final double ascendantDegree;
  final String ascendantDegreeStr;
  final String ascendantSignTa;
  final double ayanamsa;
  final String ayanamsaStr;
  final List<PlanetPosition> planetPositions;
  final List<CuspPosition> cuspPositions;
  final List<PlanetRelation> planetRelations;
  final List<HouseRelation> houseRelations;
  final List<DashaRelation> dashaRelations;
  final Map<String, List<BhavaContact>> planetBhavaContacts;
  final Map<String, List<KpHouseNumber>> planetToBhavas;

  const KpResult({
    required this.birthData,
    required this.ascendantDegree,
    required this.ascendantDegreeStr,
    required this.ascendantSignTa,
    required this.ayanamsa,
    required this.ayanamsaStr,
    required this.planetPositions,
    required this.cuspPositions,
    required this.planetRelations,
    required this.houseRelations,
    required this.dashaRelations,
    this.planetBhavaContacts = const {},
    this.planetToBhavas = const {},
  });

  PlanetPosition getPlanet(String name) {
    return planetPositions.firstWhere(
      (p) => p.planet.toLowerCase() == name.toLowerCase(),
      orElse: () => planetPositions.first,
    );
  }

  CuspPosition getCusp(int houseNum) {
    return cuspPositions.firstWhere(
      (c) => c.cuspNumber == houseNum,
      orElse: () => cuspPositions.first,
    );
  }

  PlanetRelation getPlanetRelation(String name) {
    return planetRelations.firstWhere(
      (r) => r.planet.toLowerCase() == name.toLowerCase(),
      orElse: () => planetRelations.first,
    );
  }

  List<BhavaContact> getContactsForPlanet(String name) {
    return planetBhavaContacts.entries
        .firstWhere(
          (e) => e.key.toLowerCase() == name.toLowerCase(),
          orElse: () => MapEntry(name, <BhavaContact>[]),
        )
        .value;
  }

  List<KpHouseNumber> getHousesForPlanet(String name) {
    return planetToBhavas.entries
        .firstWhere(
          (e) => e.key.toLowerCase() == name.toLowerCase(),
          orElse: () => MapEntry(name, <KpHouseNumber>[]),
        )
        .value;
  }
}
