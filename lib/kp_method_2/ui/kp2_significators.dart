import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../models/kp2_significator.dart';

/// Cosmic Tables for Planet & House Significators with Advantage Filter in KP Method 2
class KP2SignificatorsWidget extends StatelessWidget {
  final List<KP2PlanetSignificator> planetSignificators;
  final List<KP2HouseSignificator> houseSignificators;

  const KP2SignificatorsWidget({
    super.key,
    required this.planetSignificators,
    required this.houseSignificators,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Planet Significators Card
        _buildCardContainer(
          icon: Icons.hub_rounded,
          title: 'கிரக தொடர்புகள் (Planet Significators)',
          child: SingleChildScrollView(
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
                _buildColumn('அமர்ந்த பாவம்\n(Occ. House)'),
                _buildColumn('ஸ்டார் நாதன்\n(Star Lord)'),
                _buildColumn('ஸ்டார் பாவங்கள்\n(Star Houses)'),
                _buildColumn('சப் நாதன்\n(Sub Lord)'),
                _buildColumn('சப் பாவங்கள்\n(Sub Houses)'),
                _buildColumn('சப்-சப் நாதன்\n(Sub-Sub Lord)'),
                _buildColumn('சப்-சப் பாவங்கள்\n(Sub-Sub Houses)'),
              ],
              rows: planetSignificators.asMap().entries.map((entry) {
                final idx = entry.key;
                final ps = entry.value;
                final isEven = idx % 2 == 0;

                return DataRow(
                  color: WidgetStateProperty.resolveWith<Color?>(
                    (states) => isEven
                        ? Colors.white.withValues(alpha: 0.02)
                        : AppColors.primaryGold.withValues(alpha: 0.04),
                  ),
                  cells: [
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
                              ps.planet.symbol,
                              style: const TextStyle(
                                color: AppColors.lightGold,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            ps.planet.nameTa,
                            style: GoogleFonts.notoSansTamil(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    DataCell(
                      Center(
                        child: _buildHouseBadge(ps.occupiedHouse.toString(), AppColors.primaryGold),
                      ),
                    ),
                    DataCell(Text(
                      ps.starLord.nameTa,
                      style: GoogleFonts.notoSansTamil(color: Colors.blueAccent, fontSize: 12),
                    )),
                    DataCell(_buildHouseListBadges(ps.starLordHouses, Colors.blueAccent)),
                    DataCell(Text(
                      ps.subLord.nameTa,
                      style: GoogleFonts.notoSansTamil(color: AppColors.primaryGold, fontSize: 12),
                    )),
                    DataCell(_buildHouseListBadges(ps.subLordHouses, AppColors.primaryGold)),
                    DataCell(Text(
                      ps.subSubLord.nameTa,
                      style: GoogleFonts.notoSansTamil(color: Colors.purpleAccent, fontSize: 12),
                    )),
                    DataCell(_buildHouseListBadges(ps.subSubLordHouses, Colors.purpleAccent)),
                  ],
                );
              }).toList(),
            ),
          ),
        ),

        const SizedBox(height: 20),

        // 2. House Significators with Advantage Filter Card
        _buildCardContainer(
          icon: Icons.verified_rounded,
          title: 'பாவ தொடர்புகள் & அட்வான்டேஜ் (House Significators & Advantage)',
          subtitle: 'விதிமுறை: 1+12 இணைந்தால் 12 மட்டுமே; இரட்டை ஸ்டார் + ஒற்றை சப் -> சப்; ஒற்றை + இரட்டை கலவை -> ஒற்றை',
          child: SingleChildScrollView(
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
                _buildColumn('பாவம்\n(House)'),
                _buildColumn('சப் நாதன்\n(Cusp Sub)'),
                _buildColumn('சப் பாவங்கள்\n(Sub Houses)'),
                _buildColumn('ஸ்டார் நாதன்\n(Star Lord)'),
                _buildColumn('ஸ்டார் பாவங்கள்\n(Star Houses)'),
                _buildColumn('சப்-சப் நாதன்\n(Sub-Sub Lord)'),
                _buildColumn('அட்வான்டேஜ் பாவங்கள்\n★ ADVANTAGE HOUSES ★'),
              ],
              rows: houseSignificators.asMap().entries.map((entry) {
                final idx = entry.key;
                final hs = entry.value;
                final isEven = idx % 2 == 0;

                return DataRow(
                  color: WidgetStateProperty.resolveWith<Color?>(
                    (states) => isEven
                        ? Colors.white.withValues(alpha: 0.02)
                        : AppColors.primaryGold.withValues(alpha: 0.04),
                  ),
                  cells: [
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGold.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          hs.house.toString(),
                          style: const TextStyle(
                            color: AppColors.lightGold,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    DataCell(Text(
                      hs.cuspSubLord.nameTa,
                      style: GoogleFonts.notoSansTamil(color: AppColors.primaryGold, fontSize: 12),
                    )),
                    DataCell(_buildHouseListBadges(hs.subLordHouses, AppColors.primaryGold)),
                    DataCell(Text(
                      hs.starLord.nameTa,
                      style: GoogleFonts.notoSansTamil(color: Colors.blueAccent, fontSize: 12),
                    )),
                    DataCell(_buildHouseListBadges(hs.starLordHouses, Colors.blueAccent)),
                    DataCell(Text(
                      hs.subSubLord.nameTa,
                      style: GoogleFonts.notoSansTamil(color: Colors.purpleAccent, fontSize: 12),
                    )),
                    // Golden Advantage Houses Column
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primaryGold.withValues(alpha: 0.25),
                              AppColors.darkGold.withValues(alpha: 0.15),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.primaryGold.withValues(alpha: 0.6),
                            width: 1.2,
                          ),
                        ),
                        child: hs.advantageHouses.isEmpty
                            ? const Text('—', style: TextStyle(color: AppColors.textSecondary))
                            : Wrap(
                                spacing: 4,
                                children: hs.advantageHouses.map((h) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryGold,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      h.toString(),
                                      style: GoogleFonts.roboto(
                                        color: AppColors.textDark,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCardContainer({
    required IconData icon,
    required String title,
    String? subtitle,
    required Widget child,
  }) {
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
              Icon(icon, color: AppColors.primaryGold, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.cinzel(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.lightGold,
                        letterSpacing: 1.1,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: GoogleFonts.notoSansTamil(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
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

  Widget _buildHouseBadge(String house, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
      ),
      child: Text(
        house,
        style: GoogleFonts.roboto(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildHouseListBadges(List<int> houses, Color color) {
    if (houses.isEmpty) {
      return const Text('—', style: TextStyle(color: Colors.white30));
    }
    return Wrap(
      spacing: 4,
      children: houses.map((h) => _buildHouseBadge(h.toString(), color)).toList(),
    );
  }
}
