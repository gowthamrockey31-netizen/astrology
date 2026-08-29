import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';
import '../services/auth_service.dart';

class CosmicDrawer extends StatelessWidget {
  final Function(String routeName) onSelectRoute;
  final VoidCallback? onLogout;

  const CosmicDrawer({
    super.key,
    required this.onSelectRoute,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;
    final role = AuthService.activeRole;

    return Drawer(
      backgroundColor: AppColors.backgroundDeep,
      child: SafeArea(
        child: Column(
          children: [
            // Drawer Header with Cosmic Logo & Active Role Badge
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.purpleAccent, AppColors.backgroundMid],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.lightGold, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryGold.withValues(alpha: 0.4),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: const CircleAvatar(
                      backgroundColor: AppColors.backgroundDeep,
                      child: Icon(Icons.auto_awesome, color: AppColors.lightGold, size: 28),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? 'AstroDashaCare Seeker',
                          style: GoogleFonts.cinzel(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGold.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.6)),
                          ),
                          child: Text(
                            'Active Role: $role',
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.lightGold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Divider(color: AppColors.borderGold, height: 1),

            // Modules & Role Navigation List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 10),
                children: [
                  _buildSectionHeader('APPLICATION WORKSPACE'),

                  // Role-Based Drawer Filtering
                  if (role == 'User') ...[
                    _buildDrawerItem(
                      icon: Icons.dashboard_rounded,
                      title: 'User Dashboard',
                      subtitle: 'Consultations, Horoscope & Panchang',
                      isSelected: true,
                      onTap: () => onSelectRoute('/user_dashboard'),
                    ),
                  ] else if (role == 'Astrologer') ...[
                    _buildDrawerItem(
                      icon: Icons.psychology_rounded,
                      title: 'Astrologer Workspace',
                      subtitle: 'Dashboard, Calls, Kundli & Earnings',
                      isSelected: true,
                      onTap: () => onSelectRoute('/astrologer_dashboard'),
                    ),
                  ] else if (role == 'Admin') ...[
                    _buildDrawerItem(
                      icon: Icons.admin_panel_settings_rounded,
                      title: 'Admin Control Center',
                      subtitle: 'Approvals, CMS, T&C & Revenue',
                      isSelected: true,
                      onTap: () => onSelectRoute('/admin_dashboard'),
                    ),
                  ],

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Divider(color: Colors.white12),
                  ),

                  _buildSectionHeader('ஜாதக கணிதங்கள் & முறைகள் (ASTROLOGY SYSTEMS)'),
                  _buildDrawerItem(
                    icon: Icons.description_rounded,
                    title: 'பஞ்சாங்க / ஜாதக குறிப்புகள் (Panchanga & Notes)',
                    subtitle: 'பொது பஞ்சாங்கம், தினசுத்தி, அஷ்டவர்க்கம் & D1-D60',
                    onTap: () => onSelectRoute('/jaathaga_kurippugal'),
                  ),
                  _buildDrawerItem(
                    icon: Icons.grid_4x4_rounded,
                    title: 'ஜாதக சக்கரம் (Birth Chart)',
                    subtitle: 'Rasi, Navamsha, Padasaram & Settings',
                    onTap: () => onSelectRoute('/birth_chart'),
                  ),
                  _buildDrawerItem(
                    icon: Icons.compass_calibration_rounded,
                    title: 'ஜாமகோள் ஆருடம் (Jamakol Arudam)',
                    subtitle: 'உதயம், ஆருடம், கவிப்பு பிரசன்ன ஆய்வு',
                    onTap: () => onSelectRoute('/jamakol_arudam'),
                  ),
                  _buildDrawerItem(
                    icon: Icons.hub_rounded,
                    title: 'KP Astrology (உப நாத முறை)',
                    subtitle: '12 Cusps, Placidus Sub & Sub-Sub Lords',
                    onTap: () => onSelectRoute('/kp_astrology'),
                  ),
                  _buildDrawerItem(
                    icon: Icons.help_center_rounded,
                    title: 'KP Horary / பிரசன்னம் (1-249)',
                    subtitle: 'பிரசன்ன எண் முறை துல்லிய ஜாதகம்',
                    onTap: () => onSelectRoute('/kp_horary'),
                  ),
                  _buildDrawerItem(
                    icon: Icons.auto_awesome_motion_rounded,
                    title: 'பிருகு நந்தி நாடி முறை (Bhrigu Nandi Nadi)',
                    subtitle: 'திசை திரிகோண கிரக சேர்க்கைகள் & ஜீவ-கர்ம பலன்',
                    onTap: () => onSelectRoute('/bhrigu_nandi_nadi'),
                  ),
                  _buildDrawerItem(
                    icon: Icons.calculate_rounded,
                    title: 'எண்கணிதம் (Numerology)',
                    subtitle: 'பிறவி, விதி & பெயர் எண்கள் (Chaldean / Pythagorean)',
                    onTap: () => onSelectRoute('/numerology'),
                  ),
                  _buildDrawerItem(
                    icon: Icons.wb_sunny_rounded,
                    title: 'தினசரி கிரக நிலைகள் (Daily Ephemeris)',
                    subtitle: 'தினசரி கோட்சார கிரக பாகைகள் & ராசி நிலைகள்',
                    onTap: () => onSelectRoute('/daily_planet_positions'),
                  ),
                  _buildDrawerItem(
                    icon: Icons.calendar_month_rounded,
                    title: 'தினசரி நாள்காட்டி (Daily Calendar)',
                    subtitle: 'பஞ்சாங்கம், கௌரி நேரம், கோச்சார சக்கரம் & நிகழ்வுகள்',
                    onTap: () => onSelectRoute('/daily_calendar'),
                  ),
                  _buildDrawerItem(
                    icon: Icons.calendar_view_month_rounded,
                    title: 'மாத நாள்காட்டி (Month Calendar)',
                    subtitle: 'தமிழ் மாத பஞ்சாங்க அட்டவணை & நோக்கு நாள்',
                    onTap: () => onSelectRoute('/tamil_month_calendar'),
                  ),
                  _buildDrawerItem(
                    icon: Icons.picture_as_pdf_rounded,
                    title: 'PDF அமைப்புகள் (PDF Settings)',
                    subtitle: 'ஜோதிட நிலைய & வாடிக்கையாளர் விவரங்கள்',
                    onTap: () => onSelectRoute('/pdf_settings'),
                  ),
                  if (role == 'Admin')
                    _buildDrawerItem(
                      icon: Icons.public_rounded,
                      title: 'உலகியல் ஜோதிடம் (Mundane Astrology)',
                      subtitle: 'Mundane & Global Astrological Trends',
                      onTap: () => onSelectRoute('/mundane_astrology'),
                    ),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Divider(color: Colors.white12),
                  ),

                  _buildSectionHeader('பாரம்பரிய பலன்கள் (TRADITIONAL SERVICES)'),
                  _buildDrawerItem(
                    icon: Icons.favorite_rounded,
                    title: 'திருமண ஜாதகப் பொருத்தம்',
                    subtitle: 'Marriage Porutham Analysis (11 Poruthams)',
                    onTap: () => onSelectRoute('/marriage_porutham'),
                  ),
                  _buildDrawerItem(
                    icon: Icons.stars_rounded,
                    title: 'தாரா பலன்',
                    subtitle: 'Tara Balam Analysis & Nakshatra Strength',
                    onTap: () => onSelectRoute('/tara_balam'),
                  ),
                  _buildDrawerItem(
                    icon: Icons.flutter_dash_rounded,
                    title: 'பஞ்சபட்சி சாஸ்திரம்',
                    subtitle: 'Tamil Siddha Panchapakshi 5-Bird Science',
                    onTap: () => onSelectRoute('/panchapakshi'),
                  ),
                  _buildDrawerItem(
                    icon: Icons.access_time_filled_rounded,
                    title: 'நேரலை ஓரை (Live Hora)',
                    subtitle: 'Live Hora Schedule & Planetary Countdown',
                    onTap: () => onSelectRoute('/hora'),
                  ),
                  _buildDrawerItem(
                    icon: Icons.health_and_safety_rounded,
                    title: 'ஆயுள் கணிதம் (Pindayu Longevity)',
                    subtitle: 'Classical 7-Planet Longevity Calculation',
                    onTap: () => onSelectRoute('/longevity'),
                  ),
                  _buildDrawerItem(
                    icon: Icons.calendar_month_rounded,
                    title: 'Live Panchangam',
                    subtitle: 'Tithi, Nakshatra, Rahu Kalam',
                    onTap: () => onSelectRoute('/panchang'),
                  ),
                  _buildDrawerItem(
                    icon: Icons.smart_toy_rounded,
                    title: 'AI Horoscope Assistant',
                    subtitle: 'Ask AI Astrology Assistant',
                    onTap: () => onSelectRoute('/ai_assistant'),
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Divider(color: Colors.white12),
                  ),

                  // Role Switching / Administration Quick Links
                  _buildSectionHeader('SWITCH WORKSPACE'),
                  if (role != 'User')
                    _buildDrawerItem(
                      icon: Icons.person_pin_rounded,
                      title: 'Switch to User View',
                      subtitle: 'Browse AstroDashaCare as Client',
                      onTap: () {
                        AuthService.setActiveRole('User');
                        onSelectRoute('/user_dashboard');
                      },
                    ),
                  if (role != 'Astrologer')
                    _buildDrawerItem(
                      icon: Icons.psychology_alt_rounded,
                      title: 'Astrologer Portal',
                      subtitle: 'Login / Switch to Astrologer',
                      onTap: () {
                        AuthService.setActiveRole('Astrologer');
                        onSelectRoute('/astrologer_dashboard');
                      },
                    ),
                  if (role != 'Admin')
                    _buildDrawerItem(
                      icon: Icons.admin_panel_settings_outlined,
                      title: 'Admin Control Center',
                      subtitle: 'Authorize with Admin Access',
                      onTap: () {
                        AuthService.setActiveRole('Admin');
                        onSelectRoute('/admin_dashboard');
                      },
                    ),

                  const SizedBox(height: 12),
                ],
              ),
            ),

            // Logout Footer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.backgroundMid,
                border: Border(top: BorderSide(color: AppColors.borderGold, width: 0.5)),
              ),
              child: Material(
                color: Colors.transparent,
                child: ListTile(
                  leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                  title: Text(
                    'Log Out',
                    style: GoogleFonts.outfit(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  subtitle: Text(
                    'End active $role session',
                    style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 12),
                  ),
                  onTap: () {
                    if (onLogout != null) {
                      onLogout!();
                    } else {
                      AuthService.logout();
                      onSelectRoute('/login');
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, top: 12, bottom: 6),
      child: Text(
        title,
        style: GoogleFonts.cinzel(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryGold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isSelected = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primaryGold.withValues(alpha: 0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isSelected ? Border.all(color: AppColors.primaryGold, width: 1) : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          dense: true,
          leading: Icon(
            icon,
            color: isSelected ? AppColors.lightGold : AppColors.lightGold.withValues(alpha: 0.7),
            size: 22,
          ),
          title: Text(
            title,
            style: GoogleFonts.outfit(
              color: isSelected ? AppColors.lightGold : AppColors.textPrimary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              fontSize: 13.5,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: GoogleFonts.outfit(
              color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.textSecondary),
          onTap: onTap,
        ),
      ),
    );
  }
}
