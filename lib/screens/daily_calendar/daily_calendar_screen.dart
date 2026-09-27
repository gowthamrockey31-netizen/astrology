import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../models/daily_calendar_models.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/daily_calendar_engine.dart';
import '../../services/gowri_panchangam_engine.dart';
import '../../widgets/cosmic_background.dart';
import '../../widgets/south_indian_rasi_chart.dart';
import '../../widgets/weekly_gowri_modal.dart';
import '../../daily_rasi_palan/screens/daily_rasi_palan_screen.dart';

/// Module Screen: தினசரி நாள்காட்டி (Daily Calendar & Panchangam)
class DailyCalendarScreen extends StatefulWidget {
  const DailyCalendarScreen({super.key});

  @override
  State<DailyCalendarScreen> createState() => _DailyCalendarScreenState();
}

class _DailyCalendarScreenState extends State<DailyCalendarScreen> {
  DateTime _selectedDate = DateTime.now();
  late UserModel _user;
  late DailyCalendarData _calendarData;
  late String _currentCity;
  late double _latitude;
  late double _longitude;

  static const List<Map<String, dynamic>> _popularCities = [
    {'name': 'திண்டுக்கல் (Dindigul)', 'city': 'Dindigul', 'lat': 10.3626, 'lon': 77.9920},
    {'name': 'சென்னை (Chennai)', 'city': 'Chennai', 'lat': 13.0827, 'lon': 80.2707},
    {'name': 'மதுரை (Madurai)', 'city': 'Madurai', 'lat': 9.9252, 'lon': 78.1198},
    {'name': 'கோயம்புத்தூர் (Coimbatore)', 'city': 'Coimbatore', 'lat': 11.0168, 'lon': 76.9558},
    {'name': 'திருச்சிராப்பள்ளி (Trichy)', 'city': 'Tiruchirappalli', 'lat': 10.7905, 'lon': 78.7047},
    {'name': 'சேலம் (Salem)', 'city': 'Salem', 'lat': 11.6643, 'lon': 78.1460},
    {'name': 'திருநெல்வேலி (Tirunelveli)', 'city': 'Tirunelveli', 'lat': 8.7139, 'lon': 77.7567},
    {'name': 'ஈரோடு (Erode)', 'city': 'Erode', 'lat': 11.3410, 'lon': 77.7172},
    {'name': 'வேலூர் (Vellore)', 'city': 'Vellore', 'lat': 12.9165, 'lon': 79.1325},
    {'name': 'தஞ்சாவூர் (Thanjavur)', 'city': 'Thanjavur', 'lat': 10.7870, 'lon': 79.1378},
    {'name': 'கன்னியாகுமரி (Kanyakumari)', 'city': 'Kanyakumari', 'lat': 8.0883, 'lon': 77.5385},
  ];

  @override
  void initState() {
    super.initState();
    _loadUserAndCalculate();
  }

  void _loadUserAndCalculate() {
    _user = AuthService.currentUser ??
        UserModel(
          id: 'default_usr',
          name: 'Divine Seeker',
          mobile: '+919876543210',
          gender: 'Male',
          dob: '1996-06-15',
          timeOfBirth: '08:30 AM',
          placeOfBirth: 'Dindigul',
          city: 'Dindigul',
          state: 'Tamil Nadu',
          country: 'India',
          zodiac: 'Gemini (Mithuna)',
          nakshatra: 'Rohini',
          lagna: 'Mesha',
          walletBalance: 500.0,
          profilePhoto: '',
          latitude: 10.3626,
          longitude: 77.9920,
          timezone: 5.5,
        );

    _currentCity = _user.city;
    _latitude = _user.latitude;
    _longitude = _user.longitude;

    _recalculate();
  }

  void _recalculate() {
    _calendarData = DailyCalendarEngine.calculate(
      targetDate: _selectedDate,
      latitude: _latitude,
      longitude: _longitude,
      utcOffsetHours: _user.timezone,
    );
  }

  void _showCityPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundMid,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        side: BorderSide(color: AppColors.borderGold, width: 0.8),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'இருப்பிடம் தேர்வு செய்க (Select City)',
                      style: GoogleFonts.cinzel(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.lightGold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70, size: 20),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
                const Divider(color: AppColors.borderGold),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _popularCities.length,
                    itemBuilder: (context, idx) {
                      final item = _popularCities[idx];
                      final isSelected = _currentCity.toLowerCase() == (item['city'] as String).toLowerCase();
                      return ListTile(
                        dense: true,
                        leading: Icon(
                          Icons.location_city_rounded,
                          color: isSelected ? AppColors.primaryGold : Colors.white54,
                          size: 20,
                        ),
                        title: Text(
                          item['name'] as String,
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? AppColors.primaryGold : Colors.white,
                          ),
                        ),
                        subtitle: Text(
                          '${item['lat']}° N, ${item['lon']}° E',
                          style: GoogleFonts.outfit(fontSize: 10, color: AppColors.textSecondary),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle_rounded, color: AppColors.primaryGold, size: 18)
                            : null,
                        onTap: () {
                          Navigator.of(ctx).pop();
                          setState(() {
                            _currentCity = item['city'] as String;
                            _latitude = item['lat'] as double;
                            _longitude = item['lon'] as double;
                            _recalculate();
                          });
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _changeDay(int daysOffset) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: daysOffset));
      _recalculate();
    });
  }

  void _setToday() {
    setState(() {
      _selectedDate = DateTime.now();
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
    final isToday = DateFormat('yyyy-MM-dd').format(_selectedDate) == DateFormat('yyyy-MM-dd').format(DateTime.now());

    return Scaffold(
      body: CosmicBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Navigation Bar
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
                            'தினசரி நாள்காட்டி',
                            style: GoogleFonts.cinzel(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.lightGold,
                              letterSpacing: 1.2,
                            ),
                          ),
                          InkWell(
                            onTap: _showCityPicker,
                            borderRadius: BorderRadius.circular(6),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.location_on, size: 12, color: AppColors.primaryGold),
                                  const SizedBox(width: 3),
                                  Text(
                                    'Daily Calendar & Panchangam • $_currentCity',
                                    style: GoogleFonts.outfit(
                                      fontSize: 11,
                                      color: AppColors.lightGold,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                  const Icon(Icons.arrow_drop_down, size: 15, color: AppColors.lightGold),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!isToday)
                      TextButton.icon(
                        onPressed: _setToday,
                        icon: const Icon(Icons.today_rounded, size: 16, color: AppColors.primaryGold),
                        label: Text(
                          'இன்று (Today)',
                          style: GoogleFonts.outfit(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.lightGold),
                        ),
                        style: TextButton.styleFrom(
                          backgroundColor: AppColors.primaryGold.withValues(alpha: 0.15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: const BorderSide(color: AppColors.borderGold),
                          ),
                        ),
                      ),
                  ],
                ).animate().fade(duration: 350.ms),

                const SizedBox(height: 14),

                // Date Selector Navigator
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.cardSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderGold.withValues(alpha: 0.6)),
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
                          icon: const Icon(Icons.chevron_left_rounded, color: AppColors.lightGold, size: 28),
                          tooltip: 'முந்தைய நாள் (Previous Day)',
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: _pickDate,
                            borderRadius: BorderRadius.circular(10),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.calendar_month_rounded, size: 16, color: AppColors.primaryGold),
                                      const SizedBox(width: 6),
                                      Text(
                                        _calendarData.englishDate,
                                        style: GoogleFonts.cinzel(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.lightGold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${_calendarData.weekdayTa} (${_calendarData.weekdayEn}) • ${_calendarData.tamilDateFormatted}',
                                    style: GoogleFonts.outfit(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => _changeDay(1),
                          icon: const Icon(Icons.chevron_right_rounded, color: AppColors.lightGold, size: 28),
                          tooltip: 'அடுத்த நாள் (Next Day)',
                        ),
                      ],
                    ),
                  ).animate().fade(duration: 300.ms),

                const SizedBox(height: 14),

                // Dedicated Navigation Card: இன்றைய ராசிபலன் (Daily Rasi Palan)
                InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => DailyRasiPalanScreen(initialDate: _selectedDate),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF1A237E).withValues(alpha: 0.65),
                          const Color(0xFF0D47A1).withValues(alpha: 0.45),
                          AppColors.cardSurface,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF42A5F5).withValues(alpha: 0.75), width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1976D2).withValues(alpha: 0.22),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1565C0).withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF42A5F5), width: 1),
                          ),
                          child: const Icon(Icons.auto_awesome_rounded, color: Color(0xFF80D8FF), size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'இன்றைய ராசிபலன்',
                                style: GoogleFonts.cinzel(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.lightGold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '12 ராசிகளுக்கான கோட்சார தினசரி பலன்கள் (Daily Rasi Palan)',
                                style: GoogleFonts.outfit(
                                  fontSize: 11,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.lightGold, size: 16),
                      ],
                    ),
                  ),
                ).animate().fade(duration: 350.ms),

                const SizedBox(height: 14),

                // SECTION 1: Date Information Card
                _buildCardContainer(
                  title: 'தேதி மற்றும் நாள்குறிப்பு விவரங்கள்',
                  icon: Icons.info_outline_rounded,
                  accentColor: AppColors.primaryGold,
                  child: Column(
                    children: [
                      _buildInfoRow('தமிழ் தேதி', _calendarData.tamilDateFormatted),
                      _buildInfoRow('ஆங்கில தேதி', _calendarData.englishDate),
                      _buildInfoRow('நாள் / கிழமை', '${_calendarData.weekdayTa} (${_calendarData.weekdayEn})'),
                      _buildInfoRow('தமிழ் மாதம் / நாள்', '${_calendarData.tamilMonth} மாதம் - ${_calendarData.tamilDay} ஆம் நாள்'),
                      _buildInfoRow('பிறை நிலை', _calendarData.pakshaTa),
                      _buildInfoRow('நாள் விஷேசம்', _calendarData.naalVisheshamTa, highlight: true),
                      _buildInfoRow('நோக்கு நாள்', _calendarData.nokkuNaalTa),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // SECTION 2: நல்ல நேரம் (Morning & Evening)
                _buildCardContainer(
                  title: 'நல்ல நேரம் (Auspicious Muhurtha Timings)',
                  icon: Icons.access_time_filled_rounded,
                  accentColor: Colors.amberAccent,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTimingTile(
                        icon: Icons.wb_sunny_rounded,
                        title: 'காலை நல்ல நேரம்',
                        timing: _calendarData.morningNallaNeram,
                        badgeColor: Colors.greenAccent,
                      ),
                      const SizedBox(height: 8),
                      _buildTimingTile(
                        icon: Icons.nights_stay_rounded,
                        title: 'மாலை நல்ல நேரம்',
                        timing: _calendarData.eveningNallaNeram,
                        badgeColor: Colors.greenAccent,
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundMid,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.amberAccent.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.info_outline_rounded, size: 14, color: Colors.amberAccent),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _calendarData.nallaNeramNote,
                                style: GoogleFonts.outfit(
                                  fontSize: 10.5,
                                  color: AppColors.textSecondary,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // SECTION 3: கௌரி நல்ல நேரம் (Day & Night Gowri Periods)
                _buildCardContainer(
                  title: 'கௌரி நல்ல நேரம் (Gowri Panchangam)',
                  icon: Icons.auto_awesome_rounded,
                  accentColor: Colors.cyanAccent,
                  trailing: InkWell(
                    onTap: () {
                      WeeklyGowriModal.show(
                        context,
                        selectedWeekdayIndex: _selectedDate.weekday % 7,
                      );
                    },
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.cyanAccent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.table_chart_outlined, color: Colors.cyanAccent, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            'வார அட்டவணை',
                            style: GoogleFonts.outfit(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.cyanAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  child: Builder(
                    builder: (context) {
                      final now = DateTime.now();
                      final isViewingToday = _selectedDate.year == now.year &&
                          _selectedDate.month == now.month &&
                          _selectedDate.day == now.day;
                      final queryTime = isViewingToday
                          ? now
                          : DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, now.hour, now.minute, now.second);
                      final currentGowri = GowriPanchangamEngine.getCurrentGowriPeriod(
                        dayPeriods: _calendarData.dayGowriPeriods,
                        nightPeriods: _calendarData.nightGowriPeriods,
                        currentTime: queryTime,
                        weekdayIndex: _selectedDate.weekday % 7,
                      );

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (currentGowri != null) ...[
                            Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: currentGowri.isGood
                                      ? [const Color(0xFF0F3822), const Color(0xFF0A2315)]
                                      : [const Color(0xFF381215), const Color(0xFF230A0C)],
                                ),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: currentGowri.isGood
                                      ? Colors.greenAccent.withValues(alpha: 0.6)
                                      : Colors.redAccent.withValues(alpha: 0.6),
                                  width: 1.2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: (currentGowri.isGood ? Colors.greenAccent : Colors.redAccent).withValues(alpha: 0.15),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: (currentGowri.isGood ? Colors.greenAccent : Colors.redAccent).withValues(alpha: 0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      currentGowri.isGood ? Icons.check_circle_rounded : Icons.warning_amber_rounded,
                                      color: currentGowri.isGood ? Colors.greenAccent : Colors.redAccent,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              isViewingToday
                                                  ? 'தற்போதைய கௌரி நேரம் (${currentGowri.dayNightTa}):'
                                                  : 'கௌரி நேரம் (${currentGowri.dayNightTa}):',
                                              style: GoogleFonts.outfit(
                                                fontSize: 10.5,
                                                color: Colors.white70,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const Spacer(),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: (currentGowri.isGood ? Colors.green : Colors.red).withValues(alpha: 0.25),
                                                borderRadius: BorderRadius.circular(4),
                                                border: Border.all(
                                                  color: currentGowri.isGood ? Colors.greenAccent : Colors.redAccent,
                                                  width: 0.6,
                                                ),
                                              ),
                                              child: Text(
                                                currentGowri.isGood ? 'சுபம்' : 'அசுபம்',
                                                style: GoogleFonts.outfit(
                                                  fontSize: 9.5,
                                                  fontWeight: FontWeight.bold,
                                                  color: currentGowri.isGood ? Colors.greenAccent : Colors.redAccent,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 3),
                                        Row(
                                          children: [
                                            Text(
                                              currentGowri.nameTa,
                                              style: GoogleFonts.cinzel(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: currentGowri.isGood ? const Color(0xFF69F0AE) : const Color(0xFFFF8A80),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                '•  ${currentGowri.timeRange}',
                                                style: GoogleFonts.outfit(
                                                  fontSize: 11.5,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          Text(
                            'பகல் கௌரி காலங்கள் (Day Periods):',
                            style: GoogleFonts.cinzel(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.lightGold),
                          ),
                          const SizedBox(height: 8),
                          _buildGowriGrid(_calendarData.dayGowriPeriods),
                          const SizedBox(height: 14),
                          Text(
                            'இரவு கௌரி காலங்கள் (Night Periods):',
                            style: GoogleFonts.cinzel(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.lightGold),
                          ),
                          const SizedBox(height: 8),
                          _buildGowriGrid(_calendarData.nightGowriPeriods),
                        ],
                      );
                    },
                  ),
                ),

                const SizedBox(height: 14),

                // SECTION 4: தினசரி பஞ்சாங்கம் (Tithi, Nakshatra, Yoga, Karana)
                _buildCardContainer(
                  title: 'தினசரி பஞ்சாங்கம் (Daily Panchangam)',
                  icon: Icons.calendar_month_rounded,
                  accentColor: AppColors.lightGold,
                  child: Column(
                    children: [
                      _buildTransitionSection(
                        title: 'திதி (TITHI)',
                        icon: Icons.brightness_2_rounded,
                        trans: _calendarData.tithiTransition,
                        subtitle: 'பக்ஷம்: ${_calendarData.tithiPakshaTa}',
                      ),
                      const Divider(color: AppColors.borderGold, height: 20),
                      _buildTransitionSection(
                        title: 'நட்சத்திரம் (Nakshatra)',
                        icon: Icons.star_rate_rounded,
                        trans: _calendarData.nakshatraTransition,
                        subtitle: '${_calendarData.nakshatraPada}-ஆம் பாதம் • நாதன்: ${_calendarData.nakshatraLordTa}',
                      ),
                      const Divider(color: AppColors.borderGold, height: 20),
                      _buildTransitionSection(
                        title: 'நாம யோகம் (Nama Yoga)',
                        icon: Icons.merge_type_rounded,
                        trans: _calendarData.yogaTransition,
                      ),
                      const Divider(color: AppColors.borderGold, height: 20),
                      _buildInfoRow('அமிர்தாதி யோகம்', _calendarData.amirthathiYogaTa, highlight: true),
                      const Divider(color: AppColors.borderGold, height: 20),
                      _buildTransitionSection(
                        title: 'கரணம் (Karana)',
                        icon: Icons.pie_chart_rounded,
                        trans: _calendarData.karanaTransition,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // SECTION 5 & 6: சந்திராஷ்டமம் & நேந்திரம் / ஜீவன்
                _buildCardContainer(
                  title: 'சந்திராஷ்டமம் & நேந்திரம் / ஜீவன்',
                  icon: Icons.shield_rounded,
                  accentColor: Colors.purpleAccent,
                  child: Column(
                    children: [
                      _buildInfoRow('சந்திராஷ்டம ராசி', _calendarData.chandrashtamaRasiTa, highlight: true),
                      _buildInfoRow('சந்திராஷ்டம நட்சத்திரங்கள்', _calendarData.chandrashtamaNakshatrasTa),
                      const Divider(color: AppColors.borderGold, height: 16),
                      _buildInfoRow('நேந்திரம்', _calendarData.nendhiramTa),
                      _buildInfoRow('ஜீவன்', _calendarData.jeevanTa),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // SECTION 7: ராகு காலம், குளிகை, எமகண்டம், அபிஜித்
                _buildCardContainer(
                  title: 'தினசரி முக்கிய நேரங்கள் & அபிஜித்',
                  icon: Icons.timer_rounded,
                  accentColor: Colors.orangeAccent,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildTimingTile(
                              icon: Icons.wb_twilight_rounded,
                              title: 'சூரிய உதயம்',
                              timing: _calendarData.sunriseStr,
                              badgeColor: Colors.amberAccent,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildTimingTile(
                              icon: Icons.wb_sunny_outlined,
                              title: 'சூரிய அஸ்தமனம்',
                              timing: _calendarData.sunsetStr,
                              badgeColor: Colors.orangeAccent,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTimingTile(
                              icon: Icons.warning_amber_rounded,
                              title: 'ராகு காலம்',
                              timing: _calendarData.rahuKalam,
                              badgeColor: Colors.redAccent,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildTimingTile(
                              icon: Icons.hourglass_bottom_rounded,
                              title: 'குளிகை காலம்',
                              timing: _calendarData.gulikaiKalam,
                              badgeColor: Colors.tealAccent,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTimingTile(
                              icon: Icons.cancel_outlined,
                              title: 'எமகண்டம்',
                              timing: _calendarData.yamaGandam,
                              badgeColor: Colors.redAccent,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildTimingTile(
                              icon: Icons.star_rounded,
                              title: 'அபிஜித் முகூர்த்தம்',
                              timing: _calendarData.abhijitMuhurtham,
                              badgeColor: Colors.greenAccent,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // SECTION 8 & 9: சூலம் & பரிகாரம் & நாழிகை
                _buildCardContainer(
                  title: 'சூலம், பரிகாரம் & நாழிகை கணக்குகள்',
                  icon: Icons.explore_rounded,
                  accentColor: Colors.tealAccent,
                  child: Column(
                    children: [
                      _buildInfoRow('சூலம் திசை', _calendarData.soolamDirectionTa),
                      _buildInfoRow('பரிகாரம்', _calendarData.pariharamTa, highlight: true),
                      const Divider(color: AppColors.borderGold, height: 16),
                      _buildInfoRow('உதயாத நாழிகை', _calendarData.udayathiNazhigai),
                      _buildInfoRow('நட்சத்திர நாழிகை', _calendarData.nakshatraNazhigai),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // SECTION 10: இன்றைய கோச்சார ராசி கட்டம் (Transit Chart)
                _buildCardContainer(
                  title: 'இன்றைய கோச்சார ராசி கட்டம் (Daily Transit Chart)',
                  icon: Icons.grid_view_rounded,
                  accentColor: AppColors.primaryGold,
                  child: Column(
                    children: [
                      SouthIndianRasiChart(
                        title: 'கோச்சார சக்கரம் (${_calendarData.englishDate})',
                        planets: _calendarData.rawPlanets,
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'கிரகங்களின் கோச்சார நிலைகள் (Planetary Longitudes):',
                        style: GoogleFonts.cinzel(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.lightGold),
                      ),
                      const SizedBox(height: 8),
                      ..._calendarData.transits.map((t) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundMid,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: Row(
                            children: [
                              Text(
                                t.nameTa,
                                style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              const SizedBox(width: 6),
                              Text('(${t.nameEn})', style: GoogleFonts.outfit(fontSize: 10, color: AppColors.textSecondary)),
                              if (t.isRetrograde) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: Colors.cyan.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: Colors.cyanAccent, width: 0.6),
                                  ),
                                  child: Text('வக்ரம்', style: GoogleFonts.outfit(fontSize: 8.5, color: Colors.cyanAccent)),
                                ),
                              ],
                              const Spacer(),
                              Text(
                                '${t.rasiNameTa} • ${t.formattedDMS}',
                                style: GoogleFonts.outfit(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.lightGold),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${t.nakshatraNameTa} (${t.pada})',
                                style: GoogleFonts.outfit(fontSize: 10.5, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),


                const SizedBox(height: 14),

                // SECTION 11: கோச்சார லக்னம் (Transit Lagna 2-hour Progression)
                _buildCardContainer(
                  title: 'கோச்சார லக்னம் (Transit Lagna - 2 மணி நேர சுழற்சி)',
                  icon: Icons.auto_awesome_rounded,
                  accentColor: Colors.amberAccent,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGold.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.5)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.stars_rounded, color: AppColors.primaryGold, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'நடப்பு கோச்சார லக்னம்: ${_calendarData.currentTransitLagna}',
                                style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.lightGold),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'சூரியன் இருக்கும் ராசியில் உதயமாகி, 2 மணி நேரத்திற்கு ஒரு முறை அடுத்த ராசிக்கு மாற்றம் ஏற்படும் கால அட்டவணை:',
                        style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 10),
                      ..._calendarData.transitLagnas.map((lagna) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: lagna.isCurrent ? AppColors.primaryGold.withValues(alpha: 0.18) : AppColors.backgroundMid,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: lagna.isCurrent ? AppColors.primaryGold : Colors.white10,
                              width: lagna.isCurrent ? 1.2 : 0.8,
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(
                                '${lagna.rasiNameTa} (${lagna.rasiNameEn})',
                                style: GoogleFonts.outfit(
                                  fontSize: 12.5,
                                  fontWeight: lagna.isCurrent ? FontWeight.bold : FontWeight.w500,
                                  color: lagna.isCurrent ? AppColors.lightGold : Colors.white,
                                ),
                              ),
                              if (lagna.isCurrent) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withValues(alpha: 0.25),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: Colors.greenAccent, width: 0.6),
                                  ),
                                  child: Text('தற்போது', style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.greenAccent)),
                                ),
                              ],
                              const Spacer(),
                              Text(
                                lagna.timeRange,
                                style: GoogleFonts.outfit(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: lagna.isCurrent ? Colors.white : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // SECTION 12: இன்று நடந்த முக்கிய நிகழ்வுகள்
                _buildCardContainer(
                  title: 'இன்று நடந்த முக்கிய நிகழ்வுகள் (Special Events)',
                  icon: Icons.festival_rounded,
                  accentColor: Colors.greenAccent,
                  child: _calendarData.specialEvents.isEmpty
                      ? Row(
                          children: [
                            const Icon(Icons.info_outline, color: AppColors.textSecondary, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              'இன்றைக்கு குறிப்பிடத்தக்க நிகழ்வுகள் இல்லை.',
                              style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary, fontStyle: FontStyle.italic),
                            ),
                          ],
                        )
                      : Column(
                          children: _calendarData.specialEvents.map((evt) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 6),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.5)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.celebration_rounded, color: Colors.greenAccent, size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      evt,
                                      style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
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

  Widget _buildCardContainer({
    required String title,
    required IconData icon,
    required Color accentColor,
    required Widget child,
    Widget? trailing,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accentColor.withValues(alpha: 0.45), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: accentColor, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.cinzel(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.lightGold,
                    ),
                  ),
                ),
                if (trailing != null) trailing,
              ],
            ),
            const Divider(color: AppColors.borderGold, height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: GoogleFonts.outfit(fontSize: 11.5, color: AppColors.textSecondary),
            ),
          ),
          const Text(' : ', style: TextStyle(color: AppColors.borderGold)),
          Expanded(
            flex: 6,
            child: Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: highlight ? FontWeight.bold : FontWeight.w500,
                color: highlight ? Colors.amberAccent : Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimingTile({
    required IconData icon,
    required String title,
    required String timing,
    required Color badgeColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.backgroundMid,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: badgeColor),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.outfit(fontSize: 10, color: AppColors.textSecondary)),
                Text(timing, style: GoogleFonts.outfit(fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGowriGrid(List<GowriPeriod> periods) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: periods.map((p) {
        final isCur = p.isCurrent;
        return Container(
          width: (MediaQuery.of(context).size.width - 70) / 2,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: isCur
                ? (p.isGood ? Colors.green.withValues(alpha: 0.28) : Colors.red.withValues(alpha: 0.24))
                : (p.isGood ? Colors.green.withValues(alpha: 0.12) : Colors.red.withValues(alpha: 0.1)),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isCur
                  ? (p.isGood ? const Color(0xFF00E676) : const Color(0xFFFF1744))
                  : (p.isGood ? Colors.greenAccent.withValues(alpha: 0.5) : Colors.redAccent.withValues(alpha: 0.4)),
              width: isCur ? 1.6 : 1.0,
            ),
            boxShadow: isCur
                ? [
                    BoxShadow(
                      color: (p.isGood ? Colors.greenAccent : Colors.redAccent).withValues(alpha: 0.3),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    p.nameTa,
                    style: GoogleFonts.outfit(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: p.isGood ? Colors.greenAccent : Colors.redAccent,
                    ),
                  ),
                  if (isCur) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: (p.isGood ? Colors.greenAccent : Colors.redAccent).withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        'தற்போது',
                        style: GoogleFonts.outfit(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ],
                  const Spacer(),
                  Text(
                    p.isGood ? 'சுபம்' : 'அசுபம்',
                    style: GoogleFonts.outfit(fontSize: 9, color: p.isGood ? Colors.greenAccent : Colors.redAccent),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                p.timeRange,
                style: GoogleFonts.outfit(
                  fontSize: 10,
                  color: isCur ? Colors.white : Colors.white70,
                  fontWeight: isCur ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTransitionSection({
    required String title,
    required IconData icon,
    required PanchangamTransition trans,
    String? subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: AppColors.primaryGold),
            const SizedBox(width: 6),
            Text(
              title,
              style: GoogleFonts.cinzel(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.lightGold),
            ),
            if (subtitle != null) ...[
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  subtitle,
                  style: GoogleFonts.outfit(fontSize: 10.5, color: AppColors.textSecondary),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.backgroundMid,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('இன்றைய நிலை:', style: GoogleFonts.outfit(fontSize: 9.5, color: AppColors.textSecondary)),
                        Text(trans.currentName, style: GoogleFonts.outfit(fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.white)),
                      ],
                    ),
                  ),
                  Text(
                    trans.currentTiming,
                    style: GoogleFonts.outfit(fontSize: 10.5, color: Colors.amberAccent, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const Divider(color: Colors.white10, height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('முந்தையது: ${trans.previousName}', style: GoogleFonts.outfit(fontSize: 9.5, color: AppColors.textSecondary)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'அடுத்தது: ${trans.nextName}',
                      textAlign: TextAlign.end,
                      style: GoogleFonts.outfit(fontSize: 9.5, color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
