import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../models/kp2_result.dart';

/// Cosmic Summary Header for KP Method 2
class KP2SummaryWidget extends StatelessWidget {
  final KP2Result result;
  final VoidCallback? onEditProfile;

  const KP2SummaryWidget({
    super.key,
    required this.result,
    this.onEditProfile,
  });

  @override
  Widget build(BuildContext context) {
    final birth = result.birthData;
    final dateStr = DateFormat('dd-MM-yyyy').format(birth.date);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.cardSurface,
            AppColors.backgroundMid.withValues(alpha: 0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryGold.withValues(alpha: 0.4),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGold.withValues(alpha: 0.1),
            blurRadius: 16,
            spreadRadius: 2,
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row with Edit Action
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryGold.withValues(alpha: 0.15),
                      border: Border.all(color: AppColors.primaryGold, width: 1),
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      color: AppColors.lightGold,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'KP METHOD 2',
                        style: GoogleFonts.cinzel(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.lightGold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        'துல்லிய பிளாசிடஸ் கணிதம் & அட்வான்டேஜ் விதிமுறை',
                        style: GoogleFonts.notoSansTamil(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (onEditProfile != null)
                IconButton(
                  tooltip: 'Change Profile',
                  icon: const Icon(Icons.edit_calendar_rounded, color: AppColors.primaryGold),
                  onPressed: onEditProfile,
                ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 14),

          // Profile & Coordinates Grid
          Wrap(
            spacing: 16,
            runSpacing: 12,
            children: [
              _buildInfoBadge(
                icon: Icons.calendar_today_rounded,
                label: 'பிறந்த தேதி / நேரம்',
                value: '$dateStr • ${birth.time}',
              ),
              _buildInfoBadge(
                icon: Icons.location_on_rounded,
                label: 'இடம் & அட்ச / தீர்க்கரேகை',
                value: '${birth.place} (${birth.latitude.toStringAsFixed(2)}°, ${birth.longitude.toStringAsFixed(2)}°)',
              ),
              _buildInfoBadge(
                icon: Icons.access_time_filled_rounded,
                label: 'ஜூலியன் நாள் (JD UT)',
                value: result.julianDay.toStringAsFixed(4),
              ),
              _buildInfoBadge(
                icon: Icons.explore_rounded,
                label: 'சித்ரபக்ஷ லஹரி அயனாம்சம்',
                value: result.ayanamsaDms,
                isHighlight: true,
              ),
              _buildInfoBadge(
                icon: Icons.wb_sunny_rounded,
                label: 'கிழமை நாதன் (Day Lord)',
                value: '${result.rulingPlanets.dayLord.nameTa} (${result.rulingPlanets.dayLord.nameEn})',
              ),
            ],
          ),

          const SizedBox(height: 14),
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 12),

          // Dasha Balance Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.purpleAccent.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primaryGold.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.timelapse_rounded, color: AppColors.lightGold, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    result.dashaBalance.formattedTamil,
                    style: GoogleFonts.notoSansTamil(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.lightGold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBadge({
    required IconData icon,
    required String label,
    required String value,
    bool isHighlight = false,
  }) {
    return Container(
      constraints: const BoxConstraints(minWidth: 150),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isHighlight
            ? AppColors.primaryGold.withValues(alpha: 0.12)
            : AppColors.backgroundLight.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isHighlight
              ? AppColors.primaryGold.withValues(alpha: 0.6)
              : Colors.white10,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isHighlight ? AppColors.lightGold : AppColors.primaryGold,
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: GoogleFonts.notoSansTamil(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.roboto(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isHighlight ? AppColors.lightGold : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
