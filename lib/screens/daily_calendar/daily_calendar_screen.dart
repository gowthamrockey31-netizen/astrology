import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../models/daily_calendar_models.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/daily_calendar_engine.dart';
import '../../widgets/cosmic_background.dart';
import '../../widgets/south_indian_rasi_chart.dart';

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
          placeOfBirth: 'Chennai',
          city: 'Chennai',
          state: 'Tamil Nadu',
          country: 'India',
          zodiac: 'Gemini (Mithuna)',
          nakshatra: 'Rohini',
          lagna: 'Mesha',
          walletBalance: 500.0,
          profilePhoto: '',
          latitude: 13.0827,
          longitude: 80.2707,
          timezone: 5.5,
        );

    _recalculate();
  }

  void _recalculate() {
    _calendarData = DailyCalendarEngine.calculate(
      targetDate: _selectedDate,
      latitude: _user.latitude,
      longitude: _user.longitude,
      utcOffsetHours: _user.timezone,
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
                          Text(
                            'Daily Calendar & Panchangam • ${_user.city}',
                            style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary),
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
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // SECTION 3: கௌரி நல்ல நேரம் (Day & Night Gowri Periods)
                _buildCardContainer(
                  title: 'கௌரி நல்ல நேரம் (Gowri Panchangam)',
                  icon: Icons.auto_awesome_rounded,
                  accentColor: Colors.cyanAccent,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                        title: 'திதி (Tithi)',
                        icon: Icons.brightness_6_rounded,
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

                // SECTION 11: கிரக பாதசார குறிப்புகள்
                _buildCardContainer(
                  title: 'கிரக பாதசார குறிப்புகள்',
                  icon: Icons.notes_rounded,
                  accentColor: Colors.amberAccent,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ..._calendarData.padaSaramNotes.map((note) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('• ', style: TextStyle(color: AppColors.primaryGold, fontSize: 14)),
                              Expanded(
                                child: Text(
                                  note,
                                  style: GoogleFonts.poppins(fontSize: 11.5, color: Colors.white.withValues(alpha: 0.9)),
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
        return Container(
          width: (MediaQuery.of(context).size.width - 70) / 2,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: p.isGood ? Colors.green.withValues(alpha: 0.12) : Colors.red.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: p.isGood ? Colors.greenAccent.withValues(alpha: 0.5) : Colors.redAccent.withValues(alpha: 0.4),
            ),
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
                style: GoogleFonts.outfit(fontSize: 10, color: Colors.white70),
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('முந்தையது: ${trans.previousName}', style: GoogleFonts.outfit(fontSize: 9.5, color: AppColors.textSecondary)),
                  Text('அடுத்தது: ${trans.nextName}', style: GoogleFonts.outfit(fontSize: 9.5, color: AppColors.textSecondary)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
