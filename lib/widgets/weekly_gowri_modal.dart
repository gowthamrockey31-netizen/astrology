// ===============================================================
// WEEKLY GOWRI PANCHANGAM MODAL (வார கௌரி பஞ்சாங்கம்)
// Complete 7-day Day & Night Gowri Reference Table
// ===============================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/gowri_panchangam_engine.dart';
import '../core/theme/app_colors.dart';

class WeeklyGowriModal extends StatefulWidget {
  final int selectedWeekdayIndex; // 0=Sunday ... 6=Saturday
  final Function(int weekdayIndex)? onSelectWeekday;
  final DateTime? sunrise;
  final DateTime? sunset;
  final DateTime? nextSunrise;

  const WeeklyGowriModal({
    super.key,
    required this.selectedWeekdayIndex,
    this.onSelectWeekday,
    this.sunrise,
    this.sunset,
    this.nextSunrise,
  });

  static void show(
    BuildContext context, {
    required int selectedWeekdayIndex,
    Function(int weekdayIndex)? onSelectWeekday,
    DateTime? sunrise,
    DateTime? sunset,
    DateTime? nextSunrise,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.backgroundDeep,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        side: BorderSide(color: AppColors.borderGold, width: 0.8),
      ),
      builder: (_) => WeeklyGowriModal(
        selectedWeekdayIndex: selectedWeekdayIndex,
        onSelectWeekday: onSelectWeekday,
        sunrise: sunrise,
        sunset: sunset,
        nextSunrise: nextSunrise,
      ),
    );
  }

  @override
  State<WeeklyGowriModal> createState() => _WeeklyGowriModalState();
}

class _WeeklyGowriModalState extends State<WeeklyGowriModal> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.88,
        padding: const EdgeInsets.only(top: 12, left: 16, right: 16, bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Modal Header
            Row(
              children: [
                const Icon(Icons.table_chart_rounded, color: AppColors.lightGold, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'கௌரி பஞ்சாங்கம் - வார அட்டவணை',
                        style: GoogleFonts.cinzel(
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.lightGold,
                        ),
                      ),
                      Text(
                        'Weekly Reference Table (ஞாயிறு - சனி)',
                        style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: Colors.white70),
                  splashRadius: 20,
                ),
              ],
            ),
            const Divider(color: AppColors.borderGold, height: 16),

            // Tab Bar: Day / Night
            Container(
              decoration: BoxDecoration(
                color: AppColors.cardSurface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.borderGold.withValues(alpha: 0.3)),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: AppColors.primaryGold.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primaryGold, width: 1),
                ),
                labelColor: AppColors.lightGold,
                unselectedLabelColor: AppColors.textSecondary,
                labelStyle: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold),
                tabs: const [
                  Tab(
                    icon: Icon(Icons.wb_sunny_rounded, size: 16),
                    text: 'பகல் கௌரி (Day)',
                  ),
                  Tab(
                    icon: Icon(Icons.nightlight_round, size: 16),
                    text: 'இரவு கௌரி (Night)',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Content List
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildDayOrNightTable(isDay: true),
                  _buildDayOrNightTable(isDay: false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _getSlots({required bool isDay}) {
    if (widget.sunrise != null && widget.sunset != null) {
      if (isDay) {
        return GowriPanchangamEngine.calculateDayGowriPeriods(
          sunrise: widget.sunrise!,
          sunset: widget.sunset!,
          weekdayIndex: 0,
        ).map((p) => p.timeRange).toList();
      } else {
        return GowriPanchangamEngine.calculateNightGowriPeriods(
          sunset: widget.sunset!,
          nextSunrise: widget.nextSunrise ?? widget.sunrise!.add(const Duration(days: 1)),
          weekdayIndex: 0,
        ).map((p) => p.timeRange).toList();
      }
    }
    return isDay
        ? GowriPanchangamEngine.standardSlotsDay
        : GowriPanchangamEngine.standardSlotsNight;
  }

  Widget _buildDayOrNightTable({required bool isDay}) {
    final slots = _getSlots(isDay: isDay);
    final hasDynamic = widget.sunrise != null && widget.sunset != null;

    return ListView(
      children: [
        // Time Intervals Legend
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.schedule_rounded,
                    size: 13,
                    color: isDay ? Colors.amberAccent : Colors.cyanAccent,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    hasDynamic
                        ? 'கணக்கிடப்பட்ட 8 கால இடைவெளிகள் (8 Dynamic Intervals):'
                        : 'திட்டமிடப்பட்ட 8 கால இடைவெளிகள் (8 Standard Intervals):',
                    style: GoogleFonts.outfit(
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      color: isDay ? Colors.amberAccent : Colors.cyanAccent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: List.generate(8, (i) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.cardSurface,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${i + 1}: ${slots[i]}',
                      style: GoogleFonts.outfit(fontSize: 9.5, color: Colors.white70),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),

        // 7 Weekday Cards (Sunday=0 to Saturday=6)
        for (int w = 0; w < 7; w++) _buildWeekdayCard(weekdayIndex: w, isDay: isDay),
      ],
    );
  }

  Widget _buildWeekdayCard({required int weekdayIndex, required bool isDay}) {
    final isSelected = widget.selectedWeekdayIndex == weekdayIndex;
    final dayNameTa = GowriPanchangamEngine.weekdaysTa[weekdayIndex];
    final dayNameEn = GowriPanchangamEngine.weekdaysEn[weekdayIndex];
    final types = isDay
        ? GowriPanchangamEngine.dayGowri[weekdayIndex]!
        : GowriPanchangamEngine.nightGowri[weekdayIndex]!;
    final slots = _getSlots(isDay: isDay);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSelected ? AppColors.primaryGold : AppColors.borderGold.withValues(alpha: 0.35),
          width: isSelected ? 1.5 : 0.8,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: AppColors.primaryGold.withValues(alpha: 0.15),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primaryGold.withValues(alpha: 0.18)
                  : Colors.white.withValues(alpha: 0.03),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(9)),
            ),
            child: Row(
              children: [
                Text(
                  '$dayNameTa ($dayNameEn)',
                  style: GoogleFonts.cinzel(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? AppColors.lightGold : Colors.white,
                  ),
                ),
                const Spacer(),
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGold.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.primaryGold, width: 0.6),
                    ),
                    child: Text(
                      'தேர்ந்தெடுக்கப்பட்ட நாள்',
                      style: GoogleFonts.outfit(
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.lightGold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const Divider(color: AppColors.borderGold, height: 1, thickness: 0.5),

          // 8 Slots
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: List.generate(8, (i) {
                final type = types[i];
                final slotTiming = slots[i];
                return Container(
                  width: (MediaQuery.of(context).size.width - 64) / 2,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: type.isGood
                        ? Colors.green.withValues(alpha: 0.12)
                        : Colors.red.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: type.isGood
                          ? Colors.greenAccent.withValues(alpha: 0.45)
                          : Colors.redAccent.withValues(alpha: 0.40),
                      width: 0.8,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '#${i + 1} ${type.tamilName}',
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: type.isGood ? Colors.greenAccent : Colors.redAccent,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            type.isGood ? 'சுபம்' : 'அசுபம்',
                            style: GoogleFonts.outfit(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: type.isGood ? Colors.greenAccent : Colors.redAccent,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        slotTiming,
                        style: GoogleFonts.outfit(fontSize: 9.5, color: Colors.white70),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
