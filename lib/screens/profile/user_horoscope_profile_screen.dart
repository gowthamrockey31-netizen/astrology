import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../models/user_model.dart';
import '../../services/astrology_calculator.dart';
import '../../services/auth_service.dart';
import '../../services/geocoding_service.dart';
import '../../widgets/cosmic_background.dart';
import '../../widgets/golden_button.dart';
import '../../widgets/golden_text_field.dart';

class UserHoroscopeProfileScreen extends StatefulWidget {
  final VoidCallback onSaved;

  const UserHoroscopeProfileScreen({
    super.key,
    required this.onSaved,
  });

  @override
  State<UserHoroscopeProfileScreen> createState() => _UserHoroscopeProfileScreenState();
}

class _UserHoroscopeProfileScreenState extends State<UserHoroscopeProfileScreen> {
  final _nameController = TextEditingController(text: AuthService.currentUser?.name ?? 'Divine Seeker');
  final _placeController = TextEditingController(text: AuthService.currentUser?.placeOfBirth ?? 'Chennai');
  final _cityController = TextEditingController(text: AuthService.currentUser?.city ?? 'Chennai');
  final _stateController = TextEditingController(text: AuthService.currentUser?.state ?? 'Tamil Nadu');
  final _countryController = TextEditingController(text: AuthService.currentUser?.country ?? 'India');

  final _latController = TextEditingController(text: '${AuthService.currentUser?.latitude ?? 13.0827}');
  final _lonController = TextEditingController(text: '${AuthService.currentUser?.longitude ?? 80.2707}');
  final _tzController = TextEditingController(text: '${AuthService.currentUser?.timezone ?? 5.5}');

  List<GeocodingLocation> _placeSuggestions = [];
  bool _showSuggestions = false;

  List<GeocodingLocation> _citySuggestions = [];
  bool _showCitySuggestions = false;

  List<IndianState> _stateSuggestions = [];
  bool _showStateSuggestions = false;

  String _gender = 'Male';
  DateTime _dob = DateTime(1996, 6, 15);
  TimeOfDay _tob = const TimeOfDay(hour: 8, minute: 30);

  String _selectedZodiac = 'Gemini (Mithuna)';
  String _selectedNakshatra = 'Rohini';
  String _selectedLagna = 'Simha (Leo)';

  @override
  void initState() {
    super.initState();
    final user = AuthService.currentUser;
    if (user != null) {
      _gender = user.gender.isNotEmpty ? user.gender : 'Male';
      if (user.zodiac.isNotEmpty) _selectedZodiac = user.zodiac;
      if (user.nakshatra.isNotEmpty) _selectedNakshatra = user.nakshatra;
      if (user.lagna.isNotEmpty) _selectedLagna = user.lagna;
      final parsedDob = DateTime.tryParse(user.dob);
      if (parsedDob != null) _dob = parsedDob;

      if (user.name.isNotEmpty) _nameController.text = user.name;
      if (user.placeOfBirth.isNotEmpty) _placeController.text = user.placeOfBirth;
      if (user.city.isNotEmpty) _cityController.text = user.city;
      if (user.state.isNotEmpty) _stateController.text = user.state;
      if (user.country.isNotEmpty) _countryController.text = user.country;

      // Auto-resolve city/state from place of birth if city is empty or default placeholder
      if (_cityController.text.isEmpty || _cityController.text.toLowerCase() == 'city') {
        final loc = GeocodingService.resolvePlace(_placeController.text);
        if (loc != null) {
          _cityController.text = loc.cityName;
          _stateController.text = loc.state;
          _countryController.text = loc.country;
        }
      }

      _latController.text = '${user.latitude}';
      _lonController.text = '${user.longitude}';
      _tzController.text = '${user.timezone}';
    }
    _recalculateAstrology();
  }

  void _applyLocation(GeocodingLocation loc) {
    setState(() {
      _placeController.text = loc.displayName;
      _cityController.text = loc.cityName;
      _stateController.text = loc.state;
      _countryController.text = loc.country;
      _latController.text = loc.latitude.toString();
      _lonController.text = loc.longitude.toString();
      _tzController.text = loc.timezone.toString();
      _showSuggestions = false;
      _showCitySuggestions = false;
      _showStateSuggestions = false;
    });
    _recalculateAstrology();
  }

  void _applyState(IndianState state) {
    setState(() {
      _stateController.text = state.name;
      _countryController.text = 'India';
      _showStateSuggestions = false;
      _showSuggestions = false;
      _showCitySuggestions = false;
      if (_cityController.text.isEmpty || _cityController.text.toLowerCase() == 'city') {
        _latController.text = state.latitude.toString();
        _lonController.text = state.longitude.toString();
        _tzController.text = '5.5';
      }
    });
    _recalculateAstrology();
  }

  void _recalculateAstrology() {
    final lat = double.tryParse(_latController.text.trim()) ?? 13.0827;
    final lon = double.tryParse(_lonController.text.trim()) ?? 80.2707;
    final tz = double.tryParse(_tzController.text.trim()) ?? 5.5;

    final birthDt = DateTime(_dob.year, _dob.month, _dob.day, _tob.hour, _tob.minute);
    final data = AstrologyCalculator.calculateHoroscope(
      dateOfBirth: birthDt,
      latitude: lat,
      longitude: lon,
      utcOffsetHours: tz,
    );

    final moon = data['moon'] as PlanetDetail;
    final lagna = data['lagna'] as PlanetDetail;

    setState(() {
      _selectedZodiac = "${moon.rasiNameEn} (${moon.rasiNameTa})";
      _selectedNakshatra = "${moon.nakshatraNameTa} (${moon.nakshatraNameEn})";
      _selectedLagna = "${lagna.rasiNameEn} (${lagna.rasiNameTa})";
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob,
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
      _dob = picked;
      _recalculateAstrology();
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _tob,
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
      _tob = picked;
      _recalculateAstrology();
    }
  }

  void _saveProfile() async {
    final currentUser = AuthService.currentUser;
    final tobString = DateFormat('hh:mm a').format(DateTime(2000, 1, 1, _tob.hour, _tob.minute));
    final dobString = DateFormat('yyyy-MM-dd').format(_dob);

    final lat = double.tryParse(_latController.text.trim()) ?? 13.0827;
    final lon = double.tryParse(_lonController.text.trim()) ?? 80.2707;
    final tz = double.tryParse(_tzController.text.trim()) ?? 5.5;

    final updated = UserModel(
      id: currentUser?.id ?? 'usr_1',
      name: _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : 'Divine Seeker',
      mobile: currentUser?.mobile ?? '+919876543210',
      gender: _gender,
      dob: dobString,
      timeOfBirth: tobString,
      placeOfBirth: _placeController.text.trim(),
      city: _cityController.text.trim(),
      state: _stateController.text.trim(),
      country: _countryController.text.trim(),
      zodiac: _selectedZodiac,
      nakshatra: _selectedNakshatra,
      lagna: _selectedLagna,
      walletBalance: currentUser?.walletBalance ?? 750.0,
      role: 'User',
      profilePhoto: currentUser?.profilePhoto ?? '',
      latitude: lat,
      longitude: lon,
      timezone: tz,
    );

    await AuthService.updateUserProfile(updated);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Horoscope Profile saved to MongoDB!', style: GoogleFonts.outfit(color: AppColors.lightGold)),
          backgroundColor: AppColors.backgroundMid,
        ),
      );
    }
    widget.onSaved();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CosmicBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.brightness_5_rounded, color: AppColors.lightGold, size: 28),
                    const SizedBox(width: 12),
                    Text(
                      'Horoscope Profile',
                      style: GoogleFonts.cinzel(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Enter birth coordinates for accurate Kundli, Zodiac, & Dasha calculations.',
                  style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textSecondary),
                ),

                const SizedBox(height: 20),

                // Form Fields
                GoldenTextField(
                  label: 'Full Name',
                  hint: 'Enter your full name',
                  prefixIcon: Icons.person_outline_rounded,
                  controller: _nameController,
                ),
                const SizedBox(height: 14),

                // Gender Selector
                Text('Gender', style: GoogleFonts.outfit(color: AppColors.lightGold, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Row(
                  children: ['Male', 'Female', 'Other'].map((g) {
                    final selected = _gender == g;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _gender = g),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: selected ? AppColors.primaryGold.withValues(alpha: 0.2) : AppColors.cardSurface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: selected ? AppColors.lightGold : Colors.white12),
                          ),
                          child: Center(
                            child: Text(
                              g,
                              style: GoogleFonts.outfit(
                                color: selected ? AppColors.lightGold : AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 16),

                // Date & Time Pickers
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: _pickDate,
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.cardSurface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.borderGold.withValues(alpha: 0.5)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Date of Birth', style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary)),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.lightGold),
                                  const SizedBox(width: 8),
                                  Text(
                                    DateFormat('dd / MM / yyyy').format(_dob),
                                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: _pickTime,
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.cardSurface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.borderGold.withValues(alpha: 0.5)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Time of Birth', style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary)),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.access_time_rounded, size: 16, color: AppColors.lightGold),
                                  const SizedBox(width: 8),
                                  Text(
                                    _tob.format(context),
                                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Place of Birth (Searches all Indian cities, districts & states)
                GoldenTextField(
                  label: 'Place of Birth (பிறந்த ஊர் / நகரம்)',
                  hint: 'Type City / Town e.g. Chennai, Mumbai, Coimbatore, Pune',
                  prefixIcon: Icons.place_rounded,
                  controller: _placeController,
                  onTap: () async {
                    final results = await GeocodingService.searchPlaces(_placeController.text);
                    setState(() {
                      _placeSuggestions = results;
                      _showSuggestions = results.isNotEmpty;
                      _showCitySuggestions = false;
                      _showStateSuggestions = false;
                    });
                  },
                  onChanged: (val) async {
                    final results = await GeocodingService.searchPlaces(val);
                    setState(() {
                      _placeSuggestions = results;
                      _showSuggestions = results.isNotEmpty;
                      _showCitySuggestions = false;
                      _showStateSuggestions = false;
                    });
                  },
                  suffixIcon: _placeController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, color: AppColors.textSecondary, size: 18),
                          onPressed: () {
                            _placeController.clear();
                            final defaultResults = GeocodingService.searchOffline('');
                            setState(() {
                              _placeSuggestions = defaultResults;
                              _showSuggestions = true;
                              _showCitySuggestions = false;
                              _showStateSuggestions = false;
                            });
                          },
                        )
                      : IconButton(
                          icon: const Icon(Icons.arrow_drop_down_rounded, color: AppColors.primaryGold, size: 22),
                          onPressed: () {
                            final defaultResults = GeocodingService.searchOffline('');
                            setState(() {
                              _placeSuggestions = defaultResults;
                              _showSuggestions = !_showSuggestions;
                              _showCitySuggestions = false;
                              _showStateSuggestions = false;
                            });
                          },
                        ),
                ),

                // Matching Location Suggestions Dropdown (All Indian Cities & Places)
                if (_showSuggestions && _placeSuggestions.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 6, bottom: 10),
                    decoration: BoxDecoration(
                      color: AppColors.cardSurface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.7), width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    constraints: const BoxConstraints(maxHeight: 220),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGold.withValues(alpha: 0.12),
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.location_searching_rounded, size: 14, color: AppColors.lightGold),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Matching Indian Locations (${_placeSuggestions.length})',
                                    style: GoogleFonts.outfit(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.lightGold,
                                    ),
                                  ),
                                ],
                              ),
                              InkWell(
                                onTap: () => setState(() => _showSuggestions = false),
                                child: const Icon(Icons.close_rounded, size: 16, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        Flexible(
                          child: ListView.separated(
                            shrinkWrap: true,
                            itemCount: _placeSuggestions.length,
                            separatorBuilder: (context, index) => const Divider(color: Colors.white12, height: 1),
                            itemBuilder: (context, idx) {
                              final loc = _placeSuggestions[idx];
                              return InkWell(
                                onTap: () => _applyLocation(loc),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryGold.withValues(alpha: 0.15),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.location_on_rounded, color: AppColors.lightGold, size: 16),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              loc.cityName,
                                              style: GoogleFonts.outfit(
                                                color: Colors.white,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              loc.displayName,
                                              style: GoogleFonts.outfit(
                                                color: AppColors.textSecondary,
                                                fontSize: 11,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: Colors.black38,
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(color: Colors.white12),
                                        ),
                                        child: Text(
                                          '${loc.latitude.toStringAsFixed(2)}°, ${loc.longitude.toStringAsFixed(2)}°',
                                          style: GoogleFonts.outfit(
                                            color: AppColors.lightGold,
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 14),

                Row(
                  children: [
                    // City Field with all Indian cities recommendation
                    Expanded(
                      child: GoldenTextField(
                        label: 'City (நகரம்)',
                        hint: 'Search all India cities e.g. Mumbai, Chennai',
                        prefixIcon: Icons.location_city_rounded,
                        controller: _cityController,
                        onTap: () {
                          final results = GeocodingService.searchCities(_cityController.text, stateFilter: _stateController.text);
                          setState(() {
                            _citySuggestions = results;
                            _showCitySuggestions = results.isNotEmpty;
                            _showSuggestions = false;
                            _showStateSuggestions = false;
                          });
                        },
                        onChanged: (val) async {
                          final results = GeocodingService.searchCities(val, stateFilter: _stateController.text);
                          setState(() {
                            _citySuggestions = results;
                            _showCitySuggestions = results.isNotEmpty;
                            _showSuggestions = false;
                            _showStateSuggestions = false;
                          });
                          final loc = GeocodingService.resolvePlace(val);
                          if (loc != null) {
                            setState(() {
                              _stateController.text = loc.state;
                              _countryController.text = loc.country;
                              _latController.text = loc.latitude.toString();
                              _lonController.text = loc.longitude.toString();
                              _tzController.text = loc.timezone.toString();
                            });
                            _recalculateAstrology();
                          }
                        },
                        suffixIcon: _cityController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, color: AppColors.textSecondary, size: 18),
                                onPressed: () {
                                  _cityController.clear();
                                  final results = GeocodingService.searchCities('', stateFilter: _stateController.text);
                                  setState(() {
                                    _citySuggestions = results;
                                    _showCitySuggestions = true;
                                    _showSuggestions = false;
                                    _showStateSuggestions = false;
                                  });
                                },
                              )
                            : IconButton(
                                icon: const Icon(Icons.arrow_drop_down_rounded, color: AppColors.primaryGold, size: 22),
                                onPressed: () {
                                  final results = GeocodingService.searchCities(_cityController.text, stateFilter: _stateController.text);
                                  setState(() {
                                    _citySuggestions = results;
                                    _showCitySuggestions = !_showCitySuggestions;
                                    _showSuggestions = false;
                                    _showStateSuggestions = false;
                                  });
                                },
                              ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // State Field with 28 States & UTs recommendation
                    Expanded(
                      child: GoldenTextField(
                        label: 'State (மாநிலம்)',
                        hint: 'Search 28+ States e.g. Tamil Nadu, Maharashtra',
                        prefixIcon: Icons.map_rounded,
                        controller: _stateController,
                        onTap: () {
                          final results = GeocodingService.searchStates(_stateController.text);
                          setState(() {
                            _stateSuggestions = results;
                            _showStateSuggestions = results.isNotEmpty;
                            _showSuggestions = false;
                            _showCitySuggestions = false;
                          });
                        },
                        onChanged: (val) {
                          final results = GeocodingService.searchStates(val);
                          setState(() {
                            _stateSuggestions = results;
                            _showStateSuggestions = results.isNotEmpty;
                            _showSuggestions = false;
                            _showCitySuggestions = false;
                          });
                          final loc = GeocodingService.resolvePlace('$_cityController.text $val');
                          if (loc != null) {
                            setState(() {
                              _latController.text = loc.latitude.toString();
                              _lonController.text = loc.longitude.toString();
                              _tzController.text = loc.timezone.toString();
                            });
                            _recalculateAstrology();
                          }
                        },
                        suffixIcon: _stateController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, color: AppColors.textSecondary, size: 18),
                                onPressed: () {
                                  _stateController.clear();
                                  final allStates = GeocodingService.searchStates('');
                                  setState(() {
                                    _stateSuggestions = allStates;
                                    _showStateSuggestions = true;
                                    _showSuggestions = false;
                                    _showCitySuggestions = false;
                                  });
                                },
                              )
                            : IconButton(
                                icon: const Icon(Icons.arrow_drop_down_rounded, color: AppColors.primaryGold, size: 22),
                                onPressed: () {
                                  final allStates = GeocodingService.searchStates('');
                                  setState(() {
                                    _stateSuggestions = allStates;
                                    _showStateSuggestions = !_showStateSuggestions;
                                    _showSuggestions = false;
                                    _showCitySuggestions = false;
                                  });
                                },
                              ),
                      ),
                    ),
                  ],
                ),

                // City Recommendations Dropdown (All Indian Cities)
                if (_showCitySuggestions && _citySuggestions.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 6, bottom: 8),
                    decoration: BoxDecoration(
                      color: AppColors.cardSurface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.7)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGold.withValues(alpha: 0.1),
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.location_city_rounded, size: 14, color: AppColors.lightGold),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Recommended Indian Cities (${_citySuggestions.length})',
                                    style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.lightGold),
                                  ),
                                ],
                              ),
                              InkWell(
                                onTap: () => setState(() => _showCitySuggestions = false),
                                child: const Icon(Icons.close_rounded, size: 14, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        Flexible(
                          child: ListView.separated(
                            shrinkWrap: true,
                            itemCount: _citySuggestions.length,
                            separatorBuilder: (context, index) => const Divider(color: Colors.white10, height: 1),
                            itemBuilder: (context, idx) {
                              final loc = _citySuggestions[idx];
                              return ListTile(
                                dense: true,
                                leading: const Icon(Icons.location_city_rounded, color: AppColors.lightGold, size: 16),
                                title: Text(
                                  '${loc.cityName}, ${loc.state}',
                                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w600),
                                ),
                                subtitle: Text(
                                  '${loc.country} | Lat: ${loc.latitude.toStringAsFixed(2)}°, Lon: ${loc.longitude.toStringAsFixed(2)}°',
                                  style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 10),
                                ),
                                onTap: () => _applyLocation(loc),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                // State Recommendations Dropdown (28 States & UTs)
                if (_showStateSuggestions && _stateSuggestions.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 6, bottom: 8),
                    decoration: BoxDecoration(
                      color: AppColors.cardSurface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.7)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGold.withValues(alpha: 0.1),
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.map_rounded, size: 14, color: AppColors.lightGold),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Indian States & UTs (${_stateSuggestions.length})',
                                    style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.lightGold),
                                  ),
                                ],
                              ),
                              InkWell(
                                onTap: () => setState(() => _showStateSuggestions = false),
                                child: const Icon(Icons.close_rounded, size: 14, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        Flexible(
                          child: ListView.separated(
                            shrinkWrap: true,
                            itemCount: _stateSuggestions.length,
                            separatorBuilder: (context, index) => const Divider(color: Colors.white10, height: 1),
                            itemBuilder: (context, idx) {
                              final st = _stateSuggestions[idx];
                              return ListTile(
                                dense: true,
                                leading: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryGold.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    st.code,
                                    style: GoogleFonts.outfit(color: AppColors.lightGold, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                title: Text(
                                  '${st.name} (${st.nameTamil})',
                                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w600),
                                ),
                                subtitle: Text(
                                  'Capital: ${st.capital} ${st.isUnionTerritory ? "(UT)" : "(State)"}',
                                  style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 10.5),
                                ),
                                onTap: () => _applyState(st),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 24),

                GoldenButton(
                  text: 'Save Horoscope Profile',
                  onPressed: _saveProfile,
                  icon: Icons.check_circle_rounded,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
