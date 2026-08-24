import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../models/dosham_result_model.dart';
import '../../models/horoscope_calculation_result.dart';
import '../../models/jaathaga_kurippugal_model.dart';
import '../../models/planet_status_model.dart';
import '../../models/user_model.dart';
import '../../models/varga_chart_model.dart';
import '../../models/yogi_calculation_result.dart';
import '../../services/aadhi_antha_nazhigai_calculator.dart';
import '../../services/ashtakavarga_calculator.dart';
import '../../services/astrology_calculator.dart';
import '../../services/auth_service.dart';
import '../../services/dina_suddhi_calculator.dart';
import '../../services/jaathaga_kurippugal_calculator.dart';
import '../../services/nazhigai_calculator.dart';
import '../../services/pdf_generator_service.dart';
import '../../services/planet_status_calculator.dart';
import '../../services/rahu_ketu_dosham_calculator.dart';
import '../../services/sevvai_dosham_calculator.dart';
import '../../services/varga_calculator.dart';
import '../../services/yogi_calculator.dart';
import '../../widgets/astro_card.dart';
import '../../widgets/cosmic_background.dart';
import '../../widgets/south_indian_jathagam_widget.dart';
import '../../widgets/varga_chart_widget.dart';
import 'package:printing/printing.dart';

class JaathagaKurippugalScreen extends StatefulWidget {
  const JaathagaKurippugalScreen({super.key});

  @override
  State<JaathagaKurippugalScreen> createState() => _JaathagaKurippugalScreenState();
}

class _JaathagaKurippugalScreenState extends State<JaathagaKurippugalScreen> with SingleTickerProviderStateMixin {
  late UserModel _user;
  late HoroscopeCalculationResult _astroData;
  late JaathagaKurippugalResult _notes;
  late PlanetStatusReport _planetStatusReport;
  late YogiCalculationResult _yogiResult;
  late SevvaiDoshamResult _sevvaiResult;
  late RahuKetuDoshamResult _rahuKetuResult;
  late AshtakavargaResult _ashtakavargaResult;
  late AadhiAnthaNazhigaiResult _aadhiAnthaResult;
  late DinaSuddhiResult _dinaSuddhiResult;
  
  VargaType _selectedVarga = VargaType.d9;
  late VargaChartResult _currentVargaResult;

  int _selectedTabIndex = 0;

  final List<String> _tabs = [
    'பொது & பஞ்சாங்கம்',
    'வர்க்க சக்கரம் (D1-D60)',
    'யோகி / அவயோகி',
    'கிரக நிலைகள் & நட்பு',
    'நாழிகை கணக்குகள்',
    'தினசுத்தி',
    'செவ்வாய் / ராகு தோஷம்',
    'அஷ்டவர்க்கம்',
  ];

  @override
  void initState() {
    super.initState();
    _loadAndCalculateData();
  }

  void _loadAndCalculateData() {
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

    final parsedDob = DateTime.tryParse(_user.dob) ?? DateTime(1996, 6, 15);
    final tobParts = _user.timeOfBirth.split(':');
    int hour = 8;
    int minute = 30;
    if (tobParts.length >= 2) {
      hour = int.tryParse(tobParts[0].replaceAll(RegExp(r'[^0-9]'), '')) ?? 8;
      minute = int.tryParse(tobParts[1].replaceAll(RegExp(r'[^0-9]'), '')) ?? 30;
      if (_user.timeOfBirth.toUpperCase().contains('PM') && hour < 12) hour += 12;
      if (_user.timeOfBirth.toUpperCase().contains('AM') && hour == 12) hour = 0;
    }

    final birthDt = DateTime(parsedDob.year, parsedDob.month, parsedDob.day, hour, minute);

    _astroData = AstrologyCalculator.calculateHoroscope(
      dateOfBirth: birthDt,
      latitude: _user.latitude,
      longitude: _user.longitude,
      utcOffsetHours: _user.timezone,
    );

    _notes = JaathagaKurippugalCalculator.calculateNotes(user: _user, birthDateTime: birthDt);
    _planetStatusReport = PlanetStatusCalculator.calculatePlanetStatuses(_astroData.planets);
    _yogiResult = YogiCalculator.calculateYogi(
      sunLongitude: _astroData.sun.longitude,
      moonLongitude: _astroData.moon.longitude,
    );
    _sevvaiResult = SevvaiDoshamCalculator.calculateSevvaiDosham(_astroData.planets);
    _rahuKetuResult = RahuKetuDoshamCalculator.calculateRahuKetuDosham(_astroData.planets);
    _ashtakavargaResult = AshtakavargaCalculator.calculateAshtakavarga(_astroData.planets);
    _aadhiAnthaResult = AadhiAnthaNazhigaiCalculator.calculate(
      moonLongitude: _astroData.moon.longitude,
      nakshatraNameTa: _astroData.moon.nakshatraNameTa,
    );
    _dinaSuddhiResult = DinaSuddhiCalculator.calculate(
      date: birthDt,
      sunLongitude: _astroData.sun.longitude,
      moonLongitude: _astroData.moon.longitude,
      latitude: _user.latitude,
      longitude: _user.longitude,
      utcOffsetHours: _user.timezone,
    );

    _currentVargaResult = VargaCalculator.calculateVarga(type: _selectedVarga, planets: _astroData.planets);
  }

  void _onVargaChanged(VargaType newVarga) {
    setState(() {
      _selectedVarga = newVarga;
      _currentVargaResult = VargaCalculator.calculateVarga(type: newVarga, planets: _astroData.planets);
    });
  }

  void _printPdf() async {
    final pdfBytes = await PdfGeneratorService.generateHoroscopePdf(user: _user);
    await Printing.layoutPdf(onLayout: (format) async => pdfBytes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CosmicBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                            'ஜாதக குறிப்புகள்',
                            style: GoogleFonts.cinzel(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.lightGold,
                              letterSpacing: 1.2,
                            ),
                          ),
                          Text(
                            '${_user.name} • ${_user.dob}',
                            style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.picture_as_pdf_rounded, color: AppColors.primaryGold),
                      tooltip: 'PDF அச்சிடு (Print Horoscope PDF)',
                      onPressed: _printPdf,
                    ),
                    IconButton(
                      icon: const Icon(Icons.tune_rounded, color: AppColors.lightGold),
                      tooltip: 'PDF Settings',
                      onPressed: () => Navigator.of(context).pushNamed('/pdf_settings'),
                    ),
                  ],
                ),
              ),

              // Filter / Section Tabs Scrollable Horizontal Bar
              SizedBox(
                height: 44,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: _tabs.length,
                  itemBuilder: (context, idx) {
                    final isSelected = _selectedTabIndex == idx;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Text(
                          _tabs[idx],
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? Colors.black : AppColors.lightGold,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: AppColors.primaryGold,
                        backgroundColor: AppColors.backgroundMid,
                        side: BorderSide(
                          color: isSelected ? AppColors.primaryGold : AppColors.borderGold.withValues(alpha: 0.4),
                        ),
                        onSelected: (val) {
                          if (val) setState(() => _selectedTabIndex = idx);
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),

              // Tab Body Content
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: _buildCurrentTabContent(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildGeneralAndPanchangTab();
      case 1:
        return _buildVargaChartsTab();
      case 2:
        return _buildYogiTab();
      case 3:
        return _buildPlanetStatusTab();
      case 4:
        return _buildNazhigaiTab();
      case 5:
        return _buildDinaSuddhiTab();
      case 6:
        return _buildDoshamTab();
      case 7:
        return _buildAshtakavargaTab();
      default:
        return _buildGeneralAndPanchangTab();
    }
  }

  // ---------------------------------------------------------------------------
  // Tab 0: General & Panchangam
  // ---------------------------------------------------------------------------
  Widget _buildGeneralAndPanchangTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionCard(
          title: 'பிறப்பு விவரங்கள் (Birth Profile)',
          icon: Icons.person_rounded,
          rows: [
            _InfoRow('ஜாதகர் பெயர்', _notes.personName),
            _InfoRow('பாலினம்', _notes.gender),
            _InfoRow('வயது', _notes.age),
            _InfoRow('பிறந்த ஆங்கில தேதி', _notes.englishDate),
            _InfoRow('தமிழ் தேதி', _notes.tamilDate),
            _InfoRow('கிழமை', _notes.weekday),
            _InfoRow('பிறந்த நேரம்', _notes.timeOfBirth),
            _InfoRow('பிறந்த இடம்', _notes.placeOfBirth),
          ],
        ),
        const SizedBox(height: 14),
        _buildSectionCard(
          title: 'பஞ்சாங்க விவரங்கள் (Birth Panchangam)',
          icon: Icons.calendar_today_rounded,
          rows: [
            _InfoRow('லக்னம்', '${_notes.lagna} (${_notes.lagnaDegree})'),
            _InfoRow('ராசி', _notes.rasi),
            _InfoRow('நட்சத்திரம்', '${_notes.nakshatra} (${_notes.pada})'),
            _InfoRow('நட்சத்திர நாதன்', _notes.starLord),
            _InfoRow('திதி', '${_notes.paksha} ${_notes.thithi}'),
            _InfoRow('யோகம்', _notes.yoga),
            _InfoRow('கரணம்', _notes.karanam),
            _InfoRow('அமிர்தாதி யோகம்', _notes.amirthathiYoga),
            _InfoRow('முக்குண வேளை', _notes.mukkunaVelai),
          ],
        ),
        const SizedBox(height: 14),
        _buildSectionCard(
          title: 'சூரிய நேரங்கள் & விசேஷ குறிப்புகள்',
          icon: Icons.wb_sunny_rounded,
          rows: [
            _InfoRow('சூரிய உதயம்', _notes.sunrise),
            _InfoRow('சூரிய அஸ்தமனம்', _notes.sunset),
            _InfoRow('திதி சூன்ய ராசிகள்', _notes.thithiSunyam),
            _InfoRow('நாம எழுத்துக்கள்', _notes.nameLetters),
            _InfoRow('கணம் / யோனி', '${_notes.gana} / ${_notes.yoni}'),
            _InfoRow('ரஜ்ஜு / பறவை', '${_notes.rajju} / ${_notes.bird}'),
            _InfoRow('மரம் / வகை', '${_notes.tree} (${_notes.treeType})'),
          ],
        ),
        const SizedBox(height: 14),
        SouthIndianJathagamWidget(user: _user),
        const SizedBox(height: 20),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Tab 1: Varga Divisional Charts (D1 to D60)
  // ---------------------------------------------------------------------------
  Widget _buildVargaChartsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.borderGold.withValues(alpha: 0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'வர்க்க சக்கர தேர்வு (Select Divisional Chart)',
                style: GoogleFonts.cinzel(color: AppColors.lightGold, fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.backgroundMid,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.primaryGold),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<VargaType>(
                    value: _selectedVarga,
                    isExpanded: true,
                    dropdownColor: AppColors.backgroundDeep,
                    icon: const Icon(Icons.arrow_drop_down_rounded, color: AppColors.primaryGold),
                    items: VargaType.values.map((v) {
                      return DropdownMenuItem<VargaType>(
                        value: v,
                        child: Text(
                          '${v.code} - ${v.tamilName} (${v.englishName})',
                          style: GoogleFonts.outfit(fontSize: 13, color: AppColors.lightGold, fontWeight: FontWeight.w600),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) _onVargaChanged(val);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'முக்கியத்துவம்: ${_selectedVarga.significance}',
                style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 11),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        VargaChartWidget(vargaResult: _currentVargaResult),
        const SizedBox(height: 16),

        // Table of planetary placements in current Varga
        _buildSectionCard(
          title: '${_selectedVarga.code} கிரக அமைப்புகள்',
          icon: Icons.list_alt_rounded,
          rows: _currentVargaResult.planets.values.map((p) {
            return _InfoRow(p.tamilName, '${p.rasiNameTa} (${p.rasiNameEn}) - ${p.degreeInVarga.toStringAsFixed(2)}°');
          }).toList(),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Tab 2: Yogi / Ava Yogi / Anu Yogi
  // ---------------------------------------------------------------------------
  Widget _buildYogiTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionCard(
          title: 'யோகி & அவயோகி கணிதம் (Yogi Details)',
          icon: Icons.stars_rounded,
          rows: [
            _InfoRow('யோகி புள்ளி பாகை', _yogiResult.yogiDegreeFormatted),
            _InfoRow('யோகி ராசி', '${_yogiResult.yogiRasiTa} (${_yogiResult.yogiRasiEn})'),
            _InfoRow('யோகி நட்சத்திரம்', '${_yogiResult.yogiNakshatraTa} (${_yogiResult.yogiPada}-ஆம் பாதம்)'),
            _InfoRow('யோகி கிரகம் (தலைமை சுப காரகர்)', _yogiResult.yogiPlanetTa),
            _InfoRow('அவயோகி ராசி', _yogiResult.avaYogiRasiTa),
            _InfoRow('அவயோகி நட்சத்திரம்', _yogiResult.avaYogiNakshatraTa),
            _InfoRow('அவயோகி கிரகம் (எச்சரிக்கை கிரகம்)', _yogiResult.avaYogiPlanetTa),
            _InfoRow('அனுயோகி நட்சத்திரம் / கிரகம்', '${_yogiResult.anuYogiNakshatraTa} / ${_yogiResult.anuYogiPlanetTa}'),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.backgroundMid,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ஜோதிட விளக்கம்:', style: GoogleFonts.cinzel(color: AppColors.primaryGold, fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 6),
              Text(_yogiResult.yogiDescription, style: GoogleFonts.poppins(color: Colors.white, fontSize: 12)),
              const SizedBox(height: 6),
              Text(_yogiResult.avaYogiDescription, style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12)),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Tab 3: Detailed Planet Status (Friendship, Combustion, Debilitation, Retrograde)
  // ---------------------------------------------------------------------------
  Widget _buildPlanetStatusTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary metrics
        Row(
          children: [
            Expanded(child: _buildMetricMiniCard('ஆட்சி / உச்சம்', '${_planetStatusReport.ownHouseCount + _planetStatusReport.exaltedCount}', Colors.greenAccent)),
            const SizedBox(width: 8),
            Expanded(child: _buildMetricMiniCard('அஸ்தமனம்', '${_planetStatusReport.combustCount}', Colors.orangeAccent)),
            const SizedBox(width: 8),
            Expanded(child: _buildMetricMiniCard('நீசம்', '${_planetStatusReport.debilitatedCount}', Colors.redAccent)),
            const SizedBox(width: 8),
            Expanded(child: _buildMetricMiniCard('வக்ரம்', '${_planetStatusReport.retrogradeCount}', Colors.cyanAccent)),
          ],
        ),
        const SizedBox(height: 14),

        // Structured Table
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.5)),
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
                DataColumn(label: Text('நிலை / நட்பு', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.lightGold, fontSize: 11))),
                DataColumn(label: Text('அஸ்தமனம்', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.lightGold, fontSize: 11))),
                DataColumn(label: Text('நீசம் / உச்சம்', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.lightGold, fontSize: 11))),
                DataColumn(label: Text('வக்ரம்', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.lightGold, fontSize: 11))),
              ],
              rows: _planetStatusReport.planetStatuses.map((s) {
                return DataRow(
                  cells: [
                    DataCell(Text(s.nameTa, style: GoogleFonts.outfit(color: AppColors.lightGold, fontWeight: FontWeight.bold, fontSize: 11))),
                    DataCell(Text(s.rasiNameTa, style: GoogleFonts.outfit(color: Colors.white, fontSize: 11))),
                    DataCell(Text(s.dignity.tamilLabel, style: GoogleFonts.outfit(color: Colors.white70, fontSize: 11))),
                    DataCell(Text(s.isCombust ? 'ஆம் (Combust)' : 'இல்லை', style: GoogleFonts.outfit(color: s.isCombust ? Colors.orangeAccent : Colors.white60, fontSize: 11))),
                    DataCell(Text(s.isDebilitated ? 'நீசம்' : (s.isExalted ? 'உச்சம்' : 'இயல்பு'), style: GoogleFonts.outfit(color: s.isDebilitated ? Colors.redAccent : (s.isExalted ? Colors.greenAccent : Colors.white60), fontSize: 11))),
                    DataCell(Text(s.isRetrograde ? 'வக்ரம்' : 'நேர்கதி', style: GoogleFonts.outfit(color: s.isRetrograde ? Colors.cyanAccent : Colors.white60, fontSize: 11))),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Tab 4: Nazhigai (Udayathi & Aadhi/Andha/Parama Nazhigai)
  // ---------------------------------------------------------------------------
  Widget _buildNazhigaiTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionCard(
          title: 'ஆதி அந்த பரம நாழிகை (Nakshatra Duration Metrics)',
          icon: Icons.timer_rounded,
          rows: [
            _InfoRow('நட்சத்திரம்', '${_aadhiAnthaResult.nakshatraNameTa} (${_aadhiAnthaResult.pada}-ஆம் பாதம்)'),
            _InfoRow('பரம நாழிகை (மொத்த அளவு)', _aadhiAnthaResult.paramaNazhigaiFormatted),
            _InfoRow('ஆதி நாழிகை (சென்ற நாழிகை)', _aadhiAnthaResult.aadhiNazhigaiFormatted),
            _InfoRow('அந்த நாழிகை (இருப்பு நாழிகை)', _aadhiAnthaResult.andhaNazhigaiFormatted),
            _InfoRow('நட்சத்திர முன்னேற்றம்', '${_aadhiAnthaResult.progressPercent.toStringAsFixed(1)}%'),
          ],
        ),
        const SizedBox(height: 14),

        _buildSectionCard(
          title: 'உதயாதி நாழிகை (Udayathi Nazhigai)',
          icon: Icons.alarm_on_rounded,
          rows: [
            _InfoRow('சூரிய உதயம்', _notes.sunrise),
            _InfoRow('பிறந்த நேரம்', _notes.timeOfBirth),
            _InfoRow('உதயாதி நாழிகை முடிவு', _notes.udayathiNazhi),
            _InfoRow('பிறந்த நேர ஓரை', _notes.hora),
            _InfoRow('அகஸ் (பகல் அளவு)', _notes.akas),
            _InfoRow('நேந்திரம் / ஜீவன்', '${_notes.nendhiram} / ${_notes.jeevan}'),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Tab 5: Dina Suddhi
  // ---------------------------------------------------------------------------
  Widget _buildDinaSuddhiTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.backgroundMid,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.primaryGold, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.verified_rounded, color: AppColors.primaryGold, size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('தினசுத்தி மதிப்பீடு:', style: GoogleFonts.cinzel(color: AppColors.lightGold, fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(_dinaSuddhiResult.overallPurityScore, style: GoogleFonts.outfit(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 4),
              Text(_dinaSuddhiResult.finalVerdictTa, style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12)),
            ],
          ),
        ),
        const SizedBox(height: 14),

        _buildSectionCard(
          title: 'முக்கிய நேர காலங்கள் (Kalam Windows)',
          icon: Icons.timelapse_rounded,
          rows: [
            _InfoRow('ராகு காலம்', _dinaSuddhiResult.rahuKalam),
            _InfoRow('எமகண்டம்', _dinaSuddhiResult.yamaGandam),
            _InfoRow('குளிகை காலம்', _dinaSuddhiResult.gulikaiKalam),
            _InfoRow('அபிஜித் முகூர்த்தம்', _dinaSuddhiResult.abhijitMuhurtham),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Tab 6: Dosham (Sevvai & Rahu Ketu)
  // ---------------------------------------------------------------------------
  Widget _buildDoshamTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sevvai Dosham Card
        _buildSectionCard(
          title: 'செவ்வாய் தோஷ ஆய்வு (Sevvai / Manglik Dosham)',
          icon: Icons.shield_rounded,
          rows: [
            _InfoRow('தோஷ நிலை', _sevvaiResult.hasDosham ? 'தோஷம் உள்ளது' : (_sevvaiResult.hasExemption ? 'தோஷ நிவர்த்தி (Cancelled)' : 'தோஷம் இல்லை')),
            _InfoRow('தீவிர நிலை (Severity)', _sevvaiResult.severityLevel),
            _InfoRow('செவ்வாய் அமர்ந்த ராசி', _sevvaiResult.marsRasiTa),
            _InfoRow('லக்னத்திலிருந்து இடம்', '${_sevvaiResult.houseFromLagna}-ஆம் இடம்'),
            _InfoRow('சந்திரனிலிருந்து இடம்', '${_sevvaiResult.houseFromMoon}-ஆம் இடம்'),
            _InfoRow('விளக்கம்', _sevvaiResult.summaryTamil),
          ],
        ),
        const SizedBox(height: 14),

        // Rahu Ketu / Kalasarpa Dosham Card
        _buildSectionCard(
          title: 'ராகு கேது & காலசர்ப்ப தோஷ ஆய்வு',
          icon: Icons.all_inclusive_rounded,
          rows: [
            _InfoRow('காலசர்ப்ப தோஷம்', _rahuKetuResult.hasKalasarpaDosham ? _rahuKetuResult.kalasarpaTypeTa : 'இல்லை'),
            _InfoRow('சர்ப்ப தோஷ நிலை', _rahuKetuResult.hasSarpaDosham ? 'சர்ப்ப தோஷம் உள்ளது' : 'இல்லை'),
            _InfoRow('ராகு அமர்வு', 'லக்னத்திலிருந்து ${_rahuKetuResult.rahuHouseFromLagna}-ஆம் வீடு (${_rahuKetuResult.rahuRasiTa})'),
            _InfoRow('கேது அமர்வு', 'லக்னத்திலிருந்து ${_rahuKetuResult.ketuHouseFromLagna}-ஆம் வீடு (${_rahuKetuResult.ketuRasiTa})'),
            _InfoRow('விளக்கம்', _rahuKetuResult.summaryTamil),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Tab 7: Ashtakavarga
  // ---------------------------------------------------------------------------
  Widget _buildAshtakavargaTab() {
    final planets7 = ['Sun', 'Moon', 'Mars', 'Mercury', 'Jupiter', 'Venus', 'Saturn'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.backgroundMid,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primaryGold),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text('சர்வ அஷ்டவர்க்க மொத்த புள்ளிகள் (Total SAV):', style: GoogleFonts.outfit(color: AppColors.lightGold, fontWeight: FontWeight.bold, fontSize: 13)),
              ),
              const SizedBox(width: 8),
              Text('${_ashtakavargaResult.totalSavPoints} / 337', style: GoogleFonts.outfit(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 15)),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // SAV Points Row
        _buildSectionCard(
          title: 'ராசி வாரியாக சர்வ அஷ்டவர்க்க பரல்கள் (SAV)',
          icon: Icons.grid_view_rounded,
          rows: List.generate(12, (i) {
            final rasiName = AstrologyCalculator.rasiNamesTa[i];
            final points = _ashtakavargaResult.sarvashtakavarga[i];
            return _InfoRow(rasiName, '$points பரல்கள் ${points >= 28 ? "(சுபம்)" : "(மத்திமம்)"}');
          }),
        ),
        const SizedBox(height: 14),

        // BAV Table for 7 Planets
        Text('பின்ன அஷ்டவர்க்க அட்டவணை (BAV)', style: GoogleFonts.cinzel(color: AppColors.lightGold, fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderGold.withValues(alpha: 0.5)),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowHeight: 36,
              dataRowMinHeight: 32,
              dataRowMaxHeight: 36,
              columnSpacing: 10,
              horizontalMargin: 8,
              headingRowColor: WidgetStateProperty.all(AppColors.backgroundMid),
              columns: [
                DataColumn(label: Text('கிரகம்', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.lightGold, fontSize: 10))),
                ...AstrologyCalculator.rasiNamesTa.map((r) => DataColumn(label: Text(r.substring(0, 2), style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.lightGold, fontSize: 10)))),
              ],
              rows: planets7.map((pKey) {
                final planetTa = AstrologyCalculator.planetNameToTamil[pKey] ?? pKey;
                final bindus = _ashtakavargaResult.bhinnashtakavarga[pKey] ?? List.filled(12, 0);
                return DataRow(
                  cells: [
                    DataCell(Text(planetTa, style: GoogleFonts.outfit(color: AppColors.lightGold, fontWeight: FontWeight.bold, fontSize: 10))),
                    ...bindus.map((b) => DataCell(Text('$b', style: GoogleFonts.outfit(color: Colors.white, fontSize: 10)))),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Helper UI Builders
  // ---------------------------------------------------------------------------
  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<_InfoRow> rows,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderGold.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primaryGold, size: 18),
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
          ...rows.map((r) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 130,
                      child: Text(
                        r.label,
                        style: GoogleFonts.outfit(fontSize: 11.5, color: AppColors.textSecondary),
                      ),
                    ),
                    const Text(' :  ', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                    Expanded(
                      child: Text(
                        r.value,
                        style: GoogleFonts.outfit(fontSize: 11.5, fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildMetricMiniCard(String label, String val, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      decoration: BoxDecoration(
        color: AppColors.backgroundMid,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Text(label, style: GoogleFonts.outfit(fontSize: 9, color: AppColors.textSecondary)),
          const SizedBox(height: 2),
          Text(val, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}

class _InfoRow {
  final String label;
  final String value;
  _InfoRow(this.label, this.value);
}
