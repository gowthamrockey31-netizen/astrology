import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../models/bnn_method1_model.dart';
import '../../models/user_model.dart';
import '../../providers/bnn_method1_chart_provider.dart';
import '../../services/auth_service.dart';
import '../../widgets/cosmic_background.dart';

/// Screen for Bhrigu Nandi Nadi (BNN) Method 1
/// Features:
/// 1. Birth details input & validation
/// 2. Planetary positions & Degree order
/// 3. BNN Method 1 connections (1, 5, 9 → 3, 11 → 7 → 2 → 12)
/// 4. Relative house & planetary relations (நட்பு, பகை, சமம்)
/// 5. Centralized Karakatwas
/// 6. Deterministic Tamil predictions
class BnnMethod1Screen extends StatefulWidget {
  const BnnMethod1Screen({super.key});

  @override
  State<BnnMethod1Screen> createState() => _BnnMethod1ScreenState();
}

class _BnnMethod1ScreenState extends State<BnnMethod1Screen> {
  late UserModel _user;
  BnnMethod1Result? _result;
  String? _errorMessage;
  String _selectedSourcePlanetKey = 'Jupiter'; // Default Jeeva Karaka Jupiter (குரு)

  // Editable input controllers
  late TextEditingController _dobController;
  late TextEditingController _tobController;
  late TextEditingController _placeController;
  late TextEditingController _latController;
  late TextEditingController _lonController;

  @override
  void initState() {
    super.initState();
    _initUser();
  }

  void _initUser() {
    _user = AuthService.currentUser ??
        UserModel(
          id: 'bnn_m1_usr',
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

    _dobController = TextEditingController(text: _user.dob);
    _tobController = TextEditingController(text: _user.timeOfBirth);
    _placeController = TextEditingController(
      text: _user.placeOfBirth.isNotEmpty ? _user.placeOfBirth : 'Chennai',
    );
    _latController = TextEditingController(text: _user.latitude.toString());
    _lonController = TextEditingController(text: _user.longitude.toString());

    _calculateMethod1Horoscope();
  }

  @override
  void dispose() {
    _dobController.dispose();
    _tobController.dispose();
    _placeController.dispose();
    _latController.dispose();
    _lonController.dispose();
    super.dispose();
  }

  void _calculateMethod1Horoscope() {
    setState(() => _errorMessage = null);

    final lat = double.tryParse(_latController.text.trim()) ?? 0.0;
    final lon = double.tryParse(_lonController.text.trim()) ?? 0.0;

    // Rule 13: Strict coordinate validation
    if (lat == 0.0 && lon == 0.0) {
      setState(() {
        _errorMessage = 'பிறந்த இடத்தின் அட்ச/தீர்க்கரேகை (Latitude & Longitude) தேவை. 0,0 பயன்படுத்த முடியாது.';
        _result = null;
      });
      return;
    }

    final parsedDob = DateTime.tryParse(_dobController.text.trim()) ?? DateTime(1996, 6, 15);
    final tobStr = _tobController.text.trim();
    final tobParts = tobStr.split(':');
    int hour = 8;
    int minute = 30;
    if (tobParts.length >= 2) {
      hour = int.tryParse(tobParts[0].replaceAll(RegExp(r'[^0-9]'), '')) ?? 8;
      minute = int.tryParse(tobParts[1].replaceAll(RegExp(r'[^0-9]'), '')) ?? 30;
      if (tobStr.toUpperCase().contains('PM') && hour < 12) hour += 12;
      if (tobStr.toUpperCase().contains('AM') && hour == 12) hour = 0;
    }

    final birthDt = DateTime(parsedDob.year, parsedDob.month, parsedDob.day, hour, minute);

    try {
      final res = DefaultBnnMethod1ChartProvider.calculateSync(
        birthDateTime: birthDt,
        latitude: lat,
        longitude: lon,
        utcOffsetHours: _user.timezone,
        placeName: _placeController.text.trim(),
      );

      setState(() {
        _result = res;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _result = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CosmicBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 14),
                _buildBirthInputCard(),
                const SizedBox(height: 16),

                if (_errorMessage != null) _buildErrorCard(),

                if (_result != null) ...[
                  _buildPlanetaryDegreeOrderTable(),
                  const SizedBox(height: 20),
                  _buildPlanetSelectorTabs(),
                  const SizedBox(height: 16),
                  _buildMethod1ConnectionsList(),
                  const SizedBox(height: 20),
                  _buildPredictionsSection(),
                  const SizedBox(height: 20),
                  if (_result!.dashaResult != null) _buildDashaCard(),
                  const SizedBox(height: 24),
                ],
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
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.lightGold, size: 20),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'பிருகு நந்தி நாடி - முறை 1',
                style: GoogleFonts.cinzel(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.lightGold,
                  letterSpacing: 0.8,
                ),
              ),
              Text(
                'BNN Method 1 (1,5,9 → 3,11 → 7 → 2 → 12)',
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  color: Colors.white70,
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
            'முறை 1',
            style: GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.lightGold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBirthInputCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderGold.withValues(alpha: 0.4)),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.edit_calendar_rounded, color: AppColors.lightGold, size: 18),
              const SizedBox(width: 8),
              Text(
                'பிறப்பு விவரங்கள் (Birth Data Input)',
                style: GoogleFonts.cinzel(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: AppColors.lightGold,
                ),
              ),
            ],
          ),
          const Divider(color: AppColors.borderGold, height: 16),
          Row(
            children: [
              Expanded(child: _buildInputField(_dobController, 'பிறந்த தேதி', 'YYYY-MM-DD')),
              const SizedBox(width: 8),
              Expanded(child: _buildInputField(_tobController, 'பிறந்த நேரம்', 'HH:MM AM/PM')),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildInputField(_placeController, 'பிறந்த இடம்', 'City / Town')),
              const SizedBox(width: 8),
              Expanded(child: _buildInputField(_latController, 'அட்சரேகை (Lat)', '13.0827')),
              const SizedBox(width: 8),
              Expanded(child: _buildInputField(_lonController, 'தீர்க்கரேகை (Lon)', '80.2707')),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 38,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGold,
                foregroundColor: AppColors.backgroundDeep,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: _calculateMethod1Horoscope,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(
                'முறை 1 கணிப்பு செய்க (Calculate Method 1)',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(TextEditingController ctrl, String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(fontSize: 10, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 3),
        TextField(
          controller: ctrl,
          style: GoogleFonts.outfit(color: Colors.white, fontSize: 12),
          decoration: InputDecoration(
            isDense: true,
            hintText: hint,
            hintStyle: GoogleFonts.outfit(color: Colors.white30, fontSize: 11),
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            filled: true,
            fillColor: AppColors.inputBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.white24),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primaryGold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _errorMessage ?? '',
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanetaryDegreeOrderTable() {
    final planets = _result!.planetaryPositions;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderGold.withValues(alpha: 0.4)),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.format_list_numbered_rounded, color: AppColors.lightGold, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'கிரக நிலைகள் & டிகிரி வரிசை (Planetary Positions & Degree Order)',
                  style: GoogleFonts.cinzel(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.lightGold,
                  ),
                ),
              ),
            ],
          ),
          const Divider(color: AppColors.borderGold, height: 14),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowHeight: 36,
              dataRowMinHeight: 32,
              dataRowMaxHeight: 36,
              columnSpacing: 14,
              horizontalMargin: 8,
              headingRowColor: WidgetStateProperty.all(AppColors.backgroundMid),
              columns: [
                DataColumn(label: Text('கிரகம்', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.lightGold, fontSize: 11))),
                DataColumn(label: Text('பாகை (DD°MM\'SS")', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.lightGold, fontSize: 11))),
                DataColumn(label: Text('ராசி', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.lightGold, fontSize: 11))),
                DataColumn(label: Text('பாவம்', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.lightGold, fontSize: 11))),
                DataColumn(label: Text('நட்சத்திரம்-பாதம்', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.lightGold, fontSize: 11))),
                DataColumn(label: Text('டிகிரி வரிசை', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.lightGold, fontSize: 11))),
                DataColumn(label: Text('இயக்கம்', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.lightGold, fontSize: 11))),
              ],
              rows: planets.map((p) {
                return DataRow(
                  cells: [
                    DataCell(Text(p.planetName, style: GoogleFonts.outfit(color: AppColors.lightGold, fontWeight: FontWeight.bold, fontSize: 11))),
                    DataCell(Text(p.formattedDMS, style: GoogleFonts.outfit(color: Colors.white, fontSize: 11))),
                    DataCell(Text(p.signNameTa, style: GoogleFonts.outfit(color: Colors.white70, fontSize: 11))),
                    DataCell(Text('${p.house}-ஆம் பாவம்', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 11))),
                    DataCell(Text('${p.nakshatra} - ${p.nakshatraPada}', style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 11))),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGold.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.5)),
                        ),
                        child: Text(
                          'வரிசை ${p.degreeOrder}',
                          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.lightGold, fontSize: 10),
                        ),
                      ),
                    ),
                    DataCell(Text(
                      p.isRetrograde ? 'வக்ரம் (R)' : 'நேர்கதி (D)',
                      style: GoogleFonts.outfit(
                        color: p.isRetrograde ? AppColors.cyanAccent : Colors.white60,
                        fontSize: 11,
                      ),
                    )),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanetSelectorTabs() {
    final planets = _result!.planetaryPositions;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: planets.map((p) {
          final isSelected = p.planetKey == _selectedSourcePlanetKey;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                p.planetName,
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? AppColors.backgroundDeep : AppColors.lightGold,
                ),
              ),
              selected: isSelected,
              selectedColor: AppColors.primaryGold,
              backgroundColor: AppColors.cardSurface,
              side: BorderSide(
                color: isSelected ? AppColors.primaryGold : AppColors.borderGold.withValues(alpha: 0.4),
              ),
              onSelected: (val) {
                if (val) {
                  setState(() => _selectedSourcePlanetKey = p.planetKey);
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMethod1ConnectionsList() {
    final connections = _result!.connectionsByPlanet[_selectedSourcePlanetKey] ?? [];
    final sourcePlanet = _result!.planetaryPositions.firstWhere(
      (p) => p.planetKey == _selectedSourcePlanetKey,
      orElse: () => _result!.planetaryPositions.first,
    );

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderGold.withValues(alpha: 0.4)),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.hub_rounded, color: AppColors.lightGold, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${sourcePlanet.planetName} - முறை 1 திசைத் தொடர்புகள் (1,5,9 → 3,11 → 7 → 2 → 12)',
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

          if (connections.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  'இந்த கிரகத்திற்கு முறை 1 தொடர்புகள் இல்லை.',
                  style: GoogleFonts.outfit(color: Colors.white60, fontSize: 12),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: connections.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (ctx, idx) {
                final conn = connections[idx];
                return _buildConnectionCard(conn, idx + 1);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildConnectionCard(BnnMethod1Connection conn, int index) {
    Color badgeColor = Colors.grey;
    if (conn.relation == BnnMethod1Relation.friend) badgeColor = Colors.greenAccent;
    if (conn.relation == BnnMethod1Relation.enemy) badgeColor = Colors.redAccent;
    if (conn.relation == BnnMethod1Relation.neutral) badgeColor = Colors.amberAccent;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundMid,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderGold.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '$index. ${conn.targetPlanet.planetName}',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: AppColors.lightGold,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: badgeColor.withValues(alpha: 0.6)),
                ),
                child: Text(
                  conn.relation.labelTa,
                  style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: badgeColor),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primaryGold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  conn.directionGroup.titleTa,
                  style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.lightGold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${conn.targetPlanet.signNameTa} (${conn.targetPlanet.formattedDMS}) | தொடர்பு பாவம்: ${conn.relativeHouse} | டிகிரி வரிசை: ${conn.degreeOrder}',
            style: GoogleFonts.outfit(fontSize: 11, color: Colors.white70),
          ),
          const SizedBox(height: 8),
          Text(
            'காரகத்துவங்கள் (Karakatwas):',
            style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textGold),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: conn.karakatwas.map((k) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(k, style: GoogleFonts.outfit(fontSize: 10, color: Colors.white70)),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionsSection() {
    final predictions = _result!.predictions.where((p) => p.sourcePlanet.planetKey == _selectedSourcePlanetKey).toList();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderGold.withValues(alpha: 0.4)),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome_rounded, color: AppColors.lightGold, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'முறை 1 நாடி பலன்கள் (Method 1 Predictions)',
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

          if (predictions.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Center(
                child: Text(
                  'தற்போது இந்த கிரகத்திற்கு நேரடி பலன்கள் இல்லை.',
                  style: GoogleFonts.outfit(color: Colors.white60, fontSize: 12),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: predictions.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (ctx, idx) {
                final pred = predictions[idx];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundMid,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            pred.summary,
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: AppColors.lightGold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '(${pred.relationLabel})',
                            style: GoogleFonts.outfit(fontSize: 11, color: Colors.white70),
                          ),
                          const Spacer(),
                          Text(
                            'திசை: ${pred.directionTitle}',
                            style: GoogleFonts.outfit(fontSize: 10, color: AppColors.cyanAccent),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        pred.explanationTa,
                        style: GoogleFonts.outfit(fontSize: 12, color: Colors.white, height: 1.4),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildDashaCard() {
    final dasha = _result!.dashaResult!;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderGold.withValues(alpha: 0.4)),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.timelapse_rounded, color: AppColors.lightGold, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'விம்சோத்தரி தசா இருப்பு (Vimshottari Dasha Balance)',
                  style: GoogleFonts.cinzel(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.lightGold,
                  ),
                ),
              ),
            ],
          ),
          const Divider(color: AppColors.borderGold, height: 14),
          Text(
            dasha.balanceFormatted,
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.lightGold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'சந்திரனின் அட்ச/தீர்க்கரேகை அடிப்படையில் துல்லியமாக கணக்கிடப்பட்டது.',
            style: GoogleFonts.outfit(fontSize: 11, color: Colors.white60),
          ),
        ],
      ),
    );
  }
}
