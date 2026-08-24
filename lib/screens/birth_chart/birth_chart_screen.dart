import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
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
    final dobCtrl = TextEditingController(text: _user.dob);
    final tobCtrl = TextEditingController(text: _user.timeOfBirth);
    final pobCtrl = TextEditingController(text: _user.placeOfBirth);
    final latCtrl = TextEditingController(text: _user.latitude.toString());
    final lonCtrl = TextEditingController(text: _user.longitude.toString());
    String selectedGender = _user.gender;

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

                    // DOB & TOB
                    Row(
                      children: [
                        Expanded(child: _buildTextField(dobCtrl, 'பிறந்த தேதி (YYYY-MM-DD)', Icons.calendar_today_rounded)),
                        const SizedBox(width: 10),
                        Expanded(child: _buildTextField(tobCtrl, 'பிறந்த நேரம் (HH:MM AM/PM)', Icons.access_time_rounded)),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Place of birth
                    _buildTextField(pobCtrl, 'பிறந்த ஊர் (Place of Birth)', Icons.location_on_rounded),
                    const SizedBox(height: 12),

                    // Latitude & Longitude
                    Row(
                      children: [
                        Expanded(child: _buildTextField(latCtrl, 'அட்சரேகை (Latitude)', Icons.my_location_rounded)),
                        const SizedBox(width: 10),
                        Expanded(child: _buildTextField(lonCtrl, 'தீர்க்கரேகை (Longitude)', Icons.explore_rounded)),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Gender Selector
                    Row(
                      children: [
                        Text('பாலினம்: ', style: GoogleFonts.outfit(color: AppColors.lightGold, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 12),
                        ChoiceChip(
                          label: Text('ஆண் (Male)', style: GoogleFonts.outfit(fontSize: 12)),
                          selected: selectedGender == 'Male',
                          selectedColor: AppColors.primaryGold.withValues(alpha: 0.3),
                          onSelected: (val) => setModalState(() => selectedGender = 'Male'),
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: Text('பெண் (Female)', style: GoogleFonts.outfit(fontSize: 12)),
                          selected: selectedGender == 'Female',
                          selectedColor: AppColors.primaryGold.withValues(alpha: 0.3),
                          onSelected: (val) => setModalState(() => selectedGender = 'Female'),
                        ),
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
                          final updatedUser = _user.copyWith(
                            name: nameCtrl.text.trim(),
                            dob: dobCtrl.text.trim(),
                            timeOfBirth: tobCtrl.text.trim(),
                            placeOfBirth: pobCtrl.text.trim(),
                            gender: selectedGender,
                            latitude: double.tryParse(latCtrl.text.trim()) ?? _user.latitude,
                            longitude: double.tryParse(lonCtrl.text.trim()) ?? _user.longitude,
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
