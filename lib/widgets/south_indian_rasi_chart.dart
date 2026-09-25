import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';
import '../services/astrology_calculator.dart';
import 'transit_orbit_painter.dart';

class SouthIndianRasiChart extends StatelessWidget {
  final String title;
  final Map<String, PlanetDetail> planets;
  final List<String>? highlightRasis;
  final Map<String, PlanetDetail>? transits;

  const SouthIndianRasiChart({
    super.key,
    required this.title,
    required this.planets,
    this.highlightRasis,
    this.transits,
  });

  /// Standard South Indian 4x4 Grid index -> Zodiac Rasi index (0..11)
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
    // Map planets to their Rasi index (0..11)
    final Map<int, List<PlanetDetail>> rasiPlanets = {};
    for (final p in planets.values) {
      rasiPlanets.putIfAbsent(p.rasiIndex, () => []).add(p);
    }

    final Map<int, List<PlanetDetail>> transitRasiPlanets = {};
    if (transits != null) {
      for (final t in transits!.values) {
        transitRasiPlanets.putIfAbsent(t.rasiIndex, () => []).add(t);
      }
    }

    final hasTransits = transits != null && transits!.isNotEmpty;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 14),
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
                  title,
                  style: GoogleFonts.cinzel(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.lightGold,
                  ),
                ),
                if (hasTransits) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1565C0),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Outer Orbit: Gocharam',
                      style: GoogleFonts.outfit(
                        fontSize: 8.5,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        if (hasTransits)
          _buildChartWithOuterOrbit(context, rasiPlanets, transitRasiPlanets)
        else
          AspectRatio(
            aspectRatio: 1,
            child: _buildInnerChartBox(rasiPlanets),
          ),
      ],
    );
  }

  Widget _buildChartWithOuterOrbit(
    BuildContext context,
    Map<int, List<PlanetDetail>> rasiPlanets,
    Map<int, List<PlanetDetail>> transitRasiPlanets,
  ) {
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
              // Top Orbit Row
              Container(
                height: topBottomOrbitHeight,
                padding: const EdgeInsets.symmetric(horizontal: sideOrbitWidth),
                child: Row(
                  children: [11, 0, 1, 2].map((rIdx) {
                    return Expanded(
                      child: _buildOuterOrbitRasiCell(transitRasiPlanets[rIdx] ?? []),
                    );
                  }).toList(),
                ),
              ),

              // Middle Section
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Left Orbit Column
                    SizedBox(
                      width: sideOrbitWidth,
                      child: Column(
                        children: [
                          const Expanded(child: SizedBox.shrink()),
                          Expanded(child: _buildOuterOrbitRasiCell(transitRasiPlanets[10] ?? [])),
                          Expanded(child: _buildOuterOrbitRasiCell(transitRasiPlanets[9] ?? [])),
                          const Expanded(child: SizedBox.shrink()),
                        ],
                      ),
                    ),

                    // Inner Rasi Chart (Existing chart kept 100% inside its box)
                    Expanded(
                      child: AspectRatio(
                        aspectRatio: 1.0,
                        child: _buildInnerChartBox(rasiPlanets),
                      ),
                    ),

                    // Right Orbit Column
                    SizedBox(
                      width: sideOrbitWidth,
                      child: Column(
                        children: [
                          const Expanded(child: SizedBox.shrink()),
                          Expanded(child: _buildOuterOrbitRasiCell(transitRasiPlanets[3] ?? [])),
                          Expanded(child: _buildOuterOrbitRasiCell(transitRasiPlanets[4] ?? [])),
                          const Expanded(child: SizedBox.shrink()),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom Orbit Row
              Container(
                height: topBottomOrbitHeight,
                padding: const EdgeInsets.symmetric(horizontal: sideOrbitWidth),
                child: Row(
                  children: [8, 7, 6, 5].map((rIdx) {
                    return Expanded(
                      child: _buildOuterOrbitRasiCell(transitRasiPlanets[rIdx] ?? []),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOuterOrbitRasiCell(List<PlanetDetail> planets) {
    if (planets.isEmpty) {
      return Center(
        child: Container(
          width: 3.5,
          height: 3.5,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF1E88E5).withValues(alpha: 0.25),
          ),
        ),
      );
    }

    return Center(
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
    );
  }

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

  Widget _buildInnerChartBox(Map<int, List<PlanetDetail>> rasiPlanets) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundDeep,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryGold, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
          ),
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

            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: hasLagna
                    ? AppColors.primaryGold.withValues(alpha: 0.18)
                    : AppColors.cardSurface,
                border: Border.all(
                  color: hasLagna ? AppColors.primaryGold : AppColors.borderGold.withValues(alpha: 0.4),
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 2,
                              vertical: 1,
                            ),
                            decoration: isLg
                                ? BoxDecoration(
                                    color: Colors.red.shade900.withValues(alpha: 0.85),
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
    );
  }
}

