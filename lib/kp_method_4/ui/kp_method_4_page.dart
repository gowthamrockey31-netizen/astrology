import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../services/auth_service.dart';
import '../../widgets/cosmic_background.dart';
import '../engine/kp4_engine.dart';
import '../models/kp4_models.dart';
import 'kp4_chart_widget.dart';
import '../../widgets/profile/family_profiles_sheet.dart';
import '../../kp_method_model_1/engine/kp_rectification_engine.dart';
import '../../kp_method_model_1/engine/kp_ruling_planet_engine.dart';
import '../../kp_method_model_1/models/kp_birth_data.dart';

/// KP Method 4 Main Screen
/// Independent module implementing the KP Method 4 UI structure:
/// 1. Header & Birth Information / Calculation Summary
/// 2. Part 1 — Rasi + Bhava Cusp (Combined chart with red cusp markers)
/// 3. Part 2 — Planet Positions (9 planets table)
/// 4. Bhava Positions (12 Bhava Cusps table)
/// 5. Part 3 — Graha Relationships (9 planets with 8/12 red, 5/9 green, '$' fallback)
/// 6. Bhava Graha Relationships (12 Bhavas with Sub Lord and Star Lord of Sub Lord relations)
/// 7. Part 4 — Dasha Relationships (Dasha -> Bhukti -> Antara -> Sookshma matching planet relations)
/// 8. Part 5 — Birth Time Rectification (Hour/Minute/Second adjustment & KP Ruling Planets candidates)
class KPMethod4Page extends StatefulWidget {
  final Kp4BirthData? initialBirthData;

  const KPMethod4Page({super.key, this.initialBirthData});

  @override
  State<KPMethod4Page> createState() => _KPMethod4PageState();
}

class _KPMethod4PageState extends State<KPMethod4Page> {
  late Kp4BirthData _originalBirthData;
  late Kp4BirthData _birthData;
  KpResult? _kpResult;
  bool _isLoading = true;
  DateTime _evaluationDate = DateTime.now();
  int _rectificationWindowMinutes = 5;

  // Selected steps for time adjustments (hour, minute, second)
  int _selectedHourStep = 1;
  int _selectedMinuteStep = 1;
  int _selectedSecondStep = 1; // Starts at 1 second only

  // Tab filter: 0=All, 1=Chart, 2=Planets, 3=Cusps, 4=Planet->Bhava, 5=Graha Rel, 6=Bhava Rel, 7=Dasha, 8=Rectification
  int _selectedSection = 0;

  final List<String> _sectionTitles = [
    'முழுமையான பார்வை (All)',
    '1. ராசி & பாவ சக்கரம்',
    '2. கிரக நிலைகள் (Planets)',
    '3. பாவ நிலைகள் (Cusps)',
    '4. கிரகம் ➔ பாவ தொடர்புகள்',
    '5. கிரக தொடர்புகள் (Graha)',
    '6. பாவ கிரக தொடர்புகள்',
    '7. தசா தொடர்புகள் (Dasha)',
    '8. நேரத் திருத்தம் (Rectification)',
  ];

  final ScrollController _planetTableController = ScrollController();
  final ScrollController _cuspTableController = ScrollController();

  @override
  void dispose() {
    _planetTableController.dispose();
    _cuspTableController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _initBirthData();
    _calculateChart();
  }

  void _initBirthData() {
    if (widget.initialBirthData != null) {
      _birthData = widget.initialBirthData!;
    } else {
      final user = AuthService.currentUser;
      if (user != null) {
        _birthData = Kp4BirthData.fromUserModel(user);
      } else {
        _birthData = Kp4BirthData.defaultProfile();
      }
    }
    _originalBirthData = _birthData;
  }

  void _calculateChart() {
    setState(() => _isLoading = true);
    try {
      final res = Kp4Engine.calculate(
        _birthData,
        evaluationTime: _evaluationDate,
      );
      setState(() {
        _kpResult = res;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('KP Method 4 Calculation error: $e'),
          backgroundColor: Colors.red.shade900,
        ),
      );
    }
  }

  void _showEditProfileDialog() {
    final dateCtrl = TextEditingController(
      text: DateFormat('dd-MM-yyyy').format(_birthData.dateTime),
    );
    final timeCtrl = TextEditingController(text: _birthData.time);
    final placeCtrl = TextEditingController(text: _birthData.place);
    final latCtrl = TextEditingController(text: _birthData.latitude.toString());
    final lonCtrl = TextEditingController(text: _birthData.longitude.toString());
    final tzCtrl = TextEditingController(text: _birthData.timezone.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.backgroundMid,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.primaryGold, width: 1.2),
        ),
        title: Row(
          children: [
            const Icon(Icons.edit_calendar_rounded, color: AppColors.primaryGold),
            const SizedBox(width: 8),
            Text(
              'சுயவிவரம் திருத்து (Edit Profile)',
              style: GoogleFonts.cinzel(
                color: AppColors.lightGold,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDialogField('பிறந்த தேதி (DD-MM-YYYY)', dateCtrl),
              _buildDialogField('பிறந்த நேரம் (HH:MM AM/PM)', timeCtrl),
              _buildDialogField('பிறந்த இடம் (City/Place)', placeCtrl),
              _buildDialogField('அட்சரேகை (Latitude)', latCtrl, isNumeric: true),
              _buildDialogField('தீர்க்கரேகை (Longitude)', lonCtrl, isNumeric: true),
              _buildDialogField('Timezone (Hours)', tzCtrl, isNumeric: true),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('ரத்து செய் (Cancel)', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGold,
              foregroundColor: Colors.black,
            ),
            onPressed: () {
              try {
                final dateParts = dateCtrl.text.split('-');
                final d = int.parse(dateParts[0]);
                final m = int.parse(dateParts[1]);
                final y = int.parse(dateParts[2]);

                int hour = 12;
                int min = 0;
                final t = timeCtrl.text.trim().toUpperCase();
                if (t.contains(':')) {
                  final isPm = t.contains('PM');
                  final isAm = t.contains('AM');
                  final cleanT = t.replaceAll('AM', '').replaceAll('PM', '').trim();
                  final tp = cleanT.split(':');
                  hour = int.tryParse(tp[0]) ?? 12;
                  min = int.tryParse(tp.length > 1 ? tp[1] : '0') ?? 0;
                  if (isPm && hour < 12) hour += 12;
                  if (isAm && hour == 12) hour = 0;
                }

                final newDt = DateTime(y, m, d, hour, min);
                final newLat = double.tryParse(latCtrl.text) ?? _birthData.latitude;
                final newLon = double.tryParse(lonCtrl.text) ?? _birthData.longitude;
                final newTz = double.tryParse(tzCtrl.text) ?? _birthData.timezone;

                setState(() {
                  _birthData = Kp4BirthData(
                    dateTime: newDt,
                    time: timeCtrl.text,
                    place: placeCtrl.text,
                    latitude: newLat,
                    longitude: newLon,
                    timezone: newTz,
                  );
                  _originalBirthData = _birthData;
                });
                Navigator.pop(ctx);
                _calculateChart();
              } catch (err) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('தவறான உள்ளீடு: $err')),
                );
              }
            },
            child: const Text('கணக்கிடு (Recalculate)'),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogField(String label, TextEditingController ctrl, {bool isNumeric = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: TextField(
        controller: ctrl,
        keyboardType: isNumeric ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.lightGold, fontSize: 13),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.borderGold.withValues(alpha: 0.5)),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: AppColors.primaryGold),
            borderRadius: BorderRadius.circular(10),
          ),
          filled: true,
          fillColor: AppColors.backgroundDeep,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDeep,
      appBar: AppBar(
        title: Text(
          'KP Method 4',
          style: GoogleFonts.cinzel(
            fontWeight: FontWeight.bold,
            color: AppColors.lightGold,
            fontSize: 18,
          ),
        ),
        backgroundColor: AppColors.backgroundMid,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'பிறந்த நேரத் திருத்தம் (Birth Time Rectification)',
            icon: const Icon(Icons.published_with_changes_rounded, color: AppColors.primaryGold),
            onPressed: () {
              setState(() => _selectedSection = 8);
            },
          ),
          IconButton(
            tooltip: 'குடும்ப ஜாதகங்கள் (Family Profiles)',
            icon: const Icon(Icons.people_alt_rounded, color: AppColors.primaryGold),
            onPressed: () => FamilyProfilesSheet.show(context, onProfileChanged: () {
              final user = AuthService.currentUser;
              if (user != null) {
                setState(() {
                  _birthData = Kp4BirthData.fromUserModel(user);
                  _originalBirthData = _birthData;
                  _calculateChart();
                });
              }
            }),
          ),
          IconButton(
            tooltip: 'சுயவிவரம் திருத்து (Edit Profile)',
            icon: const Icon(Icons.edit_calendar_rounded, color: AppColors.primaryGold),
            onPressed: _showEditProfileDialog,
          ),
          IconButton(
            tooltip: 'மறுகணக்கீடு (Refresh)',
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primaryGold),
            onPressed: _calculateChart,
          ),
        ],
      ),
      body: CosmicBackground(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primaryGold),
              )
            : _kpResult == null
                ? const Center(
                    child: Text('கணித தரவுகள் கிடைக்கவில்லை', style: TextStyle(color: Colors.white)),
                  )
                : SafeArea(
                    child: Column(
                      children: [
                        // Section Tabs
                        _buildSectionTabs(),

                        // Main Scrollable Content
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // 1. Header & Birth Details
                                _buildHeaderAndBirthSummary(_kpResult!),
                                const SizedBox(height: 14),

                                // 2. Part 1 — Rasi + Bhava Cusp (Chart)
                                if (_selectedSection == 0 || _selectedSection == 1) ...[
                                  Kp4ChartWidget(result: _kpResult!),
                                  const SizedBox(height: 16),
                                ],

                                // 3. Part 2 — Planet Positions Table
                                if (_selectedSection == 0 || _selectedSection == 2) ...[
                                  _buildPlanetPositionsCard(_kpResult!),
                                  const SizedBox(height: 16),
                                ],

                                // 4. Bhava Positions Table
                                if (_selectedSection == 0 || _selectedSection == 3) ...[
                                  _buildBhavaPositionsCard(_kpResult!),
                                  const SizedBox(height: 16),
                                ],

                                // 5. Planet-to-Bhava Contact Mapping (Planet -> [Bhava numbers])
                                if (_selectedSection == 0 || _selectedSection == 4) ...[
                                  _buildPlanetToBhavaMappingCard(_kpResult!),
                                  const SizedBox(height: 16),
                                ],

                                // 6. Part 3 — Graha Relationships
                                if (_selectedSection == 0 || _selectedSection == 5) ...[
                                  _buildGrahaRelationsCard(_kpResult!),
                                  const SizedBox(height: 16),
                                ],

                                // 7. Bhava Graha Relationships
                                if (_selectedSection == 0 || _selectedSection == 6) ...[
                                  _buildBhavaGrahaRelationsCard(_kpResult!),
                                  const SizedBox(height: 16),
                                ],

                                // 8. Part 4 — Dasha Relationships
                                if (_selectedSection == 0 || _selectedSection == 7) ...[
                                  _buildDashaRelationsCard(_kpResult!),
                                  const SizedBox(height: 16),
                                ],

                                // 9. Part 5 — Birth Time Rectification
                                if (_selectedSection == 0 || _selectedSection == 8) ...[
                                  _buildRectificationCard(_kpResult!),
                                  const SizedBox(height: 24),
                                ],
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

  Widget _buildSectionTabs() {
    return Container(
      color: AppColors.backgroundMid.withValues(alpha: 0.9),
      height: 46,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          children: List.generate(_sectionTitles.length, (index) {
            final isSelected = (_selectedSection == index);
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(
                  _sectionTitles[index],
                  style: GoogleFonts.outfit(
                    fontSize: 11.5,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? Colors.black : AppColors.lightGold,
                  ),
                ),
                selected: isSelected,
                selectedColor: AppColors.primaryGold,
                backgroundColor: AppColors.cardSurface,
                side: BorderSide(
                  color: isSelected ? AppColors.primaryGold : AppColors.borderGold.withValues(alpha: 0.3),
                ),
                onSelected: (val) {
                  if (val) setState(() => _selectedSection = index);
                },
              ),
            );
          }),
        ),
      ),
    );
  }

  // 1. Header & Birth Information Summary
  Widget _buildHeaderAndBirthSummary(KpResult res) {
    final b = res.birthData;
    final dateStr = DateFormat('dd-MM-yyyy').format(b.dateTime);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGold.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 290),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGold.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primaryGold),
                      ),
                      child: const Icon(Icons.hub_outlined, color: AppColors.primaryGold, size: 22),
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'KP Method 4',
                            style: GoogleFonts.cinzel(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.lightGold,
                            ),
                          ),
                          Text(
                            'நட்சத்திர / உப / பாவ தொடர்புகள்',
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryGold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.4)),
                ),
                child: Text(
                  'Swiss Ephemeris',
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.lightGold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.borderGold, height: 1, thickness: 0.5),
          const SizedBox(height: 10),

          // Details Grid
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _buildInfoItem(Icons.calendar_today_rounded, 'தேதி', '$dateStr (${b.time})'),
              _buildInfoItem(Icons.place_rounded, 'இடம்', b.place),
              _buildInfoItem(Icons.explore_rounded, 'அட்ச/தீர்க்கம்', '${b.latitude.toStringAsFixed(2)}°N, ${b.longitude.toStringAsFixed(2)}°E'),
              _buildInfoItem(Icons.auto_awesome_rounded, 'லக்னம்', '${res.ascendantSignTa} ${res.ascendantDegreeStr}'),
              _buildInfoItem(Icons.timelapse_rounded, 'KP Ayanamsa', res.ayanamsaStr),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 290),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primaryGold),
          const SizedBox(width: 5),
          Flexible(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary),
                  ),
                  TextSpan(
                    text: value,
                    style: GoogleFonts.outfit(fontSize: 11.5, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // 2. Part 2 — Nine-Planet Positions Table
  Widget _buildPlanetPositionsCard(KpResult res) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGold.withValues(alpha: 0.5)),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.stars_rounded, color: AppColors.primaryGold, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Part 2 — கிரக நிலைகள் (Planet Positions)',
                  style: GoogleFonts.cinzel(
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.lightGold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '9 கிரகங்களின் பாகை, நட்சத்திர நாதன், உப நாதன், உப-உப நாதன் விவரங்கள்',
            style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),

          LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= 600;
              return Theme(
                data: Theme.of(context).copyWith(
                  scrollbarTheme: ScrollbarThemeData(
                    thumbColor: WidgetStateProperty.all(AppColors.primaryGold.withValues(alpha: 0.6)),
                    thickness: WidgetStateProperty.all(4),
                    radius: const Radius.circular(4),
                  ),
                ),
                child: Scrollbar(
                  controller: _planetTableController,
                  thumbVisibility: !isDesktop,
                  child: SingleChildScrollView(
                    controller: _planetTableController,
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minWidth: isDesktop ? constraints.maxWidth : 620),
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(AppColors.backgroundMid),
                        headingRowHeight: 46,
                        dataRowMinHeight: 42,
                        dataRowMaxHeight: 52,
                        columnSpacing: 18,
                        horizontalMargin: 12,
                        headingTextStyle: GoogleFonts.cinzel(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryGold,
                        ),
                        dataTextStyle: GoogleFonts.outfit(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                        columns: const [
                          DataColumn(label: Text('Planet\n(கிரகம்)', textAlign: TextAlign.center)),
                          DataColumn(label: Text('Degree\n(பாகை)', textAlign: TextAlign.center)),
                          DataColumn(label: Text('Star Lord\n(ந.அ)', textAlign: TextAlign.center)),
                          DataColumn(label: Text('Sub Lord\n(உ.அ)', textAlign: TextAlign.center)),
                          DataColumn(label: Text('Sub-Sub Lord\n(உ.உ)', textAlign: TextAlign.center)),
                        ],
                        rows: res.planetPositions.map((p) {
                          return DataRow(
                            cells: [
                              DataCell(
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      p.planetTa,
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.lightGold),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '(${p.planet})',
                                      style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
                                    ),
                                    if (p.isRetrograde) ...[
                                      const SizedBox(width: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                        decoration: BoxDecoration(
                                          color: Colors.orange.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(3),
                                        ),
                                        child: const Text('வ', style: TextStyle(fontSize: 9, color: Colors.orangeAccent, fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              DataCell(
                                Text('${p.signNameTa} ${p.degreeStr}'),
                              ),
                              DataCell(
                                Text('${p.starLordTa} (${p.starLord})'),
                              ),
                              DataCell(
                                Text('${p.subLordTa} (${p.subLord})'),
                              ),
                              DataCell(
                                Text('${p.subSubLordTa} (${p.subSubLord})'),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // 3. Bhava Positions Table (12 Cusps)
  Widget _buildBhavaPositionsCard(KpResult res) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGold.withValues(alpha: 0.5)),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.account_tree_rounded, color: AppColors.primaryGold, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'பாவ நிலைகள் (12 Bhava Cusps)',
                  style: GoogleFonts.cinzel(
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.lightGold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '12 பிளாசிடஸ் பாவ ஆரம்ப முனைகள், நட்சத்திர/உப/உப-உப நாதர்கள்',
            style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),

          LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= 600;
              return Theme(
                data: Theme.of(context).copyWith(
                  scrollbarTheme: ScrollbarThemeData(
                    thumbColor: WidgetStateProperty.all(AppColors.primaryGold.withValues(alpha: 0.6)),
                    thickness: WidgetStateProperty.all(4),
                    radius: const Radius.circular(4),
                  ),
                ),
                child: Scrollbar(
                  controller: _cuspTableController,
                  thumbVisibility: !isDesktop,
                  child: SingleChildScrollView(
                    controller: _cuspTableController,
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minWidth: isDesktop ? constraints.maxWidth : 620),
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(AppColors.backgroundMid),
                        headingRowHeight: 46,
                        dataRowMinHeight: 42,
                        dataRowMaxHeight: 52,
                        columnSpacing: 18,
                        horizontalMargin: 12,
                        headingTextStyle: GoogleFonts.cinzel(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryGold,
                        ),
                        dataTextStyle: GoogleFonts.outfit(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                        columns: const [
                          DataColumn(label: Text('Bhava\n(பாவம்)', textAlign: TextAlign.center)),
                          DataColumn(label: Text('Cusp Degree\n(பாகை)', textAlign: TextAlign.center)),
                          DataColumn(label: Text('Star Lord\n(ந.அ)', textAlign: TextAlign.center)),
                          DataColumn(label: Text('Sub Lord\n(உ.அ)', textAlign: TextAlign.center)),
                          DataColumn(label: Text('Sub-Sub Lord\n(உ.உ)', textAlign: TextAlign.center)),
                        ],
                        rows: res.cuspPositions.map((c) {
                          final isLagna = (c.cuspNumber == 1);
                          return DataRow(
                            cells: [
                              DataCell(
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.red.withValues(alpha: 0.18),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.5)),
                                      ),
                                      child: Text(
                                        'C${c.cuspNumber}',
                                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent, fontSize: 11),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${c.cuspNumber}-ம் பாவம்${isLagna ? " (லக்னம்)" : ""}',
                                      style: TextStyle(
                                        fontWeight: isLagna ? FontWeight.bold : FontWeight.w500,
                                        color: isLagna ? AppColors.lightGold : Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              DataCell(
                                Text('${c.signNameTa} ${c.degreeStr}'),
                              ),
                              DataCell(
                                Text('${c.starLordTa} (${c.starLord})'),
                              ),
                              DataCell(
                                Text('${c.subLordTa} (${c.subLord})'),
                              ),
                              DataCell(
                                Text('${c.subSubLordTa} (${c.subSubLord})'),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // 4. Planet-to-Bhava Contact Mapping (கிரகம் ➔ பாவ தொடர்புகள்)
  Widget _buildPlanetToBhavaMappingCard(KpResult res) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGold.withValues(alpha: 0.5)),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.alt_route_rounded, color: AppColors.primaryGold, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'கிரகம் ➔ பாவ தொடர்புகள் (Planet ➔ Bhava Mapping)',
                  style: GoogleFonts.cinzel(
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.lightGold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'ஒவ்வொரு கிரகமும் தொடர்பு கொள்ளும் பாவங்கள் (முன்னுரிமை: 1.உப நாதன் ➔ 2.உப-உப நாதன் ➔ 3.நட்சத்திர நாதன்)',
            style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),

          _buildColorLegend(),
          const SizedBox(height: 14),

          LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 500;
              return Column(
                children: res.planetPositions.map((p) {
                  final houses = res.getHousesForPlanet(p.planet);
                  final contacts = res.getContactsForPlanet(p.planet);
                  final sourceLevel = contacts.isNotEmpty ? contacts.first.sourceLevel : null;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundMid.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.borderGold.withValues(alpha: 0.25)),
                    ),
                    child: isCompact
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                alignment: WrapAlignment.spaceBetween,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 8,
                                runSpacing: 4,
                                children: [
                                  _buildPlanetBadgeWithName(p.planetTa, p.planet, p.isRetrograde),
                                  if (sourceLevel != null)
                                    _buildSourceLevelBadge(sourceLevel),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Text(
                                    'தொடர்பு பாவங்கள்: ',
                                    style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary),
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(child: _buildFormattedHouseNumbers(houses)),
                                ],
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              _buildPlanetBadgeWithName(p.planetTa, p.planet, p.isRetrograde),
                              const SizedBox(width: 12),
                              const Icon(Icons.arrow_forward_rounded, color: AppColors.primaryGold, size: 16),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildFormattedHouseNumbers(houses),
                              ),
                              if (sourceLevel != null) ...[
                                const SizedBox(width: 12),
                                _buildSourceLevelBadge(sourceLevel),
                              ],
                            ],
                          ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  // 5. Part 3 — Graha Relationships (கிரக தொடர்புகள்)
  Widget _buildGrahaRelationsCard(KpResult res) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGold.withValues(alpha: 0.5)),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.hub_rounded, color: AppColors.primaryGold, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Part 3 — கிரக தொடர்புகள் (Graha Thodarbhu)',
                  style: GoogleFonts.cinzel(
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.lightGold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'படி 1: உப நாதன் | படி 2: உப-உப நாதன் (\$) | படி 3: நட்சத்திர நாதன் (*)',
            style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 10),

          // Color Legend
          _buildColorLegend(),
          const SizedBox(height: 14),

          // 9 Planets Cards
          Column(
            children: res.planetRelations.map((pr) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.backgroundMid.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.borderGold.withValues(alpha: 0.3)),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isCompact = constraints.maxWidth < 460;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Planet Title & Combined Contacts Row
                        if (isCompact) ...[
                          Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 8,
                            runSpacing: 4,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryGold.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: AppColors.primaryGold),
                                ),
                                child: Text(
                                  '${pr.planetTa} (${pr.planet})',
                                  style: GoogleFonts.cinzel(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.lightGold,
                                    fontSize: 12.5,
                                  ),
                                ),
                              ),
                              if (pr.planetSourceLevel != null)
                                _buildSourceLevelBadge(pr.planetSourceLevel!),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Text(
                                'தொடர்புகள்: ',
                                style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary),
                              ),
                              Expanded(child: _buildFormattedHouseNumbers(pr.combinedHouses)),
                            ],
                          ),
                        ] else ...[
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryGold.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: AppColors.primaryGold),
                                ),
                                child: Text(
                                  '${pr.planetTa} (${pr.planet})',
                                  style: GoogleFonts.cinzel(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.lightGold,
                                    fontSize: 12.5,
                                  ),
                                ),
                              ),
                              if (pr.planetSourceLevel != null) ...[
                                const SizedBox(width: 8),
                                _buildSourceLevelBadge(pr.planetSourceLevel!),
                              ],
                              const Spacer(),
                              Text(
                                'தொடர்புகள்: ',
                                style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary),
                              ),
                              const SizedBox(width: 4),
                              Flexible(child: _buildFormattedHouseNumbers(pr.combinedHouses)),
                            ],
                          ),
                        ],
                        const SizedBox(height: 10),

                        // Star Lord & Sub Lord rows
                        _buildRelationDetailRow(
                          levelTitle: 'நட்சத்திர நாதன் (${pr.starLordTa}):',
                          houses: pr.starLordHouses,
                          isFallback: pr.isStarLordFallback,
                          isStarLordFallback: pr.isStarLordFallback && pr.starLordSourceLevel == KpSourceLevel.STAR_LORD,
                          isCompact: isCompact,
                        ),
                        const SizedBox(height: 6),
                        _buildRelationDetailRow(
                          levelTitle: 'உப நாதன் (${pr.subLordTa}):',
                          houses: pr.subLordHouses,
                          isFallback: pr.isSubLordFallback,
                          isStarLordFallback: pr.isSubLordFallback && pr.subLordSourceLevel == KpSourceLevel.STAR_LORD,
                          isCompact: isCompact,
                        ),
                      ],
                    );
                  },
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRelationDetailRow({
    required String levelTitle,
    required List<KpHouseNumber> houses,
    required bool isFallback,
    bool isStarLordFallback = false,
    required bool isCompact,
  }) {
    if (isCompact) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Flexible(
                  child: Text(
                    levelTitle,
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      color: Colors.white70,
                    ),
                  ),
                ),
                if (isFallback) ...[
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: (isStarLordFallback ? Colors.lightBlueAccent : Colors.amber).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      isStarLordFallback ? 'Star Lord (*)' : 'Sub-Sub (\$)',
                      style: TextStyle(
                        fontSize: 9,
                        color: isStarLordFallback ? Colors.lightBlueAccent : Colors.amber,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 4),
            _buildFormattedHouseNumbers(houses),
          ],
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 170,
          child: Row(
            children: [
              Flexible(
                child: Text(
                  levelTitle,
                  style: GoogleFonts.outfit(
                    fontSize: 11.5,
                    color: Colors.white70,
                  ),
                ),
              ),
              if (isFallback) ...[
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: (isStarLordFallback ? Colors.lightBlueAccent : Colors.amber).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    isStarLordFallback ? 'Star Lord (*)' : 'Sub-Sub (\$)',
                    style: TextStyle(
                      fontSize: 9,
                      color: isStarLordFallback ? Colors.lightBlueAccent : Colors.amber,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        Expanded(
          child: _buildFormattedHouseNumbers(houses),
        ),
      ],
    );
  }

  // 6. Bhava Graha Relationships (பாவத்தின் கிரக தொடர்புகள்)
  Widget _buildBhavaGrahaRelationsCard(KpResult res) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGold.withValues(alpha: 0.5)),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.dashboard_customize_rounded, color: AppColors.primaryGold, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'பாவ கிரக தொடர்புகள் (Bhava Planetary Connections / Bhava Graha Relations)',
                  style: GoogleFonts.cinzel(
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.lightGold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '12 பாவங்களின் உப நாதர் வழியாக கிரக தொடர்புகளிலிருந்து பெறப்பட்ட நேரடி தொடர்புகள்',
            style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),

          _buildColorLegend(),
          const SizedBox(height: 14),

          Column(
            children: res.houseRelations.map((hr) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.backgroundMid.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.borderGold.withValues(alpha: 0.25)),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isCompact = constraints.maxWidth < 460;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Bhava & Sub Lord Header
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: Colors.redAccent.withValues(alpha: 0.4)),
                              ),
                              child: Text(
                                'C${hr.houseNumber}',
                                style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 11),
                              ),
                            ),
                            Text(
                              '${hr.houseNumber}-ம் பாவம் (Sub Lord: ${hr.cuspSubLordTa})',
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.lightGold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Sub Lord Planet & its Connected Bhavas
                        if (isCompact) ...[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryGold.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.5)),
                                ),
                                child: Text(
                                  '${hr.cuspSubLordTa} (${hr.cuspSubLord})',
                                  style: GoogleFonts.cinzel(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.lightGold,
                                    fontSize: 11.5,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 4,
                                runSpacing: 3,
                                children: [
                                  Text(
                                    'தொடர்புகள்: ',
                                    style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary),
                                  ),
                                  _buildFormattedHouseNumbers(hr.cuspSubLordRelations),
                                ],
                              ),
                            ],
                          ),
                        ] else ...[
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryGold.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.5)),
                                ),
                                child: Text(
                                  '${hr.cuspSubLordTa} (${hr.cuspSubLord})',
                                  style: GoogleFonts.cinzel(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.lightGold,
                                    fontSize: 11.5,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'தொடர்புகள்: ',
                                style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary),
                              ),
                              const SizedBox(width: 4),
                              Flexible(child: _buildFormattedHouseNumbers(hr.cuspSubLordRelations)),
                            ],
                          ),
                        ],
                        const SizedBox(height: 8),

                        // Star Lord from Sub Lord's Planetary Connections
                        _buildRelationDetailRow(
                          levelTitle: 'நட்சத்திர நாதன் (${hr.cuspSubLordStarLordTa.isNotEmpty ? hr.cuspSubLordStarLordTa : hr.cuspSubLordStarLord}):',
                          houses: hr.cuspSubLordStarLordRelations,
                          isFallback: hr.isStarLordFallback,
                          isCompact: isCompact,
                        ),
                        const SizedBox(height: 5),

                        // Sub Lord from Sub Lord's Planetary Connections
                        _buildRelationDetailRow(
                          levelTitle: 'உப நாதன் (${hr.cuspSubLordSubLordTa.isNotEmpty ? hr.cuspSubLordSubLordTa : hr.cuspSubLordSubLord}):',
                          houses: hr.cuspSubLordSubLordRelations,
                          isFallback: hr.isSubLordFallback,
                          isCompact: isCompact,
                        ),
                      ],
                    );
                  },
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // 7. Part 4 — Dasha Relationships (தசா / புத்தி / அந்தரம் / சூட்சுமம்)
  Widget _buildDashaRelationsCard(KpResult res) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGold.withValues(alpha: 0.5)),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.timer_outlined, color: AppColors.primaryGold, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Part 4 — தசா தொடர்புகள் (Dasha Relations)',
                        style: GoogleFonts.cinzel(
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.lightGold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Date picker button for target date
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primaryGold, width: 0.8),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                ),
                icon: const Icon(Icons.calendar_month, size: 14, color: AppColors.primaryGold),
                label: Text(
                  DateFormat('dd-MM-yyyy').format(_evaluationDate),
                  style: GoogleFonts.outfit(fontSize: 11, color: AppColors.lightGold),
                ),
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _evaluationDate,
                    firstDate: DateTime(1900),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() => _evaluationDate = picked);
                    _calculateChart();
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'தசா / புத்தி / அந்தரம் / சூட்சும நாதர்களின் வீட்டு தொடர்புகள் (கிரக தொடர்புகளிலிருந்து நேரடி இணைப்பு)',
            style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),

          _buildColorLegend(),
          const SizedBox(height: 14),

          Column(
            children: res.dashaRelations.map((dr) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.backgroundMid.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.borderGold.withValues(alpha: 0.3)),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isCompact = constraints.maxWidth < 450;
                    if (isCompact) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.backgroundDeep,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.4)),
                            ),
                            child: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 6,
                              children: [
                                Text(
                                  dr.levelName,
                                  style: GoogleFonts.outfit(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.lightGold,
                                  ),
                                ),
                                Text(
                                  '${dr.planetTa} (${dr.planet})',
                                  style: GoogleFonts.outfit(
                                    fontSize: 10.5,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                'தொடர்பு: ',
                                style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary),
                              ),
                              Expanded(child: _buildFormattedHouseNumbers(dr.relations)),
                            ],
                          ),
                          if (dr.starLordRelations.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  'ந.அ வழி: ',
                                  style: GoogleFonts.outfit(fontSize: 10, color: Colors.grey.shade400),
                                ),
                                Expanded(child: _buildFormattedHouseNumbers(dr.starLordRelations, fontSize: 10.5)),
                              ],
                            ),
                          ],
                        ],
                      );
                    }
                    return Row(
                      children: [
                        // Desktop side-by-side
                        Container(
                          width: 130,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundDeep,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.4)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                dr.levelName,
                                style: GoogleFonts.outfit(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.lightGold,
                                ),
                              ),
                              Text(
                                '${dr.planetTa} (${dr.planet})',
                                style: GoogleFonts.outfit(
                                  fontSize: 10,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'தொடர்பு: ',
                                    style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary),
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(child: _buildFormattedHouseNumbers(dr.relations)),
                                ],
                              ),
                              if (dr.starLordRelations.isNotEmpty) ...[
                                const SizedBox(height: 3),
                                Row(
                                  children: [
                                    Text(
                                      'ந.அ வழி: ',
                                      style: GoogleFonts.outfit(fontSize: 10, color: Colors.grey.shade400),
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(child: _buildFormattedHouseNumbers(dr.starLordRelations, fontSize: 10.5)),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanetBadgeWithName(String planetTa, String planetEn, bool isRetrograde) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.primaryGold.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.8)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                planetTa,
                style: GoogleFonts.cinzel(
                  fontWeight: FontWeight.bold,
                  color: AppColors.lightGold,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '($planetEn)',
                style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
              ),
              if (isRetrograde) ...[
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: const Text(
                    'வ',
                    style: TextStyle(fontSize: 8.5, color: Colors.orangeAccent, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSourceLevelBadge(KpSourceLevel level) {
    Color bg;
    Color border;
    Color text;
    String label;

    switch (level) {
      case KpSourceLevel.SUB_LORD:
        bg = AppColors.primaryGold.withValues(alpha: 0.15);
        border = AppColors.primaryGold.withValues(alpha: 0.5);
        text = AppColors.lightGold;
        label = 'உப நாதன் (Sub Lord)';
        break;
      case KpSourceLevel.SUB_SUB_LORD:
        bg = Colors.amber.withValues(alpha: 0.15);
        border = Colors.amber.withValues(alpha: 0.6);
        text = Colors.amber;
        label = 'உப-உப (\$)';
        break;
      case KpSourceLevel.STAR_LORD:
        bg = Colors.lightBlueAccent.withValues(alpha: 0.15);
        border = Colors.lightBlueAccent.withValues(alpha: 0.6);
        text = Colors.lightBlueAccent;
        label = 'நட்சத்திரம் (*)';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: border, width: 0.8),
      ),
      child: Text(
        label,
        style: GoogleFonts.outfit(
          fontSize: 9.5,
          fontWeight: FontWeight.bold,
          color: text,
        ),
      ),
    );
  }

  // Common Color Legend Box
  Widget _buildColorLegend() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.backgroundDeep.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderGold.withValues(alpha: 0.2)),
      ),
      child: Wrap(
        spacing: 14,
        runSpacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          _buildLegendChip(const Color(0xFFFF5252), '8, 12 (தடை/மறைவு - RED)'),
          _buildLegendChip(const Color(0xFF69F0AE), '5, 9 (சுப பலன் - GREEN)'),
          _buildLegendChip(AppColors.lightGold, 'மற்ற வீடுகள் (Normal)'),
          _buildLegendChip(Colors.amber, '\$ = Sub-Sub Fallback'),
          _buildLegendChip(Colors.lightBlueAccent, '* = Star Lord Fallback'),
        ],
      ),
    );
  }

  Widget _buildLegendChip(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          text,
          style: GoogleFonts.outfit(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  /// PART 3B Core Requirement:
  /// House 8 and House 12: ONLY the number in RED (e.g. 8 12)
  /// House 5 and House 9: ONLY the number in GREEN (e.g. 5 9)
  /// Other houses: normal color
  /// Fallback numbers have '$'
  Widget _buildFormattedHouseNumbers(List<KpHouseNumber> houses, {double fontSize = 12.0}) {
    if (houses.isEmpty) {
      return Text('-', style: GoogleFonts.outfit(fontSize: fontSize, color: AppColors.textSecondary));
    }

    return Wrap(
      spacing: 5,
      runSpacing: 3,
      children: houses.map((h) {
        Color textColor;
        Color bgTint;
        Color borderTint;

        if (h.house == 8 || h.house == 12) {
          // RED for 8 and 12
          textColor = const Color(0xFFFF5252);
          bgTint = const Color(0xFFFF5252).withValues(alpha: 0.16);
          borderTint = const Color(0xFFFF5252).withValues(alpha: 0.6);
        } else if (h.house == 5 || h.house == 9) {
          // GREEN for 5 and 9
          textColor = const Color(0xFF69F0AE);
          bgTint = const Color(0xFF69F0AE).withValues(alpha: 0.16);
          borderTint = const Color(0xFF69F0AE).withValues(alpha: 0.6);
        } else {
          // Normal color
          textColor = AppColors.lightGold;
          bgTint = AppColors.backgroundMid.withValues(alpha: 0.6);
          borderTint = AppColors.borderGold.withValues(alpha: 0.35);
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
          decoration: BoxDecoration(
            color: bgTint,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: borderTint, width: 0.8),
          ),
          child: Text(
            h.displayText,
            style: GoogleFonts.outfit(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        );
      }).toList(),
    );
  }

  // ==========================================
  // PART 5: பிறந்த நேரத் திருத்தம் (Birth Time Rectification)
  // Reuses Method 1 BTR Engine (Ruling Planets & candidate analysis)
  // Provides interactive Hour, Minute, and Second adjustments (+ / -)
  // ==========================================

  void _adjustBirthTime({int deltaHours = 0, int deltaMinutes = 0, int deltaSeconds = 0}) {
    final currentDt = _birthData.dateTime;
    final newDt = currentDt.add(Duration(
      hours: deltaHours,
      minutes: deltaMinutes,
      seconds: deltaSeconds,
    ));
    _applyRectifiedDateTime(newDt);
  }

  void _applyRectifiedDateTime(DateTime newDt) {
    final formattedTime = _formatTime(newDt);

    setState(() {
      _birthData = _birthData.copyWith(
        dateTime: newDt,
        time: formattedTime,
      );
    });
    _calculateChart();
  }

  void _resetToOriginalTime() {
    setState(() {
      _birthData = _originalBirthData;
    });
    _calculateChart();
  }

  String _formatTime(DateTime dt, {bool withSeconds = true}) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    return withSeconds ? '$h : $m : $s' : '$h : $m';
  }

  Widget _buildRectificationCard(KpResult res) {
    final originalTimeStr = _formatTime(_originalBirthData.dateTime);
    final currentTimeStr = _formatTime(_birthData.dateTime);
    final diffSeconds = _birthData.dateTime.difference(_originalBirthData.dateTime).inSeconds;

    String offsetStr = '0 s (அசல்)';
    if (diffSeconds != 0) {
      final sign = diffSeconds > 0 ? '+' : '-';
      final m = diffSeconds.abs() ~/ 60;
      final s = diffSeconds.abs() % 60;
      offsetStr = s == 0 ? '$sign$m min' : '$sign$m min $s sec';
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGold.withValues(alpha: 0.5)),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.published_with_changes_rounded, color: AppColors.primaryGold, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'பிறந்த நேரத் திருத்தம் (Birth Time Rectification)',
                  style: GoogleFonts.cinzel(
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.lightGold,
                  ),
                ),
              ),
              if (diffSeconds != 0)
                TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primaryGold,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                  icon: const Icon(Icons.restore_rounded, size: 16),
                  label: const Text('Reset', style: TextStyle(fontSize: 12)),
                  onPressed: _resetToOriginalTime,
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'நேரத்தை மாற்றி KP முறை 4-ன் கணித முடிவுகளை உடனுக்குடன் மறுகணக்கீடு செய்க',
            style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 14),

          // Time Display Comparison Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.backgroundMid.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderGold.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Text(
                      'அசல் பிறந்த நேரம் (Original Time):',
                      style: GoogleFonts.outfit(fontSize: 12, color: Colors.white70),
                    ),
                    Text(
                      originalTimeStr,
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Text(
                      'திருத்தப்பட்ட நேரம் (Rectified Time):',
                      style: GoogleFonts.outfit(fontSize: 12, color: AppColors.lightGold),
                    ),
                    InkWell(
                      onTap: _showDirectTimePickerDialog,
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGold.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.6)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.access_time_rounded, size: 14, color: AppColors.primaryGold),
                            const SizedBox(width: 6),
                            Text(
                              currentTimeStr,
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryGold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.arrow_drop_down, size: 16, color: AppColors.primaryGold),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Text(
                      'கால வித்தியாசம் (Time Offset):',
                      style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: (diffSeconds != 0 ? Colors.green : Colors.grey).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        offsetStr,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: diffSeconds != 0 ? Colors.greenAccent : Colors.white70,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Adjustment Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'நேர திருத்தம் (Time Adjustment):',
                style: GoogleFonts.outfit(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: AppColors.lightGold,
                ),
              ),
              InkWell(
                onTap: _showDirectTimePickerDialog,
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.touch_app_rounded, size: 13, color: AppColors.primaryGold),
                      const SizedBox(width: 4),
                      Text(
                        'நேரத்தைத் தேர்ந்தெடு (Pick Time)',
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryGold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Hour Adjustment Row
          _buildAdjustmentRow(
            label: 'மணி திருத்தம் (Hour Adjustment):',
            onDecrement: () => _adjustBirthTime(deltaHours: -_selectedHourStep),
            onIncrement: () => _adjustBirthTime(deltaHours: _selectedHourStep),
            currentStepText: '${_selectedHourStep}h',
            availableSteps: const [1, 2, 6],
            currentStep: _selectedHourStep,
            onStepChanged: (s) => setState(() => _selectedHourStep = s),
            stepUnit: 'h',
          ),
          const SizedBox(height: 8),

          // Minute Adjustment Row
          _buildAdjustmentRow(
            label: 'நிமிட திருத்தம் (Minute Adjustment):',
            onDecrement: () => _adjustBirthTime(deltaMinutes: -_selectedMinuteStep),
            onIncrement: () => _adjustBirthTime(deltaMinutes: _selectedMinuteStep),
            currentStepText: '${_selectedMinuteStep}m',
            availableSteps: const [1, 2, 5, 10],
            currentStep: _selectedMinuteStep,
            onStepChanged: (s) => setState(() => _selectedMinuteStep = s),
            stepUnit: 'm',
          ),
          const SizedBox(height: 8),

          // Second Adjustment Row (Starts from 1 second only)
          _buildAdjustmentRow(
            label: 'வினாடி திருத்தம் (Second Adjustment):',
            onDecrement: () => _adjustBirthTime(deltaSeconds: -_selectedSecondStep),
            onIncrement: () => _adjustBirthTime(deltaSeconds: _selectedSecondStep),
            currentStepText: '${_selectedSecondStep}s',
            availableSteps: const [1, 2, 5, 10, 15, 30],
            currentStep: _selectedSecondStep,
            onStepChanged: (s) => setState(() => _selectedSecondStep = s),
            stepUnit: 's',
          ),

          const SizedBox(height: 18),
          const Divider(color: AppColors.borderGold, height: 1, thickness: 0.4),
          const SizedBox(height: 14),

          // Method 1 Ruling Planets Candidates
          _buildCandidatesSection(res),
        ],
      ),
    );
  }

  Widget _buildAdjustmentRow({
    required String label,
    required VoidCallback onDecrement,
    required VoidCallback onIncrement,
    required String currentStepText,
    required List<int> availableSteps,
    required int currentStep,
    required ValueChanged<int> onStepChanged,
    required String stepUnit,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.backgroundMid.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderGold.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.outfit(fontSize: 12, color: Colors.white),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: onDecrement,
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundDeep,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.borderGold.withValues(alpha: 0.5)),
                      ),
                      child: const Icon(Icons.remove, color: AppColors.primaryGold, size: 16),
                    ),
                  ),
                  Container(
                    constraints: const BoxConstraints(minWidth: 42),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    child: Text(
                      currentStepText,
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.lightGold,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: onIncrement,
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundDeep,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.borderGold.withValues(alpha: 0.5)),
                      ),
                      child: const Icon(Icons.add, color: AppColors.primaryGold, size: 16),
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (availableSteps.length > 1) ...[
            const SizedBox(height: 6),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 5,
              runSpacing: 4,
              children: [
                Text(
                  'அளவு (Step): ',
                  style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
                ),
                ...availableSteps.map((s) {
                  final isSel = currentStep == s;
                  return InkWell(
                    onTap: () => onStepChanged(s),
                    borderRadius: BorderRadius.circular(4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isSel ? AppColors.primaryGold : AppColors.backgroundDeep,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: isSel ? AppColors.primaryGold : AppColors.borderGold.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Text(
                        '$s$stepUnit',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                          color: isSel ? Colors.black : Colors.white70,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _showDirectTimePickerDialog() async {
    final currentDt = _birthData.dateTime;
    int pickedHour = currentDt.hour;
    int pickedMinute = currentDt.minute;
    int pickedSecond = currentDt.second;

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.backgroundMid,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: AppColors.primaryGold, width: 1.2),
              ),
              title: Row(
                children: [
                  const Icon(Icons.access_time_filled_rounded, color: AppColors.primaryGold, size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'நேரத்தை தேர்வு செய்க (Select Time)',
                      style: GoogleFonts.cinzel(
                        color: AppColors.lightGold,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'மணி, நிமிடம் மற்றும் வினாடிகளை தேர்வு செய்க',
                      style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 16),

                    // HH : MM : SS Pickers
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildTimeUnitPicker(
                          label: 'மணி (Hour)',
                          value: pickedHour,
                          max: 23,
                          onChanged: (val) => setDialogState(() => pickedHour = val),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Text(
                            ':',
                            style: GoogleFonts.outfit(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryGold,
                            ),
                          ),
                        ),
                        _buildTimeUnitPicker(
                          label: 'நிமிடம் (Min)',
                          value: pickedMinute,
                          max: 59,
                          onChanged: (val) => setDialogState(() => pickedMinute = val),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Text(
                            ':',
                            style: GoogleFonts.outfit(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryGold,
                            ),
                          ),
                        ),
                        _buildTimeUnitPicker(
                          label: 'வினாடி (Sec)',
                          value: pickedSecond,
                          max: 59,
                          onChanged: (val) => setDialogState(() => pickedSecond = val),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Native Clock Picker quick-launcher
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.primaryGold.withValues(alpha: 0.6)),
                        foregroundColor: AppColors.primaryGold,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      icon: const Icon(Icons.schedule_rounded, size: 16),
                      label: const Text('கடிகார வடிவம் (Clock Picker)', style: TextStyle(fontSize: 11.5)),
                      onPressed: () async {
                        final picked = await showTimePicker(
                          context: ctx,
                          initialTime: TimeOfDay(hour: pickedHour, minute: pickedMinute),
                          builder: (context, child) {
                            return Theme(
                              data: ThemeData.dark().copyWith(
                                colorScheme: const ColorScheme.dark(
                                  primary: AppColors.primaryGold,
                                  onPrimary: AppColors.backgroundDeep,
                                  surface: AppColors.backgroundMid,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          setDialogState(() {
                            pickedHour = picked.hour;
                            pickedMinute = picked.minute;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('ரத்து செய் (Cancel)', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGold,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () {
                    final newDt = DateTime(
                      currentDt.year,
                      currentDt.month,
                      currentDt.day,
                      pickedHour,
                      pickedMinute,
                      pickedSecond,
                    );
                    Navigator.pop(ctx);
                    _applyRectifiedDateTime(newDt);
                  },
                  child: const Text('உறுதி செய் (Apply)'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildTimeUnitPicker({
    required String label,
    required int value,
    required int max,
    required ValueChanged<int> onChanged,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: () => onChanged((value + 1) % (max + 1)),
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.backgroundDeep,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.borderGold.withValues(alpha: 0.4)),
            ),
            child: const Icon(Icons.keyboard_arrow_up_rounded, color: AppColors.primaryGold, size: 20),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 52,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.backgroundDeep,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.borderGold.withValues(alpha: 0.7)),
          ),
          alignment: Alignment.center,
          child: Text(
            value.toString().padLeft(2, '0'),
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryGold,
            ),
          ),
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: () => onChanged((value - 1 + (max + 1)) % (max + 1)),
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.backgroundDeep,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.borderGold.withValues(alpha: 0.4)),
            ),
            child: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primaryGold, size: 20),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildCandidatesSection(KpResult res) {
    final kp1Birth = KPBirthData(
      dateTime: _originalBirthData.dateTime,
      latitude: _originalBirthData.latitude,
      longitude: _originalBirthData.longitude,
      placeName: _originalBirthData.place,
      timeZone: Duration(minutes: (_originalBirthData.timezone * 60).round()),
    );
    final ruling = KPRulingPlanetEngine.calculate(
      dateTime: _originalBirthData.dateTime,
      moonLongitude: res.getPlanet('Moon').longitude,
      ascendantLongitude: res.ascendantDegree,
    );
    final candidates = KPRectificationEngine.rectify(
      birthData: kp1Birth,
      rulingPlanets: ruling,
      searchRangeMinutes: _rectificationWindowMinutes,
      stepSeconds: 30,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 6,
          children: [
            Text(
              'KP ஆளும் கிரகங்கள் (Candidates):',
              style: GoogleFonts.outfit(
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
                color: AppColors.lightGold,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [2, 5, 10].map((mins) {
                final isSel = _rectificationWindowMinutes == mins;
                return Padding(
                  padding: const EdgeInsets.only(left: 6.0),
                  child: ChoiceChip(
                    label: Text(
                      '±$mins m',
                      style: TextStyle(
                        fontSize: 10,
                        color: isSel ? Colors.black : Colors.white70,
                        fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    selected: isSel,
                    selectedColor: AppColors.primaryGold,
                    backgroundColor: AppColors.backgroundMid,
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                    visualDensity: VisualDensity.compact,
                    onSelected: (val) {
                      if (val) setState(() => _rectificationWindowMinutes = mins);
                    },
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(AppColors.backgroundMid),
            headingRowHeight: 38,
            dataRowMinHeight: 40,
            dataRowMaxHeight: 48,
            columnSpacing: 14,
            horizontalMargin: 8,
            headingTextStyle: GoogleFonts.cinzel(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryGold,
            ),
            dataTextStyle: GoogleFonts.outfit(fontSize: 11, color: Colors.white),
            columns: const [
              DataColumn(label: Text('நேரம் (Time)')),
              DataColumn(label: Text('வித்தியாசம் (Offset)')),
              DataColumn(label: Text('லக்ன உப நாதன் (Sub Lord)')),
              DataColumn(label: Text('பொருத்தம் (Score)')),
              DataColumn(label: Text('செயல் (Action)')),
            ],
            rows: candidates.take(8).map((c) {
              final isCurrent = c.candidateTime.hour == _birthData.dateTime.hour &&
                  c.candidateTime.minute == _birthData.dateTime.minute &&
                  c.candidateTime.second == _birthData.dateTime.second;
              return DataRow(
                color: isCurrent
                    ? WidgetStateProperty.all(AppColors.primaryGold.withValues(alpha: 0.15))
                    : (c.isBestCandidate
                        ? WidgetStateProperty.all(Colors.green.withValues(alpha: 0.12))
                        : null),
                cells: [
                  DataCell(Text(c.timeFormatted, style: TextStyle(fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal, color: isCurrent ? AppColors.primaryGold : Colors.white))),
                  DataCell(Text(c.offsetFormatted, style: const TextStyle(color: Colors.white70))),
                  DataCell(Text(c.ascendantSubLord, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.lightGold))),
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 32,
                          child: LinearProgressIndicator(
                            value: c.matchingScore / 100.0,
                            backgroundColor: Colors.white12,
                            color: c.isBestCandidate ? Colors.greenAccent : AppColors.primaryGold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text('${c.matchingScore.round()}%', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: c.isBestCandidate ? Colors.greenAccent : Colors.white)),
                      ],
                    ),
                  ),
                  DataCell(
                    isCurrent
                        ? Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primaryGold.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: AppColors.primaryGold),
                            ),
                            child: const Text('பயனில் உள்ளது', style: TextStyle(fontSize: 10, color: AppColors.lightGold, fontWeight: FontWeight.bold)),
                          )
                        : OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.primaryGold, width: 0.8),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              minimumSize: Size.zero,
                            ),
                            onPressed: () => _applyRectifiedDateTime(c.candidateTime),
                            child: const Text('பயன்படுத்து', style: TextStyle(fontSize: 10, color: AppColors.lightGold)),
                          ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
