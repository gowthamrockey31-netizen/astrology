import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../models/kp_astrology_model.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/kp_astrology_calculator.dart';
import '../../widgets/cosmic_background.dart';

/// New Major Module 2: KP Astrology (Krishnamurti Paddhati) Screen
class KpAstrologyScreen extends StatefulWidget {
  const KpAstrologyScreen({super.key});

  @override
  State<KpAstrologyScreen> createState() => _KpAstrologyScreenState();
}

class _KpAstrologyScreenState extends State<KpAstrologyScreen> {
  late UserModel _user;
  late KpAstrologyResult _kpResult;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _user = AuthService.currentUser ??
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
          zodiac: 'Gemini',
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

    _kpResult = KpAstrologyCalculator.calculateKpChart(
      dateTime: dt,
      latitude: _user.latitude,
      longitude: _user.longitude,
      utcOffsetHours: _user.timezone,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CosmicBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Bar
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.lightGold),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'KP Astrology',
                            style: GoogleFonts.cinzel(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.lightGold,
                              letterSpacing: 1.2,
                            ),
                          ),
                          Text(
                            'Krishnamurti Paddhati (Star & Sub Lord Analysis)',
                            style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGold.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.primaryGold),
                      ),
                      child: Text(
                        'Ayanamsa: ${_kpResult.kpAyanamsaFormatted}',
                        style: GoogleFonts.outfit(fontSize: 10, color: AppColors.lightGold, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ).animate().fade(duration: 400.ms),

                const SizedBox(height: 14),

                // Ruling Planets (RP)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.cardSurface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.borderGold.withValues(alpha: 0.5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ஆளும் கிரகங்கள் (KP Ruling Planets - RP)',
                        style: GoogleFonts.cinzel(color: AppColors.lightGold, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const Divider(color: AppColors.borderGold, height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        children: _kpResult.rulingPlanets.entries.map((e) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.backgroundMid,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.4)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(e.key, style: GoogleFonts.outfit(fontSize: 9.5, color: AppColors.textSecondary)),
                                Text(e.value, style: GoogleFonts.outfit(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.lightGold)),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // KP 12 Cusps Table
                Text(
                  '12 பாவக ஆரம்ப நிலைகள் (12 KP Cusps & Sub Lords)',
                  style: GoogleFonts.cinzel(color: AppColors.lightGold, fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.cardSurface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.borderGold.withValues(alpha: 0.4)),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowHeight: 36,
                      dataRowMinHeight: 32,
                      dataRowMaxHeight: 36,
                      columnSpacing: 14,
                      horizontalMargin: 12,
                      headingRowColor: WidgetStateProperty.all(AppColors.backgroundMid),
                      columns: [
                        DataColumn(label: Text('பாவகம் (Cusp)', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.lightGold, fontSize: 11))),
                        DataColumn(label: Text('ராசி (Sign)', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.lightGold, fontSize: 11))),
                        DataColumn(label: Text('பாகை (Degree)', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.lightGold, fontSize: 11))),
                        DataColumn(label: Text('ராசி நாதன்', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.lightGold, fontSize: 11))),
                        DataColumn(label: Text('நட்சத்திர நாதன் (Star)', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.lightGold, fontSize: 11))),
                        DataColumn(label: Text('உப நாதன் (Sub)', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.greenAccent, fontSize: 11))),
                        DataColumn(label: Text('உப-உப நாதன் (Sub-Sub)', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.lightGold, fontSize: 11))),
                      ],
                      rows: _kpResult.cusps.map((c) {
                        return DataRow(
                          cells: [
                            DataCell(Text('பாவகம் ${c.cuspNumber}', style: GoogleFonts.outfit(color: AppColors.lightGold, fontWeight: FontWeight.bold, fontSize: 11))),
                            DataCell(Text(c.rasiNameTa, style: GoogleFonts.outfit(color: Colors.white, fontSize: 11))),
                            DataCell(Text(c.degreeFormatted, style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 11))),
                            DataCell(Text(c.signLordTa, style: GoogleFonts.outfit(color: Colors.white, fontSize: 11))),
                            DataCell(Text(c.starLordTa, style: GoogleFonts.outfit(color: Colors.white, fontSize: 11))),
                            DataCell(Text(c.subLordTa, style: GoogleFonts.outfit(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 11))),
                            DataCell(Text(c.subSubLordTa, style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 11))),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // KP Planets Table
                Text(
                  'கிரக நிலைகள் & உப நாதர்கள் (KP Planet Positions & Sub Lords)',
                  style: GoogleFonts.cinzel(color: AppColors.lightGold, fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.cardSurface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.borderGold.withValues(alpha: 0.4)),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowHeight: 36,
                      dataRowMinHeight: 32,
                      dataRowMaxHeight: 36,
                      columnSpacing: 14,
                      horizontalMargin: 12,
                      headingRowColor: WidgetStateProperty.all(AppColors.backgroundMid),
                      columns: [
                        DataColumn(label: Text('கிரகம்', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.lightGold, fontSize: 11))),
                        DataColumn(label: Text('ராசி', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.lightGold, fontSize: 11))),
                        DataColumn(label: Text('பாகை', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.lightGold, fontSize: 11))),
                        DataColumn(label: Text('பாவகம்', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.lightGold, fontSize: 11))),
                        DataColumn(label: Text('நட்சத்திர நாதன்', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.lightGold, fontSize: 11))),
                        DataColumn(label: Text('உப நாதன் (Sub)', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.greenAccent, fontSize: 11))),
                        DataColumn(label: Text('உப-உப நாதன்', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.lightGold, fontSize: 11))),
                      ],
                      rows: _kpResult.planets.map((p) {
                        return DataRow(
                          cells: [
                            DataCell(Text(p.planetNameTa, style: GoogleFonts.outfit(color: AppColors.lightGold, fontWeight: FontWeight.bold, fontSize: 11))),
                            DataCell(Text(p.rasiNameTa, style: GoogleFonts.outfit(color: Colors.white, fontSize: 11))),
                            DataCell(Text(p.degreeFormatted, style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 11))),
                            DataCell(Text('${p.cuspOccupied}-ஆம் பாவம்', style: GoogleFonts.outfit(color: Colors.white, fontSize: 11))),
                            DataCell(Text(p.starLordTa, style: GoogleFonts.outfit(color: Colors.white, fontSize: 11))),
                            DataCell(Text(p.subLordTa, style: GoogleFonts.outfit(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 11))),
                            DataCell(Text(p.subSubLordTa, style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 11))),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // NEW: KP Cusp Sub Lord House Relation (KP பாவ உப நட்சத்திராதிபதி தொடர்பு)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'KP பாவ உப நட்சத்திராதிபதி தொடர்பு',
                            style: GoogleFonts.cinzel(color: AppColors.lightGold, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          Text(
                            'KP Cusp Sub Lord House Relation (12 Cusps)',
                            style: GoogleFonts.outfit(fontSize: 10.5, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
                      ),
                      child: Text(
                        '12 Cusps Relation',
                        style: GoogleFonts.outfit(fontSize: 10, color: Colors.amber, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                Container(
                  decoration: BoxDecoration(
                    color: AppColors.cardSurface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.borderGold.withValues(alpha: 0.5)),
                  ),
                  child: Column(
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          showCheckboxColumn: false,
                          headingRowHeight: 38,
                          dataRowMinHeight: 36,
                          dataRowMaxHeight: 42,
                          columnSpacing: 14,
                          horizontalMargin: 12,
                          headingRowColor: WidgetStateProperty.all(AppColors.backgroundMid),
                          columns: [
                            DataColumn(label: Text('பாவம் (Cusp)', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.lightGold, fontSize: 11))),
                            DataColumn(label: Text('பாகை (Degree)', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.lightGold, fontSize: 11))),
                            DataColumn(label: Text('நட்சத்திரம்', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.lightGold, fontSize: 11))),
                            DataColumn(label: Text('நட்சத்திர நாதன்', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.lightGold, fontSize: 11))),
                            DataColumn(label: Text('உப நாதன் (Sub)', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.greenAccent, fontSize: 11))),
                            DataColumn(label: Text('தொடர்பு பாவகங்கள்', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.amberAccent, fontSize: 11))),
                            DataColumn(label: Text('விவரம்', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.textSecondary, fontSize: 11))),
                          ],
                          rows: _kpResult.cuspHouseRelations.map((rel) {
                            final cusp = _kpResult.cusps.firstWhere(
                              (c) => c.cuspNumber == rel.houseNumber,
                              orElse: () => _kpResult.cusps[rel.houseNumber - 1],
                            );
                            return DataRow(
                              onSelectChanged: (_) => _showRelationDetailModal(context, rel, cusp),
                              cells: [
                                DataCell(
                                  Text(
                                    'பாவம் ${rel.houseNumber}',
                                    style: GoogleFonts.outfit(color: AppColors.lightGold, fontWeight: FontWeight.bold, fontSize: 11),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    cusp.degreeFormatted,
                                    style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 11),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    rel.nakshatraNameTa,
                                    style: GoogleFonts.outfit(color: Colors.white, fontSize: 11),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    rel.cuspStarLordTa,
                                    style: GoogleFonts.outfit(color: Colors.white, fontSize: 11),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    rel.cuspSubLordTa,
                                    style: GoogleFonts.outfit(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 11),
                                  ),
                                ),
                                DataCell(
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: Colors.amber.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
                                    ),
                                    child: Text(
                                      rel.finalRelatedHousesFormatted,
                                      style: GoogleFonts.outfit(
                                        color: Colors.amberAccent,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11.5,
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  const Icon(Icons.info_outline_rounded, color: AppColors.lightGold, size: 16),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundMid.withValues(alpha: 0.5),
                          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(14)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.touch_app_outlined, size: 14, color: AppColors.lightGold),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'எந்த ஒரு பாவக வரியைத் தொட்டும் விரிவான தொடர்பு கணிப்பு விளக்கத்தைப் பார்க்கலாம்.',
                                style: GoogleFonts.outfit(fontSize: 10, color: AppColors.textSecondary),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showRelationDetailModal(BuildContext context, KpCuspHouseRelationResult rel, KpCuspDetail cusp) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.backgroundDeep,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            border: Border(
              top: BorderSide(color: AppColors.borderGold, width: 1.5),
              left: BorderSide(color: AppColors.borderGold, width: 0.5),
              right: BorderSide(color: AppColors.borderGold, width: 0.5),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.borderGold.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'பாவம் ${rel.houseNumber} - உப நட்சத்திராதிபதி தொடர்பு விளக்கம்',
                              style: GoogleFonts.cinzel(
                                color: AppColors.lightGold,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              'Cusp ${rel.houseNumber} Sub Lord Signification Breakdown',
                              style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        icon: const Icon(Icons.close, color: AppColors.lightGold, size: 20),
                      ),
                    ],
                  ),
                  const Divider(color: AppColors.borderGold, height: 16),

                  // Cusp Basic Data
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.cardSurface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.borderGold.withValues(alpha: 0.4)),
                    ),
                    child: Column(
                      children: [
                        _buildDetailRow('பாவக ஆரம்ப பாகை (Degree)', cusp.degreeFormatted),
                        _buildDetailRow('ராசி (Sign)', cusp.rasiNameTa),
                        _buildDetailRow('நட்சத்திரம் (Nakshatra)', '${rel.nakshatraNameTa} (${rel.nakshatraNameEn})'),
                        _buildDetailRow('பாவக நட்சத்திர நாதன்', rel.cuspStarLordTa),
                        _buildDetailRow('பாவக உப நாதன் (Cusp Sub Lord)', rel.cuspSubLordTa, isHighlight: true),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Level 1 & 2: Sub Lord Details
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.cardSurface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.borderGold.withValues(alpha: 0.4)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '1. உப நாதன் நிலை (Sub Lord Significations)',
                          style: GoogleFonts.cinzel(color: AppColors.lightGold, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                        const SizedBox(height: 6),
                        _buildDetailRow('உப நாதன் (Sub Lord)', rel.cuspSubLordTa),
                        _buildDetailRow(
                          'உப நாதன் நின்ற பாவம் (Occupied)',
                          rel.subLordOccupiedHouses.isEmpty ? 'இல்லை' : rel.subLordOccupiedHouses.join(', '),
                        ),
                        _buildDetailRow(
                          'உப நாதன் ஆதிக்கம் பெற்ற பாவங்கள் (Owned)',
                          rel.subLordOwnedHouses.isEmpty ? 'இல்லை' : rel.subLordOwnedHouses.join(', '),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Level 3: Star Lord Details
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.cardSurface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.borderGold.withValues(alpha: 0.4)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '2. உப நாதனின் நட்சத்திர நாதன் நிலை (Star Lord Significations)',
                          style: GoogleFonts.cinzel(color: AppColors.lightGold, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                        const SizedBox(height: 6),
                        _buildDetailRow('நட்சத்திர நாதன் (Star Lord)', rel.subLordStarLordTa),
                        _buildDetailRow(
                          'நட்சத்திர நாதன் நின்ற பாவம் (Occupied)',
                          rel.starLordOccupiedHouses.isEmpty ? 'இல்லை' : rel.starLordOccupiedHouses.join(', '),
                        ),
                        _buildDetailRow(
                          'நட்சத்திர நாதன் ஆதிக்கம் பெற்ற பாவங்கள் (Owned)',
                          rel.starLordOwnedHouses.isEmpty ? 'இல்லை' : rel.starLordOwnedHouses.join(', '),
                        ),
                      ],
                    ),
                  ),

                  // Node Special Details (if Sub Lord is Rahu/Ketu)
                  if (rel.isSubLordNode) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.cardSurface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.purpleAccent.withValues(alpha: 0.5)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '3. ராகு / கேது சிறப்பு தொடர்புகள் (Node Agent Rules)',
                            style: GoogleFonts.cinzel(color: Colors.purpleAccent, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                          const SizedBox(height: 6),
                          _buildDetailRow('ராசி நாதன் (Sign Lord)', rel.nodeSignLordTa ?? '-'),
                          _buildDetailRow(
                            'ராசி நாதன் தொடர்பு பாவங்கள்',
                            rel.nodeSignLordHouses.isEmpty ? 'இல்லை' : rel.nodeSignLordHouses.join(', '),
                          ),
                          if (rel.conjunctPlanetsTa.isNotEmpty) ...[
                            _buildDetailRow('இணைந்த கிரகங்கள் (Conjunct)', rel.conjunctPlanetsTa.join(', ')),
                            _buildDetailRow(
                              'இணைந்த கிரக தொடர்பு பாவங்கள்',
                              rel.conjunctPlanetsHouses.isEmpty ? 'இல்லை' : rel.conjunctPlanetsHouses.join(', '),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),

                  // Final Result Box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryGold.withValues(alpha: 0.2),
                          AppColors.backgroundMid,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primaryGold, width: 1.2),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'இறுதி தொடர்பு பாவகங்கள் (Final Related Houses)',
                          style: GoogleFonts.cinzel(
                            color: AppColors.lightGold,
                            fontWeight: FontWeight.bold,
                            fontSize: 12.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          rel.finalRelatedHousesFormatted,
                          style: GoogleFonts.outfit(
                            color: Colors.amberAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            letterSpacing: 2.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String title, String value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.outfit(
                color: isHighlight ? Colors.greenAccent : AppColors.textSecondary,
                fontSize: 11,
                fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.outfit(
              color: isHighlight ? Colors.greenAccent : AppColors.lightGold,
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

