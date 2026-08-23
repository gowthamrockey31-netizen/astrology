import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../models/tara_balam_model.dart';
import '../../services/astrology_calculator.dart';
import '../../services/auth_service.dart';
import '../../services/tara_balam_calculator.dart';
import '../../widgets/astro_card.dart';
import '../../widgets/cosmic_background.dart';
import '../../widgets/golden_button.dart';

class TaraBalamScreen extends StatefulWidget {
  const TaraBalamScreen({super.key});

  @override
  State<TaraBalamScreen> createState() => _TaraBalamScreenState();
}

class _TaraBalamScreenState extends State<TaraBalamScreen> {
  // Selected 0-indexed nakshatra indices (0..26)
  int _birthNakshatraIndex = 0; // Ashwini by default
  int _targetNakshatraIndex = 1; // Bharani by default

  TaraResult? _result;
  String? _autoFetchedInfo;

  @override
  void initState() {
    super.initState();
    _loadFromHoroscopeSilent();
    _calculateTara();
  }

  void _loadFromHoroscopeSilent() {
    final user = AuthService.currentUser;
    if (user == null) return;

    try {
      final parsedDob = DateTime.tryParse(user.dob) ?? DateTime(1996, 6, 15);
      final times = user.timeOfBirth.split(':');
      int hour = 8;
      int minute = 30;

      if (times.length >= 2) {
        hour = int.tryParse(times[0].replaceAll(RegExp(r'[^0-9]'), '')) ?? 8;
        final minParts = times[1].trim().split(' ');
        minute = int.tryParse(minParts[0].replaceAll(RegExp(r'[^0-9]'), '')) ?? 30;
        if (times[1].toUpperCase().contains('PM') && hour < 12) {
          hour += 12;
        } else if (times[1].toUpperCase().contains('AM') && hour == 12) {
          hour = 0;
        }
      }

      final birthDt = DateTime(parsedDob.year, parsedDob.month, parsedDob.day, hour, minute);
      final astroData = AstrologyCalculator.calculateHoroscope(
        dateOfBirth: birthDt,
        latitude: user.latitude,
        longitude: user.longitude,
        utcOffsetHours: user.timezone,
      );

      final PlanetDetail moon = astroData['moon'];
      setState(() {
        _birthNakshatraIndex = moon.nakshatraIndex;
        _autoFetchedInfo = '${user.name} (${moon.nakshatraNameTa})';
      });
    } catch (_) {
      // Fallback silent
    }
  }

  void _loadFromUserHoroscope() {
    final user = AuthService.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('பயனர் ஜாதகத் தகவல்கள் பெறப்படவில்லை.')),
      );
      return;
    }

    try {
      final parsedDob = DateTime.tryParse(user.dob) ?? DateTime(1996, 6, 15);
      final times = user.timeOfBirth.split(':');
      int hour = 8;
      int minute = 30;

      if (times.length >= 2) {
        hour = int.tryParse(times[0].replaceAll(RegExp(r'[^0-9]'), '')) ?? 8;
        final minParts = times[1].trim().split(' ');
        minute = int.tryParse(minParts[0].replaceAll(RegExp(r'[^0-9]'), '')) ?? 30;
        if (times[1].toUpperCase().contains('PM') && hour < 12) {
          hour += 12;
        } else if (times[1].toUpperCase().contains('AM') && hour == 12) {
          hour = 0;
        }
      }

      final birthDt = DateTime(parsedDob.year, parsedDob.month, parsedDob.day, hour, minute);
      final astroData = AstrologyCalculator.calculateHoroscope(
        dateOfBirth: birthDt,
        latitude: user.latitude,
        longitude: user.longitude,
        utcOffsetHours: user.timezone,
      );

      final PlanetDetail moon = astroData['moon'];

      setState(() {
        _birthNakshatraIndex = moon.nakshatraIndex;
        _autoFetchedInfo = '${user.name} (${moon.nakshatraNameTa})';
      });

      _calculateTara();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ஜாதகத்திலிருந்து பிறந்த நட்சத்திரம் பெறப்பட்டது: ${moon.nakshatraNameTa} (${moon.pada}-ஆம் பாதம்)'),
          backgroundColor: AppColors.backgroundMid,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ஜாதகம் கணக்கிடுவதில் பிழை: $e')),
      );
    }
  }

  void _loadCurrentTransitNakshatra() {
    try {
      final transits = AstrologyCalculator.calculateTransits();
      final PlanetDetail? moonTransit = transits['Moon'];

      final DateTime now = DateTime.now();
      final nowAstro = AstrologyCalculator.calculateHoroscope(
        dateOfBirth: now,
        latitude: 13.0827,
        longitude: 80.2707,
        utcOffsetHours: 5.5,
      );
      final PlanetDetail nowMoon = moonTransit ?? nowAstro['moon'];

      setState(() {
        _targetNakshatraIndex = nowMoon.nakshatraIndex;
      });

      _calculateTara();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('இன்றைய கோச்சார சந்திர நட்சத்திரம் அமைக்கப்பட்டது: ${nowMoon.nakshatraNameTa}'),
          backgroundColor: AppColors.backgroundMid,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('கோச்சார நிலையை கணக்கிடுவதில் பிழை: $e')),
      );
    }
  }

  void _calculateTara() {
    setState(() {
      _result = TaraBalaCalculator.calculate(
        birthNakshatra: _birthNakshatraIndex,
        currentNakshatra: _targetNakshatraIndex,
        isOneBased: false,
      );
    });
  }

  Color _getNatureColor(String nature) {
    switch (nature) {
      case 'மிகவும் நன்மை':
        return Colors.tealAccent.shade400;
      case 'நன்மை':
        return Colors.greenAccent.shade400;
      case 'சாதாரணம்':
        return Colors.amberAccent.shade200;
      case 'சிரமம்':
        return Colors.orangeAccent.shade400;
      case 'தவிர்க்க வேண்டியது':
      case 'மிகவும் சிரமம்':
        return Colors.redAccent.shade200;
      default:
        return AppColors.lightGold;
    }
  }

  IconData _getNatureIcon(String nature) {
    switch (nature) {
      case 'மிகவும் நன்மை':
      case 'நன்மை':
        return Icons.check_circle_rounded;
      case 'சாதாரணம்':
        return Icons.info_rounded;
      case 'சிரமம்':
        return Icons.warning_amber_rounded;
      case 'தவிர்க்க வேண்டியது':
      case 'மிகவும் சிரமம்':
        return Icons.cancel_rounded;
      default:
        return Icons.stars_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final stars = TaraBalaCalculator.nakshatras;

    return Scaffold(
      body: CosmicBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Navigation Header
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.lightGold),
                    ),
                    Expanded(
                      child: Text(
                        'தாரா பலன்',
                        style: GoogleFonts.cinzel(
                          fontSize: 22,
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
                        'Tara Balam',
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
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text(
                    'பிறந்த நட்சத்திரம் & நடப்பு நட்சத்திர தாரா பலன் கணிப்பு',
                    style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 12, height: 1.3),
                  ),
                ).animate().fade(delay: 100.ms),

                const SizedBox(height: 18),

                // Card Input Form
                AstroCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.stars_rounded, color: AppColors.primaryGold, size: 22),
                            const SizedBox(width: 8),
                            Text(
                              'நட்சத்திரத் தேர்வு',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.lightGold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Auto Fetch from Horoscope Button
                        OutlinedButton.icon(
                          onPressed: _loadFromUserHoroscope,
                          icon: const Icon(Icons.auto_awesome_rounded, color: AppColors.lightGold, size: 18),
                          label: Text(
                            'ஜாதகத்திலிருந்து பெறுக',
                            style: GoogleFonts.poppins(
                              color: AppColors.lightGold,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.borderGold),
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            backgroundColor: AppColors.primaryGold.withValues(alpha: 0.08),
                          ),
                        ),

                        if (_autoFetchedInfo != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            'இணைக்கப்பட்ட ஜாதகம்: $_autoFetchedInfo',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],

                        const SizedBox(height: 16),

                        // Birth Nakshatra Dropdown Header
                        Text(
                          'பிறந்த நட்சத்திரம் (மூல நட்சத்திரம்)',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundMid,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.borderGold.withValues(alpha: 0.6)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              value: _birthNakshatraIndex,
                              isExpanded: true,
                              dropdownColor: AppColors.backgroundMid,
                              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.lightGold),
                              items: List.generate(
                                stars.length,
                                (index) => DropdownMenuItem<int>(
                                  value: index,
                                  child: Text(
                                    '${index + 1}. ${stars[index]}',
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
                                  ),
                                ),
                              ),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() {
                                    _birthNakshatraIndex = val;
                                  });
                                }
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Selected/Current Nakshatra Dropdown Header with Quick Action
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'தேர்ந்தெடுக்கப்பட்ட நட்சத்திரம்',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: _loadCurrentTransitNakshatra,
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                child: Row(
                                  children: [
                                    const Icon(Icons.wb_twilight_rounded, size: 14, color: AppColors.primaryGold),
                                    const SizedBox(width: 4),
                                    Text(
                                      'இன்றைய சந்திரன்',
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primaryGold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundMid,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.borderGold.withValues(alpha: 0.6)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              value: _targetNakshatraIndex,
                              isExpanded: true,
                              dropdownColor: AppColors.backgroundMid,
                              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.lightGold),
                              items: List.generate(
                                stars.length,
                                (index) => DropdownMenuItem<int>(
                                  value: index,
                                  child: Text(
                                    '${index + 1}. ${stars[index]}',
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
                                  ),
                                ),
                              ),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() {
                                    _targetNakshatraIndex = val;
                                  });
                                }
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Calculate Button
                        GoldenButton(
                          text: 'தாரா பலன் காண்க',
                          icon: Icons.calculate_rounded,
                          onPressed: _calculateTara,
                        ),
                      ],
                    ),
                  ),
                ).animate().fade(delay: 200.ms),

                const SizedBox(height: 20),

                // Result Screen Display
                if (_result != null) ...[
                  AstroCard(
                    child: Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'தாரா பலன்',
                            style: GoogleFonts.cinzel(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.lightGold,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            height: 2,
                            width: 50,
                            color: AppColors.primaryGold,
                          ),
                          const SizedBox(height: 18),

                          // Clean Two-Column Stars Summary Container
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: AppColors.backgroundMid,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.borderGold.withValues(alpha: 0.3)),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.brightness_4_rounded, size: 16, color: AppColors.primaryGold),
                                        const SizedBox(width: 8),
                                        Text(
                                          'மூல நட்சத்திரம்:',
                                          style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 13),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      _result!.birthNakshatraName,
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(color: Colors.white12, height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.wb_sunny_rounded, size: 16, color: AppColors.primaryGold),
                                        const SizedBox(width: 8),
                                        Text(
                                          'தேர்ந்தெடுக்கப்பட்ட நட்சத்திரம்:',
                                          style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 13),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      _result!.currentNakshatraName,
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Main Tara Name Badge
                          Text(
                            'தாரா:',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _result!.taraName,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.cinzel(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: AppColors.lightGold,
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Count & Tara Number Badges
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.06),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.white12),
                                ),
                                child: Text(
                                  'தாரா எண்: ${_result!.taraNumber}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.06),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.white12),
                                ),
                                child: Text(
                                  'எண்ணிக்கை: ${_result!.count}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Nature Pill Chip
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: _getNatureColor(_result!.nature).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: _getNatureColor(_result!.nature)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getNatureIcon(_result!.nature),
                                  size: 18,
                                  color: _getNatureColor(_result!.nature),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _result!.nature,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: _getNatureColor(_result!.nature),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Detailed Result / Interpretation
                          Text(
                            'பலன்:',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.lightGold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.backgroundMid.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.borderGold.withValues(alpha: 0.3)),
                            ),
                            child: Text(
                              _result!.result,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                height: 1.5,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().scale(duration: 350.ms),
                ],

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
