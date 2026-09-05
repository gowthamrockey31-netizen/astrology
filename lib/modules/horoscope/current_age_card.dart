import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import 'current_age_calculator.dart';

/// UI Card widget to calculate and display real-time completed Age:
/// - Primary: வருடம், மாதம், நாள் (Tamil)
/// - Secondary: Years, Months, Days (English)
class CurrentAgeCard extends StatelessWidget {
  final DateTime birthDateTime;

  const CurrentAgeCard({
    super.key,
    required this.birthDateTime,
  });

  @override
  Widget build(BuildContext context) {
    final age = CurrentAgeCalculator.calculate(
      birthDateTime: birthDateTime,
    );

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
      color: AppColors.cardSurface,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: AppColors.primaryGold.withValues(alpha: 0.55),
          width: 1.2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.cake_rounded, color: AppColors.lightGold, size: 22),
                const SizedBox(width: 8),
                Text(
                  'நடப்பு வயது',
                  style: GoogleFonts.cinzel(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: AppColors.lightGold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              age.tamilText,
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              age.englishText,
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
