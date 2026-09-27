import 'package:flutter/foundation.dart';

/// Dignity state of a planet
enum PlanetaryDignity {
  exalted, // உச்சம்
  moolatrikona, // மூலத்திரிகோணம்
  ownSign, // ஆட்சி
  friend, // நட்பு
  neutral, // சமம்
  enemy, // பகை
  debilitated, // நீசம்
  combust, // அஸ்தங்கம்
}

/// The 8 Traditional Jamakkol Outer Planets in counter-clockwise 45-degree rotation
@immutable
class JamakkolPlanet {
  final String key; // 'Sun', 'Mars', 'Jupiter', 'Mercury', 'Venus', 'Saturn', 'Moon', 'Rahu'
  final String nameEn;
  final String nameTa;
  final String shortTa;
  final String shortEn;
  final double absoluteLongitude; // 0..360°
  final int rasiIndex; // 0..11 (0=Mesham, 1=Rishabam, ..., 11=Meenam)
  final String rasiNameTa;
  final String rasiNameEn;
  final double degreeInRasi; // 0..30°
  final String formattedDms; // e.g. "24° 38' 12\""
  final String nakshatraTa;
  final String nakshatraEn;
  final int nakshatraIndex; // 0..26
  final int pada; // 1..4
  final int borderSide; // 0: Top, 1: Right, 2: Bottom, 3: Left (South Indian Chart)
  final int gridCol; // 0..3
  final int gridRow; // 0..3
  final bool isCurrentJamamLord;

  const JamakkolPlanet({
    required this.key,
    required this.nameEn,
    required this.nameTa,
    required this.shortTa,
    required this.shortEn,
    required this.absoluteLongitude,
    required this.rasiIndex,
    required this.rasiNameTa,
    required this.rasiNameEn,
    required this.degreeInRasi,
    required this.formattedDms,
    required this.nakshatraTa,
    required this.nakshatraEn,
    required this.nakshatraIndex,
    required this.pada,
    required this.borderSide,
    required this.gridCol,
    required this.gridRow,
    this.isCurrentJamamLord = false,
  });
}

/// Real-time Astronomical Gocharam (Transit) Planet
@immutable
class TransitPlanet {
  final String nameEn;
  final String nameTa;
  final String symbol;
  final double absoluteLongitude;
  final int rasiIndex;
  final String rasiNameTa;
  final String rasiNameEn;
  final double degreeInRasi;
  final String formattedDms;
  final String nakshatraTa;
  final String nakshatraEn;
  final int nakshatraIndex;
  final int pada;
  final bool isRetrograde;
  final bool isCombust;
  final PlanetaryDignity dignity;
  final String dignityLabelTa;
  final String dignityLabelEn;

  const TransitPlanet({
    required this.nameEn,
    required this.nameTa,
    required this.symbol,
    required this.absoluteLongitude,
    required this.rasiIndex,
    required this.rasiNameTa,
    required this.rasiNameEn,
    required this.degreeInRasi,
    required this.formattedDms,
    required this.nakshatraTa,
    required this.nakshatraEn,
    required this.nakshatraIndex,
    required this.pada,
    this.isRetrograde = false,
    this.isCombust = false,
    required this.dignity,
    required this.dignityLabelTa,
    required this.dignityLabelEn,
  });
}

/// Special Jamakkol Point (Udayam, Arudam, Kavippu, Upagrahas)
enum SpecialPointType {
  udayam, // உதயம்
  arudam, // ஆருடம்
  kavippu, // கவிப்பு
  mandi, // மாந்தி / குளிகன்
  yamakandam, // எமகண்டம்
  rahuKaalam, // ராகு காலம்
  mrityu, // மிருத்யு
  lagna, // லக்னம்
}

@immutable
class JamakkolSpecialPoint {
  final SpecialPointType type;
  final String nameEn;
  final String nameTa;
  final String shortCode; // 'உ', 'ஆ', 'கவி', 'மாந்', 'எம', 'ரா.கா', 'மிரு'
  final double absoluteLongitude;
  final int rasiIndex;
  final String rasiNameTa;
  final String rasiNameEn;
  final double degreeInRasi;
  final String formattedDms;
  final String nakshatraTa;
  final String nakshatraEn;
  final int nakshatraIndex;
  final int pada;
  final int houseFromUdayam; // 1 to 12
  final String? descriptionTa;

  const JamakkolSpecialPoint({
    required this.type,
    required this.nameEn,
    required this.nameTa,
    required this.shortCode,
    required this.absoluteLongitude,
    required this.rasiIndex,
    required this.rasiNameTa,
    required this.rasiNameEn,
    required this.degreeInRasi,
    required this.formattedDms,
    required this.nakshatraTa,
    required this.nakshatraEn,
    required this.nakshatraIndex,
    required this.pada,
    required this.houseFromUdayam,
    this.descriptionTa,
  });
}
