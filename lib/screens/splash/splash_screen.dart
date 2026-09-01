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
  bool _navigating = false;

  @override
  void initState() {
    super.initState();
    _navigateToLogin();
  }

  void _navigateToLogin() async {
    await Future.delayed(const Duration(milliseconds: 3200));
    _proceedToLogin();
  }

  void _proceedToLogin() {
    if (_navigating || !mounted) return;
    _navigating = true;
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
    final size = MediaQuery.of(context).size;
    final isLandscape = size.width > size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF03050C),
      body: GestureDetector(
        onTap: _proceedToLogin,
        child: CosmicBackground(
          showNebula: true,
          child: SafeArea(
            child: Stack(
              children: [
                // Centered Splash Poster
                Center(
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: isLandscape ? size.height * 0.65 : 480,
                      maxHeight: size.height,
                    ),
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryGold.withValues(alpha: 0.18),
                          blurRadius: 40,
                          spreadRadius: 4,
                        ),
                        BoxShadow(
                          color: AppColors.purpleAccent.withValues(alpha: 0.25),
                          blurRadius: 60,
                          spreadRadius: 8,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(isLandscape ? 20 : 0),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Main Divine Poster Image
                          Image.asset(
                            AppConstants.splashGanesha,
                            fit: BoxFit.contain,
                            alignment: Alignment.center,
                            errorBuilder: (context, error, stackTrace) => Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(AppConstants.appLogo, width: 140, height: 140),
                                const SizedBox(height: 20),
                                Text(
                                  AppConstants.appName,
                                  style: GoogleFonts.cinzel(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.lightGold,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Subtle Golden Shimmer Highlight
                          Positioned.fill(
                            child: Container()
                                .animate()
                                .shimmer(
                                  duration: 2200.ms,
                                  delay: 800.ms,
                                  color: AppColors.lightGold.withValues(alpha: 0.12),
                                ),
                          ),
                        ],
                      ),
                    ),
                  )
                      .animate()
                      .fade(duration: 900.ms, curve: Curves.easeOut)
                      .scale(
                        begin: const Offset(0.95, 0.95),
                        end: const Offset(1.0, 1.0),
                        duration: 1000.ms,
                        curve: Curves.easeOutCubic,
                      ),
                ),

                // Bottom Loading Indicator & Tap to Continue hint
                Positioned(
                  bottom: 24,
                  left: 0,
                  right: 0,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF070B18).withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.borderGold.withValues(alpha: 0.3),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                color: AppColors.lightGold,
                                strokeWidth: 2,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Entering Divine Sanctuary...',
                              style: GoogleFonts.cinzel(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.lightGold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      )
                          .animate()
                          .fade(duration: 800.ms, delay: 600.ms)
                          .slideY(begin: 0.4, end: 0, duration: 600.ms),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
