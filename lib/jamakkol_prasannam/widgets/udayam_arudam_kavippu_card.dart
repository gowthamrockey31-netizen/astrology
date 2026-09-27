import 'package:flutter/material.dart';
import '../engine/jamakkol_aspect_calculator.dart';
import '../models/jamakkol_models.dart';
import '../models/jamakkol_planet_models.dart';

/// Card presenting the Three Pillars of Jamakkol Prasannam: Udayam, Arudam, Kavippu
class UdayamArudamKavippuCardWidget extends StatelessWidget {
  final JamakkolChartState state;
  final bool isTamil;

  const UdayamArudamKavippuCardWidget({
    super.key,
    required this.state,
    this.isTamil = true,
  });

  @override
  Widget build(BuildContext context) {
    final udayam = state.udayam;
    final arudam = state.arudam;
    final kavippu = state.kavippu;

    final udayaLordTa = JamakkolAspectCalculator.rasiLordsTa[udayam.rasiIndex];
    final udayaLordEn = JamakkolAspectCalculator.rasiLordsEn[udayam.rasiIndex];
    final arudaLordTa = JamakkolAspectCalculator.rasiLordsTa[arudam.rasiIndex];
    final arudaLordEn = JamakkolAspectCalculator.rasiLordsEn[arudam.rasiIndex];
    final kavippuLordTa = JamakkolAspectCalculator.rasiLordsTa[kavippu.rasiIndex];
    final kavippuLordEn = JamakkolAspectCalculator.rasiLordsEn[kavippu.rasiIndex];

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.35), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(Icons.stars_rounded, color: Color(0xFFFFD700), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isTamil ? 'மூன்று முக்கிய தூண்கள் (உதயம் • ஆருடம் • கவிப்பு)' : 'The Three Core Pillars',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 3 Columns or responsive Wrap for Mobile/Tablet
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 700;
              if (isWide) {
                return Row(
                  children: [
                    Expanded(
                      child: _buildPillarBox(
                        title: isTamil ? 'உதயம் (Udayam)' : 'Udayam (Querent)',
                        sub: isTamil ? 'கேள்வி கேட்பவர்' : 'The Querent',
                        point: udayam,
                        lord: isTamil ? udayaLordTa : udayaLordEn,
                        houseText: isTamil ? 'லக்னம் (1-ஆம் பாவம்)' : 'House 1',
                        accentColor: const Color(0xFF3B82F6),
                        bgColor: const Color(0xFF1E3A8A).withValues(alpha: 0.25),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildPillarBox(
                        title: isTamil ? 'ஆருடம் (Arudam)' : 'Arudam (Matter)',
                        sub: isTamil ? 'கேட்கப்படும் காரியம்' : 'The Inquired Matter',
                        point: arudam,
                        lord: isTamil ? arudaLordTa : arudaLordEn,
                        houseText: isTamil ? 'உதயத்திற்கு ${arudam.houseFromUdayam}-ஆம் இடம்' : 'House ${arudam.houseFromUdayam} from Udayam',
                        accentColor: const Color(0xFF10B981),
                        bgColor: const Color(0xFF065F46).withValues(alpha: 0.25),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildPillarBox(
                        title: isTamil ? 'கவிப்பு (Kavippu)' : 'Kavippu (Obstacle)',
                        sub: isTamil ? 'தடை / மறைமுகம்' : 'Shadow / Obstruction',
                        point: kavippu,
                        lord: isTamil ? kavippuLordTa : kavippuLordEn,
                        houseText: isTamil ? 'உதயத்திற்கு ${kavippu.houseFromUdayam}-ஆம் இடம்' : 'House ${kavippu.houseFromUdayam} from Udayam',
                        accentColor: const Color(0xFFEF4444),
                        bgColor: const Color(0xFF7F1D1D).withValues(alpha: 0.25),
                      ),
                    ),
                  ],
                );
              } else {
                return Column(
                  children: [
                    _buildPillarBox(
                      title: isTamil ? 'உதயம் (Udayam)' : 'Udayam (Querent)',
                      sub: isTamil ? 'கேள்வி கேட்பவர்' : 'The Querent',
                      point: udayam,
                      lord: isTamil ? udayaLordTa : udayaLordEn,
                      houseText: isTamil ? 'லக்னம் (1-ஆம் பாவம்)' : 'House 1',
                      accentColor: const Color(0xFF3B82F6),
                      bgColor: const Color(0xFF1E3A8A).withValues(alpha: 0.25),
                    ),
                    const SizedBox(height: 8),
                    _buildPillarBox(
                      title: isTamil ? 'ஆருடம் (Arudam)' : 'Arudam (Matter)',
                      sub: isTamil ? 'கேட்கப்படும் காரியம்' : 'The Inquired Matter',
                      point: arudam,
                      lord: isTamil ? arudaLordTa : arudaLordEn,
                      houseText: isTamil ? 'உதயத்திற்கு ${arudam.houseFromUdayam}-ஆம் இடம்' : 'House ${arudam.houseFromUdayam} from Udayam',
                      accentColor: const Color(0xFF10B981),
                      bgColor: const Color(0xFF065F46).withValues(alpha: 0.25),
                    ),
                    const SizedBox(height: 8),
                    _buildPillarBox(
                      title: isTamil ? 'கவிப்பு (Kavippu)' : 'Kavippu (Obstacle)',
                      sub: isTamil ? 'தடை / மறைமுகம்' : 'Shadow / Obstruction',
                      point: kavippu,
                      lord: isTamil ? kavippuLordTa : kavippuLordEn,
                      houseText: isTamil ? 'உதயத்திற்கு ${kavippu.houseFromUdayam}-ஆம் இடம்' : 'House ${kavippu.houseFromUdayam} from Udayam',
                      accentColor: const Color(0xFFEF4444),
                      bgColor: const Color(0xFF7F1D1D).withValues(alpha: 0.25),
                    ),
                  ],
                );
              }
            },
          ),
          const SizedBox(height: 12),

          // Pillar Relationship Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              children: [
                const Icon(Icons.sync_alt_rounded, color: Color(0xFFFFD700), size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isTamil ? state.interpretation.udayamToArudamTextTa : state.interpretation.udayamToArudamTextEn,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
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

  Widget _buildPillarBox({
    required String title,
    required String sub,
    required JamakkolSpecialPoint point,
    required String lord,
    required String houseText,
    required Color accentColor,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: accentColor.withValues(alpha: 0.5), width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: accentColor, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  point.shortCode,
                  style: TextStyle(color: accentColor, fontWeight: FontWeight.bold, fontSize: 11),
                ),
              ),
            ],
          ),
          Text(sub, style: const TextStyle(color: Colors.white54, fontSize: 10)),
          const SizedBox(height: 6),

          // Rasi & Degree
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  isTamil ? point.rasiNameTa : point.rasiNameEn,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                point.formattedDms,
                style: TextStyle(color: accentColor, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 3),

          // Star & Pada
          Text(
            '★ ${isTamil ? point.nakshatraTa : point.nakshatraEn} - பாதம் ${point.pada}',
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
          const SizedBox(height: 3),

          // Lord & House
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  '${isTamil ? "அதிபதி" : "Lord"}: $lord',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Color(0xFFFFD700), fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  houseText,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: const TextStyle(color: Colors.white60, fontSize: 10),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
