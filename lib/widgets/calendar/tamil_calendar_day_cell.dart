import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../models/tamil_calendar_models.dart';

/// Single interactive day cell for the Tamil Month Grid
class TamilCalendarDayCell extends StatelessWidget {
  final CalendarDay dayData;
  final bool isSelected;
  final bool isCurrentMonth;
  final bool isToday;
  final VoidCallback onTap;

  const TamilCalendarDayCell({
    super.key,
    required this.dayData,
    required this.isSelected,
    required this.isCurrentMonth,
    required this.isToday,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final gregorianFormatted = DateFormat('dd/MM').format(dayData.date);

    // Dynamic border & background styling
    Color bgColor;
    Border border;
    List<BoxShadow>? shadows;

    if (isSelected) {
      bgColor = AppColors.primaryGold.withValues(alpha: 0.22);
      border = Border.all(color: AppColors.primaryGold, width: 1.5);
      shadows = [
        BoxShadow(
          color: AppColors.primaryGold.withValues(alpha: 0.35),
          blurRadius: 8,
          spreadRadius: 1,
        ),
      ];
    } else if (isToday) {
      bgColor = Colors.amber.withValues(alpha: 0.12);
      border = Border.all(color: Colors.amberAccent, width: 1.2);
    } else if (dayData.isTamilMonthStart) {
      bgColor = AppColors.primaryGold.withValues(alpha: 0.10);
      border = Border.all(color: AppColors.primaryGold.withValues(alpha: 0.7), width: 1.0);
    } else {
      bgColor = isCurrentMonth ? AppColors.cardSurface.withValues(alpha: 0.85) : Colors.black26;
      border = Border.all(
        color: isCurrentMonth ? AppColors.borderGold.withValues(alpha: 0.35) : Colors.white10,
        width: 0.8,
      );
    }

    final double opacity = isCurrentMonth ? 1.0 : 0.40;

    return Opacity(
      opacity: opacity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          splashColor: AppColors.primaryGold.withValues(alpha: 0.25),
          highlightColor: AppColors.primaryGold.withValues(alpha: 0.15),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
              border: border,
              boxShadow: shadows,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 1. Top Row: Gregorian Date Number & Date Tag (15 | 15/08)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '${dayData.date.day}',
                      style: GoogleFonts.outfit(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w900,
                        color: isSelected
                            ? AppColors.lightGold
                            : (dayData.isTamilMonthStart ? Colors.amberAccent : Colors.white),
                        height: 1.0,
                      ),
                    ),
                    Text(
                      gregorianFormatted,
                      style: GoogleFonts.outfit(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                        height: 1.0,
                      ),
                    ),
                  ],
                ),

                // 2. Tamil Solar Month & Date (e.g. "ஆடி 30" or highlighted "ஆவணி 1")
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 2.5, vertical: 0.5),
                  decoration: BoxDecoration(
                    color: dayData.isTamilMonthStart
                        ? AppColors.primaryGold.withValues(alpha: 0.35)
                        : Colors.white.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(3),
                    border: dayData.isTamilMonthStart
                        ? Border.all(color: AppColors.primaryGold, width: 0.6)
                        : null,
                  ),
                  child: Text(
                    '${dayData.tamilMonth} ${dayData.tamilDay}',
                    style: GoogleFonts.outfit(
                      fontSize: 8.5,
                      fontWeight: dayData.isTamilMonthStart ? FontWeight.w800 : FontWeight.w600,
                      color: dayData.isTamilMonthStart ? AppColors.lightGold : Colors.white.withValues(alpha: 0.95),
                      height: 1.0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // 3. Middle: Nokku & Tithi / Nakshatra
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Nokku & Tithi
                      Row(
                        children: [
                          Text(
                            dayData.nokkuDinam.symbol,
                            style: TextStyle(
                              fontSize: 8.5,
                              fontWeight: FontWeight.bold,
                              color: dayData.nokkuDinam == NokkuDinamType.mel
                                  ? Colors.greenAccent
                                  : (dayData.nokkuDinam == NokkuDinamType.keezh
                                      ? Colors.orangeAccent
                                      : Colors.cyanAccent),
                            ),
                          ),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              dayData.thithi,
                              style: GoogleFonts.outfit(
                                fontSize: 8.0,
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
                      // Nakshatra line
                      Row(
                        children: [
                          const Text('⭐', style: TextStyle(fontSize: 6.5)),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              dayData.nakshatra,
                              style: GoogleFonts.outfit(
                                fontSize: 8.0,
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

                // 4. Bottom Badges: Government Holiday / Festival / Muhurtham
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (dayData.isMuhurtham)
                      const Padding(
                        padding: EdgeInsets.only(right: 2),
                        child: Text(
                          '💍',
                          style: TextStyle(fontSize: 8),
                        ),
                      ),
                    if (dayData.hasFestival)
                      Padding(
                        padding: const EdgeInsets.only(right: 2),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 2.5, vertical: 0.5),
                          decoration: BoxDecoration(
                            color: Colors.purple.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: const Text('🎉', style: TextStyle(fontSize: 6.5)),
                        ),
                      ),
                    if (dayData.isGovernmentHoliday)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 2.5, vertical: 0.5),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: const Text('🏛️', style: TextStyle(fontSize: 6.5)),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
