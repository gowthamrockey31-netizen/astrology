import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/tamil_calendar_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../models/tamil_calendar_models.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../widgets/calendar/tamil_month_calendar_view.dart';
import '../../widgets/cosmic_background.dart';

/// Standalone Module Screen: மாத நாள்காட்டி (Tamil Month Calendar & Panchangam)
class TamilMonthCalendarScreen extends StatefulWidget {
  const TamilMonthCalendarScreen({super.key});

  @override
  State<TamilMonthCalendarScreen> createState() => _TamilMonthCalendarScreenState();
}

class _TamilMonthCalendarScreenState extends State<TamilMonthCalendarScreen> {
  late UserModel _user;
  late TamilCalendarController _tamilCalendarController;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  void _loadUser() {
    _user = AuthService.currentUser ??
        UserModel(
          id: 'default_usr',
          name: 'Divine Seeker',
          mobile: '+919876543210',
          gender: 'Male',
          dob: '1996-06-15',
          timeOfBirth: '08:30 AM',
          placeOfBirth: 'Chennai',
          city: 'Chennai',
          state: 'Tamil Nadu',
          country: 'India',
          zodiac: 'Gemini (Mithuna)',
          nakshatra: 'Rohini',
          lagna: 'Mesha',
          walletBalance: 500.0,
          profilePhoto: '',
          latitude: 13.0827,
          longitude: 80.2707,
          timezone: 5.5,
        );

    _tamilCalendarController = TamilCalendarController(
      initialLocation: PanchangaLocation(
        city: _user.city,
        latitude: _user.latitude,
        longitude: _user.longitude,
        timezone: _user.timezone,
      ),
      initialDate: DateTime.now(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CosmicBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Navigation Header
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.lightGold),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'மாத நாள்காட்டி',
                            style: GoogleFonts.cinzel(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.lightGold,
                              letterSpacing: 1.2,
                            ),
                          ),
                          Text(
                            'Tamil Month Calendar • ${_user.city}',
                            style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _tamilCalendarController.goToToday(),
                      icon: const Icon(Icons.today_rounded, size: 16, color: AppColors.primaryGold),
                      label: Text(
                        'இன்று (Today)',
                        style: GoogleFonts.outfit(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.lightGold,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor: AppColors.primaryGold.withValues(alpha: 0.15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: const BorderSide(color: AppColors.borderGold),
                        ),
                      ),
                    ),
                  ],
                ).animate().fade(duration: 350.ms),

                const SizedBox(height: 14),

                // Dedicated Monthly Calendar Grid View
                TamilMonthCalendarView(
                  controller: _tamilCalendarController,
                  onSwitchToDayView: () {
                    Navigator.of(context).pushNamed('/daily_calendar');
                  },
                ).animate().fade(delay: 150.ms),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
