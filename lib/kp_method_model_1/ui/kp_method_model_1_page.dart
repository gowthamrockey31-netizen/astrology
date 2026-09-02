import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../services/auth_service.dart';
import '../../widgets/cosmic_background.dart';
import '../engine/kp_complete_engine.dart';
import '../models/kp_birth_data.dart';
import '../models/kp_result.dart';
import 'kp_cusp_table.dart';
import 'kp_dasha_view.dart';
import 'kp_planet_table.dart';
import 'kp_rasi_table.dart';
import 'kp_rectification_view.dart';
import 'kp_ruling_planet_card.dart';
import 'kp_significator_table.dart';

/// KP METHOD MODEL 1 Page
/// KP Astrology Calculation & Analysis complete module
class KPMethodModel1Page extends StatefulWidget {
  final KPBirthData? initialBirthData;

  const KPMethodModel1Page({super.key, this.initialBirthData});

  @override
  State<KPMethodModel1Page> createState() => _KPMethodModel1PageState();
}

class _KPMethodModel1PageState extends State<KPMethodModel1Page> {
  late KPBirthData _birthData;
  KPMethodModel1Result? _result;
  bool _isLoading = true;
  int _selectedTabIndex = 0;

  final List<String> _tabs = [
    'Horoscope',
    'Rasi / கிரகங்கள்',
    'Ruling Planets',
    '12 Cusps',
    '9 Planets',
    'Planet Significators',
    'House Significators',
    'Dasha / Bhukti',
    'Birth Time Rectification',
  ];

  @override
  void initState() {
    super.initState();
    _initBirthData();
  }

  void _initBirthData() {
    if (widget.initialBirthData != null) {
      _birthData = widget.initialBirthData!;
    } else {
      final user = AuthService.currentUser;
      if (user != null) {
        _birthData = KPBirthData.fromUser(user);
      } else {
        _birthData = KPBirthData.defaultData();
      }
    }
    _calculateChart();
  }

  Future<void> _calculateChart() async {
    setState(() => _isLoading = true);
    final engine = KPCompleteEngine();
    final res = await engine.calculate(birth: _birthData);
    if (mounted) {
      setState(() {
        _result = res;
        _isLoading = false;
      });
    }
  }

  void _showEditBirthDialog() {
    final dateCtrl = TextEditingController(text: DateFormat('yyyy-MM-dd').format(_birthData.dateTime));
    final timeCtrl = TextEditingController(text: DateFormat('HH:mm').format(_birthData.dateTime));
    final placeCtrl = TextEditingController(text: _birthData.placeName);
    final latCtrl = TextEditingController(text: _birthData.latitude.toString());
    final lonCtrl = TextEditingController(text: _birthData.longitude.toString());
    final tzCtrl = TextEditingController(text: _birthData.utcOffsetHours.toString());

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.backgroundDeep,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.primaryGold),
          ),
          title: Text(
            'Edit Birth Coordinates',
            style: GoogleFonts.cinzel(color: AppColors.lightGold, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dialogField('Date (YYYY-MM-DD)', dateCtrl),
                const SizedBox(height: 10),
                _dialogField('Time (HH:MM 24hr)', timeCtrl),
                const SizedBox(height: 10),
                _dialogField('Place Name', placeCtrl),
                const SizedBox(height: 10),
                _dialogField('Latitude (e.g. 13.0827)', latCtrl),
                const SizedBox(height: 10),
                _dialogField('Longitude (e.g. 80.2707)', lonCtrl),
                const SizedBox(height: 10),
                _dialogField('Timezone Offset (hrs, e.g. 5.5)', tzCtrl),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGold, foregroundColor: Colors.black),
              onPressed: () {
                final d = DateTime.tryParse(dateCtrl.text) ?? _birthData.dateTime;
                final tParts = timeCtrl.text.split(':');
                final h = int.tryParse(tParts.isNotEmpty ? tParts[0] : '8') ?? 8;
                final m = int.tryParse(tParts.length > 1 ? tParts[1] : '30') ?? 30;
                final dt = DateTime(d.year, d.month, d.day, h, m);
                final lat = double.tryParse(latCtrl.text) ?? _birthData.latitude;
                final lon = double.tryParse(lonCtrl.text) ?? _birthData.longitude;
                final tz = double.tryParse(tzCtrl.text) ?? 5.5;

                setState(() {
                  _birthData = KPBirthData(
                    dateTime: dt,
                    latitude: lat,
                    longitude: lon,
                    placeName: placeCtrl.text.trim().isNotEmpty ? placeCtrl.text.trim() : 'Custom Location',
                    timeZone: Duration(minutes: (tz * 60).round()),
                  );
                });
                Navigator.pop(ctx);
                _calculateChart();
              },
              child: const Text('Recalculate', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Widget _dialogField(String label, TextEditingController ctrl) {
    return TextField(
      controller: ctrl,
      style: const TextStyle(color: Colors.white, fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.lightGold, fontSize: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primaryGold.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primaryGold),
        ),
        filled: true,
        fillColor: AppColors.backgroundMid,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

    return Scaffold(
      body: CosmicBackground(
        child: SafeArea(
          child: Column(
            children: [
              // 1. Top Header
              _buildTopHeader(context),

              // 2. Birth Details Bar
              _buildBirthDetailsBar(dateFormat),

              // 3. Tab Navigation Bar
              _buildTabBar(),

              // 4. Content Area
              Expanded(
                child: _isLoading
                    ? _buildLoadingState()
                    : (_result == null || !_result!.isEngineAvailable)
                        ? _buildUnavailableState()
                        : _buildSelectedTabContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.backgroundDeep.withValues(alpha: 0.8),
        border: Border(bottom: BorderSide(color: AppColors.primaryGold.withValues(alpha: 0.2))),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.lightGold),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'KP METHOD MODEL 1',
                      style: GoogleFonts.cinzel(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.lightGold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
                      ),
                      child: const Text('MODEL 1', style: TextStyle(color: AppColors.primaryGold, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                Text(
                  'KP Astrology Calculation & Analysis (கிருஷ்ணமூர்த்தி பத்ததி)',
                  style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primaryGold),
            tooltip: 'Recalculate',
            onPressed: _calculateChart,
          ),
        ],
      ),
    );
  }

  Widget _buildBirthDetailsBar(DateFormat dateFormat) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: AppColors.backgroundMid.withValues(alpha: 0.7),
      child: Row(
        children: [
          const Icon(Icons.person_pin_rounded, color: AppColors.primaryGold, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Text(
                    dateFormat.format(_birthData.dateTime),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  const Text(' • ', style: TextStyle(color: Colors.white38)),
                  Text(
                    _birthData.placeName,
                    style: const TextStyle(color: AppColors.lightGold, fontSize: 12),
                  ),
                  const Text(' • ', style: TextStyle(color: Colors.white38)),
                  Text(
                    'Lat: ${_birthData.latitude.toStringAsFixed(3)}°, Lon: ${_birthData.longitude.toStringAsFixed(3)}°',
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                  if (_result != null && _result!.isEngineAvailable) ...[
                    const Text(' • ', style: TextStyle(color: Colors.white38)),
                    Text(
                      'KP Ayanamsa: ${_result!.kpAyanamsa.toStringAsFixed(4)}°',
                      style: const TextStyle(color: Colors.amberAccent, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ],
                ],
              ),
            ),
          ),
          TextButton.icon(
            icon: const Icon(Icons.edit_location_alt_rounded, size: 14, color: AppColors.primaryGold),
            label: const Text('Edit', style: TextStyle(color: AppColors.primaryGold, fontSize: 12)),
            onPressed: _showEditBirthDialog,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.backgroundDeep,
        border: Border(bottom: BorderSide(color: AppColors.primaryGold.withValues(alpha: 0.15))),
      ),
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
                color: isSelected ? AppColors.primaryGold : AppColors.primaryGold.withValues(alpha: 0.25),
              ),
              onSelected: (val) {
                if (val) setState(() => _selectedTabIndex = idx);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: AppColors.primaryGold,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'கிரக நிலைகள் கணக்கிடப்படுகிறது...',
            style: GoogleFonts.cinzel(fontSize: 16, color: AppColors.lightGold, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            'Computing Planetary Positions -> Placidus Cusps -> Star & Sub Lords -> Significators',
            style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildUnavailableState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.backgroundMid,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.redAccent.withValues(alpha: 0.4)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 48),
            const SizedBox(height: 16),
            Text(
              'கிரக நிலைகளை கணக்கிட முடியவில்லை',
              style: GoogleFonts.cinzel(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.redAccent),
            ),
            const SizedBox(height: 10),
            Text(
              _result?.errorMessage ??
                  'Connect the supported astronomical ephemeris engine to calculate accurate KP planetary positions and cusps.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.white70),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGold, foregroundColor: Colors.black),
              onPressed: _calculateChart,
              child: const Text('Retry Calculation'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedTabContent() {
    final res = _result!;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_selectedTabIndex == 0) _buildOverviewTab(res),
          if (_selectedTabIndex == 1)
            KPRasiTable(
              planets: res.planets,
              lagnaDegreeFormatted: res.cusps.isNotEmpty ? res.cusps.first.dmsFormatted : null,
              lagnaRasiTa: res.cusps.isNotEmpty ? res.cusps.first.rasiNameTa : null,
              lagnaNakshatraTa: res.cusps.isNotEmpty ? '${res.cusps.first.nakshatraNameTa} (${res.cusps.first.pada})' : null,
            ),
          if (_selectedTabIndex == 2) KPRulingPlanetCard(rulingPlanets: res.rulingPlanets),
          if (_selectedTabIndex == 3) KPCuspTable(cusps: res.cusps),
          if (_selectedTabIndex == 4) KPPlanetTable(planets: res.planets),
          if (_selectedTabIndex == 5)
            KPSignificatorTable(
              planetSignificators: res.planetSignificators,
              houseSignificators: const [],
            ),
          if (_selectedTabIndex == 6)
            KPSignificatorTable(
              planetSignificators: const [],
              houseSignificators: res.houseSignificators,
            ),
          if (_selectedTabIndex == 7) KPDashaView(dashaHierarchy: res.dashaHierarchy),
          if (_selectedTabIndex == 8)
            KPRectificationView(
              birthData: res.birthData,
              rulingPlanets: res.rulingPlanets,
            ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(KPMethodModel1Result res) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Quick Summary Cards
        Row(
          children: [
            Expanded(
              child: _summaryCard(
                'Lagna (Ascendant)',
                res.cusps.isNotEmpty ? '${res.cusps.first.rasiNameEn} (${res.cusps.first.dmsFormatted})' : '-',
                'Sub: ${res.cusps.isNotEmpty ? res.cusps.first.subLord : '-'}',
                Icons.navigation_rounded,
                AppColors.primaryGold,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _summaryCard(
                'Moon Sign & Star',
                res.planets.length > 1 ? '${res.planets[1].rasiNameEn} • ${res.planets[1].nakshatraNameEn}' : '-',
                'Sub: ${res.planets.length > 1 ? res.planets[1].subLord : '-'}',
                Icons.nightlight_round,
                Colors.amberAccent,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Accurate KP Rasi & Planet Positions Table (Matching screenshot format)
        KPRasiTable(
          planets: res.planets,
          lagnaDegreeFormatted: res.cusps.isNotEmpty ? res.cusps.first.dmsFormatted : null,
          lagnaRasiTa: res.cusps.isNotEmpty ? res.cusps.first.rasiNameTa : null,
          lagnaNakshatraTa: res.cusps.isNotEmpty ? '${res.cusps.first.nakshatraNameTa} (${res.cusps.first.pada})' : null,
        ),

        const SizedBox(height: 16),

        // Ruling Planets Summary
        KPRulingPlanetCard(rulingPlanets: res.rulingPlanets),

        const SizedBox(height: 16),

        // 12 Cusps Snapshot
        KPCuspTable(cusps: res.cusps),
      ],
    );
  }

  Widget _summaryCard(String title, String value, String subtitle, IconData icon, Color accent) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.backgroundMid,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: accent),
              const SizedBox(width: 6),
              Text(title, style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.cinzel(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(color: accent, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
