import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../models/bnn_models.dart';
import '../../models/horoscope_calculation_result.dart';
import '../../models/user_model.dart';
import '../../services/astrology_calculator.dart';
import '../../services/auth_service.dart';
import '../../services/bnn_engine.dart';
import '../../widgets/astro_card.dart';
import '../../widgets/cosmic_background.dart';

/// Module Screen: பிருகு நந்தி நாடி முறை (Bhrigu Nandi Nadi / BNN Method)
class BhriguNandiNadiScreen extends StatefulWidget {
  const BhriguNandiNadiScreen({super.key});

  @override
  State<BhriguNandiNadiScreen> createState() => _BhriguNandiNadiScreenState();
}

class _BhriguNandiNadiScreenState extends State<BhriguNandiNadiScreen> {
  late UserModel _user;
  late HoroscopeCalculationResult _astroData;
  late List<BnnPlanetPosition> _allBnnPlanets;
  late Map<String, BnnPlanetAnalysis> _allAnalysis;

  String _selectedPlanetKey = 'Jupiter'; // Default to Jeeva Karaka Jupiter (குரு)

  @override
  void initState() {
    super.initState();
    _loadAndCalculateData();
  }

  void _loadAndCalculateData() {
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

    final birthDt = DateTime(parsedDob.year, parsedDob.month, parsedDob.day, hour, minute);

    // Consume accurate authoritative Birth Chart planetary positions
    _astroData = AstrologyCalculator.calculateHoroscope(
      dateOfBirth: birthDt,
      latitude: _user.latitude,
      longitude: _user.longitude,
      utcOffsetHours: _user.timezone,
    );

    // Normalize planetary data into BNN models
    _allBnnPlanets = BnnEngine.normalizePlanets(_astroData.planets);

    // Perform BNN analysis across all planets
    _allAnalysis = BnnEngine.analyzeAllPlanets(_allBnnPlanets);
  }

  @override
  Widget build(BuildContext context) {
    final currentAnalysis = _allAnalysis[_selectedPlanetKey];
    final selectedPlanet = _allBnnPlanets.firstWhere(
      (p) => p.planetKey == _selectedPlanetKey,
      orElse: () => _allBnnPlanets.first,
    );

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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'பிருகு நந்தி நாடி முறை',
                            style: GoogleFonts.cinzel(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              color: AppColors.lightGold,
                              letterSpacing: 1.1,
                            ),
                          ),
                          Text(
                            '${_user.name} • ${_user.dob} • BNN Method',
                            style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
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
                        'BNN Engine',
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.lightGold,
                        ),
                      ),
                    ),
                  ],
                ).animate().fade(duration: 350.ms),

                const SizedBox(height: 12),

                // Main Planet Selector Header
                Text(
                  'முக்கிய கிரகம் (Select Primary Planet)',
                  style: GoogleFonts.cinzel(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.lightGold,
                  ),
                ),
                const SizedBox(height: 8),

                // Horizontal Planet Selector Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: _allBnnPlanets.map((p) {
                      final isSel = p.planetKey == _selectedPlanetKey;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(
                            '${p.tamilName} (${p.englishName})',
                            style: GoogleFonts.outfit(
                              fontSize: 11.5,
                              fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                              color: isSel ? Colors.black : AppColors.lightGold,
                            ),
                          ),
                          selected: isSel,
                          selectedColor: AppColors.primaryGold,
                          backgroundColor: AppColors.backgroundMid,
                          side: BorderSide(
                            color: isSel ? AppColors.primaryGold : AppColors.borderGold.withValues(alpha: 0.4),
                          ),
                          onSelected: (val) {
                            if (val) {
                              setState(() => _selectedPlanetKey = p.planetKey);
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 14),

                // Selected Planet Focus Card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.cardSurface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.primaryGold, width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryGold.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.auto_awesome_rounded, color: AppColors.primaryGold, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            selectedPlanet.tamilName,
                            style: GoogleFonts.cinzel(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.lightGold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '(${selectedPlanet.englishName})',
                            style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 12),
                          ),
                          const Spacer(),
                          if (selectedPlanet.isRetrograde)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.cyan.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.cyanAccent),
                              ),
                              child: Text(
                                'வக்ரம் (Retrograde)',
                                style: GoogleFonts.outfit(color: Colors.cyanAccent, fontSize: 9.5, fontWeight: FontWeight.bold),
                              ),
                            ),
                        ],
                      ),
                      const Divider(color: AppColors.borderGold, height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoMetric(
                              label: 'அமர்ந்த ராசி',
                              val: '${selectedPlanet.signNameTa} (${selectedPlanet.signNumber}-ஆம் ராசி)',
                            ),
                          ),
                          Expanded(
                            child: _buildInfoMetric(
                              label: 'ராசி பாகை',
                              val: selectedPlanet.formattedDegree,
                            ),
                          ),
                          Expanded(
                            child: _buildInfoMetric(
                              label: 'முழு பாகை (0°-360°)',
                              val: '${selectedPlanet.absoluteLongitude.toStringAsFixed(2)}°',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ).animate().fade(duration: 300.ms),

                const SizedBox(height: 18),

                // 4 BNN Relation Groups
                if (currentAnalysis != null) ...[
                  _buildRelationCard(currentAnalysis.trine159, Icons.change_history_rounded, Colors.amberAccent),
                  const SizedBox(height: 14),
                  _buildRelationCard(currentAnalysis.upachaya311, Icons.trending_up_rounded, Colors.greenAccent),
                  const SizedBox(height: 14),
                  _buildRelationCard(currentAnalysis.seventh7, Icons.compare_arrows_rounded, Colors.purpleAccent),
                  const SizedBox(height: 14),
                  _buildRelationCard(currentAnalysis.secondTwelfth212, Icons.account_balance_wallet_rounded, Colors.orangeAccent),
                ],

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoMetric({required String label, required String val}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.outfit(fontSize: 10, color: AppColors.textSecondary)),
        const SizedBox(height: 2),
        Text(val, style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
      ],
    );
  }

  Widget _buildRelationCard(BnnRelationResult relation, IconData icon, Color accentColor) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accentColor.withValues(alpha: 0.5), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Title & Related Signs
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: accentColor, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        relation.relationTitleTa,
                        style: GoogleFonts.cinzel(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.lightGold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'தொடர்பு ராசிகள்: ${relation.relatedSignNamesTa.join(' • ')} (ராசி ${relation.relatedSigns.join(', ')})',
                        style: GoogleFonts.outfit(fontSize: 10.5, color: accentColor),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: relation.hasRelatedPlanets
                        ? Colors.green.withValues(alpha: 0.2)
                        : Colors.white10,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: relation.hasRelatedPlanets ? Colors.greenAccent : Colors.white24,
                    ),
                  ),
                  child: Text(
                    relation.hasRelatedPlanets
                        ? '${relation.relatedPlanets.length} கிரகங்கள்'
                        : 'கிரகங்கள் இல்லை',
                    style: GoogleFonts.outfit(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: relation.hasRelatedPlanets ? Colors.greenAccent : Colors.white60,
                    ),
                  ),
                ),
              ],
            ),

            const Divider(color: AppColors.borderGold, height: 18),

            // Related Planets List
            if (!relation.hasRelatedPlanets)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, color: AppColors.textSecondary, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'இந்த தொடர்பில் கிரகங்கள் இல்லை.',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'தொடர்புடைய கிரகங்கள் (Degree Ascending):',
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.lightGold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ...relation.relatedPlanets.asMap().entries.map((entry) {
                    final idx = entry.key + 1;
                    final planet = entry.value;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundMid,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primaryGold.withValues(alpha: 0.2),
                              border: Border.all(color: AppColors.primaryGold, width: 1),
                            ),
                            child: Text(
                              '$idx',
                              style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.lightGold),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            planet.tamilName,
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '(${planet.englishName})',
                            style: GoogleFonts.outfit(fontSize: 10.5, color: AppColors.textSecondary),
                          ),
                          const Spacer(),
                          Text(
                            '${planet.signNameTa} – ${planet.formattedDegree}',
                            style: GoogleFonts.outfit(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: accentColor,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),

            const SizedBox(height: 10),

            // Palan / Prediction Interpretation Box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.backgroundDeep,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.35)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.psychology_rounded, color: AppColors.primaryGold, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'நாடி பலன் (BNN Interpretation):',
                        style: GoogleFonts.cinzel(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryGold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    relation.interpretationTa,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.9),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
