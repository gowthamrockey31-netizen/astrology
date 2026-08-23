import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';
import '../services/astrology_calculator.dart';

class SouthIndianRasiChart extends StatelessWidget {
  final String title;
  final Map<String, PlanetDetail> planets;
  final List<String>? highlightRasis;

  const SouthIndianRasiChart({
    super.key,
    required this.title,
    required this.planets,
    this.highlightRasis,
  });

  /// Standard South Indian 4x4 Grid index -> Zodiac Rasi index (0..11)
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
    // Map planets to their Rasi index (0..11)
    final Map<int, List<PlanetDetail>> rasiPlanets = {};
    for (final p in planets.values) {
      rasiPlanets.putIfAbsent(p.rasiIndex, () => []).add(p);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 14),
          decoration: BoxDecoration(
            color: AppColors.backgroundMid,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.6)),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              title,
              style: GoogleFonts.cinzel(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.lightGold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        AspectRatio(
          aspectRatio: 1,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.backgroundDeep,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primaryGold, width: 1.5),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                ),
                itemCount: 16,
                itemBuilder: (context, index) {
                  final isCenter = (index == 5 || index == 6 || index == 9 || index == 10);
                  if (isCenter) {
                    return const SizedBox.shrink();
                  }

                  final rasiIdx = _gridIndexToRasiIndex[index] ?? 0;
                  final rasiName = AstrologyCalculator.rasiNamesTa[rasiIdx];
                  final housePlanets = rasiPlanets[rasiIdx] ?? [];
                  final hasLagna = housePlanets.any((p) => p.name == 'Lagna');

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: hasLagna
                          ? AppColors.primaryGold.withValues(alpha: 0.18)
                          : AppColors.cardSurface,
                      border: Border.all(
                        color: hasLagna ? AppColors.primaryGold : AppColors.borderGold.withValues(alpha: 0.4),
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
                                  fontWeight: FontWeight.normal,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                            Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 2,
                              runSpacing: 1,
                              children: housePlanets.map((p) {
                                final isLg = p.name == 'Lagna';
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 2,
                                    vertical: 1,
                                  ),
                                  decoration: isLg
                                      ? BoxDecoration(
                                          color: Colors.red.shade900.withValues(alpha: 0.85),
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
          ),
        ),
      ],
    );
  }
}
