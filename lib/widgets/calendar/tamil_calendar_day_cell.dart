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
    } else {
      bgColor = isCurrentMonth ? AppColors.cardSurface.withValues(alpha: 0.85) : Colors.black26;
      border = Border.all(
        color: isCurrentMonth ? AppColors.borderGold.withValues(alpha: 0.35) : Colors.white10,
        width: 0.8,
      );
    }

    final double opacity = isCurrentMonth ? 1.0 : 0.45;

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
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
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
                // Top Row: Tamil Date (Prominent) & Gregorian Date
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    // Prominent Tamil Date Number (1..32)
                    Text(
                      '${dayData.tamilDay}',
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: isSelected
                            ? AppColors.lightGold
                            : (dayData.isMuhurtham ? Colors.amberAccent : Colors.white),
                        height: 1.0,
                      ),
                    ),
                    // Gregorian Date (small: dd/MM)
                    Text(
                      gregorianFormatted,
                      style: GoogleFonts.outfit(
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                        height: 1.0,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 2),

                // Middle: Indicators (Nokku & Tithi / Nakshatra)
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
                              fontSize: 9,
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
                                fontSize: 8.5,
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
                          const Text('⭐', style: TextStyle(fontSize: 7)),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              dayData.nakshatra,
                              style: GoogleFonts.outfit(
                                fontSize: 8.5,
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

                // Bottom Badges: Government Holiday / Festival / Muhurtham
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (dayData.isMuhurtham)
                      const Padding(
                        padding: EdgeInsets.only(right: 2),
                        child: Text(
                          '💍',
                          style: TextStyle(fontSize: 8.5),
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
                          child: const Text('🎉', style: TextStyle(fontSize: 7)),
                        ),
                      ),
                    if (dayData.isGovernmentHoliday)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 2.5, vertical: 0.5),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: const Text('🏛️', style: TextStyle(fontSize: 7)),
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
