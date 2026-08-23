import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../models/horoscope_calculation_result.dart';
import '../../models/porutham_model.dart';
import '../../services/astrology_calculator.dart';
import '../../services/porutham_calculator.dart';
import '../../widgets/cosmic_background.dart';
import '../../widgets/golden_button.dart';
import '../../widgets/golden_text_field.dart';
import '../../widgets/south_indian_rasi_chart.dart';

class CityLocation {
  final String name;
  final double lat;
  final double lon;
  final double tz;

  const CityLocation(this.name, this.lat, this.lon, this.tz);
}

class MarriagePoruthamScreen extends StatefulWidget {
  const MarriagePoruthamScreen({super.key});

  @override
  State<MarriagePoruthamScreen> createState() => _MarriagePoruthamScreenState();
}

class _MarriagePoruthamScreenState extends State<MarriagePoruthamScreen> {
  // Preset location database for accurate Thirukanitha calculations
  static const List<CityLocation> _presetCities = [
    CityLocation('சென்னை (Chennai)', 13.0827, 80.2707, 5.5),
    CityLocation('மதுரை (Madurai)', 9.9252, 78.1198, 5.5),
    CityLocation('கோயம்புத்தூர் (Coimbatore)', 11.0168, 76.9558, 5.5),
    CityLocation('திருச்சிராப்பள்ளி (Tiruchirappalli)', 10.7905, 78.7047, 5.5),
    CityLocation('சேலம் (Salem)', 11.6643, 78.1460, 5.5),
    CityLocation('திருநெல்வேலி (Tirunelveli)', 8.7139, 77.7567, 5.5),
    CityLocation('ஈரோடு (Erode)', 11.3410, 77.7172, 5.5),
    CityLocation('வேலூர் (Vellore)', 12.9165, 79.1325, 5.5),
    CityLocation('கன்னியாகுமரி (Kanyakumari)', 8.0883, 77.5385, 5.5),
    CityLocation('தஞ்சாவூர் (Thanjavur)', 10.7870, 79.1378, 5.5),
    CityLocation('பெங்களூரு (Bangalore)', 12.9716, 77.5946, 5.5),
    CityLocation('மும்பை (Mumbai)', 19.0760, 72.8777, 5.5),
    CityLocation('டெல்லி (Delhi)', 28.6139, 77.2090, 5.5),
    CityLocation('யாழ்ப்பாணம் (Jaffna)', 9.6615, 80.0255, 5.5),
    CityLocation('சிங்கப்பூர் (Singapore)', 1.3521, 103.8198, 8.0),
    CityLocation('மலேசியா (Kuala Lumpur)', 3.1390, 101.6869, 8.0),
  ];

  // Mode state: 0 = Automatic Birth Details Mode, 1 = Manual Nakshatra Mode
  int _calculationMode = 0;

  // Male Form Controllers & State
  final _maleNameController = TextEditingController(text: 'சுரேஷ்');
  DateTime _maleDob = DateTime(1996, 6, 15);
  TimeOfDay _maleTob = const TimeOfDay(hour: 8, minute: 30);
  CityLocation _maleCity = _presetCities[0];

  // Female Form Controllers & State
  final _femaleNameController = TextEditingController(text: 'பிரியா');
  DateTime _femaleDob = DateTime(1998, 11, 20);
  TimeOfDay _femaleTob = const TimeOfDay(hour: 14, minute: 15);
  CityLocation _femaleCity = _presetCities[1];

  // Manual Mode State (Nakshatra, Pada, Rasi)
  int _maleManualStarIndex = 3; // Rohini
  int _maleManualPada = 1;
  int _maleManualRasiIndex = 1; // Rishabam

  int _femaleManualStarIndex = 16; // Anuradha
  int _femaleManualPada = 2;
  int _femaleManualRasiIndex = 7; // Viruchigam

  // Calculated Output State
  bool _isCalculating = false;
  bool _hasCalculated = false;

  HoroscopeCalculationResult? _maleAstroData;
  HoroscopeCalculationResult? _femaleAstroData;

  PlanetDetail? _maleMoon;
  PlanetDetail? _maleLagna;

  PlanetDetail? _femaleMoon;
  PlanetDetail? _femaleLagna;

  MarriagePoruthamResult? _poruthamResult;

  Future<void> _pickDate({required bool isMale}) async {
    final initialDate = isMale ? _maleDob : _femaleDob;
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
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
      setState(() {
        if (isMale) {
          _maleDob = picked;
        } else {
          _femaleDob = picked;
        }
      });
    }
  }

  Future<void> _pickTime({required bool isMale}) async {
    final initialTime = isMale ? _maleTob : _femaleTob;
    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
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
      setState(() {
        if (isMale) {
          _maleTob = picked;
        } else {
          _femaleTob = picked;
        }
      });
    }
  }

  void _calculateMarriagePorutham() async {
    // Form Validation (Requirement 18)
    final maleName = _maleNameController.text.trim();
    final femaleName = _femaleNameController.text.trim();

    if (_calculationMode == 0) {
      if (maleName.isEmpty) {
        _showErrorSnackBar('ஆண் ஜாதகரின் பெயரை உள்ளிடவும்.');
        return;
      }
      if (femaleName.isEmpty) {
        _showErrorSnackBar('பெண் ஜாதகரின் பெயரை உள்ளிடவும்.');
        return;
      }
    }

    setState(() {
      _isCalculating = true;
    });

    await Future.delayed(const Duration(milliseconds: 300)); // Smooth UX transition

    try {
      if (_calculationMode == 0) {
        // Mode A: Automatic Calculation via existing AstrologyCalculator engine
        final maleBirthDt = DateTime(
          _maleDob.year,
          _maleDob.month,
          _maleDob.day,
          _maleTob.hour,
          _maleTob.minute,
        );
        final maleData = AstrologyCalculator.calculateHoroscope(
          dateOfBirth: maleBirthDt,
          latitude: _maleCity.lat,
          longitude: _maleCity.lon,
          utcOffsetHours: _maleCity.tz,
        );

        final femaleBirthDt = DateTime(
          _femaleDob.year,
          _femaleDob.month,
          _femaleDob.day,
          _femaleTob.hour,
          _femaleTob.minute,
        );
        final femaleData = AstrologyCalculator.calculateHoroscope(
          dateOfBirth: femaleBirthDt,
          latitude: _femaleCity.lat,
          longitude: _femaleCity.lon,
          utcOffsetHours: _femaleCity.tz,
        );

        final mMoon = maleData['moon'] as PlanetDetail;
        final mLagna = maleData['lagna'] as PlanetDetail;

        final fMoon = femaleData['moon'] as PlanetDetail;
        final fLagna = femaleData['lagna'] as PlanetDetail;

        // Porutham Calculation
        final result = PoruthamCalculator.calculatePorutham(
          maleStarIndex: mMoon.nakshatraIndex,
          malePada: mMoon.pada,
          maleRasiIndex: mMoon.rasiIndex,
          femaleStarIndex: fMoon.nakshatraIndex,
          femalePada: fMoon.pada,
          femaleRasiIndex: fMoon.rasiIndex,
        );

        setState(() {
          _maleAstroData = maleData;
          _femaleAstroData = femaleData;
          _maleMoon = mMoon;
          _maleLagna = mLagna;
          _femaleMoon = fMoon;
          _femaleLagna = fLagna;
          _poruthamResult = result;
          _hasCalculated = true;
          _isCalculating = false;
        });
      } else {
        // Mode B: Manual Nakshatra Mode
        final result = PoruthamCalculator.calculatePorutham(
          maleStarIndex: _maleManualStarIndex,
          malePada: _maleManualPada,
          maleRasiIndex: _maleManualRasiIndex,
          femaleStarIndex: _femaleManualStarIndex,
          femalePada: _femaleManualPada,
          femaleRasiIndex: _femaleManualRasiIndex,
        );

        setState(() {
          _maleAstroData = null;
          _femaleAstroData = null;
          _maleMoon = null;
          _femaleMoon = null;
          _poruthamResult = result;
          _hasCalculated = true;
          _isCalculating = false;
        });
      }
    } catch (e) {
      setState(() {
        _isCalculating = false;
      });
      _showErrorSnackBar('கணிப்பதில் பிழை ஏற்பட்டது: ${e.toString()}');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.red.shade900,
        behavior: SnackBarBehavior.floating,
      ),
    );
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
                // Top Navigation Bar
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.lightGold),
                    ),
                    Expanded(
                      child: Text(
                        'திருமண ஜாதகப் பொருத்தம்',
                        style: GoogleFonts.cinzel(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.lightGold,
                          letterSpacing: 1.2,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(Icons.favorite_rounded, color: Colors.pinkAccent, size: 24),
                  ],
                ).animate().fade(duration: 400.ms),

                Text(
                  'ஆண் மற்றும் பெண் ஜாதகங்களின் திருக்கணிதப் பொருத்த கணிப்பு',
                  style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary),
                ).animate().fade(delay: 100.ms),

                const SizedBox(height: 16),

                // Mode Selector Toggle (Requirement 11)
                _buildModeSelector(),

                const SizedBox(height: 16),

                // Input Forms Section
                if (_calculationMode == 0) ...[
                  _buildAutomaticInputForms(),
                ] else ...[
                  _buildManualInputForms(),
                ],

                const SizedBox(height: 20),

                // Action Button "பொருத்தம் பார்க்க"
                GoldenButton(
                  text: _isCalculating ? 'கணிக்கப்படுகிறது...' : 'பொருத்தம் பார்க்க',
                  icon: Icons.auto_awesome_rounded,
                  onPressed: _isCalculating ? () {} : _calculateMarriagePorutham,
                ).animate().scale(delay: 200.ms),

                const SizedBox(height: 24),

                // Calculation Results Section
                if (_hasCalculated && _poruthamResult != null) ...[
                  const Divider(color: AppColors.borderGold, thickness: 1),
                  const SizedBox(height: 16),

                  // Section Header: Basic Horoscope Summaries (Requirement 5)
                  _buildResultsSectionHeader('ஜாதக சுருக்கம் & விவரங்கள்'),
                  const SizedBox(height: 12),

                  _buildBasicSummaryCards(),

                  const SizedBox(height: 24),

                  // Section Header: Rasi Charts (Requirement 6 & 7)
                  if (_maleAstroData != null && _femaleAstroData != null) ...[
                    _buildResultsSectionHeader('ஜாதகக் கட்டங்கள் (ராசி)'),
                    const SizedBox(height: 12),
                    _buildDualRasiCharts(),
                    const SizedBox(height: 24),
                  ],

                  // Section Header: Porutham Results (Requirement 8 & 9)
                  _buildResultsSectionHeader('திருமணப் பொருத்தம் (11 பொருத்தங்கள்)'),
                  const SizedBox(height: 12),
                  _buildPoruthamResultsTable(),

                  const SizedBox(height: 24),

                  // Section Header: Overall Conclusion (Requirement 10)
                  _buildResultsSectionHeader('மொத்த பொருத்தம்'),
                  const SizedBox(height: 12),
                  _buildOverallSummaryCard(),

                  const SizedBox(height: 32),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModeSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.backgroundMid,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderGold.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _calculationMode = 0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _calculationMode == 0 ? AppColors.primaryGold : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'பிறந்த விவரங்களிலிருந்து',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _calculationMode == 0 ? AppColors.textDark : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _calculationMode = 1),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _calculationMode == 1 ? AppColors.primaryGold : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'நட்சத்திரம் கைமுறையாக',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _calculationMode == 1 ? AppColors.textDark : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAutomaticInputForms() {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 650) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildMaleForm()),
              const SizedBox(width: 16),
              Expanded(child: _buildFemaleForm()),
            ],
          );
        } else {
          return Column(
            children: [
              _buildMaleForm(),
              const SizedBox(height: 16),
              _buildFemaleForm(),
            ],
          );
        }
      },
    );
  }

  Widget _buildMaleForm() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGold.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.male_rounded, color: Colors.blueAccent, size: 22),
              const SizedBox(width: 6),
              Text(
                'ஆண் ஜாதகர்',
                style: GoogleFonts.cinzel(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.lightGold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GoldenTextField(
            label: 'பெயர்',
            hint: 'ஆண் பெயர்',
            prefixIcon: Icons.person_outline_rounded,
            controller: _maleNameController,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildPickerBox(
                  label: 'பிறந்த தேதி',
                  icon: Icons.calendar_today_rounded,
                  value: DateFormat('dd-MM-yyyy').format(_maleDob),
                  onTap: () => _pickDate(isMale: true),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildPickerBox(
                  label: 'பிறந்த நேரம்',
                  icon: Icons.access_time_rounded,
                  value: _maleTob.format(context),
                  onTap: () => _pickTime(isMale: true),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'பிறந்த ஊர் / இடம்',
            style: GoogleFonts.outfit(color: AppColors.lightGold, fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          _buildCityDropdown(
            selectedCity: _maleCity,
            onChanged: (val) {
              if (val != null) setState(() => _maleCity = val);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFemaleForm() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGold.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.female_rounded, color: Colors.pinkAccent, size: 22),
              const SizedBox(width: 6),
              Text(
                'பெண் ஜாதகர்',
                style: GoogleFonts.cinzel(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.lightGold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GoldenTextField(
            label: 'பெயர்',
            hint: 'பெண் பெயர்',
            prefixIcon: Icons.person_outline_rounded,
            controller: _femaleNameController,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildPickerBox(
                  label: 'பிறந்த தேதி',
                  icon: Icons.calendar_today_rounded,
                  value: DateFormat('dd-MM-yyyy').format(_femaleDob),
                  onTap: () => _pickDate(isMale: false),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildPickerBox(
                  label: 'பிறந்த நேரம்',
                  icon: Icons.access_time_rounded,
                  value: _femaleTob.format(context),
                  onTap: () => _pickTime(isMale: false),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'பிறந்த ஊர் / இடம்',
            style: GoogleFonts.outfit(color: AppColors.lightGold, fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          _buildCityDropdown(
            selectedCity: _femaleCity,
            onChanged: (val) {
              if (val != null) setState(() => _femaleCity = val);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildManualInputForms() {
    return Column(
      children: [
        // Male Manual Card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderGold.withOpacity(0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ஆண் நட்சத்திர விவரங்கள்', style: GoogleFonts.cinzel(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.lightGold)),
              const SizedBox(height: 10),
              _buildStarDropdown(
                label: 'நட்சத்திரம்',
                selectedIndex: _maleManualStarIndex,
                onChanged: (val) {
                  if (val != null) setState(() => _maleManualStarIndex = val);
                },
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildPadaDropdown(
                      label: 'பாதம்',
                      selectedPada: _maleManualPada,
                      onChanged: (val) {
                        if (val != null) setState(() => _maleManualPada = val);
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildRasiDropdown(
                      label: 'ராசி',
                      selectedIndex: _maleManualRasiIndex,
                      onChanged: (val) {
                        if (val != null) setState(() => _maleManualRasiIndex = val);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Female Manual Card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderGold.withOpacity(0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('பெண் நட்சத்திர விவரங்கள்', style: GoogleFonts.cinzel(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.lightGold)),
              const SizedBox(height: 10),
              _buildStarDropdown(
                label: 'நட்சத்திரம்',
                selectedIndex: _femaleManualStarIndex,
                onChanged: (val) {
                  if (val != null) setState(() => _femaleManualStarIndex = val);
                },
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildPadaDropdown(
                      label: 'பாதம்',
                      selectedPada: _femaleManualPada,
                      onChanged: (val) {
                        if (val != null) setState(() => _femaleManualPada = val);
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildRasiDropdown(
                      label: 'ராசி',
                      selectedIndex: _femaleManualRasiIndex,
                      onChanged: (val) {
                        if (val != null) setState(() => _femaleManualRasiIndex = val);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPickerBox({
    required String label,
    required IconData icon,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.backgroundMid,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.borderGold.withOpacity(0.4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: GoogleFonts.outfit(fontSize: 10, color: AppColors.textSecondary)),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(icon, size: 14, color: AppColors.lightGold),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    value,
                    style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCityDropdown({
    required CityLocation selectedCity,
    required ValueChanged<CityLocation?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.backgroundMid,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderGold.withOpacity(0.4)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<CityLocation>(
          value: selectedCity,
          isExpanded: true,
          dropdownColor: AppColors.backgroundMid,
          style: GoogleFonts.outfit(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
          items: _presetCities.map((city) {
            return DropdownMenuItem<CityLocation>(
              value: city,
              child: Text(city.name),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildStarDropdown({
    required String label,
    required int selectedIndex,
    required ValueChanged<int?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.backgroundMid,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderGold.withOpacity(0.4)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: selectedIndex,
          isExpanded: true,
          dropdownColor: AppColors.backgroundMid,
          style: GoogleFonts.outfit(color: AppColors.lightGold, fontSize: 12, fontWeight: FontWeight.bold),
          items: List.generate(27, (i) {
            return DropdownMenuItem<int>(
              value: i,
              child: Text("${i + 1}. ${AstrologyCalculator.nakshatrasTa[i]}"),
            );
          }),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildPadaDropdown({
    required String label,
    required int selectedPada,
    required ValueChanged<int?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.backgroundMid,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderGold.withOpacity(0.4)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: selectedPada,
          isExpanded: true,
          dropdownColor: AppColors.backgroundMid,
          style: GoogleFonts.outfit(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
          items: [1, 2, 3, 4].map((p) {
            return DropdownMenuItem<int>(
              value: p,
              child: Text("$p பாதம்"),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildRasiDropdown({
    required String label,
    required int selectedIndex,
    required ValueChanged<int?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.backgroundMid,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderGold.withOpacity(0.4)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: selectedIndex,
          isExpanded: true,
          dropdownColor: AppColors.backgroundMid,
          style: GoogleFonts.outfit(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
          items: List.generate(12, (i) {
            return DropdownMenuItem<int>(
              value: i,
              child: Text(AstrologyCalculator.rasiNamesTa[i]),
            );
          }),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildResultsSectionHeader(String title) {
    return Row(
      children: [
        const Icon(Icons.stars_rounded, color: AppColors.lightGold, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.cinzel(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.lightGold,
          ),
        ),
      ],
    );
  }

  Widget _buildBasicSummaryCards() {
    final maleName = _maleNameController.text.trim().isNotEmpty ? _maleNameController.text.trim() : 'ஆண் ஜாதகர்';
    final femaleName = _femaleNameController.text.trim().isNotEmpty ? _femaleNameController.text.trim() : 'பெண் ஜாதகர்';

    final maleRasi = _maleMoon != null ? _maleMoon!.rasiNameTa : AstrologyCalculator.rasiNamesTa[_maleManualRasiIndex];
    final maleStar = _maleMoon != null ? _maleMoon!.nakshatraNameTa : AstrologyCalculator.nakshatrasTa[_maleManualStarIndex];
    final malePada = _maleMoon != null ? _maleMoon!.pada : _maleManualPada;
    final maleLagna = _maleLagna != null ? _maleLagna!.rasiNameTa : 'அறியப்படவில்லை';

    final femaleRasi = _femaleMoon != null ? _femaleMoon!.rasiNameTa : AstrologyCalculator.rasiNamesTa[_femaleManualRasiIndex];
    final femaleStar = _femaleMoon != null ? _femaleMoon!.nakshatraNameTa : AstrologyCalculator.nakshatrasTa[_femaleManualStarIndex];
    final femalePada = _femaleMoon != null ? _femaleMoon!.pada : _femaleManualPada;
    final femaleLagna = _femaleLagna != null ? _femaleLagna!.rasiNameTa : 'அறியப்படவில்லை';

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 650) {
          return Row(
            children: [
              Expanded(
                child: _buildSinglePersonSummary(
                  title: 'ஆண் ஜாதகர்',
                  name: maleName,
                  dob: DateFormat('dd/MM/yyyy').format(_maleDob),
                  tob: _maleTob.format(context),
                  pob: _maleCity.name.split(' ')[0],
                  lagna: maleLagna,
                  rasi: maleRasi,
                  star: maleStar,
                  pada: malePada,
                  iconColor: Colors.blueAccent,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildSinglePersonSummary(
                  title: 'பெண் ஜாதகர்',
                  name: femaleName,
                  dob: DateFormat('dd/MM/yyyy').format(_femaleDob),
                  tob: _femaleTob.format(context),
                  pob: _femaleCity.name.split(' ')[0],
                  lagna: femaleLagna,
                  rasi: femaleRasi,
                  star: femaleStar,
                  pada: femalePada,
                  iconColor: Colors.pinkAccent,
                ),
              ),
            ],
          );
        } else {
          return Column(
            children: [
              _buildSinglePersonSummary(
                title: 'ஆண் ஜாதகர்',
                name: maleName,
                dob: DateFormat('dd/MM/yyyy').format(_maleDob),
                tob: _maleTob.format(context),
                pob: _maleCity.name.split(' ')[0],
                lagna: maleLagna,
                rasi: maleRasi,
                star: maleStar,
                pada: malePada,
                iconColor: Colors.blueAccent,
              ),
              const SizedBox(height: 12),
              _buildSinglePersonSummary(
                title: 'பெண் ஜாதகர்',
                name: femaleName,
                dob: DateFormat('dd/MM/yyyy').format(_femaleDob),
                tob: _femaleTob.format(context),
                pob: _femaleCity.name.split(' ')[0],
                lagna: femaleLagna,
                rasi: femaleRasi,
                star: femaleStar,
                pada: femalePada,
                iconColor: Colors.pinkAccent,
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildSinglePersonSummary({
    required String title,
    required String name,
    required String dob,
    required String tob,
    required String pob,
    required String lagna,
    required String rasi,
    required String star,
    required int pada,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderGold.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person_pin_rounded, color: iconColor, size: 20),
              const SizedBox(width: 6),
              Text(
                title,
                style: GoogleFonts.cinzel(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.lightGold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('பெயர்: $name', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
          if (_calculationMode == 0)
            Text('பிறந்த தேதி/நேரம்: $dob • $tob ($pob)', style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.backgroundMid,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_calculationMode == 0)
                  Text('லக்னம்: $lagna', style: GoogleFonts.outfit(fontSize: 11, color: AppColors.lightGold, fontWeight: FontWeight.w600)),
                Text('ராசி: $rasi', style: GoogleFonts.outfit(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600)),
                Text('நட்சத்திரம்: $star ($pada-ம் பாதம்)', style: GoogleFonts.outfit(fontSize: 11, color: AppColors.lightGold, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDualRasiCharts() {
    final Map<String, PlanetDetail> malePlanets = _maleAstroData!.planets;
    final Map<String, PlanetDetail> femalePlanets = _femaleAstroData!.planets;

    final maleName = _maleNameController.text.trim().isNotEmpty ? _maleNameController.text.trim() : 'ஆண்';
    final femaleName = _femaleNameController.text.trim().isNotEmpty ? _femaleNameController.text.trim() : 'பெண்';

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 650) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SouthIndianRasiChart(
                  title: '$maleName - ராசி மண்டலம்',
                  planets: malePlanets,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SouthIndianRasiChart(
                  title: '$femaleName - ராசி மண்டலம்',
                  planets: femalePlanets,
                ),
              ),
            ],
          );
        } else {
          return Column(
            children: [
              SouthIndianRasiChart(
                title: '$maleName - ராசி மண்டலம்',
                planets: malePlanets,
              ),
              const SizedBox(height: 16),
              SouthIndianRasiChart(
                title: '$femaleName - ராசி மண்டலம்',
                planets: femalePlanets,
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildPoruthamResultsTable() {
    final result = _poruthamResult!;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGold.withOpacity(0.5)),
      ),
      child: Column(
        children: result.items.asMap().entries.map((entry) {
          final idx = entry.key;
          final item = entry.value;
          final isLast = idx == result.items.length - 1;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: item.isMatched ? Colors.green.shade900.withOpacity(0.4) : Colors.red.shade900.withOpacity(0.4),
                        border: Border.all(color: item.isMatched ? Colors.greenAccent : Colors.redAccent, width: 1),
                      ),
                      child: Icon(
                        item.isMatched ? Icons.check : Icons.close,
                        size: 14,
                        color: item.isMatched ? Colors.greenAccent : Colors.redAccent,
                      ),
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
                                '${idx + 1}. ${item.nameTa}',
                                style: GoogleFonts.cinzel(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.lightGold),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: item.isMatched ? Colors.green.withOpacity(0.15) : Colors.red.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: item.isMatched ? Colors.greenAccent : Colors.redAccent, width: 0.8),
                                ),
                                child: Text(
                                  item.statusTextTa,
                                  style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: item.isMatched ? Colors.greenAccent : Colors.redAccent),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.descriptionTa,
                            style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLast) const Divider(color: Colors.white12, height: 1),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildOverallSummaryCard() {
    final result = _poruthamResult!;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.backgroundMid,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primaryGold, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGold.withOpacity(0.2),
            blurRadius: 16,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'மொத்தப் பொருத்தம்',
                    style: GoogleFonts.cinzel(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.lightGold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '11 முக்கிய பொருத்தங்களின் முடிவு',
                    style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryGold,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  result.scoreText,
                  style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: AppColors.borderGold, thickness: 0.8),
          const SizedBox(height: 10),
          Text(
            result.overallConclusionTa,
            textAlign: TextAlign.center,
            style: GoogleFonts.cinzel(fontSize: 16, fontWeight: FontWeight.bold, color: result.isRajjuMatched ? Colors.greenAccent : Colors.redAccent),
          ),
          const SizedBox(height: 6),
          Text(
            result.summaryDetailsTa,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
