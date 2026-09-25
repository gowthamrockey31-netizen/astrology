import 'nakshatra_prasannam_data.dart';
import 'nakshatra_prasannam_models.dart';

/// Pure Dart calculation engine for Nakshatra Prasannam.
/// Implements all core astrological formulas without external API or library dependencies.
class NakshatraPrasannaCalculator {
  /// 1. Normalize angle strictly into [0.0, 360.0)
  static double normalizeLongitude(double deg) {
    if (deg.isNaN || deg.isInfinite) return 0.0;
    double norm = deg % 360.0;
    if (norm < 0.0) norm += 360.0;
    return norm;
  }

  /// 2. Format degrees to DD° MM′ SS″
  static String formatDegreeMinutes(double deg, {bool includeSeconds = false}) {
    final norm = normalizeLongitude(deg);
    final d = norm.floor();
    final remM = (norm - d) * 60.0;
    final m = remM.floor();
    if (!includeSeconds) {
      return "${d.toString().padLeft(2, '0')}° ${m.toString().padLeft(2, '0')}′";
    }
    final s = ((remM - m) * 60.0).round();
    return "${d.toString().padLeft(2, '0')}° ${m.toString().padLeft(2, '0')}′ ${s.toString().padLeft(2, '0')}″";
  }

  /// Format degree within its 30° Rasi
  static String formatDegreeInRasi(double deg) {
    final normInRasi = normalizeLongitude(deg) % 30.0;
    final d = normInRasi.floor();
    final remM = (normInRasi - d) * 60.0;
    final m = remM.floor();
    final s = ((remM - m) * 60.0).round();
    return "${d.toString().padLeft(2, '0')}° ${m.toString().padLeft(2, '0')}′ ${s.toString().padLeft(2, '0')}″";
  }

  /// 3. Calculate Nakshatra position (DRM / Star Position)
  /// 1 Nakshatra = 13° 20' = 13.333333333333334° (40 / 3)
  /// 1 Pada = 3° 20' = 3.3333333333333335° (10 / 3)
  static NakshatraPosition getNakshatraPosition(double longitude) {
    final norm = normalizeLongitude(longitude);
    const starSpan = 40.0 / 3.0; // 13.333333333333334
    const padaSpan = 10.0 / 3.0; // 3.3333333333333335

    final starIndex = (norm / starSpan).floor().clamp(0, 26);
    final traversed = norm - (starIndex * starSpan);
    final remaining = (starSpan - traversed).clamp(0.0, starSpan);
    final pada = ((traversed / padaSpan).floor().clamp(0, 3)) + 1;

    final nakData = kNakshatras[starIndex];

    return NakshatraPosition(
      nakshatraIndex: starIndex,
      nakshatraNameTamil: nakData.tamilName,
      nakshatraNameEnglish: nakData.englishName,
      lord: nakData.lord,
      pada: pada,
      traversedDegrees: traversed,
      remainingDegrees: remaining,
      totalStarDegrees: starSpan,
      longitude: norm,
    );
  }

  /// 4. Calculate remaining star time (மீதமுள்ள நேரம்)
  /// Vimshottari 120 years scaled to 24 hours (1440 minutes):
  /// 1 Vimshottari year = 12.0 minutes.
  /// Remaining time = (remainingDegrees / 13°20') * (lordDashaYears * 12.0 min)
  static double remainingStarTime(double remainingDegrees, Planet lord) {
    const starSpan = 40.0 / 3.0;
    final dashaYears = kPlanetDashaYears[lord] ?? 7;
    final totalStarMinutes = dashaYears * 12.0;
    final fraction = (remainingDegrees / starSpan).clamp(0.0, 1.0);
    return fraction * totalStarMinutes;
  }

  /// 5. Calculate elapsed time in minutes from Sunrise to Question Time
  static double elapsedFromSunrise(DateTime sunrise, DateTime questionTime) {
    return questionTime.difference(sunrise).inMicroseconds / 60000000.0;
  }

  /// 6. Build Sequential Nakshatra Dasha Periods & Calculate HRM
  static HrmResult calculateHRM({
    required DateTime sunrise,
    required DateTime questionTime,
    required NakshatraPosition drm,
    int maxCycles = 2,
  }) {
    final timeline = <DashaSegment>[];

    // Segment 0: DRM Lord's remaining period
    final firstDuration = remainingStarTime(drm.remainingDegrees, drm.lord);
    var segStart = sunrise;
    var segEnd = segStart.add(Duration(microseconds: (firstDuration * 60000000.0).round()));

    timeline.add(DashaSegment(
      planet: drm.lord,
      startTime: segStart,
      endTime: segEnd,
      durationMinutes: firstDuration,
      isCurrentSegment: false,
    ));

    // Subsequent segments follow Vimshottari sequence from the next lord
    int currentLordIdx = kVimshottariOrder.indexOf(drm.lord);

    // Build timeline for at least 24 hours or past question time
    final targetLimit = questionTime.isAfter(segEnd)
        ? questionTime.add(const Duration(hours: 6))
        : sunrise.add(const Duration(hours: 24));

    while (segEnd.isBefore(targetLimit) && timeline.length < 50) {
      currentLordIdx = (currentLordIdx + 1) % kVimshottariOrder.length;
      final nextPlanet = kVimshottariOrder[currentLordIdx];
      final duration = (kPlanetDashaYears[nextPlanet] ?? 7) * 12.0;

      segStart = segEnd;
      segEnd = segStart.add(Duration(microseconds: (duration * 60000000.0).round()));

      timeline.add(DashaSegment(
        planet: nextPlanet,
        startTime: segStart,
        endTime: segEnd,
        durationMinutes: duration,
        isCurrentSegment: false,
      ));
    }

    // Locate which segment contains questionTime
    int activeIdx = 0;
    for (int i = 0; i < timeline.length; i++) {
      final s = timeline[i];
      // If questionTime falls within [startTime, endTime)
      if (!questionTime.isBefore(s.startTime) && questionTime.isBefore(s.endTime)) {
        activeIdx = i;
        break;
      }
      // Boundary condition: exactly at start of day or at end
      if (questionTime.isAtSameMomentAs(s.startTime)) {
        activeIdx = i;
        break;
      }
      activeIdx = i;
    }

    // Mark current active segment
    final updatedTimeline = <DashaSegment>[];
    for (int i = 0; i < timeline.length; i++) {
      final s = timeline[i];
      updatedTimeline.add(DashaSegment(
        planet: s.planet,
        startTime: s.startTime,
        endTime: s.endTime,
        durationMinutes: s.durationMinutes,
        isCurrentSegment: i == activeIdx,
      ));
    }

    final activeSegment = updatedTimeline[activeIdx];
    final elapsedInSeg = (questionTime.difference(activeSegment.startTime).inMicroseconds / 60000000.0)
        .clamp(0.0, activeSegment.durationMinutes);
    final remainingInSeg = (activeSegment.durationMinutes - elapsedInSeg)
        .clamp(0.0, activeSegment.durationMinutes);

    return HrmResult(
      hrmPlanet: activeSegment.planet,
      startTime: activeSegment.startTime,
      endTime: activeSegment.endTime,
      totalDurationMinutes: activeSegment.durationMinutes,
      elapsedMinutes: elapsedInSeg,
      remainingMinutes: remainingInSeg,
      timeline: updatedTimeline,
    );
  }

  /// 7. Calculate NPL (Nakshatra Prasanna Lagna)
  /// Identifies the Rasi and Bhava (house from Ascendant) where the HRM planet is posited.
  static NplResult? calculateNPL({
    required Planet hrmPlanet,
    required double? hrmPlanetLongitude,
    required double? ascendantLongitude,
  }) {
    if (hrmPlanetLongitude == null) return null;

    final normPlanet = normalizeLongitude(hrmPlanetLongitude);
    final planetRasiIdx = (normPlanet / 30.0).floor().clamp(0, 11);
    final rasiData = kRasis[planetRasiIdx];

    int bhava = 1;
    if (ascendantLongitude != null) {
      final normAsc = normalizeLongitude(ascendantLongitude);
      final lagnaRasiIdx = (normAsc / 30.0).floor().clamp(0, 11);
      bhava = ((planetRasiIdx - lagnaRasiIdx + 12) % 12) + 1;
    }

    return NplResult(
      hrmPlanet: hrmPlanet,
      rasiIndex: planetRasiIdx,
      rasiTamil: rasiData.tamilName,
      rasiEnglish: rasiData.englishName,
      bhava: bhava,
      planetLongitude: normPlanet,
    );
  }

  /// 8. Calculate Jeeva & Sareera
  /// Source Planet: HRM Planet
  /// Jeeva: Star lord of the constellation occupied by Source Planet
  /// Sareera: Star lord of the constellation occupied by Jeeva planet
  static JeevaSareeraResult? calculateJeevaSareera({
    required Planet sourcePlanet,
    required Map<Planet, double> planetLongitudes,
  }) {
    final sourceLon = planetLongitudes[sourcePlanet];
    if (sourceLon == null) return null;

    // Jeeva planet is the star lord of source planet
    final jeevaPos = getNakshatraPosition(sourceLon);
    final jeevaPlanet = jeevaPos.lord;

    // Sareera planet is the star lord of jeeva planet
    final jeevaLon = planetLongitudes[jeevaPlanet] ?? sourceLon;
    final sareeraPos = getNakshatraPosition(jeevaLon);
    final sareeraPlanet = sareeraPos.lord;

    final rel = evaluatePlanetaryRelation(jeevaPlanet, sareeraPlanet);

    String desc;
    String tamLabel;
    switch (rel) {
      case PlanetaryRelationship.same:
        tamLabel = 'சுய நட்சத்திர தொடர்பு (பரிபூரண சுபம்)';
        desc = 'ஜீவா மற்றும் சரீரா ஒரே கிரகமாக இணைந்துள்ளன. காரியம் தடையின்றி உடனே கைகூடும்.';
        break;
      case PlanetaryRelationship.friend:
        tamLabel = 'நட்புத் தொடர்பு (உத்தமம்)';
        desc = 'ஜீவா மற்றும் சரீரா கிரகங்கள் நட்பு பெற்றுள்ளன. காரியம் சுபமாகவும் நன்மையாகவும் முடியும்.';
        break;
      case PlanetaryRelationship.neutral:
        tamLabel = 'சம தொடர்பு (மத்திமம்)';
        desc = 'ஜீவா மற்றும் சரீரா சம நிலையில் உள்ளன. முயற்சியின் பேரில் காரியம் நிறைவேறும்.';
        break;
      case PlanetaryRelationship.enemy:
        tamLabel = 'பகைத் தொடர்பு (தாமதம் / எச்சரிக்கை)';
        desc = 'ஜீவா மற்றும் சரீரா தங்களுக்குள் பகை பெற்றுள்ளன. சில தடைகள், தாமதங்களை எதிர்கொள்ள நேரிடும்.';
        break;
    }

    return JeevaSareeraResult(
      sourcePlanet: sourcePlanet,
      jeevaPlanet: jeevaPlanet,
      sareeraPlanet: sareeraPlanet,
      relation: rel,
      relationTamil: tamLabel,
      relationDescription: desc,
    );
  }

  /// 9. Evaluate general planetary relationship (Same, Friend, Neutral, Enemy)
  static PlanetaryRelationship evaluatePlanetaryRelation(Planet p1, Planet p2) {
    if (p1 == p2) return PlanetaryRelationship.same;
    final friends = kPlanetFriends[p1] ?? [];
    if (friends.contains(p2)) return PlanetaryRelationship.friend;
    final enemies = kPlanetEnemies[p1] ?? [];
    if (enemies.contains(p2)) return PlanetaryRelationship.enemy;
    return PlanetaryRelationship.neutral;
  }

  /// 10. Guna of Planet at Nakshatra
  static String gunaOfPlanetAtStar(Planet planet, int nakshatraIndex) {
    final nak = kNakshatras[nakshatraIndex % 27];
    return nak.guna;
  }

  /// 11. Uttama Drekkana & Parivarthana calculation
  /// Drekkana (1/3rd of sign = 10°):
  /// - Chara sign (0, 3, 6, 9): 1st drekkana is Vargottama / Uttama.
  /// - Sthira sign (1, 4, 7, 10): 2nd drekkana is Madhyama.
  /// - Ubhaya sign (2, 5, 8, 11): 3rd drekkana is in 9th sign.
  static UttamaResult calculateUttama({
    required double planetLongitude,
    required Map<Planet, double> planetLongitudes,
  }) {
    final norm = normalizeLongitude(planetLongitude);
    final rasiIdx = (norm / 30.0).floor().clamp(0, 11);
    final degInRasi = norm % 30.0;
    final drekkanaIdx = (degInRasi / 10.0).floor().clamp(0, 2);

    final rasi = kRasis[rasiIdx];
    bool isVargottama = false;
    String vargottamaDesc = '';

    // In Chara signs, 1st Drekkana (0-10 deg) is Vargottama Drekkana (உத்தம திரேக்காணம்)
    if (rasi.nature == 'சரம்' && drekkanaIdx == 0) {
      isVargottama = true;
      vargottamaDesc = 'சர ராசியில் முதல் திரேக்காணம் (0°-10°) உத்தம வர்க்கோத்தம திரேக்காணம் ஆகும்.';
    } else if (rasi.nature == 'ஸ்திரம்' && drekkanaIdx == 1) {
      vargottamaDesc = 'ஸ்திர ராசியில் 2-ஆம் திரேக்காணம் (மத்திம திரேக்காணம்).';
    } else if (rasi.nature == 'உபயம்' && drekkanaIdx == 2) {
      vargottamaDesc = 'உபய ராசியில் 3-ஆம் திரேக்காணம் (அசுப / அதம திரேக்காணம்).';
    } else {
      vargottamaDesc = 'சாதாரண திரேக்காண அமைப்பு.';
    }

    // Check Parivarthana (mutual sign exchange)
    bool isParivarthana = false;
    String parivarthanaDesc = 'பரிவர்த்தனை இல்லை.';

    final p1 = rasi.lord; // Sign lord where target planet is posited
    final p1Lon = planetLongitudes[p1];
    if (p1Lon != null) {
      final p1RasiIdx = (normalizeLongitude(p1Lon) / 30.0).floor().clamp(0, 11);
      final p1RasiLord = kRasis[p1RasiIdx].lord;
      // If the lord of P1's sign is our planet's sign or matches
      if (p1RasiLord != p1 && planetLongitudes.containsValue(planetLongitude)) {
        // Find which planet corresponds to planetLongitude
        Planet? targetPlanet;
        for (final entry in planetLongitudes.entries) {
          if ((entry.value - planetLongitude).abs() < 0.0001) {
            targetPlanet = entry.key;
            break;
          }
        }
        if (targetPlanet != null && p1RasiLord == targetPlanet) {
          isParivarthana = true;
          parivarthanaDesc =
              '${kPlanetTamilNames[targetPlanet]} மற்றும் ${kPlanetTamilNames[p1]} தங்களுக்குள் பரிவர்த்தனை பெற்றுள்ளன.';
        }
      }
    }

    final summary = isVargottama
        ? 'உத்தம திரேக்காண அமைப்பு உள்ளது. காரியத்தில் தெய்வீக அனுகூலமும் பூரண வெற்றியும் கிட்டும்.'
        : (isParivarthana
            ? 'சுப பரிவர்த்தனை அமைப்பு உள்ளது. மாற்று வழியில் வெற்றி கிட்டும்.'
            : 'சராசரி திரேக்காண பலன்.');

    return UttamaResult(
      isVargottama: isVargottama,
      vargottamaDescription: vargottamaDesc,
      isParivarthana: isParivarthana,
      parivarthanaDescription: parivarthanaDesc,
      summary: summary,
    );
  }

  /// 12. Evaluate DRM–HRM Relationship
  static MoonRelationship evaluateDrmHrm(Planet drmLord, Planet hrmLord) {
    final rel = evaluatePlanetaryRelation(drmLord, hrmLord);
    String label;
    String desc;

    switch (rel) {
      case PlanetaryRelationship.same:
        label = 'ஒரே அதிபதி (சுய தொடர்பு)';
        desc = 'உதய சந்திரனும் பிரசன்ன சந்திரனும் ஒரே கிரக ஆதிக்கத்தில் உள்ளன. காரியம் விரைவாகவும் தடையின்றியும் நிறைவேறும்.';
        break;
      case PlanetaryRelationship.friend:
        label = 'நட்புத் தொடர்பு (சுபம்)';
        desc = 'DRM மற்றும் HRM கிரகங்கள் தங்களுக்குள் நட்பு கொண்டுள்ளன. காரியம் சுபமாகவும் அனுகூலமாகவும் முடியும்.';
        break;
      case PlanetaryRelationship.neutral:
        label = 'சம தொடர்பு (மத்திமம்)';
        desc = 'DRM மற்றும் HRM கிரகங்கள் சம நிலையில் உள்ளன. காரியம் சராசரி முயற்சியில் தாமதமாக நிறைவேறும்.';
        break;
      case PlanetaryRelationship.enemy:
        label = 'பகைத் தொடர்பு (தடை)';
        desc = 'DRM மற்றும் HRM கிரகங்கள் தங்களுக்குள் பகை கொண்டுள்ளன. காரியத்தில் தடைகள் மற்றும் காலதாமதம் ஏற்படலாம்.';
        break;
    }

    return MoonRelationship(
      drmLord: drmLord,
      hrmLord: hrmLord,
      relation: rel,
      relationTamil: label,
      explanation: desc,
    );
  }

  /// 13. Determine Answer Period (Event Timing)
  static AnswerPeriod determineAnswerPeriod({
    required MoonRelationship drmHrm,
    required JeevaSareeraResult? jeevaSareera,
    required String guna,
    required int? bhava,
  }) {
    // Favorable conditions
    final bool isDrmHrmFavorable = drmHrm.relation == PlanetaryRelationship.same ||
        drmHrm.relation == PlanetaryRelationship.friend;
    final bool isJsFavorable = jeevaSareera != null &&
        (jeevaSareera.relation == PlanetaryRelationship.same ||
            jeevaSareera.relation == PlanetaryRelationship.friend);
    final bool isGoodBhava = bhava != null && (bhava == 1 || bhava == 2 || bhava == 4 || bhava == 5 || bhava == 9 || bhava == 10 || bhava == 11);
    final bool isDusthana = bhava != null && (bhava == 6 || bhava == 8 || bhava == 12);

    if (isDrmHrmFavorable && isJsFavorable && guna == 'சாத்வீகம்' && isGoodBhava) {
      return AnswerPeriod.sameDay;
    } else if (isDrmHrmFavorable && !isDusthana) {
      return AnswerPeriod.withinOneMonth;
    } else if (!isDusthana && (drmHrm.relation != PlanetaryRelationship.enemy)) {
      return AnswerPeriod.oneToTwoMonths;
    } else {
      return AnswerPeriod.delayed;
    }
  }

  /// 14. Event timing interpretation
  static String timingInterpretation(AnswerPeriod period) {
    switch (period) {
      case AnswerPeriod.sameDay:
        return 'ஒரே நாள் (24 மணி நேரத்திற்குள் காரியம் மிக விரைவில் கைகூடும்)';
      case AnswerPeriod.withinOneMonth:
        return 'ஒரு மாதத்திற்குள் (சாதகமான சுப பலன்கள் ஒரு மாதத்திற்குள் கிடைக்கும்)';
      case AnswerPeriod.oneToTwoMonths:
        return 'ஒன்று அல்லது இரண்டு மாதங்கள் (சராசரி கால இடைவெளியில் காரியம் முடியும்)';
      case AnswerPeriod.delayed:
        return 'தாமதம் (காரியத்தில் தடைகள் நீங்க கூடுதல் கால அவகாசமும் வழிபாடும் தேவை)';
    }
  }
}
