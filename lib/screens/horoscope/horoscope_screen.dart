import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../daily_rasi_palan/engine/daily_rasi_palan_engine.dart';
import '../../daily_rasi_palan/engine/extended_horoscope_engine.dart';
import '../../daily_rasi_palan/models/extended_horoscope_models.dart';
import '../../daily_rasi_palan/models/rasi_palan_models.dart';
import '../../daily_rasi_palan/screens/daily_rasi_palan_screen.dart';
import '../../models/horoscope_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../services/mock_data_service.dart';
import '../../widgets/cosmic_background.dart';

class HoroscopeScreen extends StatefulWidget {
  const HoroscopeScreen({super.key});

  @override
  State<HoroscopeScreen> createState() => _HoroscopeScreenState();
}

class _HoroscopeScreenState extends State<HoroscopeScreen> {
  String _selectedSign = AppConstants.zodiacSigns[0];
  int _selectedTab = 0; // 0: Daily, 1: Weekly, 2: Monthly, 3: Yearly

  DateTime _selectedDate = DateTime.now();

  int get _selectedRasiIndex {
    final idx = AppConstants.zodiacSigns.indexOf(_selectedSign);
    return idx >= 0 ? idx : 0;
  }

  void _changeDay(int delta) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: delta));
    });
  }

  void _changeMonth(int delta) {
    setState(() {
      final testDate = DateTime(_selectedDate.year, _selectedDate.month + delta, 1);
      final daysInNewMonth = DateTime(testDate.year, testDate.month + 1, 0).day;
      _selectedDate = DateTime(testDate.year, testDate.month, _selectedDate.day.clamp(1, daysInNewMonth));
    });
  }

  void _changeYear(int delta) {
    setState(() {
      final daysInMonth = DateTime(_selectedDate.year + delta, _selectedDate.month + 1, 0).day;
      _selectedDate = DateTime(_selectedDate.year + delta, _selectedDate.month, _selectedDate.day.clamp(1, daysInMonth));
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
      });
    }
  }

  void _setToday() {
    final now = DateTime.now();
    setState(() {
      _selectedDate = DateTime(now.year, now.month, now.day);
    });
  }

  HoroscopePredictionModel? _getCurrentPrediction() {
    if (MockDataService.deletedPredictions.contains(_selectedSign)) {
      return null;
    }
    if (MockDataService.customPredictions.containsKey(_selectedSign)) {
      return MockDataService.customPredictions[_selectedSign]!;
    }
    return HoroscopePredictionModel.forSign(_selectedSign);
  }

  void _showEditPredictionDialog({bool isNew = false}) async {
    final current = _getCurrentPrediction() ?? HoroscopePredictionModel.forSign(_selectedSign);
    final signCtrl = TextEditingController(text: isNew ? 'Aries (Mesha)' : current.zodiacSign);
    final dailyCtrl = TextEditingController(text: isNew ? '' : current.daily);
    final weeklyCtrl = TextEditingController(text: isNew ? '' : current.weekly);
    final monthlyCtrl = TextEditingController(text: isNew ? '' : current.monthly);
    final yearlyCtrl = TextEditingController(text: isNew ? '' : current.yearly);
    final luckyNoCtrl = TextEditingController(text: isNew ? '7' : '${current.luckyNumber}');
    final luckyColorCtrl = TextEditingController(text: isNew ? 'Golden Yellow' : current.luckyColor);
    final luckyGemCtrl = TextEditingController(text: isNew ? 'Yellow Sapphire' : current.luckyGem);

    final bool? saved = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.backgroundMid,
          insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
          titlePadding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          actionsPadding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppColors.borderGold, width: 1.5),
          ),
          title: Row(
            children: [
              Icon(
                isNew ? Icons.add_circle_outline_rounded : Icons.edit_note_rounded,
                color: AppColors.lightGold,
                size: 26,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isNew ? "Add Custom Horoscope" : "Edit ${_selectedSign.split(' ')[0]} Prediction",
                  style: GoogleFonts.cinzel(color: AppColors.lightGold, fontWeight: FontWeight.bold, fontSize: 15),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: signCtrl,
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
                    decoration: const InputDecoration(labelText: "Zodiac Sign Name", labelStyle: TextStyle(color: AppColors.lightGold)),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: dailyCtrl,
                    maxLines: 2,
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
                    decoration: const InputDecoration(labelText: "Daily Prediction", labelStyle: TextStyle(color: AppColors.lightGold)),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: weeklyCtrl,
                    maxLines: 2,
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
                    decoration: const InputDecoration(labelText: "Weekly Prediction", labelStyle: TextStyle(color: AppColors.lightGold)),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: monthlyCtrl,
                    maxLines: 2,
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
                    decoration: const InputDecoration(labelText: "Monthly Prediction", labelStyle: TextStyle(color: AppColors.lightGold)),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: yearlyCtrl,
                    maxLines: 2,
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
                    decoration: const InputDecoration(labelText: "Yearly Prediction", labelStyle: TextStyle(color: AppColors.lightGold)),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: luckyNoCtrl,
                          keyboardType: TextInputType.number,
                          style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
                          decoration: const InputDecoration(labelText: "Lucky No.", labelStyle: TextStyle(color: AppColors.lightGold)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: luckyColorCtrl,
                          style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
                          decoration: const InputDecoration(labelText: "Lucky Color", labelStyle: TextStyle(color: AppColors.lightGold)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: luckyGemCtrl,
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
                    decoration: const InputDecoration(labelText: "Lucky Gemstone", labelStyle: TextStyle(color: AppColors.lightGold)),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text("Cancel", style: GoogleFonts.poppins(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGold),
              onPressed: () {
                if (signCtrl.text.trim().isEmpty) return;
                Navigator.of(ctx).pop(true);
              },
              child: Text(
                isNew ? "Add Prediction" : "Save Changes",
                style: GoogleFonts.poppins(color: AppColors.textDark, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );

    if (saved == true) {
      final updated = HoroscopePredictionModel(
        zodiacSign: signCtrl.text.trim(),
        daily: dailyCtrl.text.trim().isNotEmpty ? dailyCtrl.text.trim() : current.daily,
        weekly: weeklyCtrl.text.trim().isNotEmpty ? weeklyCtrl.text.trim() : current.weekly,
        monthly: monthlyCtrl.text.trim().isNotEmpty ? monthlyCtrl.text.trim() : current.monthly,
        yearly: yearlyCtrl.text.trim().isNotEmpty ? yearlyCtrl.text.trim() : current.yearly,
        luckyNumber: int.tryParse(luckyNoCtrl.text.trim()) ?? current.luckyNumber,
        luckyColor: luckyColorCtrl.text.trim().isNotEmpty ? luckyColorCtrl.text.trim() : current.luckyColor,
        luckyGem: luckyGemCtrl.text.trim().isNotEmpty ? luckyGemCtrl.text.trim() : current.luckyGem,
        compatibilityScore: current.compatibilityScore,
      );

      await FirestoreService.saveHoroscopePrediction(updated);
      setState(() {
        _selectedSign = updated.zodiacSign;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Horoscope prediction saved successfully!", style: GoogleFonts.poppins(color: AppColors.lightGold)),
            backgroundColor: AppColors.backgroundMid,
          ),
        );
      }
    }
  }

  void _confirmDeletePrediction() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.backgroundMid,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Colors.redAccent, width: 1),
        ),
        title: Text("Delete Prediction", style: GoogleFonts.cinzel(color: Colors.redAccent, fontWeight: FontWeight.bold)),
        content: Text("Are you sure you want to delete prediction for '$_selectedSign'?", style: GoogleFonts.poppins(color: AppColors.textPrimary, fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text("Cancel", style: GoogleFonts.poppins(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text("Delete", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirestoreService.deleteHoroscopePrediction(_selectedSign);
      setState(() {});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Prediction for '$_selectedSign' deleted successfully.", style: GoogleFonts.poppins(color: AppColors.lightGold)),
            backgroundColor: AppColors.backgroundMid,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = AuthService.activeRole == 'Admin';
    final prediction = _getCurrentPrediction();
    final rasi = Rasi.fromIndex(_selectedRasiIndex);
    final dailyPalan = DailyRasiPalanEngine.calculatePalan(
      rasi: rasi,
      date: _selectedDate,
    );
    final weeklyPalan = ExtendedHoroscopeEngine.calculateWeeklyPalan(
      rasi: rasi,
      anchorDate: _selectedDate,
    );
    final monthlyPalan = ExtendedHoroscopeEngine.calculateMonthlyPalan(
      rasi: rasi,
      anchorDate: _selectedDate,
    );
    final yearlyPalan = ExtendedHoroscopeEngine.calculateYearlyPalan(
      rasi: rasi,
      year: _selectedDate.year,
    );

    final isToday = DateFormat('yyyy-MM-dd').format(_selectedDate) ==
        DateFormat('yyyy-MM-dd').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundMid,
        title: Text('Horoscope Predictions', style: GoogleFonts.cinzel(color: AppColors.lightGold, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome_rounded, color: AppColors.lightGold),
            tooltip: "Full Daily Rasi Palan",
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => DailyRasiPalanScreen(
                    initialDate: _selectedDate,
                    initialRasiIndex: _selectedRasiIndex,
                  ),
                ),
              );
            },
          ),
          if (isAdmin) ...[
            IconButton(
              icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.lightGold, size: 24),
              tooltip: "Add Prediction",
              onPressed: () => _showEditPredictionDialog(isNew: true),
            ),
          ],
        ],
      ),
      floatingActionButton: isAdmin && prediction != null && _selectedTab != 0
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.primaryGold,
              onPressed: () => _showEditPredictionDialog(isNew: false),
              icon: const Icon(Icons.edit_outlined, color: AppColors.textDark),
              label: Text("Edit Prediction", style: GoogleFonts.outfit(color: AppColors.textDark, fontWeight: FontWeight.bold)),
            )
          : null,
      body: CosmicBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Zodiac Sign Selector Grid/Horizontal list
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  children: AppConstants.zodiacSigns.map((sign) {
                    final isSel = _selectedSign == sign;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedSign = sign),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSel ? AppColors.primaryGold.withValues(alpha: 0.25) : AppColors.cardSurface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSel ? const Color(0xFFFFD700) : Colors.white12,
                            width: isSel ? 1.5 : 1.0,
                          ),
                        ),
                        child: Text(
                          sign.split(' ')[0],
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isSel ? const Color(0xFFFFD700) : Colors.white,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              // Timeframe Tabs: Daily, Weekly, Monthly, Yearly
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: ['Daily', 'Weekly', 'Monthly', 'Yearly'].asMap().entries.map((entry) {
                  final idx = entry.key;
                  final label = entry.value;
                  final isSel = _selectedTab == idx;
                  return ChoiceChip(
                    label: Text(label),
                    selected: isSel,
                    selectedColor: AppColors.primaryGold,
                    labelStyle: GoogleFonts.outfit(
                      color: isSel ? AppColors.backgroundDeep : AppColors.lightGold,
                      fontWeight: FontWeight.bold,
                    ),
                    onSelected: (val) => setState(() => _selectedTab = idx),
                  );
                }).toList(),
              ),

              const SizedBox(height: 8),

              // Renders dynamic Horoscope according to selected timeframe (Daily, Weekly, Monthly, Yearly)
              Expanded(
                child: _selectedTab == 0
                    ? _buildDailyPalanView(dailyPalan, isToday, isAdmin)
                    : (_selectedTab == 1
                        ? _buildWeeklyPalanView(weeklyPalan, isAdmin)
                        : (_selectedTab == 2
                            ? _buildMonthlyPalanView(monthlyPalan, isAdmin)
                            : _buildYearlyPalanView(yearlyPalan, isAdmin))),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Dynamic Daily Rasi Palan View for HoroscopeScreen Daily Tab ---
  Widget _buildDailyPalanView(DailyRasiPalan palan, bool isToday, bool isAdmin) {
    final dateStr = DateFormat('dd MMMM yyyy (EEEE)').format(_selectedDate);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Date Navigation Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.cardSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderGold.withValues(alpha: 0.5)),
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
                if (!isToday)
                  TextButton(
                    onPressed: _setToday,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      backgroundColor: AppColors.primaryGold.withValues(alpha: 0.15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: AppColors.borderGold, width: 0.8),
                      ),
                    ),
                    child: Text('இன்று', style: GoogleFonts.outfit(fontSize: 11, color: AppColors.lightGold)),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // 2. Hero Header Card for the selected Rasi
          Container(
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
                  color: const Color(0xFFFFD700).withValues(alpha: 0.20),
                  blurRadius: 14,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'இன்றைய ராசிபலன்',
                          style: GoogleFonts.cinzel(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF80D8FF),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${palan.rasi.tamilName} (${palan.rasi.englishName})',
                          style: GoogleFonts.cinzel(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFFFD700),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
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
                const SizedBox(height: 10),
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
                            (idx) => Icon(
                              idx < palan.rating ? Icons.star_rounded : Icons.star_outline_rounded,
                              color: idx < palan.rating ? Colors.amberAccent : Colors.white30,
                              size: 19,
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
          ),

          const SizedBox(height: 12),

          // 3. Mandatory Daily Horoscope Sections
          // ⭐ பொதுப்பலன் (General)
          _buildDetailCard(
            icon: Icons.star_rounded,
            iconColor: Colors.amberAccent,
            title: '⭐ பொதுப்பலன் (General)',
            content: palan.general,
          ),
          const SizedBox(height: 10),

          // 💼 தொழில் / வேலை (Career & Job)
          _buildDetailCard(
            icon: Icons.business_center_rounded,
            iconColor: const Color(0xFF64B5F6),
            title: '💼 தொழில் / வேலை (Career & Job)',
            content: palan.career,
          ),
          const SizedBox(height: 10),

          // 💰 பணவரவு (Finance & Wealth)
          _buildDetailCard(
            icon: Icons.account_balance_wallet_rounded,
            iconColor: const Color(0xFF81C784),
            title: '💰 பணவரவு (Finance & Wealth)',
            content: palan.finance,
          ),
          const SizedBox(height: 10),

          // ❤️ காதல் / திருமணம் (Love & Marriage)
          _buildDetailCard(
            icon: Icons.favorite_rounded,
            iconColor: const Color(0xFFFF4081),
            title: '❤️ காதல் / திருமணம் (Love & Marriage)',
            content: palan.love,
          ),
          const SizedBox(height: 10),

          // 👨👩👧 குடும்பம் (Family)
          _buildDetailCard(
            icon: Icons.family_restroom_rounded,
            iconColor: const Color(0xFFFFB74D),
            title: '👨‍👩‍👧 குடும்பம் (Family)',
            content: palan.family,
          ),
          const SizedBox(height: 10),

          // 🩺 ஆரோக்கியம் (Health)
          _buildDetailCard(
            icon: Icons.health_and_safety_rounded,
            iconColor: const Color(0xFF4DD0E1),
            title: '🩺 ஆரோக்கியம் (Health)',
            content: palan.health,
          ),
          const SizedBox(height: 10),

          // 📚 கல்வி (Education)
          _buildDetailCard(
            icon: Icons.school_rounded,
            iconColor: const Color(0xFFBA68C8),
            title: '📚 கல்வி (Education)',
            content: palan.education,
          ),
          const SizedBox(height: 10),

          // 🚗 பயணம் (Travel)
          _buildDetailCard(
            icon: Icons.directions_car_rounded,
            iconColor: const Color(0xFF4FC3F7),
            title: '🚗 பயணம் (Travel)',
            content: palan.travel,
          ),
          const SizedBox(height: 10),

          // Lucky Info Grid: அதிர்ஷ்ட நிறம் & அதிர்ஷ்ட எண்
          Row(
            children: [
              Expanded(
                child: _buildMiniInfoCard(
                  icon: Icons.palette_rounded,
                  iconColor: const Color(0xFFFF8A65),
                  title: '🎨 அதிர்ஷ்ட நிறம்',
                  value: palan.luckyColor,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMiniInfoCard(
                  icon: Icons.tag_rounded,
                  iconColor: const Color(0xFFE040FB),
                  title: '🔢 அதிர்ஷ்ட எண்',
                  value: '${palan.luckyNumber}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // ⚠️ கவனம் (Caution)
          _buildDetailCard(
            icon: Icons.warning_amber_rounded,
            iconColor: const Color(0xFFFF5252),
            title: '⚠️ கவனம் (Caution)',
            content: palan.caution,
          ),
          const SizedBox(height: 10),

          // 🕉️ பரிகாரம் (Remedy)
          _buildDetailCard(
            icon: Icons.self_improvement_rounded,
            iconColor: AppColors.primaryGold,
            title: '🕉️ பரிகாரம் (Remedy)',
            content: palan.remedy,
            highlight: true,
          ),
          const SizedBox(height: 14),

          // Button to open Full Screen with 12-Rasi carousel & house transits
          InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => DailyRasiPalanScreen(
                    initialDate: _selectedDate,
                    initialRasiIndex: _selectedRasiIndex,
                  ),
                ),
              );
            },
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF42A5F5), width: 1.2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.auto_awesome_rounded, color: Color(0xFF80D8FF), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'அனைத்து 12 ராசிகள் & கோட்சார விவரங்கள்',
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 16),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // --- Dynamic Weekly Rasi Palan View ---
  Widget _buildWeeklyPalanView(WeeklyRasiPalan palan, bool isAdmin) {
    final week = ExtendedHoroscopeEngine.getWeekRange(_selectedDate);
    final weekStartStr = DateFormat('dd MMM yyyy').format(week['start']!);
    final weekEndStr = DateFormat('dd MMM yyyy').format(week['end']!);
    final weekRangeStr = '$weekStartStr – $weekEndStr';

    final now = DateTime.now();
    final curWeek = ExtendedHoroscopeEngine.getWeekRange(now);
    final isCurrentWeek = week['start']!.isAtSameMomentAs(curWeek['start']!);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Weekly Date Navigation Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.cardSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderGold.withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => _changeDay(-7),
                  icon: const Icon(Icons.chevron_left_rounded, color: AppColors.lightGold, size: 26),
                  tooltip: 'Previous Week',
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
                          const Icon(Icons.date_range_rounded, size: 16, color: AppColors.primaryGold),
                          const SizedBox(width: 8),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              weekRangeStr,
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
                  onPressed: () => _changeDay(7),
                  icon: const Icon(Icons.chevron_right_rounded, color: AppColors.lightGold, size: 26),
                  tooltip: 'Next Week',
                ),
                if (!isCurrentWeek)
                  TextButton(
                    onPressed: _setToday,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      backgroundColor: AppColors.primaryGold.withValues(alpha: 0.15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: AppColors.borderGold, width: 0.8),
                      ),
                    ),
                    child: Text('இந்த வாரம்', style: GoogleFonts.outfit(fontSize: 11, color: AppColors.lightGold)),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // 2. Weekly Hero Header Card
          Container(
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
                  color: const Color(0xFFFFD700).withValues(alpha: 0.20),
                  blurRadius: 14,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'வாராந்திர ராசிபலன் (Weekly Horoscope)',
                          style: GoogleFonts.cinzel(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF80D8FF),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${palan.rasi.tamilName} (${palan.rasi.englishName})',
                          style: GoogleFonts.cinzel(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFFFD700),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
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
                const SizedBox(height: 10),
                const Divider(color: AppColors.borderGold, height: 1),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          'வார மதிப்பீடு: ',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.lightGold,
                          ),
                        ),
                        Row(
                          children: List.generate(
                            5,
                            (idx) => Icon(
                              idx < palan.rating ? Icons.star_rounded : Icons.star_outline_rounded,
                              color: idx < palan.rating ? Colors.amberAccent : Colors.white30,
                              size: 19,
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
                const SizedBox(height: 10),
                // Lucky and Caution Days Pills
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.5)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle_outline_rounded, color: Colors.greenAccent, size: 13),
                          const SizedBox(width: 4),
                          Text(
                            'சாதகமான நாள்: ${palan.luckyDays}',
                            style: GoogleFonts.outfit(fontSize: 11, color: Colors.greenAccent, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.orangeAccent.withValues(alpha: 0.5)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.warning_amber_rounded, color: Colors.orangeAccent, size: 13),
                          const SizedBox(width: 4),
                          Text(
                            'கவன நாள்: ${palan.cautionDays}',
                            style: GoogleFonts.outfit(fontSize: 11, color: Colors.orangeAccent, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // 3. Weekly Overview
          _buildDetailCard(
            icon: Icons.star_rounded,
            iconColor: Colors.amberAccent,
            title: '⭐ பொதுப்பலன் (Weekly Overview)',
            content: palan.general,
          ),
          const SizedBox(height: 10),

          // 4. Period Highlights (Start, Mid, End of Week)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.cardSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.4), width: 0.8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.timeline_rounded, color: Colors.cyanAccent, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      '🗓️ வார காலப் பகுப்பு (Weekly Timeline)',
                      style: GoogleFonts.outfit(fontSize: 13.5, fontWeight: FontWeight.bold, color: AppColors.lightGold),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                for (final h in palan.periodHighlights) ...[
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: h.isAuspicious ? Colors.green.withValues(alpha: 0.08) : Colors.red.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: h.isAuspicious ? Colors.greenAccent.withValues(alpha: 0.3) : Colors.redAccent.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              h.title,
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: h.isAuspicious ? Colors.greenAccent : const Color(0xFFFF8A80),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              h.dateRange,
                              style: GoogleFonts.outfit(fontSize: 10.5, color: Colors.white70),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          h.description,
                          style: GoogleFonts.outfit(fontSize: 11.5, color: Colors.white.withValues(alpha: 0.9), height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 10),

          // 5. Category Cards
          _buildDetailCard(
            icon: Icons.business_center_rounded,
            iconColor: const Color(0xFF64B5F6),
            title: '💼 தொழில் / வேலை (Career & Job)',
            content: palan.career,
          ),
          const SizedBox(height: 10),

          _buildDetailCard(
            icon: Icons.account_balance_wallet_rounded,
            iconColor: const Color(0xFF81C784),
            title: '💰 பணவரவு (Finance & Wealth)',
            content: palan.finance,
          ),
          const SizedBox(height: 10),

          _buildDetailCard(
            icon: Icons.favorite_rounded,
            iconColor: const Color(0xFFFF4081),
            title: '❤️ காதல் / திருமணம் (Love & Marriage)',
            content: palan.love,
          ),
          const SizedBox(height: 10),

          _buildDetailCard(
            icon: Icons.family_restroom_rounded,
            iconColor: const Color(0xFFFFB74D),
            title: '👨‍👩‍👧 குடும்பம் (Family)',
            content: palan.family,
          ),
          const SizedBox(height: 10),

          _buildDetailCard(
            icon: Icons.health_and_safety_rounded,
            iconColor: const Color(0xFF4DD0E1),
            title: '🩺 ஆரோக்கியம் (Health)',
            content: palan.health,
          ),
          const SizedBox(height: 10),

          _buildDetailCard(
            icon: Icons.school_rounded,
            iconColor: const Color(0xFFBA68C8),
            title: '📚 கல்வி (Education)',
            content: palan.education,
          ),
          const SizedBox(height: 10),

          _buildDetailCard(
            icon: Icons.store_rounded,
            iconColor: const Color(0xFFFFCC80),
            title: '🏢 தொழில் / வியாபாரம் (Business)',
            content: palan.business,
          ),
          const SizedBox(height: 10),

          _buildDetailCard(
            icon: Icons.directions_car_rounded,
            iconColor: const Color(0xFF4FC3F7),
            title: '🚗 பயணம் (Travel)',
            content: palan.travel,
          ),
          const SizedBox(height: 10),

          // Lucky Info Grid
          Row(
            children: [
              Expanded(
                child: _buildMiniInfoCard(
                  icon: Icons.palette_rounded,
                  iconColor: const Color(0xFFFF8A65),
                  title: '🎨 அதிர்ஷ்ட நிறம்',
                  value: palan.luckyColor,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMiniInfoCard(
                  icon: Icons.tag_rounded,
                  iconColor: const Color(0xFFE040FB),
                  title: '🔢 அதிர்ஷ்ட எண்',
                  value: '${palan.luckyNumber}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Caution
          _buildDetailCard(
            icon: Icons.warning_amber_rounded,
            iconColor: const Color(0xFFFF5252),
            title: '⚠️ கவனம் (Caution)',
            content: palan.caution,
          ),
          const SizedBox(height: 10),

          // Remedy
          _buildDetailCard(
            icon: Icons.self_improvement_rounded,
            iconColor: AppColors.primaryGold,
            title: '🕉️ பரிகாரம் (Remedy)',
            content: palan.remedy,
            highlight: true,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // --- Dynamic Monthly Rasi Palan View ---
  Widget _buildMonthlyPalanView(MonthlyRasiPalan palan, bool isAdmin) {
    final monthNameTa = ExtendedHoroscopeEngine.monthsTa[palan.month - 1];
    final monthNameEn = ExtendedHoroscopeEngine.monthsEn[palan.month - 1];
    final monthStr = '$monthNameTa ${palan.year} ($monthNameEn)';

    final now = DateTime.now();
    final isCurrentMonth = palan.year == now.year && palan.month == now.month;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Monthly Date Navigation Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.cardSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderGold.withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => _changeMonth(-1),
                  icon: const Icon(Icons.chevron_left_rounded, color: AppColors.lightGold, size: 26),
                  tooltip: 'Previous Month',
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
                          const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.primaryGold),
                          const SizedBox(width: 8),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              monthStr,
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
                  onPressed: () => _changeMonth(1),
                  icon: const Icon(Icons.chevron_right_rounded, color: AppColors.lightGold, size: 26),
                  tooltip: 'Next Month',
                ),
                if (!isCurrentMonth)
                  TextButton(
                    onPressed: _setToday,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      backgroundColor: AppColors.primaryGold.withValues(alpha: 0.15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: AppColors.borderGold, width: 0.8),
                      ),
                    ),
                    child: Text('இந்த மாதம்', style: GoogleFonts.outfit(fontSize: 11, color: AppColors.lightGold)),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // 2. Monthly Hero Header Card
          Container(
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
                  color: const Color(0xFFFFD700).withValues(alpha: 0.20),
                  blurRadius: 14,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'மாதாந்திர ராசிபலன் (Monthly Horoscope)',
                          style: GoogleFonts.cinzel(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF80D8FF),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${palan.rasi.tamilName} (${palan.rasi.englishName})',
                          style: GoogleFonts.cinzel(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFFFD700),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
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
                const SizedBox(height: 10),
                const Divider(color: AppColors.borderGold, height: 1),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          'மாத மதிப்பீடு: ',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.lightGold,
                          ),
                        ),
                        Row(
                          children: List.generate(
                            5,
                            (idx) => Icon(
                              idx < palan.rating ? Icons.star_rounded : Icons.star_outline_rounded,
                              color: idx < palan.rating ? Colors.amberAccent : Colors.white30,
                              size: 19,
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
                const SizedBox(height: 10),
                // Auspicious and Caution Pills
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.5)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.event_available_rounded, color: Colors.greenAccent, size: 13),
                          const SizedBox(width: 4),
                          Text(
                            palan.auspiciousPeriod,
                            style: GoogleFonts.outfit(fontSize: 11, color: Colors.greenAccent, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.5)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.event_busy_rounded, color: Colors.redAccent, size: 13),
                          const SizedBox(width: 4),
                          Text(
                            palan.cautionPeriod,
                            style: GoogleFonts.outfit(fontSize: 11, color: Colors.redAccent, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // 3. Monthly Overview
          _buildDetailCard(
            icon: Icons.star_rounded,
            iconColor: Colors.amberAccent,
            title: '⭐ மாதப் பொதுப்பலன் (Monthly Overview)',
            content: palan.general,
          ),
          const SizedBox(height: 10),

          // 4. Monthly Breakdown (1-10, 11-20, 21-End)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.cardSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFBA68C8).withValues(alpha: 0.4), width: 0.8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.pie_chart_rounded, color: Color(0xFFBA68C8), size: 18),
                    const SizedBox(width: 8),
                    Text(
                      '📊 மாத காலப் பகுப்பு (Monthly Breakdown)',
                      style: GoogleFonts.outfit(fontSize: 13.5, fontWeight: FontWeight.bold, color: AppColors.lightGold),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                for (final h in palan.periodBreakdowns) ...[
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: h.isAuspicious ? Colors.green.withValues(alpha: 0.08) : Colors.red.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: h.isAuspicious ? Colors.greenAccent.withValues(alpha: 0.3) : Colors.redAccent.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              h.title,
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: h.isAuspicious ? Colors.greenAccent : const Color(0xFFFF8A80),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              h.dateRange,
                              style: GoogleFonts.outfit(fontSize: 10.5, color: Colors.white70),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          h.description,
                          style: GoogleFonts.outfit(fontSize: 11.5, color: Colors.white.withValues(alpha: 0.9), height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 10),

          // 5. Category Cards
          _buildDetailCard(
            icon: Icons.business_center_rounded,
            iconColor: const Color(0xFF64B5F6),
            title: '💼 தொழில் / வேலை (Career & Job)',
            content: palan.career,
          ),
          const SizedBox(height: 10),

          _buildDetailCard(
            icon: Icons.account_balance_wallet_rounded,
            iconColor: const Color(0xFF81C784),
            title: '💰 பணவரவு (Finance & Wealth)',
            content: palan.finance,
          ),
          const SizedBox(height: 10),

          _buildDetailCard(
            icon: Icons.favorite_rounded,
            iconColor: const Color(0xFFFF4081),
            title: '❤️ காதல் / திருமணம் (Love & Marriage)',
            content: palan.love,
          ),
          const SizedBox(height: 10),

          _buildDetailCard(
            icon: Icons.family_restroom_rounded,
            iconColor: const Color(0xFFFFB74D),
            title: '👨‍👩‍👧 குடும்பம் (Family)',
            content: palan.family,
          ),
          const SizedBox(height: 10),

          _buildDetailCard(
            icon: Icons.health_and_safety_rounded,
            iconColor: const Color(0xFF4DD0E1),
            title: '🩺 ஆரோக்கியம் (Health)',
            content: palan.health,
          ),
          const SizedBox(height: 10),

          _buildDetailCard(
            icon: Icons.school_rounded,
            iconColor: const Color(0xFFBA68C8),
            title: '📚 கல்வி (Education)',
            content: palan.education,
          ),
          const SizedBox(height: 10),

          _buildDetailCard(
            icon: Icons.store_rounded,
            iconColor: const Color(0xFFFFCC80),
            title: '🏢 தொழில் / வியாபாரம் (Business)',
            content: palan.business,
          ),
          const SizedBox(height: 10),

          _buildDetailCard(
            icon: Icons.directions_car_rounded,
            iconColor: const Color(0xFF4FC3F7),
            title: '🚗 பயணம் (Travel)',
            content: palan.travel,
          ),
          const SizedBox(height: 10),

          // Lucky Info Grid
          Row(
            children: [
              Expanded(
                child: _buildMiniInfoCard(
                  icon: Icons.palette_rounded,
                  iconColor: const Color(0xFFFF8A65),
                  title: '🎨 அதிர்ஷ்ட நிறம்',
                  value: palan.luckyColor,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMiniInfoCard(
                  icon: Icons.tag_rounded,
                  iconColor: const Color(0xFFE040FB),
                  title: '🔢 அதிர்ஷ்ட எண்',
                  value: '${palan.luckyNumber}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Caution
          _buildDetailCard(
            icon: Icons.warning_amber_rounded,
            iconColor: const Color(0xFFFF5252),
            title: '⚠️ கவனம் (Caution)',
            content: palan.caution,
          ),
          const SizedBox(height: 10),

          // Remedy
          _buildDetailCard(
            icon: Icons.self_improvement_rounded,
            iconColor: AppColors.primaryGold,
            title: '🕉️ பரிகாரம் (Remedy)',
            content: palan.remedy,
            highlight: true,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // --- Dynamic Yearly Rasi Palan View ---
  Widget _buildYearlyPalanView(YearlyRasiPalan palan, bool isAdmin) {
    final yearStr = '${palan.year}-ஆம் ஆண்டு (Year ${palan.year})';
    final now = DateTime.now();
    final isCurrentYear = palan.year == now.year;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Yearly Date Navigation Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.cardSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderGold.withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => _changeYear(-1),
                  icon: const Icon(Icons.chevron_left_rounded, color: AppColors.lightGold, size: 26),
                  tooltip: 'Previous Year',
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
                          const Icon(Icons.auto_awesome_rounded, size: 16, color: AppColors.primaryGold),
                          const SizedBox(width: 8),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              yearStr,
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
                  onPressed: () => _changeYear(1),
                  icon: const Icon(Icons.chevron_right_rounded, color: AppColors.lightGold, size: 26),
                  tooltip: 'Next Year',
                ),
                if (!isCurrentYear)
                  TextButton(
                    onPressed: _setToday,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      backgroundColor: AppColors.primaryGold.withValues(alpha: 0.15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: AppColors.borderGold, width: 0.8),
                      ),
                    ),
                    child: Text('இந்த ஆண்டு', style: GoogleFonts.outfit(fontSize: 11, color: AppColors.lightGold)),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // 2. Yearly Hero Header Card
          Container(
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
                  color: const Color(0xFFFFD700).withValues(alpha: 0.20),
                  blurRadius: 14,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'வருடாந்திர ராசிபலன் (Annual Horoscope)',
                          style: GoogleFonts.cinzel(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF80D8FF),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${palan.rasi.tamilName} (${palan.rasi.englishName})',
                          style: GoogleFonts.cinzel(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFFFD700),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
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
                const SizedBox(height: 10),
                const Divider(color: AppColors.borderGold, height: 1),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          'ஆண்டு மதிப்பீடு: ',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.lightGold,
                          ),
                        ),
                        Row(
                          children: List.generate(
                            5,
                            (idx) => Icon(
                              idx < palan.rating ? Icons.star_rounded : Icons.star_outline_rounded,
                              color: idx < palan.rating ? Colors.amberAccent : Colors.white30,
                              size: 19,
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
                const SizedBox(height: 10),
                // Favorable and Caution Months Pills
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.5)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.thumb_up_alt_rounded, color: Colors.greenAccent, size: 13),
                          const SizedBox(width: 4),
                          Text(
                            'நன்மை தரும் மாதங்கள்: ${palan.favorableMonths}',
                            style: GoogleFonts.outfit(fontSize: 11, color: Colors.greenAccent, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.amberAccent.withValues(alpha: 0.5)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.info_outline_rounded, color: Colors.amberAccent, size: 13),
                          const SizedBox(width: 4),
                          Text(
                            'கவன மாதங்கள்: ${palan.cautionMonths}',
                            style: GoogleFonts.outfit(fontSize: 11, color: Colors.amberAccent, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // 3. Annual Overview
          _buildDetailCard(
            icon: Icons.star_rounded,
            iconColor: Colors.amberAccent,
            title: '⭐ ஆண்டுப் பொதுப்பலன் (Annual Overview)',
            content: palan.general,
          ),
          const SizedBox(height: 10),

          // 4. Major Transits (குரு, சனி, ராகு-கேது பெயர்ச்சி தாக்கம்)
          _buildDetailCard(
            icon: Icons.brightness_medium_rounded,
            iconColor: AppColors.primaryGold,
            title: '🪐 முக்கிய பெயர்ச்சிகள் & கிரக நிலை (Major Transits)',
            content: palan.majorTransitInfluences,
            highlight: true,
          ),
          const SizedBox(height: 10),

          // 5. Month-wise Summary (12 Calendar Months)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.cardSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF4DD0E1).withValues(alpha: 0.4), width: 0.8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_view_month_rounded, color: Color(0xFF4DD0E1), size: 18),
                    const SizedBox(width: 8),
                    Text(
                      '📅 12 மாத சுருக்கப் பலன்கள் (Month-by-Month)',
                      style: GoogleFonts.outfit(fontSize: 13.5, fontWeight: FontWeight.bold, color: AppColors.lightGold),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                for (final item in palan.monthSummaries) ...[
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '${item.month}. ${item.monthNameTa} (${item.monthNameEn})',
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.lightGold,
                              ),
                            ),
                            const Spacer(),
                            Row(
                              children: List.generate(
                                5,
                                (idx) => Icon(
                                  idx < item.rating ? Icons.star_rounded : Icons.star_outline_rounded,
                                  color: idx < item.rating ? Colors.amberAccent : Colors.white24,
                                  size: 13,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${item.score}/100',
                              style: GoogleFonts.outfit(
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                                color: _getRatingColor(item.rating),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.summary,
                          style: GoogleFonts.outfit(fontSize: 11.5, color: Colors.white.withValues(alpha: 0.88), height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 10),

          // 6. Category Cards
          _buildDetailCard(
            icon: Icons.business_center_rounded,
            iconColor: const Color(0xFF64B5F6),
            title: '💼 தொழில் / வேலை (Career & Job)',
            content: palan.career,
          ),
          const SizedBox(height: 10),

          _buildDetailCard(
            icon: Icons.account_balance_wallet_rounded,
            iconColor: const Color(0xFF81C784),
            title: '💰 பணவரவு (Finance & Wealth)',
            content: palan.finance,
          ),
          const SizedBox(height: 10),

          _buildDetailCard(
            icon: Icons.favorite_rounded,
            iconColor: const Color(0xFFFF4081),
            title: '❤️ காதல் / திருமணம் (Love & Marriage)',
            content: palan.love,
          ),
          const SizedBox(height: 10),

          _buildDetailCard(
            icon: Icons.family_restroom_rounded,
            iconColor: const Color(0xFFFFB74D),
            title: '👨‍👩‍👧 குடும்பம் (Family)',
            content: palan.family,
          ),
          const SizedBox(height: 10),

          _buildDetailCard(
            icon: Icons.health_and_safety_rounded,
            iconColor: const Color(0xFF4DD0E1),
            title: '🩺 ஆரோக்கியம் (Health)',
            content: palan.health,
          ),
          const SizedBox(height: 10),

          _buildDetailCard(
            icon: Icons.school_rounded,
            iconColor: const Color(0xFFBA68C8),
            title: '📚 கல்வி (Education)',
            content: palan.education,
          ),
          const SizedBox(height: 10),

          _buildDetailCard(
            icon: Icons.store_rounded,
            iconColor: const Color(0xFFFFCC80),
            title: '🏢 தொழில் / வியாபாரம் (Business)',
            content: palan.business,
          ),
          const SizedBox(height: 10),

          _buildDetailCard(
            icon: Icons.directions_car_rounded,
            iconColor: const Color(0xFF4FC3F7),
            title: '🚗 பயணம் (Travel)',
            content: palan.travel,
          ),
          const SizedBox(height: 10),

          // Lucky Info Grid
          Row(
            children: [
              Expanded(
                child: _buildMiniInfoCard(
                  icon: Icons.palette_rounded,
                  iconColor: const Color(0xFFFF8A65),
                  title: '🎨 அதிர்ஷ்ட நிறம்',
                  value: palan.luckyColor,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMiniInfoCard(
                  icon: Icons.tag_rounded,
                  iconColor: const Color(0xFFE040FB),
                  title: '🔢 அதிர்ஷ்ட எண்',
                  value: '${palan.luckyNumber}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Caution
          _buildDetailCard(
            icon: Icons.warning_amber_rounded,
            iconColor: const Color(0xFFFF5252),
            title: '⚠️ கவனம் (Caution)',
            content: palan.caution,
          ),
          const SizedBox(height: 10),

          // Remedy
          _buildDetailCard(
            icon: Icons.self_improvement_rounded,
            iconColor: AppColors.primaryGold,
            title: '🕉️ பரிகாரம் (Remedy)',
            content: palan.remedy,
            highlight: true,
          ),
          const SizedBox(height: 20),
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
            ? AppColors.primaryGold.withValues(alpha: 0.12)
            : AppColors.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: highlight ? const Color(0xFFFFD700) : AppColors.borderGold.withValues(alpha: 0.4),
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
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: highlight ? const Color(0xFFFFD700) : AppColors.lightGold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: GoogleFonts.outfit(
              fontSize: 12.5,
              color: Colors.white.withValues(alpha: 0.92),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderGold.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 15),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.outfit(fontSize: 11, color: Colors.white70),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.cinzel(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.lightGold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getRatingColor(int rating) {
    switch (rating) {
      case 5:
        return const Color(0xFF66BB6A);
      case 4:
        return const Color(0xFF42A5F5);
      case 3:
        return const Color(0xFFFFCA28);
      case 2:
        return const Color(0xFFFFA726);
      default:
        return const Color(0xFFEF5350);
    }
  }

  String _getRatingLabel(int rating) {
    switch (rating) {
      case 5:
        return 'மிகச் சிறப்பு';
      case 4:
        return 'சாதகமான நாள்';
      case 3:
        return 'சராசரி பலன்';
      case 2:
        return 'கவனம் தேவை';
      default:
        return 'பொறுமை அவசியம்';
    }
  }

  Widget _buildEmptyPredictionView(bool isAdmin) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderGold.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.delete_forever_rounded, color: Colors.redAccent, size: 48),
          const SizedBox(height: 12),
          Text(
            "Prediction Deleted",
            style: GoogleFonts.cinzel(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            "The horoscope prediction for '$_selectedSign' has been deleted by Admin.",
            style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          if (isAdmin) ...[
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGold),
              onPressed: () => _showEditPredictionDialog(isNew: true),
              icon: const Icon(Icons.add_rounded, color: AppColors.textDark),
              label: Text("Add Prediction for ${_selectedSign.split(' ')[0]}", style: GoogleFonts.outfit(color: AppColors.textDark, fontWeight: FontWeight.bold)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLuckyItem(String title, String val) {
    return Column(
      children: [
        Text(title, style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary), textAlign: TextAlign.center),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            val,
            style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.lightGold),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
