import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../models/kp2_planet.dart';
import '../models/kp2_ruling_planet.dart';

/// Cosmic Ruling Planets Card and Deduplicated List for KP Method 2
class KP2RulingPlanetsWidget extends StatelessWidget {
  final KP2RulingPlanets rulingPlanets;

  const KP2RulingPlanetsWidget({
    super.key,
    required this.rulingPlanets,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryGold.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.stars_rounded, color: AppColors.primaryGold, size: 20),
              const SizedBox(width: 8),
              Text(
                'ஆளும் கிரகங்கள் (KP Ruling Planets)',
                style: GoogleFonts.cinzel(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.lightGold,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Day Lord
          _buildRulingRow(
            icon: Icons.calendar_month_rounded,
            title: 'கிழமை நாதன் (Day Lord)',
            planet: rulingPlanets.dayLord,
            color: Colors.amber,
          ),
          const SizedBox(height: 14),

          // 1. Transit Ascendant — Five Ruling Planets
          Text(
            'லக்ன ஆளும் கிரகங்கள் (Transit Ascendant - 5 Ruling Planets):',
            style: GoogleFonts.notoSansTamil(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.lightGold,
            ),
          ),
          const SizedBox(height: 8),
          _buildRulingRow(
            icon: Icons.accessibility_new_rounded,
            title: '1. லக்னம் நின்ற ராசி நாதன் (Ascendant Sign Lord)',
            planet: rulingPlanets.ascSignLord,
            color: Colors.tealAccent,
          ),
          const SizedBox(height: 8),
          _buildRulingRow(
            icon: Icons.star_rounded,
            title: '2. லக்னம் நின்ற நட்சத்திர நாதன் (Ascendant Star Lord)',
            planet: rulingPlanets.ascStarLord,
            color: Colors.purpleAccent,
          ),
          const SizedBox(height: 8),
          _buildRulingRow(
            icon: Icons.filter_tilt_shift_rounded,
            title: '3. லக்னம் நின்ற உப நாதன் (Ascendant Sub Lord)',
            planet: rulingPlanets.ascSubLord,
            color: Colors.orangeAccent,
          ),
          const SizedBox(height: 8),
          _buildRulingRow(
            icon: Icons.lens_blur_rounded,
            title: '4. லக்னம் நின்ற உப-உப நாதன் (Ascendant Sub-Sub Lord)',
            planet: rulingPlanets.ascSubSubLord,
            color: Colors.deepOrangeAccent,
          ),
          const SizedBox(height: 8),
          _buildRulingRow(
            icon: Icons.grain_rounded,
            title: '5. லக்னம் நின்ற உப-உப-உப நாதன் (Ascendant Sub-Sub-Sub Lord)',
            planet: rulingPlanets.ascSubSubSubLord,
            color: Colors.amberAccent,
          ),

          const SizedBox(height: 14),

          // 2. Transit Moon — Five Ruling Planets
          Text(
            'சந்திர ஆளும் கிரகங்கள் (Transit Moon - 5 Ruling Planets):',
            style: GoogleFonts.notoSansTamil(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.lightGold,
            ),
          ),
          const SizedBox(height: 8),
          _buildRulingRow(
            icon: Icons.nightlight_round,
            title: '1. சந்திரன் நின்ற ராசி நாதன் (Moon Sign Lord)',
            planet: rulingPlanets.moonSignLord,
            color: Colors.lightBlueAccent,
          ),
          const SizedBox(height: 8),
          _buildRulingRow(
            icon: Icons.star_border_rounded,
            title: '2. சந்திரன் நின்ற நட்சத்திர நாதன் (Moon Star Lord)',
            planet: rulingPlanets.moonStarLord,
            color: Colors.cyanAccent,
          ),
          const SizedBox(height: 8),
          _buildRulingRow(
            icon: Icons.subdirectory_arrow_right_rounded,
            title: '3. சந்திரன் நின்ற உப நாதன் (Moon Sub Lord)',
            planet: rulingPlanets.moonSubLord,
            color: AppColors.primaryGold,
          ),
          const SizedBox(height: 8),
          _buildRulingRow(
            icon: Icons.fiber_manual_record_rounded,
            title: '4. சந்திரன் நின்ற உப-உப நாதன் (Moon Sub-Sub Lord)',
            planet: rulingPlanets.moonSubSubLord,
            color: Colors.pinkAccent,
          ),
          const SizedBox(height: 8),
          _buildRulingRow(
            icon: Icons.blur_on_rounded,
            title: '5. சந்திரன் நின்ற உப-உப-உப நாதன் (Moon Sub-Sub-Sub Lord)',
            planet: rulingPlanets.moonSubSubSubLord,
            color: Colors.greenAccent,
          ),

          const SizedBox(height: 18),
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 16),

          // Deduplicated Unique Ruling Planets
          Text(
            'தனித்துவமான ஆளும் கிரகங்கள் (Unique Deduplicated Ruling Planets):',
            style: GoogleFonts.notoSansTamil(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.lightGold,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: rulingPlanets.uniquePlanets.map((planet) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryGold.withValues(alpha: 0.25),
                      AppColors.purpleAccent.withValues(alpha: 0.3),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primaryGold.withValues(alpha: 0.6),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryGold.withValues(alpha: 0.15),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.primaryGold,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        planet.symbol,
                        style: const TextStyle(
                          color: AppColors.textDark,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      planet.nameTa,
                      style: GoogleFonts.notoSansTamil(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.lightGold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '(${planet.nameEn})',
                      style: GoogleFonts.roboto(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRulingRow({
    required IconData icon,
    required String title,
    required KP2Planet planet,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white10, width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.notoSansTamil(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  planet.symbol,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  planet.nameTa,
                  style: GoogleFonts.notoSansTamil(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
