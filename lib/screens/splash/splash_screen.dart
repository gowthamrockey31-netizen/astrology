import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:astrocall/core/constants/app_constants.dart';
import 'package:astrocall/core/theme/app_colors.dart';
import 'package:astrocall/widgets/cosmic_background.dart';
import 'package:astrocall/screens/login/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToLogin();
  }

  void _navigateToLogin() async {
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 800),
        pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CosmicBackground(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Logo Container with Golden Aura & Dynamic Animations
                Container(
                  width: 170,
                  height: 170,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.goldBorderGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryGold.withOpacity(0.6),
                        blurRadius: 36,
                        spreadRadius: 6,
                      ),
                    ],
                  ),
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.backgroundDeep,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.asset(
                      AppConstants.appLogo,
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.auto_awesome,
                        size: 80,
                        color: AppColors.lightGold,
                      ),
                    ),
                  ),
                )
                    .animate()
                    .scale(duration: 1200.ms, curve: Curves.easeOutBack)
                    .fade(duration: 1000.ms)
                    .shimmer(duration: 1800.ms, delay: 600.ms, color: AppColors.lightGold.withOpacity(0.4)),

                const SizedBox(height: 32),

                // Main Title: Astrocall
                Text(
                  AppConstants.appName,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cinzel(
                    fontSize: 44,
                    fontWeight: FontWeight.bold,
                    color: AppColors.lightGold,
                    letterSpacing: 3.0,
                    shadows: [
                      Shadow(
                        color: AppColors.primaryGold.withOpacity(0.8),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                )
                    .animate()
                    .fade(duration: 1000.ms, delay: 400.ms)
                    .slideY(begin: 0.3, end: 0, duration: 800.ms, curve: Curves.easeOut),

                const SizedBox(height: 8),

                // Ornament Divider
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(width: 40, height: 1, color: AppColors.borderGold),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Icon(Icons.star, size: 12, color: AppColors.lightGold),
                    ),
                    Container(width: 40, height: 1, color: AppColors.borderGold),
                  ],
                ).animate().fade(duration: 800.ms, delay: 700.ms),

                const SizedBox(height: 8),

                // Subtitle: Digital Astrology Centre
                Text(
                  AppConstants.appSubtitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cinzel(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                    letterSpacing: 2.0,
                  ),
                ).animate().fade(duration: 1000.ms, delay: 900.ms),

                const SizedBox(height: 48),

                // Subtle Loading Ring
                const SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    color: AppColors.lightGold,
                    strokeWidth: 2,
                  ),
                ).animate().fade(duration: 600.ms, delay: 1200.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
