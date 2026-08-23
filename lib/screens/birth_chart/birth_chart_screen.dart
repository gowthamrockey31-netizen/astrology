import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../widgets/cosmic_background.dart';
import '../../widgets/golden_button.dart';
import '../../widgets/south_indian_jathagam_widget.dart';

class BirthChartScreen extends StatelessWidget {
  const BirthChartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;
    return Scaffold(
      body: CosmicBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.lightGold),
                    ),
                    Text('Birth Chart',
                        style: GoogleFonts.cinzel(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.lightGold, letterSpacing: 1.5)),
                    const Spacer(),
                    const Icon(Icons.brightness_5_rounded, color: AppColors.primaryGold, size: 26),
                  ],
                ).animate().fade(duration: 500.ms),
                const SizedBox(height: 4),
                Text('ஜாதக வரைபடம் • Vedic Kundali (Rasi, Navamsha & Pathasaram)',
                    style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 12)).animate().fade(delay: 100.ms),
                const SizedBox(height: 20),
                
                // Full South Indian Jathagam Chart (Rasi, Navamsha & Natchathira Pathasaram)
                SouthIndianJathagamWidget(user: user).animate().fade(delay: 150.ms),
                
                const SizedBox(height: 24),
                GoldenButton(
                  text: 'Update Birth Details',
                  icon: Icons.edit_rounded,
                  onPressed: () => Navigator.of(context).pushNamed('/profile'),
                ).animate().scale(delay: 450.ms, duration: 400.ms),
                const SizedBox(height: 16),
                _buildConsultBanner(context).animate().fade(delay: 500.ms),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConsultBanner(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed('/user_dashboard'),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(colors: [AppColors.purpleAccent.withOpacity(0.3), AppColors.blueAccent.withOpacity(0.2)]),
          border: Border.all(color: AppColors.borderGold.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            const Icon(Icons.psychology_rounded, color: AppColors.lightGold, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Get Expert Analysis', style: GoogleFonts.cinzel(color: AppColors.lightGold, fontWeight: FontWeight.bold, fontSize: 14)),
                  Text('Consult an astrologer for deep chart reading',
                      style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: AppColors.lightGold, size: 16),
          ],
        ),
      ),
    );
  }
}
