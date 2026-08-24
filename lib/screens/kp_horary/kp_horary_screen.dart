import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../models/kp_astrology_model.dart';
import '../../services/kp_astrology_calculator.dart';
import '../../widgets/cosmic_background.dart';

/// New Major Module 3: KP Horary / பிரசன்னம் Screen (Horary Numbers 1 to 249)
class KpHoraryScreen extends StatefulWidget {
  const KpHoraryScreen({super.key});

  @override
  State<KpHoraryScreen> createState() => _KpHoraryScreenState();
}

class _KpHoraryScreenState extends State<KpHoraryScreen> {
  int _horaryNumber = 108;
  final TextEditingController _questionCtrl = TextEditingController(text: 'தொழில் / வேலை மாற்றம் நன்மை தருமா?');
  DateTime _queryTime = DateTime.now();
  late KpAstrologyResult _horaryResult;

  @override
  void initState() {
    super.initState();
    _recalculate();
  }

  @override
  void dispose() {
    _questionCtrl.dispose();
    super.dispose();
  }

  void _recalculate() {
    final double customAscLong = KpAstrologyCalculator.getHoraryNumberAscendantLongitude(_horaryNumber);
    _horaryResult = KpAstrologyCalculator.calculateKpChart(
      dateTime: _queryTime,
      latitude: 13.0827,
      longitude: 80.2707,
      utcOffsetHours: 5.5,
      customAscendantLongitude: customAscLong,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ascCusp = _horaryResult.cusps.first;

    return Scaffold(
      body: CosmicBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
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
                            'KP Horary / பிரசன்னம்',
                            style: GoogleFonts.cinzel(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.lightGold,
                              letterSpacing: 1.2,
                            ),
                          ),
                          Text(
                            '1-249 KP Horary Number Prasanna Kundali',
                            style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ).animate().fade(duration: 400.ms),

                const SizedBox(height: 14),

                // Question & Horary Number Selector Card
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
                      TextField(
                        controller: _questionCtrl,
                        style: GoogleFonts.outfit(color: Colors.white, fontSize: 13),
                        decoration: InputDecoration(
                          labelText: 'கேள்வி / பிரச்சனை (Horary Query)',
                          labelStyle: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 12),
                          prefixIcon: const Icon(Icons.help_outline_rounded, color: AppColors.lightGold, size: 18),
                          filled: true,
                          fillColor: AppColors.backgroundMid,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Text('KP எண் (1-249):', style: GoogleFonts.cinzel(color: AppColors.lightGold, fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Slider(
                              value: _horaryNumber.toDouble(),
                              min: 1,
                              max: 249,
                              divisions: 248,
                              activeColor: AppColors.primaryGold,
                              inactiveColor: AppColors.backgroundMid,
                              label: '$_horaryNumber',
                              onChanged: (v) {
                                setState(() {
                                  _horaryNumber = v.round();
                                  _recalculate();
                                });
                              },
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryGold,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text('$_horaryNumber', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 14)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Horary Ascendant Summary Card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundMid,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.primaryGold, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('பிரசன்ன உதய லக்னம் (Horary Ascendant):', style: GoogleFonts.cinzel(color: AppColors.lightGold, fontWeight: FontWeight.bold, fontSize: 13)),
                          Text(ascCusp.rasiNameTa, style: GoogleFonts.outfit(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('ஸ்புடம்: ${ascCusp.degreeFormatted}', style: GoogleFonts.outfit(color: Colors.white, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text('ராசி நாதன்: ${ascCusp.signLordTa}  |  நட்சத்திர நாதன்: ${ascCusp.starLordTa}', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text('உப நாதன் (Sub Lord): ${ascCusp.subLordTa}  |  உப-உப நாதன்: ${ascCusp.subSubLordTa}', style: GoogleFonts.outfit(color: AppColors.primaryGold, fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Horary 12 Cusps
                Text('பிரசன்ன 12 பாவகங்கள் (KP Horary Cusps)', style: GoogleFonts.cinzel(color: AppColors.lightGold, fontWeight: FontWeight.bold, fontSize: 13)),
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
                      columnSpacing: 14,
                      horizontalMargin: 12,
                      headingRowColor: WidgetStateProperty.all(AppColors.backgroundMid),
                      columns: [
                        DataColumn(label: Text('பாவம்', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.lightGold, fontSize: 11))),
                        DataColumn(label: Text('ராசி', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.lightGold, fontSize: 11))),
                        DataColumn(label: Text('பாகை', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.lightGold, fontSize: 11))),
                        DataColumn(label: Text('நட்சத்திர நாதன்', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.lightGold, fontSize: 11))),
                        DataColumn(label: Text('உப நாதன் (Sub)', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.greenAccent, fontSize: 11))),
                      ],
                      rows: _horaryResult.cusps.map((c) {
                        return DataRow(
                          cells: [
                            DataCell(Text('பாவம் ${c.cuspNumber}', style: GoogleFonts.outfit(color: AppColors.lightGold, fontWeight: FontWeight.bold, fontSize: 11))),
                            DataCell(Text(c.rasiNameTa, style: GoogleFonts.outfit(color: Colors.white, fontSize: 11))),
                            DataCell(Text(c.degreeFormatted, style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 11))),
                            DataCell(Text(c.starLordTa, style: GoogleFonts.outfit(color: Colors.white, fontSize: 11))),
                            DataCell(Text(c.subLordTa, style: GoogleFonts.outfit(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 11))),
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
