import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../controllers/tamil_calendar_controller.dart';
import '../../core/theme/app_colors.dart';
import 'tamil_calendar_day_cell.dart';
import 'tamil_day_detail_sheet.dart';

/// Full interactive monthly calendar grid supporting both Tamil Month and Gregorian Month views
class TamilMonthCalendarView extends StatelessWidget {
  final TamilCalendarController controller;
  final VoidCallback? onSwitchToDayView;
  final double? customAspectRatio;

  const TamilMonthCalendarView({
    super.key,
    required this.controller,
    this.onSwitchToDayView,
    this.customAspectRatio,
  });

  static const List<String> weekdayHeadersTa = [
    'ஞா', 'தி', 'செ', 'பு', 'வி', 'வெ', 'ச'
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final displayMode = controller.displayMode;
        final monthData = controller.currentMonthData;
        final selectedDate = controller.selectedDate;
        final today = DateTime.now();
        final gridDays = controller.getMonthGridDays();

        String mainTitle;
        String subTitle;
        String dateRangeFormatted;

        if (displayMode == CalendarDisplayMode.tamilMonth) {
          mainTitle = controller.focusedTamilMonthName;
          subTitle = 'தமிழ் ஆண்டு: ${controller.focusedTamilYearName} வருடம்';
          dateRangeFormatted =
              '${DateFormat('d MMMM yyyy').format(monthData.startDate)} – ${DateFormat('d MMMM yyyy').format(monthData.endDate)}';
        } else {
          mainTitle = '${controller.focusedGregorianMonthNameTa} ${controller.focusedGregorianYear}';
          subTitle = '${controller.focusedGregorianMonthNameEn} ${controller.focusedGregorianYear}';
          final firstDate = DateTime(controller.focusedGregorianYear, controller.focusedGregorianMonth, 1);
          final lastDate = DateTime(controller.focusedGregorianYear, controller.focusedGregorianMonth + 1, 0);
          dateRangeFormatted =
              '${DateFormat('d MMMM').format(firstDate)} – ${DateFormat('d MMMM yyyy').format(lastDate)}';
        }

        // Dynamically compute childAspectRatio based on available screen space
        final mediaQuery = MediaQuery.of(context);
        final screenWidth = mediaQuery.size.width;
        final screenHeight = mediaQuery.size.height;
        final safeHeight = screenHeight - mediaQuery.padding.top - mediaQuery.padding.bottom;

        final int rowCount = (gridDays.length / 7).ceil().clamp(1, 6);
        const double nonGridHeight = 215.0; // Header, month nav card, weekday row, legend, margins
        final double availableGridHeight = safeHeight - nonGridHeight;
        final double gridSpacingHeight = (rowCount - 1) * 4.0;
        final double targetCellHeight = availableGridHeight > 0
            ? (availableGridHeight - gridSpacingHeight) / rowCount
            : 60.0;
        final double cellWidth = (screenWidth - 32.0 - 24.0) / 7.0; // 32 screen h-padding, 24 cross-axis spacing
        final double dynamicAspectRatio = (targetCellHeight > 0 && cellWidth > 0)
            ? (cellWidth / targetCellHeight)
            : 0.78;
        final double effectiveAspectRatio = customAspectRatio ?? dynamicAspectRatio.clamp(0.48, 0.78);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Month Header & Navigator Card
            _buildMonthNavigatorCard(
              context: context,
              mainTitle: mainTitle,
              subTitle: subTitle,
              dateRangeFormatted: dateRangeFormatted,
            ),

            const SizedBox(height: 8),

            // Weekday Header Row (ஞா, தி, செ, பு, வி, வெ, ச)
            _buildWeekdayHeaders(),

            const SizedBox(height: 6),

            // 7-Column Calendar Grid with exact weekday alignment
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: gridDays.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: effectiveAspectRatio,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemBuilder: (context, index) {
                final dayData = gridDays[index];

                // Leading / trailing padding slots are empty to preserve weekday alignment
                if (dayData == null) {
                  return const SizedBox.shrink();
                }

                final isSelected = dayData.date.year == selectedDate.year &&
                    dayData.date.month == selectedDate.month &&
                    dayData.date.day == selectedDate.day;
                final isToday = dayData.date.year == today.year &&
                    dayData.date.month == today.month &&
                    dayData.date.day == today.day;

                return TamilCalendarDayCell(
                  dayData: dayData,
                  isSelected: isSelected,
                  isCurrentMonth: true,
                  isToday: isToday,
                  displayMode: displayMode,
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

            const SizedBox(height: 8),

            // Quick Legend / Guide (Scrollable horizontally to prevent overflow)
            _buildCalendarLegend(),
          ],
        );
      },
    );
  }

  Widget _buildMonthNavigatorCard({
    required BuildContext context,
    required String mainTitle,
    required String subTitle,
    required String dateRangeFormatted,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderGold.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGold.withValues(alpha: 0.08),
            blurRadius: 8,
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

          // Central Month & Date Range
          Expanded(
            child: Column(
              children: [
                Text(
                  subTitle,
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.8,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 1),
                Text(
                  mainTitle,
                  style: GoogleFonts.cinzel(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.lightGold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  dateRangeFormatted,
                  style: GoogleFonts.outfit(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                    color: Colors.white70,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
      padding: const EdgeInsets.symmetric(vertical: 5),
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
                  fontSize: 11.5,
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
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.backgroundMid.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white10),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildLegendItem('⬆', 'மேல் நோக்கு', Colors.greenAccent),
            const SizedBox(width: 12),
            _buildLegendItem('⬇', 'கீழ் நோக்கு', Colors.orangeAccent),
            const SizedBox(width: 12),
            _buildLegendItem('↔', 'சம நோக்கு', Colors.cyanAccent),
            const SizedBox(width: 12),
            _buildLegendItem('💍', 'முகூர்த்தம்', Colors.amberAccent),
            const SizedBox(width: 12),
            _buildLegendItem('🎉', 'விசேஷம்', Colors.purpleAccent),
            const SizedBox(width: 12),
            _buildLegendItem('🏛️', 'அரசு விடுமுறை', Colors.redAccent),
          ],
        ),
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
