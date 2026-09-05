import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../models/horoscope_calculation_result.dart';
import '../../models/user_model.dart';
import '../../services/astrology_calculator.dart';
import '../../services/auth_service.dart';
import '../../widgets/cosmic_background.dart';
import 'bnn_method_2_engine.dart';
import 'bnn_method_2_models.dart';
import 'bnn_method_2_widgets.dart';

/// Screen for பிருகு நந்தி நாடி - Method 2 (BNN Method 2)
class BhriguNandiNadiMethod2Screen extends StatefulWidget {
  const BhriguNandiNadiMethod2Screen({super.key});

  @override
  State<BhriguNandiNadiMethod2Screen> createState() => _BhriguNandiNadiMethod2ScreenState();
}

class _BhriguNandiNadiMethod2ScreenState extends State<BhriguNandiNadiMethod2Screen> {
  late UserModel _user;
  List<BNNMethod2PlanetPosition> _bnnPlanets = [];
  Map<String, BNNMethod2PlanetAnalysis> _analyses = {};
  String _selectedPlanetKey = 'Jupiter'; // Default: Jeeva Karaka Jupiter (குரு)
  String? _errorMessage;

  // Editable birth controllers
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
          id: 'bnn2_usr',
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

    if (lat == 0.0 && lon == 0.0) {
      setState(() {
        _errorMessage = 'பிறந்த இடத்தின் அட்ச/தீர்க்கரேகை தேவை. (Latitude & Longitude Required)';
        _bnnPlanets = [];
        _analyses = {};
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
      // 1. Existing Horoscope Calculation (Untouched)
      final HoroscopeCalculationResult astroData = AstrologyCalculator.calculateHoroscope(
        dateOfBirth: birthDt,
        latitude: lat,
        longitude: lon,
        utcOffsetHours: _user.timezone,
      );

      // 2. BNN Method 2 Adapter
      final planets = BNNMethod2Adapter.fromExistingPlanetsMap(
        planetsMap: astroData.planets,
        lagnaRasiIndex: astroData.lagna.rasiIndex,
      );

      // 3. BNN Method 2 Calculator
      final analyses = BNNMethod2Calculator.analyzeAllPlanets(planets);

      setState(() {
        _bnnPlanets = planets;
        _analyses = analyses;
        if (!_analyses.containsKey(_selectedPlanetKey) && planets.isNotEmpty) {
          _selectedPlanetKey = planets.first.planetKey;
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _bnnPlanets = [];
        _analyses = {};
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

                // Birth Details Input Card
                _buildBirthInputCard(),
                const SizedBox(height: 16),

                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.redAccent),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: GoogleFonts.outfit(color: Colors.white, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  )
                else if (_bnnPlanets.isNotEmpty) ...[
                  // Planet Selector Bar
                  _buildPlanetSelector(),
                  const SizedBox(height: 14),

                  // Selected Planet Analysis Card
                  if (_analyses.containsKey(_selectedPlanetKey))
                    BNNMethod2PlanetCard(analysis: _analyses[_selectedPlanetKey]!),
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
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.lightGold),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'பிருகு நந்தி நாடி - Method 2',
                style: GoogleFonts.cinzel(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.lightGold,
                  letterSpacing: 1.1,
                ),
              ),
              Text(
                'BNN Method 2: திசை தொடர்புகள் & காரக பகுப்பாய்வு',
                style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 11),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBirthInputCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGold.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person_pin_rounded, color: AppColors.lightGold, size: 18),
              const SizedBox(width: 8),
              Text(
                'ஜாதக விவரங்கள் (Birth Input)',
                style: GoogleFonts.cinzel(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.lightGold,
                ),
              ),
            ],
          ),
          const Divider(color: Colors.white12, height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(_dobController, 'பிறந்த தேதி', Icons.calendar_today_rounded),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTextField(_tobController, 'பிறந்த நேரம்', Icons.access_time_rounded),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildTextField(_placeController, 'பிறந்த இடம்', Icons.place_rounded),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildTextField(_latController, 'அட்சரேகை (Lat)', Icons.my_location_rounded),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTextField(_lonController, 'தீர்க்கரேகை (Lon)', Icons.explore_rounded),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: _calculateHoroscope,
              icon: const Icon(Icons.sync_rounded, color: Colors.black, size: 18),
              label: Text(
                'கணக்கீடு செய் (Calculate)',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String label, IconData icon) {
    return TextField(
      controller: ctrl,
      style: GoogleFonts.outfit(color: Colors.white, fontSize: 12),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 11),
        prefixIcon: Icon(icon, color: AppColors.lightGold, size: 16),
        isDense: true,
        filled: true,
        fillColor: AppColors.backgroundMid,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.borderGold.withValues(alpha: 0.3)),
        ),
      ),
    );
  }

  Widget _buildPlanetSelector() {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _bnnPlanets.length,
        itemBuilder: (context, idx) {
          final p = _bnnPlanets[idx];
          final isSelected = p.planetKey == _selectedPlanetKey;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                '${p.tamilName} (${p.house})',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.black : AppColors.lightGold,
                ),
              ),
              selected: isSelected,
              selectedColor: AppColors.primaryGold,
              backgroundColor: AppColors.cardSurface,
              side: BorderSide(
                color: isSelected ? AppColors.primaryGold : AppColors.borderGold.withValues(alpha: 0.4),
              ),
              onSelected: (val) {
                if (val) setState(() => _selectedPlanetKey = p.planetKey);
              },
            ),
          );
        },
      ),
    );
  }
}
