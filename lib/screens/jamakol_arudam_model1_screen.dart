import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../engine/jamakol_arudam_model1_engine.dart';
import '../../models/jamakol_arudam_model1.dart';
import '../../models/user_model.dart';
import '../../services/astrology_calculator.dart';
import '../../services/auth_service.dart';
import '../../widgets/cosmic_background.dart';

/// Screen for ஜாமகோள் ஆருடம் – Model 1 (Jamakol Arudam Model 1)
/// Features:
/// 1. Birth / Query Inputs with coordinate validation
/// 2. Three Core Cards: உதயம், ஆருடம், கவிப்பு with DD° MM' SS"
/// 3. Jamam Status Banner
/// 4. 9 Navagrahas Ephemeris Table
/// 5. Deterministic Model 1 Predictions & Question Success Analysis
class JamakolArudamModel1Screen extends StatefulWidget {
  const JamakolArudamModel1Screen({super.key});

  @override
  State<JamakolArudamModel1Screen> createState() => _JamakolArudamModel1ScreenState();
}

class _JamakolArudamModel1ScreenState extends State<JamakolArudamModel1Screen> {
  late UserModel _user;
  DateTime _queryTime = DateTime.now();
  int _selectedAarudamNumber = 1;
  JamakolArudamModel1Result? _result;
  String? _errorMessage;

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
          id: 'jamakol_m1_usr',
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

    final now = DateTime.now();
    _queryTime = now;
    final hStr = now.hour.toString().padLeft(2, '0');
    final mStr = now.minute.toString().padLeft(2, '0');

    _dobController = TextEditingController(text: "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}");
    _tobController = TextEditingController(text: "$hStr:$mStr");
    _placeController = TextEditingController(
      text: _user.placeOfBirth.isNotEmpty ? _user.placeOfBirth : 'Chennai',
    );
    _latController = TextEditingController(text: _user.latitude.toString());
    _lonController = TextEditingController(text: _user.longitude.toString());

    _calculateModel1();
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

  void _calculateModel1() {
    setState(() => _errorMessage = null);

    final lat = double.tryParse(_latController.text.trim()) ?? 0.0;
    final lon = double.tryParse(_lonController.text.trim()) ?? 0.0;

    // Rule 8 & 14: Coordinate validation
    if (lat == 0.0 && lon == 0.0) {
      setState(() {
        _errorMessage = 'அட்சரேகை மற்றும் தீர்க்கரேகை (Lat/Lon) தேவை. 0,0 பயன்படுத்த முடியாது.';
        _result = null;
      });
      return;
    }

    final parsedDob = DateTime.tryParse(_dobController.text.trim()) ?? DateTime.now();
    final tobStr = _tobController.text.trim();
    final tobParts = tobStr.split(':');
    int hour = _queryTime.hour;
    int minute = _queryTime.minute;
    if (tobParts.length >= 2) {
      hour = int.tryParse(tobParts[0].replaceAll(RegExp(r'[^0-9]'), '')) ?? hour;
      minute = int.tryParse(tobParts[1].replaceAll(RegExp(r'[^0-9]'), '')) ?? minute;
      if (tobStr.toUpperCase().contains('PM') && hour < 12) hour += 12;
      if (tobStr.toUpperCase().contains('AM') && hour == 12) hour = 0;
    }

    final queryDt = DateTime(parsedDob.year, parsedDob.month, parsedDob.day, hour, minute);

    try {
      final res = JamakolArudamModel1Engine.calculate(
        queryTime: queryDt,
        customAarudamNumber: _selectedAarudamNumber,
        latitude: lat,
        longitude: lon,
        utcOffsetHours: _user.timezone,
        placeName: _placeController.text.trim(),
      );

      setState(() {
        _queryTime = queryDt;
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
                _buildInputCard(),
                const SizedBox(height: 16),

                if (_errorMessage != null) _buildErrorCard(),

                if (_result != null) ...[
                  _buildCorePointsSection(),
                  const SizedBox(height: 16),
                  _buildJamamStatusBanner(),
                  const SizedBox(height: 16),
                  _buildPlanetList(_result!.planets),
                  const SizedBox(height: 16),
                  _buildQuestionSuccessAnalysis(),
                  const SizedBox(height: 16),
                  _buildPredictionsList(),
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
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.lightGold, size: 20),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ஜாமகோள் ஆருடம் – Model 1',
                style: GoogleFonts.cinzel(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.lightGold,
                  letterSpacing: 0.8,
                ),
              ),
              Text(
                'Jamakol Arudam Prasannam (Model 1)',
                style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.refresh_rounded, color: AppColors.primaryGold),
          tooltip: 'தற்போதைய நேரத்திற்கு புதுப்பி (Refresh to Now)',
          onPressed: () {
            final now = DateTime.now();
            final hStr = now.hour.toString().padLeft(2, '0');
            final mStr = now.minute.toString().padLeft(2, '0');
            _dobController.text = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
            _tobController.text = "$hStr:$mStr";
            _calculateModel1();
          },
        ),
      ],
    ).animate().fade(duration: 300.ms);
  }

  Widget _buildInputCard() {
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
                'பிரசன்ன நேரம் & இட விவரங்கள்',
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
              Expanded(child: _buildInputField(_dobController, 'தேதி', 'YYYY-MM-DD')),
              const SizedBox(width: 8),
              Expanded(child: _buildInputField(_tobController, 'நேரம்', 'HH:MM')),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildInputField(_placeController, 'இடம்', 'City')),
              const SizedBox(width: 8),
              Expanded(child: _buildInputField(_latController, 'Lat', '13.0827')),
              const SizedBox(width: 8),
              Expanded(child: _buildInputField(_lonController, 'Lon', '80.2707')),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                'ஆருட ராசி எண் (1-12):',
                style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 12),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Slider(
                  value: _selectedAarudamNumber.toDouble(),
                  min: 1,
                  max: 12,
                  divisions: 11,
                  activeColor: AppColors.primaryGold,
                  inactiveColor: AppColors.backgroundMid,
                  label: '$_selectedAarudamNumber - ${AstrologyCalculator.rasiNamesTa[_selectedAarudamNumber - 1]}',
                  onChanged: (v) {
                    setState(() {
                      _selectedAarudamNumber = v.round();
                      _calculateModel1();
                    });
                  },
                ),
              ),
              Text(
                '$_selectedAarudamNumber (${AstrologyCalculator.rasiNamesTa[_selectedAarudamNumber - 1]})',
                style: GoogleFonts.cinzel(color: AppColors.lightGold, fontWeight: FontWeight.bold, fontSize: 12),
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
                foregroundColor: AppColors.backgroundDeep,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: _calculateModel1,
              icon: const Icon(Icons.calculate_rounded, size: 18),
              label: Text(
                'Model 1 கணிப்பு செய்க (Calculate Model 1)',
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

  /// Section 9 & 10: 3 Core Cards with full DD° MM' SS" precision
  Widget _buildCorePointsSection() {
    final udhayam = _result!.udhayam;
    final aarudam = _result!.aarudam;
    final kavippu = _result!.kavippu;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'முக்கிய புள்ளிகள் (Core Points)',
          style: GoogleFonts.cinzel(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppColors.lightGold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildCoreCard(
                udhayam.nameTa,
                udhayam.rasi,
                udhayam.formattedDMS,
                Colors.blueAccent,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildCoreCard(
                aarudam.nameTa,
                aarudam.rasi,
                aarudam.formattedDMS,
                Colors.amberAccent,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildCoreCard(
                kavippu.nameTa,
                kavippu.rasi,
                kavippu.formattedDMS,
                Colors.redAccent,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Section 10: Required Core Card Widget
  Widget _buildCoreCard(
    String title,
    String rasi,
    String degree,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1.2),
      ),
      child: Column(
        children: [
          Container(
            height: 3,
            width: 24,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: GoogleFonts.cinzel(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            rasi,
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            degree,
            style: GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.lightGold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJamamStatusBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundMid,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.wb_twilight_rounded, color: AppColors.primaryGold, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _result!.jamamNameTa,
                  style: GoogleFonts.outfit(color: AppColors.lightGold, fontWeight: FontWeight.bold, fontSize: 13),
                ),
                Text(
                  'ஜாம அதிபதி கிரகம்: ${_result!.jamamLordTa}',
                  style: GoogleFonts.outfit(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Section 11: Required Planet List / Table Widget
  Widget _buildPlanetList(List<JamakolArudamPlanet> planets) {
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
              const Icon(Icons.public_rounded, color: AppColors.lightGold, size: 18),
              const SizedBox(width: 8),
              Text(
                'கிரக நிலைகள் (Ephemeris Planetary Positions)',
                style: GoogleFonts.cinzel(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.lightGold,
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
              columnSpacing: 16,
              horizontalMargin: 8,
              headingRowColor: WidgetStateProperty.all(AppColors.backgroundMid),
              columns: [
                DataColumn(label: Text('கிரகம்', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.lightGold, fontSize: 11))),
                DataColumn(label: Text('ராசி', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.lightGold, fontSize: 11))),
                DataColumn(label: Text('பாகை (DD°MM\'SS")', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.lightGold, fontSize: 11))),
                DataColumn(label: Text('பாவம் (உதயம் வழி)', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.lightGold, fontSize: 11))),
                DataColumn(label: Text('நட்சத்திரம்-பாதம்', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.lightGold, fontSize: 11))),
                DataColumn(label: Text('இயக்கம்', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.lightGold, fontSize: 11))),
              ],
              rows: planets.map((p) {
                return DataRow(
                  cells: [
                    DataCell(Text(p.nameTa, style: GoogleFonts.outfit(color: AppColors.lightGold, fontWeight: FontWeight.bold, fontSize: 11))),
                    DataCell(Text(p.rasi, style: GoogleFonts.outfit(color: Colors.white, fontSize: 11))),
                    DataCell(Text(p.formattedDMS, style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 11))),
                    DataCell(Text('${p.house}-ஆம் பாவம்', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 11))),
                    DataCell(Text('${p.nakshatra} - ${p.pada}', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 11))),
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

  Widget _buildQuestionSuccessAnalysis() {
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
          Text(
            'காரிய சித்தி ஆய்வு (Question Success Analysis)',
            style: GoogleFonts.cinzel(
              color: AppColors.lightGold,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const Divider(color: AppColors.borderGold, height: 16),
          Text(
            _result!.generalSummaryTa,
            style: GoogleFonts.outfit(color: Colors.white, fontSize: 12.5, height: 1.4),
          ),
          const SizedBox(height: 10),
          Text(
            'சுப ராசிகள் (Favorable): ${_result!.favorableSignsTa.join(", ")}',
            style: GoogleFonts.outfit(color: Colors.greenAccent, fontWeight: FontWeight.w600, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            'தடை ராசிகள் (Obstructions): ${_result!.obstructiveSignsTa.join(", ")}',
            style: GoogleFonts.outfit(color: Colors.redAccent, fontWeight: FontWeight.w600, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionsList() {
    final predictions = _result!.predictions;

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
              Text(
                'ஜாமகோள் Model 1 பலன்கள் (Predictions)',
                style: GoogleFonts.cinzel(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.lightGold,
                ),
              ),
            ],
          ),
          const Divider(color: AppColors.borderGold, height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: predictions.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (ctx, idx) {
              final pred = predictions[idx];
              final badgeColor = pred.isFavorable ? Colors.greenAccent : Colors.amberAccent;

              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.backgroundMid,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          pred.title,
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            fontSize: 12.5,
                            color: AppColors.lightGold,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: badgeColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            pred.isFavorable ? 'சுபம்' : 'கவனம்',
                            style: GoogleFonts.outfit(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: badgeColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      pred.interpretationTa,
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
