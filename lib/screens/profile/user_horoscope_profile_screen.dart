import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../models/user_model.dart';
import '../../services/astrology_calculator.dart';
import '../../services/auth_service.dart';
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
    }
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
                            color: selected ? AppColors.primaryGold.withOpacity(0.2) : AppColors.cardSurface,
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
                            border: Border.all(color: AppColors.borderGold.withOpacity(0.5)),
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
                                    DateFormat('dd MMM yyyy').format(_dob),
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
                            border: Border.all(color: AppColors.borderGold.withOpacity(0.5)),
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

                const SizedBox(height: 14),

                GoldenTextField(
                  label: 'Place of Birth',
                  hint: 'e.g. Hospital / Area',
                  prefixIcon: Icons.place_rounded,
                  controller: _placeController,
                ),

                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      child: GoldenTextField(
                        label: 'City',
                        hint: 'City',
                        prefixIcon: Icons.location_city_rounded,
                        controller: _cityController,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GoldenTextField(
                        label: 'State',
                        hint: 'State',
                        prefixIcon: Icons.map_rounded,
                        controller: _stateController,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Astrological Details Section Header with Auto-Calculate Action
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Astrological Details',
                      style: GoogleFonts.cinzel(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.lightGold,
                      ),
                    ),
                    InkWell(
                      onTap: _recalculateAstrology,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGold.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.primaryGold.withOpacity(0.5)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.auto_awesome, size: 14, color: AppColors.lightGold),
                            const SizedBox(width: 4),
                            Text(
                              'Auto-Calculate',
                              style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.lightGold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Zodiac Sign Dropdown
                _buildDropdownField(
                  label: 'Zodiac Sign (Rasi)',
                  value: _selectedZodiac,
                  items: AppConstants.zodiacSigns,
                  icon: Icons.wb_sunny_rounded,
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedZodiac = val);
                  },
                ),

                const SizedBox(height: 14),

                // Nakshatra Dropdown
                _buildDropdownField(
                  label: 'Nakshatra (Star)',
                  value: _selectedNakshatra,
                  items: AppConstants.nakshatras,
                  icon: Icons.auto_awesome_rounded,
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedNakshatra = val);
                  },
                ),

                const SizedBox(height: 20),

                // Summary Astro Badges
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundMid,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primaryGold, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryGold.withOpacity(0.2),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.stars_rounded, color: AppColors.lightGold, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'ACTIVE HOROSCOPE PROFILE',
                            style: GoogleFonts.cinzel(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.lightGold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildAstroBadge('ZODIAC', _selectedZodiac),
                          _buildAstroBadge('NAKSHATRA', _selectedNakshatra),
                        ],
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

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required IconData icon,
    required ValueChanged<String?> onChanged,
  }) {
    String safeValue = items.contains(value)
        ? value
        : (items.firstWhere(
            (item) => item.toLowerCase().contains(value.toLowerCase()) || value.toLowerCase().contains(item.toLowerCase()),
            orElse: () => items.first,
          ));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.outfit(color: AppColors.lightGold, fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderGold.withOpacity(0.5)),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.lightGold, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: safeValue,
                    isExpanded: true,
                    dropdownColor: AppColors.backgroundMid,
                    style: GoogleFonts.outfit(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.bold),
                    icon: const Icon(Icons.arrow_drop_down_rounded, color: AppColors.lightGold),
                    items: items.map((String item) {
                      return DropdownMenuItem<String>(
                        value: item,
                        child: Text(
                          item,
                          style: GoogleFonts.outfit(color: AppColors.textPrimary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: onChanged,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAstroBadge(String title, String value) {
    return Column(
      children: [
        Text(title, style: GoogleFonts.outfit(fontSize: 10, color: AppColors.textSecondary, letterSpacing: 1)),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
