import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../models/kp_cusp.dart';

/// Clean table displaying the 12 KP Placidus House Cusps
class KPCuspTable extends StatelessWidget {
  final List<KPCusp> cusps;

  const KPCuspTable({super.key, required this.cusps});

  @override
  Widget build(BuildContext context) {
    if (cusps.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text('No cusp data available', style: TextStyle(color: AppColors.textSecondary)),
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
                const Icon(Icons.grid_view_rounded, color: AppColors.primaryGold, size: 20),
                const SizedBox(width: 8),
                Text(
                  '12 KP PLACIDUS CUSPS (பாவ ஆரம்பங்கள்)',
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
                  _headerCol('House'),
                  _headerCol('Sign'),
                  _headerCol('Degree (DMS)'),
                  _headerCol('Sign Lord'),
                  _headerCol('Star Lord'),
                  _headerCol('Sub Lord'),
                  _headerCol('Sub-Sub Lord'),
                  _headerCol('SL Houses'),
                  _headerCol('Sub Houses'),
                ],
                rows: cusps.map((c) {
                  return DataRow(
                    cells: [
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGold.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Cusp ${c.houseNumber}',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryGold),
                          ),
                        ),
                      ),
                      DataCell(Text(c.rasiNameEn, style: const TextStyle(color: AppColors.lightGold))),
                      DataCell(Text(c.dmsFormatted, style: const TextStyle(color: Colors.white70, fontFamily: 'monospace'))),
                      DataCell(Text(c.signLord, style: const TextStyle(color: Colors.white))),
                      DataCell(Text(c.starLord, style: const TextStyle(color: Colors.amberAccent))),
                      DataCell(
                        Text(
                          c.subLord,
                          style: const TextStyle(color: Colors.lightGreenAccent, fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataCell(Text(c.subSubLord, style: const TextStyle(color: Colors.cyanAccent))),
                      DataCell(
                        Text(
                          c.starLordHouses.isEmpty ? '-' : c.starLordHouses.join(', '),
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ),
                      DataCell(
                        Text(
                          c.subLordHouses.isEmpty ? '-' : c.subLordHouses.join(', '),
                          style: const TextStyle(color: Colors.lightGreenAccent),
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
