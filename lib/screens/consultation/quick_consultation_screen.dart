import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/consultation/quick_consultation_view.dart';
import '../../widgets/profile/family_profiles_sheet.dart';

/// Screen hosting the 4-Slot Quick Consultation View for Astrologers and Clients.
class QuickConsultationScreen extends StatelessWidget {
  const QuickConsultationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDeep,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundMid,
        elevation: 2,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'விரைவு ஆலோசனை',
              style: GoogleFonts.cinzel(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.lightGold,
              ),
            ),
            Text(
              '4-Slot Quick Consultation View',
              style: GoogleFonts.outfit(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.people_alt_rounded, color: AppColors.lightGold),
            tooltip: 'குடும்ப ஜாதகங்கள் (Family Profiles)',
            onPressed: () => FamilyProfilesSheet.show(context),
          ),
        ],
      ),
      body: const SafeArea(
        child: QuickConsultationView(),
      ),
    );
  }
}
