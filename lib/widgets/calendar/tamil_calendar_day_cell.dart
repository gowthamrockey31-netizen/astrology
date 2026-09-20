import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/tamil_calendar_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../models/tamil_calendar_models.dart';

/// Single interactive day cell for the Tamil Month Grid (Zero-Overflow, Ultra-Responsive)
class TamilCalendarDayCell extends StatelessWidget {
  final CalendarDay dayData;
  final bool isSelected;
  final bool isCurrentMonth;
  final bool isToday;
  final CalendarDisplayMode displayMode;
  final VoidCallback onTap;

  const TamilCalendarDayCell({
    super.key,
    required this.dayData,
    required this.isSelected,
    required this.isCurrentMonth,
    required this.isToday,
    this.displayMode = CalendarDisplayMode.tamilMonth,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSunday = dayData.weekdayNumber == 7;

    // Dynamic border & background styling
    Color bgColor;
    Border border;
    List<BoxShadow>? shadows;

    if (isSelected) {
      bgColor = AppColors.primaryGold.withValues(alpha: 0.22);
      border = Border.all(color: AppColors.primaryGold, width: 1.4);
      shadows = [
        BoxShadow(
          color: AppColors.primaryGold.withValues(alpha: 0.35),
          blurRadius: 6,
          spreadRadius: 1,
        ),
      ];
    } else if (isToday) {
      bgColor = Colors.amber.withValues(alpha: 0.12);
      border = Border.all(color: Colors.amberAccent, width: 1.2);
    } else {
      bgColor = isCurrentMonth ? AppColors.cardSurface.withValues(alpha: 0.9) : Colors.black26;
      border = Border.all(
        color: isCurrentMonth ? AppColors.borderGold.withValues(alpha: 0.3) : Colors.white10,
        width: 0.6,
      );
    }

    final double opacity = isCurrentMonth ? 1.0 : 0.45;

    // Numbers display based on mode
    final String mainNumber = (displayMode == CalendarDisplayMode.tamilMonth)
        ? '${dayData.tamilDay}'
        : '${dayData.date.day}';

    final String subNumber = (displayMode == CalendarDisplayMode.tamilMonth)
        ? '${dayData.date.day}'
        : '${dayData.tamilMonth.length > 3 ? dayData.tamilMonth.substring(0, 3) : dayData.tamilMonth} ${dayData.tamilDay}';

    return Opacity(
      opacity: opacity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          splashColor: AppColors.primaryGold.withValues(alpha: 0.25),
          highlightColor: AppColors.primaryGold.withValues(alpha: 0.15),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(horizontal: 2.5, vertical: 3),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
              border: border,
              boxShadow: shadows,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 1. Top Row: Primary Number & Secondary Reference
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Main Date Number
                    Text(
                      mainNumber,
                      style: GoogleFonts.outfit(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w900,
                        color: isSelected
                            ? AppColors.lightGold
                            : (isSunday
                                ? Colors.redAccent
                                : (dayData.isMuhurtham ? Colors.amberAccent : Colors.white)),
                        height: 1.0,
                      ),
                    ),
                    // Sub Date Label
                    Flexible(
                      child: Text(
                        subNumber,
                        style: GoogleFonts.outfit(
                          fontSize: 8.0,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : AppColors.textSecondary,
                          height: 1.0,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 1),

                // 2. Middle: Nokku, Tithi & Nakshatra
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Nokku & Tithi line
                      Row(
                        children: [
                          Text(
                            dayData.nokkuDinam.symbol,
                            style: TextStyle(
                              fontSize: 7.5,
                              fontWeight: FontWeight.bold,
                              color: dayData.nokkuDinam == NokkuDinamType.mel
                                  ? Colors.greenAccent
                                  : (dayData.nokkuDinam == NokkuDinamType.keezh
                                      ? Colors.orangeAccent
                                      : Colors.cyanAccent),
                            ),
                          ),
                          const SizedBox(width: 1.5),
                          Expanded(
                            child: Text(
                              dayData.thithi,
                              style: GoogleFonts.outfit(
                                fontSize: 7.5,
                                fontWeight: FontWeight.w600,
                                color: dayData.thithiNumber == 15
                                    ? Colors.amberAccent
                                    : (dayData.thithiNumber == 30
                                        ? Colors.deepOrangeAccent
                                        : Colors.white70),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 0.5),
                      // Nakshatra line
                      Row(
                        children: [
                          const Text('★', style: TextStyle(fontSize: 6.5, color: AppColors.lightGold)),
                          const SizedBox(width: 1.5),
                          Expanded(
                            child: Text(
                              dayData.nakshatra,
                              style: GoogleFonts.outfit(
                                fontSize: 7.5,
                                color: AppColors.lightGold.withValues(alpha: 0.9),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // 3. Bottom Badges: Muhurtham / Festival / Holiday
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.bottomRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (dayData.isMuhurtham)
                        const Padding(
                          padding: EdgeInsets.only(right: 1.5),
                          child: Text('💍', style: TextStyle(fontSize: 7.5)),
                        ),
                      if (dayData.hasFestival)
                        Padding(
                          padding: const EdgeInsets.only(right: 1.5),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 0.5),
                            decoration: BoxDecoration(
                              color: Colors.purple.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: const Text('🎉', style: TextStyle(fontSize: 6.5)),
                          ),
                        ),
                      if (dayData.isGovernmentHoliday)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 0.5),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: const Text('🏛️', style: TextStyle(fontSize: 6.5)),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
