import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:astrocall/core/theme/app_colors.dart';

class AstroDivider extends StatelessWidget {
  final String label;

  const AstroDivider({
    super.key,
    this.label = 'OR',
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1.2,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, AppColors.borderGold],
              ),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 14),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderGold.withOpacity(0.6), width: 1),
            color: AppColors.backgroundDeep,
          ),
          child: Text(
            label,
            style: GoogleFonts.poppins(
              color: AppColors.lightGold,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1.2,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.borderGold, Colors.transparent],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
