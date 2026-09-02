import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../models/kp_significator.dart';

/// Tables displaying Planet and House Significators along with Model 1 Advantage Houses
class KPSignificatorTable extends StatelessWidget {
  final List<KPPlanetSignificator> planetSignificators;
  final List<KPHouseSignificator> houseSignificators;

  const KPSignificatorTable({
    super.key,
    required this.planetSignificators,
    required this.houseSignificators,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Model 1 Advantage Filter Explanation Card
        Card(
          color: AppColors.backgroundMid,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: AppColors.primaryGold.withValues(alpha: 0.3)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.filter_alt_rounded, color: AppColors.primaryGold, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'KP ADVANTAGE FILTER — MODEL 1',
                        style: GoogleFonts.cinzel(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.lightGold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '• Rule 1: STAR = Even, SUB = Odd -> Sub houses priority\n'
                        '• Rule 2: STAR = Odd, SUB = Even -> Star houses priority\n'
                        '• Rule 3: Mixed odd/even -> Odd houses priority\n'
                        '• Rule 4: If 1 + 12 occur together -> Remove 1, Keep 12',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: Colors.white70,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // 1. Planet Significators Table
        Card(
          color: AppColors.backgroundMid,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: AppColors.primaryGold.withValues(alpha: 0.3)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.hub_rounded, color: AppColors.primaryGold, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'PLANET SIGNIFICATORS (கிரக காரகத்துவங்கள்)',
                      style: GoogleFonts.cinzel(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.lightGold,
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
                      _headerCol('Planet'),
                      _headerCol('Planet Houses'),
                      _headerCol('Star Lord'),
                      _headerCol('Star Houses'),
                      _headerCol('Sub Lord'),
                      _headerCol('Sub Houses'),
                      _headerCol('Advantage Houses (Model 1)'),
                    ],
                    rows: planetSignificators.map((ps) {
                      return DataRow(
                        cells: [
                          DataCell(Text(ps.planet, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                          DataCell(Text(ps.planetHouses.isEmpty ? '-' : ps.planetHouses.join(', '), style: const TextStyle(color: Colors.white70))),
                          DataCell(Text(ps.starLord, style: const TextStyle(color: Colors.amberAccent))),
                          DataCell(Text(ps.starLordHouses.isEmpty ? '-' : ps.starLordHouses.join(', '), style: const TextStyle(color: Colors.white70))),
                          DataCell(Text(ps.subLord, style: const TextStyle(color: Colors.lightGreenAccent, fontWeight: FontWeight.bold))),
                          DataCell(Text(ps.subLordHouses.isEmpty ? '-' : ps.subLordHouses.join(', '), style: const TextStyle(color: Colors.white70))),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.amber.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
                              ),
                              child: Text(
                                ps.advantageHouses.isEmpty ? '-' : ps.advantageHouses.join(', '),
                                style: const TextStyle(
                                  color: AppColors.lightGold,
                                  fontWeight: FontWeight.bold,
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
          ),
        ),

        const SizedBox(height: 16),

        // 2. House Significators Table
        Card(
          color: AppColors.backgroundMid,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: AppColors.primaryGold.withValues(alpha: 0.3)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.domain_rounded, color: AppColors.primaryGold, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'HOUSE SIGNIFICATORS (பாவ காரகத்துவங்கள்)',
                      style: GoogleFonts.cinzel(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.lightGold,
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
                      _headerCol('House'),
                      _headerCol('Cusp Sub Lord'),
                      _headerCol('SL Houses'),
                      _headerCol('Star Lord'),
                      _headerCol('Star Houses'),
                      _headerCol('Sub Lord'),
                      _headerCol('Sub Houses'),
                      _headerCol('Final Advantage Houses'),
                    ],
                    rows: houseSignificators.map((hs) {
                      return DataRow(
                        cells: [
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.primaryGold.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text('House ${hs.houseNumber}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryGold)),
                            ),
                          ),
                          DataCell(Text(hs.cuspSubLord, style: const TextStyle(color: Colors.lightGreenAccent, fontWeight: FontWeight.bold))),
                          DataCell(Text(hs.cuspSubLordHouses.isEmpty ? '-' : hs.cuspSubLordHouses.join(', '), style: const TextStyle(color: Colors.white70))),
                          DataCell(Text(hs.starLord, style: const TextStyle(color: Colors.amberAccent))),
                          DataCell(Text(hs.starLordHouses.isEmpty ? '-' : hs.starLordHouses.join(', '), style: const TextStyle(color: Colors.white70))),
                          DataCell(Text(hs.subLord, style: const TextStyle(color: Colors.cyanAccent))),
                          DataCell(Text(hs.subLordHouses.isEmpty ? '-' : hs.subLordHouses.join(', '), style: const TextStyle(color: Colors.white70))),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.green.withValues(alpha: 0.5)),
                              ),
                              child: Text(
                                hs.finalAdvantageHouses.isEmpty ? '-' : hs.finalAdvantageHouses.join(', '),
                                style: const TextStyle(
                                  color: Colors.lightGreenAccent,
                                  fontWeight: FontWeight.bold,
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
          ),
        ),
      ],
    );
  }

  DataColumn _headerCol(String title) {
    return DataColumn(
      label: Text(
        title,
        style: GoogleFonts.outfit(
          color: AppColors.primaryGold,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
