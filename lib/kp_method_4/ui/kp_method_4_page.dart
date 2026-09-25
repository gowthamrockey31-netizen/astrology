import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../services/auth_service.dart';
import '../../widgets/cosmic_background.dart';
import '../engine/kp4_engine.dart';
import '../models/kp4_models.dart';
import 'kp4_chart_widget.dart';

/// KP Method 4 Main Screen
/// Independent module implementing the 7-part UI structure:
/// 1. Header & Birth Information / Calculation Summary
/// 2. Part 1 — Rasi + Bhava Cusp (Combined chart with red cusp markers)
/// 3. Part 2 — Planet Positions (9 planets table)
/// 4. Bhava Positions (12 Bhava Cusps table)
/// 5. Part 3 — Graha Relationships (9 planets with 8/12 red, 5/9 green, '$' fallback)
/// 6. Bhava Graha Relationships (12 Bhavas with Sub Lord and Star Lord of Sub Lord relations)
/// 7. Part 4 — Dasha Relationships (Dasha -> Bhukti -> Antara -> Sookshma matching planet relations)
class KPMethod4Page extends StatefulWidget {
  final Kp4BirthData? initialBirthData;

  const KPMethod4Page({super.key, this.initialBirthData});

  @override
  State<KPMethod4Page> createState() => _KPMethod4PageState();
}

class _KPMethod4PageState extends State<KPMethod4Page> {
  late Kp4BirthData _birthData;
  KpResult? _kpResult;
  bool _isLoading = true;
  DateTime _evaluationDate = DateTime.now();

  // Tab filter: 0=All, 1=Chart, 2=Planets, 3=Cusps, 4=Graha Rel, 5=Bhava Rel, 6=Dasha
  int _selectedSection = 0;

  final List<String> _sectionTitles = [
    'முழுமையான பார்வை (All)',
    '1. ராசி & பாவ சக்கரம்',
    '2. கிரக நிலைகள் (Planets)',
    '3. பாவ நிலைகள் (Cusps)',
    '4. கிரக தொடர்புகள் (Graha)',
    '5. பாவ கிரக தொடர்புகள்',
    '6. தசா தொடர்புகள் (Dasha)',
  ];

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

                                // 5. Part 3 — Graha Relationships
                                if (_selectedSection == 0 || _selectedSection == 4) ...[
                                  _buildGrahaRelationsCard(_kpResult!),
                                  const SizedBox(height: 16),
                                ],

                                // 6. Bhava Graha Relationships
                                if (_selectedSection == 0 || _selectedSection == 5) ...[
                                  _buildBhavaGrahaRelationsCard(_kpResult!),
                                  const SizedBox(height: 16),
                                ],

                                // 7. Part 4 — Dasha Relationships
                                if (_selectedSection == 0 || _selectedSection == 6) ...[
                                  _buildDashaRelationsCard(_kpResult!),
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
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        itemCount: _sectionTitles.length,
        itemBuilder: (context, index) {
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
        },
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                        'நட்சத்திர / உப தொடர்புகள் & பாவ கிரக தொடர்புகள்',
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.primaryGold),
        const SizedBox(width: 5),
        Text(
          '$label: ',
          style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: GoogleFonts.outfit(fontSize: 11.5, fontWeight: FontWeight.w600, color: Colors.white),
        ),
      ],
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
              Text(
                'Part 2 — கிரக நிலைகள் (Planet Positions)',
                style: GoogleFonts.cinzel(
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                  color: AppColors.lightGold,
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

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(AppColors.backgroundMid),
              columnSpacing: 16,
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
                DataColumn(label: Text('Planet (கிரகம்)')),
                DataColumn(label: Text('Degree (பாகை)')),
                DataColumn(label: Text('Star Lord (ந.அ)')),
                DataColumn(label: Text('Sub Lord (உ.அ)')),
                DataColumn(label: Text('Sub-Sub Lord (உ.உ)')),
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
              Text(
                'பாவ நிலைகள் (12 Bhava Cusps)',
                style: GoogleFonts.cinzel(
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                  color: AppColors.lightGold,
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

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(AppColors.backgroundMid),
              columnSpacing: 16,
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
                DataColumn(label: Text('Bhava (பாவம்)')),
                DataColumn(label: Text('Cusp Degree (பாகை)')),
                DataColumn(label: Text('Star Lord (ந.அ)')),
                DataColumn(label: Text('Sub Lord (உ.அ)')),
                DataColumn(label: Text('Sub-Sub Lord (உ.உ)')),
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
        ],
      ),
    );
  }

  // 4. Part 3 — Graha Relationships (கிரக தொடர்புகள்)
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.hub_rounded, color: AppColors.primaryGold, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Part 3 — கிரக தொடர்புகள் (Graha Thodarbhu)',
                    style: GoogleFonts.cinzel(
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                      color: AppColors.lightGold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'படி 1: ந.அ உப நாதராக உள்ள பாவங்கள் | படி 2: உ.அ உப நாதராக உள்ள பாவங்கள் | படி 3 (\$): உ.உ நிலை Fallback',
            style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 10),

          // Color Legend
          _buildColorLegend(),
          const SizedBox(height: 14),

          // 9 Planets Cards / Table
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Planet Title Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
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
                          ],
                        ),
                        // Total Combined Relations
                        Row(
                          children: [
                            Text(
                              'தொடர்புகள்: ',
                              style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary),
                            ),
                            _buildFormattedHouseNumbers(pr.combinedHouses),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Star Lord & Sub Lord rows
                    _buildRelationDetailRow(
                      levelTitle: 'நட்சத்திர நாதன் (${pr.starLordTa}):',
                      houses: pr.starLordHouses,
                      isFallback: pr.isStarLordFallback,
                    ),
                    const SizedBox(height: 6),
                    _buildRelationDetailRow(
                      levelTitle: 'உப நாதன் (${pr.subLordTa}):',
                      houses: pr.subLordHouses,
                      isFallback: pr.isSubLordFallback,
                    ),
                  ],
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
  }) {
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
                    color: Colors.amber.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: const Text('Sub-Sub', style: TextStyle(fontSize: 9, color: Colors.amber, fontWeight: FontWeight.bold)),
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

  // 5. Bhava Graha Relationships (பாவத்தின் கிரக தொடர்புகள்)
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
              Text(
                'பாவத்தின் கிரக தொடர்புகள் (Bhava Graha Relations)',
                style: GoogleFonts.cinzel(
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                  color: AppColors.lightGold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '12 பாவங்களின் உப நாதர் மற்றும் அதன் நட்சத்திர நாதரின் வீட்டு தொடர்புகள்',
            style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),

          _buildColorLegend(),
          const SizedBox(height: 14),

          Column(
            children: res.houseRelations.map((hr) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.backgroundMid.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.borderGold.withValues(alpha: 0.25)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Bhava Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
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
                            const SizedBox(width: 8),
                            Text(
                              '${hr.houseNumber}-ம் பாவம்',
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.lightGold,
                              ),
                            ),
                          ],
                        ),
                        // Combined
                        Row(
                          children: [
                            Text(
                              'இறுதி தொடர்பு: ',
                              style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary),
                            ),
                            _buildFormattedHouseNumbers(hr.combinedHouses),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Sub Lord and Star Lord of Sub Lord
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'உப நாதர்: ${hr.cuspSubLordTa} (${hr.cuspSubLord})',
                                style: GoogleFonts.outfit(fontSize: 11, color: Colors.white70),
                              ),
                              const SizedBox(height: 4),
                              _buildFormattedHouseNumbers(hr.cuspSubLordRelations),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'உ.அ-வின் நட்சத்திர நாதன்: ${hr.cuspSubLordStarLordTa} (${hr.cuspSubLordStarLord})',
                                style: GoogleFonts.outfit(fontSize: 11, color: Colors.white70),
                              ),
                              const SizedBox(height: 4),
                              _buildFormattedHouseNumbers(hr.cuspSubLordStarLordRelations),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // 6. Part 4 — Dasha Relationships (தசா / புத்தி / அந்தரம் / சூட்சுமம்)
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
              Row(
                children: [
                  const Icon(Icons.timer_outlined, color: AppColors.primaryGold, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Part 4 — தசா தொடர்புகள் (Dasha Relations)',
                    style: GoogleFonts.cinzel(
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                      color: AppColors.lightGold,
                    ),
                  ),
                ],
              ),
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
                child: Row(
                  children: [
                    // Level badge
                    Container(
                      width: 120,
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

                    // Relations
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
                              _buildFormattedHouseNumbers(dr.relations),
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
                                _buildFormattedHouseNumbers(dr.starLordRelations, fontSize: 10.5),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
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
}
