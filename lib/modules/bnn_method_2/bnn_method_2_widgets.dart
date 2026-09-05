import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import 'bnn_method_2_models.dart';

/// Dedicated UI Card for BNN Method 2 Planet Analysis
class BNNMethod2PlanetCard extends StatelessWidget {
  final BNNMethod2PlanetAnalysis analysis;

  const BNNMethod2PlanetCard({
    super.key,
    required this.analysis,
  });

  Color _getRelationColor(BNNMethod2RelationType rel) {
    switch (rel) {
      case BNNMethod2RelationType.friend:
        return Colors.greenAccent.shade400;
      case BNNMethod2RelationType.enemy:
        return Colors.redAccent.shade200;
      case BNNMethod2RelationType.neutral:
        return Colors.amber.shade400;
    }
  }

  @override
  Widget build(BuildContext context) {
    final planet = analysis.sourcePlanet;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      color: AppColors.cardSurface,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: AppColors.primaryGold.withValues(alpha: 0.6),
          width: 1.2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Planet Header: Name, House, Exact Degree
            _buildPlanetHeader(planet),
            const SizedBox(height: 14),

            // ① கிரகத்தின் மிக முக்கியமான 10 காரகங்கள்
            _buildNumberedSection(
              title: '① கிரகத்தின் மிக முக்கியமான 10 காரகங்கள்',
              items: analysis.planetKarakas,
              badgeColor: AppColors.primaryGold,
            ),
            const SizedBox(height: 16),

            // ② நோய் / உடல் காரகங்கள்
            _buildNumberedSection(
              title: '② நோய் / உடல் காரகங்கள்',
              items: analysis.diseaseKarakas,
              badgeColor: Colors.tealAccent,
            ),
            const SizedBox(height: 16),

            // ③ லக்னத்திலிருந்து {house}ம் பாவத்தின் 10 காரகங்கள்
            _buildNumberedSection(
              title: '③ லக்னத்திலிருந்து ${planet.house}ம் பாவத்தின் 10 காரகங்கள்',
              items: analysis.houseKarakas,
              badgeColor: Colors.purpleAccent,
            ),
            const SizedBox(height: 16),

            // ④ பிருகு நந்தி நாடி கிரக இணைப்புகள்
            _buildConnectionsSection(analysis.connections),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanetHeader(BNNMethod2PlanetPosition planet) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundMid,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.borderGold.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryGold.withValues(alpha: 0.2),
              border: Border.all(color: AppColors.primaryGold, width: 1.5),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: AppColors.lightGold,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      planet.tamilName,
                      style: GoogleFonts.cinzel(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.lightGold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '(${planet.englishName})',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  '${planet.signNameTa} • பாவம்: ${planet.house} • ${planet.nakshatra} (${planet.pada})',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black45,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.7)),
            ),
            child: Column(
              children: [
                Text(
                  'பாகை',
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  planet.formattedDMS,
                  style: GoogleFonts.outfit(
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
    );
  }

  Widget _buildNumberedSection({
    required String title,
    required List<String> items,
    required Color badgeColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.lightGold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.backgroundMid.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.borderGold.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final idx = entry.key + 1;
              final text = entry.value;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: badgeColor.withValues(alpha: 0.15),
                      ),
                      child: Text(
                        '$idx',
                        style: GoogleFonts.outfit(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: badgeColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        text,
                        style: GoogleFonts.outfit(
                          fontSize: 12.5,
                          color: Colors.white,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildConnectionsSection(List<BNNMethod2Connection> connections) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '④ பிருகு நந்தி நாடி கிரக இணைப்புகள்',
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.lightGold,
          ),
        ),
        const SizedBox(height: 8),
        if (connections.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white12),
            ),
            child: Center(
              child: Text(
                'குறிப்பிட்ட திசையில் இணைப்பு இல்லை',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          )
        else
          Column(
            children: connections.map((conn) {
              final relColor = _getRelationColor(conn.relationship);
              final target = conn.targetPlanet;

              return Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.backgroundMid,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: relColor.withValues(alpha: 0.4),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    // Direction House Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGold.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.5)),
                      ),
                      child: Text(
                        '${conn.relativeHouse}-ஆம் இடம்',
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.lightGold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Target Planet Name & Degree
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${target.tamilName} (${target.englishName})',
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'பாகை: ${target.formattedDMS} • ${target.signNameTa}',
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Relationship Badge (நட்பு, பகை, சமம்)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: relColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: relColor),
                      ),
                      child: Text(
                        conn.relationship.labelTa,
                        style: GoogleFonts.outfit(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: relColor,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}
