import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';
import '../models/horoscope_calculation_result.dart';
import '../models/user_model.dart';
import '../services/astrology_calculator.dart';
import '../services/dasha_calculator.dart';
import '../services/tithi_calculator.dart';
import 'transit_orbit_painter.dart';

class SouthIndianJathagamWidget extends StatefulWidget {
  final UserModel? user;
  final bool isCallOverlay;

  const SouthIndianJathagamWidget({
    super.key,
    this.user,
    this.isCallOverlay = false,
  });

  @override
  State<SouthIndianJathagamWidget> createState() => _SouthIndianJathagamWidgetState();
}

class _SouthIndianJathagamWidgetState extends State<SouthIndianJathagamWidget> {
  int _selectedTithiNumber = 0; // 0 means auto from calculated birth Tithi

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
    final name = user?.name ?? 'Divine Seeker';
    final dobStr = user?.dob ?? '1996-06-15';
    final tobStr = user?.timeOfBirth ?? '08:30 AM';
    final pobStr = user?.placeOfBirth ?? 'Chennai';

    // Parse DateTime for calculations
    final parsedDob = DateTime.tryParse(dobStr) ?? DateTime(1996, 6, 15);
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
    final String ayanamsaStr = astroData.ayanamsaFormatted;

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

            const SizedBox(height: 16),

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
            _buildPathasaramTable(planets),

            const SizedBox(height: 24),

            // Rasi & Navamsha Charts Title
            Row(
              children: [
                const Icon(Icons.grid_on_rounded, color: AppColors.lightGold, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'ஜாதக கட்டங்கள் (ராசி & நவாம்சம்)',
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
            const SizedBox(height: 12),

            // South Indian Rasi Chart & Navamsha D9 Chart
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 650) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildRasiChartWithTransitOrbit(planets, transits, activeTithi)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildNavamshaChart(planets, activeTithi)),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      _buildRasiChartWithTransitOrbit(planets, transits, activeTithi),
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

  Widget _buildPathasaramTable(Map<String, PlanetDetail> planets) {
    final planetKeys = ['Lagna', 'Sun', 'Moon', 'Mars', 'Mercury', 'Jupiter', 'Venus', 'Saturn', 'Rahu', 'Ketu'];

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
          ],
          rows: planetKeys.map((key) {
            final p = planets[key]!;
            final isLagna = key == 'Lagna';
            return DataRow(
              color: isLagna ? WidgetStateProperty.all(AppColors.primaryGold.withOpacity(0.12)) : null,
              cells: [
                DataCell(Text(p.tamilName, style: GoogleFonts.outfit(color: isLagna ? AppColors.lightGold : Colors.white, fontWeight: isLagna ? FontWeight.bold : FontWeight.normal, fontSize: 11))),
                DataCell(Text(
                  p.degreeFormatted,
                  style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 11, letterSpacing: 0.5),
                  maxLines: 1,
                  softWrap: false,
                )),
                DataCell(Text(p.rasiNameTa, style: GoogleFonts.outfit(color: Colors.white, fontSize: 11))),
                DataCell(Text("${p.nakshatraNameTa}-${p.pada}", style: GoogleFonts.outfit(color: AppColors.lightGold, fontWeight: FontWeight.w600, fontSize: 11))),
                DataCell(Text(p.tamilStarLord, style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 11))),
                DataCell(Text(p.tamilSubLord, style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 11))),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildRasiChartWithTransitOrbit(
    Map<String, PlanetDetail> planets,
    Map<String, PlanetDetail> transits,
    TithiDetail activeTithi,
  ) {
    final Map<int, List<PlanetDetail>> rasiPlanets = {};
    for (final p in planets.values) {
      rasiPlanets.putIfAbsent(p.rasiIndex, () => []).add(p);
    }

    // Calculate Tithi Soonyam Rasi indices for chart highlighting
    final Set<int> soonyamRasiIndices = {};
    for (final rasiTa in activeTithi.soonyamRasisTa) {
      final idx = AstrologyCalculator.rasiNamesTa.indexOf(rasiTa);
      if (idx >= 0) soonyamRasiIndices.add(idx);
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.backgroundMid,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.6)),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'ராசி (Rasi Chart D1)',
                  style: GoogleFonts.cinzel(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.lightGold),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: const Color(0xFF1565C0), borderRadius: BorderRadius.circular(6)),
                  child: Text('Outer Orbit: Gocharam', style: GoogleFonts.outfit(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        AspectRatio(
          aspectRatio: 1,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.backgroundDeep,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primaryGold, width: 1.5),
            ),
            child: Stack(
              children: [
                CustomPainterWidget(
                  painter: TransitOrbitPainter(transits: transits),
                ),

                // Center merged title
                Center(
                  child: Container(
                    width: 90,
                    height: 40,
                    alignment: Alignment.center,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'ராசி',
                        style: GoogleFonts.cinzel(color: AppColors.primaryGold.withValues(alpha: 0.85), fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
                    itemCount: 16,
                    itemBuilder: (context, index) {
                      final isCenter = (index == 5 || index == 6 || index == 9 || index == 10);
                      if (isCenter) {
                        return const SizedBox.shrink();
                      }

                      final rasiIdx = _gridIndexToRasiIndex[index] ?? 0;
                      final rasiName = AstrologyCalculator.rasiNamesTa[rasiIdx];
                      final housePlanets = rasiPlanets[rasiIdx] ?? [];
                      final hasLagna = housePlanets.any((p) => p.name == 'Lagna');
                      final isSoonyam = soonyamRasiIndices.contains(rasiIdx);

                      // Determine cell background color: Lagna > Soonyam > Default
                      Color cellColor;
                      Color borderColor;
                      if (hasLagna) {
                        cellColor = AppColors.primaryGold.withValues(alpha: 0.18);
                        borderColor = AppColors.primaryGold;
                      } else if (isSoonyam) {
                        cellColor = Colors.orange.shade900.withValues(alpha: 0.3);
                        borderColor = Colors.orange.shade700;
                      } else {
                        cellColor = AppColors.cardSurface;
                        borderColor = Colors.brown.shade300;
                      }

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: cellColor,
                          border: Border.all(
                            color: borderColor,
                            width: 0.5,
                          ),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: SizedBox(
                            width: 65,
                            height: 65,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    rasiName,
                                    style: GoogleFonts.outfit(
                                      fontSize: 8,
                                      fontWeight: isSoonyam ? FontWeight.bold : FontWeight.normal,
                                      color: isSoonyam ? Colors.orange.shade300 : AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                                Wrap(
                                  alignment: WrapAlignment.center,
                                  spacing: 2,
                                  runSpacing: 1,
                                  children: housePlanets.map((p) {
                                    final isLg = p.name == 'Lagna';
                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                                      decoration: isLg
                                          ? BoxDecoration(
                                              color: Colors.red.shade900.withValues(alpha: 0.8),
                                              borderRadius: BorderRadius.circular(3),
                                            )
                                          : null,
                                      child: Text(
                                        p.symbol,
                                        style: GoogleFonts.outfit(
                                          fontSize: isLg ? 9.5 : 9.0,
                                          fontWeight: isLg ? FontWeight.bold : FontWeight.w600,
                                          color: isLg ? Colors.white : AppColors.lightGold,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                                const SizedBox(height: 1),
                              ],
                            ),
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

        // Tithi Soonyam Legend
        if (soonyamRasiIndices.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 12, height: 12,
                  decoration: BoxDecoration(
                    color: Colors.orange.shade900.withValues(alpha: 0.3),
                    border: Border.all(color: Colors.orange.shade700, width: 0.5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  'திதி சூன்ய ராசி',
                  style: GoogleFonts.outfit(fontSize: 9, color: Colors.orange.shade300, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
      ],
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

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.backgroundMid,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.6)),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'நவாம்சம் (Navamsha Chart D9)',
              style: GoogleFonts.cinzel(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.lightGold),
            ),
          ),
        ),
        const SizedBox(height: 8),
        AspectRatio(
          aspectRatio: 1,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.backgroundDeep,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primaryGold, width: 1.5),
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
                        style: GoogleFonts.cinzel(color: AppColors.primaryGold.withValues(alpha: 0.85), fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
                    itemCount: 16,
                    itemBuilder: (context, index) {
                      final isCenter = (index == 5 || index == 6 || index == 9 || index == 10);
                      if (isCenter) {
                        return const SizedBox.shrink();
                      }

                      final rasiIdx = _gridIndexToRasiIndex[index] ?? 0;
                      final rasiName = AstrologyCalculator.rasiNamesTa[rasiIdx];
                      final housePlanets = navamshaPlanets[rasiIdx] ?? [];
                      final hasLagna = housePlanets.any((p) => p.name == 'Lagna');

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: hasLagna
                              ? AppColors.primaryGold.withValues(alpha: 0.18)
                              : AppColors.cardSurface,
                          border: Border.all(
                            color: hasLagna ? AppColors.primaryGold : Colors.brown.shade300,
                            width: 0.5,
                          ),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: SizedBox(
                            width: 65,
                            height: 65,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    rasiName,
                                    style: GoogleFonts.outfit(
                                      fontSize: 8,
                                      fontWeight: FontWeight.normal,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                                Wrap(
                                  alignment: WrapAlignment.center,
                                  spacing: 2,
                                  runSpacing: 1,
                                  children: housePlanets.map((p) {
                                    final isLg = p.name == 'Lagna';
                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                                      decoration: isLg
                                          ? BoxDecoration(
                                              color: Colors.red.shade900.withValues(alpha: 0.8),
                                              borderRadius: BorderRadius.circular(3),
                                            )
                                          : null,
                                      child: Text(
                                        p.symbol,
                                        style: GoogleFonts.outfit(
                                          fontSize: isLg ? 9.5 : 9.0,
                                          fontWeight: isLg ? FontWeight.bold : FontWeight.w600,
                                          color: isLg ? Colors.white : AppColors.lightGold,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                                const SizedBox(height: 1),
                              ],
                            ),
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
