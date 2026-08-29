import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../controllers/tamil_calendar_controller.dart';
import '../../core/theme/app_colors.dart';
import 'tamil_calendar_day_cell.dart';
import 'tamil_day_detail_sheet.dart';

/// Full interactive monthly calendar grid for Tamil Month & Panchangam
class TamilMonthCalendarView extends StatelessWidget {
  final TamilCalendarController controller;
  final VoidCallback? onSwitchToDayView;

  const TamilMonthCalendarView({
    super.key,
    required this.controller,
    this.onSwitchToDayView,
  });

  static const List<String> weekdayHeadersTa = [
    'ஞா', 'தி', 'செ', 'பு', 'வி', 'வெ', 'ச'
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final focusedMonth = controller.focusedMonth;
        final tamilMonthName = controller.getFocusedTamilMonthName();
        final gregorianMonthYear = DateFormat('MMMM yyyy').format(focusedMonth);
        final gridDays = controller.getMonthGridDays();
        final selectedDate = controller.selectedDate;
        final today = DateTime.now();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Month Header & Navigator Card
            _buildMonthNavigatorCard(
              context: context,
              tamilMonthName: tamilMonthName,
              gregorianMonthYear: gregorianMonthYear,
            ),

            const SizedBox(height: 12),

            // 2. Weekday Header Row (ஞா, தி, செ, பு, வி, வெ, ச)
            _buildWeekdayHeaders(),

            const SizedBox(height: 8),

            // 3. 7-Column Calendar Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: gridDays.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 0.72,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
              ),
              itemBuilder: (context, index) {
                final dayData = gridDays[index];
                final isCurrentMonth = dayData.date.month == focusedMonth.month &&
                    dayData.date.year == focusedMonth.year;
                final isSelected = dayData.date.year == selectedDate.year &&
                    dayData.date.month == selectedDate.month &&
                    dayData.date.day == selectedDate.day;
                final isToday = dayData.date.year == today.year &&
                    dayData.date.month == today.month &&
                    dayData.date.day == today.day;

                return TamilCalendarDayCell(
                  dayData: dayData,
                  isSelected: isSelected,
                  isCurrentMonth: isCurrentMonth,
                  isToday: isToday,
                  onTap: () {
                    controller.selectDate(dayData.date);
                    TamilDayDetailSheet.show(
                      context,
                      dayData,
                      onOpenFullDayView: onSwitchToDayView != null
                          ? () => onSwitchToDayView!()
                          : null,
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 14),

            // 4. Quick Legend / Guide
            _buildCalendarLegend(),
          ],
        );
      },
    );
  }

  Widget _buildMonthNavigatorCard({
    required BuildContext context,
    required String tamilMonthName,
    required String gregorianMonthYear,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGold.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGold.withValues(alpha: 0.08),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          // Previous Month Button
          IconButton(
            onPressed: controller.previousMonth,
            icon: const Icon(Icons.chevron_left_rounded, color: AppColors.lightGold, size: 28),
            tooltip: 'முந்தைய மாதம் (Previous Month)',
          ),

          // Central Tamil Month & Gregorian Year Title
          Expanded(
            child: Column(
              children: [
                Text(
                  'தமிழ் மாதம்',
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  tamilMonthName,
                  style: GoogleFonts.cinzel(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.lightGold,
                  ),
                ),
                Text(
                  gregorianMonthYear,
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          // Next Month Button
          IconButton(
            onPressed: controller.nextMonth,
            icon: const Icon(Icons.chevron_right_rounded, color: AppColors.lightGold, size: 28),
            tooltip: 'அடுத்த மாதம் (Next Month)',
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayHeaders() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.backgroundMid.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderGold.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: List.generate(7, (index) {
          final isSunday = index == 0;
          return Expanded(
            child: Center(
              child: Text(
                weekdayHeadersTa[index],
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isSunday ? Colors.redAccent : AppColors.lightGold,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCalendarLegend() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.backgroundMid.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildLegendItem('⬆', 'மேல் நோக்கு', Colors.greenAccent),
          _buildLegendItem('⬇', 'கீழ் நோக்கு', Colors.orangeAccent),
          _buildLegendItem('↔', 'சம நோக்கு', Colors.cyanAccent),
          _buildLegendItem('💍', 'முகூர்த்தம்', Colors.amberAccent),
          _buildLegendItem('🏛️', 'அரசு விடுமுறை', Colors.redAccent),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String symbol, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(symbol, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold)),
        const SizedBox(width: 3),
        Text(
          label,
          style: GoogleFonts.outfit(fontSize: 9.5, color: Colors.white70),
        ),
      ],
    );
  }
}
