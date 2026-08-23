import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../models/horoscope_calculation_result.dart';
import '../../models/user_model.dart';
import '../../services/ashtakavarga_calculator.dart';
import '../../services/astrology_calculator.dart';
import '../../services/auth_service.dart';
import '../../widgets/astro_card.dart';
import '../../widgets/cosmic_background.dart';

class AshtakavargaScreen extends StatefulWidget {
  const AshtakavargaScreen({super.key});

  @override
  State<AshtakavargaScreen> createState() => _AshtakavargaScreenState();
}

class _AshtakavargaScreenState extends State<AshtakavargaScreen> {
  late UserModel _user;
  late HoroscopeCalculationResult _astroData;
  late AshtakavargaResult _ashtakavarga;
  String _selectedPlanet = 'SAV'; // 'SAV', 'Sun', 'Moon', 'Mars', 'Mercury', 'Jupiter', 'Venus', 'Saturn'

  static const Map<int, int> _gridIndexToRasiIndex = {
    0: 11, // Meenam
    1: 0,  // Mesham
    2: 1,  // Rishabam
    3: 2,  // Mithunam
    7: 3,  // Kadagam
    11: 4, // Simmam
    15: 5, // Kanni
    14: 6, // Thulam
    13: 7, // Viruchigam
    12: 8, // Dhanusu
    8: 9,  // Makaram
    4: 10, // Kumbam
  };

  static const Map<String, String> _planetDisplayTa = {
    'SAV': 'சர்வாஷ்ட வர்க்கம் (SAV)',
    'Sun': 'சூரியன் (Sun BAV)',
    'Moon': 'சந்திரன் (Moon BAV)',
    'Mars': 'செவ்வாய் (Mars BAV)',
    'Mercury': 'புதன் (Mercury BAV)',
    'Jupiter': 'குரு (Jupiter BAV)',
    'Venus': 'சுக்கிரன் (Venus BAV)',
    'Saturn': 'சனி (Saturn BAV)',
  };

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

    _ashtakavarga = AshtakavargaCalculator.calculateAshtakavarga(_astroData.planets);
  }

  @override
  Widget build(BuildContext context) {
    List<int> currentScores;
    if (_selectedPlanet == 'SAV') {
      currentScores = _ashtakavarga.sarvashtakavarga;
    } else {
      currentScores = _ashtakavarga.bhinnashtakavarga[_selectedPlanet] ?? List.filled(12, 0);
    }

    return Scaffold(
      body: CosmicBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Navigation Bar Header
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.lightGold),
                    ),
                    Expanded(
                      child: Text(
                        'அஷ்ட வர்க்க சக்கரம்',
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
                        'Ashtakavarga',
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
                    'பின்ன அஷ்ட வர்க்கம் & சர்வாஷ்ட வர்க்க சக்கர பலன்கள் (SAV Total: ${_ashtakavarga.totalSavPoints} Points)',
                    style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 11),
                  ),
                ).animate().fade(delay: 100.ms),

                const SizedBox(height: 16),

                // Planet Filter Tabs Horizontal Scroll
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _planetDisplayTa.keys.map((key) {
                      final isSel = _selectedPlanet == key;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedPlanet = key),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSel ? AppColors.primaryGold.withValues(alpha: 0.25) : AppColors.cardSurface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSel ? AppColors.primaryGold : Colors.white12,
                              width: isSel ? 1.5 : 0.8,
                            ),
                          ),
                          child: Text(
                            key == 'SAV' ? 'SAV (மொத்தம்)' : key,
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isSel ? AppColors.lightGold : Colors.white70,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ).animate().fade(delay: 150.ms),

                const SizedBox(height: 16),

                // Ashtakavarga South Indian Chart Card
                AstroCard(
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.grid_on_rounded, color: AppColors.primaryGold, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _planetDisplayTa[_selectedPlanet] ?? '',
                                style: GoogleFonts.cinzel(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.lightGold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        AspectRatio(
                          aspectRatio: 1,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.backgroundDeep,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.primaryGold, width: 1.5),
                            ),
                            child: Stack(
                              children: [
                                Center(
                                  child: Container(
                                    width: 100,
                                    height: 50,
                                    alignment: Alignment.center,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          _selectedPlanet == 'SAV' ? 'சர்வாஷ்டம்' : 'அஷ்டவர்க்கம்',
                                          style: GoogleFonts.cinzel(
                                            color: AppColors.primaryGold.withValues(alpha: 0.9),
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          _selectedPlanet == 'SAV' ? 'Total: 337' : _selectedPlanet,
                                          style: GoogleFonts.outfit(
                                            color: AppColors.textSecondary,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: GridView.builder(
                                    physics: const NeverScrollableScrollPhysics(),
                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 4,
                                    ),
                                    itemCount: 16,
                                    itemBuilder: (context, index) {
                                      final isCenter = (index == 5 || index == 6 || index == 9 || index == 10);
                                      if (isCenter) return const SizedBox.shrink();

                                      final rasiIdx = _gridIndexToRasiIndex[index] ?? 0;
                                      final rasiName = AstrologyCalculator.rasiNamesTa[rasiIdx];
                                      final bindu = currentScores[rasiIdx];
                                      final isLagna = _astroData.lagna.rasiIndex == rasiIdx;

                                      // High bindu threshold (SAV >= 28 or BAV >= 4)
                                      final bool isGood = _selectedPlanet == 'SAV' ? bindu >= 28 : bindu >= 4;

                                      return Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: isLagna
                                              ? AppColors.primaryGold.withValues(alpha: 0.18)
                                              : (isGood
                                                  ? Colors.green.shade900.withValues(alpha: 0.25)
                                                  : Colors.red.shade900.withValues(alpha: 0.15)),
                                          border: Border.all(
                                            color: isLagna
                                                ? AppColors.primaryGold
                                                : (isGood ? Colors.greenAccent.withValues(alpha: 0.5) : Colors.brown.shade400),
                                            width: isLagna ? 1.5 : 0.6,
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  rasiName,
                                                  style: GoogleFonts.outfit(
                                                    fontSize: 8.5,
                                                    color: AppColors.textSecondary,
                                                  ),
                                                ),
                                                if (isLagna)
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 0.5),
                                                    decoration: BoxDecoration(
                                                      color: Colors.red.shade900,
                                                      borderRadius: BorderRadius.circular(3),
                                                    ),
                                                    child: Text(
                                                      'லக்',
                                                      style: GoogleFonts.outfit(
                                                        fontSize: 7,
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            Center(
                                              child: Text(
                                                '$bindu',
                                                style: GoogleFonts.cinzel(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: isGood ? Colors.greenAccent : AppColors.lightGold,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              'பிந்து',
                                              style: GoogleFonts.outfit(fontSize: 7, color: Colors.white38),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate().fade(delay: 200.ms),

                const SizedBox(height: 20),

                // Ashtakavarga Full Bindu Table Card
                AstroCard(
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'அனைத்து கிரக பிந்து அட்டவணை (Full Ashtakavarga Matrix)',
                          style: GoogleFonts.cinzel(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.lightGold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            headingRowHeight: 34,
                            dataRowMinHeight: 30,
                            dataRowMaxHeight: 34,
                            horizontalMargin: 8,
                            columnSpacing: 12,
                            headingRowColor: WidgetStateProperty.all(AppColors.backgroundMid),
                            columns: [
                              DataColumn(label: Text('ராசி', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.lightGold, fontSize: 11))),
                              DataColumn(label: Text('சூ', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.lightGold, fontSize: 11))),
                              DataColumn(label: Text('சந்', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.lightGold, fontSize: 11))),
                              DataColumn(label: Text('செவ்', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.lightGold, fontSize: 11))),
                              DataColumn(label: Text('பு', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.lightGold, fontSize: 11))),
                              DataColumn(label: Text('குரு', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.lightGold, fontSize: 11))),
                              DataColumn(label: Text('சுக்', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.lightGold, fontSize: 11))),
                              DataColumn(label: Text('சனி', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.lightGold, fontSize: 11))),
                              DataColumn(label: Text('SAV', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.greenAccent, fontSize: 11))),
                            ],
                            rows: List.generate(12, (idx) {
                              final rasiName = AstrologyCalculator.rasiNamesTa[idx];
                              final sunB = _ashtakavarga.bhinnashtakavarga['Sun']![idx];
                              final moonB = _ashtakavarga.bhinnashtakavarga['Moon']![idx];
                              final marsB = _ashtakavarga.bhinnashtakavarga['Mars']![idx];
                              final mercB = _ashtakavarga.bhinnashtakavarga['Mercury']![idx];
                              final jupB = _ashtakavarga.bhinnashtakavarga['Jupiter']![idx];
                              final venB = _ashtakavarga.bhinnashtakavarga['Venus']![idx];
                              final satB = _ashtakavarga.bhinnashtakavarga['Saturn']![idx];
                              final savB = _ashtakavarga.sarvashtakavarga[idx];
                              final isLagna = _astroData.lagna.rasiIndex == idx;

                              return DataRow(
                                color: isLagna ? WidgetStateProperty.all(AppColors.primaryGold.withValues(alpha: 0.12)) : null,
                                cells: [
                                  DataCell(Text(rasiName, style: GoogleFonts.outfit(color: isLagna ? AppColors.lightGold : Colors.white, fontWeight: isLagna ? FontWeight.bold : FontWeight.normal, fontSize: 11))),
                                  DataCell(Text('$sunB', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 11))),
                                  DataCell(Text('$moonB', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 11))),
                                  DataCell(Text('$marsB', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 11))),
                                  DataCell(Text('$mercB', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 11))),
                                  DataCell(Text('$jupB', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 11))),
                                  DataCell(Text('$venB', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 11))),
                                  DataCell(Text('$satB', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 11))),
                                  DataCell(Text('$savB', style: GoogleFonts.outfit(color: savB >= 28 ? Colors.greenAccent : Colors.amberAccent, fontWeight: FontWeight.bold, fontSize: 11))),
                                ],
                              );
                            }),
                          ),
                        ),
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
}
