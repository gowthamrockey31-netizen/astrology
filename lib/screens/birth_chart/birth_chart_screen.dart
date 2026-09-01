import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/geocoding_service.dart';
import '../../widgets/cosmic_background.dart';
import '../../widgets/south_indian_jathagam_widget.dart';

class BirthChartScreen extends StatefulWidget {
  const BirthChartScreen({super.key});

  @override
  State<BirthChartScreen> createState() => _BirthChartScreenState();
}

class _BirthChartScreenState extends State<BirthChartScreen> {
  late UserModel _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  void _loadUser() {
    _user = AuthService.currentUser ??
        UserModel(
          id: 'default_seeker',
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
  }

  void _showUpdateBirthDetailsDialog() {
    final nameCtrl = TextEditingController(text: _user.name);
    DateTime selectedDob = DateTime.tryParse(_user.dob) ?? DateTime(1996, 6, 15);
    TimeOfDay selectedTob = const TimeOfDay(hour: 8, minute: 30);
    try {
      final rawTob = _user.timeOfBirth.trim();
      final isPm = rawTob.toLowerCase().contains('pm');
      final isAm = rawTob.toLowerCase().contains('am');
      final digits = RegExp(r'(\d+):(\d+)').firstMatch(rawTob);
      if (digits != null) {
        int h = int.parse(digits.group(1)!);
        int m = int.parse(digits.group(2)!);
        if (isPm && h < 12) h += 12;
        if (isAm && h == 12) h = 0;
        selectedTob = TimeOfDay(hour: h, minute: m);
      }
    } catch (_) {}
    final tobCtrl = TextEditingController(text: _user.timeOfBirth.isNotEmpty ? _user.timeOfBirth : selectedTob.format(context));
    final pobCtrl = TextEditingController(text: _user.placeOfBirth);
    final latCtrl = TextEditingController(text: _user.latitude.toString());
    final lonCtrl = TextEditingController(text: _user.longitude.toString());
    String selectedGender = _user.gender.isNotEmpty ? _user.gender : 'Male';
    if (selectedGender != 'Male' && selectedGender != 'Female' && selectedGender != 'Other') {
      selectedGender = 'Other';
    }

    List<GeocodingLocation> suggestions = [];
    bool showSuggestions = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.backgroundDeep,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        side: BorderSide(color: AppColors.primaryGold, width: 1.5),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(modalCtx).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.edit_calendar_rounded, color: AppColors.lightGold, size: 24),
                        const SizedBox(width: 10),
                        Text(
                          'பிறப்பு விவரங்கள் திருத்தம்',
                          style: GoogleFonts.cinzel(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.lightGold,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                          onPressed: () => Navigator.of(ctx).pop(),
                        ),
                      ],
                    ),
                    const Divider(color: AppColors.borderGold, height: 20),
                    const SizedBox(height: 8),

                    // Name
                    _buildTextField(nameCtrl, 'பெயர் (Name)', Icons.person_rounded),
                    const SizedBox(height: 12),

                    // DOB (DD / MM / YYYY) & TOB
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: selectedDob,
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
                                setModalState(() => selectedDob = picked);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: AppColors.cardSurface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.borderGold.withValues(alpha: 0.5)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'பிறந்த தேதி (Date / Month / Year)',
                                    style: GoogleFonts.outfit(fontSize: 10, color: AppColors.textSecondary),
                                  ),
                                  const SizedBox(height: 3),
                                  Row(
                                    children: [
                                      const Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.lightGold),
                                      const SizedBox(width: 6),
                                      Text(
                                        DateFormat('dd / MM / yyyy').format(selectedDob),
                                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              final picked = await showTimePicker(
                                context: context,
                                initialTime: selectedTob,
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
                                setModalState(() {
                                  selectedTob = picked;
                                  tobCtrl.text = selectedTob.format(context);
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: AppColors.cardSurface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.borderGold.withValues(alpha: 0.5)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'பிறந்த நேரம் (Time of Birth)',
                                    style: GoogleFonts.outfit(fontSize: 10, color: AppColors.textSecondary),
                                  ),
                                  const SizedBox(height: 3),
                                  Row(
                                    children: [
                                      const Icon(Icons.access_time_rounded, size: 14, color: AppColors.lightGold),
                                      const SizedBox(width: 6),
                                      Text(
                                        selectedTob.format(context),
                                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12),
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
                    const SizedBox(height: 12),

                    // Place of birth with live suggestions & auto Lat/Lon
                    TextField(
                      controller: pobCtrl,
                      style: GoogleFonts.outfit(color: Colors.white, fontSize: 13),
                      onChanged: (val) async {
                        if (val.trim().length >= 2) {
                          final results = await GeocodingService.searchPlaces(val);
                          setModalState(() {
                            suggestions = results;
                            showSuggestions = results.isNotEmpty;
                          });
                        } else {
                          setModalState(() => showSuggestions = false);
                        }
                      },
                      decoration: InputDecoration(
                        labelText: 'பிறந்த ஊர் (Place of Birth)',
                        hintText: 'Type city e.g. Coimbatore, Madurai',
                        labelStyle: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 12),
                        prefixIcon: const Icon(Icons.location_on_rounded, color: AppColors.lightGold, size: 18),
                        filled: true,
                        fillColor: AppColors.cardSurface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.borderGold, width: 0.8),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.borderGold.withValues(alpha: 0.5)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.primaryGold, width: 1.2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),

                    // Suggestions dropdown
                    if (showSuggestions && suggestions.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(top: 4, bottom: 8),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundMid,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.6)),
                        ),
                        constraints: const BoxConstraints(maxHeight: 160),
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: suggestions.length,
                          separatorBuilder: (context, index) => const Divider(color: Colors.white10, height: 1),
                          itemBuilder: (context, idx) {
                            final loc = suggestions[idx];
                            return ListTile(
                              dense: true,
                              leading: const Icon(Icons.place, color: AppColors.lightGold, size: 16),
                              title: Text(
                                loc.displayName,
                                style: GoogleFonts.outfit(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text(
                                'Lat: ${loc.latitude.toStringAsFixed(4)}, Lon: ${loc.longitude.toStringAsFixed(4)}',
                                style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 10),
                              ),
                              onTap: () {
                                setModalState(() {
                                  pobCtrl.text = loc.cityName;
                                  latCtrl.text = loc.latitude.toString();
                                  lonCtrl.text = loc.longitude.toString();
                                  showSuggestions = false;
                                });
                              },
                            );
                          },
                        ),
                      ),

                    const SizedBox(height: 12),

                    // Latitude & Longitude (Editable)
                    Row(
                      children: [
                        Expanded(child: _buildTextField(latCtrl, 'அட்சரேகை (Latitude)', Icons.my_location_rounded)),
                        const SizedBox(width: 10),
                        Expanded(child: _buildTextField(lonCtrl, 'தீர்க்கரேகை (Longitude)', Icons.explore_rounded)),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Standard Gender Selector: Male / Female / Other
                    Row(
                      children: [
                        Text('பாலினம்: ', style: GoogleFonts.outfit(color: AppColors.lightGold, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 12),
                        ...['Male', 'Female', 'Other'].map((g) {
                          final isSel = selectedGender == g;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(g, style: GoogleFonts.outfit(fontSize: 12, fontWeight: isSel ? FontWeight.bold : FontWeight.normal)),
                              selected: isSel,
                              selectedColor: AppColors.primaryGold.withValues(alpha: 0.35),
                              onSelected: (val) => setModalState(() => selectedGender = g),
                            ),
                          );
                        }),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGold,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: () {
                          final lat = double.tryParse(latCtrl.text.trim());
                          final lon = double.tryParse(lonCtrl.text.trim());
                          if (lat == null || lon == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Location not found. Please select a valid place.', style: GoogleFonts.outfit(color: Colors.white)),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                            return;
                          }

                          final isoDob = DateFormat('yyyy-MM-dd').format(selectedDob);
                          final updatedUser = _user.copyWith(
                            name: nameCtrl.text.trim(),
                            dob: isoDob,
                            timeOfBirth: tobCtrl.text.trim(),
                            placeOfBirth: pobCtrl.text.trim(),
                            gender: selectedGender,
                            latitude: lat,
                            longitude: lon,
                          );

                          AuthService.updateCurrentUser(updatedUser);
                          setState(() {
                            _user = updatedUser;
                          });

                          Navigator.of(ctx).pop();

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'பிறப்பு விவரங்கள் புதுப்பிக்கப்பட்டன. ஜாதகம் மறு கணக்கீடு செய்யப்பட்டது!',
                                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.black),
                              ),
                              backgroundColor: AppColors.primaryGold,
                            ),
                          );
                        },
                        child: Text(
                          'சேமி & மறு கணக்கீடு செய் (Update Chart)',
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String label, IconData icon) {
    return TextField(
      controller: ctrl,
      style: GoogleFonts.outfit(color: Colors.white, fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 12),
        prefixIcon: Icon(icon, color: AppColors.lightGold, size: 18),
        filled: true,
        fillColor: AppColors.cardSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderGold, width: 0.8),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.borderGold.withValues(alpha: 0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryGold, width: 1.2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.lightGold),
                    ),
                    Text(
                      'Birth Chart',
                      style: GoogleFonts.cinzel(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.lightGold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.settings_rounded, color: AppColors.primaryGold, size: 26),
                      tooltip: 'Settings & Update Birth Details',
                      onPressed: _showUpdateBirthDetailsDialog,
                    ),
                  ],
                ).animate().fade(duration: 500.ms),
                const SizedBox(height: 4),
                Text(
                  'ஜாதக வரைபடம் • Vedic Kundali (Rasi, Navamsha & Pathasaram)',
                  style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 12),
                ).animate().fade(delay: 100.ms),
                const SizedBox(height: 20),

                // Full South Indian Jathagam Chart (Rasi, Navamsha & Natchathira Pathasaram)
                SouthIndianJathagamWidget(user: _user).animate().fade(delay: 150.ms),

                const SizedBox(height: 24),
                _buildConsultBanner(context).animate().fade(delay: 500.ms),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConsultBanner(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed('/user_dashboard'),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            colors: [
              AppColors.purpleAccent.withValues(alpha: 0.3),
              AppColors.blueAccent.withValues(alpha: 0.2),
            ],
          ),
          border: Border.all(color: AppColors.borderGold.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            const Icon(Icons.psychology_rounded, color: AppColors.lightGold, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Get Expert Analysis',
                    style: GoogleFonts.cinzel(
                      color: AppColors.lightGold,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    'Consult an astrologer for deep chart reading',
                    style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: AppColors.lightGold, size: 16),
          ],
        ),
      ),
    );
  }
}
