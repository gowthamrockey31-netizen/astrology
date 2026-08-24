import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';
import '../models/varga_chart_model.dart';
import '../services/astrology_calculator.dart';

/// Interactive Reusable South Indian Style Varga (Divisional) Chart Widget
class VargaChartWidget extends StatelessWidget {
  final VargaChartResult vargaResult;
  final String title;

  const VargaChartWidget({
    super.key,
    required this.vargaResult,
    this.title = '',
  });

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
    final chartTitle = title.isNotEmpty ? title : '${vargaResult.type.code} - ${vargaResult.type.tamilName} (${vargaResult.type.englishName})';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundDeep,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryGold, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGold.withValues(alpha: 0.15),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          // Header Bar
          Container(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.backgroundMid,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.borderGold.withValues(alpha: 0.5)),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.grid_4x4_rounded, color: AppColors.lightGold, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    chartTitle,
                    style: GoogleFonts.cinzel(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.lightGold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),

          // 4x4 South Indian Grid
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.backgroundDeep,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primaryGold, width: 1.2),
              ),
              child: Stack(
                children: [
                  // Center Title Box
                  Center(
                    child: Container(
                      width: 100,
                      height: 50,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.backgroundMid.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.3)),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                vargaResult.type.code,
                                style: GoogleFonts.cinzel(
                                  color: AppColors.primaryGold,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                vargaResult.type.tamilName,
                                style: GoogleFonts.outfit(
                                  color: AppColors.lightGold,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 16 Grid Cells (12 perimeter houses, 4 center merged)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
                      itemCount: 16,
                      itemBuilder: (context, index) {
                        final isCenter = (index == 5 || index == 6 || index == 9 || index == 10);
                        if (isCenter) {
                          return const SizedBox.shrink();
                        }

                        final rasiIdx = _gridIndexToRasiIndex[index] ?? 0;
                        final rasiName = AstrologyCalculator.rasiNamesTa[rasiIdx];
                        final housePlanets = vargaResult.rasiPlanets[rasiIdx] ?? [];
                        final hasLagna = housePlanets.any((p) => p.planetKey == 'Lagna');

                        return Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: hasLagna
                                ? AppColors.primaryGold.withValues(alpha: 0.18)
                                : AppColors.cardSurface,
                            border: Border.all(
                              color: hasLagna ? AppColors.primaryGold : Colors.brown.shade300,
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
                                        color: AppColors.textSecondary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Wrap(
                                    alignment: WrapAlignment.center,
                                    spacing: 2,
                                    runSpacing: 1,
                                    children: housePlanets.map((p) {
                                      final isLg = p.planetKey == 'Lagna';
                                      return Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                                        decoration: isLg
                                            ? BoxDecoration(
                                                color: Colors.red.shade900.withValues(alpha: 0.8),
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
