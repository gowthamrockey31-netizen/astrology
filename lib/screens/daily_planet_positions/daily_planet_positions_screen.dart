import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../models/horoscope_calculation_result.dart';
import '../../services/astrology_calculator.dart';
import '../../widgets/cosmic_background.dart';

/// New Major Module 4: Daily Planetary Positions (தினசரி கிரக நிலைகள் & கோட்சாரம்)
class DailyPlanetPositionsScreen extends StatefulWidget {
  const DailyPlanetPositionsScreen({super.key});

  @override
  State<DailyPlanetPositionsScreen> createState() => _DailyPlanetPositionsScreenState();
}

class _DailyPlanetPositionsScreenState extends State<DailyPlanetPositionsScreen> {
  DateTime _selectedDate = DateTime.now();
  late HoroscopeCalculationResult _ephemerisData;

  @override
  void initState() {
    super.initState();
    _recalculate();
  }

  void _recalculate() {
    _ephemerisData = AstrologyCalculator.calculateHoroscope(
      dateOfBirth: _selectedDate,
      latitude: 13.0827,
      longitude: 80.2707,
      utcOffsetHours: 5.5,
    );
  }

  void _changeDay(int daysOffset) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: daysOffset));
      _recalculate();
    });
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primaryGold,
              onPrimary: Colors.black,
              surface: AppColors.backgroundMid,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = DateTime(picked.year, picked.month, picked.day, _selectedDate.hour, _selectedDate.minute);
        _recalculate();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final planets = _ephemerisData.planets.values.where((p) => p.name != 'Lagna').toList();

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
                            'தினசரி கிரக நிலைகள்',
                            style: GoogleFonts.cinzel(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.lightGold,
                              letterSpacing: 1.2,
                            ),
                          ),
                          Text(
                            'Daily Ephemeris & Gocharam Planetary Longitudes',
                            style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ).animate().fade(duration: 400.ms),

                const SizedBox(height: 14),

                // Date Navigation Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.cardSurface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left_rounded, color: AppColors.primaryGold, size: 28),
                        tooltip: 'முந்தைய நாள் (Previous Day)',
                        onPressed: () => _changeDay(-1),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: _pickDate,
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.calendar_month_rounded, color: AppColors.lightGold, size: 16),
                                  const SizedBox(width: 6),
                                  Text(
                                    "${_selectedDate.day.toString().padLeft(2, '0')}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.year}",
                                    style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.lightGold),
                                  ),
                                ],
                              ),
                              Text(
                                '${_ephemerisData.tamilDateFormatted} (${_ephemerisData.tithi.tithiNameTa})',
                                style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right_rounded, color: AppColors.primaryGold, size: 28),
                        tooltip: 'அடுத்த நாள் (Next Day)',
                        onPressed: () => _changeDay(1),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Daily Planetary Positions Table
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.cardSurface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.borderGold.withValues(alpha: 0.4)),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowHeight: 38,
                      dataRowMinHeight: 34,
                      dataRowMaxHeight: 38,
                      columnSpacing: 14,
                      horizontalMargin: 12,
                      headingRowColor: WidgetStateProperty.all(AppColors.backgroundMid),
                      columns: [
                        DataColumn(label: Text('கிரகம்', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.lightGold, fontSize: 11))),
                        DataColumn(label: Text('ராசி', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.lightGold, fontSize: 11))),
                        DataColumn(label: Text('பாகை (Degree)', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.lightGold, fontSize: 11))),
                        DataColumn(label: Text('நட்சத்திரம்', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.lightGold, fontSize: 11))),
                        DataColumn(label: Text('பாதம்', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.lightGold, fontSize: 11))),
                        DataColumn(label: Text('இயக்கம்', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.lightGold, fontSize: 11))),
                      ],
                      rows: planets.map((p) {
                        return DataRow(
                          cells: [
                            DataCell(Text(p.tamilName, style: GoogleFonts.outfit(color: AppColors.lightGold, fontWeight: FontWeight.bold, fontSize: 11))),
                            DataCell(Text(p.rasiNameTa, style: GoogleFonts.outfit(color: Colors.white, fontSize: 11))),
                            DataCell(Text(p.degreeFormatted, style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 11))),
                            DataCell(Text(p.nakshatraNameTa, style: GoogleFonts.outfit(color: Colors.white, fontSize: 11))),
                            DataCell(Text('${p.pada}-ஆம் பாதம்', style: GoogleFonts.outfit(color: AppColors.lightGold, fontSize: 11))),
                            DataCell(Text(p.isRetrograde ? 'வக்ரம் (R)' : 'நேர்கதி (D)', style: GoogleFonts.outfit(color: p.isRetrograde ? Colors.cyanAccent : Colors.white60, fontSize: 11))),
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
