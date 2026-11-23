import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../models/kp2_birth_data.dart';
import '../models/kp2_planet.dart';
import '../models/kp2_ruling_planet.dart';

/// KP Ruling Planets Widget (ஆளும் கிரகங்கள்)
/// Displays the 10 ruling planet calculation positions matching the reference layout
/// plus detailed position breakdowns and deduplicated unique ruling planets.
class KP2RulingPlanetsWidget extends StatelessWidget {
  final KP2RulingPlanets rulingPlanets;
  final KP2BirthData? birthData;
  final VoidCallback? onEditTransit;

  const KP2RulingPlanetsWidget({
    super.key,
    required this.rulingPlanets,
    this.birthData,
    this.onEditTransit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryGold.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Reference Table Layout (ஆளும் கிரகங்கள் Table)
          _buildReferenceTable(context),

          const SizedBox(height: 20),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 16),

          // 2. Detailed 10 Position List (Cards)
          _buildDetailedPositionsList(),

          const SizedBox(height: 18),
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 16),

          // 3. Deduplicated Unique Ruling Planets
          _buildUniquePlanetsSection(),
        ],
      ),
    );
  }

  /// Builds the 6-column reference table exactly matching the user's reference image
  Widget _buildReferenceTable(BuildContext context) {
    final String dateStr = birthData != null
        ? DateFormat('dd-MM-yyyy').format(birthData!.date)
        : DateFormat('dd-MM-yyyy').format(DateTime.now());
    final String timeStr = birthData?.time ?? '08:49:22 AM';
    final String placeStr = birthData?.place.isNotEmpty == true
        ? birthData!.place
        : 'Chennai, Kundrathur';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black87, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top Header: Title & Transit DateTime
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'ஆளும் கிரகங்கள்',
                style: GoogleFonts.notoSansTamil(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF7C1010), // Maroon / deep red
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$dateStr  $timeStr',
                    style: GoogleFonts.roboto(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF7C1010),
                    ),
                  ),
                  if (onEditTransit != null) ...[
                    const SizedBox(width: 6),
                    InkWell(
                      onTap: onEditTransit,
                      child: const Padding(
                        padding: EdgeInsets.all(2.0),
                        child: Icon(Icons.edit_calendar, size: 16, color: Color(0xFF7C1010)),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Sub-bar: Location & Day Lord (Grey bar)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFBDBDBD), // Medium Grey matching image
              border: Border.all(color: Colors.black87, width: 1.2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    placeStr,
                    style: GoogleFonts.notoSansTamil(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  'நாள் அதிபதி: ${rulingPlanets.dayLord.shortNameTa}',
                  style: GoogleFonts.notoSansTamil(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 2),

          // 6-Column Ruling Planets Table
          Table(
            border: TableBorder.all(
              color: Colors.black87,
              width: 1.2,
            ),
            columnWidths: const {
              0: FlexColumnWidth(1.4), // கிரகம் (Planet / Lagna)
              1: FlexColumnWidth(1.0), // ரா.அ (Sign Lord)
              2: FlexColumnWidth(1.0), // ந.அ (Star Lord)
              3: FlexColumnWidth(1.0), // உ.அ (Sub Lord)
              4: FlexColumnWidth(1.0), // உ.உ (Sub-Sub Lord)
              5: FlexColumnWidth(1.0), // உ.உ.உ (Sub-Sub-Sub Lord)
            },
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              // Header Row
              TableRow(
                children: [
                  _buildTableCell('கிரகம்', isHeader: true, isGrey: true),
                  _buildTableCell('ரா.அ', isHeader: true),
                  _buildTableCell('ந.அ', isHeader: true),
                  _buildTableCell('உ.அ', isHeader: true),
                  _buildTableCell('உ.உ', isHeader: true),
                  _buildTableCell('உ.உ.உ', isHeader: true),
                ],
              ),

              // Row 1: Lagna (லக்னம்) — 5 Ruling Planets
              TableRow(
                children: [
                  _buildTableCell('லக்னம்', isHeader: true, isGrey: true),
                  _buildTableCell(rulingPlanets.ascSignLord.shortNameTa),
                  _buildTableCell(rulingPlanets.ascStarLord.shortNameTa),
                  _buildTableCell(rulingPlanets.ascSubLord.shortNameTa),
                  _buildTableCell(rulingPlanets.ascSubSubLord.shortNameTa),
                  _buildTableCell(rulingPlanets.ascSubSubSubLord.shortNameTa),
                ],
              ),

              // Row 2: Moon (சந்திரன்) — 5 Ruling Planets
              TableRow(
                children: [
                  _buildTableCell('சந்திரன்', isHeader: true, isGrey: true),
                  _buildTableCell(rulingPlanets.moonSignLord.shortNameTa),
                  _buildTableCell(rulingPlanets.moonStarLord.shortNameTa),
                  _buildTableCell(rulingPlanets.moonSubLord.shortNameTa),
                  // Highlight 4th & 5th levels in blue as shown in reference image
                  _buildTableCell(
                    rulingPlanets.moonSubSubLord.shortNameTa,
                    textColor: const Color(0xFF0000CC),
                  ),
                  _buildTableCell(
                    rulingPlanets.moonSubSubSubLord.shortNameTa,
                    textColor: const Color(0xFF0000CC),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 8),
          // Sub-heading Legends
          Wrap(
            spacing: 12,
            runSpacing: 4,
            children: [
              _buildLegendTag('ரா.அ', 'ராசி அதிபதி (Sign Lord)'),
              _buildLegendTag('ந.அ', 'நட்சத்திர அதிபதி (Star Lord)'),
              _buildLegendTag('உ.அ', 'உப அதிபதி (Sub Lord)'),
              _buildLegendTag('உ.உ', 'உப உப அதிபதி (Sub-Sub Lord)'),
              _buildLegendTag('உ.உ.உ', 'உப உப உப அதிபதி (Sub-Sub-Sub Lord)'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTableCell(
    String text, {
    bool isHeader = false,
    bool isGrey = false,
    Color textColor = Colors.black,
  }) {
    return Container(
      height: 38,
      alignment: Alignment.center,
      color: isGrey ? const Color(0xFFBDBDBD) : Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: GoogleFonts.notoSansTamil(
          fontSize: isHeader ? 14 : 15,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildLegendTag(String code, String meaning) {
    return Text(
      '$code: $meaning',
      style: GoogleFonts.notoSansTamil(
        fontSize: 10.5,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  /// Detailed 10 Position List
  Widget _buildDetailedPositionsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Day Lord
        _buildRulingRow(
          icon: Icons.calendar_month_rounded,
          title: 'கிழமை நாதன் (Day Lord)',
          planet: rulingPlanets.dayLord,
          color: Colors.amber,
        ),
        const SizedBox(height: 14),

        // 1. Transit Ascendant — Five Ruling Planets
        Text(
          'லக்ன ஆளும் கிரகங்கள் (Transit Ascendant - 5 Ruling Planets):',
          style: GoogleFonts.notoSansTamil(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppColors.lightGold,
          ),
        ),
        const SizedBox(height: 8),
        _buildRulingRow(
          icon: Icons.accessibility_new_rounded,
          title: '1. லக்னம் நின்ற ராசி நாதன் (Ascendant Sign Lord)',
          planet: rulingPlanets.ascSignLord,
          color: Colors.tealAccent,
        ),
        const SizedBox(height: 8),
        _buildRulingRow(
          icon: Icons.star_rounded,
          title: '2. லக்னம் நின்ற நட்சத்திர நாதன் (Ascendant Star Lord)',
          planet: rulingPlanets.ascStarLord,
          color: Colors.purpleAccent,
        ),
        const SizedBox(height: 8),
        _buildRulingRow(
          icon: Icons.filter_tilt_shift_rounded,
          title: '3. லக்னம் நின்ற உப நாதன் (Ascendant Sub Lord)',
          planet: rulingPlanets.ascSubLord,
          color: Colors.orangeAccent,
        ),
        const SizedBox(height: 8),
        _buildRulingRow(
          icon: Icons.lens_blur_rounded,
          title: '4. லக்னம் நின்ற உப-உப நாதன் (Ascendant Sub-Sub Lord)',
          planet: rulingPlanets.ascSubSubLord,
          color: Colors.deepOrangeAccent,
        ),
        const SizedBox(height: 8),
        _buildRulingRow(
          icon: Icons.grain_rounded,
          title: '5. லக்னம் நின்ற உப-உப-உப நாதன் (Ascendant Sub-Sub-Sub Lord)',
          planet: rulingPlanets.ascSubSubSubLord,
          color: Colors.amberAccent,
        ),

        const SizedBox(height: 14),

        // 2. Transit Moon — Five Ruling Planets
        Text(
          'சந்திர ஆளும் கிரகங்கள் (Transit Moon - 5 Ruling Planets):',
          style: GoogleFonts.notoSansTamil(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppColors.lightGold,
          ),
        ),
        const SizedBox(height: 8),
        _buildRulingRow(
          icon: Icons.nightlight_round,
          title: '1. சந்திரன் நின்ற ராசி நாதன் (Moon Sign Lord)',
          planet: rulingPlanets.moonSignLord,
          color: Colors.lightBlueAccent,
        ),
        const SizedBox(height: 8),
        _buildRulingRow(
          icon: Icons.star_border_rounded,
          title: '2. சந்திரன் நின்ற நட்சத்திர நாதன் (Moon Star Lord)',
          planet: rulingPlanets.moonStarLord,
          color: Colors.cyanAccent,
        ),
        const SizedBox(height: 8),
        _buildRulingRow(
          icon: Icons.subdirectory_arrow_right_rounded,
          title: '3. சந்திரன் நின்ற உப நாதன் (Moon Sub Lord)',
          planet: rulingPlanets.moonSubLord,
          color: AppColors.primaryGold,
        ),
        const SizedBox(height: 8),
        _buildRulingRow(
          icon: Icons.fiber_manual_record_rounded,
          title: '4. சந்திரன் நின்ற உப-உப நாதன் (Moon Sub-Sub Lord)',
          planet: rulingPlanets.moonSubSubLord,
          color: Colors.pinkAccent,
        ),
        const SizedBox(height: 8),
        _buildRulingRow(
          icon: Icons.blur_on_rounded,
          title: '5. சந்திரன் நின்ற உப-உப-உப நாதன் (Moon Sub-Sub-Sub Lord)',
          planet: rulingPlanets.moonSubSubSubLord,
          color: Colors.greenAccent,
        ),
      ],
    );
  }

  /// Deduplicated Unique Ruling Planets
  Widget _buildUniquePlanetsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'தனித்துவமான ஆளும் கிரகங்கள் (Unique Deduplicated Ruling Planets):',
          style: GoogleFonts.notoSansTamil(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppColors.lightGold,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: rulingPlanets.uniquePlanets.map((planet) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryGold.withValues(alpha: 0.25),
                    AppColors.purpleAccent.withValues(alpha: 0.3),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primaryGold.withValues(alpha: 0.6),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryGold.withValues(alpha: 0.15),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryGold,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      planet.symbol,
                      style: const TextStyle(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    planet.nameTa,
                    style: GoogleFonts.notoSansTamil(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.lightGold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '(${planet.nameEn})',
                    style: GoogleFonts.roboto(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRulingRow({
    required IconData icon,
    required String title,
    required KP2Planet planet,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white10, width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.notoSansTamil(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  planet.symbol,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  planet.nameTa,
                  style: GoogleFonts.notoSansTamil(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
