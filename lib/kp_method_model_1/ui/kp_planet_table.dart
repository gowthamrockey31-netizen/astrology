import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../models/kp_planet_position.dart';

/// Clean table displaying the 9 KP Planets with detailed positions and lords
class KPPlanetTable extends StatelessWidget {
  final List<KPPlanetPosition> planets;

  const KPPlanetTable({super.key, required this.planets});

  @override
  Widget build(BuildContext context) {
    if (planets.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text('No planetary data available', style: TextStyle(color: AppColors.textSecondary)),
        ),
      );
    }

    return Card(
      color: AppColors.backgroundMid,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.primaryGold.withValues(alpha: 0.3), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.public_rounded, color: AppColors.primaryGold, size: 20),
                const SizedBox(width: 8),
                Text(
                  '9 KP PLANETS (கிரக நிலைகள்)',
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
                  _headerCol('Planet'),
                  _headerCol('Sign'),
                  _headerCol('Degree (DMS)'),
                  _headerCol('Nakshatra'),
                  _headerCol('Pada'),
                  _headerCol('Star Lord'),
                  _headerCol('Sub Lord'),
                  _headerCol('Sub-Sub Lord'),
                  _headerCol('Occupied'),
                  _headerCol('Owned'),
                  _headerCol('Status'),
                ],
                rows: planets.map((p) {
                  return DataRow(
                    cells: [
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              p.planet.symbol,
                              style: const TextStyle(color: AppColors.primaryGold, fontSize: 16),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              p.planet.nameEn,
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      DataCell(Text(p.rasiNameEn, style: const TextStyle(color: AppColors.lightGold))),
                      DataCell(Text(p.dmsFormatted, style: const TextStyle(color: Colors.white70, fontFamily: 'monospace'))),
                      DataCell(Text(p.nakshatraNameEn, style: const TextStyle(color: Colors.white))),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGold.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text('P${p.pada}', style: const TextStyle(color: AppColors.primaryGold, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      DataCell(Text(p.starLord, style: const TextStyle(color: Colors.amberAccent))),
                      DataCell(
                        Text(
                          p.subLord,
                          style: const TextStyle(color: Colors.lightGreenAccent, fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataCell(Text(p.subSubLord, style: const TextStyle(color: Colors.cyanAccent))),
                      DataCell(Text('H${p.occupiedHouse}', style: const TextStyle(color: Colors.white))),
                      DataCell(
                        Text(
                          p.ownedHouses.isEmpty ? '-' : p.ownedHouses.map((h) => 'H$h').join(', '),
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ),
                      DataCell(
                        p.isRetrograde
                            ? Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.redAccent.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text('R (வக்ரம்)', style: TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                              )
                            : const Text('Direct', style: TextStyle(color: Colors.greenAccent, fontSize: 11)),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
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
