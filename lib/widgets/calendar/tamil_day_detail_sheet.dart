import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../models/tamil_calendar_models.dart';

/// Rich Modal Bottom Sheet displaying comprehensive Panchanga details for the selected day
class TamilDayDetailSheet extends StatelessWidget {
  final CalendarDay dayData;
  final VoidCallback? onOpenFullDayView;

  const TamilDayDetailSheet({
    super.key,
    required this.dayData,
    this.onOpenFullDayView,
  });

  static void show(BuildContext context, CalendarDay dayData, {VoidCallback? onOpenFullDayView}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => TamilDayDetailSheet(
        dayData: dayData,
        onOpenFullDayView: onOpenFullDayView,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formattedGregorian = DateFormat('dd MMMM yyyy (EEEE)').format(dayData.date);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: const BoxDecoration(
        color: AppColors.backgroundDeep,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: AppColors.borderGold, width: 1.5),
          left: BorderSide(color: AppColors.borderGold, width: 0.5),
          right: BorderSide(color: AppColors.borderGold, width: 0.5),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10, bottom: 8),
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderGold.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Content Scrollable
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Header Banner: Tamil Date Prominent
                  _buildHeaderBanner(formattedGregorian),

                  const SizedBox(height: 14),

                  // 2. Special Badges (Government Holiday / Festivals / Muhurtham)
                  if (dayData.isGovernmentHoliday || dayData.hasFestival || dayData.isMuhurtham)
                    _buildSpecialBadgesSection(),

                  // 3. Panchanga Section (திதி, நட்சத்திரம், பாதம், யோகம், கரணம், வாரம்)
                  _buildPanchangaSection(),

                  const SizedBox(height: 14),

                  // 4. Important Timings (சூரிய உதயம், அஸ்தமனம், ராகு, எமகண்டம், குளிகை, அபிஜித், etc.)
                  _buildTimingsSection(),

                  const SizedBox(height: 14),

                  // 5. Additional Astrological Insights (நோக்கு நாள், சந்திராஷ்டமம், சூலம்/பரிகாரம்)
                  _buildInsightsSection(),

                  if (onOpenFullDayView != null) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          onOpenFullDayView!();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGold,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.calendar_view_day_rounded, size: 18),
                        label: Text(
                          'முழு தினசரி பஞ்சாங்கம் காண்க (Full Daily Panchangam)',
                          style: GoogleFonts.cinzel(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderBanner(String formattedGregorian) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryGold.withValues(alpha: 0.2),
            AppColors.cardSurface,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGold.withValues(alpha: 0.7)),
      ),
      child: Row(
        children: [
          // Tamil Date Circle
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryGold.withValues(alpha: 0.15),
              border: Border.all(color: AppColors.primaryGold, width: 1.5),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${dayData.tamilDay}',
                    style: GoogleFonts.cinzel(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.lightGold,
                      height: 1.0,
                    ),
                  ),
                  Text(
                    dayData.tamilMonth,
                    style: GoogleFonts.outfit(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                      height: 1.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Month, Year, Gregorian Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${dayData.tamilYearName} வருடம் • ${dayData.tamilMonth} மாதம்',
                  style: GoogleFonts.cinzel(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.lightGold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  formattedGregorian,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'இடம்: ${dayData.location.city}',
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialBadgesSection() {
    return Column(
      children: [
        if (dayData.isGovernmentHoliday)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.redAccent.withValues(alpha: 0.6)),
            ),
            child: Row(
              children: [
                const Text('🏛️', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'அரசு விடுமுறை: ${dayData.governmentHoliday!.nameTa} (${dayData.governmentHoliday!.nameEn})',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade200,
                    ),
                  ),
                ),
              ],
            ),
          ),

        if (dayData.hasFestival)
          ...dayData.festivals.map(
            (f) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.purple.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.purpleAccent.withValues(alpha: 0.6)),
              ),
              child: Row(
                children: [
                  const Text('🎉', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'பண்டிகை / விசேஷம்: ${f.nameTa} (${f.category.labelTa})',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple.shade200,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

        if (dayData.isMuhurtham)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.amberAccent.withValues(alpha: 0.6)),
            ),
            child: Row(
              children: [
                const Text('💍', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'சுப முகூர்த்த நாள் (Auspicious Wedding / Event Muhurtham Day)',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber.shade200,
                    ),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 6),
      ],
    );
  }

  Widget _buildPanchangaSection() {
    return _buildCard(
      title: 'பஞ்சாங்க விவரங்கள் (Panchangam)',
      icon: Icons.auto_awesome_rounded,
      accentColor: AppColors.primaryGold,
      child: Column(
        children: [
          _buildDetailRow('வாரம் / கிழமை', '${dayData.weekdayTa} (${dayData.weekdayEn})'),
          const Divider(color: Colors.white10, height: 14),
          _buildDetailRow('திதி', '${dayData.thithi} (${dayData.pakshaTa})'),
          const Divider(color: Colors.white10, height: 14),
          _buildDetailRow(
            'நட்சத்திரம் & பாதம்',
            '${dayData.nakshatra} (${dayData.nakshatraPada}-ஆம் பாதம்) • அதிபதி: ${dayData.nakshatraLord}',
          ),
          const Divider(color: Colors.white10, height: 14),
          _buildDetailRow('யோகம்', dayData.yoga),
          const Divider(color: Colors.white10, height: 14),
          _buildDetailRow('அமிர்தாதி யோகம்', dayData.amirthathiYoga, highlight: true),
          const Divider(color: Colors.white10, height: 14),
          _buildDetailRow('கரணம்', dayData.karana),
        ],
      ),
    );
  }

  Widget _buildTimingsSection() {
    return _buildCard(
      title: 'முக்கிய நேரங்கள் & காலங்கள் (Timings)',
      icon: Icons.access_time_filled_rounded,
      accentColor: Colors.amberAccent,
      child: Column(
        children: [
          // Sunrise / Sunset
          Row(
            children: [
              Expanded(child: _buildTimingBadge('சூரிய உதயம்', dayData.sunrise, Icons.wb_sunny_rounded, Colors.amberAccent)),
              const SizedBox(width: 8),
              Expanded(child: _buildTimingBadge('சூரிய அஸ்தமனம்', dayData.sunset, Icons.wb_twilight_rounded, Colors.orangeAccent)),
            ],
          ),
          const SizedBox(height: 8),
          // Rahu / Gulikai
          Row(
            children: [
              Expanded(child: _buildTimingBadge('ராகு காலம்', dayData.rahuKalam, Icons.warning_amber_rounded, Colors.redAccent)),
              const SizedBox(width: 8),
              Expanded(child: _buildTimingBadge('குளிகை காலம்', dayData.kuligai, Icons.hourglass_bottom_rounded, Colors.tealAccent)),
            ],
          ),
          const SizedBox(height: 8),
          // Yamagandam / Abhijit
          Row(
            children: [
              Expanded(child: _buildTimingBadge('எமகண்டம்', dayData.yemakandam, Icons.cancel_outlined, Colors.redAccent)),
              const SizedBox(width: 8),
              Expanded(child: _buildTimingBadge('அபிஜித் முகூர்த்தம்', dayData.abhijit, Icons.star_rounded, Colors.greenAccent)),
            ],
          ),
          const SizedBox(height: 8),
          // Durmuhurtham / Varjyam / Amrit Kalam
          Row(
            children: [
              Expanded(child: _buildTimingBadge('துர்முஹூர்த்தம்', dayData.durMuhurtham, Icons.block_rounded, Colors.orangeAccent)),
              const SizedBox(width: 8),
              Expanded(child: _buildTimingBadge('வர்ஜ்யம்', dayData.varjyam, Icons.do_not_disturb_on_total_silence_rounded, Colors.deepOrangeAccent)),
            ],
          ),
          const SizedBox(height: 8),
          _buildTimingBadge('அமிர்த காலம்', dayData.amritKalam, Icons.favorite_rounded, Colors.pinkAccent),
        ],
      ),
    );
  }

  Widget _buildInsightsSection() {
    return _buildCard(
      title: 'நோக்கு நாள் & பிற விவரங்கள்',
      icon: Icons.visibility_rounded,
      accentColor: Colors.cyanAccent,
      child: Column(
        children: [
          _buildDetailRow(
            'நோக்கு நாள்',
            '${dayData.nokkuDinam.symbol} ${dayData.nokkuDinam.nameTa} (${dayData.nokkuDinam.nameEn})',
            highlight: true,
          ),
          const Divider(color: Colors.white10, height: 14),
          _buildDetailRow('சந்திராஷ்டம ராசி', '${dayData.chandrashtamaRasi} ராசி'),
          const Divider(color: Colors.white10, height: 14),
          _buildDetailRow('சூலம் திசை', dayData.soolamDirection),
          const Divider(color: Colors.white10, height: 14),
          _buildDetailRow('பரிகாரம்', dayData.pariharam),
        ],
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required Color accentColor,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGold.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: accentColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.cinzel(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.lightGold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool highlight = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: highlight ? Colors.amberAccent : Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimingBadge(String label, String timing, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.backgroundMid,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.outfit(fontSize: 10, color: AppColors.textSecondary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            timing,
            style: GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
