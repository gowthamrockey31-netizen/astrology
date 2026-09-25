import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../models/kp4_models.dart';

/// South Indian Chart for KP Method 4
/// Combines the Rasi chart with the 12 Bhava starting cusps clearly marked in RED
class Kp4ChartWidget extends StatelessWidget {
  final KpResult result;

  const Kp4ChartWidget({
    super.key,
    required this.result,
  });

  /// Standard South Indian 4x4 Grid index -> Zodiac Rasi index (0..11)
  static const Map<int, int> _gridIndexToRasiIndex = {
    0: 11, // Meenam (Pisces)
    1: 0,  // Mesham (Aries)
    2: 1,  // Rishabam (Taurus)
    3: 2,  // Mithunam (Gemini)
    7: 3,  // Kadagam (Cancer)
    11: 4, // Simmam (Leo)
    15: 5, // Kanni (Virgo)
    14: 6, // Thulam (Libra)
    13: 7, // Viruchigam (Scorpio)
    12: 8, // Dhanusu (Sagittarius)
    8: 9,  // Makaram (Capricorn)
    4: 10, // Kumbam (Aquarius)
  };

  static const List<String> _rasiNamesTa = [
    'மேஷம்', 'ரிஷபம்', 'மிதுனம்', 'கடகம்',
    'சிம்மம்', 'கன்னி', 'துலாம்', 'விருச்சிகம்',
    'தனுசு', 'மகரம்', 'கும்பம்', 'மீனம்',
  ];

  static const List<String> _rasiNamesEn = [
    'Aries', 'Taurus', 'Gemini', 'Cancer',
    'Leo', 'Virgo', 'Libra', 'Scorpio',
    'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces',
  ];

  static const Map<String, String> _planetShortTa = {
    'Sun': 'சூரி',
    'Moon': 'சந்',
    'Mars': 'செவ்',
    'Mercury': 'புத',
    'Jupiter': 'குரு',
    'Venus': 'சுக்',
    'Saturn': 'சனி',
    'Rahu': 'ராகு',
    'Ketu': 'கேது',
  };

  @override
  Widget build(BuildContext context) {
    // Map planets to sign index (0..11)
    final Map<int, List<PlanetPosition>> signPlanets = {};
    for (final p in result.planetPositions) {
      signPlanets.putIfAbsent(p.signIndex, () => []).add(p);
    }

    // Map 12 Bhava cusps to sign index (0..11)
    final Map<int, List<CuspPosition>> signCusps = {};
    for (final c in result.cuspPositions) {
      signCusps.putIfAbsent(c.signIndex, () => []).add(c);
    }

    // Ascendant sign
    final ascSignIdx = (result.ascendantDegree / 30.0).floor().clamp(0, 11);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGold.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.grid_view_rounded, color: AppColors.primaryGold, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'ராசி & பாவ ஆரம்ப முனைகள்',
                    style: GoogleFonts.cinzel(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.lightGold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.redAccent.withValues(alpha: 0.6)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '12 Cusps in RED',
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Part 1: Rasi chart combined with 12 Placidus starting cusps (சிவப்பு நிறத்தில் பாவ ஆரம்ப முனைகள்)',
            style: GoogleFonts.outfit(
              fontSize: 11.5,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),

          // 4x4 South Indian Grid
          AspectRatio(
            aspectRatio: 1.0,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.backgroundDeep,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primaryGold, width: 1.5),
              ),
              child: Stack(
                children: [
                  GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                    ),
                    itemCount: 16,
                    itemBuilder: (context, index) {
                      final isCenter = (index == 5 || index == 6 || index == 9 || index == 10);
                      if (isCenter) {
                        return const SizedBox.shrink();
                      }

                      final rasiIdx = _gridIndexToRasiIndex[index] ?? 0;
                      final rasiTa = _rasiNamesTa[rasiIdx];
                      final rasiEn = _rasiNamesEn[rasiIdx];
                      final planets = signPlanets[rasiIdx] ?? [];
                      final cusps = signCusps[rasiIdx] ?? [];
                      final isAscendantSign = (rasiIdx == ascSignIdx);

                      return _buildSignCell(
                        rasiIdx: rasiIdx,
                        rasiTa: rasiTa,
                        rasiEn: rasiEn,
                        planets: planets,
                        cusps: cusps,
                        isAscendantSign: isAscendantSign,
                      );
                    },
                  ),

                  // Center 2x2 Info Area
                  Center(
                    child: FractionallySizedBox(
                      widthFactor: 0.5,
                      heightFactor: 0.5,
                      child: Container(
                        margin: const EdgeInsets.all(3),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundMid.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.borderGold.withValues(alpha: 0.6),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'KP METHOD 4',
                              style: GoogleFonts.cinzel(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryGold,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'ராசி & பாவ தொடக்கம்',
                              style: GoogleFonts.outfit(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.lightGold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              height: 1,
                              width: 60,
                              color: AppColors.primaryGold.withValues(alpha: 0.3),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'லக்னம்: ${result.ascendantSignTa} ${result.ascendantDegreeStr}',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.outfit(
                                fontSize: 10,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'KP Ayanamsa: ${result.ayanamsaStr}',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.outfit(
                                fontSize: 9.5,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: Colors.redAccent,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'C1..C12 = பாவம்',
                                  style: GoogleFonts.outfit(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.redAccent,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignCell({
    required int rasiIdx,
    required String rasiTa,
    required String rasiEn,
    required List<PlanetPosition> planets,
    required List<CuspPosition> cusps,
    required bool isAscendantSign,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isAscendantSign
            ? AppColors.primaryGold.withValues(alpha: 0.12)
            : AppColors.cardSurface.withValues(alpha: 0.6),
        border: Border.all(
          color: isAscendantSign
              ? AppColors.primaryGold
              : AppColors.borderGold.withValues(alpha: 0.3),
          width: 0.7,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Sign Title Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  rasiTa,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(
                    fontSize: 8.5,
                    fontWeight: FontWeight.bold,
                    color: isAscendantSign ? AppColors.lightGold : AppColors.textSecondary,
                  ),
                ),
              ),
              if (isAscendantSign)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 0.5),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGold,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    'லக்',
                    style: GoogleFonts.outfit(
                      fontSize: 7.5,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 2),

          // RED Cusp Indicators (Part 1 Core Requirement)
          if (cusps.isNotEmpty)
            Wrap(
              spacing: 2,
              runSpacing: 2,
              children: cusps.map((c) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.redAccent, width: 0.8),
                  ),
                  child: Text(
                    'C${c.cuspNumber} ${c.degreeInRasi.toStringAsFixed(1)}°',
                    style: GoogleFonts.outfit(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                    ),
                  ),
                );
              }).toList(),
            ),

          const Spacer(),

          // Planets in this Sign
          if (planets.isNotEmpty)
            Wrap(
              spacing: 2,
              runSpacing: 1.5,
              children: planets.map((p) {
                final shortName = _planetShortTa[p.planet] ?? p.planet;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 2.5, vertical: 0.5),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundDeep.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(3),
                    border: Border.all(
                      color: p.isRetrograde
                          ? Colors.orangeAccent.withValues(alpha: 0.6)
                          : AppColors.primaryGold.withValues(alpha: 0.3),
                      width: 0.5,
                    ),
                  ),
                  child: Text(
                    '${p.isRetrograde ? "Ⓞ" : ""}$shortName',
                    style: GoogleFonts.outfit(
                      fontSize: 8,
                      fontWeight: FontWeight.w600,
                      color: p.isRetrograde ? Colors.orangeAccent : AppColors.lightGold,
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}
