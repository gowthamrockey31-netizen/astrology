import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../models/horoscope_calculation_result.dart';
import '../../models/longevity_result.dart';
import '../../models/user_model.dart';
import '../../services/astrology_calculator.dart';
import '../../services/auth_service.dart';
import '../../services/longevity_calculator.dart';
import '../../widgets/astro_card.dart';
import '../../widgets/cosmic_background.dart';

class LongevityScreen extends StatefulWidget {
  const LongevityScreen({super.key});

  @override
  State<LongevityScreen> createState() => _LongevityScreenState();
}

class _LongevityScreenState extends State<LongevityScreen> {
  late UserModel _user;
  late HoroscopeCalculationResult _astroData;
  late LongevityResult _longevityResult;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _calculateData();
  }

  void _calculateData() {
    final user = AuthService.currentUser ??
        UserModel(
          id: 'default_usr',
          name: 'Divine Seeker',
          mobile: '+919876543210',
          gender: 'Male',
          dob: '1987-03-11',
          timeOfBirth: '09:50 AM',
          placeOfBirth: 'Chinnalapatti',
          city: 'Chinnalapatti',
          state: 'Tamil Nadu',
          country: 'India',
          zodiac: 'Aries',
          nakshatra: 'Pushya',
          lagna: 'Mesha',
          walletBalance: 500.0,
          profilePhoto: '',
          latitude: 10.2785,
          longitude: 77.9244,
          timezone: 5.5,
        );

    _user = user;

    final parsedDob = DateTime.tryParse(_user.dob) ?? DateTime(1987, 3, 11);
    final tobParts = _user.timeOfBirth.split(':');
    int hour = 9;
    int minute = 50;
    if (tobParts.length >= 2) {
      hour = int.tryParse(tobParts[0].replaceAll(RegExp(r'[^0-9]'), '')) ?? 9;
      final minStr = tobParts[1].replaceAll(RegExp(r'[^0-9]'), '');
      minute = int.tryParse(minStr) ?? 50;
      if (_user.timeOfBirth.toUpperCase().contains('PM') && hour < 12) hour += 12;
      if (_user.timeOfBirth.toUpperCase().contains('AM') && hour == 12) hour = 0;
    }

    final birthDateTime = DateTime(parsedDob.year, parsedDob.month, parsedDob.day, hour, minute);

    _astroData = AstrologyCalculator.calculateHoroscope(
      dateOfBirth: birthDateTime,
      latitude: _user.latitude,
      longitude: _user.longitude,
      utcOffsetHours: _user.timezone,
    );

    _longevityResult = LongevityCalculator.calculatePindayuLongevity(
      planets: _astroData.planets,
      lagna: _astroData.lagna,
    );

    setState(() {
      _isLoading = false;
    });
  }

  Color _getCategoryColor(LongevityCategory cat) {
    switch (cat) {
      case LongevityCategory.deerghayu:
        return const Color(0xFF4CAF50); // Green
      case LongevityCategory.madhyayu:
        return AppColors.primaryGold;
      case LongevityCategory.alpayu:
        return const Color(0xFFFF5252);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CosmicBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Custom AppBar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primaryGold, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'ஆயுள் கணிதம் (Longevity / Pindayu)',
                        style: GoogleFonts.cinzel(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColors.lightGold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              if (_isLoading)
                const Expanded(child: Center(child: CircularProgressIndicator(color: AppColors.primaryGold)))
              else
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // User Profile Summary Card
                        AstroCard(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: AppColors.primaryGold.withValues(alpha: 0.2),
                                child: const Icon(Icons.person, color: AppColors.primaryGold, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(_user.name, style: GoogleFonts.cinzel(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.lightGold)),
                                    Text('DOB: ${_user.dob} ${_user.timeOfBirth} | ${_user.city}', style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(duration: 400.ms),

                        const SizedBox(height: 16),

                        // Longevity Score Hero Card
                        AstroCard(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _getCategoryColor(_longevityResult.category).withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: _getCategoryColor(_longevityResult.category), width: 1.2),
                                ),
                                child: Text(
                                  _longevityResult.categoryNameTa,
                                  style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: _getCategoryColor(_longevityResult.category),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),

                              Text(
                                'பிண்டாயுஷ் கணித ஆயுள்',
                                style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary),
                              ),
                              const SizedBox(height: 4),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    _longevityResult.finalYears.toStringAsFixed(1),
                                    style: GoogleFonts.cinzel(
                                      fontSize: 42,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryGold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'ஆண்டுகள் (Years)',
                                    style: GoogleFonts.outfit(fontSize: 14, color: AppColors.lightGold),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              const Divider(color: Colors.white12),
                              const SizedBox(height: 8),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Column(
                                    children: [
                                      Text('கிரக பலன்', style: GoogleFonts.outfit(fontSize: 10, color: AppColors.textSecondary)),
                                      Text('${_longevityResult.totalBasicYears.toStringAsFixed(1)} yrs', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Text('ஹரணக் குறைப்பு', style: GoogleFonts.outfit(fontSize: 10, color: AppColors.textSecondary)),
                                      Text('-${_longevityResult.totalReductions.toStringAsFixed(1)} yrs', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Text('லக்ன பங்களிப்பு', style: GoogleFonts.outfit(fontSize: 10, color: AppColors.textSecondary)),
                                      Text('+${_longevityResult.lagnaContribution.toStringAsFixed(2)} yrs', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.lightGold)),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ).animate().fadeIn(delay: 100.ms, duration: 400.ms),

                        const SizedBox(height: 16),

                        // Planetary Breakdown Header
                        Row(
                          children: [
                            const Icon(Icons.table_chart_rounded, color: AppColors.lightGold, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              '7 கிரக ஆயுள் பங்களிப்பு அட்டவணை',
                              style: GoogleFonts.cinzel(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.lightGold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Breakdown Table
                        AstroCard(
                          padding: const EdgeInsets.all(12),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              columnSpacing: 16,
                              headingRowHeight: 36,
                              dataRowHeight: 44,
                              columns: [
                                DataColumn(label: Text('கிரகம்', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.lightGold))),
                                DataColumn(label: Text('பாகை', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.lightGold))),
                                DataColumn(label: Text('அடிப்படை', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.lightGold))),
                                DataColumn(label: Text('பகை/அஸ்தங்கம்', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.lightGold))),
                                DataColumn(label: Text('நிகர ஆயுள்', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.lightGold))),
                              ],
                              rows: _longevityResult.planetaryBreakdown.map((item) {
                                final totalRed = item.enemyReduction + item.combustionReduction;
                                return DataRow(
                                  cells: [
                                    DataCell(Text('${item.planetNameTa} (${item.planetNameEn})', style: GoogleFonts.outfit(fontSize: 11, color: Colors.white))),
                                    DataCell(Text('${item.longitude.floor()}°', style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary))),
                                    DataCell(Text('${item.basicYears.toStringAsFixed(1)} yrs', style: GoogleFonts.outfit(fontSize: 11, color: Colors.white70))),
                                    DataCell(
                                      totalRed > 0
                                          ? Text('-${totalRed.toStringAsFixed(1)} yrs', style: GoogleFonts.outfit(fontSize: 11, color: Colors.redAccent))
                                          : Text('-', style: GoogleFonts.outfit(fontSize: 11, color: Colors.white38)),
                                    ),
                                    DataCell(Text('${item.finalYears.toStringAsFixed(1)} yrs', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryGold))),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Traditional Disclaimer Card
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade900.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.amber.shade700.withValues(alpha: 0.4)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.info_outline_rounded, color: Colors.amber, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _longevityResult.disclaimer,
                                  style: GoogleFonts.outfit(fontSize: 11, color: Colors.amber.shade200, height: 1.4),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
