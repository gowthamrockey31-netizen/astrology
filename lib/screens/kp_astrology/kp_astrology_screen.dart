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
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
