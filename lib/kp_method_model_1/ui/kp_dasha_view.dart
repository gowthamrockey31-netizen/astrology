import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../models/kp_dasha.dart';

/// Dasha View displaying Birth Dasha Balance and 4-Tier Vimshottari Hierarchy
class KPDashaView extends StatelessWidget {
  final KPDashaHierarchy dashaHierarchy;

  const KPDashaView({super.key, required this.dashaHierarchy});

  @override
  Widget build(BuildContext context) {
    final balance = dashaHierarchy.birthBalance;
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Birth Dasha Balance Card
        Card(
          color: AppColors.backgroundMid,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: AppColors.primaryGold.withValues(alpha: 0.3)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.hourglass_top_rounded, color: AppColors.primaryGold, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      'BIRTH DASHA BALANCE (இருப்பு தசை)',
                      style: GoogleFonts.cinzel(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.lightGold,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundDeep,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _metricBox('Dasha Planet', balance.planet, AppColors.lightGold),
                      _metricBox('Years', '${balance.years}', Colors.amberAccent),
                      _metricBox('Months', '${balance.months}', Colors.white),
                      _metricBox('Days', '${balance.days}', Colors.white70),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Start: ${dateFormat.format(balance.startDate)}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    Text('End: ${dateFormat.format(balance.endDate)}', style: const TextStyle(color: AppColors.lightGold, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // 2. Current Active Dasha Hierarchy
        if (dashaHierarchy.currentMahadasha != null)
          Card(
            color: AppColors.backgroundMid,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.lightGreenAccent.withValues(alpha: 0.4)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.flash_on_rounded, color: Colors.lightGreenAccent, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'CURRENT ACTIVE DASHA (தற்போதைய தசா இருப்பு)',
                        style: GoogleFonts.cinzel(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.lightGreenAccent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 12,
                    runSpacing: 10,
                    children: [
                      _activePill('Mahadasha', dashaHierarchy.currentMahadasha?.planet ?? '-'),
                      _activePill('Bhukti', dashaHierarchy.currentBhukti?.planet ?? '-'),
                      _activePill('Antara', dashaHierarchy.currentAntara?.planet ?? '-'),
                      _activePill('Sookshma', dashaHierarchy.currentSookshma?.planet ?? '-'),
                    ],
                  ),
                ],
              ),
            ),
          ),

        const SizedBox(height: 16),

        // 3. 120-Year Mahadasha Schedule
        Card(
          color: AppColors.backgroundMid,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: AppColors.primaryGold.withValues(alpha: 0.3)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.timeline_rounded, color: AppColors.primaryGold, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '120-YEAR VIMSHOTTARI TIMELINE',
                      style: GoogleFonts.cinzel(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.lightGold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: dashaHierarchy.mahadashas.length,
                  separatorBuilder: (ctx, idx) => const Divider(color: Colors.white12, height: 1),
                  itemBuilder: (context, idx) {
                    final maha = dashaHierarchy.mahadashas[idx];
                    return ExpansionTile(
                      leading: CircleAvatar(
                        radius: 16,
                        backgroundColor: maha.isCurrent
                            ? Colors.lightGreenAccent.withValues(alpha: 0.2)
                            : AppColors.primaryGold.withValues(alpha: 0.15),
                        child: Text(
                          maha.planet.substring(0, 1),
                          style: TextStyle(
                            color: maha.isCurrent ? Colors.lightGreenAccent : AppColors.primaryGold,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Row(
                        children: [
                          Text(
                            '${maha.planet} Mahadasha',
                            style: GoogleFonts.outfit(
                              fontWeight: maha.isCurrent ? FontWeight.bold : FontWeight.w500,
                              color: maha.isCurrent ? Colors.lightGreenAccent : Colors.white,
                            ),
                          ),
                          if (maha.isCurrent) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text('ACTIVE', style: TextStyle(color: Colors.lightGreenAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ],
                      ),
                      subtitle: Text(
                        '${dateFormat.format(maha.startDate)} - ${dateFormat.format(maha.endDate)} • Houses: ${maha.relatedHouses.isEmpty ? '-' : maha.relatedHouses.join(', ')}',
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                      children: maha.children.map((bhukti) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          child: Row(
                            children: [
                              const Icon(Icons.subdirectory_arrow_right_rounded, size: 16, color: Colors.white38),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${bhukti.planet} Bhukti',
                                  style: TextStyle(
                                    color: bhukti.isCurrent ? Colors.lightGreenAccent : Colors.white70,
                                    fontWeight: bhukti.isCurrent ? FontWeight.bold : FontWeight.normal,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              Text(
                                '${dateFormat.format(bhukti.startDate)} - ${dateFormat.format(bhukti.endDate)}',
                                style: const TextStyle(fontSize: 11, color: Colors.white54),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _metricBox(String title, String value, Color color) {
    return Column(
      children: [
        Text(title, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.cinzel(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _activePill(String level, String planet) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.backgroundDeep,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.lightGreenAccent.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(level, style: const TextStyle(color: AppColors.textSecondary, fontSize: 10)),
          const SizedBox(height: 2),
          Text(
            planet,
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.lightGreenAccent,
            ),
          ),
        ],
      ),
    );
  }
}
