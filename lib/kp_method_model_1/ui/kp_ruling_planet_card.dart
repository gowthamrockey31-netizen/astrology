import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../models/kp_ruling_planet.dart';

/// Clean card displaying the Ruling Planets in KP Astrology
class KPRulingPlanetCard extends StatelessWidget {
  final KPRulingPlanets rulingPlanets;

  const KPRulingPlanetCard({super.key, required this.rulingPlanets});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.backgroundMid,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.primaryGold.withValues(alpha: 0.3), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.star_rounded, color: AppColors.primaryGold, size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CURRENT RULING PLANETS (ஆளும் கிரகங்கள்)',
                        style: GoogleFonts.cinzel(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.lightGold,
                          letterSpacing: 1.1,
                        ),
                      ),
                      Text(
                        'Essential for Timing of Events & Birth Time Rectification',
                        style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.backgroundDeep,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.15)),
              ),
              child: Column(
                children: [
                  _buildRow('Day Lord (கிழமை அதிபதி)', rulingPlanets.dayLord, Icons.wb_sunny_outlined),
                  const Divider(color: Colors.white12, height: 16),
                  _buildRow('Moon Sign Lord (ராசி நாதன்)', rulingPlanets.moonSignLord, Icons.nightlight_round),
                  const Divider(color: Colors.white12, height: 16),
                  _buildRow('Moon Star Lord (நட்சத்திர நாதன்)', rulingPlanets.moonStarLord, Icons.auto_awesome),
                  const Divider(color: Colors.white12, height: 16),
                  _buildRow('Moon Sub Lord (உப நட்சத்திர நாதன்)', rulingPlanets.moonSubLord, Icons.tune_rounded),
                  const Divider(color: Colors.white12, height: 16),
                  _buildRow('Ascendant Sign Lord (லக்ன ராசி நாதன்)', rulingPlanets.ascendantSignLord, Icons.navigation_rounded),
                  const Divider(color: Colors.white12, height: 16),
                  _buildRow('Ascendant Star Lord (லக்ன நட்சத்திர நாதன்)', rulingPlanets.ascendantStarLord, Icons.flare_rounded),
                  const Divider(color: Colors.white12, height: 16),
                  _buildRow('Ascendant Sub Lord (லக்ன உப நாதன்)', rulingPlanets.ascendantSubLord, Icons.gps_fixed_rounded, isHighlight: true),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'UNIQUE RULING PLANETS LIST',
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.lightGold,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: rulingPlanets.uniqueRulingPlanets.map((planet) {
                return Chip(
                  backgroundColor: AppColors.primaryGold.withValues(alpha: 0.15),
                  side: BorderSide(color: AppColors.primaryGold.withValues(alpha: 0.4)),
                  avatar: const CircleAvatar(
                    backgroundColor: AppColors.primaryGold,
                    radius: 10,
                    child: Icon(Icons.check, size: 12, color: Colors.black),
                  ),
                  label: Text(
                    planet,
                    style: GoogleFonts.outfit(
                      color: AppColors.lightGold,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, IconData icon, {bool isHighlight = false}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: isHighlight ? Colors.lightGreenAccent : AppColors.lightGold),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 13,
              color: isHighlight ? Colors.lightGreenAccent : Colors.white70,
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isHighlight
                ? Colors.lightGreenAccent.withValues(alpha: 0.2)
                : AppColors.primaryGold.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isHighlight
                  ? Colors.lightGreenAccent.withValues(alpha: 0.4)
                  : AppColors.primaryGold.withValues(alpha: 0.3),
            ),
          ),
          child: Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isHighlight ? Colors.lightGreenAccent : AppColors.lightGold,
            ),
          ),
        ),
      ],
    );
  }
}
