import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../services/auth_service.dart';
import '../../widgets/cosmic_background.dart';
import '../engine/kp3_engine.dart';
import '../models/kp3_models.dart';

/// KP Method — Model 3 Screen
/// Independent calculation module displaying Lagna, Ruling Planets, Planet Positions,
/// Cusp Relations with Red/Blue houses, Dasha periods, and Birth Time Rectification.
class KPMethodModel3Page extends StatefulWidget {
  final BirthData? initialBirthData;

  const KPMethodModel3Page({super.key, this.initialBirthData});

  @override
  State<KPMethodModel3Page> createState() => _KPMethodModel3PageState();
}

class _KPMethodModel3PageState extends State<KPMethodModel3Page> with SingleTickerProviderStateMixin {
  late BirthData _birthData;
  KPResult? _kpResult;
  bool _isLoading = true;
  int _selectedTab = 0;

  // Rectification state
  BirthTimeRectificationResult? _rectificationResult;
  bool _isRectifying = false;

  final List<String> _tabs = [
    'லக்னம் (Lagna)',
    'ஆளும் கிரகங்கள் (Ruling)',
    'கிரக நிலைகள் (Planets)',
    'பாவ தொடர்புகள் (Cusps)',
    'தசா நிலைகள் (Dasha)',
    'நேரத் திருத்தம் (Rectification)',
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
        _birthData = BirthData.fromUserModel(user);
      } else {
        _birthData = BirthData.defaultProfile();
      }
    }
  }

  void _calculateChart() {
    setState(() => _isLoading = true);
    try {
      final module = CompleteKPModule();
      final res = module.calculate(_birthData);
      setState(() {
        _kpResult = res;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Calculation error: $e'),
          backgroundColor: Colors.red.shade900,
        ),
      );
    }
  }

  void _runRectification() {
    setState(() => _isRectifying = true);
    try {
      final res = CompleteKPModule.rectifyBirthTime(_birthData);
      setState(() {
        _rectificationResult = res;
        _isRectifying = false;
      });
    } catch (e) {
      setState(() => _isRectifying = false);
    }
  }

  void _applyRectifiedTime(BirthData newBirthData) {
    setState(() {
      _birthData = newBirthData;
    });
    _calculateChart();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('திருத்தப்பட்ட நேரம் பயன்படுத்தப்பட்டது (Rectified time applied)'),
        backgroundColor: Colors.teal,
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.year.toString().padLeft(4, '0')}';
  }

  String _formatDateIso(DateTime dt) {
    return '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  String _formatTime(DateTime dt, {bool withSeconds = false}) {
    final h12 = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    final p = dt.hour >= 12 ? 'PM' : 'AM';
    return withSeconds ? '${h12.toString().padLeft(2, '0')}:$m:$s $p' : '${h12.toString().padLeft(2, '0')}:$m $p';
  }

  String _formatTime24(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  void _showEditProfileDialog() {
    final dateCtrl = TextEditingController(text: _formatDateIso(_birthData.dateTime));
    final timeCtrl = TextEditingController(text: _formatTime24(_birthData.dateTime));
    final placeCtrl = TextEditingController(text: _birthData.place);
    final latCtrl = TextEditingController(text: _birthData.latitude.toString());
    final lonCtrl = TextEditingController(text: _birthData.longitude.toString());
    final tzCtrl = TextEditingController(text: _birthData.timezone.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.backgroundMid,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.primaryGold, width: 1.2),
        ),
        title: Row(
          children: [
            const Icon(Icons.edit_calendar_rounded, color: AppColors.primaryGold),
            const SizedBox(width: 8),
            Text(
              'பிறப்பு விவரங்கள் (Birth Data)',
              style: GoogleFonts.notoSansTamil(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.lightGold,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDialogField('பிறந்த தேதி (YYYY-MM-DD)', dateCtrl),
              _buildDialogField('பிறந்த நேரம் (HH:MM 24hr)', timeCtrl),
              _buildDialogField('இடம் (Place)', placeCtrl),
              _buildDialogField('அட்சரேகை (Latitude)', latCtrl, isNum: true),
              _buildDialogField('தீர்க்கரேகை (Longitude)', lonCtrl, isNum: true),
              _buildDialogField('டைம்ஜோன் (Timezone e.g. 5.5)', tzCtrl, isNum: true),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('ரத்து (Cancel)', style: TextStyle(color: Colors.grey.shade400)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGold,
              foregroundColor: AppColors.backgroundDeep,
            ),
            onPressed: () {
              try {
                final dateParts = dateCtrl.text.trim().split('-');
                final timeParts = timeCtrl.text.trim().split(':');
                final newDt = DateTime(
                  int.parse(dateParts[0]),
                  int.parse(dateParts[1]),
                  int.parse(dateParts[2]),
                  int.parse(timeParts[0]),
                  int.parse(timeParts[1]),
                );
                final updated = _birthData.copyWith(
                  dateTime: newDt,
                  time: timeCtrl.text.trim(),
                  place: placeCtrl.text.trim(),
                  latitude: double.parse(latCtrl.text.trim()),
                  longitude: double.parse(lonCtrl.text.trim()),
                  timezone: double.parse(tzCtrl.text.trim()),
                );
                Navigator.pop(ctx);
                setState(() => _birthData = updated);
                _calculateChart();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Invalid input: $e'), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text('சேமி (Save & Recalculate)'),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogField(String label, TextEditingController ctrl, {bool isNum = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: TextField(
        controller: ctrl,
        keyboardType: isNum ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.white.withAlpha(50)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.primaryGold),
          ),
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
        backgroundColor: AppColors.backgroundMid,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'KP Method',
              style: GoogleFonts.cinzel(
                color: AppColors.lightGold,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              'KP Method — Model 3 (முழுமையான கே.பி முறை)',
              style: GoogleFonts.notoSansTamil(
                color: Colors.white70,
                fontSize: 11,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primaryGold),
            tooltip: 'மீண்டும் கணக்கிடு (Recalculate)',
            onPressed: _calculateChart,
          ),
        ],
      ),
      body: CosmicBackground(
        child: SafeArea(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primaryGold),
                )
              : _kpResult == null
                  ? const Center(
                      child: Text('No data available', style: TextStyle(color: Colors.white70)),
                    )
                  : Column(
                      children: [
                        // Birth Header Info Card
                        _buildBirthSummaryCard(),

                        // Tab Navigation Selector
                        _buildTabSelector(),

                        // Tab Content Body
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(12.0),
                            child: _buildSelectedTabContent(),
                          ),
                        ),
                      ],
                    ),
        ),
      ),
    );
  }

  /// Top Profile Summary Card
  Widget _buildBirthSummaryCard() {
    final res = _kpResult!;
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 10, 12, 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primaryGold.withAlpha(100), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(120),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryGold.withAlpha(30),
              border: Border.all(color: AppColors.primaryGold, width: 1.5),
            ),
            child: const Icon(Icons.hub_rounded, color: AppColors.primaryGold, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _birthData.place,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    InkWell(
                      onTap: _showEditProfileDialog,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGold.withAlpha(30),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.primaryGold, width: 0.8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.edit, color: AppColors.primaryGold, size: 12),
                            const SizedBox(width: 4),
                            Text(
                              'திருத்து (Edit)',
                              style: GoogleFonts.notoSansTamil(
                                color: AppColors.lightGold,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 12,
                  runSpacing: 4,
                  children: [
                    Text(
                      '📅 ${_formatDate(_birthData.dateTime)}',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    Text(
                      '⏰ ${_formatTime(_birthData.dateTime)}',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    Text(
                      '🌐 KP அயனாம்சம்: ${res.ayanamsaStr}',
                      style: const TextStyle(color: AppColors.lightGold, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Horizontal Tab Selector
  Widget _buildTabSelector() {
    return Container(
      height: 44,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _tabs.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedTab == index;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () => setState(() => _selectedTab = index),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryGold : AppColors.cardSurfaceLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppColors.lightGold : Colors.white12,
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    _tabs[index],
                    style: GoogleFonts.notoSansTamil(
                      color: isSelected ? AppColors.backgroundDeep : Colors.white70,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSelectedTabContent() {
    switch (_selectedTab) {
      case 0:
        return _buildLagnaSection();
      case 1:
        return _buildRulingPlanetsSection();
      case 2:
        return _buildPlanetPositionsSection();
      case 3:
        return _buildCuspRelationsSection();
      case 4:
        return _buildDashaSection();
      case 5:
        return _buildRectificationSection();
      default:
        return _buildLagnaSection();
    }
  }

  // ==========================================
  // SECTION 1: லக்னம் (Lagna)
  // ==========================================
  Widget _buildLagnaSection() {
    final res = _kpResult!;
    final ascCusp = res.cusps.firstWhere((c) => c.cuspNumber == 1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionHeader('லக்னம் (Ascendant Calculation)', Icons.explore_rounded),
        Card(
          color: AppColors.cardSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.borderGold, width: 1.2),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildInfoTile('லக்ன பாகை (Degree)', res.ascendantDegreeStr, Colors.amber),
                    _buildInfoTile('ராசி (Sign)', '${ascCusp.signNameTa} (${ascCusp.signName})', Colors.white),
                  ],
                ),
                const Divider(color: Colors.white12, height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildInfoTile('நட்சத்திரம் (Star)', '${ascCusp.nakshatraNameTa} - பாதம் ${ascCusp.pada}', Colors.white),
                    _buildInfoTile('ராசி நாதன் (Sign Lord)', ascCusp.signLord, AppColors.lightGold),
                  ],
                ),
                const Divider(color: Colors.white12, height: 24),
                // KP 4-Tier Lords Grid
                Text(
                  'கே.பி லக்ன உப நாதர்கள் (KP Ascendant Lords)',
                  style: GoogleFonts.notoSansTamil(
                    color: AppColors.lightGold,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildLordBadge('ந.அ (Star Lord)', ascCusp.starLord, Colors.cyan)),
                    const SizedBox(width: 6),
                    Expanded(child: _buildLordBadge('உ.அ (Sub Lord)', ascCusp.subLord, Colors.amber)),
                    const SizedBox(width: 6),
                    Expanded(child: _buildLordBadge('உ.உ (Sub-Sub)', ascCusp.subSubLord, Colors.orangeAccent)),
                    const SizedBox(width: 6),
                    Expanded(child: _buildLordBadge('உ.உ.உ (Sub-Sub-Sub)', ascCusp.subSubSubLord, Colors.purpleAccent)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTile(String label, String value, Color valColor) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11)),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.outfit(color: valColor, fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ],
    );
  }

  Widget _buildLordBadge(String title, String lord, Color col) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: col.withAlpha(25),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: col.withAlpha(120), width: 1),
      ),
      child: Column(
        children: [
          Text(title, style: TextStyle(color: col, fontSize: 9, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(
            lord,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            KPConstants.planetToTamil(lord),
            style: TextStyle(color: Colors.white.withAlpha(180), fontSize: 10),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ==========================================
  // SECTION 2: ஆளும் கிரகங்கள் (Ruling Planets)
  // ==========================================
  Widget _buildRulingPlanetsSection() {
    final res = _kpResult!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionHeader('ஆளும் கிரகங்கள் (Ruling Planets)', Icons.stars_rounded),
        Card(
          color: AppColors.cardSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.borderGold, width: 1),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: res.rulingPlanets.length,
            separatorBuilder: (_, __) => const Divider(color: Colors.white10, height: 1),
            itemBuilder: (context, idx) {
              final rp = res.rulingPlanets[idx];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  children: [
                    // Category Badge (ரா.அ, ந.அ, உ.அ, உ.உ, உ.உ.உ)
                    Container(
                      width: 52,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(rp.category).withAlpha(35),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _getCategoryColor(rp.category), width: 1),
                      ),
                      child: Center(
                        child: Text(
                          rp.category,
                          style: GoogleFonts.notoSansTamil(
                            color: _getCategoryColor(rp.category),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${rp.planetTa} (${rp.planet})',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          Text(
                            '${rp.source} — ${rp.categoryEn}',
                            style: TextStyle(color: Colors.white.withAlpha(140), fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    // Houses owned/occupied
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.teal.withAlpha(30),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.teal.shade300, width: 0.8),
                      ),
                      child: Text(
                        'பாவங்கள்: ${rp.houses.isEmpty ? '-' : rp.houses.join(', ')}',
                        style: const TextStyle(color: Colors.tealAccent, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Color _getCategoryColor(String cat) {
    switch (cat) {
      case 'ரா.அ':
        return Colors.lightGreenAccent;
      case 'ந.அ':
        return Colors.cyanAccent;
      case 'உ.அ':
        return AppColors.lightGold;
      case 'உ.உ':
        return Colors.orangeAccent;
      case 'உ.உ.உ':
        return Colors.pinkAccent;
      default:
        return Colors.white;
    }
  }

  // ==========================================
  // SECTION 3: கிரக நிலைகள் (Planet Positions)
  // ==========================================
  Widget _buildPlanetPositionsSection() {
    final res = _kpResult!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionHeader('கிரக நிலைகள் (Planetary Positions)', Icons.public_rounded),
        Card(
          color: AppColors.cardSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.borderGold, width: 1),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 14,
              headingRowColor: WidgetStateProperty.all(AppColors.primaryGold.withAlpha(30)),
              dataRowColor: WidgetStateProperty.resolveWith(
                (states) => states.contains(WidgetState.hovered) ? Colors.white.withAlpha(15) : Colors.transparent,
              ),
              columns: const [
                DataColumn(label: Text('கிரகம் (Planet)', style: TextStyle(color: AppColors.lightGold, fontWeight: FontWeight.bold, fontSize: 12))),
                DataColumn(label: Text('பாகை (Degree)', style: TextStyle(color: AppColors.lightGold, fontWeight: FontWeight.bold, fontSize: 12))),
                DataColumn(label: Text('பாவம் (House)', style: TextStyle(color: AppColors.lightGold, fontWeight: FontWeight.bold, fontSize: 12))),
                DataColumn(label: Text('ரா.அ (Sign)', style: TextStyle(color: AppColors.lightGold, fontWeight: FontWeight.bold, fontSize: 12))),
                DataColumn(label: Text('ந.அ (Star)', style: TextStyle(color: AppColors.lightGold, fontWeight: FontWeight.bold, fontSize: 12))),
                DataColumn(label: Text('உ.அ (Sub)', style: TextStyle(color: AppColors.lightGold, fontWeight: FontWeight.bold, fontSize: 12))),
                DataColumn(label: Text('உ.உ (Sub-Sub)', style: TextStyle(color: AppColors.lightGold, fontWeight: FontWeight.bold, fontSize: 12))),
                DataColumn(label: Text('உ.உ.உ (Sub-Sub-Sub)', style: TextStyle(color: AppColors.lightGold, fontWeight: FontWeight.bold, fontSize: 12))),
              ],
              rows: res.planetPositions.map((p) {
                return DataRow(
                  cells: [
                    DataCell(Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('${p.planetTa} (${p.planet})', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
                        if (p.isRetrograde) ...[
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(color: Colors.red.withAlpha(60), borderRadius: BorderRadius.circular(4)),
                            child: const Text('வ', style: TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ],
                    )),
                    DataCell(Text(p.degreeStr, style: const TextStyle(color: Colors.white70, fontSize: 11))),
                    DataCell(Center(child: Text('${p.house}', style: const TextStyle(color: Colors.tealAccent, fontWeight: FontWeight.bold, fontSize: 12)))),
                    DataCell(Text(p.signLord, style: const TextStyle(color: Colors.lightGreenAccent, fontSize: 11))),
                    DataCell(Text(p.starLord, style: const TextStyle(color: Colors.cyanAccent, fontSize: 11))),
                    DataCell(Text(p.subLord, style: const TextStyle(color: AppColors.lightGold, fontWeight: FontWeight.bold, fontSize: 11))),
                    DataCell(Text(p.subSubLord, style: const TextStyle(color: Colors.orangeAccent, fontSize: 11))),
                    DataCell(Text(p.subSubSubLord, style: const TextStyle(color: Colors.pinkAccent, fontSize: 11))),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // SECTION 4: பாவ தொடர்புகள் (Cusp Relations)
  // ==========================================
  Widget _buildCuspRelationsSection() {
    final res = _kpResult!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionHeader('பாவ தொடர்புகள் & சாதக / பாதக வீடுகள் (Cusp Relations)', Icons.account_tree_rounded),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: res.cuspRelations.length,
          itemBuilder: (context, idx) {
            final cr = res.cuspRelations[idx];
            final cuspPos = res.cusps[idx];

            return Card(
              color: AppColors.cardSurface,
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(
                  color: cr.redHouses.isNotEmpty ? Colors.red.withAlpha(100) : AppColors.borderGold.withAlpha(100),
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cusp Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primaryGold.withAlpha(40),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.primaryGold),
                              ),
                              child: Text(
                                'பாவம் ${cr.cuspNumber}',
                                style: const TextStyle(color: AppColors.lightGold, fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${cuspPos.signNameTa} (${cuspPos.degreeStr})',
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                        // Lords summary
                        Text(
                          'ந: ${cr.starLord} | உ: ${cr.subLord}',
                          style: const TextStyle(color: Colors.white60, fontSize: 11),
                        ),
                      ],
                    ),
                    const Divider(color: Colors.white10, height: 16),
                    // Signified Houses row
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'நட்சத்திர அதிபதி வீடுகள்: ${cr.starHouses.isEmpty ? '-' : cr.starHouses.join(', ')}',
                            style: const TextStyle(color: Colors.cyanAccent, fontSize: 11),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'உப அதிபதி வீடுகள்: ${cr.subHouses.isEmpty ? '-' : cr.subHouses.join(', ')}',
                            style: const TextStyle(color: AppColors.lightGold, fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'முடிவு தொடர்புகள் (Final Houses): ${cr.finalHouses.isEmpty ? '-' : cr.finalHouses.join(', ')}',
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    // Red & Blue Badges
                    Row(
                      children: [
                        // Blue Houses (Favorable)
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.blue.withAlpha(25),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.blueAccent.withAlpha(120), width: 1),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle_rounded, color: Colors.blueAccent, size: 14),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: Text(
                                    'வளர்ச்சி வீடுகள் (Blue): ${cr.blueHouses.isEmpty ? 'இல்லை' : cr.blueHouses.join(', ')}',
                                    style: const TextStyle(color: Colors.lightBlueAccent, fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Red Houses (Challenging)
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.red.withAlpha(25),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.redAccent.withAlpha(120), width: 1),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 14),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: Text(
                                    'தடை வீடுகள் (Red): ${cr.redHouses.isEmpty ? 'இல்லை' : cr.redHouses.join(', ')}',
                                    style: const TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // ==========================================
  // SECTION 5: தசா நிலைகள் (Dasha)
  // ==========================================
  Widget _buildDashaSection() {
    final res = _kpResult!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionHeader('தசா நிலைகள் (Vimshottari Dasha Periods)', Icons.timelapse_rounded),
        Card(
          color: AppColors.cardSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.borderGold, width: 1),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: res.dashaPeriods.length,
            separatorBuilder: (_, __) => const Divider(color: Colors.white10, height: 1),
            itemBuilder: (context, idx) {
              final d = res.dashaPeriods[idx];
              final isCurrent = DateTime.now().isAfter(d.startDate) && DateTime.now().isBefore(d.endDate);

              return Container(
                color: isCurrent ? AppColors.primaryGold.withAlpha(20) : Colors.transparent,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    // Planet Circle
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCurrent ? AppColors.primaryGold : Colors.white12,
                        border: Border.all(color: isCurrent ? AppColors.lightGold : Colors.white24),
                      ),
                      child: Center(
                        child: Text(
                          d.planetTa.isNotEmpty ? d.planetTa[0] : d.planet[0],
                          style: TextStyle(
                            color: isCurrent ? AppColors.backgroundDeep : Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
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
                                '${d.planetTa} தசை (${d.planet})',
                                style: TextStyle(
                                  color: isCurrent ? AppColors.lightGold : Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              if (isCurrent) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade900,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text('நடப்பு (Active)', style: TextStyle(color: Colors.greenAccent, fontSize: 9, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'காலம்: ${d.startDateFormatted} முதல் ${d.endDateFormatted} வரை',
                            style: const TextStyle(color: Colors.white70, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    // Related houses
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.indigo.withAlpha(40),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.indigoAccent.withAlpha(100), width: 0.8),
                      ),
                      child: Text(
                        'பாவங்கள்: ${d.relatedHouses.isEmpty ? '-' : d.relatedHouses.join(', ')}',
                        style: const TextStyle(color: Colors.indigoAccent, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ==========================================
  // SECTION 6: பிறந்த நேரத் திருத்தம் (Birth Time Rectification)
  // ==========================================
  Widget _buildRectificationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionHeader('பிறந்த நேரத் திருத்தம் (Birth Time Rectification)', Icons.published_with_changes_rounded),
        Card(
          color: AppColors.cardSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.borderGold, width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'கே.பி ஆளும் கிரகங்கள் அடிப்படையில் பிறந்த நேரத் திருத்தம் (KP Ruling Planets Rectification)',
                  style: GoogleFonts.notoSansTamil(
                    color: AppColors.lightGold,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'லக்ன உப நாதர் மற்றும் உப-உப நாதர் ஆகியவை ஆளும் கிரகங்களுடன் (Ruling Planets) முழுமையாகப் பொருந்துகிறதா என ஆய்வு செய்து துல்லியமான பிறந்த நேரத்தை கண்டறியும்.',
                  style: GoogleFonts.notoSansTamil(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGold,
                    foregroundColor: AppColors.backgroundDeep,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: _isRectifying
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.backgroundDeep),
                        )
                      : const Icon(Icons.auto_fix_high_rounded),
                  label: Text(
                    _isRectifying ? 'ஆய்வு செய்யப்படுகிறது...' : 'நேரத்தை ஆய்வு செய் (Analyze & Rectify Time)',
                    style: GoogleFonts.notoSansTamil(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  onPressed: _isRectifying ? null : _runRectification,
                ),

                if (_rectificationResult != null) ...[
                  const Divider(color: Colors.white12, height: 28),
                  _buildRectificationResultsCard(_rectificationResult!),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRectificationResultsCard(BirthTimeRectificationResult r) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.teal.shade300, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'முடிவு (Rectification Result)',
                style: GoogleFonts.notoSansTamil(
                  color: Colors.tealAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.teal.withAlpha(40),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'பொருத்தம்: ${r.congruenceScore.toStringAsFixed(1)}%',
                  style: const TextStyle(color: Colors.tealAccent, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildRectifyRow('அசல் நேரம் (Original Time):', _formatTime(r.originalBirthData.dateTime, withSeconds: true)),
          _buildRectifyRow('திருத்தப்பட்ட நேரம் (Rectified Time):', _formatTime(r.rectifiedBirthData.dateTime, withSeconds: true)),
          _buildRectifyRow('கால வித்தியாசம் (Time Offset):', r.offsetFormatted),
          _buildRectifyRow('திருத்தப்பட்ட லக்ன பாகை (Ascendant):', r.rectifiedLagnaDegreeStr),
          _buildRectifyRow('லக்ன உப நாதர் (Sub Lord):', r.rectifiedSubLord),
          _buildRectifyRow('லக்ன உப-உப நாதர் (Sub-Sub Lord):', r.rectifiedSubSubLord),
          const Divider(color: Colors.white10, height: 18),
          Text(
            r.explanationTa,
            style: GoogleFonts.notoSansTamil(color: Colors.white70, fontSize: 11),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.tealAccent, width: 1.2),
                foregroundColor: Colors.tealAccent,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
              label: Text(
                'திருத்தப்பட்ட நேரத்தைப் பயன்படுத்து (Apply Rectified Time)',
                style: GoogleFonts.notoSansTamil(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              onPressed: () => _applyRectifiedTime(r.rectifiedBirthData),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRectifyRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11)),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryGold, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.cinzel(
              color: AppColors.lightGold,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
