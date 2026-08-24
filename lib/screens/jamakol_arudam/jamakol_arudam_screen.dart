import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../models/jamakol_arudam_model.dart';
import '../../services/astrology_calculator.dart';
import '../../services/jamakol_arudam_calculator.dart';
import '../../widgets/cosmic_background.dart';

/// New Major Module 1: Jamakol Arudam (ஜாமகோள் ஆருடம்) Prasannam Screen
class JamakolArudamScreen extends StatefulWidget {
  const JamakolArudamScreen({super.key});

  @override
  State<JamakolArudamScreen> createState() => _JamakolArudamScreenState();
}

class _JamakolArudamScreenState extends State<JamakolArudamScreen> {
  DateTime _queryTime = DateTime.now();
  int _selectedAarudamNumber = 1;
  late JamakolArudamResult _result;

  @override
  void initState() {
    super.initState();
    _recalculate();
  }

  void _recalculate() {
    _result = JamakolArudamCalculator.calculate(
      queryTime: _queryTime,
      customAarudamNumber: _selectedAarudamNumber,
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
                            'ஜாமகோள் ஆருடம்',
                            style: GoogleFonts.cinzel(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.lightGold,
                              letterSpacing: 1.2,
                            ),
                          ),
                          Text(
                            'Jamakol Arudam Prasannam Engine',
                            style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh_rounded, color: AppColors.primaryGold),
                      tooltip: 'தற்போதைய நேரத்திற்கு புதுப்பி (Refresh to Now)',
                      onPressed: () {
                        setState(() {
                          _queryTime = DateTime.now();
                          _recalculate();
                        });
                      },
                    ),
                  ],
                ).animate().fade(duration: 400.ms),

                const SizedBox(height: 12),

                // Query Settings Card
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('பிரசன்ன நேரம்:', style: GoogleFonts.cinzel(color: AppColors.lightGold, fontWeight: FontWeight.bold, fontSize: 13)),
                          Text(
                            "${_queryTime.hour.toString().padLeft(2, '0')}:${_queryTime.minute.toString().padLeft(2, '0')}:${_queryTime.second.toString().padLeft(2, '0')} (${_queryTime.day}/${_queryTime.month}/${_queryTime.year})",
                            style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Text('ஆருட ராசி எண் (1-12):', style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 12)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Slider(
                              value: _selectedAarudamNumber.toDouble(),
                              min: 1,
                              max: 12,
                              divisions: 11,
                              activeColor: AppColors.primaryGold,
                              inactiveColor: AppColors.backgroundMid,
                              label: '$_selectedAarudamNumber - ${AstrologyCalculator.rasiNamesTa[_selectedAarudamNumber - 1]}',
                              onChanged: (v) {
                                setState(() {
                                  _selectedAarudamNumber = v.round();
                                  _recalculate();
                                });
                              },
                            ),
                          ),
                          Text('$_selectedAarudamNumber', style: GoogleFonts.cinzel(color: AppColors.lightGold, fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 4 Pillars of Jamakol
                Row(
                  children: [
                    Expanded(child: _buildSpecialPillarCard('உதயம் (Udhayam)', _result.udhayam.rasiNameTa, Colors.blueAccent)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildSpecialPillarCard('ஆருடம் (Aarudam)', _result.aarudam.rasiNameTa, Colors.amberAccent)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildSpecialPillarCard('கவிப்பு (Kavippu)', _result.kavippu.rasiNameTa, Colors.redAccent)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildSpecialPillarCard('சூரியன் (Sun)', _result.sooriyan.rasiNameTa, Colors.orangeAccent)),
                  ],
                ),
                const SizedBox(height: 16),

                // Jamam Status Banner
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundMid,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primaryGold),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.wb_twilight_rounded, color: AppColors.primaryGold, size: 24),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_result.jamamNameTa, style: GoogleFonts.outfit(color: AppColors.lightGold, fontWeight: FontWeight.bold, fontSize: 13)),
                            Text('ஜாம அதிபதி கிரகம்: ${_result.jamamLordTa}', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 11)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Question Analysis & Interpretation
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
                      Text('பிரசன்ன பலன் & காரிய சித்தி ஆய்வு', style: GoogleFonts.cinzel(color: AppColors.lightGold, fontWeight: FontWeight.bold, fontSize: 14)),
                      const Divider(color: AppColors.borderGold, height: 16),
                      Text(_result.questionSuccessAnalysisTa, style: GoogleFonts.poppins(color: Colors.white, fontSize: 12.5)),
                      const SizedBox(height: 10),
                      Text('சுப ராசிகள் (Favorable): ${_result.favorableSignsTa.join(", ")}', style: GoogleFonts.outfit(color: Colors.greenAccent, fontWeight: FontWeight.w600, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text('தடை ராசிகள் (Obstructions): ${_result.obstructiveSignsTa.join(", ")}', style: GoogleFonts.outfit(color: Colors.redAccent, fontWeight: FontWeight.w600, fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Jamakol Outer Planets Table
                Text('ஜாமக்கோள் வெளி கிரகங்கள் (Outer Jama Planets)', style: GoogleFonts.cinzel(color: AppColors.lightGold, fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.cardSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderGold.withValues(alpha: 0.4)),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowHeight: 36,
                      dataRowMinHeight: 32,
                      dataRowMaxHeight: 36,
                      columnSpacing: 24,
                      headingRowColor: WidgetStateProperty.all(AppColors.backgroundMid),
                      columns: [
                        DataColumn(label: Text('ஜாம கிரகம்', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.lightGold, fontSize: 11))),
                        DataColumn(label: Text('அமர்ந்த ராசி', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.lightGold, fontSize: 11))),
                        DataColumn(label: Text('குறியீடு', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.lightGold, fontSize: 11))),
                      ],
                      rows: _result.jamaPlanets.map((jp) {
                        return DataRow(
                          cells: [
                            DataCell(Text(jp.nameTa, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 11))),
                            DataCell(Text(jp.rasiNameTa, style: GoogleFonts.outfit(color: AppColors.lightGold, fontSize: 11))),
                            DataCell(Text(jp.symbol, style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 11))),
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

  Widget _buildSpecialPillarCard(String title, String rasi, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.6)),
      ),
      child: Column(
        children: [
          Text(title, textAlign: TextAlign.center, style: GoogleFonts.outfit(fontSize: 9.5, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(rasi, textAlign: TextAlign.center, style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
