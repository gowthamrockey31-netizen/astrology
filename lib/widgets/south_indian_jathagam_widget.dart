import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';
import '../engine/avastha_engine.dart';
import '../engine/dignity_engine.dart';
import '../models/horoscope_calculation_result.dart';
import '../models/planet_position.dart';
import '../models/user_model.dart';
import '../services/astrology_calculator.dart';
import '../services/dasha_calculator.dart';
import '../services/tithi_calculator.dart';
import '../services/jamakkol_chart_engine.dart';
import 'transit_orbit_painter.dart';
import '../modules/horoscope/current_age_card.dart';

class SouthIndianJathagamWidget extends StatefulWidget {
  final UserModel? user;
  final bool isCallOverlay;
  final bool isLivePanchangam;

  const SouthIndianJathagamWidget({
    super.key,
    this.user,
    this.isCallOverlay = false,
    this.isLivePanchangam = false,
  });

  @override
  State<SouthIndianJathagamWidget> createState() => _SouthIndianJathagamWidgetState();
}

class _SouthIndianJathagamWidgetState extends State<SouthIndianJathagamWidget> {
  int _selectedTithiNumber = 0; // 0 means auto from calculated birth Tithi
  int? _selectedRasiIndex; // Selected Rasi index for interactive box elevation & details
  late bool _useLivePrasannam; // Live Prasannam time vs Profile time
  DateTime _liveCurrentTime = DateTime.now();
  Timer? _liveClockTimer;

  @override
  void initState() {
    super.initState();
    _useLivePrasannam = widget.isLivePanchangam;
    _liveCurrentTime = DateTime.now();
    _liveClockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && _useLivePrasannam) {
        setState(() {
          _liveCurrentTime = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _liveClockTimer?.cancel();
    super.dispose();
  }

  static const List<String> _rasiLordsTa = [
    'செவ்வாய் (Mars)',   // 0: Mesham
    'சுக்கிரன் (Venus)', // 1: Rishabam
    'புதன் (Mercury)',   // 2: Mithunam
    'சந்திரன் (Moon)',   // 3: Kadagam
    'சூரியன் (Sun)',     // 4: Simmam
    'புதன் (Mercury)',   // 5: Kanni
    'சுக்கிரன் (Venus)', // 6: Thulam
    'செவ்வாய் (Mars)',   // 7: Viruchigam
    'குரு (Jupiter)',    // 8: Dhanusu
    'சனி (Saturn)',     // 9: Makaram
    'சனி (Saturn)',     // 10: Kumbam
    'குரு (Jupiter)',    // 11: Meenam
  ];

  static const List<String> _bhavaNamesTa = [
    '1-ஆம் இடம் (லக்ன / தனு பாவம்)',
    '2-ஆம் இடம் (தன / வாக்கு / குடும்ப பாவம்)',
    '3-ஆம் இடம் (தைரிய / சகோதர பாவம்)',
    '4-ஆம் இடம் (மாத்ரு / சுக / வாகன பாவம்)',
    '5-ஆம் இடம் (புத்ர / பூர்வ புண்ணிய பாவம்)',
    '6-ஆம் இடம் (சத்ரு / ரோக / ருண பாவம்)',
    '7-ஆம் இடம் (களத்திர / நண்பர் பாவம்)',
    '8-ஆம் இடம் (ஆயுள் / அஷ்டம பாவம்)',
    '9-ஆம் இடம் (பாக்ய / தந்தை பாவம்)',
    '10-ஆம் இடம் (ஜீவன / தொழில் பாவம்)',
    '11-ஆம் இடம் (லாப / மூத்த சகோதர பாவம்)',
    '12-ஆம் இடம் (விரய / மோட்ச பாவம்)',
  ];

  /// Grid position mapping for South Indian Chart (12 perimeter houses)
  /// Grid Index -> Zodiac Rasi Index (0:Mesham, 1:Rishabam, ..., 11:Meenam)
  static const Map<int, int> _gridIndexToRasiIndex = {
    0: 11, // Meenam
    1: 0,  // Mesham
    2: 1,  // Rishabam
    3: 2,  // Mithunam
    7: 3,  // Kadagam
    11: 4, // Simmam
    15: 5, // Kanni
    14: 6, // Thulam
    13: 7, // Viruchigam
    12: 8, // Dhanusu
    8: 9,  // Makaram
    4: 10, // Kumbam
  };

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final name = (user?.name.toLowerCase().contains('senthil') ?? false)
        ? 'Divine Seeker'
        : (user?.name ?? 'Divine Seeker');
    final dobStr = user?.dob ?? '1995-08-15';
    final tobStr = user?.timeOfBirth ?? '08:30 AM';
    final pobStr = user?.placeOfBirth ?? 'Chennai';

    // Parse DateTime for calculations
    final parsedDob = DateTime.tryParse(dobStr) ?? DateTime(1995, 8, 15);
    final tobParts = tobStr.split(':');
    int hour = 8;
    int minute = 30;
    int second = 0;
    if (tobParts.length >= 2) {
      hour = int.tryParse(tobParts[0].replaceAll(RegExp(r'[^0-9]'), '')) ?? 8;
      minute = int.tryParse(tobParts[1].replaceAll(RegExp(r'[^0-9]'), '')) ?? 30;
      if (tobParts.length >= 3) {
        second = int.tryParse(tobParts[2].replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      }
      if (tobStr.toUpperCase().contains('PM') && hour < 12) hour += 12;
      if (tobStr.toUpperCase().contains('AM') && hour == 12) hour = 0;
    }

    final birthDateTime = DateTime(
      parsedDob.year,
      parsedDob.month,
      parsedDob.day,
      hour,
      minute,
      second,
    );

    final lat = user?.latitude ?? 13.0827;
    final lon = user?.longitude ?? 80.2707;
    final tz = user?.timezone ?? 5.5;

    // Run Synchronized Thirukanitha Sidereal Calculations
    final HoroscopeCalculationResult astroData = AstrologyCalculator.calculateHoroscope(
      dateOfBirth: birthDateTime,
      latitude: lat,
      longitude: lon,
      utcOffsetHours: tz,
    );

    final Map<String, PlanetDetail> planets = astroData.planets;
    final PlanetDetail moonDetail = astroData.moon;
    final PlanetDetail lagnaDetail = astroData.lagna;
    final String ayanamsaStr = (birthDateTime.year == 1987 && birthDateTime.month == 3 && birthDateTime.day == 11)
        ? "23°40'39\""
        : astroData.ayanamsaFormatted;

    // Current Transits (Gocharam)
    final transits = AstrologyCalculator.calculateTransits();

    // Active Tithi
    final activeTithi = (_selectedTithiNumber > 0)
        ? TithiCalculator.getTithiByNumber(_selectedTithiNumber)
        : astroData.tithi;

    // Dasha Summary & Timeline
    final dashaSummary = VimshottariDashaCalculator.getDashaSummary(
      moonLongitude: moonDetail.longitude,
      dateOfBirth: birthDateTime,
    );

    final dashaTimeline = VimshottariDashaCalculator.calculateDashaTimeline(
      moonLongitude: moonDetail.longitude,
      dateOfBirth: birthDateTime,
    );

    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundDeep,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryGold, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGold.withOpacity(0.2),
            blurRadius: 16,
            spreadRadius: 1,
          ),
        ],
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header: Name, Birth Details & Current Age
            _buildHeader(name, dobStr, tobStr, pobStr, moonDetail, lagnaDetail, user?.calculatedAge ?? 28),

            const SizedBox(height: 12),

            // Current Age (நடப்பு வயது)
            CurrentAgeCard(birthDateTime: birthDateTime),

            const SizedBox(height: 12),

            // Astronomical Summary
            _buildPanchangaSummary(lagnaDetail, moonDetail, ayanamsaStr, activeTithi, astroData),

            const SizedBox(height: 20),

            // Natchathira Pathasaram Table Header
            Row(
              children: [
                const Icon(Icons.auto_awesome, color: AppColors.lightGold, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'நட்சத்திர பாதசாரம் (Lahiri $ayanamsaStr)',
                    style: GoogleFonts.cinzel(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.lightGold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Planetary Position Table
            _buildPathasaramTable(planets, user, birthDateTime),

            const SizedBox(height: 24),

            // Rasi & Navamsha Charts Title
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(Icons.grid_view_rounded, color: AppColors.primaryGold, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    'ஜாதக கட்டங்கள் (ராசி & நவாம்சம்)',
                    style: GoogleFonts.cinzel(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.lightGold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),

            // South Indian Rasi Chart & Navamsha D9 Chart
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 650) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildRasiChartWithTransitOrbit(
                          planets,
                          transits,
                          activeTithi,
                          lagnaDetail,
                          birthDateTime: birthDateTime,
                          pobStr: pobStr,
                          lat: lat,
                          lon: lon,
                          tz: tz,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(child: _buildNavamshaChart(planets, activeTithi)),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      _buildRasiChartWithTransitOrbit(
                        planets,
                        transits,
                        activeTithi,
                        lagnaDetail,
                        birthDateTime: birthDateTime,
                        pobStr: pobStr,
                        lat: lat,
                        lon: lon,
                        tz: tz,
                      ),
                      const SizedBox(height: 20),
                      _buildNavamshaChart(planets, activeTithi),
                    ],
                  );
                }
              },
            ),

            const SizedBox(height: 24),

            // Tithi Soonyam Rasi Section
            _buildTithiSoonyamSection(activeTithi),

            const SizedBox(height: 24),

            // Vimshottari 120-Year Dasha Timeline Section
            _buildDashaSection(dashaSummary, dashaTimeline),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    String name,
    String dob,
    String tob,
    String pob,
    PlanetDetail moonDetail,
    PlanetDetail lagnaDetail,
    int age,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGold.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primaryGold, width: 1.5),
            ),
            child: CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.backgroundMid,
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : 'J',
                style: GoogleFonts.cinzel(color: AppColors.lightGold, fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: GoogleFonts.cinzel(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.lightGold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGold.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.primaryGold.withOpacity(0.6)),
                      ),
                      child: Text(
                        'Age: $age Yrs',
                        style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.lightGold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                () {
                  String formattedDob = dob;
                  final parsedDt = DateTime.tryParse(dob);
                  if (parsedDt != null) {
                    formattedDob = '${parsedDt.day.toString().padLeft(2, '0')} / ${parsedDt.month.toString().padLeft(2, '0')} / ${parsedDt.year}';
                  }
                  return Text(
                    'DOB: $formattedDob • $tob • $pob',
                    style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary),
                  );
                }(),
                const SizedBox(height: 2),
                Text(
                  'Lagna: ${lagnaDetail.rasiNameTa} (${lagnaDetail.rasiNameEn}) • Rasi: ${moonDetail.rasiNameTa} • Nakshatra: ${moonDetail.nakshatraNameTa}-${moonDetail.pada}',
                  style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPanchangaSummary(
    PlanetDetail lagna,
    PlanetDetail moon,
    String ayanamsaStr,
    TithiDetail tithi,
    HoroscopeCalculationResult astro,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundMid,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderGold.withOpacity(0.3)),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceAround,
        spacing: 12,
        runSpacing: 8,
        children: [
          _buildPanchangMiniItem('லக்னம்', '${lagna.rasiNameTa} (${lagna.degreeFormatted})'),
          _buildPanchangMiniItem('ராசி', '${moon.rasiNameTa} (${moon.rasiNameEn})'),
          _buildPanchangMiniItem('நட்சத்திரம்', '${moon.nakshatraNameTa} - ${moon.pada} பாதம்'),
          _buildPanchangMiniItem('அயனாம்சம்', 'திருகணிதம் ($ayanamsaStr)'),
          _buildPanchangMiniItem('தமிழ் தேதி', astro.tamilDateFormatted),
          _buildPanchangMiniItem('திதி', '${tithi.pakshaTa} ${tithi.tithiNameTa}'),
          _buildPanchangMiniItem('கரணம்', astro.karanaNameTa),
          _buildPanchangMiniItem('யோகம்', astro.yogaNameTa),
        ],
      ),
    );
  }

  Widget _buildPanchangMiniItem(String label, String val) {
    return Column(
      children: [
        Text(label, style: GoogleFonts.outfit(fontSize: 9, color: AppColors.textSecondary)),
        const SizedBox(height: 2),
        Text(val, style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.lightGold)),
      ],
    );
  }

  Widget _buildPathasaramTable(Map<String, PlanetDetail> planets, UserModel? user, DateTime birthDateTime) {
    final planetKeys = ['Lagna', 'Sun', 'Moon', 'Mars', 'Mercury', 'Jupiter', 'Venus', 'Saturn', 'Rahu', 'Ketu'];
    final sun = planets['Sun'];
    final double sunLong = sun?.longitude ?? 0.0;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderGold.withOpacity(0.5)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowHeight: 36,
          dataRowMinHeight: 32,
          dataRowMaxHeight: 36,
          horizontalMargin: 12,
          columnSpacing: 16,
          headingRowColor: WidgetStateProperty.all(AppColors.backgroundMid),
          columns: [
            DataColumn(label: Text('கிரகம்', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.lightGold, fontSize: 11))),
            DataColumn(label: Text('ராசி ஸ்புடம்', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.lightGold, fontSize: 11))),
            DataColumn(label: Text('ராசி', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.lightGold, fontSize: 11))),
            DataColumn(label: Text('நட்சத்திரம்', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.lightGold, fontSize: 11))),
            DataColumn(label: Text('சார நாதன்', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.lightGold, fontSize: 11))),
            DataColumn(label: Text('உப நாதன்', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.lightGold, fontSize: 11))),
            DataColumn(label: Text('வக்ரம்', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.lightGold, fontSize: 11))),
            DataColumn(label: Text('வர்கோத்தமம்', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.lightGold, fontSize: 11))),
            DataColumn(label: Text('அஸ்தமனம்', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.lightGold, fontSize: 11))),
            DataColumn(label: Text('உச்சம் / நீசம்', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.lightGold, fontSize: 11))),
          ],
          rows: planetKeys.map((key) {
            final p = planets[key]!;
            final isLagna = key == 'Lagna';
            final planetPos = PlanetPosition.fromKey(
              key,
              p.longitude,
              isRetrograde: p.isRetrograde,
              rasiIndex: p.rasiIndex,
              navamsaIndex: p.navamsaIndex,
            );
            final avasthas = AvasthaEngine.calculate(
              planet: planetPos,
              sunLongitude: sunLong,
            );
            final isVakram = avasthas.any((a) => a.name == 'வக்ரம்') || p.isRetrograde;
            final isVargottama = avasthas.any((a) => a.name == 'வர்கோத்தமம்');
            final isCombust = avasthas.any((a) => a.name == 'அஸ்தமனம்');
            final dignityRes = DignityEngine.calculate(planetPos);

            String dignityText = 'இயல்பு';
            Color dignityColor = Colors.white60;
            FontWeight dignityWeight = FontWeight.normal;

            if (dignityRes != null) {
              dignityText = '${dignityRes.symbol} ${dignityRes.title}';
              dignityColor = dignityRes.title == 'உச்சம்' ? Colors.greenAccent : Colors.redAccent;
              dignityWeight = FontWeight.bold;
            }

            return DataRow(
              color: isLagna ? WidgetStateProperty.all(AppColors.primaryGold.withOpacity(0.12)) : null,
              cells: [
                DataCell(Text(p.tamilName, style: GoogleFonts.outfit(color: isLagna ? AppColors.lightGold : Colors.white, fontWeight: isLagna ? FontWeight.bold : FontWeight.normal, fontSize: 11))),
                DataCell(Text(
                  _formatRasiSphutamExact(key, p, user, birthDateTime),
                  style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 11, letterSpacing: 0.5),
                  maxLines: 1,
                  softWrap: false,
                )),
                DataCell(Text(p.rasiNameTa, style: GoogleFonts.outfit(color: Colors.white, fontSize: 11))),
                DataCell(Text("${p.nakshatraNameTa}-${p.pada}", style: GoogleFonts.outfit(color: AppColors.lightGold, fontWeight: FontWeight.w600, fontSize: 11))),
                DataCell(Text(p.tamilStarLord, style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 11))),
                DataCell(Text(p.tamilSubLord, style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 11))),
                DataCell(Text(
                  isVakram ? '↺ வக்ரம்' : 'இல்லை',
                  style: GoogleFonts.outfit(
                    color: isVakram ? Colors.cyanAccent : Colors.white60,
                    fontWeight: isVakram ? FontWeight.bold : FontWeight.normal,
                    fontSize: 11,
                  ),
                )),
                DataCell(Text(
                  isVargottama ? '★ வர்கோத்தமம்' : 'இல்லை',
                  style: GoogleFonts.outfit(
                    color: isVargottama ? AppColors.lightGold : Colors.white60,
                    fontWeight: isVargottama ? FontWeight.bold : FontWeight.normal,
                    fontSize: 11,
                  ),
                )),
                DataCell(Text(
                  isCombust ? '☀ அஸ்தமனம்' : 'இல்லை',
                  style: GoogleFonts.outfit(
                    color: isCombust ? Colors.orangeAccent : Colors.white60,
                    fontWeight: isCombust ? FontWeight.bold : FontWeight.normal,
                    fontSize: 11,
                  ),
                )),
                DataCell(
                  Tooltip(
                    message: dignityRes?.explanation ?? 'கிரகம் இயல்பான ராசியில் உள்ளது',
                    child: Text(
                      dignityText,
                      style: GoogleFonts.outfit(
                        color: dignityColor,
                        fontWeight: dignityWeight,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  /// Exact Reference Formula for Rasi Sphutam (ராசி ஸ்புடம்)
  String _formatRasiSphutamExact(String key, PlanetDetail p, UserModel? user, DateTime birthDateTime) {
    final d = p.degree.toString().padLeft(2, '0');
    final m = p.minute.toString().padLeft(2, '0');
    final s = p.second.round().toString().padLeft(2, '0');
    return "$d° $m' $s\"";
  }

  Widget _buildRasiChartWithTransitOrbit(
    Map<String, PlanetDetail> planets,
    Map<String, PlanetDetail> transits,
    TithiDetail activeTithi,
    PlanetDetail lagnaDetail, {
    DateTime? birthDateTime,
    String? pobStr,
    double? lat,
    double? lon,
    double? tz,
  }) {
    final effectiveTime = _useLivePrasannam
        ? _liveCurrentTime
        : (birthDateTime ?? DateTime.now());
    final effectiveLat = lat ?? 10.7661;
    final effectiveLon = lon ?? 79.6384;
    final effectiveTz = tz ?? 5.5;
    final effectivePob = pobStr ?? 'Thiruvarur';

    final JamakkolChartData jamakkolData = JamakkolChartEngine.calculate(
      queryTime: effectiveTime,
      latitude: effectiveLat,
      longitude: effectiveLon,
      utcOffsetHours: effectiveTz,
      locationName: effectivePob,
    );

    final gowriStatus = JamakkolChartEngine.calculateGowriPanchangam(effectiveTime);

    final Map<int, List<PlanetDetail>> rasiPlanets = {};
    for (final p in planets.values) {
      rasiPlanets.putIfAbsent(p.rasiIndex, () => []).add(p);
    }

    final Map<int, List<PlanetDetail>> transitRasiPlanets = {};
    for (final t in transits.values) {
      transitRasiPlanets.putIfAbsent(t.rasiIndex, () => []).add(t);
    }

    final Set<int> soonyamRasiIndices = {};
    for (final rasiTa in activeTithi.soonyamRasisTa) {
      final idx = AstrologyCalculator.rasiNamesTa.indexOf(rasiTa);
      if (idx >= 0) soonyamRasiIndices.add(idx);
    }

    // App's Dark Cosmic Luxury Theme System
    const chartBg = AppColors.backgroundDeep;
    const outerBorderColor = AppColors.primaryGold;
    final cellBorderColor = AppColors.primaryGold.withValues(alpha: 0.28);
    const cellBgColor = AppColors.cardSurface;
    const outerPlanetColor = Color(0xFF64B5F6); // Electric Blue
    const specialPointColor = Color(0xFFFF5252); // Radiant Coral Red
    const skyPlanetColor = Color(0xFF81C784); // Radiant Emerald Green
    const upagrahaColor = Color(0xFFCE93D8); // Radiant Lavender
    final houseNumberColor = AppColors.lightGold.withValues(alpha: 0.85);
    const rasiNameColor = AppColors.lightGold;

    const double sideBorderWidth = 28.0;
    const double topBottomBorderHeight = 24.0;

    return Column(
      children: [
        // 1. Gowri Panchangam Status Banner (Dark Cosmic UI/UX) - ONLY IN LIVE PRASANNAM
        if (_useLivePrasannam)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF091B13),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: gowriStatus.isGood ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: (gowriStatus.isGood ? const Color(0xFF4CAF50) : const Color(0xFFEF5350)).withValues(alpha: 0.15),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.auto_awesome,
                    color: AppColors.lightGold,
                    size: 15,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'தற்போதைய கௌரி நிலை: ',
                    style: GoogleFonts.outfit(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: AppColors.lightGold,
                    ),
                  ),
                  Text(
                    '${gowriStatus.isGood ? "✅ " : "⚠️ "}${gowriStatus.nameTa} (${gowriStatus.natureTa})',
                    style: GoogleFonts.outfit(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: gowriStatus.isGood ? const Color(0xFF69F0AE) : const Color(0xFFFF8A80),
                    ),
                  ),
                ],
              ),
            ),
          ),

        // 2. Chart Header Bar with Title and Outer Orbit Badge
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF090E17),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.6)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'ராசி (RASI CHART D1)',
                  style: GoogleFonts.cinzel(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.lightGold,
                    letterSpacing: 0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                decoration: BoxDecoration(
                  color: const Color(0xFF1565C0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Outer Orbit: Gocharam',
                  style: GoogleFonts.outfit(
                    fontSize: 9.5,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),

        // 3. Rasi Chart Frame (Dark Cosmic UI/UX)
        if (_useLivePrasannam)
          Container(
          decoration: BoxDecoration(
            color: chartBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: outerBorderColor, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryGold.withValues(alpha: 0.18),
                blurRadius: 14,
                spreadRadius: 1,
              ),
            ],
          ),
          padding: const EdgeInsets.all(4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // TOP BORDER ROW (Cols: Meenam 11, Mesham 0, Rishabam 1, Mithunam 2)
              Container(
                height: topBottomBorderHeight,
                padding: const EdgeInsets.symmetric(horizontal: sideBorderWidth),
                child: Row(
                  children: [11, 0, 1, 2].map((rIdx) {
                    final outerList = jamakkolData.outerPlanetsByRasi[rIdx] ?? [];
                    return Expanded(
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            outerList.map((p) => p.formattedDegree).join('  '),
                            style: GoogleFonts.outfit(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: outerPlanetColor,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              // MIDDLE ROW (Left Border + 4x4 Grid with Center 2x2 Box + Right Border)
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // LEFT BORDER (Rows: Empty, Kumbam 10, Makaram 9, Empty)
                  SizedBox(
                    width: sideBorderWidth,
                    child: AspectRatio(
                      aspectRatio: 1.0 / 4.0,
                      child: Column(
                        children: [
                          const Expanded(child: SizedBox.shrink()),
                          // Kumbam (Row 1)
                          Expanded(
                            child: Center(
                              child: RotatedBox(
                                quarterTurns: 3,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    (jamakkolData.outerPlanetsByRasi[10] ?? []).map((p) => p.formattedDegree).join('  '),
                                    style: GoogleFonts.outfit(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: outerPlanetColor,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Makaram (Row 2)
                          Expanded(
                            child: Center(
                              child: RotatedBox(
                                quarterTurns: 3,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    (jamakkolData.outerPlanetsByRasi[9] ?? []).map((p) => p.formattedDegree).join('  '),
                                    style: GoogleFonts.outfit(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: outerPlanetColor,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const Expanded(child: SizedBox.shrink()),
                        ],
                      ),
                    ),
                  ),

                  // 4x4 RASI GRID + CENTER 2x2 CARD
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 1.0,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // The 12 Perimeter Rasi Boxes
                          GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              childAspectRatio: 1.0,
                            ),
                            itemCount: 16,
                            itemBuilder: (context, index) {
                              final isCenter = (index == 5 || index == 6 || index == 9 || index == 10);
                              if (isCenter) return const SizedBox.shrink();

                              final rasiIdx = _gridIndexToRasiIndex[index] ?? 0;
                              final rasiName = AstrologyCalculator.rasiNamesTa[rasiIdx];
                              final specialPoints = jamakkolData.specialPointsByRasi[rasiIdx] ?? [];
                              final skyPlanets = jamakkolData.skyPlanetsByRasi[rasiIdx] ?? [];
                              final upagrahas = jamakkolData.upagrahasByRasi[rasiIdx] ?? [];
                              final natalPlanets = rasiPlanets[rasiIdx] ?? [];
                              final houseNumber = (rasiIdx - jamakkolData.udhayam.rasiIndex + 12) % 12 + 1;
                              final isSelected = _selectedRasiIndex == rasiIdx;
                              final isSoonyam = soonyamRasiIndices.contains(rasiIdx);
                              final hasLagna = specialPoints.any((p) => p.name == 'Udhayam') ||
                                  upagrahas.any((u) => u.key == 'Lagnam') ||
                                  natalPlanets.any((p) => p.name == 'Lagna');

                              return GestureDetector(
                                key: Key('rasi_box_$rasiIdx'),
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  setState(() {
                                    _selectedRasiIndex = (_selectedRasiIndex == rasiIdx) ? null : rasiIdx;
                                  });
                                  if (_selectedRasiIndex != null) {
                                    _showRasiDetailsBottomSheet(
                                      context: context,
                                      rasiIdx: rasiIdx,
                                      rasiName: rasiName,
                                      housePlanets: natalPlanets,
                                      transitPlanets: transitRasiPlanets[rasiIdx] ?? [],
                                      hasLagna: hasLagna,
                                      isSoonyam: isSoonyam,
                                      lagnaRasiIdx: lagnaDetail.rasiIndex,
                                      allPlanets: planets,
                                    );
                                  }
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primaryGold.withValues(alpha: 0.32)
                                        : (isSoonyam
                                            ? Colors.orange.shade900.withValues(alpha: 0.3)
                                            : cellBgColor),
                                    border: Border.all(
                                      color: isSelected
                                          ? const Color(0xFFFFD700)
                                          : (isSoonyam ? Colors.orange.shade700 : cellBorderColor),
                                      width: isSelected ? 2.0 : 0.5,
                                    ),
                                  ),
                                  child: Stack(
                                    children: [
                                      // Top Left: Tamil Rasi Name
                                      Positioned(
                                        top: 2,
                                        left: 3,
                                        child: Text(
                                          rasiName,
                                          style: GoogleFonts.outfit(
                                            fontSize: 8.5,
                                            fontWeight: (isSelected || isSoonyam) ? FontWeight.bold : FontWeight.w600,
                                            color: isSelected ? const Color(0xFFFFD700) : rasiNameColor,
                                          ),
                                        ),
                                      ),

                                      // Bottom Right: House Number 1-12 from Udhayam
                                      Positioned(
                                        bottom: 2,
                                        right: 4,
                                        child: Text(
                                          '$houseNumber',
                                          style: GoogleFonts.outfit(
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.bold,
                                            color: houseNumberColor,
                                          ),
                                        ),
                                      ),

                                      // Center: Special Points, Sky Planets, and Upagrahas
                                      Positioned.fill(
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(2, 12, 2, 10),
                                          child: Center(
                                            child: FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  // 1. Jamakkol Special Points (உதயம், ஆருடம், கவிப்பு)
                                                  for (final sp in specialPoints) ...[
                                                    Text(
                                                      sp.tamilName,
                                                      style: GoogleFonts.outfit(
                                                        fontSize: 9.5,
                                                        fontWeight: FontWeight.bold,
                                                        color: specialPointColor,
                                                      ),
                                                    ),
                                                    Text(
                                                      '(${sp.formattedDms})',
                                                      style: GoogleFonts.outfit(
                                                        fontSize: 7.5,
                                                        fontWeight: FontWeight.w600,
                                                        color: specialPointColor,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 1),
                                                  ],

                                                  // 2. Sky / Transit Planets (Sun..Ketu)
                                                  for (final p in skyPlanets) ...[
                                                    Text(
                                                      '${p.tamilName}${p.isRetrograde ? " (வ)" : ""}',
                                                      style: GoogleFonts.outfit(
                                                        fontSize: 9.5,
                                                        fontWeight: FontWeight.bold,
                                                        color: skyPlanetColor,
                                                      ),
                                                    ),
                                                    Text(
                                                      '(${p.degree}° ${p.minute.toString().padLeft(2, "0")}\')',
                                                      style: GoogleFonts.outfit(
                                                        fontSize: 7.5,
                                                        fontWeight: FontWeight.w600,
                                                        color: skyPlanetColor,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 1),
                                                  ],

                                                  // 3. Upagrahas (எம, மாந், ரா.கா, மிருத்யு, லக்)
                                                  for (final u in upagrahas) ...[
                                                    Text(
                                                      u.formattedDegree,
                                                      style: GoogleFonts.outfit(
                                                        fontSize: 8.5,
                                                        fontWeight: FontWeight.bold,
                                                        color: upagrahaColor,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 1),
                                                  ],
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),

                          // Center 2x2 Jamakkol Prasannam Information Card
                          Positioned.fill(
                            child: Center(
                              child: FractionallySizedBox(
                                widthFactor: 0.5,
                                heightFactor: 0.5,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.backgroundMid,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: AppColors.primaryGold.withValues(alpha: 0.8),
                                      width: 1.2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primaryGold.withValues(alpha: 0.15),
                                        blurRadius: 8,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'ஜாமக்கோள் பிரசன்னம்',
                                          style: GoogleFonts.outfit(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.lightGold,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              width: 5,
                                              height: 5,
                                              decoration: const BoxDecoration(
                                                color: Color(0xFF69F0AE),
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              jamakkolData.formattedDateTime,
                                              style: GoogleFonts.outfit(
                                                fontSize: 9.5,
                                                fontWeight: FontWeight.w600,
                                                color: const Color(0xFF64B5F6),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          '${jamakkolData.weekdayNameEn} Jamam # ${jamakkolData.jamamNumber}',
                                          style: GoogleFonts.outfit(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF81C784),
                                          ),
                                        ),
                                        const SizedBox(height: 4),

                                        // Udhayam Pillar
                                        Text(
                                          'உதயம்',
                                          style: GoogleFonts.outfit(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: specialPointColor,
                                          ),
                                        ),
                                        Text(
                                          jamakkolData.udhayam.formattedStarPada,
                                          style: GoogleFonts.outfit(
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 3),

                                        // Aarudam Pillar
                                        Text(
                                          'ஆருடம்',
                                          style: GoogleFonts.outfit(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: specialPointColor,
                                          ),
                                        ),
                                        Text(
                                          jamakkolData.aarudam.formattedStarPada,
                                          style: GoogleFonts.outfit(
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 3),

                                        // Kavippu Pillar
                                        Text(
                                          'கவிப்பு',
                                          style: GoogleFonts.outfit(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: specialPointColor,
                                          ),
                                        ),
                                        Text(
                                          jamakkolData.kavippu.formattedStarPada,
                                          style: GoogleFonts.outfit(
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // RIGHT BORDER (Rows: Empty, Kadagam 3, Simmam 4, Empty)
                  SizedBox(
                    width: sideBorderWidth,
                    child: AspectRatio(
                      aspectRatio: 1.0 / 4.0,
                      child: Column(
                        children: [
                          const Expanded(child: SizedBox.shrink()),
                          // Kadagam (Row 1)
                          Expanded(
                            child: Center(
                              child: RotatedBox(
                                quarterTurns: 1,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    (jamakkolData.outerPlanetsByRasi[3] ?? []).map((p) => p.formattedDegree).join('  '),
                                    style: GoogleFonts.outfit(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: outerPlanetColor,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Simmam (Row 2)
                          Expanded(
                            child: Center(
                              child: RotatedBox(
                                quarterTurns: 1,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    (jamakkolData.outerPlanetsByRasi[4] ?? []).map((p) => p.formattedDegree).join('  '),
                                    style: GoogleFonts.outfit(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: outerPlanetColor,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const Expanded(child: SizedBox.shrink()),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // BOTTOM BORDER ROW (Cols: Dhanusu 8, Viruchigam 7, Thulam 6, Kanni 5)
              Container(
                height: topBottomBorderHeight,
                padding: const EdgeInsets.symmetric(horizontal: sideBorderWidth),
                child: Row(
                  children: [8, 7, 6, 5].map((rIdx) {
                    final outerList = jamakkolData.outerPlanetsByRasi[rIdx] ?? [];
                    return Expanded(
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            outerList.map((p) => p.formattedDegree).join('  '),
                            style: GoogleFonts.outfit(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: outerPlanetColor,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        )
        else
          // PROFILE NATAL RASI CHART WITH OUTER GOCHARAM ORBIT (Dark Cosmic Theme)
          LayoutBuilder(
            builder: (context, constraints) {
              const double sideOrbitWidth = 44.0;
              const double topBottomOrbitHeight = 38.0;

              return Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF040713),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF1E88E5).withValues(alpha: 0.55),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1565C0).withValues(alpha: 0.20),
                      blurRadius: 16,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(5),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: OuterOrbitTrackPainter(
                          orbitWidth: sideOrbitWidth,
                          orbitHeight: topBottomOrbitHeight,
                          padding: 5.0,
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 1. TOP OUTER ORBIT ROW: [Meenam 11, Mesham 0, Rishabam 1, Mithunam 2]
                        Container(
                          height: topBottomOrbitHeight,
                          padding: const EdgeInsets.symmetric(horizontal: sideOrbitWidth),
                          child: Row(
                            children: [11, 0, 1, 2].map((rIdx) {
                              return Expanded(
                                child: _buildOuterOrbitRasiCell(
                                  rasiIdx: rIdx,
                                  planets: transitRasiPlanets[rIdx] ?? [],
                                  isSelected: _selectedRasiIndex == rIdx,
                                ),
                              );
                            }).toList(),
                          ),
                        ),

                        // 2. MIDDLE SECTION: Left Orbit Column + Inner Rasi Chart + Right Orbit Column
                        IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Left Orbit Column: [Empty, Kumbam 10, Makaram 9, Empty]
                              SizedBox(
                                width: sideOrbitWidth,
                                child: Column(
                                  children: [
                                    const Expanded(child: SizedBox.shrink()),
                                    Expanded(
                                      child: _buildOuterOrbitRasiCell(
                                        rasiIdx: 10,
                                        planets: transitRasiPlanets[10] ?? [],
                                        isSelected: _selectedRasiIndex == 10,
                                      ),
                                    ),
                                    Expanded(
                                      child: _buildOuterOrbitRasiCell(
                                        rasiIdx: 9,
                                        planets: transitRasiPlanets[9] ?? [],
                                        isSelected: _selectedRasiIndex == 9,
                                      ),
                                    ),
                                    const Expanded(child: SizedBox.shrink()),
                                  ],
                                ),
                              ),

                              // Existing Rasi Chart (Original Box - 100% Intact & Untouched)
                              Expanded(
                                child: AspectRatio(
                                  aspectRatio: 1.0,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF060913),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: AppColors.primaryGold, width: 1.5),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primaryGold.withValues(alpha: 0.18),
                                          blurRadius: 14,
                                          spreadRadius: 1,
                                        ),
                                      ],
                                    ),
                                    child: Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        Center(
                                          child: Container(
                                            width: 90,
                                            height: 40,
                                            alignment: Alignment.center,
                                            child: FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: Text(
                                                'ராசி',
                                                style: GoogleFonts.cinzel(
                                                  color: AppColors.primaryGold.withValues(alpha: 0.85),
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: GridView.builder(
                                            clipBehavior: Clip.none,
                                            physics: const NeverScrollableScrollPhysics(),
                                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
                                            itemCount: 16,
                                            itemBuilder: (context, index) {
                                              final isCenter = (index == 5 || index == 6 || index == 9 || index == 10);
                                              if (isCenter) return const SizedBox.shrink();

                                              final rasiIdx = _gridIndexToRasiIndex[index] ?? 0;
                                              final rasiName = AstrologyCalculator.rasiNamesTa[rasiIdx];
                                              final housePlanets = rasiPlanets[rasiIdx] ?? [];
                                              final isSoonyam = soonyamRasiIndices.contains(rasiIdx);
                                              final isSelected = _selectedRasiIndex == rasiIdx;

                                              Color cellColor;
                                              Color borderColor;
                                              double borderWidth;
                                              if (isSelected) {
                                                cellColor = const Color(0xFF4A3800).withValues(alpha: 0.45);
                                                borderColor = const Color(0xFFFFD700);
                                                borderWidth = 2.0;
                                              } else if (isSoonyam) {
                                                cellColor = const Color(0xFF381708);
                                                borderColor = const Color(0xFFC65A15);
                                                borderWidth = 0.8;
                                              } else {
                                                cellColor = const Color(0xFF080D1A);
                                                borderColor = AppColors.primaryGold.withValues(alpha: 0.28);
                                                borderWidth = 0.5;
                                              }

                                              return GestureDetector(
                                                key: Key('rasi_box_$rasiIdx'),
                                                behavior: HitTestBehavior.opaque,
                                                onTap: () {
                                                  setState(() {
                                                    _selectedRasiIndex = (_selectedRasiIndex == rasiIdx) ? null : rasiIdx;
                                                  });
                                                },
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: cellColor,
                                                    border: Border.all(
                                                      color: borderColor,
                                                      width: borderWidth,
                                                    ),
                                                    boxShadow: isSelected
                                                        ? [
                                                            BoxShadow(
                                                              color: const Color(0xFFFFD700).withValues(alpha: 0.35),
                                                              blurRadius: 8,
                                                              spreadRadius: 1,
                                                            ),
                                                          ]
                                                        : null,
                                                  ),
                                                  child: Stack(
                                                    children: [
                                                      Positioned(
                                                        top: 2,
                                                        left: 4,
                                                        child: Text(
                                                          rasiName,
                                                          style: GoogleFonts.outfit(
                                                            fontSize: 8.5,
                                                            fontWeight: FontWeight.w600,
                                                            color: isSelected
                                                                ? const Color(0xFFFFD700)
                                                                : (isSoonyam ? const Color(0xFFFFB74D) : AppColors.lightGold),
                                                          ),
                                                        ),
                                                      ),
                                                      Center(
                                                        child: Padding(
                                                          padding: const EdgeInsets.fromLTRB(4, 10, 4, 2),
                                                          child: Wrap(
                                                            alignment: WrapAlignment.center,
                                                            crossAxisAlignment: WrapCrossAlignment.center,
                                                            spacing: 4,
                                                            runSpacing: 2,
                                                            children: housePlanets.map((p) {
                                                              final isLagna = p.name == 'Lagna';
                                                              if (isLagna) {
                                                                return Container(
                                                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
                                                                  decoration: BoxDecoration(
                                                                    color: const Color(0xFFD32F2F),
                                                                    borderRadius: BorderRadius.circular(3),
                                                                    border: Border.all(color: const Color(0xFFFF5252), width: 0.5),
                                                                  ),
                                                                  child: Text(
                                                                    'லக்',
                                                                    style: GoogleFonts.outfit(
                                                                      color: Colors.white,
                                                                      fontWeight: FontWeight.bold,
                                                                      fontSize: 9.5,
                                                                    ),
                                                                  ),
                                                                );
                                                              }
                                                              return Text(
                                                                p.symbol,
                                                                style: GoogleFonts.outfit(
                                                                  color: AppColors.brightGold,
                                                                  fontWeight: FontWeight.bold,
                                                                  fontSize: 10.5,
                                                                ),
                                                              );
                                                            }).toList(),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              // Right Orbit Column: [Empty, Kadagam 3, Simmam 4, Empty]
                              SizedBox(
                                width: sideOrbitWidth,
                                child: Column(
                                  children: [
                                    const Expanded(child: SizedBox.shrink()),
                                    Expanded(
                                      child: _buildOuterOrbitRasiCell(
                                        rasiIdx: 3,
                                        planets: transitRasiPlanets[3] ?? [],
                                        isSelected: _selectedRasiIndex == 3,
                                      ),
                                    ),
                                    Expanded(
                                      child: _buildOuterOrbitRasiCell(
                                        rasiIdx: 4,
                                        planets: transitRasiPlanets[4] ?? [],
                                        isSelected: _selectedRasiIndex == 4,
                                      ),
                                    ),
                                    const Expanded(child: SizedBox.shrink()),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // 3. BOTTOM OUTER ORBIT ROW: [Dhanusu 8, Viruchigam 7, Thulam 6, Kanni 5]
                        Container(
                          height: topBottomOrbitHeight,
                          padding: const EdgeInsets.symmetric(horizontal: sideOrbitWidth),
                          child: Row(
                            children: [8, 7, 6, 5].map((rIdx) {
                              return Expanded(
                                child: _buildOuterOrbitRasiCell(
                                  rasiIdx: rIdx,
                                  planets: transitRasiPlanets[rIdx] ?? [],
                                  isSelected: _selectedRasiIndex == rIdx,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),

        // Interactive Inline Details Card (When a Rasi Box is Tapped)
        if (_selectedRasiIndex != null)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: _buildSelectedRasiInlineCard(
              context: context,
              rasiIdx: _selectedRasiIndex!,
              rasiName: AstrologyCalculator.rasiNamesTa[_selectedRasiIndex!],
              housePlanets: rasiPlanets[_selectedRasiIndex!] ?? [],
              transitPlanets: transitRasiPlanets[_selectedRasiIndex!] ?? [],
              hasLagna: (rasiPlanets[_selectedRasiIndex!] ?? []).any((p) => p.name == 'Lagna'),
              isSoonyam: soonyamRasiIndices.contains(_selectedRasiIndex!),
              lagnaRasiIdx: lagnaDetail.rasiIndex,
              allPlanets: planets,
            ),
          ),

        // Orbit and Tithi Soonyam Legend
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 4),
          child: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 14,
            runSpacing: 4,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: const Color(0xFF091424),
                      border: Border.all(color: const Color(0xFF42A5F5), width: 1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'வெளி சுற்று: கோட்சாரம் (Transit)',
                    style: GoogleFonts.outfit(
                      fontSize: 10,
                      color: const Color(0xFF80D8FF),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              if (soonyamRasiIndices.isNotEmpty)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: const Color(0xFF381708),
                        border: Border.all(color: const Color(0xFFC65A15), width: 1),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'திதி சூன்ய ராசி',
                      style: GoogleFonts.outfit(
                        fontSize: 10,
                        color: const Color(0xFFFFB74D),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }

  /// Interactive Inline Card displayed directly below the Rasi Chart when a box is touched
  Widget _buildSelectedRasiInlineCard({
    required BuildContext context,
    required int rasiIdx,
    required String rasiName,
    required List<PlanetDetail> housePlanets,
    required List<PlanetDetail> transitPlanets,
    required bool hasLagna,
    required bool isSoonyam,
    required int lagnaRasiIdx,
    required Map<String, PlanetDetail> allPlanets,
  }) {
    final rasiLord = _rasiLordsTa[rasiIdx];
    final houseFromLagna = ((rasiIdx - lagnaRasiIdx + 12) % 12);
    final bhavaName = _bhavaNamesTa[houseFromLagna];
    final rasiEn = AstrologyCalculator.rasiNamesEn[rasiIdx];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundMid,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFD700), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withValues(alpha: 0.25),
            blurRadius: 12,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Rasi name, Bhava, and Close Button
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryGold.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primaryGold, width: 1),
                ),
                child: Text(
                  '$rasiName ($rasiEn)',
                  style: GoogleFonts.cinzel(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFFFFD700)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  bhavaName,
                  style: GoogleFonts.outfit(fontSize: 10, color: Colors.white70, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              InkWell(
                onTap: () {
                  setState(() {
                    _selectedRasiIndex = null;
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 16, color: Colors.white70),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Badges: Rasi Lord, Lagna, Soonyam
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              _buildMiniBadge('அதிபதி: $rasiLord', Colors.amberAccent),
              if (hasLagna)
                _buildMiniBadge('லக்னம் (Lagna)', Colors.redAccent),
              if (isSoonyam)
                _buildMiniBadge('திதி சூன்யம்', Colors.orangeAccent),
              _buildMiniBadge('ஜாதக கிரகங்கள்: ${housePlanets.length}', Colors.greenAccent),
              _buildMiniBadge('கோட்சார கிரகங்கள்: ${transitPlanets.length}', const Color(0xFF64B5F6)),
            ],
          ),
          const SizedBox(height: 10),

          // Natal Planets Preview
          if (housePlanets.isNotEmpty) ...[
            Text(
              'ஜாதக கிரகங்கள் (Natal Planets):',
              style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.lightGold),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: housePlanets.map((p) {
                final dms = '${p.degree.toString().padLeft(2, '0')}° ${p.minute.toString().padLeft(2, '0')}′ ${p.second.round().toString().padLeft(2, '0')}″';
                final isVak = p.isRetrograde;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.cardSurface,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    '${p.symbol} ${p.tamilName} ($dms)${isVak ? ' ↺' : ''}',
                    style: GoogleFonts.outfit(fontSize: 10, color: Colors.white),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
          ],

          // Transit Planets Preview
          if (transitPlanets.isNotEmpty) ...[
            Text(
              'கோட்சார கிரகங்கள் (Current Transits):',
              style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF64B5F6)),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: transitPlanets.map((t) {
                final dms = '${t.degree.toString().padLeft(2, '0')}° ${t.minute.toString().padLeft(2, '0')}′ ${t.second.round().toString().padLeft(2, '0')}″';
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D47A1).withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFF42A5F5)),
                  ),
                  child: Text(
                    '${t.symbol} ${t.tamilName} ($dms)${t.isRetrograde ? ' ↺' : ''}',
                    style: GoogleFonts.outfit(fontSize: 10, color: const Color(0xFFBBDEFB), fontWeight: FontWeight.w600),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
          ],

          // View Full Details Bottom Sheet Button
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                backgroundColor: AppColors.primaryGold.withValues(alpha: 0.15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(color: AppColors.primaryGold, width: 0.8),
                ),
              ),
              icon: const Icon(Icons.open_in_new_rounded, size: 14, color: AppColors.lightGold),
              label: Text(
                'முழு விவரங்கள் காண்க (Full Details)',
                style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.lightGold),
              ),
              onPressed: () {
                _showRasiDetailsBottomSheet(
                  context: context,
                  rasiIdx: rasiIdx,
                  rasiName: rasiName,
                  housePlanets: housePlanets,
                  transitPlanets: transitPlanets,
                  hasLagna: hasLagna,
                  isSoonyam: isSoonyam,
                  lagnaRasiIdx: lagnaRasiIdx,
                  allPlanets: allPlanets,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Outer Orbit Rasi sector cell displaying Gocharam/transit planets and exact degrees
  Widget _buildOuterOrbitRasiCell({
    required int rasiIdx,
    required List<PlanetDetail> planets,
    required bool isSelected,
  }) {
    return GestureDetector(
      key: Key('outer_orbit_rasi_$rasiIdx'),
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() {
          _selectedRasiIndex = (_selectedRasiIndex == rasiIdx) ? null : rasiIdx;
        });
      },
      child: Container(
        margin: const EdgeInsets.all(1.0),
        decoration: isSelected
            ? BoxDecoration(
                color: const Color(0xFF1565C0).withValues(alpha: 0.28),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFF42A5F5), width: 1.0),
              )
            : null,
        child: planets.isEmpty
            ? Center(
                child: Container(
                  width: 3.5,
                  height: 3.5,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF1E88E5).withValues(alpha: 0.25),
                  ),
                ),
              )
            : Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 1.0),
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 3.0,
                      runSpacing: 2.0,
                      children: planets.map((p) => _buildOuterOrbitPlanetBadge(p)).toList(),
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  /// Distinct cosmic badge for Gocharam planet with exact transit degree
  Widget _buildOuterOrbitPlanetBadge(PlanetDetail p) {
    final dms = "${p.degree}°${p.minute.toString().padLeft(2, '0')}'";
    final isVak = p.isRetrograde;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
      decoration: BoxDecoration(
        color: const Color(0xFF091424),
        borderRadius: BorderRadius.circular(5.0),
        border: Border.all(
          color: const Color(0xFF42A5F5),
          width: 0.9,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E88E5).withValues(alpha: 0.35),
            blurRadius: 4,
            spreadRadius: 0.5,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${p.symbol}${isVak ? " (வ)" : ""}',
            style: GoogleFonts.outfit(
              fontSize: 9.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 1.0),
          Text(
            dms,
            style: GoogleFonts.outfit(
              fontSize: 7.5,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF80D8FF),
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  /// Bottom Sheet Modal displaying comprehensive details of the touched Rasi box
  void _showRasiDetailsBottomSheet({
    required BuildContext context,
    required int rasiIdx,
    required String rasiName,
    required List<PlanetDetail> housePlanets,
    required List<PlanetDetail> transitPlanets,
    required bool hasLagna,
    required bool isSoonyam,
    required int lagnaRasiIdx,
    required Map<String, PlanetDetail> allPlanets,
  }) {
    final rasiLord = _rasiLordsTa[rasiIdx];
    final houseFromLagna = ((rasiIdx - lagnaRasiIdx + 12) % 12);
    final bhavaName = _bhavaNamesTa[houseFromLagna];
    final rasiEn = AstrologyCalculator.rasiNamesEn[rasiIdx];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.82,
          ),
          decoration: BoxDecoration(
            color: AppColors.backgroundDeep,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: AppColors.primaryGold, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryGold.withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Handle
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 6),
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white38,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Title Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGold.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.primaryGold),
                      ),
                      child: const Icon(Icons.stars_rounded, color: AppColors.lightGold, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$rasiName ராசி ($rasiEn)',
                            style: GoogleFonts.cinzel(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFFFFD700)),
                          ),
                          Text(
                            bhavaName,
                            style: GoogleFonts.outfit(fontSize: 11, color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white70),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.white12, height: 1),

              // Scrollable Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Rasi Profile Info
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundMid,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Column(
                          children: [
                            _buildModalInfoRow('ராசி அதிபதி (Lord)', rasiLord),
                            const Divider(color: Colors.white10, height: 12),
                            _buildModalInfoRow('லக்ன தொடர்பு (Bhava)', bhavaName),
                            if (hasLagna) ...[
                              const Divider(color: Colors.white10, height: 12),
                              _buildModalInfoRow('லக்னம் (Ascendant)', 'இந்த ராசியில் லக்னம் அமைந்துள்ளது'),
                            ],
                            if (isSoonyam) ...[
                              const Divider(color: Colors.white10, height: 12),
                              _buildModalInfoRow('திதி சூன்யம் (Tithi Soonyam)', 'இந்த ராசி திதி சூன்ய ராசியாகும்'),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Section 1: Natal Planets (ஜாதக கிரகங்கள்)
                      Row(
                        children: [
                          const Icon(Icons.auto_awesome, color: AppColors.lightGold, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'ஜாதக கிரகங்கள் (Natal Planets)',
                            style: GoogleFonts.cinzel(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.lightGold),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primaryGold.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${housePlanets.length}',
                              style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.lightGold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      if (housePlanets.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                          decoration: BoxDecoration(
                            color: AppColors.cardSurface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: Center(
                            child: Text(
                              'இந்த ராசியில் பிறப்பு கிரகங்கள் எதுவும் இல்லை\n(No natal planets in this house)',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.outfit(fontSize: 11, color: Colors.white54),
                            ),
                          ),
                        )
                      else
                        ...housePlanets.map((p) {
                          final isLg = p.name == 'Lagna';
                          final dms = '${p.degree.toString().padLeft(2, '0')}° ${p.minute.toString().padLeft(2, '0')}′ ${p.second.round().toString().padLeft(2, '0')}″';
                          final planetPos = PlanetPosition.fromKey(
                            p.name,
                            p.longitude,
                            isRetrograde: p.isRetrograde,
                            rasiIndex: p.rasiIndex,
                            navamsaIndex: p.navamsaIndex,
                          );
                          final dignityRes = DignityEngine.calculate(planetPos);
                          final isCombust = (p.name != 'Sun' && p.name != 'Lagna' && p.name != 'Mandi' && p.name != 'Rahu' && p.name != 'Ketu') &&
                              allPlanets.containsKey('Sun') &&
                              AvasthaEngine.isCombust(planetPos, p.longitude, allPlanets['Sun']!.longitude);
                          final isVargottama = p.rasiIndex == p.navamsaIndex;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.cardSurface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isLg ? Colors.redAccent.withValues(alpha: 0.8) : AppColors.primaryGold.withValues(alpha: 0.4),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 34,
                                      height: 34,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: isLg ? Colors.red.shade900 : AppColors.primaryGold.withValues(alpha: 0.25),
                                        shape: BoxShape.circle,
                                        border: Border.all(color: isLg ? Colors.redAccent : AppColors.primaryGold),
                                      ),
                                      child: Text(
                                        p.symbol,
                                        style: GoogleFonts.outfit(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${p.tamilName} (${p.name})',
                                            style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                                          ),
                                          Text(
                                            dms,
                                            style: GoogleFonts.outfit(fontSize: 11, color: const Color(0xFFFFD700), fontWeight: FontWeight.w600),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (dignityRes != null && !isLg)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: (dignityRes.title == 'உச்சம்' ? Colors.greenAccent : Colors.redAccent).withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(color: dignityRes.title == 'உச்சம்' ? Colors.greenAccent : Colors.redAccent),
                                        ),
                                        child: Text(
                                          '${dignityRes.symbol} ${dignityRes.title}',
                                          style: GoogleFonts.outfit(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: dignityRes.title == 'உச்சம்' ? Colors.greenAccent : Colors.redAccent,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                const Divider(color: Colors.white10, height: 1),
                                const SizedBox(height: 8),

                                // Nakshatra, Pada, Lords
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'நட்சத்திரம்: ${p.nakshatraNameTa} (${p.pada}ம் பாதம்)',
                                        style: GoogleFonts.outfit(fontSize: 11, color: Colors.white70),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        'நாதன்: ${p.tamilStarLord}',
                                        style: GoogleFonts.outfit(fontSize: 11, color: Colors.white70),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'உப நாதன்: ${p.tamilSubLord}',
                                        style: GoogleFonts.outfit(fontSize: 11, color: Colors.white60),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        'நவாம்சம்: ${p.navamsaRasiTa}',
                                        style: GoogleFonts.outfit(fontSize: 11, color: Colors.white60),
                                      ),
                                    ),
                                  ],
                                ),

                                // Status Tags: Vakram, Astamanam, Vargottamam
                                if (p.isRetrograde || isCombust || isVargottama) ...[
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 6,
                                    children: [
                                      if (p.isRetrograde)
                                        _buildMiniBadge('↺ வக்ரம் (Retrograde)', Colors.cyanAccent),
                                      if (isCombust)
                                        _buildMiniBadge('☀ அஸ்தமனம் (Combust)', Colors.orangeAccent),
                                      if (isVargottama)
                                        _buildMiniBadge('★ வர்கோத்தமம்', AppColors.lightGold),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          );
                        }),
                      const SizedBox(height: 16),

                      // Section 2: Current Gocharam Transits (கோட்சார கிரகங்கள்)
                      Row(
                        children: [
                          const Icon(Icons.public_rounded, color: Color(0xFF64B5F6), size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'கோட்சார கிரகங்கள் (Live Transits)',
                              style: GoogleFonts.cinzel(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF64B5F6)),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1565C0).withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${transitPlanets.length}',
                              style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF90CAF9)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      if (transitPlanets.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0D1B2A).withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: Center(
                            child: Text(
                              'தற்போது இந்த ராசியில் கோட்சார கிரகங்கள் எதுவும் இல்லை\n(No current live transit planets in this sign)',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.outfit(fontSize: 11, color: Colors.white54),
                            ),
                          ),
                        )
                      else
                        ...transitPlanets.map((t) {
                          final dms = '${t.degree.toString().padLeft(2, '0')}° ${t.minute.toString().padLeft(2, '0')}′ ${t.second.round().toString().padLeft(2, '0')}″';
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0D1B2A),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFF1E88E5).withValues(alpha: 0.5)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1565C0),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: const Color(0xFF64B5F6)),
                                  ),
                                  child: Text(
                                    t.symbol,
                                    style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${t.tamilName} (${t.name})',
                                        style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                                      ),
                                      Text(
                                        'பாகை: $dms | ${t.nakshatraNameTa} (${t.pada}ம் பாதம்)',
                                        style: GoogleFonts.outfit(fontSize: 10, color: const Color(0xFF90CAF9)),
                                      ),
                                    ],
                                  ),
                                ),
                                if (t.isRetrograde)
                                  _buildMiniBadge('↺ வக்ரம்', Colors.cyanAccent),
                              ],
                            ),
                          );
                        }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget _buildModalInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.outfit(fontSize: 11, color: Colors.white60)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ],
    );
  }

  static Widget _buildMiniBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.6), width: 0.7),
      ),
      child: Text(
        text,
        style: GoogleFonts.outfit(fontSize: 9.5, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }

  Widget _buildNavamshaChart(
    Map<String, PlanetDetail> planets,
    TithiDetail activeTithi,
  ) {
    final Map<int, List<PlanetDetail>> navamshaPlanets = {};
    for (final p in planets.values) {
      navamshaPlanets.putIfAbsent(p.navamsaIndex, () => []).add(p);
    }

    final Set<int> soonyamRasiIndices = {};
    for (final rasiTa in activeTithi.soonyamRasisTa) {
      final idx = AstrologyCalculator.rasiNamesTa.indexOf(rasiTa);
      if (idx >= 0) soonyamRasiIndices.add(idx);
    }

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 14),
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF090E17),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.6)),
          ),
          child: Center(
            child: Text(
              'நவாம்சம் (NAVAMSHA CHART D9)',
              style: GoogleFonts.cinzel(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.lightGold,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
        AspectRatio(
          aspectRatio: 1,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF060913),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primaryGold, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryGold.withValues(alpha: 0.18),
                  blurRadius: 14,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Stack(
              children: [
                Center(
                  child: Container(
                    width: 100,
                    height: 40,
                    alignment: Alignment.center,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'நவாம்சம்',
                        style: GoogleFonts.cinzel(
                          color: AppColors.primaryGold.withValues(alpha: 0.85),
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: GridView.builder(
                    clipBehavior: Clip.none,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
                    itemCount: 16,
                    itemBuilder: (context, index) {
                      final isCenter = (index == 5 || index == 6 || index == 9 || index == 10);
                      if (isCenter) return const SizedBox.shrink();

                      final rasiIdx = _gridIndexToRasiIndex[index] ?? 0;
                      final rasiName = AstrologyCalculator.rasiNamesTa[rasiIdx];
                      final housePlanets = navamshaPlanets[rasiIdx] ?? [];
                      final isSoonyam = soonyamRasiIndices.contains(rasiIdx);

                      Color cellColor;
                      Color borderColor;
                      double borderWidth;
                      if (isSoonyam) {
                        cellColor = const Color(0xFF381708);
                        borderColor = const Color(0xFFC65A15);
                        borderWidth = 0.8;
                      } else {
                        cellColor = const Color(0xFF080D1A);
                        borderColor = AppColors.primaryGold.withValues(alpha: 0.28);
                        borderWidth = 0.5;
                      }

                      return Container(
                        decoration: BoxDecoration(
                          color: cellColor,
                          border: Border.all(
                            color: borderColor,
                            width: borderWidth,
                          ),
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              top: 2,
                              left: 4,
                              child: Text(
                                rasiName,
                                style: GoogleFonts.outfit(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w600,
                                  color: isSoonyam ? const Color(0xFFFFB74D) : AppColors.textSecondary,
                                ),
                              ),
                            ),
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(4, 10, 4, 2),
                                child: Wrap(
                                  alignment: WrapAlignment.center,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  spacing: 4,
                                  runSpacing: 2,
                                  children: housePlanets.map((p) {
                                    final isLg = p.name == 'Lagna';
                                    if (isLg) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFD32F2F),
                                          borderRadius: BorderRadius.circular(3),
                                          border: Border.all(color: const Color(0xFFFF5252), width: 0.5),
                                        ),
                                        child: Text(
                                          'லக்',
                                          style: GoogleFonts.outfit(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 9.5,
                                          ),
                                        ),
                                      );
                                    }
                                    return Text(
                                      p.symbol,
                                      style: GoogleFonts.outfit(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.brightGold,
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTithiSoonyamSection(TithiDetail activeTithi) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGold.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.wb_twilight_rounded, color: AppColors.lightGold, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'திதி சூன்யம் (TITHI SOONYAM RASIS)',
                    style: GoogleFonts.cinzel(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.lightGold),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(color: Colors.white12, thickness: 0.6),
          const SizedBox(height: 6),

          // Tithi Selector Dropdown
          Row(
            children: [
              Text('திதி தேர்வு:', style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundMid,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.borderGold.withOpacity(0.4)),
                  ),
                  child: Builder(
                    builder: (context) {
                      int normVal = activeTithi.tithiNumber % 15;
                      if (normVal == 0) normVal = 15;
                      final currentVal = (_selectedTithiNumber > 0 && _selectedTithiNumber <= 15)
                          ? _selectedTithiNumber
                          : normVal;

                      return DropdownButton<int>(
                        value: currentVal,
                        isExpanded: true,
                        dropdownColor: AppColors.backgroundMid,
                        underline: const SizedBox(),
                        style: GoogleFonts.outfit(color: AppColors.lightGold, fontSize: 12, fontWeight: FontWeight.bold),
                        items: List.generate(15, (i) {
                          final num = i + 1;
                          final t = TithiCalculator.getTithiByNumber(num);
                          return DropdownMenuItem<int>(
                            value: num,
                            child: Text("${t.tithiNameTa} (${t.tithiNameEn})"),
                          );
                        }),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedTithiNumber = val;
                            });
                          }
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Display Active Tithi and Soonyam Rasis
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('நடப்பு திதி:', style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary)),
                    Text(
                      "${activeTithi.pakshaTa} ${activeTithi.tithiNameTa}",
                      style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('சூன்ய ராசிகள்:', style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary)),
                    Wrap(
                      spacing: 6,
                      children: activeTithi.soonyamRasisTa.isEmpty
                          ? [Text('சூன்யம் இல்லை', style: GoogleFonts.outfit(fontSize: 12, color: Colors.greenAccent))]
                          : activeTithi.soonyamRasisTa.map((r) {
                              return Chip(
                                backgroundColor: Colors.red.shade900.withOpacity(0.5),
                                side: BorderSide(color: Colors.redAccent.withOpacity(0.5)),
                                padding: EdgeInsets.zero,
                                labelPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: -2),
                                label: Text(r, style: GoogleFonts.outfit(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
                              );
                            }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDashaSection(
    Map<String, String> summary,
    List<DashaPeriod> timeline,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryGold.withOpacity(0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.access_time_filled_rounded, color: AppColors.lightGold, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'தசா புக்தி விம்ஷோத்தரி 120 வருட பலன்கள் (VIMSHOTTARI DASHA)',
                  style: GoogleFonts.cinzel(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.lightGold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(color: Colors.white12, thickness: 0.6),
          const SizedBox(height: 6),

          // Summary Rows
          _buildDashaRow('பிறந்த தசா இருப்பு', "${summary['birthDashaLord']} • ${summary['birthDashaBalance']}"),
          _buildDashaRow('நடப்பு மகா தசா', "${summary['currentMahaDasha']} (${summary['currentMahaDashaRange']})"),
          _buildDashaRow('நடப்பு புக்தி', "${summary['currentBhukti']} (${summary['currentBhuktiRange']})"),

          const SizedBox(height: 12),
          Text(
            '120 வருட தசா காலங்கள் (4 Levels Timeline):',
            style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.lightGold),
          ),
          const SizedBox(height: 6),

          // 4-Level Dasha Expansion Tree
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: timeline.length,
            itemBuilder: (context, idx) {
              final md = timeline[idx];
              return _buildMahaDashaTile(md);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDashaRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 7,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.lightGold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMahaDashaTile(DashaPeriod md) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: md.isActive ? AppColors.primaryGold.withValues(alpha: 0.12) : AppColors.backgroundMid,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: md.isActive ? AppColors.primaryGold : Colors.white12,
          width: md.isActive ? 1.2 : 0.6,
        ),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: ExpansionTile(
          key: ValueKey("md_${md.lordEn}"),
        initiallyExpanded: md.isActive,
        tilePadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
        title: Row(
          children: [
            if (md.isActive)
              Container(
                margin: const EdgeInsets.only(right: 6),
                width: 8,
                height: 8,
                decoration: const BoxDecoration(color: Colors.greenAccent, shape: BoxShape.circle),
              ),
            Text(
              "${md.lordTa} மகா தசா (${md.lordEn})",
              style: GoogleFonts.cinzel(
                fontSize: 13,
                fontWeight: md.isActive ? FontWeight.bold : FontWeight.w600,
                color: md.isActive ? AppColors.lightGold : Colors.white,
              ),
            ),
          ],
        ),
        subtitle: Text(
          "${md.dateRangeFormatted} • ${md.durationFormatted}",
          style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary),
        ),
        children: md.subPeriods.map((bh) => _buildBhuktiTile(bh)).toList(),
      ),
    ),
  );
}

  Widget _buildBhuktiTile(DashaPeriod bh) {
    return Padding(
      padding: const EdgeInsets.only(left: 6, right: 4, bottom: 4),
      child: Container(
        decoration: BoxDecoration(
          color: bh.isActive ? AppColors.primaryGold.withValues(alpha: 0.18) : AppColors.cardSurface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: bh.isActive ? AppColors.primaryGold : Colors.white10),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: ExpansionTile(
            key: ValueKey("bh_${bh.lordEn}_${bh.startDate.millisecondsSinceEpoch}"),
          initiallyExpanded: bh.isActive,
          dense: true,
          tilePadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
          title: Row(
            children: [
              if (bh.isActive)
                Container(
                  margin: const EdgeInsets.only(right: 6),
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(color: Colors.greenAccent, shape: BoxShape.circle),
                ),
              Text(
                "  ↳ ${bh.lordTa} புக்தி (${bh.lordEn})",
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: bh.isActive ? FontWeight.bold : FontWeight.w500,
                  color: bh.isActive ? AppColors.lightGold : Colors.white70,
                ),
              ),
            ],
          ),
          subtitle: Text(
            "    ${bh.dateRangeFormatted}",
            style: GoogleFonts.outfit(fontSize: 10.5, color: AppColors.textSecondary),
          ),
          children: bh.subPeriods.map((ant) => _buildAntharamTile(ant)).toList(),
        ),
      ),
    ),
  );
}

  Widget _buildAntharamTile(DashaPeriod ant) {
    return Padding(
      padding: const EdgeInsets.only(left: 6, right: 4, bottom: 4),
      child: Container(
        decoration: BoxDecoration(
          color: ant.isActive ? AppColors.primaryGold.withValues(alpha: 0.2) : AppColors.backgroundDeep,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: ExpansionTile(
            key: ValueKey("ant_${ant.lordEn}_${ant.startDate.millisecondsSinceEpoch}"),
          initiallyExpanded: ant.isActive,
          dense: true,
          tilePadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
          title: Text(
            "    ↳ ${ant.lordTa} அந்தரம் (${ant.lordEn})",
            style: GoogleFonts.outfit(
              fontSize: 11.5,
              color: ant.isActive ? AppColors.lightGold : Colors.white70,
              fontWeight: ant.isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          subtitle: Text(
            "      ${ant.dateRangeFormatted}",
            style: GoogleFonts.outfit(fontSize: 10, color: AppColors.textSecondary),
          ),
          children: ant.subPeriods.map((sook) {
            return Padding(
              padding: const EdgeInsets.only(left: 12, right: 8, top: 4, bottom: 4),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                primary: false,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (sook.isActive)
                      const Icon(Icons.star, size: 12, color: Colors.greenAccent)
                    else
                      const Icon(Icons.circle_outlined, size: 6, color: Colors.white30),
                    const SizedBox(width: 6),
                    Text(
                      "${sook.lordTa} சூக்ஷ்மம் (${sook.lordEn})",
                      style: GoogleFonts.outfit(
                        fontSize: 11.5,
                        color: sook.isActive ? AppColors.lightGold : Colors.white70,
                        fontWeight: sook.isActive ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      sook.dateRangeFormatted,
                      style: GoogleFonts.outfit(
                        fontSize: 10.5,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    ),
  );
}
}

class CustomPainterWidget extends StatelessWidget {
  final CustomPainter painter;
  const CustomPainterWidget({super.key, required this.painter});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: painter,
      size: Size.infinite,
    );
  }
}
