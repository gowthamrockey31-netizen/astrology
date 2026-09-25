import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../models/bnn_method1_model.dart';
import '../../models/user_model.dart';
import '../../providers/bnn_method1_chart_provider.dart';
import '../../services/auth_service.dart';
import '../../widgets/cosmic_background.dart';
import '../modules/bnn_method_2/bnn_method_2_models.dart'
    show BNNMethod2PlanetKaraka, BNNMethod2DiseaseKaraka, BNNMethod2HouseKaraka;

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
                const SizedBox(height: 16),

                if (_errorMessage != null) _buildErrorCard(),

                if (_result != null) ...[
                  _buildPlanetaryDegreeOrderTable(),
                  const SizedBox(height: 20),
                  _buildPlanetSelectorTabs(),
                  const SizedBox(height: 16),
                  _buildSelectedPlanetKarakasSection(),
                  const SizedBox(height: 16),
                  _buildPredictionsSection(),
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
                '${p.planetName} (${p.house})',
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

  Widget _buildSelectedPlanetKarakasSection() {
    final sourcePlanet = _result!.planetaryPositions.firstWhere(
      (p) => p.planetKey == _selectedSourcePlanetKey,
      orElse: () => _result!.planetaryPositions.first,
    );

    final planetKarakas = BNNMethod2PlanetKaraka.get(sourcePlanet.planetKey);
    final diseaseKarakas = BNNMethod2DiseaseKaraka.get(sourcePlanet.planetKey);
    final houseKarakas = BNNMethod2HouseKaraka.get(sourcePlanet.house);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      color: AppColors.cardSurface,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: AppColors.primaryGold.withValues(alpha: 0.6),
          width: 1.2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Planet Header: Name, House, Exact Degree
            _buildPlanetHeader(sourcePlanet),
            const SizedBox(height: 14),

            // ① கிரகத்தின் மிக முக்கியமான 10 காரகங்கள்
            _buildNumberedSection(
              title: '① கிரகத்தின் மிக முக்கியமான 10 காரகங்கள்',
              items: planetKarakas,
              badgeColor: AppColors.primaryGold,
            ),
            const SizedBox(height: 16),

            // ② நோய் / உடல் காரகங்கள்
            _buildNumberedSection(
              title: '② நோய் / உடல் காரகங்கள்',
              items: diseaseKarakas,
              badgeColor: Colors.tealAccent,
            ),
            const SizedBox(height: 16),

            // ③ லக்னத்திலிருந்து {house}ம் பாவத்தின் 10 காரகங்கள்
            _buildNumberedSection(
              title: '③ லக்னத்திலிருந்து ${sourcePlanet.house}ம் பாவத்தின் 10 காரகங்கள்',
              items: houseKarakas,
              badgeColor: Colors.purpleAccent,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanetHeader(BnnMethod1Planet planet) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundMid,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.borderGold.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryGold.withValues(alpha: 0.2),
              border: Border.all(color: AppColors.primaryGold, width: 1.5),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: AppColors.lightGold,
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
                      planet.planetName,
                      style: GoogleFonts.cinzel(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.lightGold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '(${planet.englishName})',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  '${planet.signNameTa} • பாவம்: ${planet.house} • ${planet.nakshatra} (${planet.nakshatraPada})',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black45,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.7)),
            ),
            child: Column(
              children: [
                Text(
                  'பாகை',
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  planet.formattedDMS,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.lightGold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberedSection({
    required String title,
    required List<String> items,
    required Color badgeColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.lightGold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.backgroundMid.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.borderGold.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final idx = entry.key + 1;
              final text = entry.value;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: badgeColor.withValues(alpha: 0.15),
                      ),
                      child: Text(
                        '$idx',
                        style: GoogleFonts.outfit(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: badgeColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        text,
                        style: GoogleFonts.outfit(
                          fontSize: 12.5,
                          color: Colors.white,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
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

}
