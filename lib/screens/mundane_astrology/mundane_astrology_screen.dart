import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../models/mundane_models.dart';
import '../../services/auth_service.dart';
import '../../services/mundane_calculator.dart';
import '../../widgets/cosmic_background.dart';

/// Screen: உலகியல் ஜோதிடம் (Mundane Astrology) - Admin Only Module
class MundaneAstrologyScreen extends StatefulWidget {
  final MundaneChart? chart;

  const MundaneAstrologyScreen({
    super.key,
    this.chart,
  });

  @override
  State<MundaneAstrologyScreen> createState() => _MundaneAstrologyScreenState();
}

class _MundaneAstrologyScreenState extends State<MundaneAstrologyScreen> {
  late MundaneChart _chart;

  late TextEditingController _countryController;
  late TextEditingController _stateController;
  late TextEditingController _cityController;
  late TextEditingController _dateController;
  late TextEditingController _timeController;
  late TextEditingController _latController;
  late TextEditingController _lonController;

  String _selectedPreset = 'Current'; // 'Current', 'India1947', 'Custom'

  @override
  void initState() {
    super.initState();
    // Safety check: redirect non-admin users immediately
    if (!AuthService.isAdmin) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/user_dashboard');
        }
      });
    }

    _countryController = TextEditingController(text: 'India');
    _stateController = TextEditingController(text: 'Delhi');
    _cityController = TextEditingController(text: 'New Delhi');
    _dateController = TextEditingController(text: DateFormat('yyyy-MM-dd').format(DateTime.now()));
    _timeController = TextEditingController(text: DateFormat('hh:mm a').format(DateTime.now()));
    _latController = TextEditingController(text: '28.6139');
    _lonController = TextEditingController(text: '77.2090');

    _chart = widget.chart ?? MundaneCalculator.calculateMundaneChart(
      dateTime: DateTime.now(),
      country: 'India',
      state: 'Delhi',
      city: 'New Delhi',
      latitude: 28.6139,
      longitude: 77.2090,
    );
  }

  @override
  void dispose() {
    _countryController.dispose();
    _stateController.dispose();
    _cityController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _latController.dispose();
    _lonController.dispose();
    super.dispose();
  }

  void _loadPreset(String preset) {
    setState(() {
      _selectedPreset = preset;
      if (preset == 'India1947') {
        _countryController.text = 'India';
        _stateController.text = 'Delhi';
        _cityController.text = 'New Delhi';
        _dateController.text = '1947-08-15';
        _timeController.text = '00:00 AM';
        _latController.text = '28.6139';
        _lonController.text = '77.2090';
        _chart = MundaneExample.indiaIndependenceChart;
      } else {
        _countryController.text = 'India';
        _stateController.text = 'Delhi';
        _cityController.text = 'New Delhi';
        _dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
        _timeController.text = DateFormat('hh:mm a').format(DateTime.now());
        _latController.text = '28.6139';
        _lonController.text = '77.2090';
        _calculateChart();
      }
    });
  }

  void _calculateChart() {
    final lat = double.tryParse(_latController.text.trim()) ?? 28.6139;
    final lon = double.tryParse(_lonController.text.trim()) ?? 77.2090;
    final parsedDate = DateTime.tryParse(_dateController.text.trim()) ?? DateTime.now();

    final timeStr = _timeController.text.trim();
    final timeParts = timeStr.split(':');
    int hour = 12;
    int min = 0;
    if (timeParts.length >= 2) {
      hour = int.tryParse(timeParts[0].replaceAll(RegExp(r'[^0-9]'), '')) ?? 12;
      min = int.tryParse(timeParts[1].replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      if (timeStr.toUpperCase().contains('PM') && hour < 12) hour += 12;
      if (timeStr.toUpperCase().contains('AM') && hour == 12) hour = 0;
    }

    final dt = DateTime(parsedDate.year, parsedDate.month, parsedDate.day, hour, min);

    setState(() {
      _chart = MundaneCalculator.calculateMundaneChart(
        dateTime: dt,
        country: _countryController.text.trim().isNotEmpty ? _countryController.text.trim() : 'India',
        state: _stateController.text.trim().isNotEmpty ? _stateController.text.trim() : 'Delhi',
        city: _cityController.text.trim().isNotEmpty ? _cityController.text.trim() : 'New Delhi',
        latitude: lat,
        longitude: lon,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Route-level authorization check: NEVER expose Mundane Astrology data to non-admin
    if (!AuthService.isAdmin) {
      return Scaffold(
        backgroundColor: AppColors.backgroundDeep,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.security_rounded, size: 64, color: Colors.redAccent),
                const SizedBox(height: 16),
                Text(
                  'Access Denied / அனுமதி மறுக்கப்பட்டது',
                  style: GoogleFonts.cinzel(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  'உலகியல் ஜோதிடம் (Mundane Astrology) பகுதி நிர்வாகிகளுக்கு (Admin) மட்டுமே அனுமதிக்கப்பட்டுள்ளது.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(fontSize: 13, color: Colors.white70),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGold),
                  onPressed: () => Navigator.of(context).pushReplacementNamed('/user_dashboard'),
                  child: Text('Back to Dashboard', style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      );
    }

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
                _buildHeader(),
                const SizedBox(height: 14),

                // Preset selector chips (Current / Demo 1947 / Custom)
                _buildPresetSelector(),
                const SizedBox(height: 12),

                // A. Location & Event Input / Details
                _buildEventLocationSection(),
                const SizedBox(height: 16),

                // B. Planetary Positions Table (Sorted by absolute longitude ascending)
                _buildPlanetaryPositionsTable(),
                const SizedBox(height: 16),

                // C. Planetary Conjunctions, Aspects & House Clusters
                _buildAspectsAndClustersSection(),
                const SizedBox(height: 16),

                // D. Automatic Mundane Predictions (Sorted by strength)
                _buildPredictionsSection(),
                const SizedBox(height: 16),

                // E. Real-time Transit Comparison Analysis
                _buildTransitSection(),
                const SizedBox(height: 16),

                // F. 12 Mundane Houses Reference
                _buildHouseMeaningsReferenceSection(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
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
                'உலகியல் ஜோதிடம்',
                style: GoogleFonts.cinzel(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.lightGold,
                  letterSpacing: 1.1,
                ),
              ),
              Text(
                'Mundane Astrology • National & Global Trends (Admin Only)',
                style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.redAccent.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.redAccent),
          ),
          child: Text(
            'Admin Only',
            style: GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.redAccent,
            ),
          ),
        ),
      ],
    ).animate().fade(duration: 300.ms);
  }

  Widget _buildPresetSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildPresetChip('Current', 'தற்போதைய தேசிய நிலை (Live Chart)', Icons.radar_rounded),
          const SizedBox(width: 8),
          _buildPresetChip('India1947', 'இந்தியா சுதந்திர ஜாதகம் (1947 Demo)', Icons.flag_rounded),
          const SizedBox(width: 8),
          _buildPresetChip('Custom', 'சுய இட/நிகழ்வு கணக்கீடு (Custom Event)', Icons.tune_rounded),
        ],
      ),
    );
  }

  Widget _buildPresetChip(String key, String label, IconData icon) {
    final isSel = _selectedPreset == key;
    return ChoiceChip(
      avatar: Icon(icon, size: 14, color: isSel ? Colors.black : AppColors.lightGold),
      label: Text(label, style: GoogleFonts.outfit(fontSize: 11, fontWeight: isSel ? FontWeight.bold : FontWeight.normal, color: isSel ? Colors.black : AppColors.lightGold)),
      selected: isSel,
      selectedColor: AppColors.primaryGold,
      backgroundColor: AppColors.backgroundMid,
      side: BorderSide(color: isSel ? AppColors.primaryGold : AppColors.borderGold.withValues(alpha: 0.4)),
      onSelected: (val) {
        if (val) _loadPreset(key);
      },
    );
  }

  Widget _buildEventLocationSection() {
    final fmtDate = DateFormat('dd MMMM yyyy, hh:mm a').format(_chart.chartDateTime);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderGold.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.public_rounded, color: AppColors.primaryGold, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'நிகழ்வு & பிராந்திய விவரங்கள் (Location & Event Details)',
                  style: GoogleFonts.cinzel(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.lightGold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _buildSmallField('நாடு (Country)', _countryController)),
              const SizedBox(width: 8),
              Expanded(child: _buildSmallField('மாநிலம் (State)', _stateController)),
              const SizedBox(width: 8),
              Expanded(child: _buildSmallField('நகரம் (City)', _cityController)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildSmallField('தேதி (Date)', _dateController)),
              const SizedBox(width: 8),
              Expanded(child: _buildSmallField('நேரம் (Time)', _timeController)),
              const SizedBox(width: 8),
              Expanded(child: _buildSmallField('Lat', _latController)),
              const SizedBox(width: 8),
              Expanded(child: _buildSmallField('Lon', _lonController)),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 36,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGold,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: _calculateChart,
              icon: const Icon(Icons.calculate_rounded, size: 16),
              label: Text('உலகியல் ஜாதகம் கணக்கிடுக (Calculate Mundane Chart)', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 11.5)),
            ),
          ),
          const Divider(height: 18, color: Colors.white12),

          // Active Summary Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.backgroundMid,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.borderGold.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on_rounded, color: AppColors.primaryGold, size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${_chart.regionName} • $fmtDate • லக்னம்: ${_chart.ascendant.rasiNameTa} (${_chart.ascendant.formattedDMS})',
                    style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.lightGold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallField(String label, TextEditingController ctrl) {
    return TextFormField(
      controller: ctrl,
      style: GoogleFonts.outfit(fontSize: 11, color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.outfit(fontSize: 9.5, color: AppColors.textSecondary),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        filled: true,
        fillColor: AppColors.backgroundMid,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Colors.white12)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Colors.white12)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AppColors.primaryGold)),
      ),
    );
  }

  Widget _buildPlanetaryPositionsTable() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderGold.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                const Icon(Icons.stars_rounded, color: AppColors.primaryGold, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '9 கிரக நிலைகள் (Planetary Longitudes - 0° to 360° Ascending)',
                    style: GoogleFonts.cinzel(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.lightGold),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.borderGold),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowHeight: 34,
              dataRowMinHeight: 30,
              dataRowMaxHeight: 34,
              horizontalMargin: 12,
              columnSpacing: 14,
              headingRowColor: WidgetStateProperty.all(AppColors.backgroundMid),
              columns: [
                DataColumn(label: Text('கிரகம்', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.lightGold, fontSize: 11))),
                DataColumn(label: Text('பாகை (DMS)', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.lightGold, fontSize: 11))),
                DataColumn(label: Text('ராசி (Sign)', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.lightGold, fontSize: 11))),
                DataColumn(label: Text('பாவம் (House)', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.lightGold, fontSize: 11))),
                DataColumn(label: Text('நட்சத்திரம்-பாதம்', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.lightGold, fontSize: 11))),
                DataColumn(label: Text('முழு பாகை (0-360°)', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.lightGold, fontSize: 11))),
              ],
              rows: _chart.planetPositions.map((p) {
                return DataRow(
                  cells: [
                    DataCell(Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(p.tamilName, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 11.5)),
                        if (p.isRetrograde) ...[
                          const SizedBox(width: 4),
                          Text('(வ)', style: GoogleFonts.outfit(color: Colors.cyanAccent, fontWeight: FontWeight.bold, fontSize: 10)),
                        ],
                      ],
                    )),
                    DataCell(Text(p.formattedDMS, style: GoogleFonts.outfit(color: AppColors.lightGold, fontSize: 11))),
                    DataCell(Text(p.rasiNameTa, style: GoogleFonts.outfit(color: Colors.white70, fontSize: 11))),
                    DataCell(Text('${p.house}-ஆம் பாவம்', style: GoogleFonts.outfit(color: Colors.white, fontSize: 11))),
                    DataCell(Text('${p.nakshatraNameTa}-${p.pada}', style: GoogleFonts.outfit(color: AppColors.lightGold, fontSize: 11))),
                    DataCell(Text('${p.longitude.toStringAsFixed(2)}°', style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 11))),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAspectsAndClustersSection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderGold.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Aspects header
          Row(
            children: [
              const Icon(Icons.compare_arrows_rounded, color: AppColors.primaryGold, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'முக்கிய உலகியல் பார்வைகள் & சேர்க்கைகள் (Planetary Aspects)',
                  style: GoogleFonts.cinzel(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.lightGold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Aspects list
          if (_chart.aspects.isEmpty)
            Text('தற்போது தீவிர கிரக பார்வைகள் இல்லை.', style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary))
          else
            Column(
              children: _chart.aspects.map((a) {
                final isMalefic = a.nature == 'Malefic';
                return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundMid,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isMalefic ? Colors.redAccent.withValues(alpha: 0.4) : Colors.greenAccent.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${a.planet1} ↔ ${a.planet2} (${a.aspectTypeTa} - ${a.angularDistance.toStringAsFixed(1)}°)',
                          style: GoogleFonts.outfit(fontSize: 11.5, fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        a.natureTa,
                        style: GoogleFonts.outfit(fontSize: 10.5, color: isMalefic ? Colors.redAccent : Colors.greenAccent),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),

          // House Clusters Section (if 3 or more planets in same house)
          if (_chart.clusters.isNotEmpty) ...[
            const Divider(height: 20, color: Colors.white12),
            Row(
              children: [
                const Icon(Icons.hub_rounded, color: Colors.amberAccent, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'பாவ கிரகக் கூட்டணிகள் (House Clusters - 3+ Planets)',
                    style: GoogleFonts.cinzel(fontSize: 12.5, fontWeight: FontWeight.bold, color: Colors.amberAccent),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Column(
              children: _chart.clusters.map((c) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amberAccent.withValues(alpha: 0.4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${c.houseNumber}-ஆம் பாவத்தில் ${c.planetCount} கிரகங்கள்',
                            style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.amberAccent),
                          ),
                          Text('ஆற்றல்: ${c.predictionStrength}%', style: GoogleFonts.outfit(fontSize: 11, color: AppColors.lightGold, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(c.interpretationTa, style: GoogleFonts.outfit(fontSize: 11, color: Colors.white70)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPredictionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'தேசிய & உலகளாவிய பலன்கள் (Mundane Predictions)',
                style: GoogleFonts.cinzel(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.lightGold),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primaryGold.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Sorted by Strength',
                style: GoogleFonts.outfit(fontSize: 9.5, color: AppColors.lightGold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Column(
          children: _chart.predictions.map((pred) {
            final isFav = pred.isFavorable;
            final progressColor = isFav ? Colors.greenAccent : Colors.orangeAccent;

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.cardSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderGold.withValues(alpha: 0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGold.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          pred.categoryTa,
                          style: GoogleFonts.cinzel(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryGold),
                        ),
                      ),
                      Row(
                        children: [
                          Icon(isFav ? Icons.trending_up_rounded : Icons.warning_amber_rounded, size: 14, color: progressColor),
                          const SizedBox(width: 4),
                          Text(
                            '${pred.strength}% (${pred.intensityTa})',
                            style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: progressColor),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: pred.strength / 100.0,
                      minHeight: 4,
                      backgroundColor: Colors.white12,
                      valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    pred.titleTa,
                    style: GoogleFonts.outfit(fontSize: 12.5, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    pred.descriptionTa,
                    style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary),
                  ),
                ],
              ),
            );
          }).toList(),
        ),

        // Astrology Disclaimer
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.blueGrey.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blueGrey.withValues(alpha: 0.3)),
          ),
          child: Text(
            'குறிப்பு: இவை அனைத்தும் உலகியல் ஜோதிட விதிகளின்படியான கிரக சேர்க்கை மதிப்பீடுகள் மட்டுமே. அறிவியல் ரீதியான அல்லது உறுதியான நிகழ்வுகளின் முன்அறிவிப்பு அல்ல.',
            style: GoogleFonts.outfit(fontSize: 10, color: Colors.white60, fontStyle: FontStyle.italic),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildTransitSection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderGold.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.sync_alt_rounded, color: AppColors.primaryGold, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'கோச்சார ஒப்பீட்டு ஆய்வு (Transit vs Natal/Event Chart)',
                  style: GoogleFonts.cinzel(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.lightGold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (_chart.transitComparisons.isEmpty)
            Text('தற்போது தீவிர கோச்சார பார்வைகள் இல்லை.', style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary))
          else
            Column(
              children: _chart.transitComparisons.take(4).map((tc) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundMid,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: tc.isFavorable ? Colors.greenAccent.withValues(alpha: 0.3) : Colors.orangeAccent.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'கோச்சாரம் ${tc.transitPlanet.tamilName} ↔ நிகழ்வு ${tc.eventPlanet.tamilName} (${tc.aspectTypeTa})',
                            style: GoogleFonts.outfit(fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          Text('${tc.strength}%', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.lightGold)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(tc.interpretationTa, style: GoogleFonts.outfit(fontSize: 10.5, color: AppColors.textSecondary)),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildHouseMeaningsReferenceSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderGold.withValues(alpha: 0.5)),
      ),
      child: Material(
        color: Colors.transparent,
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            leading: const Icon(Icons.menu_book_rounded, color: AppColors.primaryGold, size: 20),
            title: Text(
              '12 உலகியல் பாவங்களின் தேசிய காரகத்துவங்கள் (12 Mundane Houses)',
              style: GoogleFonts.cinzel(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.lightGold),
            ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Column(
                children: MundaneData.houseMeaningsTa.entries.map((e) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGold.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${e.key}-ஆம் பாவம்',
                            style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.lightGold),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            e.value,
                            style: GoogleFonts.outfit(fontSize: 10.5, color: Colors.white70),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
