import '../engine/bnn_method1_engine.dart';
import '../models/bnn_method1_model.dart';
import '../services/astrology_calculator.dart';
import '../services/bnn_engine.dart';

/// Adapter Interface for BNN Method 1 Chart and Ephemeris calculations
abstract class BnnMethod1ChartProvider {
  Future<BnnMethod1Result> calculateMethod1Chart({
    required DateTime birthDateTime,
    required double latitude,
    required double longitude,
    double utcOffsetHours = 5.5,
    String placeName = '',
  });
}

/// Real Production Adapter implementation consuming AstrologyCalculator ephemeris
class DefaultBnnMethod1ChartProvider implements BnnMethod1ChartProvider {
  const DefaultBnnMethod1ChartProvider();

  @override
  Future<BnnMethod1Result> calculateMethod1Chart({
    required DateTime birthDateTime,
    required double latitude,
    required double longitude,
    double utcOffsetHours = 5.5,
    String placeName = '',
  }) async {
    return calculateSync(
      birthDateTime: birthDateTime,
      latitude: latitude,
      longitude: longitude,
      utcOffsetHours: utcOffsetHours,
      placeName: placeName,
    );
  }

  /// Synchronous calculation pipeline
  static BnnMethod1Result calculateSync({
    required DateTime birthDateTime,
    required double latitude,
    required double longitude,
    double utcOffsetHours = 5.5,
    String placeName = '',
  }) {
    // 1. Strict Input Validation (Rule 13)
    validateInputs(
      birthDateTime: birthDateTime,
      latitude: latitude,
      longitude: longitude,
    );

    // 2. Consume real astronomical calculation layer (Rule 2 & 12)
    final astroData = AstrologyCalculator.calculateHoroscope(
      dateOfBirth: birthDateTime,
      latitude: latitude,
      longitude: longitude,
      utcOffsetHours: utcOffsetHours,
    );

    final lagnaRasiIdx = astroData.lagna.rasiIndex;
    final lagnaSign = lagnaRasiIdx + 1;
    final lagnaDms = BnnMethod1Engine.toDMS(astroData.lagna.degreeInRasi);

    final bnnLagna = BnnMethod1Planet(
      planetKey: 'Lagna',
      planetName: 'லக்னம்',
      englishName: 'Ascendant',
      longitude: astroData.lagna.longitude,
      sign: lagnaSign,
      signNameTa: astroData.lagna.rasiNameTa,
      signNameEn: astroData.lagna.rasiNameEn,
      degreeWithinSign: astroData.lagna.degreeInRasi,
      degree: lagnaDms.$1,
      minute: lagnaDms.$2,
      second: lagnaDms.$3,
      house: 1,
      nakshatra: astroData.lagna.nakshatraNameTa,
      nakshatraIndex: astroData.lagna.nakshatraIndex,
      nakshatraPada: astroData.lagna.pada,
      isRetrograde: false,
    );

    // 3. Adapt 9 standard planets from real astronomical data
    final List<BnnMethod1Planet> planets = [];

    for (final key in BnnMethod1Engine.standardPlanetKeys) {
      final p = astroData.planets[key];
      if (p == null) continue;

      final signNum = p.rasiIndex + 1;
      final house = ((p.rasiIndex - lagnaRasiIdx + 12) % 12) + 1;
      final dms = BnnMethod1Engine.toDMS(p.degreeInRasi);

      planets.add(BnnMethod1Planet(
        planetKey: p.name,
        planetName: p.tamilName,
        englishName: p.name,
        longitude: p.longitude,
        sign: signNum,
        signNameTa: p.rasiNameTa,
        signNameEn: p.rasiNameEn,
        degreeWithinSign: p.degreeInRasi,
        degree: dms.$1,
        minute: dms.$2,
        second: dms.$3,
        house: house,
        nakshatra: p.nakshatraNameTa,
        nakshatraIndex: p.nakshatraIndex,
        nakshatraPada: p.pada,
        isRetrograde: p.isRetrograde,
      ));
    }

    // 4. Consume real Vimshottari Dasha from Moon's actual longitude (Rule 11)
    final dashaResult = BnnEngine.calculateVimshottariDasha(
      moonLongitude: astroData.moon.longitude,
      birthDateTime: birthDateTime,
    );

    // Formatted birth time string
    final hStr = birthDateTime.hour.toString().padLeft(2, '0');
    final mStr = birthDateTime.minute.toString().padLeft(2, '0');
    final birthTimeStr = "$hStr:$mStr";

    // 5. Execute BNN Method 1 Engine
    return BnnMethod1Engine.calculate(
      birthDate: birthDateTime,
      birthTime: birthTimeStr,
      latitude: latitude,
      longitude: longitude,
      place: placeName,
      utcOffsetHours: utcOffsetHours,
      lagna: bnnLagna,
      rawPlanets: planets,
      dashaResult: dashaResult,
    );
  }

  /// Strict coordinate and date validation
  static void validateInputs({
    required DateTime birthDateTime,
    required double latitude,
    required double longitude,
  }) {
    if (latitude == 0.0 && longitude == 0.0) {
      throw ArgumentError(
        'பிறந்த இடத்தின் அட்சரேகை/தீர்க்கரேகை (Latitude/Longitude) தேவை. 0,0 பயன்படுத்த முடியாது.',
      );
    }
    if (latitude < -90.0 || latitude > 90.0) {
      throw ArgumentError(
        'அட்சரேகை (Latitude) -90 முதல் +90 வரை மட்டுமே இருக்க வேண்டும். பெறப்பட்டது: $latitude',
      );
    }
    if (longitude < -180.0 || longitude > 180.0) {
      throw ArgumentError(
        'தீர்க்கரேகை (Longitude) -180 முதல் +180 வரை மட்டுமே இருக்க வேண்டும். பெறப்பட்டது: $longitude',
      );
    }
    if (birthDateTime.year < 1800 || birthDateTime.year > 2200) {
      throw ArgumentError(
        'செல்லுபடியாகும் பிறந்த ஆண்டை உள்ளிடவும் (1800-2200). பெறப்பட்டது: ${birthDateTime.year}',
      );
    }
  }
}
