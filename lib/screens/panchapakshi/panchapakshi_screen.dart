import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../models/horoscope_calculation_result.dart';
import '../../models/user_model.dart';
import '../../services/astrology_calculator.dart';
import '../../services/auth_service.dart';
import '../../services/panchapakshi_calculator.dart';
import '../../widgets/astro_card.dart';
import '../../widgets/cosmic_background.dart';

class PanchapakshiScreen extends StatefulWidget {
  const PanchapakshiScreen({super.key});

  @override
  State<PanchapakshiScreen> createState() => _PanchapakshiScreenState();
}

class _PanchapakshiScreenState extends State<PanchapakshiScreen> {
  late UserModel _user;
  late HoroscopeCalculationResult _astroData;
  late PanchapakshiActivityResult _panchapakshiResult;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final currentUser = AuthService.currentUser;
    _user = currentUser ??
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

    _astroData = AstrologyCalculator.calculateHoroscope(
      dateOfBirth: dt,
      latitude: _user.latitude,
      longitude: _user.longitude,
      utcOffsetHours: _user.timezone,
    );

    _panchapakshiResult = PanchapakshiCalculator.calculateCurrentActivity(
      nakshatraIndex: _astroData.moon.nakshatraIndex,
      isShuklaPaksha: _astroData.tithi.isShuklaPaksha,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bird = _panchapakshiResult.bird;
    final isGood = _panchapakshiResult.isAuspicious;

    return Scaffold(
      body: CosmicBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Bar
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.lightGold),
                    ),
                    Expanded(
                      child: Text(
                        'பஞ்சபட்சி சாஸ்திரம்',
                        style: GoogleFonts.cinzel(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.lightGold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGold.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.borderGold),
                      ),
                      child: Text(
                        'Panchapakshi',
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.lightGold,
                        ),
                      ),
                    ),
                  ],
                ).animate().fade(duration: 400.ms),

                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Text(
                    'தமிழ் சித்தர்களின் பஞ்சபட்சி சாஸ்திரம் • 5 பறவைகளின் தொழில்கள் & வல்லமை',
                    style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 11),
                  ),
                ).animate().fade(delay: 100.ms),

                const SizedBox(height: 16),

                // 1. Birth Bird Banner Card
                AstroCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primaryGold.withValues(alpha: 0.15),
                            border: Border.all(color: AppColors.primaryGold, width: 1.5),
                          ),
                          alignment: Alignment.center,
                          child: Text(bird.symbol, style: const TextStyle(fontSize: 32)),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'உங்கள் ஜென்ம பட்சி: ${bird.nameTa}',
                                style: GoogleFonts.cinzel(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.lightGold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${bird.nameEn} • ${_astroData.moon.nakshatraNameTa} (${_astroData.tithi.pakshaTa})',
                                style: GoogleFonts.outfit(fontSize: 12, color: Colors.white),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                bird.description,
                                style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate().fade(delay: 150.ms),

                const SizedBox(height: 16),

                // 2. Current Live Activity Status Card
                AstroCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.flash_on_rounded, color: AppColors.primaryGold, size: 20),
                                const SizedBox(width: 6),
                                Text(
                                  'தற்போதைய பட்சி தொழில்',
                                  style: GoogleFonts.cinzel(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.lightGold,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: isGood ? Colors.green.shade900 : Colors.red.shade900,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                isGood ? 'சுப நேரம்' : 'கவனம் தேவை',
                                style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _panchapakshiResult.currentActivityTa,
                                    style: GoogleFonts.cinzel(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: isGood ? Colors.greenAccent : Colors.redAccent,
                                    ),
                                  ),
                                  Text(
                                    _panchapakshiResult.currentActivityEn,
                                    style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isGood ? Colors.green.shade900.withValues(alpha: 0.4) : Colors.red.shade900.withValues(alpha: 0.4),
                                border: Border.all(color: isGood ? Colors.greenAccent : Colors.redAccent, width: 1.5),
                              ),
                              child: Text(
                                '${_panchapakshiResult.powerPercentage}%',
                                style: GoogleFonts.outfit(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isGood ? Colors.greenAccent : Colors.redAccent,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(color: Colors.white12),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.access_time, color: AppColors.textSecondary, size: 14),
                            const SizedBox(width: 6),
                            Text(
                              'நடப்பு ஜாமம்: ${_panchapakshiResult.currentYamamIndex}வது ஜாமம் (${_panchapakshiResult.yamamTimeRange})',
                              style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ).animate().fade(delay: 200.ms),

                const SizedBox(height: 16),

                // 3. 5 Activities Reference Guide Card
                AstroCard(
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'பஞ்ச பட்சி 5 தொழில்கள் விளக்கம்',
                          style: GoogleFonts.cinzel(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.lightGold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildActivityGuideItem('1. அரசு (Ruling)', '100% வல்லமை', 'சுப காரியங்கள், புதிய ஒப்பந்தங்கள், முக்கிய முடிவுகள் எடுக்க உத்தமம்.', Colors.greenAccent),
                        _buildActivityGuideItem('2. ஊண் (Eating)', '80% வல்லமை', 'வியாபாரம், பயணம், உணவு மற்றும் மகிழ்ச்சியான நிகழ்வுகளுக்கு உகந்தது.', Colors.lightGreenAccent),
                        _buildActivityGuideItem('3. நடை (Walking)', '50% வல்லமை', 'சாதாரண அன்றாட பணிகள் மற்றும் பயணங்களுக்கு ஏற்றது.', Colors.amberAccent),
                        _buildActivityGuideItem('4. துயில் (Sleeping)', '20% வல்லமை', 'ஓய்வு எடுக்கலாம்; முக்கிய புதிய முயற்சிகளை தவிர்க்கவும்.', Colors.orangeAccent),
                        _buildActivityGuideItem('5. சாவு (Dying)', '0% வல்லமை', 'முழுமையாக தவிர்க்க வேண்டிய நேரம்; சுப காரியங்கள் செய்யக்கூடாது.', Colors.redAccent),
                      ],
                    ),
                  ),
                ).animate().fade(delay: 250.ms),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActivityGuideItem(String title, String power, String desc, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
                Text(power, style: GoogleFonts.outfit(fontSize: 10, color: AppColors.textSecondary)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 6,
            child: Text(
              desc,
              style: GoogleFonts.outfit(fontSize: 11, color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }
}
