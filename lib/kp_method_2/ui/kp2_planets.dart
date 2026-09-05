import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../models/kp2_planet_position.dart';

/// Clean Cosmic Planetary Positions Table for KP Method 2
class KP2PlanetsWidget extends StatelessWidget {
  final List<KP2PlanetPosition> planetPositions;

  const KP2PlanetsWidget({
    super.key,
    required this.planetPositions,
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
              const Icon(Icons.public, color: AppColors.primaryGold, size: 20),
              const SizedBox(width: 8),
              Text(
                '9 KP கிரக நிலைகள் (Planetary Positions)',
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
                _buildColumn('கிரகம்\n(Planet)'),
                _buildColumn('ராசி\n(Rasi)'),
                _buildColumn('பாகை (DMS)\n(Degree)'),
                _buildColumn('நட்சத்திரம்\n(Nakshatra)'),
                _buildColumn('பாதம்\n(Pada)'),
                _buildColumn('ஸ்டார்\n(Star Lord)'),
                _buildColumn('சப்\n(Sub Lord)'),
                _buildColumn('சப்-சப்\n(Sub-Sub)'),
                _buildColumn('பாவம்\n(House)'),
              ],
              rows: planetPositions.asMap().entries.map((entry) {
                final idx = entry.key;
                final pos = entry.value;
                final isEven = idx % 2 == 0;

                return DataRow(
                  color: WidgetStateProperty.resolveWith<Color?>(
                    (states) => isEven
                        ? Colors.white.withValues(alpha: 0.02)
                        : AppColors.primaryGold.withValues(alpha: 0.04),
                  ),
                  cells: [
                    // Planet
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primaryGold.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              pos.planet.symbol,
                              style: const TextStyle(
                                color: AppColors.lightGold,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            pos.planet.nameTa,
                            style: GoogleFonts.notoSansTamil(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (pos.isRetrograde) ...[
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(
                                color: Colors.redAccent.withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'வ',
                                style: TextStyle(
                                  color: Colors.redAccent,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    // Rasi
                    DataCell(
                      Text(
                        pos.rasiNameTa,
                        style: GoogleFonts.notoSansTamil(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
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
                          pos.formattedDms,
                          style: GoogleFonts.robotoMono(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.lightGold,
                          ),
                        ),
                      ),
                    ),
                    // Nakshatra
                    DataCell(
                      Text(
                        pos.nakshatraNameTa,
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
                          pos.pada.toString(),
                          style: GoogleFonts.roboto(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    // Star Lord
                    DataCell(
                      _buildLordBadge(pos.starLord.nameTa, Colors.blueAccent),
                    ),
                    // Sub Lord
                    DataCell(
                      _buildLordBadge(pos.subLord.nameTa, AppColors.primaryGold),
                    ),
                    // Sub-Sub Lord
                    DataCell(
                      _buildLordBadge(pos.subSubLord.nameTa, Colors.purpleAccent),
                    ),
                    // Occupied House
                    DataCell(
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGold.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: AppColors.primaryGold.withValues(alpha: 0.4),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            pos.occupiedHouse.toString(),
                            style: GoogleFonts.roboto(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.lightGold,
                            ),
                          ),
                        ),
                      ),
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
