import 'package:flutter/material.dart';
import '../../services/astrology_calculator.dart';
import '../models/jamakkol_models.dart';
import '../models/jamakkol_planet_models.dart';

/// ORIGINAL South Indian Style Jamakkol Prasannam Rasi Chart
/// Features 4x4 inner Rasi grid and 8 Jamakkol Outer Planets on outer ring
class JamakkolChartWidget extends StatelessWidget {
  final JamakkolChartState state;
  final bool isTamil;
  final void Function(int rasiIndex)? onRasiTap;

  const JamakkolChartWidget({
    super.key,
    required this.state,
    this.isTamil = true,
    this.onRasiTap,
  });

  /// South Indian 4x4 cell index to Rasi Index (0=Mesham .. 11=Meenam, -1 for center)
  /// Row 0: Meenam (11), Mesham (0), Rishabam (1), Mithunam (2)
  /// Row 1: Kumbam (10), Center(-1), Center(-1),   Katakam (3)
  /// Row 2: Makaram (9), Center(-1), Center(-1),   Simham (4)
  /// Row 3: Dhanusu (8), Viruch (7), Thulam (6),   Kanni (5)
  static const List<List<int>> gridRasiMap = [
    [11, 0, 1, 2],
    [10, -1, -1, 3],
    [9, -1, -1, 4],
    [8, 7, 6, 5],
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final chartSize = availableWidth.clamp(320.0, 680.0);
        const double outerBorderPadding = 36.0;
        final double innerGridSize = chartSize - (outerBorderPadding * 2);

        return Center(
          child: Container(
            width: chartSize,
            height: chartSize,
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              gradient: const RadialGradient(
                center: Alignment.center,
                radius: 0.95,
                colors: [
                  Color(0xFF0F172A),
                  Color(0xFF070B14),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.6),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // 1. Center & Inner 4x4 Rasi Grid
                Positioned(
                  left: outerBorderPadding,
                  top: outerBorderPadding,
                  width: innerGridSize,
                  height: innerGridSize,
                  child: _buildInnerGrid(context, innerGridSize),
                ),

                // 2. 8 Jamakkol Outer Planets positioned on the border ring
                ..._buildOuterPlanetBadges(chartSize, outerBorderPadding, innerGridSize),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Builds the 4x4 inner grid
  Widget _buildInnerGrid(BuildContext context, double size) {
    final cellSize = size / 4.0;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.6), width: 1.2),
      ),
      child: Stack(
        children: [
          // Cells
          for (int row = 0; row < 4; row++)
            for (int col = 0; col < 4; col++)
              if (gridRasiMap[row][col] != -1)
                Positioned(
                  left: col * cellSize,
                  top: row * cellSize,
                  width: cellSize,
                  height: cellSize,
                  child: _buildRasiCell(context, gridRasiMap[row][col], cellSize),
                ),

          // Central 2x2 Area
          Positioned(
            left: cellSize,
            top: cellSize,
            width: cellSize * 2,
            height: cellSize * 2,
            child: _buildCenterDashboard(cellSize * 2),
          ),
        ],
      ),
    );
  }

  /// Builds an individual Rasi cell
  Widget _buildRasiCell(BuildContext context, int rasiIndex, double cellSize) {
    final isUdayam = state.udayam.rasiIndex == rasiIndex;
    final isArudam = state.arudam.rasiIndex == rasiIndex;
    final isKavippu = state.kavippu.rasiIndex == rasiIndex;

    // House number from Udayam (1..12)
    final houseNum = (((rasiIndex - state.udayam.rasiIndex) % 12 + 12) % 12) + 1;

    final rasiName = isTamil ? AstrologyCalculator.rasiNamesTa[rasiIndex] : AstrologyCalculator.rasiNamesEn[rasiIndex];

    final gocharamPlanets = state.transitPlanetsByRasi[rasiIndex] ?? [];
    final specialPoints = state.specialPointsByRasi[rasiIndex] ?? [];

    Color cellBgColor = Colors.transparent;
    if (isUdayam) {
      cellBgColor = const Color(0xFF1E3A8A).withValues(alpha: 0.28);
    } else if (isArudam) {
      cellBgColor = const Color(0xFF065F46).withValues(alpha: 0.25);
    } else if (isKavippu) {
      cellBgColor = const Color(0xFF7F1D1D).withValues(alpha: 0.25);
    }

    return InkWell(
      onTap: () => onRasiTap?.call(rasiIndex),
      child: Container(
        decoration: BoxDecoration(
          color: cellBgColor,
          border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.35), width: 0.8),
        ),
        padding: const EdgeInsets.all(3.0),
        child: Stack(
          children: [
            // Rasi Name (Top Left)
            Positioned(
              left: 2,
              top: 1,
              child: Text(
                rasiName,
                style: TextStyle(
                  color: isUdayam
                      ? const Color(0xFF93C5FD)
                      : (isArudam ? const Color(0xFF6EE7B7) : Colors.white70),
                  fontSize: cellSize < 85 ? 9.5 : 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // House Number relative to Udayam (Top Right)
            Positioned(
              right: 2,
              top: 1,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 0.5),
                decoration: BoxDecoration(
                  color: houseNum == 1
                      ? const Color(0xFF3B82F6)
                      : (houseNum == 5 || houseNum == 9
                          ? const Color(0xFF10B981)
                          : const Color(0xFF334155)),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  '$houseNum',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),

            // Planets & Special Points Content (Centered, scaled to never clip)
            Positioned.fill(
              top: 14,
              left: 1,
              right: 1,
              bottom: 2,
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.center,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: cellSize - 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Special 3 Pillars
                        Wrap(
                          spacing: 2,
                          runSpacing: 1,
                          alignment: WrapAlignment.center,
                          children: [
                            if (isUdayam)
                              _buildPillarBadge(
                                label: isTamil ? 'உத' : 'UDY',
                                degree: state.udayam.formattedDms,
                                bgColor: const Color(0xFF2563EB),
                              ),
                            if (isArudam)
                              _buildPillarBadge(
                                label: isTamil ? 'ஆரு' : 'ARD',
                                degree: state.arudam.formattedDms,
                                bgColor: const Color(0xFF059669),
                              ),
                            if (isKavippu)
                              _buildPillarBadge(
                                label: isTamil ? 'கவி' : 'KAV',
                                degree: state.kavippu.formattedDms,
                                bgColor: const Color(0xFFDC2626),
                              ),
                          ],
                        ),

                        // Upagrahas & Special Points (Mandi, Mrityu, Ra.Ka, Emakandam, Lagna)
                        Wrap(
                          spacing: 2,
                          runSpacing: 1,
                          alignment: WrapAlignment.center,
                          children: specialPoints
                              .where((pt) =>
                                  pt.type != SpecialPointType.udayam &&
                                  pt.type != SpecialPointType.arudam &&
                                  pt.type != SpecialPointType.kavippu)
                              .map((u) => _buildUpagrahaBadge(u))
                              .toList(),
                        ),

                        // Gocharam / Transit Planets
                        Wrap(
                          spacing: 2,
                          runSpacing: 1,
                          alignment: WrapAlignment.center,
                          children: gocharamPlanets.map((tp) => _buildTransitPlanetBadge(tp)).toList(),
                        ),
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
  }

  /// Builds Central Information Card in the 2x2 center area
  Widget _buildCenterDashboard(double centerSize) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0B1120).withValues(alpha: 0.92),
        border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.5), width: 1.0),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.center,
          child: SizedBox(
            width: 320,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Title
                Text(
            isTamil ? 'ஜாமக்கோள் பிரசன்னம்' : 'JAMAKKOL PRASANNAM',
            style: const TextStyle(
              color: Color(0xFFFFD700),
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 3),

          // Location & Date & Tamil Month
          Text(
            '${state.location.name} • ${state.tamilMonth.isNotEmpty ? "${state.tamilMonth} • " : ""}${_formatShortTime(state.queryDateTime)}',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 9.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),

          // Active Jamam Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF9333EA), Color(0xFF4F46E5)],
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              isTamil
                  ? '${state.currentJamam.displayNameTa} [${state.currentJamam.rulingPlanetTa}]'
                  : '${state.currentJamam.displayNameEn} [${state.currentJamam.rulingPlanetEn}]',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 8.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 5),

          // Quick summary of 3 Pillars
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildMiniStatus(
                label: isTamil ? 'உதயம்' : 'Udayam',
                sign: isTamil ? state.udayam.rasiNameTa : state.udayam.rasiNameEn,
                deg: '★ ${state.udayam.nakshatraTa}-${state.udayam.pada}',
                color: const Color(0xFF60A5FA),
              ),
              _buildMiniStatus(
                label: isTamil ? 'ஆருடம்' : 'Arudam',
                sign: isTamil ? state.arudam.rasiNameTa : state.arudam.rasiNameEn,
                deg: '★ ${state.arudam.nakshatraTa}-${state.arudam.pada}',
                color: const Color(0xFF34D399),
              ),
              _buildMiniStatus(
                label: isTamil ? 'கவிப்பு' : 'Kavippu',
                sign: isTamil ? state.kavippu.rasiNameTa : state.kavippu.rasiNameEn,
                deg: '★ ${state.kavippu.nakshatraTa}-${state.kavippu.pada}',
                color: const Color(0xFFF87171),
              ),
            ],
          ),

          const SizedBox(height: 3),
          // Quick summary of Jamakkol Points: Ra.Ka, Emakandam, Mridyu
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildMiniStatus(
                label: isTamil ? 'ரா.கா' : 'Ra.Ka',
                sign: isTamil
                    ? AstrologyCalculator.rasiNamesTa[state.rahuKalamRasi]
                    : AstrologyCalculator.rasiNamesEn[state.rahuKalamRasi],
                deg: state.upagrahas.firstWhere((u) => u.type == SpecialPointType.rahuKaalam, orElse: () => state.udayam).formattedDms,
                color: const Color(0xFFC084FC),
              ),
              _buildMiniStatus(
                label: isTamil ? 'எம' : 'Emakandam',
                sign: isTamil
                    ? AstrologyCalculator.rasiNamesTa[state.emakandamRasi]
                    : AstrologyCalculator.rasiNamesEn[state.emakandamRasi],
                deg: state.upagrahas.firstWhere((u) => u.type == SpecialPointType.yamakandam, orElse: () => state.udayam).formattedDms,
                color: const Color(0xFFFB923C),
              ),
              _buildMiniStatus(
                label: isTamil ? 'மிரு' : 'Mridyu',
                sign: isTamil
                    ? AstrologyCalculator.rasiNamesTa[state.mridyuRasi]
                    : AstrologyCalculator.rasiNamesEn[state.mridyuRasi],
                deg: state.upagrahas.firstWhere((u) => u.type == SpecialPointType.mrityu, orElse: () => state.udayam).formattedDms,
                color: const Color(0xFFFB7185),
              ),
            ],
          ),

          const SizedBox(height: 3),
          // Sunrise & Sunset info
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              isTamil
                  ? 'சூரிய உதயம்: ${_formatShortTime(state.sunrise)} | அஸ்தமனம்: ${_formatShortTime(state.sunset)}'
                  : 'Sunrise: ${_formatShortTime(state.sunrise)} | Sunset: ${_formatShortTime(state.sunset)}',
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 8,
              ),
            ),
          ),
        ],
      ),
    ),
    ),
    ),
    );
  }

  Widget _buildMiniStatus({
    required String label,
    required String sign,
    required String deg,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: TextStyle(color: color, fontSize: 8.5, fontWeight: FontWeight.bold)),
        Text(sign, style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w600)),
        Text(deg, style: const TextStyle(color: Colors.white54, fontSize: 7)),
      ],
    );
  }

  /// Builds the 8 Jamakkol Outer Planets around the 4 borders
  List<Widget> _buildOuterPlanetBadges(double chartSize, double padding, double innerGridSize) {
    final List<Widget> widgets = [];
    final cellSize = innerGridSize / 4.0;
    final Map<String, int> cellBadgeCount = {};

    for (final jp in state.jamakkolPlanets) {
      final cellKey = '${jp.borderSide}_${jp.gridCol}_${jp.gridRow}';
      final int badgeIndex = cellBadgeCount[cellKey] ?? 0;
      cellBadgeCount[cellKey] = badgeIndex + 1;

      final double offset = badgeIndex * 26.0;

      double left = 0;
      double top = 0;

      // Position along the top, right, bottom, left outer margins
      switch (jp.borderSide) {
        case 0: // Top border
          left = padding + (jp.gridCol * cellSize) + (cellSize * 0.05) + offset;
          top = 4.0;
          break;
        case 1: // Right border
          left = chartSize - padding + 2.0;
          top = padding + (jp.gridRow * cellSize) + (cellSize * 0.1) + offset;
          break;
        case 2: // Bottom border
          left = padding + (jp.gridCol * cellSize) + (cellSize * 0.05) + offset;
          top = chartSize - padding + 4.0;
          break;
        case 3: // Left border
        default:
          left = 4.0;
          top = padding + (jp.gridRow * cellSize) + (cellSize * 0.1) + offset;
          break;
      }

      final isCurrentLord = jp.isCurrentJamamLord;

      widgets.add(
        Positioned(
          left: left,
          top: top,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: isCurrentLord
                  ? const Color(0xFFF59E0B)
                  : const Color(0xFF1E293B).withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: isCurrentLord ? const Color(0xFFFFD700) : const Color(0xFF64748B),
                width: isCurrentLord ? 1.5 : 0.8,
              ),
              boxShadow: isCurrentLord
                  ? [
                      BoxShadow(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.5),
                        blurRadius: 6,
                        spreadRadius: 1,
                      )
                    ]
                  : null,
            ),
            child: Text(
              '${isTamil ? jp.shortTa : jp.shortEn} ${_formatOuterPlanetDegree(jp)}',
              style: TextStyle(
                color: isCurrentLord ? Colors.black : const Color(0xFFFDE68A),
                fontSize: 8.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    }

    return widgets;
  }

  String _formatOuterPlanetDegree(JamakkolPlanet jp) {
    final double norm = (jp.absoluteLongitude % 360.0 + 360.0) % 360.0;
    final int d = norm.floor();
    final int m = ((norm - d) * 60.0).floor();
    return "$d° ${m.toString().padLeft(2, '0')}'";
  }

  Widget _buildPillarBadge({
    required String label,
    required String degree,
    required Color bgColor,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 0.5),
      padding: const EdgeInsets.symmetric(horizontal: 2.5, vertical: 0.5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        '$label $degree',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 7.5,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildUpagrahaBadge(JamakkolSpecialPoint pt) {
    Color bg = const Color(0xFF831843).withValues(alpha: 0.85);
    Color txt = const Color(0xFFFBCFE8);
    String label = pt.shortCode;

    if (pt.type == SpecialPointType.rahuKaalam) {
      bg = const Color(0xFF7E22CE).withValues(alpha: 0.9);
      txt = Colors.white;
      label = isTamil ? 'ரா.கா' : 'Ra.Ka';
    } else if (pt.type == SpecialPointType.yamakandam) {
      bg = const Color(0xFFC2410C).withValues(alpha: 0.9);
      txt = Colors.white;
      label = isTamil ? 'எம' : 'Emakandam';
    } else if (pt.type == SpecialPointType.mrityu) {
      bg = const Color(0xFFBE123C).withValues(alpha: 0.9);
      txt = Colors.white;
      label = isTamil ? 'மிரு' : 'Mridyu';
    } else if (pt.type == SpecialPointType.mandi) {
      bg = const Color(0xFF831843).withValues(alpha: 0.9);
      txt = const Color(0xFFFBCFE8);
      label = isTamil ? 'மாந்' : 'Mandi';
    } else if (pt.type == SpecialPointType.lagna) {
      bg = const Color(0xFF0284C7).withValues(alpha: 0.9);
      txt = Colors.white;
      label = isTamil ? 'லக்' : 'LAG';
    }

    final d = pt.degreeInRasi.floor();
    final m = ((pt.degreeInRasi - d) * 60.0).round();
    final String degStr = m == 0
        ? "$d°"
        : (m >= 60 ? "${d + 1}°" : "$d° ${m.toString().padLeft(2, '0')}'");

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 0.5, horizontal: 0.5),
      padding: const EdgeInsets.symmetric(horizontal: 2.5, vertical: 0.8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(2.5),
      ),
      child: Text(
        '$label $degStr',
        style: TextStyle(
          color: txt,
          fontSize: 7,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTransitPlanetBadge(TransitPlanet tp) {
    String suffix = '';
    if (tp.isRetrograde) suffix += '(R)';
    if (tp.isCombust) suffix += '(C)';

    final d = tp.degreeInRasi.floor();
    final m = ((tp.degreeInRasi - d) * 60.0).round();
    final String degStr = m == 0
        ? "$d°"
        : (m >= 60 ? "${d + 1}°" : "$d° ${m.toString().padLeft(2, '0')}'");

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 0.5),
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 0.5),
      decoration: BoxDecoration(
        color: const Color(0xFF0F766E).withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(2.5),
      ),
      child: Text(
        '${isTamil ? tp.symbol : tp.nameEn.substring(0, 2)} $degStr$suffix',
        style: const TextStyle(
          color: Color(0xFFCCFBF1),
          fontSize: 7.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatShortTime(DateTime dt) {
    final hr = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final min = dt.minute.toString().padLeft(2, '0');
    final amPm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hr:$min $amPm';
  }
}
