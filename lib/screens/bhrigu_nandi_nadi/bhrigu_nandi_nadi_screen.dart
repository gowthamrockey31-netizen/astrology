import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../models/bhrigu_nandi_nadi_model.dart';
import '../../models/user_model.dart';
import '../../services/astrology_calculator.dart';
import '../../services/auth_service.dart';
import '../../services/bhrigu_nandi_nadi_calculator.dart';
import '../../widgets/cosmic_background.dart';

/// New Major Module 5: Bhrigu Nandi Nadi (பிருகு நந்தி நாடி முறை) Screen
class BhriguNandiNadiScreen extends StatefulWidget {
  const BhriguNandiNadiScreen({super.key});

  @override
  State<BhriguNandiNadiScreen> createState() => _BhriguNandiNadiScreenState();
}

class _BhriguNandiNadiScreenState extends State<BhriguNandiNadiScreen> {
  late UserModel _user;
  late BhriguNandiNadiResult _nadiResult;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
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
          zodiac: 'Gemini',
          nakshatra: 'Rohini',
          lagna: 'Mesha',
          walletBalance: 500.0,
          profilePhoto: '',
          latitude: 13.0827,
          longitude: 80.2707,
          timezone: 5.5,
        );

    final parsedDob = DateTime.tryParse(_user.dob) ?? DateTime(1996, 6, 15);
    final tobParts = _user.timeOfBirth.split(':');
    int hour = 8;
    int minute = 30;
    if (tobParts.length >= 2) {
      hour = int.tryParse(tobParts[0].replaceAll(RegExp(r'[^0-9]'), '')) ?? 8;
      minute = int.tryParse(tobParts[1].replaceAll(RegExp(r'[^0-9]'), '')) ?? 30;
      if (_user.timeOfBirth.toUpperCase().contains('PM') && hour < 12) hour += 12;
      if (_user.timeOfBirth.toUpperCase().contains('AM') && hour == 12) hour = 0;
    }

    final dt = DateTime(parsedDob.year, parsedDob.month, parsedDob.day, hour, minute);

    final astroData = AstrologyCalculator.calculateHoroscope(
      dateOfBirth: dt,
      latitude: _user.latitude,
      longitude: _user.longitude,
      utcOffsetHours: _user.timezone,
    );

    _nadiResult = BhriguNandiNadiCalculator.calculate(astroData.planets);
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
                // Header
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
                            'பிருகு நந்தி நாடி முறை',
                            style: GoogleFonts.cinzel(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.lightGold,
                              letterSpacing: 1.2,
                            ),
                          ),
                          Text(
                            'Bhrigu Nandi Nadi Planetary Combinations',
                            style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ).animate().fade(duration: 400.ms),

                const SizedBox(height: 14),

                // 4 Directional Trines (Fire, Earth, Air, Water)
                Text(
                  'திசை வாரியான கிரக அமைப்புகள் (Directional Element Trines)',
                  style: GoogleFonts.cinzel(color: AppColors.lightGold, fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _buildDirectionCard(NadiDirection.east, Colors.redAccent)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildDirectionCard(NadiDirection.south, Colors.brown.shade300)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _buildDirectionCard(NadiDirection.west, Colors.cyanAccent)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildDirectionCard(NadiDirection.north, Colors.blueAccent)),
                  ],
                ),
                const SizedBox(height: 16),

                // Primary Nadi Combinations
                Text(
                  'முக்கிய நாடி கிரக சேர்க்கைகள் & பலன்கள்',
                  style: GoogleFonts.cinzel(color: AppColors.lightGold, fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 8),
                ..._nadiResult.combinations.map((comb) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.cardSurface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.borderGold.withValues(alpha: 0.5)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.hub_rounded, color: AppColors.primaryGold, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                comb.primaryPlanetTa,
                                style: GoogleFonts.cinzel(color: AppColors.lightGold, fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primaryGold.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                comb.relationTypeTa,
                                style: GoogleFonts.outfit(fontSize: 10, color: AppColors.lightGold, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(comb.primaryRoleTa, style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary)),
                        const Divider(color: AppColors.borderGold, height: 16),
                        Text(
                          'சேர்க்கை கிரகங்கள்: ${comb.combinedPlanetsTa.isNotEmpty ? comb.combinedPlanetsTa.join(", ") : "நேரடி சேர்க்கை இல்லை"}',
                          style: GoogleFonts.outfit(color: Colors.white70, fontSize: 11.5),
                        ),
                        const SizedBox(height: 6),
                        Text(comb.predictionTa, style: GoogleFonts.poppins(color: Colors.white, fontSize: 12)),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDirectionCard(NadiDirection dir, Color color) {
    final list = _nadiResult.directionalPlanetsTa[dir] ?? [];
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundMid,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(dir.labelTa, style: GoogleFonts.cinzel(color: color, fontWeight: FontWeight.bold, fontSize: 11)),
          Text(dir.signsTa, style: GoogleFonts.outfit(fontSize: 9.5, color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          Text(
            list.isNotEmpty ? list.join('\n') : 'கிரகங்கள் இல்லை',
            style: GoogleFonts.outfit(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
