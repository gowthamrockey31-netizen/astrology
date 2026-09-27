import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/cosmic_background.dart';
import '../engine/daily_rasi_palan_engine.dart';
import '../models/rasi_palan_models.dart';

/// Screen: இன்றைய ராசிபலன் (Daily Horoscope / Daily Rasi Palan)
class DailyRasiPalanScreen extends StatefulWidget {
  final DateTime? initialDate;
  final int? initialRasiIndex;

  const DailyRasiPalanScreen({
    super.key,
    this.initialDate,
    this.initialRasiIndex,
  });

  @override
  State<DailyRasiPalanScreen> createState() => _DailyRasiPalanScreenState();
}

class _DailyRasiPalanScreenState extends State<DailyRasiPalanScreen> {
  late DateTime _selectedDate;
  late int _selectedRasiIndex;
  late Map<int, DailyRasiPalan> _allPalan;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
    _selectedRasiIndex = widget.initialRasiIndex ?? 0;
    _calculatePalan();
  }

  void _calculatePalan() {
    setState(() {
      _isLoading = true;
    });
    try {
      _allPalan = DailyRasiPalanEngine.calculateAllRasis(date: _selectedDate);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _changeDay(int delta) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: delta));
      _calculatePalan();
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
        _selectedDate = DateTime(picked.year, picked.month, picked.day);
        _calculatePalan();
      });
    }
  }

  void _setToday() {
    final now = DateTime.now();
    setState(() {
      _selectedDate = DateTime(now.year, now.month, now.day);
      _calculatePalan();
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentPalan = _allPalan[_selectedRasiIndex] ??
        DailyRasiPalanEngine.calculatePalan(
          rasi: Rasi.fromIndex(_selectedRasiIndex),
          date: _selectedDate,
        );

    final isToday = DateFormat('yyyy-MM-dd').format(_selectedDate) ==
        DateFormat('yyyy-MM-dd').format(DateTime.now());

    return Scaffold(
      body: CosmicBackground(
        child: SafeArea(
          child: Column(
            children: [
              // 1. Top App Bar
              _buildTopBar(isToday),

              // 2. Date Navigation Bar
              _buildDateBar(isToday),

              // 3. 12 Rasi Selector Chips Carousel
              _buildRasiSelector(),

              // 4. Main Horoscope Content ScrollView
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: AppColors.primaryGold),
                      )
                    : SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header Banner for the selected Rasi
                            _buildRasiHeaderCard(currentPalan),
                            const SizedBox(height: 12),

                            // General Prediction (பொதுப்பலன்)
                            _buildDetailCard(
                              icon: Icons.star_rounded,
                              iconColor: Colors.amberAccent,
                              title: 'பொதுப்பலன் (General)',
                              content: currentPalan.general,
                            ),
                            const SizedBox(height: 10),

                            // Career / Job (தொழில் / வேலை)
                            _buildDetailCard(
                              icon: Icons.business_center_rounded,
                              iconColor: const Color(0xFF64B5F6),
                              title: 'தொழில் / வேலை (Career & Job)',
                              content: currentPalan.career,
                            ),
                            const SizedBox(height: 10),

                            // Finance (பணவரவு)
                            _buildDetailCard(
                              icon: Icons.account_balance_wallet_rounded,
                              iconColor: const Color(0xFF81C784),
                              title: 'பணவரவு (Finance & Wealth)',
                              content: currentPalan.finance,
                            ),
                            const SizedBox(height: 10),

                            // Love / Marriage (காதல் / திருமணம்)
                            _buildDetailCard(
                              icon: Icons.favorite_rounded,
                              iconColor: const Color(0xFFFF4081),
                              title: 'காதல் / திருமணம் (Love & Marriage)',
                              content: currentPalan.love,
                            ),
                            const SizedBox(height: 10),

                            // Family (குடும்பம்)
                            _buildDetailCard(
                              icon: Icons.family_restroom_rounded,
                              iconColor: const Color(0xFFFFB74D),
                              title: 'குடும்பம் (Family)',
                              content: currentPalan.family,
                            ),
                            const SizedBox(height: 10),

                            // Health (ஆரோக்கியம்)
                            _buildDetailCard(
                              icon: Icons.health_and_safety_rounded,
                              iconColor: const Color(0xFF4DD0E1),
                              title: 'ஆரோக்கியம் (Health)',
                              content: currentPalan.health,
                            ),
                            const SizedBox(height: 10),

                            // Education (கல்வி)
                            _buildDetailCard(
                              icon: Icons.school_rounded,
                              iconColor: const Color(0xFFBA68C8),
                              title: 'கல்வி (Education)',
                              content: currentPalan.education,
                            ),
                            const SizedBox(height: 10),

                            // Travel (பயணம்)
                            _buildDetailCard(
                              icon: Icons.directions_car_rounded,
                              iconColor: const Color(0xFF4FC3F7),
                              title: 'பயணம் (Travel)',
                              content: currentPalan.travel,
                            ),
                            const SizedBox(height: 10),

                            // Lucky Info Grid (Lucky Color & Lucky Number)
                            Row(
                              children: [
                                Expanded(
                                  child: _buildMiniInfoCard(
                                    icon: Icons.palette_rounded,
                                    iconColor: const Color(0xFFFF8A65),
                                    title: 'அதிர்ஷ்ட நிறம்',
                                    value: currentPalan.luckyColor,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _buildMiniInfoCard(
                                    icon: Icons.tag_rounded,
                                    iconColor: const Color(0xFFE040FB),
                                    title: 'அதிர்ஷ்ட எண்',
                                    value: '${currentPalan.luckyNumber}',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            // Caution (கவனம்)
                            _buildDetailCard(
                              icon: Icons.warning_amber_rounded,
                              iconColor: const Color(0xFFFF5252),
                              title: 'கவனம் (Caution)',
                              content: currentPalan.caution,
                            ),
                            const SizedBox(height: 10),

                            // Remedy (பரிகாரம்)
                            _buildDetailCard(
                              icon: Icons.self_improvement_rounded,
                              iconColor: AppColors.primaryGold,
                              title: 'பரிகாரம் (Remedy)',
                              content: currentPalan.remedy,
                              highlight: true,
                            ),
                            const SizedBox(height: 10),

                            // Planetary Positions & House Inspector (Cosmic Details)
                            _buildPlanetaryHousesAccordion(currentPalan),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildTopBar(bool isToday) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 4),
      child: Row(
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
                  'இன்றைய ராசிபலன்',
                  style: GoogleFonts.cinzel(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: AppColors.lightGold,
                    letterSpacing: 0.8,
                  ),
                ),
                Text(
                  'Daily Horoscope & Transit Predictions',
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          if (!isToday)
            TextButton.icon(
              onPressed: _setToday,
              icon: const Icon(Icons.today_rounded, size: 15, color: AppColors.primaryGold),
              label: Text(
                'இன்று',
                style: GoogleFonts.outfit(
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                  color: AppColors.lightGold,
                ),
              ),
              style: TextButton.styleFrom(
                backgroundColor: AppColors.primaryGold.withValues(alpha: 0.15),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(color: AppColors.borderGold),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDateBar(bool isToday) {
    final dateStr = DateFormat('dd MMMM yyyy (EEEE)').format(_selectedDate);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
          IconButton(
            onPressed: () => _changeDay(-1),
            icon: const Icon(Icons.chevron_left_rounded, color: AppColors.lightGold, size: 26),
            tooltip: 'Previous Day',
          ),
          Expanded(
            child: InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.calendar_month_rounded, size: 16, color: AppColors.primaryGold),
                    const SizedBox(width: 8),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        dateStr,
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.lightGold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: () => _changeDay(1),
            icon: const Icon(Icons.chevron_right_rounded, color: AppColors.lightGold, size: 26),
            tooltip: 'Next Day',
          ),
        ],
      ),
    );
  }

  Widget _buildRasiSelector() {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: Rasi.values.length,
        itemBuilder: (context, index) {
          final rasi = Rasi.values[index];
          final isSelected = rasi.index == _selectedRasiIndex;
          final palan = _allPalan[rasi.index];
          final rating = palan?.rating ?? 3;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedRasiIndex = rasi.index;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryGold.withValues(alpha: 0.25)
                    : const Color(0xFF090E1A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? const Color(0xFFFFD700) : AppColors.borderGold.withValues(alpha: 0.35),
                  width: isSelected ? 1.5 : 0.8,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primaryGold.withValues(alpha: 0.3),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    rasi.tamilName,
                    style: GoogleFonts.outfit(
                      fontSize: 12.5,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      color: isSelected ? const Color(0xFFFFD700) : Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      5,
                      (starIdx) => Icon(
                        starIdx < rating ? Icons.star_rounded : Icons.star_outline_rounded,
                        size: 10,
                        color: starIdx < rating ? Colors.amberAccent : Colors.white24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRasiHeaderCard(DailyRasiPalan palan) {
    final dateFormatted = DateFormat('dd MMMM yyyy').format(palan.date);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF0E1A33),
            const Color(0xFF142446),
            AppColors.cardSurface,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFFD700), width: 1.3),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withValues(alpha: 0.22),
            blurRadius: 14,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${palan.rasi.tamilName} (${palan.rasi.englishName})',
                    style: GoogleFonts.cinzel(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFFFD700),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dateFormatted,
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              // Score circular badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D2545),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF42A5F5), width: 1.0),
                ),
                child: Column(
                  children: [
                    Text(
                      '${palan.score}',
                      style: GoogleFonts.cinzel(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF80D8FF),
                      ),
                    ),
                    Text(
                      'மதிப்பெண்',
                      style: GoogleFonts.outfit(
                        fontSize: 8.5,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.borderGold, height: 1),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'நாள் மதிப்பீடு: ',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.lightGold,
                    ),
                  ),
                  Row(
                    children: List.generate(
                      5,
                      (index) => Icon(
                        index < palan.rating ? Icons.star_rounded : Icons.star_outline_rounded,
                        color: index < palan.rating ? Colors.amberAccent : Colors.white30,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _getRatingColor(palan.rating).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: _getRatingColor(palan.rating), width: 0.8),
                ),
                child: Text(
                  _getRatingLabel(palan.rating),
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: _getRatingColor(palan.rating),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String content,
    bool highlight = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: highlight
            ? const Color(0xFF131F10)
            : const Color(0xFF090E1A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: highlight ? Colors.greenAccent.withValues(alpha: 0.6) : AppColors.borderGold.withValues(alpha: 0.45),
          width: highlight ? 1.2 : 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.lightGold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: GoogleFonts.outfit(
              fontSize: 12.5,
              color: Colors.white,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniInfoCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF090E1A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderGold.withValues(alpha: 0.45), width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryGold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanetaryHousesAccordion(DailyRasiPalan palan) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 12),
        backgroundColor: const Color(0xFF070B14),
        collapsedBackgroundColor: const Color(0xFF070B14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: AppColors.borderGold.withValues(alpha: 0.35)),
        ),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: AppColors.borderGold.withValues(alpha: 0.35)),
        ),
        leading: const Icon(Icons.cyclone_rounded, color: Color(0xFF64B5F6), size: 20),
        title: Text(
          'கோட்சார கிரக இடங்கள் (Transit House Placements)',
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.lightGold,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: palan.planetPositions.map((pos) {
                final isPositive = pos.scoreContribution > 0;
                final sign = isPositive ? '+${pos.scoreContribution}' : '${pos.scoreContribution}';
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isPositive
                        ? const Color(0xFF1B381A).withValues(alpha: 0.7)
                        : const Color(0xFF381A1A).withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isPositive ? const Color(0xFF66BB6A) : const Color(0xFFEF5350),
                      width: 0.7,
                    ),
                  ),
                  child: Text(
                    '${pos.transit.planetTamil}: ${pos.house}ஆம் இடம் ($sign)',
                    style: GoogleFonts.outfit(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Color _getRatingColor(int rating) {
    switch (rating) {
      case 5:
        return const Color(0xFF69F0AE);
      case 4:
        return const Color(0xFF40C4FF);
      case 3:
        return const Color(0xFFFFD700);
      case 2:
        return const Color(0xFFFFB74D);
      case 1:
      default:
        return const Color(0xFFFF5252);
    }
  }

  String _getRatingLabel(int rating) {
    switch (rating) {
      case 5:
        return 'மிக நன்று (Excellent)';
      case 4:
        return 'நன்று (Good)';
      case 3:
        return 'சுமார் (Average)';
      case 2:
        return 'கவனம் (Caution)';
      case 1:
      default:
        return 'பொறுமை (Patience)';
    }
  }
}
