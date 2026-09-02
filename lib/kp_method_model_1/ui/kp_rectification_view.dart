import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../engine/kp_rectification_engine.dart';
import '../models/kp_birth_data.dart';
import '../models/kp_ruling_planet.dart';

/// Interactive Birth Time Rectification view using KP Ruling Planets methodology
class KPRectificationView extends StatefulWidget {
  final KPBirthData birthData;
  final KPRulingPlanets rulingPlanets;

  const KPRectificationView({
    super.key,
    required this.birthData,
    required this.rulingPlanets,
  });

  @override
  State<KPRectificationView> createState() => _KPRectificationViewState();
}

class _KPRectificationViewState extends State<KPRectificationView> {
  int _selectedRangeMinutes = 5;
  List<KPRectificationCandidate> _candidates = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _runRectification();
  }

  void _runRectification() {
    setState(() => _isSearching = true);
    final results = KPRectificationEngine.rectify(
      birthData: widget.birthData,
      rulingPlanets: widget.rulingPlanets,
      searchRangeMinutes: _selectedRangeMinutes,
      stepSeconds: 30,
    );
    setState(() {
      _candidates = results;
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Controls Card
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
                    const Icon(Icons.timer_rounded, color: AppColors.primaryGold, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      'BIRTH TIME RECTIFICATION (BTR)',
                      style: GoogleFonts.cinzel(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.lightGold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Verify birth time accuracy by matching Ascendant Sub-Lord against Ruling Planets.',
                  style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('Search Window: ', style: TextStyle(color: Colors.white70, fontSize: 13)),
                    const SizedBox(width: 8),
                    ...[2, 5, 10].map((mins) {
                      final isSel = _selectedRangeMinutes == mins;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text('± $mins min'),
                          selected: isSel,
                          selectedColor: AppColors.primaryGold,
                          backgroundColor: AppColors.backgroundDeep,
                          labelStyle: TextStyle(
                            color: isSel ? Colors.black : Colors.white70,
                            fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                          ),
                          onSelected: (val) {
                            if (val) {
                              setState(() => _selectedRangeMinutes = mins);
                              _runRectification();
                            }
                          },
                        ),
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Results Table Card
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'CANDIDATE RECTIFICATION TIMES',
                      style: GoogleFonts.cinzel(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.lightGold,
                      ),
                    ),
                    if (_isSearching) const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryGold)),
                  ],
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(
                      AppColors.primaryGold.withValues(alpha: 0.15),
                    ),
                    horizontalMargin: 12,
                    columnSpacing: 18,
                    dataRowMinHeight: 48,
                    dataRowMaxHeight: 56,
                    columns: [
                      _headerCol('Status'),
                      _headerCol('Candidate Time'),
                      _headerCol('Offset'),
                      _headerCol('Ascendant Sub Lord'),
                      _headerCol('Matching Score'),
                      _headerCol('Matched Ruling Planets'),
                    ],
                    rows: _candidates.map((c) {
                      final isBest = c.isBestCandidate && c.matchingScore > 0;
                      return DataRow(
                        color: isBest
                            ? WidgetStateProperty.all(Colors.green.withValues(alpha: 0.15))
                            : null,
                        cells: [
                          DataCell(
                            isBest
                                ? Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withValues(alpha: 0.3),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: Colors.greenAccent),
                                    ),
                                    child: const Text('Best Matching Candidate', style: TextStyle(color: Colors.lightGreenAccent, fontWeight: FontWeight.bold, fontSize: 10)),
                                  )
                                : const Text('-', style: TextStyle(color: Colors.white38)),
                          ),
                          DataCell(Text(c.timeFormatted, style: TextStyle(fontWeight: isBest ? FontWeight.bold : FontWeight.normal, color: isBest ? Colors.lightGreenAccent : Colors.white))),
                          DataCell(Text(c.offsetFormatted, style: const TextStyle(color: Colors.white70))),
                          DataCell(Text(c.ascendantSubLord, style: TextStyle(color: isBest ? Colors.lightGreenAccent : AppColors.lightGold, fontWeight: FontWeight.bold))),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 45,
                                  child: LinearProgressIndicator(
                                    value: c.matchingScore / 100.0,
                                    backgroundColor: Colors.white12,
                                    color: isBest ? Colors.lightGreenAccent : AppColors.primaryGold,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text('${c.matchingScore.round()}%', style: TextStyle(fontWeight: FontWeight.bold, color: isBest ? Colors.lightGreenAccent : Colors.white)),
                              ],
                            ),
                          ),
                          DataCell(
                            Text(
                              c.matchedRulingPlanets.isEmpty ? 'None' : c.matchedRulingPlanets.join(', '),
                              style: TextStyle(color: isBest ? Colors.lightGreenAccent : Colors.white70, fontSize: 12),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  DataColumn _headerCol(String title) {
    return DataColumn(
      label: Text(
        title,
        style: GoogleFonts.outfit(
          color: AppColors.primaryGold,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
