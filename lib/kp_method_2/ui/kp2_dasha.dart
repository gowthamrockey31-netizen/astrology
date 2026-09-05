import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../models/kp2_dasha.dart';

/// Cosmic Vimshottari Dasha Tree View for KP Method 2
class KP2DashaWidget extends StatelessWidget {
  final KP2DashaBalance dashaBalance;
  final List<KP2DashaPeriod> dashaTimeline;

  const KP2DashaWidget({
    super.key,
    required this.dashaBalance,
    required this.dashaTimeline,
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
              const Icon(Icons.timeline_rounded, color: AppColors.primaryGold, size: 20),
              const SizedBox(width: 8),
              Text(
                'விம்சோத்தரி தசா இருப்பு & காலங்கள்',
                style: GoogleFonts.cinzel(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.lightGold,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Dasha Balance Card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryGold.withValues(alpha: 0.2),
                  AppColors.purpleAccent.withValues(alpha: 0.25),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: AppColors.primaryGold,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    dashaBalance.lord.symbol,
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'பிறந்த நேர தசா இருப்பு (Birth Balance):',
                        style: GoogleFonts.notoSansTamil(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        dashaBalance.formattedTamil,
                        style: GoogleFonts.notoSansTamil(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.lightGold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Mahadasha List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: dashaTimeline.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final maha = dashaTimeline[index];
              return _buildMahaTile(maha);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMahaTile(KP2DashaPeriod maha) {
    final isActive = maha.isActive;

    return Container(
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.purpleAccent.withValues(alpha: 0.2)
            : AppColors.backgroundLight.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? AppColors.primaryGold : Colors.white10,
          width: isActive ? 1.5 : 1,
        ),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: Theme(
          data: ThemeData(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            leading: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primaryGold : Colors.white12,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                maha.lord.symbol,
                style: TextStyle(
                  color: isActive ? AppColors.textDark : AppColors.lightGold,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            title: Row(
              children: [
                Text(
                  '${maha.lord.nameTa} தசா (${maha.lord.nameEn})',
                  style: GoogleFonts.notoSansTamil(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isActive ? AppColors.lightGold : AppColors.textPrimary,
                  ),
                ),
                if (isActive) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGold,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'நடப்பு தசா',
                      style: GoogleFonts.notoSansTamil(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            subtitle: Text(
              maha.dateRangeFormatted,
              style: GoogleFonts.robotoMono(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                color: Colors.black12,
                child: Column(
                  children: maha.subPeriods.map((bhukti) {
                    return _buildBhuktiTile(bhukti);
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBhuktiTile(KP2DashaPeriod bhukti) {
    final isActive = bhukti.isActive;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Material(
        type: MaterialType.transparency,
        child: Theme(
          data: ThemeData(dividerColor: Colors.transparent),
          child: ExpansionTile(
            dense: true,
            tilePadding: const EdgeInsets.symmetric(horizontal: 8),
            leading: Text(
              bhukti.lord.symbol,
              style: TextStyle(
                color: isActive ? AppColors.primaryGold : Colors.white60,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
            title: Row(
              children: [
                Text(
                  '${bhukti.lord.nameTa} புக்தி',
                  style: GoogleFonts.notoSansTamil(
                    fontSize: 12,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    color: isActive ? AppColors.lightGold : AppColors.textPrimary,
                  ),
                ),
                if (isActive) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGold.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: const Text(
                      'நடப்பு புக்தி',
                      style: TextStyle(
                        fontSize: 9,
                        color: AppColors.lightGold,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            trailing: Text(
              bhukti.dateRangeFormatted,
              style: GoogleFonts.robotoMono(
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
            ),
            children: bhukti.subPeriods.map((antara) {
              return _buildAntaraRow(antara);
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildAntaraRow(KP2DashaPeriod antara) {
    final isActive = antara.isActive;

    return Padding(
      padding: const EdgeInsets.only(left: 32, right: 8, top: 3, bottom: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                '• ${antara.lord.nameTa} அந்தரம்',
                style: GoogleFonts.notoSansTamil(
                  fontSize: 11,
                  color: isActive ? AppColors.lightGold : AppColors.textSecondary,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              if (isActive) ...[
                const SizedBox(width: 4),
                const Icon(Icons.check_circle_outline, size: 12, color: AppColors.lightGold),
              ],
            ],
          ),
          Text(
            antara.dateRangeFormatted,
            style: GoogleFonts.robotoMono(
              fontSize: 9.5,
              color: isActive ? AppColors.lightGold : Colors.white38,
            ),
          ),
        ],
      ),
    );
  }
}
