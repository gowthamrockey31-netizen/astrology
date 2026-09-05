import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../models/kp2_cusp.dart';

/// Clean Cosmic Placidus House Cusps Table for KP Method 2
class KP2CuspsWidget extends StatelessWidget {
  final List<KP2Cusp> cusps;

  const KP2CuspsWidget({
    super.key,
    required this.cusps,
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
          Row(
            children: [
              const Icon(Icons.account_balance, color: AppColors.primaryGold, size: 20),
              const SizedBox(width: 8),
              Text(
                '12 பாவ ஆரம்ப முனைகள் (Placidus Cusps)',
                style: GoogleFonts.cinzel(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.lightGold,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(
                AppColors.primaryGold.withValues(alpha: 0.15),
              ),
              horizontalMargin: 12,
              columnSpacing: 16,
              dataRowMinHeight: 44,
              dataRowMaxHeight: 52,
              columns: [
                _buildColumn('பாவம்\n(Cusp)'),
                _buildColumn('பாகை (DMS)\n(Degree)'),
                _buildColumn('ராசி\n(Rasi)'),
                _buildColumn('நட்சத்திரம்\n(Nakshatra)'),
                _buildColumn('பாதம்\n(Pada)'),
                _buildColumn('ராசி நாதன்\n(Sign Lord)'),
                _buildColumn('ஸ்டார் நாதன்\n(Star Lord)'),
                _buildColumn('சப் நாதன்\n(Sub Lord)'),
                _buildColumn('சப்-சப் நாதன்\n(Sub-Sub)'),
              ],
              rows: cusps.asMap().entries.map((entry) {
                final idx = entry.key;
                final cusp = entry.value;
                final isEven = idx % 2 == 0;
                final isLagna = cusp.house == 1;

                return DataRow(
                  color: WidgetStateProperty.resolveWith<Color?>(
                    (states) => isLagna
                        ? AppColors.purpleAccent.withValues(alpha: 0.18)
                        : (isEven
                            ? Colors.white.withValues(alpha: 0.02)
                            : AppColors.primaryGold.withValues(alpha: 0.04)),
                  ),
                  cells: [
                    // House number
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isLagna
                                  ? AppColors.primaryGold
                                  : AppColors.primaryGold.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              cusp.house.toString(),
                              style: TextStyle(
                                color: isLagna ? AppColors.textDark : AppColors.lightGold,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          if (isLagna) ...[
                            const SizedBox(width: 6),
                            Text(
                              '(லக்னம்)',
                              style: GoogleFonts.notoSansTamil(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.lightGold,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    // DMS Degree
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          cusp.formattedDms,
                          style: GoogleFonts.robotoMono(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.lightGold,
                          ),
                        ),
                      ),
                    ),
                    // Rasi
                    DataCell(
                      Text(
                        cusp.rasiNameTa,
                        style: GoogleFonts.notoSansTamil(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    // Nakshatra
                    DataCell(
                      Text(
                        cusp.nakshatraNameTa,
                        style: GoogleFonts.notoSansTamil(
                          fontSize: 12,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    // Pada
                    DataCell(
                      Center(
                        child: Text(
                          cusp.pada.toString(),
                          style: GoogleFonts.roboto(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    // Sign Lord
                    DataCell(
                      _buildLordBadge(cusp.signLord.nameTa, Colors.tealAccent),
                    ),
                    // Star Lord
                    DataCell(
                      _buildLordBadge(cusp.starLord.nameTa, Colors.blueAccent),
                    ),
                    // Sub Lord
                    DataCell(
                      _buildLordBadge(cusp.subLord.nameTa, AppColors.primaryGold),
                    ),
                    // Sub-Sub Lord
                    DataCell(
                      _buildLordBadge(cusp.subSubLord.nameTa, Colors.purpleAccent),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  DataColumn _buildColumn(String title) {
    return DataColumn(
      label: Text(
        title,
        textAlign: TextAlign.center,
        style: GoogleFonts.notoSansTamil(
          fontWeight: FontWeight.bold,
          color: AppColors.lightGold,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildLordBadge(String name, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
      ),
      child: Text(
        name,
        style: GoogleFonts.notoSansTamil(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
