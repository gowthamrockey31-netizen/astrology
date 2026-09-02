import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../models/kp_planet_position.dart';

/// Accurate KP Rasi & Planet Position Table
/// Displays:
/// Column 1: கிரகம் (Planet)
/// Column 2: ராசி ஸ்புடம் (Exact Degree in DD°MM'SS" format, never wrapping)
/// Column 3: ராசி (Zodiac Sign)
/// Column 4: நட்சத்திரம் (Nakshatra & Pada)
class KPRasiTable extends StatelessWidget {
  final List<KPPlanetPosition> planets;
  final String? lagnaDegreeFormatted;
  final String? lagnaRasiTa;
  final String? lagnaNakshatraTa;

  const KPRasiTable({
    super.key,
    required this.planets,
    this.lagnaDegreeFormatted,
    this.lagnaRasiTa,
    this.lagnaNakshatraTa,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.4), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title Header
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: AppColors.primaryGold, size: 20),
              const SizedBox(width: 8),
              Text(
                'நட்சத்திர பாதசாரம் (KP ராசி & கிரக நிலைகள்)',
                style: GoogleFonts.cinzel(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.lightGold,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Responsive Table
          LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth > 600;

              // Responsive column ratios
              final double col1Width = constraints.maxWidth * (isDesktop ? 0.20 : 0.22);
              final double col2Width = constraints.maxWidth * (isDesktop ? 0.26 : 0.30);
              final double col3Width = constraints.maxWidth * (isDesktop ? 0.22 : 0.20);
              final double col4Width = constraints.maxWidth * (isDesktop ? 0.32 : 0.28);

              return Column(
                children: [
                  // Table Header Row
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundMid,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.25)),
                    ),
                    child: Row(
                      children: [
                        _headerCell('கிரகம்', col1Width, Alignment.centerLeft),
                        _headerCell('ராசி ஸ்புடம்', col2Width, Alignment.centerLeft),
                        _headerCell('ராசி', col3Width, Alignment.centerLeft),
                        _headerCell('நட்சத்திரம்', col4Width, Alignment.centerLeft),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Optional Lagna Row
                  if (lagnaDegreeFormatted != null && lagnaRasiTa != null)
                    _buildRow(
                      planetText: 'லக்னம்',
                      degreeText: lagnaDegreeFormatted!,
                      rasiText: lagnaRasiTa!,
                      nakshatraText: lagnaNakshatraTa ?? '-',
                      col1: col1Width,
                      col2: col2Width,
                      col3: col3Width,
                      col4: col4Width,
                      isHighlight: true,
                    ),

                  // Planet Data Rows
                  ...planets.map((p) {
                    return _buildRow(
                      planetText: p.displayNameTa,
                      degreeText: p.dmsFormatted,
                      rasiText: p.rasiNameTa,
                      nakshatraText: p.nakshatraWithPadaTa,
                      col1: col1Width,
                      col2: col2Width,
                      col3: col3Width,
                      col4: col4Width,
                      isHighlight: false,
                    );
                  }),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _headerCell(String title, double width, Alignment align) {
    return SizedBox(
      width: width,
      child: Align(
        alignment: align,
        child: Text(
          title,
          style: AppTheme.tamilTextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.lightGold,
          ),
        ),
      ),
    );
  }

  Widget _buildRow({
    required String planetText,
    required String degreeText,
    required String rasiText,
    required String nakshatraText,
    required double col1,
    required double col2,
    required double col3,
    required double col4,
    required bool isHighlight,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isHighlight ? AppColors.primaryGold.withValues(alpha: 0.12) : AppColors.backgroundDeep,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isHighlight
              ? AppColors.primaryGold.withValues(alpha: 0.4)
              : Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Row(
        children: [
          // Column 1: Planet Name
          SizedBox(
            width: col1,
            child: Text(
              planetText,
              style: AppTheme.tamilTextStyle(
                fontSize: 12.5,
                fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
                color: isHighlight ? AppColors.lightGold : Colors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Column 2: EXACT DEGREE DISPLAY (CIRCLED AREA)
          // Monospaced, zero-padding, non-wrapping DD°MM'SS"
          SizedBox(
            width: col2,
            child: Text(
              degreeText,
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isHighlight ? Colors.amberAccent : AppColors.lightGold,
                letterSpacing: 0.5,
              ),
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.visible,
            ),
          ),

          // Column 3: Rasi Name
          SizedBox(
            width: col3,
            child: Text(
              rasiText,
              style: AppTheme.tamilTextStyle(
                fontSize: 12,
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Column 4: Nakshatra (Pada)
          SizedBox(
            width: col4,
            child: Text(
              nakshatraText,
              style: AppTheme.tamilTextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isHighlight ? AppColors.lightGold : Colors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
