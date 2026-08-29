import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../models/bnn_models.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/bnn_engine.dart';
import '../../widgets/cosmic_background.dart';

/// Module Screen: பிருகு நந்தி நாடி முறை (Bhrigu Nandi Nadi / BNN Method)
class BhriguNandiNadiScreen extends StatefulWidget {
  const BhriguNandiNadiScreen({super.key});

  @override
  State<BhriguNandiNadiScreen> createState() => _BhriguNandiNadiScreenState();
}

class _BhriguNandiNadiScreenState extends State<BhriguNandiNadiScreen> {
  late UserModel _user;
  BnnChartData? _chartData;
  String? _errorMessage;

  String _selectedPlanetKey = 'Jupiter'; // Default to Jeeva Karaka Jupiter (குரு)

  // Editable birth input controllers
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

    _dobController = TextEditingController(text: _user.dob);
    _tobController = TextEditingController(text: _user.timeOfBirth);
    _placeController = TextEditingController(text: _user.placeOfBirth.isNotEmpty ? _user.placeOfBirth : 'Chennai');
    _latController = TextEditingController(text: _user.latitude.toString());
    _lonController = TextEditingController(text: _user.longitude.toString());

    _calculateHoroscope();
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

  void _calculateHoroscope() {
    setState(() => _errorMessage = null);

    final lat = double.tryParse(_latController.text.trim()) ?? 0.0;
    final lon = double.tryParse(_lonController.text.trim()) ?? 0.0;

    // Coordinate validation: never allow 0,0 for real horoscope calculation
    if (lat == 0.0 && lon == 0.0) {
      setState(() {
        _errorMessage = 'பிறந்த இடத்தின் அட்ச/தீர்க்கரேகை (Latitude & Longitude) தேவை. 0,0 பயன்படுத்த முடியாது.';
        _chartData = null;
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
      final chart = BnnChartProvider.calculateBnnChart(
        birthDateTime: birthDt,
        latitude: lat,
        longitude: lon,
        utcOffsetHours: _user.timezone,
        placeName: _placeController.text.trim(),
      );

      setState(() {
        _chartData = chart;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _chartData = null;
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
                // Header
                _buildHeader(),
                const SizedBox(height: 14),

                // Birth Details & Coordinates Input Card
                _buildBirthInputCard(),
                const SizedBox(height: 16),

                if (_errorMessage != null)
                  _buildErrorBanner(_errorMessage!)
                else if (_chartData != null) ...[
                  // 1. Planetary Positions Section
                  _buildPlanetaryPositionsSection(_chartData!),
                  const SizedBox(height: 18),

                  // 2. BNN Connections Section
                  _buildBnnConnectionsSection(_chartData!),
                  const SizedBox(height: 18),

                  // 3. Real Vimshottari Dasha Hierarchy Section
                  _buildDashaSection(_chartData!.dashaResult),
                ],

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
                'பிருகு நந்தி நாடி முறை',
                style: GoogleFonts.cinzel(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.lightGold,
                  letterSpacing: 1.1,
                ),
              ),
              Text(
                '${_user.name} • BNN Horoscope & Dasha',
                style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primaryGold.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderGold),
          ),
          child: Text(
            'BNN Engine',
            style: GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.lightGold,
            ),
          ),
        ),
      ],
    ).animate().fade(duration: 300.ms);
  }

  Widget _buildBirthInputCard() {
    return Container(
      padding: const EdgeInsets.all(12),
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
              const Icon(Icons.person_pin_circle_rounded, color: AppColors.primaryGold, size: 18),
              const SizedBox(width: 6),
              Text(
                'ஜாதக விவரங்கள் (Birth Input & Coordinates)',
                style: GoogleFonts.cinzel(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.lightGold),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildInputField(label: 'பிறந்த தேதி', controller: _dobController, icon: Icons.calendar_today_rounded),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildInputField(label: 'பிறந்த நேரம்', controller: _tobController, icon: Icons.access_time_rounded),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildInputField(label: 'பிறந்த இடம்', controller: _placeController, icon: Icons.location_city_rounded),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildInputField(label: 'Lat', controller: _latController, icon: Icons.explore_outlined),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildInputField(label: 'Lon', controller: _lonController, icon: Icons.explore_outlined),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 38,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGold,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: _calculateHoroscope,
              icon: const Icon(Icons.calculate_rounded, size: 18),
              label: Text('கணக்கீடு செய்க (Calculate BNN Chart)', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      style: GoogleFonts.outfit(fontSize: 11.5, color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.outfit(fontSize: 10.5, color: AppColors.textSecondary),
        prefixIcon: Icon(icon, color: AppColors.primaryGold, size: 14),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        filled: true,
        fillColor: AppColors.backgroundMid,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.white12)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.white12)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.primaryGold)),
      ),
    );
  }

  Widget _buildErrorBanner(String error) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.redAccent),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              error,
              style: GoogleFonts.outfit(color: Colors.redAccent, fontSize: 11.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanetaryPositionsSection(BnnChartData chart) {
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
                const Icon(Icons.scatter_plot_rounded, color: AppColors.primaryGold, size: 18),
                const SizedBox(width: 8),
                Text(
                  'கிரக நிலைகள் (Planetary Positions & Bhavas)',
                  style: GoogleFonts.cinzel(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.lightGold),
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
                DataColumn(label: Text('பாவம் (House)', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.lightGold, fontSize: 11))),
                DataColumn(label: Text('ராசி', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.lightGold, fontSize: 11))),
                DataColumn(label: Text('பாகை (Degree)', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.lightGold, fontSize: 11))),
                DataColumn(label: Text('நட்சத்திரம்-பாதம்', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.lightGold, fontSize: 11))),
              ],
              rows: chart.planets.map((p) {
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
                    DataCell(Text('${p.houseNumber}-ஆம் பாவம்', style: GoogleFonts.outfit(color: AppColors.lightGold, fontSize: 11))),
                    DataCell(Text(p.signNameTa, style: GoogleFonts.outfit(color: Colors.white70, fontSize: 11))),
                    DataCell(Text(p.formattedDegreeDMS, style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 11))),
                    DataCell(Text('${p.nakshatraNameTa}-${p.pada}', style: GoogleFonts.outfit(color: AppColors.lightGold, fontSize: 11))),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBnnConnectionsSection(BnnChartData chart) {
    final selectedPlanet = chart.planets.firstWhere(
      (p) => p.planetKey == _selectedPlanetKey,
      orElse: () => chart.planets.first,
    );
    final analysis = chart.analyses[_selectedPlanetKey];
    final connections = analysis?.allSortedConnections ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'பிருகு நந்தி நாடி கிரக தொடர்புகள் (BNN Connections)',
          style: GoogleFonts.cinzel(fontSize: 13.5, fontWeight: FontWeight.bold, color: AppColors.lightGold),
        ),
        const SizedBox(height: 8),

        // Planet Selection Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: chart.planets.map((p) {
              final isSel = p.planetKey == _selectedPlanetKey;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(
                    '${p.tamilName} (${p.englishName})',
                    style: GoogleFonts.outfit(
                      fontSize: 11.5,
                      fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                      color: isSel ? Colors.black : AppColors.lightGold,
                    ),
                  ),
                  selected: isSel,
                  selectedColor: AppColors.primaryGold,
                  backgroundColor: AppColors.backgroundMid,
                  side: BorderSide(color: isSel ? AppColors.primaryGold : AppColors.borderGold.withValues(alpha: 0.4)),
                  onSelected: (val) {
                    if (val) setState(() => _selectedPlanetKey = p.planetKey);
                  },
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 12),

        // Connections List
        if (connections.isEmpty)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.cardSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white12),
            ),
            child: Text(
              'இந்த கிரகத்திற்கு நேரடி BNN தொடர்புகள் இல்லை.',
              style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 11.5),
            ),
          )
        else
          Column(
            children: connections.map((conn) => _buildConnectionCard(conn, selectedPlanet)).toList(),
          ),
      ],
    );
  }

  Widget _buildConnectionCard(BnnConnection conn, BnnPlanetPosition source) {
    Color badgeColor;
    switch (conn.directionType) {
      case BnnRelationType.trine159:
        badgeColor = Colors.amberAccent;
        break;
      case BnnRelationType.upachaya311:
        badgeColor = Colors.greenAccent;
        break;
      case BnnRelationType.seventh7:
        badgeColor = Colors.purpleAccent;
        break;
      case BnnRelationType.second2:
        badgeColor = Colors.orangeAccent;
        break;
      case BnnRelationType.twelfth12:
        badgeColor = Colors.cyanAccent;
        break;
      default:
        badgeColor = AppColors.lightGold;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: badgeColor.withValues(alpha: 0.4), width: 1),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          leading: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: badgeColor.withValues(alpha: 0.15),
              border: Border.all(color: badgeColor, width: 1),
            ),
            child: Text(
              '${conn.relativeHouse}',
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 11, color: badgeColor),
            ),
          ),
          title: Row(
            children: [
              Text(
                conn.targetPlanet.tamilName,
                style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(width: 6),
              Text(
                conn.relationship.labelTa,
                style: GoogleFonts.outfit(fontSize: 10.5, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          subtitle: Text(
            '${conn.directionType.tamilTitle} • ${conn.targetPlanet.signNameTa} (${conn.targetPlanet.formattedDegreeDMS})',
            style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(color: Colors.white12, height: 12),
                  Text(
                    'காரகத்துவங்கள் (Karakatwas - Max 10):',
                    style: GoogleFonts.cinzel(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.lightGold),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: conn.karakatwas.map((k) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundMid,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Text(
                          k,
                          style: GoogleFonts.outfit(fontSize: 10.5, color: Colors.white.withValues(alpha: 0.9)),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashaSection(BnnDashaResult dasha) {
    final fmt = DateFormat('dd-MM-yyyy');

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.timeline_rounded, color: AppColors.primaryGold, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'விம்சோத்தரி தசை இருப்பு & தசை சக்கரம்',
                      style: GoogleFonts.cinzel(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.lightGold),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGold.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    dasha.balanceFormatted,
                    style: GoogleFonts.outfit(color: AppColors.lightGold, fontSize: 11.5, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.borderGold),

          // Mahadasha Tree using lazy ExpansionTiles
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: dasha.mahadashas.length,
            itemBuilder: (context, mIdx) {
              final maha = dasha.mahadashas[mIdx];
              return Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  leading: const Icon(Icons.stars_rounded, color: AppColors.primaryGold, size: 18),
                  title: Text(
                    '${maha.planetNameTa} மகா தசை (${maha.durationYears.toStringAsFixed(1)} வருடம்)',
                    style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  subtitle: Text(
                    '${fmt.format(maha.startDate)} முதல் ${fmt.format(maha.endDate)} வரை',
                    style: GoogleFonts.outfit(fontSize: 10.5, color: AppColors.textSecondary),
                  ),
                  children: maha.subPeriods.map((bhukti) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 14),
                      child: ExpansionTile(
                        tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 1),
                        leading: const Icon(Icons.circle, color: Colors.amberAccent, size: 8),
                        title: Text(
                          '${bhukti.planetNameTa} புக்தி',
                          style: GoogleFonts.outfit(fontSize: 11.5, fontWeight: FontWeight.w600, color: Colors.amberAccent),
                        ),
                        subtitle: Text(
                          '${fmt.format(bhukti.startDate)} -> ${fmt.format(bhukti.endDate)}',
                          style: GoogleFonts.outfit(fontSize: 10, color: AppColors.textSecondary),
                        ),
                        children: bhukti.subPeriods.map((antara) {
                          return Padding(
                            padding: const EdgeInsets.only(left: 14),
                            child: ExpansionTile(
                              tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 1),
                              leading: const Icon(Icons.arrow_right_rounded, color: Colors.greenAccent, size: 16),
                              title: Text(
                                '${antara.planetNameTa} அந்தரம்',
                                style: GoogleFonts.outfit(fontSize: 11, color: Colors.greenAccent),
                              ),
                              subtitle: Text(
                                '${fmt.format(antara.startDate)} -> ${fmt.format(antara.endDate)}',
                                style: GoogleFonts.outfit(fontSize: 9.5, color: AppColors.textSecondary),
                              ),
                              children: antara.subPeriods.map((sookshma) {
                                return ListTile(
                                  dense: true,
                                  contentPadding: const EdgeInsets.only(left: 36, right: 12),
                                  title: Text(
                                    '${sookshma.planetNameTa} சூட்சுமம்',
                                    style: GoogleFonts.outfit(fontSize: 10.5, color: Colors.white70),
                                  ),
                                  trailing: Text(
                                    '${fmt.format(sookshma.startDate)} -> ${fmt.format(sookshma.endDate)}',
                                    style: GoogleFonts.outfit(fontSize: 9.5, color: AppColors.textSecondary),
                                  ),
                                );
                              }).toList(),
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
